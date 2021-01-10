Return-Path: <SRS0=9Mj4=GN=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DC94C433E0
	for <containers@archiver.kernel.org>; Sun, 10 Jan 2021 17:42:57 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3486E2242A
	for <containers@archiver.kernel.org>; Sun, 10 Jan 2021 17:42:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3486E2242A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 60F0220395;
	Sun, 10 Jan 2021 17:42:55 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id FgsnGr1NCESP; Sun, 10 Jan 2021 17:42:53 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 1B3BA203A0;
	Sun, 10 Jan 2021 17:42:53 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0B300C088B;
	Sun, 10 Jan 2021 17:42:53 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 06097C013A
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 17:42:49 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id D40D9203A0
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 17:42:48 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id mhqTIk63OcSV
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 17:42:47 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by silver.osuosl.org (Postfix) with ESMTP id 2AC8B203AB
 for <containers@lists.linux-foundation.org>;
 Sun, 10 Jan 2021 17:42:46 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-89-103-122-167.net.upcbroadband.cz [89.103.122.167])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 0A23220A1D;
 Sun, 10 Jan 2021 17:34:53 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>
Subject: [RFC PATCH v2 6/8] Move RLIMIT_SIGPENDING counter to ucounts
Date: Sun, 10 Jan 2021 18:33:45 +0100
Message-Id: <edfdb327d1d8cac23789736f117715e6ff96040e.1610299858.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <cover.1610299857.git.gladkov.alexey@gmail.com>
References: <cover.1610299857.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Sun, 10 Jan 2021 17:34:53 +0000 (UTC)
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
 Alexey Gladkov <legion@kernel.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>,
 Christian Brauner <christian@brauner.io>, Kees Cook <keescook@chromium.org>
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

Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
---
 fs/proc/array.c                |  2 +-
 include/linux/sched/user.h     |  1 -
 include/linux/signal_types.h   |  4 ++-
 include/linux/user_namespace.h |  1 +
 kernel/fork.c                  |  1 +
 kernel/signal.c                | 53 ++++++++++++++--------------------
 kernel/ucount.c                |  1 +
 kernel/user.c                  |  1 -
 kernel/user_namespace.c        |  1 +
 9 files changed, 30 insertions(+), 35 deletions(-)

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
index 2980afed6fb7..7719e2163b72 100644
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
index f61a5a3dc02f..a7be5790392e 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -825,6 +825,7 @@ void __init fork_init(void)
 
 	init_user_ns.ucount_max[UCOUNT_RLIMIT_NPROC] = task_rlimit(&init_task, RLIMIT_NPROC);
 	init_user_ns.ucount_max[UCOUNT_RLIMIT_MSGQUEUE] = task_rlimit(&init_task, RLIMIT_MSGQUEUE);
+	init_user_ns.ucount_max[UCOUNT_RLIMIT_SIGPENDING] = task_rlimit(&init_task, RLIMIT_SIGPENDING);
 
 #ifdef CONFIG_VMAP_STACK
 	cpuhp_setup_state(CPUHP_BP_PREPARE_DYN, "fork:vm_stack_cache",
diff --git a/kernel/signal.c b/kernel/signal.c
index 5736c55aaa1a..877020481212 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -412,49 +412,40 @@ void task_join_group_stop(struct task_struct *task)
 static struct sigqueue *
 __sigqueue_alloc(int sig, struct task_struct *t, gfp_t flags, int override_rlimit)
 {
-	struct sigqueue *q = NULL;
-	struct user_struct *user;
-	int sigpending;
+	struct sigqueue *q = kmem_cache_alloc(sigqueue_cachep, flags);
 
-	/*
-	 * Protect access to @t credentials. This can go away when all
-	 * callers hold rcu read lock.
-	 *
-	 * NOTE! A pending signal will hold on to the user refcount,
-	 * and we get/put the refcount only when the sigpending count
-	 * changes from/to zero.
-	 */
-	rcu_read_lock();
-	user = __task_cred(t)->user;
-	sigpending = atomic_inc_return(&user->sigpending);
-	if (sigpending == 1)
-		get_uid(user);
-	rcu_read_unlock();
+	if (likely(q != NULL)) {
+		bool overlimit;
 
-	if (override_rlimit || likely(sigpending <= task_rlimit(t, RLIMIT_SIGPENDING))) {
-		q = kmem_cache_alloc(sigqueue_cachep, flags);
-	} else {
-		print_dropped_signal(sig);
-	}
-
-	if (unlikely(q == NULL)) {
-		if (atomic_dec_and_test(&user->sigpending))
-			free_uid(user);
-	} else {
 		INIT_LIST_HEAD(&q->list);
 		q->flags = 0;
-		q->user = user;
+
+		/*
+		 * Protect access to @t credentials. This can go away when all
+		 * callers hold rcu read lock.
+		 */
+		rcu_read_lock();
+		q->ucounts = get_ucount(task_ucounts(t));
+		overlimit = inc_rlimit_ucounts_and_test(q->ucounts, UCOUNT_RLIMIT_SIGPENDING,
+				1, task_rlimit(t, RLIMIT_SIGPENDING));
+
+		if (override_rlimit || likely(!overlimit)) {
+			rcu_read_unlock();
+			return q;
+		}
+		rcu_read_unlock();
 	}
 
-	return q;
+	print_dropped_signal(sig);
+	return NULL;
 }
 
 static void __sigqueue_free(struct sigqueue *q)
 {
 	if (q->flags & SIGQUEUE_PREALLOC)
 		return;
-	if (atomic_dec_and_test(&q->user->sigpending))
-		free_uid(q->user);
+	dec_rlimit_ucounts(q->ucounts, UCOUNT_RLIMIT_SIGPENDING, 1);
+	put_ucounts(q->ucounts);
 	kmem_cache_free(sigqueue_cachep, q);
 }
 
diff --git a/kernel/ucount.c b/kernel/ucount.c
index 865fd66c48c4..c79a7155a9b7 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -75,6 +75,7 @@ static struct ctl_table user_table[] = {
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
index 9ace2a45a25d..eeff7f6d81c0 100644
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
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
