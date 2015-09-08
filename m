From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: [RFC PATCH 2/2] userns/nproc: Add hooks for userns nproc management
Date: Tue,  8 Sep 2015 11:11:13 +0300
Message-ID: <1441699873-26653-3-git-send-email-kernel@kyup.com>
References: <1441699873-26653-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1441699873-26653-1-git-send-email-kernel-6AxghH7DbtA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Nikolay Borisov <n.borisov-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Nikolay Borisov <n.borisov-/eCPMmvKun9pLGFMi4vTTA@public.gmane.org>

This patch introduce the usage of the userns_nproc_* functions
where necessary to have correct accounting of the processes.

Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
---
 kernel/cred.c | 36 ++++++++++++++++++++++++++++++++++--
 kernel/exit.c |  9 +++++++++
 kernel/fork.c | 33 +++++++++++++++++++++++++++------
 3 files changed, 70 insertions(+), 8 deletions(-)

diff --git a/kernel/cred.c b/kernel/cred.c
index b7581dc..79565b8 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -320,6 +320,7 @@ struct cred *prepare_exec_creds(void)
 int copy_creds(struct task_struct *p, unsigned long clone_flags)
 {
 	struct cred *new;
+	struct user_namespace *ns;
 	int ret;
 
 	if (
@@ -331,10 +332,15 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 		p->real_cred = get_cred(p->cred);
 		get_cred(p->cred);
 		alter_cred_subscribers(p->cred, 2);
+		ns = p->real_cred->user_ns;
 		kdebug("share_creds(%p{%d,%d})",
 		       p->cred, atomic_read(&p->cred->usage),
 		       read_cred_subscribers(p->cred));
 		atomic_inc(&p->cred->user->processes);
+		if (ns != &init_user_ns) {
+			pr_info ("%s: incrementing nproc from due copy_process (CLONE_THREAD)\n", __func__);
+			userns_nproc_inc(ns, from_kuid_munged(ns, p->real_cred->uid));
+		}
 		return 0;
 	}
 
@@ -343,6 +349,7 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 		return -ENOMEM;
 
 	if (clone_flags & CLONE_NEWUSER) {
+		pr_debug("%s: Creating new usernamespace\n", __func__);
 		ret = create_user_ns(new);
 		if (ret < 0)
 			goto error_put;
@@ -369,6 +376,11 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 
 	atomic_inc(&new->user->processes);
 	p->cred = p->real_cred = get_cred(new);
+	ns = p->real_cred->user_ns;
+	if (ns != &init_user_ns) {
+		pr_info("%s: Incrementing due to not-being a thread\n",	__func__);
+		userns_nproc_inc(ns, from_kuid_munged(ns, p->real_cred->uid));
+	}
 	alter_cred_subscribers(new, 2);
 	validate_creds(new);
 	return 0;
@@ -454,17 +466,37 @@ int commit_creds(struct cred *new)
 	if (!gid_eq(new->fsgid, old->fsgid))
 		key_fsgid_changed(task);
 
+	/* Handle cases when a process is moving from one userns to another */
+	if (old->user_ns != new->user_ns) {
+		if (new->user_ns != &init_user_ns) {
+			pr_info ("\t%s: incrementing user count in %p\n", __func__, new->user_ns);
+			userns_nproc_inc(new->user_ns, from_kuid_munged(new->user_ns, new->uid));
+		}
+		if (old->user_ns != &init_user_ns) {
+			pr_info ("\t%s: decrementing user_count in %p\n", __func__, old->user_ns);
+			userns_nproc_dec(old->user_ns, from_kuid_munged(old->user_ns, old->uid));
+		}
+	}
+
 	/* do it
 	 * RLIMIT_NPROC limits on user->processes have already been checked
 	 * in set_user().
 	 */
 	alter_cred_subscribers(new, 2);
-	if (new->user != old->user)
+	if (new->user != old->user) {
 		atomic_inc(&new->user->processes);
+		if (new->user_ns != &init_user_ns)
+			userns_nproc_inc(new->user_ns,
+				 from_kuid_munged(new->user_ns, new->uid));
+	}
 	rcu_assign_pointer(task->real_cred, new);
 	rcu_assign_pointer(task->cred, new);
-	if (new->user != old->user)
+	if (new->user != old->user) {
 		atomic_dec(&old->user->processes);
+		if (old->user_ns != &init_user_ns)
+			userns_nproc_dec(old->user_ns,
+				 from_kuid_munged(old->user_ns, old->uid));
+	}
 	alter_cred_subscribers(old, -2);
 
 	/* send notifications */
diff --git a/kernel/exit.c b/kernel/exit.c
index 22fcc05..dde172b 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -170,13 +170,22 @@ void release_task(struct task_struct *p)
 {
 	struct task_struct *leader;
 	int zap_leader;
+	struct user_namespace *ns;
+	kuid_t uid;
 repeat:
 	/* don't need to get the RCU readlock here - the process is dead and
 	 * can't be modifying its own credentials. But shut RCU-lockdep up */
 	rcu_read_lock();
 	atomic_dec(&__task_cred(p)->user->processes);
+	ns = get_user_ns(__task_cred(p)->user_ns);
+	uid = __task_cred(p)->uid;
 	rcu_read_unlock();
 
+	if (ns != &init_user_ns)
+		userns_nproc_dec(ns, from_kuid_munged(ns, uid));
+
+	put_user_ns(ns);
+
 	proc_flush_task(p);
 
 	write_lock_irq(&tasklist_lock);
diff --git a/kernel/fork.c b/kernel/fork.c
index f9826a3..c537b6a 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1308,18 +1308,34 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	DEBUG_LOCKS_WARN_ON(!p->softirqs_enabled);
 #endif
 	retval = -EAGAIN;
-	if (atomic_read(&p->real_cred->user->processes) >=
-			task_rlimit(p, RLIMIT_NPROC)) {
-		if (p->real_cred->user != INIT_USER &&
-		    !capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
-			goto bad_fork_free;
-	}
+	//If we are in the root namespace use this check
+	if (p->real_cred->user_ns == &init_user_ns) {
+		if (atomic_read(&p->real_cred->user->processes) >=
+				task_rlimit(p, RLIMIT_NPROC)) {
+			if (p->real_cred->user != INIT_USER &&
+			    !capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
+				goto bad_fork_free;
+		}
 	current->flags &= ~PF_NPROC_EXCEEDED;
+	}
 
 	retval = copy_creds(p, clone_flags);
 	if (retval < 0)
 		goto bad_fork_free;
 
+	//Otherwise perform the non-root userns check here
+	//since we want the stuff in copy_cred to have already happened
+	if (p->real_cred->user_ns != &init_user_ns) {
+		struct user_namespace *ns = p->real_cred->user_ns;
+		int32_t processes = get_userns_nproc(ns, from_kuid_munged(ns, p->real_cred->uid));
+		retval = -EAGAIN;
+
+		if (processes >= task_rlimit(p, RLIMIT_NPROC))
+			goto bad_fork_cleanup_userns_count;
+		else
+			current->flags &= ~PF_NPROC_EXCEEDED;
+	}
+
 	/*
 	 * If multiple threads are within copy_process(), then this check
 	 * triggers too late. This doesn't hurt, the check is only there
@@ -1652,6 +1668,9 @@ bad_fork_cleanup_threadgroup_lock:
 	delayacct_tsk_free(p);
 bad_fork_cleanup_count:
 	atomic_dec(&p->cred->user->processes);
+bad_fork_cleanup_userns_count:
+	if (p->cred->user_ns != &init_user_ns)
+		userns_nproc_dec(p->cred->user_ns, from_kuid_munged(p->cred->user_ns, p->cred->uid));
 	exit_creds(p);
 bad_fork_free:
 	free_task(p);
@@ -1936,6 +1955,7 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
 	int do_sysvsem = 0;
 	int err;
 
+	pr_info("%s begin\n", __func__);
 	/*
 	 * If unsharing a user namespace must also unshare the thread.
 	 */
@@ -2037,6 +2057,7 @@ bad_unshare_cleanup_fs:
 		free_fs_struct(new_fs);
 
 bad_unshare_out:
+	pr_info("%s end\n", __func__);
 	return err;
 }
 
-- 
2.5.0
