Return-Path: <SRS0=hmK5=JT=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,INCLUDES_CR_TRAILER,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E5FDC43460
	for <containers@archiver.kernel.org>; Thu, 22 Apr 2021 12:27:56 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2975F61476
	for <containers@archiver.kernel.org>; Thu, 22 Apr 2021 12:27:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2975F61476
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id BB58440203;
	Thu, 22 Apr 2021 12:27:55 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id QibQ7-WWQSqX; Thu, 22 Apr 2021 12:27:54 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp2.osuosl.org (Postfix) with ESMTP id 9C3AE4021E;
	Thu, 22 Apr 2021 12:27:54 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 7671CC000F;
	Thu, 22 Apr 2021 12:27:54 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [IPv6:2605:bc80:3010::138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 23DF8C000F
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Apr 2021 12:27:53 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id E718F83D6B
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Apr 2021 12:27:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Authentication-Results: smtp1.osuosl.org (amavisd-new);
 dkim=pass (2048-bit key) header.d=kernel.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id Ypy2AVgi_1-R
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Apr 2021 12:27:52 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by smtp1.osuosl.org (Postfix) with ESMTPS id 38DE783D5F
 for <containers@lists.linux-foundation.org>;
 Thu, 22 Apr 2021 12:27:52 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 1106761466;
 Thu, 22 Apr 2021 12:27:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=k20201202; t=1619094470;
 bh=wGjk7sHNDH4H8Q8/yo1q/j8Yxn9l6/bqhk94/LFC13A=;
 h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
 b=hb2FrSFbJ3Imx+TzBbkBU2/s1t5J1SGKH7EjMYNJzqSzGWa4TSt1vpeIWMboR49mr
 CvfUqrUFF4gggg/5sKHZ8KELNaJfxoX1Y/ZJUQtFIYekqStct5z8wKkp0KneW3wcOC
 tBRd17veoz3PvQC2O8Uvd9/XzIQxtOTUJcRMyeo48Cv9/BsnSG1I+pbGcQtZz5yjQi
 7LFv5iGWti5FkzZTYUlxZvcK9NQ/LB56OQ4WxHl4shJKliKKI0pPUls6i/hofLYTMf
 IC7oIYERcCgrEq/9aFcMvYDySY6mLEtj+kG2Q5IjdavDsIZeTc4TQWqiWts6T+z7nj
 Jzi/d4b6C5UDA==
From: legion@kernel.org
To: LKML <linux-kernel@vger.kernel.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux Containers <containers@lists.linux-foundation.org>,
 linux-mm@kvack.org
Subject: [PATCH v11 6/9] Reimplement RLIMIT_SIGPENDING on top of ucounts
Date: Thu, 22 Apr 2021 14:27:13 +0200
Message-Id: <df9d7764dddd50f28616b7840de74ec0f81711a8.1619094428.git.legion@kernel.org>
X-Mailer: git-send-email 2.29.3
In-Reply-To: <cover.1619094428.git.legion@kernel.org>
References: <cover.1619094428.git.legion@kernel.org>
MIME-Version: 1.0
Cc: Jens Axboe <axboe@kernel.dk>, Kees Cook <keescook@chromium.org>,
 Jann Horn <jannh@google.com>, Linus Torvalds <torvalds@linux-foundation.org>,
 Oleg Nesterov <oleg@redhat.com>, "Eric W . Biederman" <ebiederm@xmission.com>,
 Andrew Morton <akpm@linux-foundation.org>, Alexey Gladkov <legion@kernel.org>,
 Christian Brauner <christian.brauner@ubuntu.com>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

From: Alexey Gladkov <legion@kernel.org>

The rlimit counter is tied to uid in the user_namespace. This allows
rlimit values to be specified in userns even if they are already
globally exceeded by the user. However, the value of the previous
user_namespaces cannot be exceeded.

Changelog

v11:
* Revert most of changes to fix performance issues.

v10:
* Fix memory leak on get_ucounts failure.

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 fs/proc/array.c                |  2 +-
 include/linux/sched/user.h     |  1 -
 include/linux/signal_types.h   |  4 +++-
 include/linux/user_namespace.h |  1 +
 kernel/fork.c                  |  1 +
 kernel/signal.c                | 25 +++++++++++++------------
 kernel/ucount.c                |  1 +
 kernel/user.c                  |  1 -
 kernel/user_namespace.c        |  1 +
 9 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/fs/proc/array.c b/fs/proc/array.c
index bb87e4d89cd8..74b0ea4b7e38 100644
--- a/fs/proc/array.c
+++ b/fs/proc/array.c
@@ -284,7 +284,7 @@ static inline void task_sig(struct seq_file *m, struct task_struct *p)
 		collect_sigign_sigcatch(p, &ignored, &caught);
 		num_threads = get_nr_threads(p);
 		rcu_read_lock();  /* FIXME: is this correct? */
-		qsize = atomic_read(&__task_cred(p)->user->sigpending);
+		qsize = get_ucounts_value(task_ucounts(p), UCOUNT_RLIMIT_SIGPENDING);
 		rcu_read_unlock();
 		qlim = task_rlimit(p, RLIMIT_SIGPENDING);
 		unlock_task_sighand(p, &flags);
diff --git a/include/linux/sched/user.h b/include/linux/sched/user.h
index 8a34446681aa..8ba9cec4fb99 100644
--- a/include/linux/sched/user.h
+++ b/include/linux/sched/user.h
@@ -12,7 +12,6 @@
  */
 struct user_struct {
 	refcount_t __count;	/* reference count */
-	atomic_t sigpending;	/* How many pending signals does this user have? */
 #ifdef CONFIG_FANOTIFY
 	atomic_t fanotify_listeners;
 #endif
diff --git a/include/linux/signal_types.h b/include/linux/signal_types.h
index 68e06c75c5b2..34cb28b8f16c 100644
--- a/include/linux/signal_types.h
+++ b/include/linux/signal_types.h
@@ -13,6 +13,8 @@ typedef struct kernel_siginfo {
 	__SIGINFO;
 } kernel_siginfo_t;
 
+struct ucounts;
+
 /*
  * Real Time signals may be queued.
  */
@@ -21,7 +23,7 @@ struct sigqueue {
 	struct list_head list;
 	int flags;
 	kernel_siginfo_t info;
-	struct user_struct *user;
+	struct ucounts *ucounts;
 };
 
 /* flags values. */
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 21ad1ad1b990..0e961bd8a090 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -52,6 +52,7 @@ enum ucount_type {
 #endif
 	UCOUNT_RLIMIT_NPROC,
 	UCOUNT_RLIMIT_MSGQUEUE,
+	UCOUNT_RLIMIT_SIGPENDING,
 	UCOUNT_COUNTS,
 };
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 85c6094f5a48..741f896c156e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -824,6 +824,7 @@ void __init fork_init(void)
 
 	init_user_ns.ucount_max[UCOUNT_RLIMIT_NPROC] = task_rlimit(&init_task, RLIMIT_NPROC);
 	init_user_ns.ucount_max[UCOUNT_RLIMIT_MSGQUEUE] = task_rlimit(&init_task, RLIMIT_MSGQUEUE);
+	init_user_ns.ucount_max[UCOUNT_RLIMIT_SIGPENDING] = task_rlimit(&init_task, RLIMIT_SIGPENDING);
 
 #ifdef CONFIG_VMAP_STACK
 	cpuhp_setup_state(CPUHP_BP_PREPARE_DYN, "fork:vm_stack_cache",
diff --git a/kernel/signal.c b/kernel/signal.c
index f2a1b898da29..92383b890b35 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -414,8 +414,8 @@ static struct sigqueue *
 __sigqueue_alloc(int sig, struct task_struct *t, gfp_t flags, int override_rlimit)
 {
 	struct sigqueue *q = NULL;
-	struct user_struct *user;
-	int sigpending;
+	struct ucounts *ucounts = NULL;
+	long sigpending;
 
 	/*
 	 * Protect access to @t credentials. This can go away when all
@@ -426,27 +426,26 @@ __sigqueue_alloc(int sig, struct task_struct *t, gfp_t flags, int override_rlimi
 	 * changes from/to zero.
 	 */
 	rcu_read_lock();
-	user = __task_cred(t)->user;
-	sigpending = atomic_inc_return(&user->sigpending);
+	ucounts = task_ucounts(t);
+	sigpending = inc_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1);
 	if (sigpending == 1)
-		get_uid(user);
+		ucounts = get_ucounts(ucounts);
 	rcu_read_unlock();
 
-	if (override_rlimit || likely(sigpending <= task_rlimit(t, RLIMIT_SIGPENDING))) {
+	if (override_rlimit || (sigpending < LONG_MAX && sigpending <= task_rlimit(t, RLIMIT_SIGPENDING))) {
 		q = kmem_cache_alloc(sigqueue_cachep, flags);
 	} else {
 		print_dropped_signal(sig);
 	}
 
 	if (unlikely(q == NULL)) {
-		if (atomic_dec_and_test(&user->sigpending))
-			free_uid(user);
+		if (ucounts && dec_rlimit_ucounts(ucounts, UCOUNT_RLIMIT_SIGPENDING, 1))
+			put_ucounts(ucounts);
 	} else {
 		INIT_LIST_HEAD(&q->list);
 		q->flags = 0;
-		q->user = user;
+		q->ucounts = ucounts;
 	}
-
 	return q;
 }
 
@@ -454,8 +453,10 @@ static void __sigqueue_free(struct sigqueue *q)
 {
 	if (q->flags & SIGQUEUE_PREALLOC)
 		return;
-	if (atomic_dec_and_test(&q->user->sigpending))
-		free_uid(q->user);
+	if (q->ucounts && dec_rlimit_ucounts(q->ucounts, UCOUNT_RLIMIT_SIGPENDING, 1)) {
+		put_ucounts(q->ucounts);
+		q->ucounts = NULL;
+	}
 	kmem_cache_free(sigqueue_cachep, q);
 }
 
diff --git a/kernel/ucount.c b/kernel/ucount.c
index 6e6f936a5963..8ce62da6a62c 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -80,6 +80,7 @@ static struct ctl_table user_table[] = {
 	UCOUNT_ENTRY("max_inotify_instances"),
 	UCOUNT_ENTRY("max_inotify_watches"),
 #endif
+	{ },
 	{ },
 	{ },
 	{ }
diff --git a/kernel/user.c b/kernel/user.c
index 7f5ff498207a..6737327f83be 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -98,7 +98,6 @@ static DEFINE_SPINLOCK(uidhash_lock);
 /* root_user.__count is 1, for init task cred */
 struct user_struct root_user = {
 	.__count	= REFCOUNT_INIT(1),
-	.sigpending	= ATOMIC_INIT(0),
 	.locked_shm     = 0,
 	.uid		= GLOBAL_ROOT_UID,
 	.ratelimit	= RATELIMIT_STATE_INIT(root_user.ratelimit, 0, 0),
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index cc90d5203acf..df1bed32dd48 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -123,6 +123,7 @@ int create_user_ns(struct cred *new)
 	}
 	ns->ucount_max[UCOUNT_RLIMIT_NPROC] = rlimit(RLIMIT_NPROC);
 	ns->ucount_max[UCOUNT_RLIMIT_MSGQUEUE] = rlimit(RLIMIT_MSGQUEUE);
+	ns->ucount_max[UCOUNT_RLIMIT_SIGPENDING] = rlimit(RLIMIT_SIGPENDING);
 	ns->ucounts = ucounts;
 
 	/* Inherit USERNS_SETGROUPS_ALLOWED from our parent */
-- 
2.29.3

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
