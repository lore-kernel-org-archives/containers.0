From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 7/8] Adds functionality to read/write lock CLONE_THREAD
	fork()ing per-threadgroup
Date: Tue, 18 Aug 2009 16:58:43 -0700
Message-ID: <20090818235843.22531.57310.stgit@menage.mtv.corp.google.com>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090818235059.22531.42618.stgit-u3IScbYxn0zHt/MElyovVYaSKrA+ACpX0E9HWUfgJXw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>


Adds functionality to read/write lock CLONE_THREAD fork()ing per-threadgroup

This patch adds an rwsem that lives in a threadgroup's sighand_struct (next to
the sighand's atomic count, to piggyback on its cacheline), and two functions
in kernel/cgroup.c (for now) for easily+safely obtaining and releasing it. If
another part of the kernel later wants to use such a locking mechanism, the
CONFIG_CGROUPS ifdefs should be changed to a higher-up flag that CGROUPS and
the other system would both depend on, and the lock/unlock functions could be
moved to sched.c or so.

Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

---

 include/linux/cgroup.h    |   14 +++++--
 include/linux/init_task.h |    9 +++++
 include/linux/sched.h     |   15 ++++++++
 kernel/cgroup.c           |   87 ++++++++++++++++++++++++++++++++++++++++++++-
 kernel/fork.c             |    9 +++--
 5 files changed, 125 insertions(+), 9 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index b62bb92..642a47f 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -30,10 +30,12 @@ extern int cgroup_init(void);
 extern void cgroup_lock(void);
 extern bool cgroup_lock_live_group(struct cgroup *cgrp);
 extern void cgroup_unlock(void);
-extern void cgroup_fork(struct task_struct *p);
+extern void cgroup_fork(struct task_struct *p, unsigned long clone_flags);
 extern void cgroup_fork_callbacks(struct task_struct *p);
-extern void cgroup_post_fork(struct task_struct *p);
+extern void cgroup_post_fork(struct task_struct *p, unsigned long clone_flags);
 extern void cgroup_exit(struct task_struct *p, int run_callbacks);
+extern void cgroup_fork_failed(struct task_struct *p, int run_callbacks,
+			       unsigned long clone_flags);
 extern int cgroupstats_build(struct cgroupstats *stats,
 				struct dentry *dentry);
 
@@ -568,10 +570,14 @@ unsigned short css_depth(struct cgroup_subsys_state *css);
 
 static inline int cgroup_init_early(void) { return 0; }
 static inline int cgroup_init(void) { return 0; }
-static inline void cgroup_fork(struct task_struct *p) {}
+static inline void cgroup_fork(struct task_struct *p,
+			       unsigned long clone_flags) {}
 static inline void cgroup_fork_callbacks(struct task_struct *p) {}
-static inline void cgroup_post_fork(struct task_struct *p) {}
+static inline void cgroup_post_fork(struct task_struct *p,
+				    unsigned long clone_flags) {}
 static inline void cgroup_exit(struct task_struct *p, int callbacks) {}
+static inline void cgroup_fork_failed(struct task_struct *p, int callbacks,
+				      unsigned long clone_flags) {}
 
 static inline void cgroup_lock(void) {}
 static inline void cgroup_unlock(void) {}
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 20cbdd2..42da017 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -41,7 +41,16 @@ extern struct nsproxy init_nsproxy;
 	INIT_IPC_NS(ipc_ns)						\
 }
 
+#ifdef CONFIG_CGROUPS
+# define INIT_THREADGROUP_FORK_LOCK(sighand)				\
+	.threadgroup_fork_lock = 					\
+		__RWSEM_INITIALIZER(sighand.threadgroup_fork_lock),
+#else
+# define INIT_THREADGROUP_FORK_LOCK(sighand)
+#endif
+
 #define INIT_SIGHAND(sighand) {						\
+	INIT_THREADGROUP_FORK_LOCK(sighand)				\
 	.count		= ATOMIC_INIT(1), 				\
 	.action		= { { { .sa_handler = NULL, } }, },		\
 	.siglock	= __SPIN_LOCK_UNLOCKED(sighand.siglock),	\
diff --git a/include/linux/sched.h b/include/linux/sched.h
index e6aa408..f3d5275 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -479,6 +479,21 @@ extern int get_dumpable(struct mm_struct *mm);
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
 struct sighand_struct {
+#ifdef CONFIG_CGROUPS
+	/*
+	 * The threadgroup_fork_lock is used to prevent any threads in a
+	 * threadgroup from forking with CLONE_THREAD while held for writing,
+	 * used for threadgroup-wide operations that are fork-sensitive. It
+	 * lives here next to sighand.count as a cacheline optimization.
+	 *
+	 * TODO: if anybody besides cgroups uses this lock, change the
+	 * CONFIG_CGROUPS to a higher-up CONFIG_* that the other user and
+	 * cgroups would both depend upon. Also, they'll want to move where
+	 * the readlock happens - it currently lives in kernel/cgroup.c in
+	 * cgroup_{fork,post_fork,fork_failed}().
+	 */
+	struct rw_semaphore	threadgroup_fork_lock;
+#endif
 	atomic_t		count;
 	struct k_sigaction	action[_NSIG];
 	spinlock_t		siglock;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index fb3ba27..d49488f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1529,6 +1529,65 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 }
 
 /**
+ * threadgroup_fork_lock - block all CLONE_THREAD forks in the threadgroup
+ * @tsk: the task whose threadgroup should be locked
+ *
+ * Takes the threadgroup_lock_mutex in the threadgroup's sighand_struct, by
+ * means of searching the threadgroup list for a live thread in the group.
+ * Returns the sighand_struct that should be given to threadgroup_fork_unlock,
+ * or NULL if all threads in the group are exiting and have cleared their
+ * sighand pointers.
+ */
+struct sighand_struct *threadgroup_fork_lock(struct task_struct *tsk)
+{
+	struct sighand_struct *sighand;
+	struct task_struct *p;
+
+	/* tasklist lock protects sighand_struct's disappearance in exit(). */
+	read_lock(&tasklist_lock);
+	if (likely(tsk->sighand)) {
+		/* simple case - check the thread we were given first */
+		sighand = tsk->sighand;
+	} else {
+		sighand = NULL;
+		/*
+		 * tsk is exiting; try to find another thread in the group
+		 * whose sighand pointer is still alive.
+		 */
+		rcu_read_lock();
+		list_for_each_entry_rcu(p, &tsk->thread_group, thread_group) {
+			if (p->sighand) {
+				sighand = tsk->sighand;
+				break;
+			}
+		}
+		rcu_read_unlock();
+	}
+	/* prevent sighand from vanishing before we let go of tasklist_lock */
+	if (likely(sighand))
+		atomic_inc(&sighand->count);
+
+	/* done searching. */
+	read_unlock(&tasklist_lock);
+
+	if (likely(sighand))
+		down_write(&sighand->threadgroup_fork_lock);
+	return sighand;
+}
+
+/**
+ * threadgroup_fork_lock - let threadgroup resume CLONE_THREAD forks.
+ * @sighand: the threadgroup's sighand that threadgroup_fork_lock gave back
+ *
+ * Lets go of the threadgroup_fork_lock, and drops the sighand reference.
+ */
+void threadgroup_fork_unlock(struct sighand_struct *sighand)
+{
+	up_write(&sighand->threadgroup_fork_lock);
+	__cleanup_sighand(sighand);
+}
+
+/**
  * cgroup_attach_task - attach task 'tsk' to cgroup 'cgrp'
  * @cgrp: the cgroup the task is attaching to
  * @tsk: the task to be attached
@@ -3421,8 +3480,10 @@ static struct file_operations proc_cgroupstats_operations = {
  * At the point that cgroup_fork() is called, 'current' is the parent
  * task, and the passed argument 'child' points to the child task.
  */
-void cgroup_fork(struct task_struct *child)
+void cgroup_fork(struct task_struct *child, unsigned long clone_flags)
 {
+	if (clone_flags & CLONE_THREAD)
+		down_read(&current->sighand->threadgroup_fork_lock);
 	task_lock(current);
 	child->cgroups = current->cgroups;
 	get_css_set(child->cgroups);
@@ -3459,7 +3520,7 @@ void cgroup_fork_callbacks(struct task_struct *child)
  * with the first call to cgroup_iter_start() - to guarantee that the
  * new task ends up on its list.
  */
-void cgroup_post_fork(struct task_struct *child)
+void cgroup_post_fork(struct task_struct *child, unsigned long clone_flags)
 {
 	if (use_task_css_set_links) {
 		write_lock(&css_set_lock);
@@ -3469,6 +3530,8 @@ void cgroup_post_fork(struct task_struct *child)
 		task_unlock(child);
 		write_unlock(&css_set_lock);
 	}
+	if (clone_flags & CLONE_THREAD)
+		up_read(&current->sighand->threadgroup_fork_lock);
 }
 /**
  * cgroup_exit - detach cgroup from exiting task
@@ -3540,6 +3603,26 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
 }
 
 /**
+ * cgroup_fork_failed - undo operations for fork failure
+ * @tsk: pointer to  task_struct of exiting process
+ * @run_callback: run exit callbacks?
+ *
+ * Description: Undo cgroup operations after cgroup_fork in fork failure.
+ *
+ * We release the read lock that was taken in cgroup_fork(), since it is
+ * supposed to be dropped in cgroup_post_fork in the success case. The other
+ * thing that wants to be done is detaching the failed child task from the
+ * cgroup, so we wrap cgroup_exit.
+ */
+void cgroup_fork_failed(struct task_struct *tsk, int run_callbacks,
+			unsigned long clone_flags)
+{
+	if (clone_flags & CLONE_THREAD)
+		up_read(&current->sighand->threadgroup_fork_lock);
+	cgroup_exit(tsk, run_callbacks);
+}
+
+/**
  * cgroup_clone - clone the cgroup the given subsystem is attached to
  * @tsk: the task to be moved
  * @subsys: the given subsystem
diff --git a/kernel/fork.c b/kernel/fork.c
index a010918..0db5289 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -806,6 +806,9 @@ static int copy_sighand(unsigned long clone_flags, struct task_struct *tsk)
 		return -ENOMEM;
 	atomic_set(&sig->count, 1);
 	memcpy(sig->action, current->sighand->action, sizeof(sig->action));
+#ifdef CONFIG_CGROUPS
+	init_rwsem(&sig->threadgroup_fork_lock);
+#endif
 	return 0;
 }
 
@@ -1097,7 +1100,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	monotonic_to_bootbased(&p->real_start_time);
 	p->io_context = NULL;
 	p->audit_context = NULL;
-	cgroup_fork(p);
+	cgroup_fork(p, clone_flags);
 #ifdef CONFIG_NUMA
 	p->mempolicy = mpol_dup(p->mempolicy);
  	if (IS_ERR(p->mempolicy)) {
@@ -1315,7 +1318,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	spin_unlock(&current->sighand->siglock);
 	write_unlock_irq(&tasklist_lock);
 	proc_fork_connector(p);
-	cgroup_post_fork(p);
+	cgroup_post_fork(p, clone_flags);
 	perf_counter_fork(p);
 	return p;
 
@@ -1347,7 +1350,7 @@ bad_fork_cleanup_policy:
 	mpol_put(p->mempolicy);
 bad_fork_cleanup_cgroup:
 #endif
-	cgroup_exit(p, cgroup_callbacks_done);
+	cgroup_fork_failed(p, cgroup_callbacks_done, clone_flags);
 	delayacct_tsk_free(p);
 	module_put(task_thread_info(p)->exec_domain->module);
 bad_fork_cleanup_count:
