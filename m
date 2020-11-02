Return-Path: <SRS0=UpRV=EI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.5 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1F2DC00A89
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 17:01:26 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 818A5223AB
	for <containers@archiver.kernel.org>; Mon,  2 Nov 2020 17:01:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 818A5223AB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 455C986AF6;
	Mon,  2 Nov 2020 17:01:26 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id P9Mffm0aOzML; Mon,  2 Nov 2020 17:01:23 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 3A0B886B00;
	Mon,  2 Nov 2020 17:01:23 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id CE89FC1AD8;
	Mon,  2 Nov 2020 17:01:22 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 1C0EAC0051
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:01:21 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 0A4AD868C5
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:01:21 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id zlmAy7u0lXTY
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:01:19 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by whitealder.osuosl.org (Postfix) with ESMTP id 7C27E86AEC
 for <containers@lists.linux-foundation.org>;
 Mon,  2 Nov 2020 17:01:18 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-89-103-122-167.net.upcbroadband.cz [89.103.122.167])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits))
 (No client certificate requested)
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 5B25020A19;
 Mon,  2 Nov 2020 16:52:30 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>
Subject: [RFC PATCH v1 2/4] Move the user's process counter to ucounts
Date: Mon,  2 Nov 2020 17:50:31 +0100
Message-Id: <b6fb149b5884d341ededecc6f99bd1e40939b647.1604335819.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.25.4
In-Reply-To: <cover.1604335819.git.gladkov.alexey@gmail.com>
References: <cover.1604335819.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.1
 (raptor.unsafe.ru [5.9.43.93]); Mon, 02 Nov 2020 16:52:30 +0000 (UTC)
Cc: Alexey Gladkov <legion@kernel.org>,
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

To count the number of user processes use the counter bound to the user
in the user namespace.

Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
---
 fs/exec.c                      |  7 ++++---
 fs/io-wq.c                     | 14 +++++++++-----
 include/linux/sched/user.h     |  1 -
 include/linux/user_namespace.h |  8 ++++++++
 kernel/cred.c                  |  8 ++++----
 kernel/exit.c                  |  2 +-
 kernel/fork.c                  |  9 +++++----
 kernel/sys.c                   |  6 ++++--
 kernel/ucount.c                | 34 ++++++++++++++++++++++++++++++++++
 kernel/user.c                  |  3 ++-
 10 files changed, 71 insertions(+), 21 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index e6e8a9a70327..3f2071f7b9c7 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1826,19 +1826,20 @@ static int __do_execve_file(int fd, struct filename *filename,
 	char *pathbuf = NULL;
 	struct linux_binprm *bprm;
 	struct files_struct *displaced;
-	int retval;
+	int retval, processes;
 
 	if (IS_ERR(filename))
 		return PTR_ERR(filename);
 
+	processes = get_rlimit_counter(&init_user_ns, current_euid(), UCOUNT_RLIMIT_NPROC);
+
 	/*
 	 * We move the actual failure in case of RLIMIT_NPROC excess from
 	 * set*uid() to execve() because too many poorly written programs
 	 * don't check setuid() return code.  Here we additionally recheck
 	 * whether NPROC limit is still exceeded.
 	 */
-	if ((current->flags & PF_NPROC_EXCEEDED) &&
-	    atomic_read(&current_user()->processes) > rlimit(RLIMIT_NPROC)) {
+	if ((current->flags & PF_NPROC_EXCEEDED) && processes > rlimit(RLIMIT_NPROC)) {
 		retval = -EAGAIN;
 		goto out_ret;
 	}
diff --git a/fs/io-wq.c b/fs/io-wq.c
index 47c5f3aeb460..6170aee986db 100644
--- a/fs/io-wq.c
+++ b/fs/io-wq.c
@@ -17,6 +17,7 @@
 #include <linux/rculist_nulls.h>
 #include <linux/fs_struct.h>
 #include <linux/task_work.h>
+#include <linux/user_namespace.h>
 
 #include "io-wq.h"
 
@@ -216,7 +217,7 @@ static void io_worker_exit(struct io_worker *worker)
 	if (worker->flags & IO_WORKER_F_RUNNING)
 		atomic_dec(&acct->nr_running);
 	if (!(worker->flags & IO_WORKER_F_BOUND))
-		atomic_dec(&wqe->wq->user->processes);
+		dec_rlimit_counter(&init_user_ns, wqe->wq->user->uid, UCOUNT_RLIMIT_NPROC);
 	worker->flags = 0;
 	preempt_enable();
 
@@ -349,12 +350,12 @@ static void __io_worker_busy(struct io_wqe *wqe, struct io_worker *worker,
 			worker->flags |= IO_WORKER_F_BOUND;
 			wqe->acct[IO_WQ_ACCT_UNBOUND].nr_workers--;
 			wqe->acct[IO_WQ_ACCT_BOUND].nr_workers++;
-			atomic_dec(&wqe->wq->user->processes);
+			dec_rlimit_counter(&init_user_ns, wqe->wq->user->uid, UCOUNT_RLIMIT_NPROC);
 		} else {
 			worker->flags &= ~IO_WORKER_F_BOUND;
 			wqe->acct[IO_WQ_ACCT_UNBOUND].nr_workers++;
 			wqe->acct[IO_WQ_ACCT_BOUND].nr_workers--;
-			atomic_inc(&wqe->wq->user->processes);
+			inc_rlimit_counter(&init_user_ns, wqe->wq->user->uid, UCOUNT_RLIMIT_NPROC);
 		}
 		io_wqe_inc_running(wqe, worker);
 	 }
@@ -671,7 +672,7 @@ static bool create_io_worker(struct io_wq *wq, struct io_wqe *wqe, int index)
 	spin_unlock_irq(&wqe->lock);
 
 	if (index == IO_WQ_ACCT_UNBOUND)
-		atomic_inc(&wq->user->processes);
+		inc_rlimit_counter(&init_user_ns, wq->user->uid, UCOUNT_RLIMIT_NPROC);
 
 	wake_up_process(worker->task);
 	return true;
@@ -754,6 +755,7 @@ static bool io_wq_can_queue(struct io_wqe *wqe, struct io_wqe_acct *acct,
 			    struct io_wq_work *work)
 {
 	bool free_worker;
+	int processes;
 
 	if (!(work->flags & IO_WQ_WORK_UNBOUND))
 		return true;
@@ -766,7 +768,9 @@ static bool io_wq_can_queue(struct io_wqe *wqe, struct io_wqe_acct *acct,
 	if (free_worker)
 		return true;
 
-	if (atomic_read(&wqe->wq->user->processes) >= acct->max_workers &&
+	processes = get_rlimit_counter(&init_user_ns, wqe->wq->user->uid, UCOUNT_RLIMIT_NPROC);
+
+	if (processes >= acct->max_workers &&
 	    !(capable(CAP_SYS_RESOURCE) || capable(CAP_SYS_ADMIN)))
 		return false;
 
diff --git a/include/linux/sched/user.h b/include/linux/sched/user.h
index 917d88edb7b9..38e122bc3d07 100644
--- a/include/linux/sched/user.h
+++ b/include/linux/sched/user.h
@@ -12,7 +12,6 @@
  */
 struct user_struct {
 	refcount_t __count;	/* reference count */
-	atomic_t processes;	/* How many processes does this user have? */
 	atomic_t sigpending;	/* How many pending signals does this user have? */
 #ifdef CONFIG_FANOTIFY
 	atomic_t fanotify_listeners;
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index fc75af812d73..6d9d180b2c9d 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -50,9 +50,13 @@ enum ucount_type {
 	UCOUNT_INOTIFY_INSTANCES,
 	UCOUNT_INOTIFY_WATCHES,
 #endif
+	UCOUNT_RLIMIT_NPROC,
 	UCOUNT_COUNTS,
 };
 
+#define UCOUNT_MIN_RLIMIT UCOUNT_RLIMIT_NPROC
+#define UCOUNT_MAX_RLIMIT UCOUNT_RLIMIT_NPROC
+
 struct user_namespace {
 	struct uid_gid_map	uid_map;
 	struct uid_gid_map	gid_map;
@@ -104,6 +108,10 @@ void retire_userns_sysctls(struct user_namespace *ns);
 struct ucounts *inc_ucount(struct user_namespace *ns, kuid_t uid, enum ucount_type type);
 void dec_ucount(struct ucounts *ucounts, enum ucount_type type);
 
+long get_rlimit_counter(struct user_namespace *ns, kuid_t uid, enum ucount_type type);
+struct ucounts *inc_rlimit_counter(struct user_namespace *ns, kuid_t uid, enum ucount_type type);
+void dec_rlimit_counter(struct user_namespace *ns, kuid_t uid, enum ucount_type type);
+
 #ifdef CONFIG_USER_NS
 
 static inline struct user_namespace *get_user_ns(struct user_namespace *ns)
diff --git a/kernel/cred.c b/kernel/cred.c
index 421b1149c651..b6694700e760 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -351,7 +351,7 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 		kdebug("share_creds(%p{%d,%d})",
 		       p->cred, atomic_read(&p->cred->usage),
 		       read_cred_subscribers(p->cred));
-		atomic_inc(&p->cred->user->processes);
+		inc_rlimit_counter(&init_user_ns, task_euid(p), UCOUNT_RLIMIT_NPROC);
 		return 0;
 	}
 
@@ -384,7 +384,7 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 	}
 #endif
 
-	atomic_inc(&new->user->processes);
+	inc_rlimit_counter(&init_user_ns, new->euid, UCOUNT_RLIMIT_NPROC);
 	p->cred = p->real_cred = get_cred(new);
 	alter_cred_subscribers(new, 2);
 	validate_creds(new);
@@ -486,11 +486,11 @@ int commit_creds(struct cred *new)
 	 */
 	alter_cred_subscribers(new, 2);
 	if (new->user != old->user)
-		atomic_inc(&new->user->processes);
+		inc_rlimit_counter(&init_user_ns, new->euid, UCOUNT_RLIMIT_NPROC);
 	rcu_assign_pointer(task->real_cred, new);
 	rcu_assign_pointer(task->cred, new);
 	if (new->user != old->user)
-		atomic_dec(&old->user->processes);
+		dec_rlimit_counter(&init_user_ns, old->euid, UCOUNT_RLIMIT_NPROC);
 	alter_cred_subscribers(old, -2);
 
 	/* send notifications */
diff --git a/kernel/exit.c b/kernel/exit.c
index 727150f28103..5a0d7dd1ad64 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -187,7 +187,7 @@ void release_task(struct task_struct *p)
 	/* don't need to get the RCU readlock here - the process is dead and
 	 * can't be modifying its own credentials. But shut RCU-lockdep up */
 	rcu_read_lock();
-	atomic_dec(&__task_cred(p)->user->processes);
+	dec_rlimit_counter(&init_user_ns, task_euid(p), UCOUNT_RLIMIT_NPROC);
 	rcu_read_unlock();
 
 	cgroup_release(p);
diff --git a/kernel/fork.c b/kernel/fork.c
index efc5493203ae..2bc8bd45179f 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1844,7 +1844,7 @@ static __latent_entropy struct task_struct *copy_process(
 					int node,
 					struct kernel_clone_args *args)
 {
-	int pidfd = -1, retval;
+	int pidfd = -1, retval, processes;
 	struct task_struct *p;
 	struct multiprocess_signals delayed;
 	struct file *pidfile = NULL;
@@ -1958,9 +1958,10 @@ static __latent_entropy struct task_struct *copy_process(
 	DEBUG_LOCKS_WARN_ON(!p->hardirqs_enabled);
 	DEBUG_LOCKS_WARN_ON(!p->softirqs_enabled);
 #endif
+	processes = get_rlimit_counter(&init_user_ns, p->real_cred->euid,
+			UCOUNT_RLIMIT_NPROC);
 	retval = -EAGAIN;
-	if (atomic_read(&p->real_cred->user->processes) >=
-			task_rlimit(p, RLIMIT_NPROC)) {
+	if (processes >= task_rlimit(p, RLIMIT_NPROC)) {
 		if (p->real_cred->user != INIT_USER &&
 		    !capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
 			goto bad_fork_free;
@@ -2361,7 +2362,7 @@ static __latent_entropy struct task_struct *copy_process(
 #endif
 	delayacct_tsk_free(p);
 bad_fork_cleanup_count:
-	atomic_dec(&p->cred->user->processes);
+	dec_rlimit_counter(&init_user_ns, p->cred->euid, UCOUNT_RLIMIT_NPROC);
 	exit_creds(p);
 bad_fork_free:
 	p->state = TASK_DEAD;
diff --git a/kernel/sys.c b/kernel/sys.c
index 00a96746e28a..db780ec32d86 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -461,11 +461,14 @@ SYSCALL_DEFINE1(setgid, gid_t, gid)
 static int set_user(struct cred *new)
 {
 	struct user_struct *new_user;
+	int processes;
 
 	new_user = alloc_uid(new->uid);
 	if (!new_user)
 		return -EAGAIN;
 
+	processes = get_rlimit_counter(&init_user_ns, new_user->uid, UCOUNT_RLIMIT_NPROC);
+
 	/*
 	 * We don't fail in case of NPROC limit excess here because too many
 	 * poorly written programs don't check set*uid() return code, assuming
@@ -473,8 +476,7 @@ static int set_user(struct cred *new)
 	 * for programs doing set*uid()+execve() by harmlessly deferring the
 	 * failure to the execve() stage.
 	 */
-	if (atomic_read(&new_user->processes) >= rlimit(RLIMIT_NPROC) &&
-			new_user != INIT_USER)
+	if (processes >= rlimit(RLIMIT_NPROC) && new_user != INIT_USER)
 		current->flags |= PF_NPROC_EXCEEDED;
 	else
 		current->flags &= ~PF_NPROC_EXCEEDED;
diff --git a/kernel/ucount.c b/kernel/ucount.c
index 7b2bca8582ef..e00d644e4ca5 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -74,6 +74,7 @@ static struct ctl_table user_table[] = {
 	UCOUNT_ENTRY("max_inotify_instances"),
 	UCOUNT_ENTRY("max_inotify_watches"),
 #endif
+	{ },
 	{ }
 };
 #endif /* CONFIG_SYSCTL */
@@ -222,6 +223,39 @@ void dec_ucount(struct ucounts *ucounts, enum ucount_type type)
 	put_ucounts(ucounts);
 }
 
+long get_rlimit_counter(struct user_namespace *ns, kuid_t uid, enum ucount_type type)
+{
+	long v;
+	struct ucounts *ucounts = get_ucounts(ns, uid);
+	if (!ucounts)
+		return LONG_MAX;
+	v = atomic_long_read(&ucounts->ucount[type]);
+	put_ucounts(ucounts);
+	return v;
+}
+
+struct ucounts *inc_rlimit_counter(struct user_namespace *ns, kuid_t uid,
+		enum ucount_type type)
+{
+	if (type < UCOUNT_MIN_RLIMIT || type > UCOUNT_MAX_RLIMIT)
+		return NULL;
+
+	return inc_ucount(ns, uid, type);
+}
+
+void dec_rlimit_counter(struct user_namespace *ns, kuid_t uid, enum ucount_type type)
+{
+	struct ucounts *ucounts;
+
+	if (type < UCOUNT_MIN_RLIMIT || type > UCOUNT_MAX_RLIMIT)
+		return;
+
+	ucounts = get_ucounts(ns, uid);
+
+	if (ucounts)
+		dec_ucount(ucounts, type);
+}
+
 static __init int user_namespace_sysctl_init(void)
 {
 #ifdef CONFIG_SYSCTL
diff --git a/kernel/user.c b/kernel/user.c
index b1635d94a1f2..5bb75ebdef4f 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -98,7 +98,6 @@ static DEFINE_SPINLOCK(uidhash_lock);
 /* root_user.__count is 1, for init task cred */
 struct user_struct root_user = {
 	.__count	= REFCOUNT_INIT(1),
-	.processes	= ATOMIC_INIT(1),
 	.sigpending	= ATOMIC_INIT(0),
 	.locked_shm     = 0,
 	.uid		= GLOBAL_ROOT_UID,
@@ -224,6 +223,8 @@ static int __init uid_cache_init(void)
 	uid_hash_insert(&root_user, uidhashentry(GLOBAL_ROOT_UID));
 	spin_unlock_irq(&uidhash_lock);
 
+	inc_rlimit_counter(&init_user_ns, GLOBAL_ROOT_UID, UCOUNT_RLIMIT_NPROC);
+
 	return 0;
 }
 subsys_initcall(uid_cache_init);
-- 
2.25.4

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
