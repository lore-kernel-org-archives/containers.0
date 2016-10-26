From: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
Subject: [RFC PATCH] rlimit: Account nproc per-usernamespace/per-user
Date: Wed, 26 Oct 2016 15:40:27 +0300
Message-ID: <1477485627-16177-1-git-send-email-kernel@kyup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

There are container setups which map the same kuids to
different containers. In such situation what will happen is
that same uid's in different containers will map to the same
underlying user on the matchine (e.g. same struct user). One
implication of this is that the number of processes for that
particular user are going to be shared among all the same uids
in the container. This is problematic, as it means a user in
containerA can potentially exhaust the process limit such that
a user in containerB cannot spawn any processes.

Fix this by utilising the newly introduced UCOUNT infrastructure,
so that process counts are now being accounted per-userns/per-user.
In case when a machine is running in non-container setup then
the accounting semantics is virtually the same, given that there is
going to be one ucount-per-user struct.

Signed-off-by: Nikolay Borisov <kernel-6AxghH7DbtA@public.gmane.org>
---
Hello Eric, 

Now that ucount has been merged I took the liberty of 
experimenting what the nproc-per-userns approach would 
look like and here is the result. In my previous [0] you 
expressed concerns regarding not having hierarchical limits, 
essentially allowing users to circumvent their limits. So
this version doesn't do anything to rectify this issue. 
However, I do think the idea of the rlimit is not to 
forbid the user of spawning more processes, since currently
the limit is being set on a per-process basis, so a malicious 
process can in fact increase that limits and spawn a large number 
of processes. Given this I believe the current patch doesn't make
the situation any worse in that regard. 

[0] https://lists.linux-foundation.org/pipermail/containers/2015-September/036229.html

 fs/exec.c                      |  2 +-
 include/linux/cred.h           |  1 +
 include/linux/sched.h          |  1 -
 include/linux/user_namespace.h |  8 ++++++++
 kernel/cred.c                  | 18 +++++++++++-------
 kernel/exit.c                  |  2 +-
 kernel/fork.c                  |  7 +++++--
 kernel/sys.c                   |  2 +-
 kernel/ucount.c                | 16 ++++++++++++++++
 kernel/user.c                  |  1 -
 10 files changed, 44 insertions(+), 14 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 6fcfb3f7b137..8126e00a8d3e 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1651,7 +1651,7 @@ static int do_execveat_common(int fd, struct filename *filename,
 	 * whether NPROC limit is still exceeded.
 	 */
 	if ((current->flags & PF_NPROC_EXCEEDED) &&
-	    atomic_read(&current_user()->processes) > rlimit(RLIMIT_NPROC)) {
+	    atomic_read(&current_cred()->ucounts->ulimit[ULIMIT_NPROC]) > rlimit(RLIMIT_NPROC)) {
 		retval = -EAGAIN;
 		goto out_ret;
 	}
diff --git a/include/linux/cred.h b/include/linux/cred.h
index f0e70a1bb3ac..c3bb4d20ff16 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -141,6 +141,7 @@ struct cred {
 	void		*security;	/* subjective LSM security */
 #endif
 	struct user_struct *user;	/* real user ID subscription */
+	struct ucounts *ucounts;		/* container for per-userns/per-counts */
 	struct user_namespace *user_ns; /* user_ns the caps and keyrings are relative to. */
 	struct group_info *group_info;	/* supplementary groups for euid/fsgid */
 	struct rcu_head	rcu;		/* RCU deletion hook */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 348f51b0ec92..3709d70fe2de 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -842,7 +842,6 @@ static inline int signal_group_exit(const struct signal_struct *sig)
  */
 struct user_struct {
 	atomic_t __count;	/* reference count */
-	atomic_t processes;	/* How many processes does this user have? */
 	atomic_t sigpending;	/* How many pending signals does this user have? */
 #ifdef CONFIG_INOTIFY_USER
 	atomic_t inotify_watches; /* How many inotify watches does this user have? */
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index eb209d4523f5..d4fc31ae9d85 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -35,6 +35,11 @@ enum ucount_type {
 	UCOUNT_COUNTS,
 };
 
+enum ulimit_type {
+	ULIMIT_NPROC,
+	ULIMIT_COUNTS,
+};
+
 struct user_namespace {
 	struct uid_gid_map	uid_map;
 	struct uid_gid_map	gid_map;
@@ -67,6 +72,7 @@ struct ucounts {
 	kuid_t uid;
 	atomic_t count;
 	atomic_t ucount[UCOUNT_COUNTS];
+	atomic_t ulimit[ULIMIT_COUNTS];
 };
 
 extern struct user_namespace init_user_ns;
@@ -75,6 +81,8 @@ bool setup_userns_sysctls(struct user_namespace *ns);
 void retire_userns_sysctls(struct user_namespace *ns);
 struct ucounts *inc_ucount(struct user_namespace *ns, kuid_t uid, enum ucount_type type);
 void dec_ucount(struct ucounts *ucounts, enum ucount_type type);
+struct ucounts *inc_ulimit(struct user_namespace *ns, kuid_t uid, enum ulimit_type type);
+void dec_ulimit(struct ucounts *ucounts, enum ulimit_type type);
 
 #ifdef CONFIG_USER_NS
 
diff --git a/kernel/cred.c b/kernel/cred.c
index 5f264fb5737d..dd9ffc0396bb 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -330,13 +330,16 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 #endif
 		clone_flags & CLONE_THREAD
 	    ) {
-		p->real_cred = get_cred(p->cred);
+		struct cred *c;
+		struct ucounts *uc = inc_ulimit(p->cred->user_ns, p->cred->uid,
+						ULIMIT_NPROC);
+		p->real_cred = c = get_cred(p->cred);
 		get_cred(p->cred);
 		alter_cred_subscribers(p->cred, 2);
 		kdebug("share_creds(%p{%d,%d})",
 		       p->cred, atomic_read(&p->cred->usage),
 		       read_cred_subscribers(p->cred));
-		atomic_inc(&p->cred->user->processes);
+		c->ucounts = uc;
 		return 0;
 	}
 
@@ -369,7 +372,8 @@ int copy_creds(struct task_struct *p, unsigned long clone_flags)
 	}
 #endif
 
-	atomic_inc(&new->user->processes);
+	new->ucounts = inc_ulimit(new->user_ns, new->uid,
+				      ULIMIT_NPROC);
 	p->cred = p->real_cred = get_cred(new);
 	alter_cred_subscribers(new, 2);
 	validate_creds(new);
@@ -461,12 +465,12 @@ int commit_creds(struct cred *new)
 	 * in set_user().
 	 */
 	alter_cred_subscribers(new, 2);
-	if (new->user != old->user)
-		atomic_inc(&new->user->processes);
+	if (new->user != old->user || old->user_ns != new->user_ns)
+		new->ucounts = inc_ulimit(new->user_ns, new->uid, ULIMIT_NPROC);
 	rcu_assign_pointer(task->real_cred, new);
 	rcu_assign_pointer(task->cred, new);
-	if (new->user != old->user)
-		atomic_dec(&old->user->processes);
+	if (new->user != old->user || old->user_ns != new->user_ns)
+		dec_ulimit(old->ucounts, ULIMIT_NPROC);
 	alter_cred_subscribers(old, -2);
 
 	/* send notifications */
diff --git a/kernel/exit.c b/kernel/exit.c
index 9d68c45ebbe3..7ac8954230bd 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -173,7 +173,7 @@ void release_task(struct task_struct *p)
 	/* don't need to get the RCU readlock here - the process is dead and
 	 * can't be modifying its own credentials. But shut RCU-lockdep up */
 	rcu_read_lock();
-	atomic_dec(&__task_cred(p)->user->processes);
+	dec_ulimit(__task_cred(p)->ucounts, ULIMIT_NPROC);
 	rcu_read_unlock();
 
 	proc_flush_task(p);
diff --git a/kernel/fork.c b/kernel/fork.c
index 623259fc794d..0b16c9d920b1 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -425,6 +425,7 @@ int arch_task_struct_size __read_mostly;
 void __init fork_init(void)
 {
 	int i;
+	struct cred *c = init_task.cred;
 #ifndef CONFIG_ARCH_TASK_STRUCT_ALLOCATOR
 #ifndef ARCH_MIN_TASKALIGN
 #define ARCH_MIN_TASKALIGN	L1_CACHE_BYTES
@@ -448,6 +449,8 @@ void __init fork_init(void)
 	for (i = 0; i < UCOUNT_COUNTS; i++) {
 		init_user_ns.ucount_max[i] = max_threads/2;
 	}
+
+	c->ucounts = inc_ulimit(&init_user_ns, make_kuid(&init_user_ns, 0), ULIMIT_NPROC);
 }
 
 int __weak arch_dup_task_struct(struct task_struct *dst,
@@ -1515,7 +1518,7 @@ static __latent_entropy struct task_struct *copy_process(
 	DEBUG_LOCKS_WARN_ON(!p->softirqs_enabled);
 #endif
 	retval = -EAGAIN;
-	if (atomic_read(&p->real_cred->user->processes) >=
+	if (atomic_read(&p->real_cred->ucounts->ulimit[ULIMIT_NPROC]) >=
 			task_rlimit(p, RLIMIT_NPROC)) {
 		if (p->real_cred->user != INIT_USER &&
 		    !capable(CAP_SYS_RESOURCE) && !capable(CAP_SYS_ADMIN))
@@ -1859,7 +1862,7 @@ static __latent_entropy struct task_struct *copy_process(
 #endif
 	delayacct_tsk_free(p);
 bad_fork_cleanup_count:
-	atomic_dec(&p->cred->user->processes);
+	dec_ulimit(p->cred->ucounts, ULIMIT_NPROC);
 	exit_creds(p);
 bad_fork_free:
 	put_task_stack(p);
diff --git a/kernel/sys.c b/kernel/sys.c
index 89d5be418157..143d04ed9da5 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -433,7 +433,7 @@ static int set_user(struct cred *new)
 	 * for programs doing set*uid()+execve() by harmlessly deferring the
 	 * failure to the execve() stage.
 	 */
-	if (atomic_read(&new_user->processes) >= rlimit(RLIMIT_NPROC) &&
+	if (atomic_read(&new->ucounts->ulimit[ULIMIT_NPROC]) >= rlimit(RLIMIT_NPROC) &&
 			new_user != INIT_USER)
 		current->flags |= PF_NPROC_EXCEEDED;
 	else
diff --git a/kernel/ucount.c b/kernel/ucount.c
index 9d20d5dd298a..d8f5362f6e17 100644
--- a/kernel/ucount.c
+++ b/kernel/ucount.c
@@ -181,6 +181,22 @@ static inline bool atomic_inc_below(atomic_t *v, int u)
 	}
 }
 
+struct ucounts *inc_ulimit(struct user_namespace *ns, kuid_t uid,
+			   enum ulimit_type type)
+{
+	struct ucounts *ucounts = get_ucounts(ns, uid);
+	atomic_inc(&ucounts->ulimit[type]);
+
+	return ucounts;
+}
+
+void dec_ulimit(struct ucounts *ucounts, enum ulimit_type type)
+{
+	atomic_dec(&ucounts->ulimit[type]);
+	WARN_ON(atomic_read(&ucounts->ulimit[type]) < 0);
+	put_ucounts(ucounts);
+}
+
 struct ucounts *inc_ucount(struct user_namespace *ns, kuid_t uid,
 			   enum ucount_type type)
 {
diff --git a/kernel/user.c b/kernel/user.c
index b069ccbfb0b0..ce1ba1fb96c0 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -90,7 +90,6 @@ static DEFINE_SPINLOCK(uidhash_lock);
 /* root_user.__count is 1, for init task cred */
 struct user_struct root_user = {
 	.__count	= ATOMIC_INIT(1),
-	.processes	= ATOMIC_INIT(1),
 	.sigpending	= ATOMIC_INIT(0),
 	.locked_shm     = 0,
 	.uid		= GLOBAL_ROOT_UID,
-- 
2.5.0
