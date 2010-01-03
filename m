From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [RFC] [PATCH 1/2] cgroups: read-write lock CLONE_THREAD forking per
	threadgroup
Date: Sun, 3 Jan 2010 14:07:52 -0500
Message-ID: <20100103190752.GB13423@andrew.cmu.edu>
References: <200908202114.n7KLEN5H026646@imap1.linux-foundation.org>
	<20090821102611.GA2611@redhat.com>
	<20090821104528.GA3487@redhat.com>
	<6599ad830908211637w6c9fd3a7tbe41bc106ada03d7@mail.gmail.com>
	<20090822130952.GA4240@redhat.com>
	<20100103190613.GA13423@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: attachment; filename="cgroup-threadgroup-fork-lock.patch"
In-Reply-To: <20100103190613.GA13423-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, lizf@c
List-Id: containers.vger.kernel.org

Adds functionality to read/write lock CLONE_THREAD fork()ing per-threadgroup

From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

This patch adds an rwsem that lives in a threadgroup's sighand_struct (next to
the sighand's atomic count, to piggyback on its cacheline), and two functions
in kernel/cgroup.c (for now) for easily+safely obtaining and releasing it. If
another part of the kernel later wants to use such a locking mechanism, the
CONFIG_CGROUPS ifdefs should be changed to a higher-up flag that CGROUPS and
the other system would both depend on, and the lock/unlock functions could be
moved to sched.c or so.

This is a pre-patch for cgroups-procs-write.patch.

Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
---
 include/linux/cgroup.h    |   14 +++++--
 include/linux/init_task.h |    9 ++++
 include/linux/sched.h     |   15 +++++++
 kernel/cgroup.c           |   93 ++++++++++++++++++++++++++++++++++++++++++++-
 kernel/fork.c             |    9 +++-
 5 files changed, 131 insertions(+), 9 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 9be4c22..2eb54bb 100644
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
 extern int cgroup_load_subsys(struct cgroup_subsys *ss);
@@ -580,10 +582,14 @@ unsigned short css_depth(struct cgroup_subsys_state *css);
 
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
index 8ed0abf..aaa4b9c 100644
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
index 23b26c7..10a22a5 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -475,6 +475,21 @@ extern int get_dumpable(struct mm_struct *mm);
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
index cc2e1f6..99782a0 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1623,6 +1623,71 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 }
 
 /**
+ * threadgroup_fork_lock - block all CLONE_THREAD forks in the threadgroup
+ * @tsk: the task whose threadgroup should be locked
+ *
+ * Takes the threadgroup_lock_mutex in the threadgroup's sighand_struct, by
+ * means of searching the threadgroup list for a live thread in the group.
+ * Returns the sighand_struct that should be given to threadgroup_fork_unlock,
+ * or -ESRCH if all threads in the group are exiting and have cleared their
+ * sighand pointers, or -EAGAIN if tsk is not the threadgroup leader.
+ */
+struct sighand_struct *threadgroup_fork_lock(struct task_struct *tsk)
+{
+	struct sighand_struct *sighand;
+	struct task_struct *p;
+
+	/* tasklist lock protects sighand_struct's disappearance in exit(). */
+	read_lock(&tasklist_lock);
+
+	/* make sure the threadgroup's state is sane before we proceed */
+	if (unlikely(!thread_group_leader(tsk))) {
+		/* a race with de_thread() stripped us of our leadership */
+		read_unlock(&tasklist_lock);
+		return ERR_PTR(-EAGAIN);
+	}
+
+	/* now try to find a sighand */
+	if (likely(tsk->sighand)) {
+		sighand = tsk->sighand;
+	} else {
+		sighand = ERR_PTR(-ESRCH);
+		/*
+		 * tsk is exiting; try to find another thread in the group
+		 * whose sighand pointer is still alive.
+		 */
+		list_for_each_entry_rcu(p, &tsk->thread_group, thread_group) {
+			if (p->sighand) {
+				sighand = tsk->sighand;
+				break;
+			}
+		}
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
@@ -3713,8 +3778,10 @@ static const struct file_operations proc_cgroupstats_operations = {
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
@@ -3756,7 +3823,7 @@ void cgroup_fork_callbacks(struct task_struct *child)
  * with the first call to cgroup_iter_start() - to guarantee that the
  * new task ends up on its list.
  */
-void cgroup_post_fork(struct task_struct *child)
+void cgroup_post_fork(struct task_struct *child, unsigned long clone_flags)
 {
 	if (use_task_css_set_links) {
 		write_lock(&css_set_lock);
@@ -3766,6 +3833,8 @@ void cgroup_post_fork(struct task_struct *child)
 		task_unlock(child);
 		write_unlock(&css_set_lock);
 	}
+	if (clone_flags & CLONE_THREAD)
+		up_read(&current->sighand->threadgroup_fork_lock);
 }
 /**
  * cgroup_exit - detach cgroup from exiting task
@@ -3841,6 +3910,26 @@ void cgroup_exit(struct task_struct *tsk, int run_callbacks)
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
index 404e6ca..daf5967 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -809,6 +809,9 @@ static int copy_sighand(unsigned long clone_flags, struct task_struct *tsk)
 		return -ENOMEM;
 	atomic_set(&sig->count, 1);
 	memcpy(sig->action, current->sighand->action, sizeof(sig->action));
+#ifdef CONFIG_CGROUPS
+	init_rwsem(&sig->threadgroup_fork_lock);
+#endif
 	return 0;
 }
 
@@ -1091,7 +1094,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	monotonic_to_bootbased(&p->real_start_time);
 	p->io_context = NULL;
 	p->audit_context = NULL;
-	cgroup_fork(p);
+	cgroup_fork(p, clone_flags);
 #ifdef CONFIG_NUMA
 	p->mempolicy = mpol_dup(p->mempolicy);
  	if (IS_ERR(p->mempolicy)) {
@@ -1316,7 +1319,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	spin_unlock(&current->sighand->siglock);
 	write_unlock_irq(&tasklist_lock);
 	proc_fork_connector(p);
-	cgroup_post_fork(p);
+	cgroup_post_fork(p, clone_flags);
 	perf_event_fork(p);
 	return p;
 
@@ -1350,7 +1353,7 @@ bad_fork_cleanup_policy:
 	mpol_put(p->mempolicy);
 bad_fork_cleanup_cgroup:
 #endif
-	cgroup_exit(p, cgroup_callbacks_done);
+	cgroup_fork_failed(p, cgroup_callbacks_done, clone_flags);
 	delayacct_tsk_free(p);
 	module_put(task_thread_info(p)->exec_domain->module);
 bad_fork_cleanup_count:
