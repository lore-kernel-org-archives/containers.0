From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [GIT PULL] cgroup changes for v3.3-rc1
Date: Mon, 9 Jan 2012 10:39:51 -0800
Message-ID: <20120109183951.GB7421@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Linus.

Please pull from the following branch to receive cgroup changes.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.3

The big change is threadgroup locking, which was discussed in the
following thread.

  http://thread.gmane.org/gmane.linux.kernel.containers/21716/focus=26390

The change enabled cgroup core cleanups and removal of corner cases,
which Frederic and Mandeep have been working on and more should be
coming.

Thank you.

Dan Carpenter (1):
      cgroup: move assignement out of condition in cgroup_attach_proc()

Davidlohr Bueso (1):
      resource cgroups: remove bogus cast

Frederic Weisbecker (3):
      cgroup: Drop task_lock(parent) on cgroup_fork()
      cgroup: Remove unnecessary task_lock before fetching css_set on migration
      cgroup: Remove task_lock() from cgroup_post_fork()

Kirill A. Shutemov (2):
      cgroup: mark cgroup_rmdir_waitq and cgroup_attach_proc() as static
      cgroup: add sparse annotation to cgroup_iter_start() and cgroup_iter_end()

Li Zefan (1):
      cgroup: fix to allow mounting a hierarchy by name

Mandeep Singh Baines (4):
      cgroups: remove redundant get/put of css_set from css_set_check_fetched()
      cgroup: remove redundant get/put of old css_set from migrate
      cgroup: remove redundant get/put of task struct
      cgroup: only need to check oldcgrp==newgrp once

Tejun Heo (9):
      cgroup: add cgroup_root_mutex
      threadgroup: rename signal->threadgroup_fork_lock to ->group_rwsem
      threadgroup: extend threadgroup_lock() to cover exit and exec
      cgroup: always lock threadgroup during migration
      cgroup: improve old cgroup handling in cgroup_attach_proc()
      cgroup: introduce cgroup_taskset and use it in subsys->can_attach(), cancel_attach() and attach()
      cgroup: don't use subsys->can_attach_task() or ->attach_task()
      cgroup, cpuset: don't use ss->pre_attach()
      cgroup: kill subsys->can_attach_task(), pre_attach() and attach_task()

 Documentation/cgroups/cgroups.txt |   51 ++---
 block/blk-cgroup.c                |   45 +++--
 include/linux/cgroup.h            |   31 +++-
 include/linux/init_task.h         |    9 +-
 include/linux/sched.h             |   73 +++++--
 kernel/cgroup.c                   |  406 +++++++++++++++++++++----------------
 kernel/cgroup_freezer.c           |   16 +-
 kernel/cpuset.c                   |  105 +++++-----
 kernel/events/core.c              |   13 +-
 kernel/fork.c                     |    8 +-
 kernel/res_counter.c              |    3 +-
 kernel/sched.c                    |   31 ++-
 kernel/signal.c                   |   10 +
 mm/memcontrol.c                   |   16 +-
 security/device_cgroup.c          |    7 +-
 15 files changed, 470 insertions(+), 354 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 9c452ef..a7c96ae 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -594,53 +594,44 @@ rmdir() will fail with it. From this behavior, pre_destroy() can be
 called multiple times against a cgroup.
 
 int can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-	       struct task_struct *task)
+	       struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
 
-Called prior to moving a task into a cgroup; if the subsystem
-returns an error, this will abort the attach operation.  If a NULL
-task is passed, then a successful result indicates that *any*
-unspecified task can be moved into the cgroup. Note that this isn't
-called on a fork. If this method returns 0 (success) then this should
-remain valid while the caller holds cgroup_mutex and it is ensured that either
+Called prior to moving one or more tasks into a cgroup; if the
+subsystem returns an error, this will abort the attach operation.
+@tset contains the tasks to be attached and is guaranteed to have at
+least one task in it.
+
+If there are multiple tasks in the taskset, then:
+  - it's guaranteed that all are from the same thread group
+  - @tset contains all tasks from the thread group whether or not
+    they're switching cgroups
+  - the first task is the leader
+
+Each @tset entry also contains the task's old cgroup and tasks which
+aren't switching cgroup can be skipped easily using the
+cgroup_taskset_for_each() iterator. Note that this isn't called on a
+fork. If this method returns 0 (success) then this should remain valid
+while the caller holds cgroup_mutex and it is ensured that either
 attach() or cancel_attach() will be called in future.
 
-int can_attach_task(struct cgroup *cgrp, struct task_struct *tsk);
-(cgroup_mutex held by caller)
-
-As can_attach, but for operations that must be run once per task to be
-attached (possibly many when using cgroup_attach_proc). Called after
-can_attach.
-
 void cancel_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-	       struct task_struct *task, bool threadgroup)
+		   struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
 
 Called when a task attach operation has failed after can_attach() has succeeded.
 A subsystem whose can_attach() has some side-effects should provide this
 function, so that the subsystem can implement a rollback. If not, not necessary.
 This will be called only about subsystems whose can_attach() operation have
-succeeded.
-
-void pre_attach(struct cgroup *cgrp);
-(cgroup_mutex held by caller)
-
-For any non-per-thread attachment work that needs to happen before
-attach_task. Needed by cpuset.
+succeeded. The parameters are identical to can_attach().
 
 void attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
-	    struct cgroup *old_cgrp, struct task_struct *task)
+	    struct cgroup_taskset *tset)
 (cgroup_mutex held by caller)
 
 Called after the task has been attached to the cgroup, to allow any
 post-attachment activity that requires memory allocations or blocking.
-
-void attach_task(struct cgroup *cgrp, struct task_struct *tsk);
-(cgroup_mutex held by caller)
-
-As attach, but for operations that must be run once per task to be attached,
-like can_attach_task. Called before attach. Currently does not support any
-subsystem that might need the old_cgrp for every thread in the group.
+The parameters are identical to can_attach().
 
 void fork(struct cgroup_subsy *ss, struct task_struct *task)
 
diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 8f630ce..b8c143d 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -30,8 +30,10 @@ EXPORT_SYMBOL_GPL(blkio_root_cgroup);
 
 static struct cgroup_subsys_state *blkiocg_create(struct cgroup_subsys *,
 						  struct cgroup *);
-static int blkiocg_can_attach_task(struct cgroup *, struct task_struct *);
-static void blkiocg_attach_task(struct cgroup *, struct task_struct *);
+static int blkiocg_can_attach(struct cgroup_subsys *, struct cgroup *,
+			      struct cgroup_taskset *);
+static void blkiocg_attach(struct cgroup_subsys *, struct cgroup *,
+			   struct cgroup_taskset *);
 static void blkiocg_destroy(struct cgroup_subsys *, struct cgroup *);
 static int blkiocg_populate(struct cgroup_subsys *, struct cgroup *);
 
@@ -44,8 +46,8 @@ static int blkiocg_populate(struct cgroup_subsys *, struct cgroup *);
 struct cgroup_subsys blkio_subsys = {
 	.name = "blkio",
 	.create = blkiocg_create,
-	.can_attach_task = blkiocg_can_attach_task,
-	.attach_task = blkiocg_attach_task,
+	.can_attach = blkiocg_can_attach,
+	.attach = blkiocg_attach,
 	.destroy = blkiocg_destroy,
 	.populate = blkiocg_populate,
 #ifdef CONFIG_BLK_CGROUP
@@ -1626,30 +1628,39 @@ done:
  * of the main cic data structures.  For now we allow a task to change
  * its cgroup only if it's the only owner of its ioc.
  */
-static int blkiocg_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+static int blkiocg_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			      struct cgroup_taskset *tset)
 {
+	struct task_struct *task;
 	struct io_context *ioc;
 	int ret = 0;
 
 	/* task_lock() is needed to avoid races with exit_io_context() */
-	task_lock(tsk);
-	ioc = tsk->io_context;
-	if (ioc && atomic_read(&ioc->nr_tasks) > 1)
-		ret = -EINVAL;
-	task_unlock(tsk);
-
+	cgroup_taskset_for_each(task, cgrp, tset) {
+		task_lock(task);
+		ioc = task->io_context;
+		if (ioc && atomic_read(&ioc->nr_tasks) > 1)
+			ret = -EINVAL;
+		task_unlock(task);
+		if (ret)
+			break;
+	}
 	return ret;
 }
 
-static void blkiocg_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+static void blkiocg_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			   struct cgroup_taskset *tset)
 {
+	struct task_struct *task;
 	struct io_context *ioc;
 
-	task_lock(tsk);
-	ioc = tsk->io_context;
-	if (ioc)
-		ioc->cgroup_changed = 1;
-	task_unlock(tsk);
+	cgroup_taskset_for_each(task, cgrp, tset) {
+		task_lock(task);
+		ioc = task->io_context;
+		if (ioc)
+			ioc->cgroup_changed = 1;
+		task_unlock(task);
+	}
 }
 
 void blkio_policy_register(struct blkio_policy_type *blkiop)
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 1b7f9d5..7ad5e40 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -457,6 +457,28 @@ void cgroup_exclude_rmdir(struct cgroup_subsys_state *css);
 void cgroup_release_and_wakeup_rmdir(struct cgroup_subsys_state *css);
 
 /*
+ * Control Group taskset, used to pass around set of tasks to cgroup_subsys
+ * methods.
+ */
+struct cgroup_taskset;
+struct task_struct *cgroup_taskset_first(struct cgroup_taskset *tset);
+struct task_struct *cgroup_taskset_next(struct cgroup_taskset *tset);
+struct cgroup *cgroup_taskset_cur_cgroup(struct cgroup_taskset *tset);
+int cgroup_taskset_size(struct cgroup_taskset *tset);
+
+/**
+ * cgroup_taskset_for_each - iterate cgroup_taskset
+ * @task: the loop cursor
+ * @skip_cgrp: skip if task's cgroup matches this, %NULL to iterate through all
+ * @tset: taskset to iterate
+ */
+#define cgroup_taskset_for_each(task, skip_cgrp, tset)			\
+	for ((task) = cgroup_taskset_first((tset)); (task);		\
+	     (task) = cgroup_taskset_next((tset)))			\
+		if (!(skip_cgrp) ||					\
+		    cgroup_taskset_cur_cgroup((tset)) != (skip_cgrp))
+
+/*
  * Control Group subsystem type.
  * See Documentation/cgroups/cgroups.txt for details
  */
@@ -467,14 +489,11 @@ struct cgroup_subsys {
 	int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
 	int (*can_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			  struct task_struct *tsk);
-	int (*can_attach_task)(struct cgroup *cgrp, struct task_struct *tsk);
+			  struct cgroup_taskset *tset);
 	void (*cancel_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
-			      struct task_struct *tsk);
-	void (*pre_attach)(struct cgroup *cgrp);
-	void (*attach_task)(struct cgroup *cgrp, struct task_struct *tsk);
+			      struct cgroup_taskset *tset);
 	void (*attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
-		       struct cgroup *old_cgrp, struct task_struct *tsk);
+		       struct cgroup_taskset *tset);
 	void (*fork)(struct cgroup_subsys *ss, struct task_struct *task);
 	void (*exit)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			struct cgroup *old_cgrp, struct task_struct *task);
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 94b1e35..f4544b9 100644
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
index d81cce9..c0c5876 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -635,13 +635,15 @@ struct signal_struct {
 #endif
 #ifdef CONFIG_CGROUPS
 	/*
-	 * The threadgroup_fork_lock prevents threads from forking with
-	 * CLONE_THREAD while held for writing. Use this for fork-sensitive
-	 * threadgroup-wide operations. It's taken for reading in fork.c in
-	 * copy_process().
-	 * Currently only needed write-side by cgroups.
+	 * group_rwsem prevents new tasks from entering the threadgroup and
+	 * member tasks from exiting,a more specifically, setting of
+	 * PF_EXITING.  fork and exit paths are protected with this rwsem
+	 * using threadgroup_change_begin/end().  Users which require
+	 * threadgroup to remain stable should use threadgroup_[un]lock()
+	 * which also takes care of exec path.  Currently, cgroup is the
+	 * only user.
 	 */
-	struct rw_semaphore threadgroup_fork_lock;
+	struct rw_semaphore group_rwsem;
 #endif
 
 	int oom_adj;		/* OOM kill score adjustment (bit shift) */
@@ -2371,29 +2373,62 @@ static inline void unlock_task_sighand(struct task_struct *tsk,
 	spin_unlock_irqrestore(&tsk->sighand->siglock, *flags);
 }
 
-/* See the declaration of threadgroup_fork_lock in signal_struct. */
 #ifdef CONFIG_CGROUPS
-static inline void threadgroup_fork_read_lock(struct task_struct *tsk)
+static inline void threadgroup_change_begin(struct task_struct *tsk)
 {
-	down_read(&tsk->signal->threadgroup_fork_lock);
+	down_read(&tsk->signal->group_rwsem);
 }
-static inline void threadgroup_fork_read_unlock(struct task_struct *tsk)
+static inline void threadgroup_change_end(struct task_struct *tsk)
 {
-	up_read(&tsk->signal->threadgroup_fork_lock);
+	up_read(&tsk->signal->group_rwsem);
 }
-static inline void threadgroup_fork_write_lock(struct task_struct *tsk)
+
+/**
+ * threadgroup_lock - lock threadgroup
+ * @tsk: member task of the threadgroup to lock
+ *
+ * Lock the threadgroup @tsk belongs to.  No new task is allowed to enter
+ * and member tasks aren't allowed to exit (as indicated by PF_EXITING) or
+ * perform exec.  This is useful for cases where the threadgroup needs to
+ * stay stable across blockable operations.
+ *
+ * fork and exit paths explicitly call threadgroup_change_{begin|end}() for
+ * synchronization.  While held, no new task will be added to threadgroup
+ * and no existing live task will have its PF_EXITING set.
+ *
+ * During exec, a task goes and puts its thread group through unusual
+ * changes.  After de-threading, exclusive access is assumed to resources
+ * which are usually shared by tasks in the same group - e.g. sighand may
+ * be replaced with a new one.  Also, the exec'ing task takes over group
+ * leader role including its pid.  Exclude these changes while locked by
+ * grabbing cred_guard_mutex which is used to synchronize exec path.
+ */
+static inline void threadgroup_lock(struct task_struct *tsk)
 {
-	down_write(&tsk->signal->threadgroup_fork_lock);
+	/*
+	 * exec uses exit for de-threading nesting group_rwsem inside
+	 * cred_guard_mutex. Grab cred_guard_mutex first.
+	 */
+	mutex_lock(&tsk->signal->cred_guard_mutex);
+	down_write(&tsk->signal->group_rwsem);
 }
-static inline void threadgroup_fork_write_unlock(struct task_struct *tsk)
+
+/**
+ * threadgroup_unlock - unlock threadgroup
+ * @tsk: member task of the threadgroup to unlock
+ *
+ * Reverse threadgroup_lock().
+ */
+static inline void threadgroup_unlock(struct task_struct *tsk)
 {
-	up_write(&tsk->signal->threadgroup_fork_lock);
+	up_write(&tsk->signal->group_rwsem);
+	mutex_unlock(&tsk->signal->cred_guard_mutex);
 }
 #else
-static inline void threadgroup_fork_read_lock(struct task_struct *tsk) {}
-static inline void threadgroup_fork_read_unlock(struct task_struct *tsk) {}
-static inline void threadgroup_fork_write_lock(struct task_struct *tsk) {}
-static inline void threadgroup_fork_write_unlock(struct task_struct *tsk) {}
+static inline void threadgroup_change_begin(struct task_struct *tsk) {}
+static inline void threadgroup_change_end(struct task_struct *tsk) {}
+static inline void threadgroup_lock(struct task_struct *tsk) {}
+static inline void threadgroup_unlock(struct task_struct *tsk) {}
 #endif
 
 #ifndef __HAVE_THREAD_FUNCTIONS
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d9d5648..39c7cae 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -63,7 +63,24 @@
 
 #include <linux/atomic.h>
 
+/*
+ * cgroup_mutex is the master lock.  Any modification to cgroup or its
+ * hierarchy must be performed while holding it.
+ *
+ * cgroup_root_mutex nests inside cgroup_mutex and should be held to modify
+ * cgroupfs_root of any cgroup hierarchy - subsys list, flags,
+ * release_agent_path and so on.  Modifying requires both cgroup_mutex and
+ * cgroup_root_mutex.  Readers can acquire either of the two.  This is to
+ * break the following locking order cycle.
+ *
+ *  A. cgroup_mutex -> cred_guard_mutex -> s_type->i_mutex_key -> namespace_sem
+ *  B. namespace_sem -> cgroup_mutex
+ *
+ * B happens only through cgroup_show_options() and using cgroup_root_mutex
+ * breaks it.
+ */
 static DEFINE_MUTEX(cgroup_mutex);
+static DEFINE_MUTEX(cgroup_root_mutex);
 
 /*
  * Generate an array of cgroup subsystem pointers. At boot time, this is
@@ -921,7 +938,7 @@ static void cgroup_d_remove_dir(struct dentry *dentry)
  *
  * CGRP_WAIT_ON_RMDIR flag is set under cgroup's inode->i_mutex;
  */
-DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
+static DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
 
 static void cgroup_wakeup_rmdir_waiter(struct cgroup *cgrp)
 {
@@ -953,6 +970,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	int i;
 
 	BUG_ON(!mutex_is_locked(&cgroup_mutex));
+	BUG_ON(!mutex_is_locked(&cgroup_root_mutex));
 
 	removed_bits = root->actual_subsys_bits & ~final_bits;
 	added_bits = final_bits & ~root->actual_subsys_bits;
@@ -1043,7 +1061,7 @@ static int cgroup_show_options(struct seq_file *seq, struct vfsmount *vfs)
 	struct cgroupfs_root *root = vfs->mnt_sb->s_fs_info;
 	struct cgroup_subsys *ss;
 
-	mutex_lock(&cgroup_mutex);
+	mutex_lock(&cgroup_root_mutex);
 	for_each_subsys(root, ss)
 		seq_printf(seq, ",%s", ss->name);
 	if (test_bit(ROOT_NOPREFIX, &root->flags))
@@ -1054,7 +1072,7 @@ static int cgroup_show_options(struct seq_file *seq, struct vfsmount *vfs)
 		seq_puts(seq, ",clone_children");
 	if (strlen(root->name))
 		seq_printf(seq, ",name=%s", root->name);
-	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&cgroup_root_mutex);
 	return 0;
 }
 
@@ -1175,10 +1193,10 @@ static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
 
 	/*
 	 * If the 'all' option was specified select all the subsystems,
-	 * otherwise 'all, 'none' and a subsystem name options were not
-	 * specified, let's default to 'all'
+	 * otherwise if 'none', 'name=' and a subsystem name options
+	 * were not specified, let's default to 'all'
 	 */
-	if (all_ss || (!all_ss && !one_ss && !opts->none)) {
+	if (all_ss || (!one_ss && !opts->none && !opts->name)) {
 		for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 			struct cgroup_subsys *ss = subsys[i];
 			if (ss == NULL)
@@ -1269,6 +1287,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 
 	mutex_lock(&cgrp->dentry->d_inode->i_mutex);
 	mutex_lock(&cgroup_mutex);
+	mutex_lock(&cgroup_root_mutex);
 
 	/* See what subsystems are wanted */
 	ret = parse_cgroupfs_options(data, &opts);
@@ -1297,6 +1316,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
  out_unlock:
 	kfree(opts.release_agent);
 	kfree(opts.name);
+	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&cgrp->dentry->d_inode->i_mutex);
 	return ret;
@@ -1481,6 +1501,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	int ret = 0;
 	struct super_block *sb;
 	struct cgroupfs_root *new_root;
+	struct inode *inode;
 
 	/* First find the desired set of subsystems */
 	mutex_lock(&cgroup_mutex);
@@ -1514,7 +1535,6 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		/* We used the new root structure, so this is a new hierarchy */
 		struct list_head tmp_cg_links;
 		struct cgroup *root_cgrp = &root->top_cgroup;
-		struct inode *inode;
 		struct cgroupfs_root *existing_root;
 		const struct cred *cred;
 		int i;
@@ -1528,18 +1548,14 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 
 		mutex_lock(&inode->i_mutex);
 		mutex_lock(&cgroup_mutex);
+		mutex_lock(&cgroup_root_mutex);
 
-		if (strlen(root->name)) {
-			/* Check for name clashes with existing mounts */
-			for_each_active_root(existing_root) {
-				if (!strcmp(existing_root->name, root->name)) {
-					ret = -EBUSY;
-					mutex_unlock(&cgroup_mutex);
-					mutex_unlock(&inode->i_mutex);
-					goto drop_new_super;
-				}
-			}
-		}
+		/* Check for name clashes with existing mounts */
+		ret = -EBUSY;
+		if (strlen(root->name))
+			for_each_active_root(existing_root)
+				if (!strcmp(existing_root->name, root->name))
+					goto unlock_drop;
 
 		/*
 		 * We're accessing css_set_count without locking
@@ -1549,18 +1565,13 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		 * have some link structures left over
 		 */
 		ret = allocate_cg_links(css_set_count, &tmp_cg_links);
-		if (ret) {
-			mutex_unlock(&cgroup_mutex);
-			mutex_unlock(&inode->i_mutex);
-			goto drop_new_super;
-		}
+		if (ret)
+			goto unlock_drop;
 
 		ret = rebind_subsystems(root, root->subsys_bits);
 		if (ret == -EBUSY) {
-			mutex_unlock(&cgroup_mutex);
-			mutex_unlock(&inode->i_mutex);
 			free_cg_links(&tmp_cg_links);
-			goto drop_new_super;
+			goto unlock_drop;
 		}
 		/*
 		 * There must be no failure case after here, since rebinding
@@ -1599,6 +1610,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		cred = override_creds(&init_cred);
 		cgroup_populate_dir(root_cgrp);
 		revert_creds(cred);
+		mutex_unlock(&cgroup_root_mutex);
 		mutex_unlock(&cgroup_mutex);
 		mutex_unlock(&inode->i_mutex);
 	} else {
@@ -1615,6 +1627,10 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	kfree(opts.name);
 	return dget(sb->s_root);
 
+ unlock_drop:
+	mutex_unlock(&cgroup_root_mutex);
+	mutex_unlock(&cgroup_mutex);
+	mutex_unlock(&inode->i_mutex);
  drop_new_super:
 	deactivate_locked_super(sb);
  drop_modules:
@@ -1639,6 +1655,7 @@ static void cgroup_kill_sb(struct super_block *sb) {
 	BUG_ON(!list_empty(&cgrp->sibling));
 
 	mutex_lock(&cgroup_mutex);
+	mutex_lock(&cgroup_root_mutex);
 
 	/* Rebind all subsystems back to the default hierarchy */
 	ret = rebind_subsystems(root, 0);
@@ -1664,6 +1681,7 @@ static void cgroup_kill_sb(struct super_block *sb) {
 		root_count--;
 	}
 
+	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 
 	kill_litter_super(sb);
@@ -1740,11 +1758,90 @@ int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen)
 EXPORT_SYMBOL_GPL(cgroup_path);
 
 /*
+ * Control Group taskset
+ */
+struct task_and_cgroup {
+	struct task_struct	*task;
+	struct cgroup		*cgrp;
+};
+
+struct cgroup_taskset {
+	struct task_and_cgroup	single;
+	struct flex_array	*tc_array;
+	int			tc_array_len;
+	int			idx;
+	struct cgroup		*cur_cgrp;
+};
+
+/**
+ * cgroup_taskset_first - reset taskset and return the first task
+ * @tset: taskset of interest
+ *
+ * @tset iteration is initialized and the first task is returned.
+ */
+struct task_struct *cgroup_taskset_first(struct cgroup_taskset *tset)
+{
+	if (tset->tc_array) {
+		tset->idx = 0;
+		return cgroup_taskset_next(tset);
+	} else {
+		tset->cur_cgrp = tset->single.cgrp;
+		return tset->single.task;
+	}
+}
+EXPORT_SYMBOL_GPL(cgroup_taskset_first);
+
+/**
+ * cgroup_taskset_next - iterate to the next task in taskset
+ * @tset: taskset of interest
+ *
+ * Return the next task in @tset.  Iteration must have been initialized
+ * with cgroup_taskset_first().
+ */
+struct task_struct *cgroup_taskset_next(struct cgroup_taskset *tset)
+{
+	struct task_and_cgroup *tc;
+
+	if (!tset->tc_array || tset->idx >= tset->tc_array_len)
+		return NULL;
+
+	tc = flex_array_get(tset->tc_array, tset->idx++);
+	tset->cur_cgrp = tc->cgrp;
+	return tc->task;
+}
+EXPORT_SYMBOL_GPL(cgroup_taskset_next);
+
+/**
+ * cgroup_taskset_cur_cgroup - return the matching cgroup for the current task
+ * @tset: taskset of interest
+ *
+ * Return the cgroup for the current (last returned) task of @tset.  This
+ * function must be preceded by either cgroup_taskset_first() or
+ * cgroup_taskset_next().
+ */
+struct cgroup *cgroup_taskset_cur_cgroup(struct cgroup_taskset *tset)
+{
+	return tset->cur_cgrp;
+}
+EXPORT_SYMBOL_GPL(cgroup_taskset_cur_cgroup);
+
+/**
+ * cgroup_taskset_size - return the number of tasks in taskset
+ * @tset: taskset of interest
+ */
+int cgroup_taskset_size(struct cgroup_taskset *tset)
+{
+	return tset->tc_array ? tset->tc_array_len : 1;
+}
+EXPORT_SYMBOL_GPL(cgroup_taskset_size);
+
+
+/*
  * cgroup_task_migrate - move a task from one cgroup to another.
  *
  * 'guarantee' is set if the caller promises that a new css_set for the task
  * will already exist. If not set, this function might sleep, and can fail with
- * -ENOMEM. Otherwise, it can only fail with -ESRCH.
+ * -ENOMEM. Must be called with cgroup_mutex and threadgroup locked.
  */
 static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
 			       struct task_struct *tsk, bool guarantee)
@@ -1753,14 +1850,12 @@ static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
 	struct css_set *newcg;
 
 	/*
-	 * get old css_set. we need to take task_lock and refcount it, because
-	 * an exiting task can change its css_set to init_css_set and drop its
-	 * old one without taking cgroup_mutex.
+	 * We are synchronized through threadgroup_lock() against PF_EXITING
+	 * setting such that we can't race against cgroup_exit() changing the
+	 * css_set to init_css_set and dropping the old one.
 	 */
-	task_lock(tsk);
+	WARN_ON_ONCE(tsk->flags & PF_EXITING);
 	oldcg = tsk->cgroups;
-	get_css_set(oldcg);
-	task_unlock(tsk);
 
 	/* locate or allocate a new css_set for this task. */
 	if (guarantee) {
@@ -1775,20 +1870,11 @@ static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
 		might_sleep();
 		/* find_css_set will give us newcg already referenced. */
 		newcg = find_css_set(oldcg, cgrp);
-		if (!newcg) {
-			put_css_set(oldcg);
+		if (!newcg)
 			return -ENOMEM;
-		}
 	}
-	put_css_set(oldcg);
 
-	/* if PF_EXITING is set, the tsk->cgroups pointer is no longer safe. */
 	task_lock(tsk);
-	if (tsk->flags & PF_EXITING) {
-		task_unlock(tsk);
-		put_css_set(newcg);
-		return -ESRCH;
-	}
 	rcu_assign_pointer(tsk->cgroups, newcg);
 	task_unlock(tsk);
 
@@ -1814,8 +1900,8 @@ static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
  * @cgrp: the cgroup the task is attaching to
  * @tsk: the task to be attached
  *
- * Call holding cgroup_mutex. May take task_lock of
- * the task 'tsk' during call.
+ * Call with cgroup_mutex and threadgroup locked. May take task_lock of
+ * @tsk during call.
  */
 int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 {
@@ -1823,15 +1909,23 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 	struct cgroup_subsys *ss, *failed_ss = NULL;
 	struct cgroup *oldcgrp;
 	struct cgroupfs_root *root = cgrp->root;
+	struct cgroup_taskset tset = { };
+
+	/* @tsk either already exited or can't exit until the end */
+	if (tsk->flags & PF_EXITING)
+		return -ESRCH;
 
 	/* Nothing to do if the task is already in that cgroup */
 	oldcgrp = task_cgroup_from_root(tsk, root);
 	if (cgrp == oldcgrp)
 		return 0;
 
+	tset.single.task = tsk;
+	tset.single.cgrp = oldcgrp;
+
 	for_each_subsys(root, ss) {
 		if (ss->can_attach) {
-			retval = ss->can_attach(ss, cgrp, tsk);
+			retval = ss->can_attach(ss, cgrp, &tset);
 			if (retval) {
 				/*
 				 * Remember on which subsystem the can_attach()
@@ -1843,13 +1937,6 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 				goto out;
 			}
 		}
-		if (ss->can_attach_task) {
-			retval = ss->can_attach_task(cgrp, tsk);
-			if (retval) {
-				failed_ss = ss;
-				goto out;
-			}
-		}
 	}
 
 	retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, false);
@@ -1857,12 +1944,8 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
 		goto out;
 
 	for_each_subsys(root, ss) {
-		if (ss->pre_attach)
-			ss->pre_attach(cgrp);
-		if (ss->attach_task)
-			ss->attach_task(cgrp, tsk);
 		if (ss->attach)
-			ss->attach(ss, cgrp, oldcgrp, tsk);
+			ss->attach(ss, cgrp, &tset);
 	}
 
 	synchronize_rcu();
@@ -1884,7 +1967,7 @@ out:
 				 */
 				break;
 			if (ss->cancel_attach)
-				ss->cancel_attach(ss, cgrp, tsk);
+				ss->cancel_attach(ss, cgrp, &tset);
 		}
 	}
 	return retval;
@@ -1935,23 +2018,17 @@ static bool css_set_check_fetched(struct cgroup *cgrp,
 
 	read_lock(&css_set_lock);
 	newcg = find_existing_css_set(cg, cgrp, template);
-	if (newcg)
-		get_css_set(newcg);
 	read_unlock(&css_set_lock);
 
 	/* doesn't exist at all? */
 	if (!newcg)
 		return false;
 	/* see if it's already in the list */
-	list_for_each_entry(cg_entry, newcg_list, links) {
-		if (cg_entry->cg == newcg) {
-			put_css_set(newcg);
+	list_for_each_entry(cg_entry, newcg_list, links)
+		if (cg_entry->cg == newcg)
 			return true;
-		}
-	}
 
 	/* not found */
-	put_css_set(newcg);
 	return false;
 }
 
@@ -1985,21 +2062,21 @@ static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
  * @cgrp: the cgroup to attach to
  * @leader: the threadgroup leader task_struct of the group to be attached
  *
- * Call holding cgroup_mutex and the threadgroup_fork_lock of the leader. Will
- * take task_lock of each thread in leader's threadgroup individually in turn.
+ * Call holding cgroup_mutex and the group_rwsem of the leader. Will take
+ * task_lock of each thread in leader's threadgroup individually in turn.
  */
-int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
+static int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 {
 	int retval, i, group_size;
 	struct cgroup_subsys *ss, *failed_ss = NULL;
-	bool cancel_failed_ss = false;
 	/* guaranteed to be initialized later, but the compiler needs this */
-	struct cgroup *oldcgrp = NULL;
 	struct css_set *oldcg;
 	struct cgroupfs_root *root = cgrp->root;
 	/* threadgroup list cursor and array */
 	struct task_struct *tsk;
+	struct task_and_cgroup *tc;
 	struct flex_array *group;
+	struct cgroup_taskset tset = { };
 	/*
 	 * we need to make sure we have css_sets for all the tasks we're
 	 * going to move -before- we actually start moving them, so that in
@@ -2012,13 +2089,12 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
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
-	group = flex_array_alloc(sizeof(struct task_struct *), group_size,
-				 GFP_KERNEL);
+	group = flex_array_alloc(sizeof(*tc), group_size, GFP_KERNEL);
 	if (!group)
 		return -ENOMEM;
 	/* pre-allocate to guarantee space while iterating in rcu read-side. */
@@ -2040,49 +2116,53 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 		retval = -EAGAIN;
 		goto out_free_group_list;
 	}
-	/* take a reference on each task in the group to go in the array. */
+
 	tsk = leader;
 	i = 0;
 	do {
+		struct task_and_cgroup ent;
+
+		/* @tsk either already exited or can't exit until the end */
+		if (tsk->flags & PF_EXITING)
+			continue;
+
 		/* as per above, nr_threads may decrease, but not increase. */
 		BUG_ON(i >= group_size);
-		get_task_struct(tsk);
 		/*
 		 * saying GFP_ATOMIC has no effect here because we did prealloc
 		 * earlier, but it's good form to communicate our expectations.
 		 */
-		retval = flex_array_put_ptr(group, i, tsk, GFP_ATOMIC);
+		ent.task = tsk;
+		ent.cgrp = task_cgroup_from_root(tsk, root);
+		/* nothing to do if this task is already in the cgroup */
+		if (ent.cgrp == cgrp)
+			continue;
+		retval = flex_array_put(group, i, &ent, GFP_ATOMIC);
 		BUG_ON(retval != 0);
 		i++;
 	} while_each_thread(leader, tsk);
 	/* remember the number of threads in the array for later. */
 	group_size = i;
+	tset.tc_array = group;
+	tset.tc_array_len = group_size;
 	read_unlock(&tasklist_lock);
 
+	/* methods shouldn't be called if no task is actually migrating */
+	retval = 0;
+	if (!group_size)
+		goto out_free_group_list;
+
 	/*
 	 * step 1: check that we can legitimately attach to the cgroup.
 	 */
 	for_each_subsys(root, ss) {
 		if (ss->can_attach) {
-			retval = ss->can_attach(ss, cgrp, leader);
+			retval = ss->can_attach(ss, cgrp, &tset);
 			if (retval) {
 				failed_ss = ss;
 				goto out_cancel_attach;
 			}
 		}
-		/* a callback to be run on every thread in the threadgroup. */
-		if (ss->can_attach_task) {
-			/* run on each task in the threadgroup. */
-			for (i = 0; i < group_size; i++) {
-				tsk = flex_array_get_ptr(group, i);
-				retval = ss->can_attach_task(cgrp, tsk);
-				if (retval) {
-					failed_ss = ss;
-					cancel_failed_ss = true;
-					goto out_cancel_attach;
-				}
-			}
-		}
 	}
 
 	/*
@@ -2091,72 +2171,36 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 */
 	INIT_LIST_HEAD(&newcg_list);
 	for (i = 0; i < group_size; i++) {
-		tsk = flex_array_get_ptr(group, i);
-		/* nothing to do if this task is already in the cgroup */
-		oldcgrp = task_cgroup_from_root(tsk, root);
-		if (cgrp == oldcgrp)
-			continue;
-		/* get old css_set pointer */
-		task_lock(tsk);
-		if (tsk->flags & PF_EXITING) {
-			/* ignore this task if it's going away */
-			task_unlock(tsk);
-			continue;
-		}
-		oldcg = tsk->cgroups;
-		get_css_set(oldcg);
-		task_unlock(tsk);
-		/* see if the new one for us is already in the list? */
-		if (css_set_check_fetched(cgrp, tsk, oldcg, &newcg_list)) {
-			/* was already there, nothing to do. */
-			put_css_set(oldcg);
-		} else {
-			/* we don't already have it. get new one. */
+		tc = flex_array_get(group, i);
+		oldcg = tc->task->cgroups;
+
+		/* if we don't already have it in the list get a new one */
+		if (!css_set_check_fetched(cgrp, tc->task, oldcg,
+					   &newcg_list)) {
 			retval = css_set_prefetch(cgrp, oldcg, &newcg_list);
-			put_css_set(oldcg);
 			if (retval)
 				goto out_list_teardown;
 		}
 	}
 
 	/*
-	 * step 3: now that we're guaranteed success wrt the css_sets, proceed
-	 * to move all tasks to the new cgroup, calling ss->attach_task for each
-	 * one along the way. there are no failure cases after here, so this is
-	 * the commit point.
+	 * step 3: now that we're guaranteed success wrt the css_sets,
+	 * proceed to move all tasks to the new cgroup.  There are no
+	 * failure cases after here, so this is the commit point.
 	 */
-	for_each_subsys(root, ss) {
-		if (ss->pre_attach)
-			ss->pre_attach(cgrp);
-	}
 	for (i = 0; i < group_size; i++) {
-		tsk = flex_array_get_ptr(group, i);
-		/* leave current thread as it is if it's already there */
-		oldcgrp = task_cgroup_from_root(tsk, root);
-		if (cgrp == oldcgrp)
-			continue;
-		/* if the thread is PF_EXITING, it can just get skipped. */
-		retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, true);
-		if (retval == 0) {
-			/* attach each task to each subsystem */
-			for_each_subsys(root, ss) {
-				if (ss->attach_task)
-					ss->attach_task(cgrp, tsk);
-			}
-		} else {
-			BUG_ON(retval != -ESRCH);
-		}
+		tc = flex_array_get(group, i);
+		retval = cgroup_task_migrate(cgrp, tc->cgrp, tc->task, true);
+		BUG_ON(retval);
 	}
 	/* nothing is sensitive to fork() after this point. */
 
 	/*
-	 * step 4: do expensive, non-thread-specific subsystem callbacks.
-	 * TODO: if ever a subsystem needs to know the oldcgrp for each task
-	 * being moved, this call will need to be reworked to communicate that.
+	 * step 4: do subsystem attach callbacks.
 	 */
 	for_each_subsys(root, ss) {
 		if (ss->attach)
-			ss->attach(ss, cgrp, oldcgrp, leader);
+			ss->attach(ss, cgrp, &tset);
 	}
 
 	/*
@@ -2176,20 +2220,12 @@ out_cancel_attach:
 	/* same deal as in cgroup_attach_task */
 	if (retval) {
 		for_each_subsys(root, ss) {
-			if (ss == failed_ss) {
-				if (cancel_failed_ss && ss->cancel_attach)
-					ss->cancel_attach(ss, cgrp, leader);
+			if (ss == failed_ss)
 				break;
-			}
 			if (ss->cancel_attach)
-				ss->cancel_attach(ss, cgrp, leader);
+				ss->cancel_attach(ss, cgrp, &tset);
 		}
 	}
-	/* clean up the array of referenced threads in the group. */
-	for (i = 0; i < group_size; i++) {
-		tsk = flex_array_get_ptr(group, i);
-		put_task_struct(tsk);
-	}
 out_free_group_list:
 	flex_array_free(group);
 	return retval;
@@ -2197,8 +2233,8 @@ out_free_group_list:
 
 /*
  * Find the task_struct of the task to attach by vpid and pass it along to the
- * function to attach either it or all tasks in its threadgroup. Will take
- * cgroup_mutex; may take task_lock of task.
+ * function to attach either it or all tasks in its threadgroup. Will lock
+ * cgroup_mutex and threadgroup; may take task_lock of task.
  */
 static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 {
@@ -2225,13 +2261,7 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 			 * detect it later.
 			 */
 			tsk = tsk->group_leader;
-		} else if (tsk->flags & PF_EXITING) {
-			/* optimization for the single-task-only case */
-			rcu_read_unlock();
-			cgroup_unlock();
-			return -ESRCH;
 		}
-
 		/*
 		 * even if we're attaching all tasks in the thread group, we
 		 * only need to check permissions on one of them.
@@ -2254,13 +2284,15 @@ static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadgroup)
 		get_task_struct(tsk);
 	}
 
-	if (threadgroup) {
-		threadgroup_fork_write_lock(tsk);
+	threadgroup_lock(tsk);
+
+	if (threadgroup)
 		ret = cgroup_attach_proc(cgrp, tsk);
-		threadgroup_fork_write_unlock(tsk);
-	} else {
+	else
 		ret = cgroup_attach_task(cgrp, tsk);
-	}
+
+	threadgroup_unlock(tsk);
+
 	put_task_struct(tsk);
 	cgroup_unlock();
 	return ret;
@@ -2311,7 +2343,9 @@ static int cgroup_release_agent_write(struct cgroup *cgrp, struct cftype *cft,
 		return -EINVAL;
 	if (!cgroup_lock_live_group(cgrp))
 		return -ENODEV;
+	mutex_lock(&cgroup_root_mutex);
 	strcpy(cgrp->root->release_agent_path, buffer);
+	mutex_unlock(&cgroup_root_mutex);
 	cgroup_unlock();
 	return 0;
 }
@@ -2794,6 +2828,7 @@ static void cgroup_enable_task_cg_lists(void)
 }
 
 void cgroup_iter_start(struct cgroup *cgrp, struct cgroup_iter *it)
+	__acquires(css_set_lock)
 {
 	/*
 	 * The first time anyone tries to iterate across a cgroup,
@@ -2833,6 +2868,7 @@ struct task_struct *cgroup_iter_next(struct cgroup *cgrp,
 }
 
 void cgroup_iter_end(struct cgroup *cgrp, struct cgroup_iter *it)
+	__releases(css_set_lock)
 {
 	read_unlock(&css_set_lock);
 }
@@ -4496,20 +4532,31 @@ static const struct file_operations proc_cgroupstats_operations = {
  *
  * A pointer to the shared css_set was automatically copied in
  * fork.c by dup_task_struct().  However, we ignore that copy, since
- * it was not made under the protection of RCU or cgroup_mutex, so
- * might no longer be a valid cgroup pointer.  cgroup_attach_task() might
- * have already changed current->cgroups, allowing the previously
- * referenced cgroup group to be removed and freed.
+ * it was not made under the protection of RCU, cgroup_mutex or
+ * threadgroup_change_begin(), so it might no longer be a valid
+ * cgroup pointer.  cgroup_attach_task() might have already changed
+ * current->cgroups, allowing the previously referenced cgroup
+ * group to be removed and freed.
+ *
+ * Outside the pointer validity we also need to process the css_set
+ * inheritance between threadgoup_change_begin() and
+ * threadgoup_change_end(), this way there is no leak in any process
+ * wide migration performed by cgroup_attach_proc() that could otherwise
+ * miss a thread because it is too early or too late in the fork stage.
  *
  * At the point that cgroup_fork() is called, 'current' is the parent
  * task, and the passed argument 'child' points to the child task.
  */
 void cgroup_fork(struct task_struct *child)
 {
-	task_lock(current);
+	/*
+	 * We don't need to task_lock() current because current->cgroups
+	 * can't be changed concurrently here. The parent obviously hasn't
+	 * exited and called cgroup_exit(), and we are synchronized against
+	 * cgroup migration through threadgroup_change_begin().
+	 */
 	child->cgroups = current->cgroups;
 	get_css_set(child->cgroups);
-	task_unlock(current);
 	INIT_LIST_HEAD(&child->cg_list);
 }
 
@@ -4551,10 +4598,19 @@ void cgroup_post_fork(struct task_struct *child)
 {
 	if (use_task_css_set_links) {
 		write_lock(&css_set_lock);
-		task_lock(child);
-		if (list_empty(&child->cg_list))
+		if (list_empty(&child->cg_list)) {
+			/*
+			 * It's safe to use child->cgroups without task_lock()
+			 * here because we are protected through
+			 * threadgroup_change_begin() against concurrent
+			 * css_set change in cgroup_task_migrate(). Also
+			 * the task can't exit at that point until
+			 * wake_up_new_task() is called, so we are protected
+			 * against cgroup_exit() setting child->cgroup to
+			 * init_css_set.
+			 */
 			list_add(&child->cg_list, &child->cgroups->tasks);
-		task_unlock(child);
+		}
 		write_unlock(&css_set_lock);
 	}
 }
diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index e411a60..0e74805 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -159,13 +159,17 @@ static void freezer_destroy(struct cgroup_subsys *ss,
  */
 static int freezer_can_attach(struct cgroup_subsys *ss,
 			      struct cgroup *new_cgroup,
-			      struct task_struct *task)
+			      struct cgroup_taskset *tset)
 {
 	struct freezer *freezer;
+	struct task_struct *task;
 
 	/*
 	 * Anything frozen can't move or be moved to/from.
 	 */
+	cgroup_taskset_for_each(task, new_cgroup, tset)
+		if (cgroup_freezing(task))
+			return -EBUSY;
 
 	freezer = cgroup_freezer(new_cgroup);
 	if (freezer->state != CGROUP_THAWED)
@@ -174,11 +178,6 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
 	return 0;
 }
 
-static int freezer_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
-{
-	return cgroup_freezing(tsk) ? -EBUSY : 0;
-}
-
 static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
 {
 	struct freezer *freezer;
@@ -374,10 +373,5 @@ struct cgroup_subsys freezer_subsys = {
 	.populate	= freezer_populate,
 	.subsys_id	= freezer_subsys_id,
 	.can_attach	= freezer_can_attach,
-	.can_attach_task = freezer_can_attach_task,
-	.pre_attach	= NULL,
-	.attach_task	= NULL,
-	.attach		= NULL,
 	.fork		= freezer_fork,
-	.exit		= NULL,
 };
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 9fe58c4..42e5683 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1370,79 +1370,73 @@ static int fmeter_getrate(struct fmeter *fmp)
 	return val;
 }
 
-/* Called by cgroups to determine if a cpuset is usable; cgroup_mutex held */
-static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cont,
-			     struct task_struct *tsk)
-{
-	struct cpuset *cs = cgroup_cs(cont);
-
-	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
-		return -ENOSPC;
-
-	/*
-	 * Kthreads bound to specific cpus cannot be moved to a new cpuset; we
-	 * cannot change their cpu affinity and isolating such threads by their
-	 * set of allowed nodes is unnecessary.  Thus, cpusets are not
-	 * applicable for such threads.  This prevents checking for success of
-	 * set_cpus_allowed_ptr() on all attached tasks before cpus_allowed may
-	 * be changed.
-	 */
-	if (tsk->flags & PF_THREAD_BOUND)
-		return -EINVAL;
-
-	return 0;
-}
-
-static int cpuset_can_attach_task(struct cgroup *cgrp, struct task_struct *task)
-{
-	return security_task_setscheduler(task);
-}
-
 /*
  * Protected by cgroup_lock. The nodemasks must be stored globally because
- * dynamically allocating them is not allowed in pre_attach, and they must
- * persist among pre_attach, attach_task, and attach.
+ * dynamically allocating them is not allowed in can_attach, and they must
+ * persist until attach.
  */
 static cpumask_var_t cpus_attach;
 static nodemask_t cpuset_attach_nodemask_from;
 static nodemask_t cpuset_attach_nodemask_to;
 
-/* Set-up work for before attaching each task. */
-static void cpuset_pre_attach(struct cgroup *cont)
+/* Called by cgroups to determine if a cpuset is usable; cgroup_mutex held */
+static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			     struct cgroup_taskset *tset)
 {
-	struct cpuset *cs = cgroup_cs(cont);
+	struct cpuset *cs = cgroup_cs(cgrp);
+	struct task_struct *task;
+	int ret;
+
+	if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_allowed))
+		return -ENOSPC;
+
+	cgroup_taskset_for_each(task, cgrp, tset) {
+		/*
+		 * Kthreads bound to specific cpus cannot be moved to a new
+		 * cpuset; we cannot change their cpu affinity and
+		 * isolating such threads by their set of allowed nodes is
+		 * unnecessary.  Thus, cpusets are not applicable for such
+		 * threads.  This prevents checking for success of
+		 * set_cpus_allowed_ptr() on all attached tasks before
+		 * cpus_allowed may be changed.
+		 */
+		if (task->flags & PF_THREAD_BOUND)
+			return -EINVAL;
+		if ((ret = security_task_setscheduler(task)))
+			return ret;
+	}
 
+	/* prepare for attach */
 	if (cs == &top_cpuset)
 		cpumask_copy(cpus_attach, cpu_possible_mask);
 	else
 		guarantee_online_cpus(cs, cpus_attach);
 
 	guarantee_online_mems(cs, &cpuset_attach_nodemask_to);
-}
-
-/* Per-thread attachment work. */
-static void cpuset_attach_task(struct cgroup *cont, struct task_struct *tsk)
-{
-	int err;
-	struct cpuset *cs = cgroup_cs(cont);
 
-	/*
-	 * can_attach beforehand should guarantee that this doesn't fail.
-	 * TODO: have a better way to handle failure here
-	 */
-	err = set_cpus_allowed_ptr(tsk, cpus_attach);
-	WARN_ON_ONCE(err);
-
-	cpuset_change_task_nodemask(tsk, &cpuset_attach_nodemask_to);
-	cpuset_update_task_spread_flag(cs, tsk);
+	return 0;
 }
 
-static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
-			  struct cgroup *oldcont, struct task_struct *tsk)
+static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			  struct cgroup_taskset *tset)
 {
 	struct mm_struct *mm;
-	struct cpuset *cs = cgroup_cs(cont);
-	struct cpuset *oldcs = cgroup_cs(oldcont);
+	struct task_struct *task;
+	struct task_struct *leader = cgroup_taskset_first(tset);
+	struct cgroup *oldcgrp = cgroup_taskset_cur_cgroup(tset);
+	struct cpuset *cs = cgroup_cs(cgrp);
+	struct cpuset *oldcs = cgroup_cs(oldcgrp);
+
+	cgroup_taskset_for_each(task, cgrp, tset) {
+		/*
+		 * can_attach beforehand should guarantee that this doesn't
+		 * fail.  TODO: have a better way to handle failure here
+		 */
+		WARN_ON_ONCE(set_cpus_allowed_ptr(task, cpus_attach));
+
+		cpuset_change_task_nodemask(task, &cpuset_attach_nodemask_to);
+		cpuset_update_task_spread_flag(cs, task);
+	}
 
 	/*
 	 * Change mm, possibly for multiple threads in a threadgroup. This is
@@ -1450,7 +1444,7 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
 	 */
 	cpuset_attach_nodemask_from = oldcs->mems_allowed;
 	cpuset_attach_nodemask_to = cs->mems_allowed;
-	mm = get_task_mm(tsk);
+	mm = get_task_mm(leader);
 	if (mm) {
 		mpol_rebind_mm(mm, &cpuset_attach_nodemask_to);
 		if (is_memory_migrate(cs))
@@ -1906,9 +1900,6 @@ struct cgroup_subsys cpuset_subsys = {
 	.create = cpuset_create,
 	.destroy = cpuset_destroy,
 	.can_attach = cpuset_can_attach,
-	.can_attach_task = cpuset_can_attach_task,
-	.pre_attach = cpuset_pre_attach,
-	.attach_task = cpuset_attach_task,
 	.attach = cpuset_attach,
 	.populate = cpuset_populate,
 	.post_clone = cpuset_post_clone,
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 0e8457d..3b8e0ed 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7044,10 +7044,13 @@ static int __perf_cgroup_move(void *info)
 	return 0;
 }
 
-static void
-perf_cgroup_attach_task(struct cgroup *cgrp, struct task_struct *task)
+static void perf_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			       struct cgroup_taskset *tset)
 {
-	task_function_call(task, __perf_cgroup_move, task);
+	struct task_struct *task;
+
+	cgroup_taskset_for_each(task, cgrp, tset)
+		task_function_call(task, __perf_cgroup_move, task);
 }
 
 static void perf_cgroup_exit(struct cgroup_subsys *ss, struct cgroup *cgrp,
@@ -7061,7 +7064,7 @@ static void perf_cgroup_exit(struct cgroup_subsys *ss, struct cgroup *cgrp,
 	if (!(task->flags & PF_EXITING))
 		return;
 
-	perf_cgroup_attach_task(cgrp, task);
+	task_function_call(task, __perf_cgroup_move, task);
 }
 
 struct cgroup_subsys perf_subsys = {
@@ -7070,6 +7073,6 @@ struct cgroup_subsys perf_subsys = {
 	.create		= perf_cgroup_create,
 	.destroy	= perf_cgroup_destroy,
 	.exit		= perf_cgroup_exit,
-	.attach_task	= perf_cgroup_attach_task,
+	.attach		= perf_cgroup_attach,
 };
 #endif /* CONFIG_CGROUP_PERF */
diff --git a/kernel/fork.c b/kernel/fork.c
index 8278086..d4ac9e3 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -972,7 +972,7 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	sched_autogroup_fork(sig);
 
 #ifdef CONFIG_CGROUPS
-	init_rwsem(&sig->threadgroup_fork_lock);
+	init_rwsem(&sig->group_rwsem);
 #endif
 
 	sig->oom_adj = current->signal->oom_adj;
@@ -1157,7 +1157,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	p->io_context = NULL;
 	p->audit_context = NULL;
 	if (clone_flags & CLONE_THREAD)
-		threadgroup_fork_read_lock(current);
+		threadgroup_change_begin(current);
 	cgroup_fork(p);
 #ifdef CONFIG_NUMA
 	p->mempolicy = mpol_dup(p->mempolicy);
@@ -1372,7 +1372,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	proc_fork_connector(p);
 	cgroup_post_fork(p);
 	if (clone_flags & CLONE_THREAD)
-		threadgroup_fork_read_unlock(current);
+		threadgroup_change_end(current);
 	perf_event_fork(p);
 	return p;
 
@@ -1407,7 +1407,7 @@ bad_fork_cleanup_policy:
 bad_fork_cleanup_cgroup:
 #endif
 	if (clone_flags & CLONE_THREAD)
-		threadgroup_fork_read_unlock(current);
+		threadgroup_change_end(current);
 	cgroup_exit(p, cgroup_callbacks_done);
 	delayacct_tsk_free(p);
 	module_put(task_thread_info(p)->exec_domain->module);
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 34683ef..6d269cc 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -159,8 +159,7 @@ int res_counter_memparse_write_strategy(const char *buf,
 		return 0;
 	}
 
-	/* FIXME - make memparse() take const char* args */
-	*res = memparse((char *)buf, &end);
+	*res = memparse(buf, &end);
 	if (*end != '\0')
 		return -EINVAL;
 
diff --git a/kernel/sched.c b/kernel/sched.c
index 0e9344a..161184d 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -9127,24 +9127,31 @@ cpu_cgroup_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
 	sched_destroy_group(tg);
 }
 
-static int
-cpu_cgroup_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+static int cpu_cgroup_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+				 struct cgroup_taskset *tset)
 {
+	struct task_struct *task;
+
+	cgroup_taskset_for_each(task, cgrp, tset) {
 #ifdef CONFIG_RT_GROUP_SCHED
-	if (!sched_rt_can_attach(cgroup_tg(cgrp), tsk))
-		return -EINVAL;
+		if (!sched_rt_can_attach(cgroup_tg(cgrp), task))
+			return -EINVAL;
 #else
-	/* We don't support RT-tasks being in separate groups */
-	if (tsk->sched_class != &fair_sched_class)
-		return -EINVAL;
+		/* We don't support RT-tasks being in separate groups */
+		if (task->sched_class != &fair_sched_class)
+			return -EINVAL;
 #endif
+	}
 	return 0;
 }
 
-static void
-cpu_cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+static void cpu_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
+			      struct cgroup_taskset *tset)
 {
-	sched_move_task(tsk);
+	struct task_struct *task;
+
+	cgroup_taskset_for_each(task, cgrp, tset)
+		sched_move_task(task);
 }
 
 static void
@@ -9480,8 +9487,8 @@ struct cgroup_subsys cpu_cgroup_subsys = {
 	.name		= "cpu",
 	.create		= cpu_cgroup_create,
 	.destroy	= cpu_cgroup_destroy,
-	.can_attach_task = cpu_cgroup_can_attach_task,
-	.attach_task	= cpu_cgroup_attach_task,
+	.can_attach	= cpu_cgroup_can_attach,
+	.attach		= cpu_cgroup_attach,
 	.exit		= cpu_cgroup_exit,
 	.populate	= cpu_cgroup_populate,
 	.subsys_id	= cpu_cgroup_subsys_id,
diff --git a/kernel/signal.c b/kernel/signal.c
index b3f78d0..399c184 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2359,8 +2359,15 @@ void exit_signals(struct task_struct *tsk)
 	int group_stop = 0;
 	sigset_t unblocked;
 
+	/*
+	 * @tsk is about to have PF_EXITING set - lock out users which
+	 * expect stable threadgroup.
+	 */
+	threadgroup_change_begin(tsk);
+
 	if (thread_group_empty(tsk) || signal_group_exit(tsk->signal)) {
 		tsk->flags |= PF_EXITING;
+		threadgroup_change_end(tsk);
 		return;
 	}
 
@@ -2370,6 +2377,9 @@ void exit_signals(struct task_struct *tsk)
 	 * see wants_signal(), do_signal_stop().
 	 */
 	tsk->flags |= PF_EXITING;
+
+	threadgroup_change_end(tsk);
+
 	if (!signal_pending(tsk))
 		goto out;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6aff93c..81640e7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5298,8 +5298,9 @@ static void mem_cgroup_clear_mc(void)
 
 static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 				struct cgroup *cgroup,
-				struct task_struct *p)
+				struct cgroup_taskset *tset)
 {
+	struct task_struct *p = cgroup_taskset_first(tset);
 	int ret = 0;
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
 
@@ -5337,7 +5338,7 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 
 static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
 				struct cgroup *cgroup,
-				struct task_struct *p)
+				struct cgroup_taskset *tset)
 {
 	mem_cgroup_clear_mc();
 }
@@ -5454,9 +5455,9 @@ retry:
 
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct cgroup *cont,
-				struct cgroup *old_cont,
-				struct task_struct *p)
+				struct cgroup_taskset *tset)
 {
+	struct task_struct *p = cgroup_taskset_first(tset);
 	struct mm_struct *mm = get_task_mm(p);
 
 	if (mm) {
@@ -5471,19 +5472,18 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 #else	/* !CONFIG_MMU */
 static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 				struct cgroup *cgroup,
-				struct task_struct *p)
+				struct cgroup_taskset *tset)
 {
 	return 0;
 }
 static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
 				struct cgroup *cgroup,
-				struct task_struct *p)
+				struct cgroup_taskset *tset)
 {
 }
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct cgroup *cont,
-				struct cgroup *old_cont,
-				struct task_struct *p)
+				struct cgroup_taskset *tset)
 {
 }
 #endif
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 4450fbe..8b5b5d8 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -62,11 +62,12 @@ static inline struct dev_cgroup *task_devcgroup(struct task_struct *task)
 struct cgroup_subsys devices_subsys;
 
 static int devcgroup_can_attach(struct cgroup_subsys *ss,
-		struct cgroup *new_cgroup, struct task_struct *task)
+			struct cgroup *new_cgrp, struct cgroup_taskset *set)
 {
-	if (current != task && !capable(CAP_SYS_ADMIN))
-			return -EPERM;
+	struct task_struct *task = cgroup_taskset_first(set);
 
+	if (current != task && !capable(CAP_SYS_ADMIN))
+		return -EPERM;
 	return 0;
 }
