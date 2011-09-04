From: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/4] threadgroup: rename signal->threadgroup_fork_lock to
	->group_rwsem
Date: Mon,  5 Sep 2011 03:01:18 +0900
Message-ID: <1315159280-25032-3-git-send-email-htejun__4016.28015465594$1315159435$gmane$org@gmail.com>
References: <1315159280-25032-1-git-send-email-htejun@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1315159280-25032-1-git-send-email-htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: rjw-KKrjLPT3xs0@public.gmane.org, paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Make the following renames to prepare for extension of threadgroup
locking.

* s/signal->threadgroup_fork_lock/signal->group_rwsem/
* s/threadgroup_fork_read_lock()/threadgroup_change_begin()/
* s/threadgroup_fork_read_unlock()/threadgroup_change_done()/
* s/threadgroup_fork_write_lock()/threadgroup_lock()/
* s/threadgroup_fork_write_unlock()/threadgroup_unlock()/

This patch doesn't cause any behavior change.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/init_task.h |    9 ++++-----
 include/linux/sched.h     |   30 +++++++++++++++---------------
 kernel/cgroup.c           |   12 ++++++------
 kernel/fork.c             |    8 ++++----
 4 files changed, 29 insertions(+), 30 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index d14e058..3a0d9f2 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -23,11 +23,10 @@ extern struct files_struct init_files;
 extern struct fs_struct init_fs;
 
 #ifdef CONFIG_CGROUPS
-#define INIT_THREADGROUP_FORK_LOCK(sig)					\
-	.threadgroup_fork_lock =					\
-		__RWSEM_INITIALIZER(sig.threadgroup_fork_lock),
+#define INIT_GROUP_RWSEM(sig)						\
+	.group_rwsem = __RWSEM_INITIALIZER(sig.group_rwsem),
 #else
-#define INIT_THREADGROUP_FORK_LOCK(sig)
+#define INIT_GROUP_RWSEM(sig)
 #endif
 
 #define INIT_SIGNALS(sig) {						\
@@ -46,7 +45,7 @@ extern struct fs_struct init_fs;
 	},								\
 	.cred_guard_mutex =						\
 		 __MUTEX_INITIALIZER(sig.cred_guard_mutex),		\
-	INIT_THREADGROUP_FORK_LOCK(sig)					\
+	INIT_GROUP_RWSEM(sig)						\
 }
 
 extern struct nsproxy init_nsproxy;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6d45ce7..da74d6f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -635,13 +635,13 @@ struct signal_struct {
 #endif
 #ifdef CONFIG_CGROUPS
 	/*
-	 * The threadgroup_fork_lock prevents threads from forking with
+	 * The group_rwsem prevents threads from forking with
 	 * CLONE_THREAD while held for writing. Use this for fork-sensitive
 	 * threadgroup-wide operations. It's taken for reading in fork.c in
 	 * copy_process().
 	 * Currently only needed write-side by cgroups.
 	 */
-	struct rw_semaphore threadgroup_fork_lock;
+	struct rw_semaphore group_rwsem;
 #endif
 
 	int oom_adj;		/* OOM kill score adjustment (bit shift) */
@@ -2364,29 +2364,29 @@ static inline void unlock_task_sighand(struct task_struct *tsk,
 	spin_unlock_irqrestore(&tsk->sighand->siglock, *flags);
 }
 
-/* See the declaration of threadgroup_fork_lock in signal_struct. */
+/* See the declaration of group_rwsem in signal_struct. */
 #ifdef CONFIG_CGROUPS
-static inline void threadgroup_fork_read_lock(struct task_struct *tsk)
+static inline void threadgroup_change_begin(struct task_struct *tsk)
 {
-	down_read(&tsk->signal->threadgroup_fork_lock);
+	down_read(&tsk->signal->group_rwsem);
 }
-static inline void threadgroup_fork_read_unlock(struct task_struct *tsk)
+static inline void threadgroup_change_done(struct task_struct *tsk)
 {
-	up_read(&tsk->signal->threadgroup_fork_lock);
+	up_read(&tsk->signal->group_rwsem);
 }
-static inline void threadgroup_fork_write_lock(struct task_struct *tsk)
+static inline void threadgroup_lock(struct task_struct *tsk)
 {
-	down_write(&tsk->signal->threadgroup_fork_lock);
+	down_write(&tsk->signal->group_rwsem);
 }
-static inline void threadgroup_fork_write_unlock(struct task_struct *tsk)
+static inline void threadgroup_unlock(struct task_struct *tsk)
 {
-	up_write(&tsk->signal->threadgroup_fork_lock);
+	up_write(&tsk->signal->group_rwsem);
 }
 #else
-static inline void threadgroup_fork_read_lock(struct task_struct *tsk) {}
-static inline void threadgroup_fork_read_unlock(struct task_struct *tsk) {}
-static inline void threadgroup_fork_write_lock(struct task_struct *tsk) {}
-static inline void threadgroup_fork_write_unlock(struct task_struct *tsk) {}
+static inline void threadgroup_change_begin(struct task_struct *tsk) {}
+static inline void threadgroup_change_done(struct task_struct *tsk) {}
+static inline void threadgroup_lock(struct task_struct *tsk) {}
+static inline void threadgroup_unlock(struct task_struct *tsk) {}
 #endif
 
 #ifndef __HAVE_THREAD_FUNCTIONS
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index bd1fb5f..e81f403 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1985,8 +1985,8 @@ static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
  * @cgrp: the cgroup to attach to
  * @leader: the threadgroup leader task_struct of the group to be attached
  *
- * Call holding cgroup_mutex and the threadgroup_fork_lock of the leader. Will
- * take task_lock of each thread in leader's threadgroup individually in turn.
+ * Call holding cgroup_mutex and the group_rwsem of the leader. Will take
+ * task_lock of each thread in leader's threadgroup individually in turn.
  */
 int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 {
@@ -2012,8 +2012,8 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 * step 0: in order to do expensive, possibly blocking operations for
 	 * every thread, we cannot iterate the thread group list, since it needs
 	 * rcu or tasklist locked. instead, build an array of all threads in the
-	 * group - threadgroup_fork_lock prevents new threads from appearing,
-	 * and if threads exit, this will just be an over-estimate.
+	 * group - group_rwsem prevents new threads from appearing, and if
+	 * threads exit, this will just be an over-estimate.
 	 */
 	group_size = get_nr_threads(leader);
 	/* flex_array supports very large thread-groups better than kmalloc. */
@@ -2246,7 +2246,7 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 	}
 
 	if (threadgroup)
-		threadgroup_fork_write_lock(tsk);
+		threadgroup_lock(tsk);
 	ret = -ENODEV;
 	if (cgroup_lock_live_group(cgrp)) {
 		if (threadgroup)
@@ -2256,7 +2256,7 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 		cgroup_unlock();
 	}
 	if (threadgroup)
-		threadgroup_fork_write_unlock(tsk);
+		threadgroup_unlock(tsk);
 	put_task_struct(tsk);
 	return ret;
 }
diff --git a/kernel/fork.c b/kernel/fork.c
index fa7beb3..f0e2e56 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -980,7 +980,7 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	sched_autogroup_fork(sig);
 
 #ifdef CONFIG_CGROUPS
-	init_rwsem(&sig->threadgroup_fork_lock);
+	init_rwsem(&sig->group_rwsem);
 #endif
 
 	sig->oom_adj = current->signal->oom_adj;
@@ -1165,7 +1165,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->io_context = NULL;
 	p->audit_context = NULL;
 	if (clone_flags & CLONE_THREAD)
-		threadgroup_fork_read_lock(current);
+		threadgroup_change_begin(current);
 	cgroup_fork(p);
 #ifdef CONFIG_NUMA
 	p->mempolicy = mpol_dup(p->mempolicy);
@@ -1377,7 +1377,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	proc_fork_connector(p);
 	cgroup_post_fork(p);
 	if (clone_flags & CLONE_THREAD)
-		threadgroup_fork_read_unlock(current);
+		threadgroup_change_done(current);
 	perf_event_fork(p);
 	return p;
 
@@ -1417,7 +1417,7 @@ bad_fork_cleanup_policy:
 bad_fork_cleanup_cgroup:
 #endif
 	if (clone_flags & CLONE_THREAD)
-		threadgroup_fork_read_unlock(current);
+		threadgroup_change_done(current);
 	cgroup_exit(p, cgroup_callbacks_done);
 	delayacct_tsk_free(p);
 	module_put(task_thread_info(p)->exec_domain->module);
-- 
1.7.6
