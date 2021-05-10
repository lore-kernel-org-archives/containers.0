Received: from mail-qt1-f180.google.com (mail-qt1-f180.google.com [209.85.160.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D7D8672
	for <containers@lists.linux.dev>; Mon, 10 May 2021 17:22:55 +0000 (UTC)
Received: by mail-qt1-f180.google.com with SMTP id c10so2683601qtx.10
        for <containers@lists.linux.dev>; Mon, 10 May 2021 10:22:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=FxC8T+rJG0U6XdX85ee7SQmwf4kbHHeX6/rEu4K2jD0=;
        b=SxedVWZHDaPTpbUyYsCp/n/pHksJPKMM1g7XZ8JwTJ/mfLsfZmIBnS+Se8lBRR0UMF
         1mfH+Kw/ZpjgQSlE+m3yZe2k+dySKsP3I3N8uiibnWf4yy5qq3t89J3mXKn1WDAzvJuJ
         MdDOYPs+1KnmaQOoW6zy3Hrh6YfbPvvGJiaee2MmesFrQ5wHCjIrMNW5N8exqXBARQ+3
         vY8Xb15EQ62KR4RJnLvV5GioHdAPkgDRr9EQIfXup1L+CxNsp/ir/ogWNIzQ0QYPuzmV
         yr728pJfDvWNO5g5RWoWi8zaXQQvyJUjTfTr8hLjc3yz9v+eMvA0pPMsMnq8eXnJXd7H
         dfSg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=FxC8T+rJG0U6XdX85ee7SQmwf4kbHHeX6/rEu4K2jD0=;
        b=q+xsiXzAPaNV+QZTehcftW6HPzoftVkvh0MiMVsG4s7ow7vdG0lQQ2PzZhzSfNr6Dg
         9an8ZtZZdBDg4AmxzXWGFkwdXXgrxsbsXLbxvk1xRuQzA4nOJ/L7uweHczxoKTcqSFEd
         USc/+kaQoa2ZSZHw/Uc5EO5FcR+3wh54RMWCSmI5vQjU370s1jXyR+y5g6K+qrKxYg9S
         8WuBzVJAZ/zzR5vzWX0w76bFJISG9/f6bDBs9FlyC0DDegyfvspmoYS1x6orLZH5NMgF
         ck75AYg4OXO8RT3/UonXxDQP05XkY70GG0RMpxBnbWJGzLYodxmAqDn3kxF14abUINa+
         XqEA==
X-Gm-Message-State: AOAM533RCciVlpxXWfib5jV0N9QJvy0iqKAqth34lsbucEfzpi8r77vU
	+fPOdX1BWn4BTtzJ4yJ5XgJBluFNjgL4t54C
X-Google-Smtp-Source: ABdhPJyok2Q0sLHaOx49Q1pv4EBKBzf1u1Y3McLpEUlNJFFkoyj7UAfmO/oIHBDkgCh+Bxo4XMoQCw==
X-Received: by 2002:a05:622a:130a:: with SMTP id v10mr10280864qtk.113.1620667374449;
        Mon, 10 May 2021 10:22:54 -0700 (PDT)
Received: from localhost.localdomain (host-173-230-99-154.tnkngak.clients.pavlovmedia.com. [173.230.99.154])
        by smtp.gmail.com with ESMTPSA id q7sm11924367qki.17.2021.05.10.10.22.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 10 May 2021 10:22:54 -0700 (PDT)
From: YiFei Zhu <zhuyifei1999@gmail.com>
To: containers@lists.linux.dev,
	bpf@vger.kernel.org
Cc: YiFei Zhu <yifeifz2@illinois.edu>,
	linux-security-module@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Austin Kuo <hckuo2@illinois.edu>,
	Claudio Canella <claudio.canella@iaik.tugraz.at>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Gruss <daniel.gruss@iaik.tugraz.at>,
	Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
	Giuseppe Scrivano <gscrivan@redhat.com>,
	Hubertus Franke <frankeh@us.ibm.com>,
	Jann Horn <jannh@google.com>,
	Jinghao Jia <jinghao7@illinois.edu>,
	Josep Torrellas <torrella@illinois.edu>,
	Kees Cook <keescook@chromium.org>,
	Sargun Dhillon <sargun@sargun.me>,
	Tianyin Xu <tyxu@illinois.edu>,
	Tobin Feldman-Fitzthum <tobin@ibm.com>,
	Tom Hromatka <tom.hromatka@oracle.com>,
	Will Drewry <wad@chromium.org>
Subject: [RFC PATCH bpf-next seccomp 01/12] seccomp: Move no_new_privs check to after prepare_filter
Date: Mon, 10 May 2021 12:22:38 -0500
Message-Id: <19c5ca314e69c7c3668370bcd624a2a475162cb2.1620499942.git.yifeifz2@illinois.edu>
X-Mailer: git-send-email 2.31.1
In-Reply-To: <cover.1620499942.git.yifeifz2@illinois.edu>
References: <cover.1620499942.git.yifeifz2@illinois.edu>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: YiFei Zhu <yifeifz2@illinois.edu>

This is to make way for eBPF, so that this part of the code can be
shared by both cBPF and eBPF code paths.

Doing the privilege check after prepare_filter means that any
filter issues the caller would get -EINVAL, even when it does not
set no_new_privs or CAP_SYS_ADMIN.

Signed-off-by: YiFei Zhu <yifeifz2@illinois.edu>
---
 kernel/seccomp.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 1e63db4dbd9a..6e5ac0d686a1 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -642,16 +642,6 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 
 	BUG_ON(INT_MAX / fprog->len < sizeof(struct sock_filter));
 
-	/*
-	 * Installing a seccomp filter requires that the task has
-	 * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
-	 * This avoids scenarios where unprivileged tasks can affect the
-	 * behavior of privileged children.
-	 */
-	if (!task_no_new_privs(current) &&
-			!ns_capable_noaudit(current_user_ns(), CAP_SYS_ADMIN))
-		return ERR_PTR(-EACCES);
-
 	/* Allocate a new seccomp_filter */
 	sfilter = kzalloc(sizeof(*sfilter), GFP_KERNEL | __GFP_NOWARN);
 	if (!sfilter)
@@ -1805,6 +1795,22 @@ static long seccomp_set_mode_filter(unsigned int flags,
 	if (IS_ERR(prepared))
 		return PTR_ERR(prepared);
 
+	/*
+	 * Installing a seccomp filter requires that the task has
+	 * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
+	 * This avoids scenarios where unprivileged tasks can affect the
+	 * behavior of privileged children.
+	 *
+	 * This is checked after filter preparation because the user
+	 * will get an EINVAL if their filter is invalid prior to the
+	 * EACCES.
+	 */
+	if (!task_no_new_privs(current) &&
+	    !ns_capable_noaudit(current_user_ns(), CAP_SYS_ADMIN)) {
+		ret = -EACCES;
+		goto out_free;
+	}
+
 	if (flags & SECCOMP_FILTER_FLAG_NEW_LISTENER) {
 		listener = get_unused_fd_flags(O_CLOEXEC);
 		if (listener < 0) {
-- 
2.31.1

