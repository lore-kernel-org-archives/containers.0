Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3356F72
	for <containers@lists.linux.dev>; Fri,  2 Jul 2021 17:54:58 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id BF18961402;
	Fri,  2 Jul 2021 17:54:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1625248497;
	bh=ig/YK/r/5aLCR4xsEWigroc4/rfDVngvQX1gzhgNYiY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=nNXGNTep34Cgwd/OvUI5QhxtTKbZ1bqzOHzVc9Z9Q/gsXGxr+/ahJsB42AhZrrC/J
	 NEpgegDa2Ysbpfp+s+gkTetfnbQgugHPvUacyndQ1kZFpKoc/t5FtEuRe9spMIHQFv
	 gkEXVERrla99tcynuXPqU1gTjGHfg42RxtoK6idyoH4xKiH3iyVCj0QHamKCtzz2kT
	 4TQXfOIlx5GvqCJpLSL7GFCa2IU5cA0rtii/3wdscbfrHlsBihcQ6kBtLZ5dw2+AWx
	 cLCW8AUy+mTXNhpf8Pfunhn6AfvkGBpLiA+xr76h0yPSNlLX07ie0CHaR3tUKQk/Rp
	 rfxxF3V8UAe8Q==
From: Alexey Gladkov <legion@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux.dev>,
	Alexey Gladkov <legion@kernel.org>
Subject: [PATCH] ucounts: Fix UCOUNT_RLIMIT_SIGPENDING counter leak
Date: Fri,  2 Jul 2021 19:54:42 +0200
Message-Id: <20210702175442.1603082-1-legion@kernel.org>
X-Mailer: git-send-email 2.29.3
In-Reply-To: <CAHk-=wjQks3o_3=WewaXw++h+a318B3LTLSFER9Ee4n1pLCZLw@mail.gmail.com>
References: <CAHk-=wjQks3o_3=WewaXw++h+a318B3LTLSFER9Ee4n1pLCZLw@mail.gmail.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

If get_ucounts() could not increase the reference counter, then in case
of an error it will be impossible to decrease the counter.

In case of an error, the ucounts variable cannot be set to NULL. Also
dec_rlimit_ucounts() has to be REGARDLESS of whether get_ucounts() was
successful or not.

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 kernel/signal.c | 25 ++++++++++++++++++-------
 1 file changed, 18 insertions(+), 7 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index de0920353d30..87a64b3307a8 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -412,7 +412,7 @@ __sigqueue_alloc(int sig, struct task_struct *t, gfp_t gfp_flags,
 		 int override_rlimit, const unsigned int sigqueue_flags)
 {
 	struct sigqueue *q = NULL;
-	struct ucounts *ucounts = NULL;
+	struct ucounts *ucounts, *ucounts_new;
 	long sigpending;
 
 	/*
@@ -424,10 +424,10 @@ __sigqueue_alloc(int sig, struct task_struct *t, gfp_t gfp_flags,
 	 * changes from/to zero.
 	 */
 	rcu_read_lock();
-	ucounts = task_ucounts(t);
+	ucounts = ucounts_new = task_ucounts(t);
 	sigpending = inc_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1);
 	if (sigpending == 1)
-		ucounts = get_ucounts(ucounts);
+		ucounts_new = get_ucounts(ucounts);
 	rcu_read_unlock();
 
 	if (override_rlimit || (sigpending < LONG_MAX && sigpending <= task_rlimit(t, RLIMIT_SIGPENDING))) {
@@ -437,13 +437,24 @@ __sigqueue_alloc(int sig, struct task_struct *t, gfp_t gfp_flags,
 	}
 
 	if (unlikely(q == NULL)) {
-		if (ucounts && dec_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1))
-			put_ucounts(ucounts);
+		ucounts_new = NULL;
 	} else {
 		INIT_LIST_HEAD(&q->list);
 		q->flags = sigqueue_flags;
-		q->ucounts = ucounts;
+		q->ucounts = ucounts_new;
 	}
+
+	/*
+	 * In case it failed to allocate sigqueue or ucounts reference counter
+	 * overflow, we decrement UCOUNT_RLIMIT_SIGPENDING to avoid counter
+	 * leaks.
+	 */
+	if (unlikely(ucounts_new == NULL)) {
+		dec_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1);
+		if (sigpending == 1)
+			put_ucounts(ucounts);
+	}
+
 	return q;
 }
 
@@ -451,7 +462,7 @@ static void __sigqueue_free(struct sigqueue *q)
 {
 	if (q->flags & SIGQUEUE_PREALLOC)
 		return;
-	if (q->ucounts && dec_rlimit_ucounts(q->ucounts, UCOUNT_RLIMIT_SIGPENDING, 1)) {
+	if (dec_rlimit_ucounts(q->ucounts, UCOUNT_RLIMIT_SIGPENDING, 1)) {
 		put_ucounts(q->ucounts);
 		q->ucounts = NULL;
 	}
-- 
2.29.3

