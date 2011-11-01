From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/10] threadgroup: rename signal->threadgroup_fork_lock to
	->group_rwsem
Date: Tue,  1 Nov 2011 16:46:25 -0700
Message-ID: <1320191193-8110-3-git-send-email-tj@kernel.org>
References: <1320191193-8110-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1320191193-8110-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

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
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/init_task.h |    9 ++++-----
 include/linux/sched.h     |   30 +++++++++++++++---------------
 kernel/cgroup.c           |   13 ++++++-------
 kernel/fork.c             |    8 ++++----
 4 files changed, 29 insertions(+), 31 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 08ffab0..ef20cbe 100644
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
index e8acce7..aa47d0f 100644
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
@@ -2367,29 +2367,29 @@ static inline void unlock_task_sighand(struct task_struct *tsk,
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
index efa5886..f0e099f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2003,8 +2003,8 @@ static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
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
@@ -2030,8 +2030,8 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
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
@@ -2246,7 +2246,6 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 			cgroup_unlock();
 			return -ESRCH;
 		}
-
 		/*
 		 * even if we're attaching all tasks in the thread group, we
 		 * only need to check permissions on one of them.
@@ -2270,9 +2269,9 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 	}
 
 	if (threadgroup) {
-		threadgroup_fork_write_lock(tsk);
+		threadgroup_lock(tsk);
 		ret = cgroup_attach_proc(cgrp, tsk);
-		threadgroup_fork_write_unlock(tsk);
+		threadgroup_unlock(tsk);
 	} else {
 		ret = cgroup_attach_task(cgrp, tsk);
 	}
diff --git a/kernel/fork.c b/kernel/fork.c
index 8e6b6f4..c2af839 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -980,7 +980,7 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	sched_autogroup_fork(sig);
 
 #ifdef CONFIG_CGROUPS
-	init_rwsem(&sig->threadgroup_fork_lock);
+	init_rwsem(&sig->group_rwsem);
 #endif
 
 	sig->oom_adj = current->signal->oom_adj;
@@ -1166,7 +1166,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->io_context = NULL;
 	p->audit_context = NULL;
 	if (clone_flags & CLONE_THREAD)
-		threadgroup_fork_read_lock(current);
+		threadgroup_change_begin(current);
 	cgroup_fork(p);
 #ifdef CONFIG_NUMA
 	p->mempolicy = mpol_dup(p->mempolicy);
@@ -1378,7 +1378,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	proc_fork_connector(p);
 	cgroup_post_fork(p);
 	if (clone_flags & CLONE_THREAD)
-		threadgroup_fork_read_unlock(current);
+		threadgroup_change_done(current);
 	perf_event_fork(p);
 	return p;
 
@@ -1418,7 +1418,7 @@ bad_fork_cleanup_policy:
 bad_fork_cleanup_cgroup:
 #endif
 	if (clone_flags & CLONE_THREAD)
-		threadgroup_fork_read_unlock(current);
+		threadgroup_change_done(current);
 	cgroup_exit(p, cgroup_callbacks_done);
 	delayacct_tsk_free(p);
 	module_put(task_thread_info(p)->exec_domain->module);
-- 
1.7.3.1
