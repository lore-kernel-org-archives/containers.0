From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: [PATCH v8.75 1/4] cgroups: read-write lock CLONE_THREAD forking
	per threadgroup
Date: Wed, 6 Apr 2011 15:45:38 -0400
Message-ID: <20110406194538.GD10792__10783.6931398653$1302119359$gmane$org@ghc17.ghc.andrew.cmu.edu>
References: <20110208013542.GC31569@ghc17.ghc.andrew.cmu.edu>
	<20110406194420.GC10792@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110406194420.GC10792-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Adds functionality to read/write lock CLONE_THREAD fork()ing per-threadgroup

From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

This patch adds an rwsem that lives in a threadgroup's signal_struct that's
taken for reading in the fork path, under CONFIG_CGROUPS. If another part of
the kernel later wants to use such a locking mechanism, the CONFIG_CGROUPS
ifdefs should be changed to a higher-up flag that CGROUPS and the other system
would both depend on.

This is a pre-patch for cgroup-procs-write.patch.

Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
---
 include/linux/init_task.h |    9 +++++++++
 include/linux/sched.h     |   36 ++++++++++++++++++++++++++++++++++++
 kernel/fork.c             |   10 ++++++++++
 3 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index caa151f..7bf5257 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -22,6 +22,14 @@
 extern struct files_struct init_files;
 extern struct fs_struct init_fs;
 
+#ifdef CONFIG_CGROUPS
+#define INIT_THREADGROUP_FORK_LOCK(sig)					\
+	.threadgroup_fork_lock =					\
+		__RWSEM_INITIALIZER(sig.threadgroup_fork_lock),
+#else
+#define INIT_THREADGROUP_FORK_LOCK(sig)
+#endif
+
 #define INIT_SIGNALS(sig) {						\
 	.nr_threads	= 1,						\
 	.wait_chldexit	= __WAIT_QUEUE_HEAD_INITIALIZER(sig.wait_chldexit),\
@@ -38,6 +46,7 @@ extern struct fs_struct init_fs;
 	},								\
 	.cred_guard_mutex =						\
 		 __MUTEX_INITIALIZER(sig.cred_guard_mutex),		\
+	INIT_THREADGROUP_FORK_LOCK(sig)					\
 }
 
 extern struct nsproxy init_nsproxy;
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 3509d00..a219c69 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -514,6 +514,7 @@ struct thread_group_cputimer {
 	spinlock_t lock;
 };
 
+#include <linux/rwsem.h>
 struct autogroup;
 
 /*
@@ -633,6 +634,16 @@ struct signal_struct {
 	unsigned audit_tty;
 	struct tty_audit_buf *tty_audit_buf;
 #endif
+#ifdef CONFIG_CGROUPS
+	/*
+	 * The threadgroup_fork_lock prevents threads from forking with
+	 * CLONE_THREAD while held for writing. Use this for fork-sensitive
+	 * threadgroup-wide operations. It's taken for reading in fork.c in
+	 * copy_process().
+	 * Currently only needed write-side by cgroups.
+	 */
+	struct rw_semaphore threadgroup_fork_lock;
+#endif
 
 	int oom_adj;		/* OOM kill score adjustment (bit shift) */
 	int oom_score_adj;	/* OOM kill score adjustment */
@@ -2307,6 +2318,31 @@ static inline void unlock_task_sighand(struct task_struct *tsk,
 	spin_unlock_irqrestore(&tsk->sighand->siglock, *flags);
 }
 
+/* See the declaration of threadgroup_fork_lock in signal_struct. */
+#ifdef CONFIG_CGROUPS
+static inline void threadgroup_fork_read_lock(struct task_struct *tsk)
+{
+	down_read(&tsk->signal->threadgroup_fork_lock);
+}
+static inline void threadgroup_fork_read_unlock(struct task_struct *tsk)
+{
+	up_read(&tsk->signal->threadgroup_fork_lock);
+}
+static inline void threadgroup_fork_write_lock(struct task_struct *tsk)
+{
+	down_write(&tsk->signal->threadgroup_fork_lock);
+}
+static inline void threadgroup_fork_write_unlock(struct task_struct *tsk)
+{
+	up_write(&tsk->signal->threadgroup_fork_lock);
+}
+#else
+static inline void threadgroup_fork_read_lock(struct task_struct *tsk) {}
+static inline void threadgroup_fork_read_unlock(struct task_struct *tsk) {}
+static inline void threadgroup_fork_write_lock(struct task_struct *tsk) {}
+static inline void threadgroup_fork_write_unlock(struct task_struct *tsk) {}
+#endif
+
 #ifndef __HAVE_THREAD_FUNCTIONS
 
 #define task_thread_info(task)	((struct thread_info *)(task)->stack)
diff --git a/kernel/fork.c b/kernel/fork.c
index 41d2062..aef33ac 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -927,6 +927,10 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 	tty_audit_fork(sig);
 	sched_autogroup_fork(sig);
 
+#ifdef CONFIG_CGROUPS
+	init_rwsem(&sig->threadgroup_fork_lock);
+#endif
+
 	sig->oom_adj = current->signal->oom_adj;
 	sig->oom_score_adj = current->signal->oom_score_adj;
 	sig->oom_score_adj_min = current->signal->oom_score_adj_min;
@@ -1109,6 +1113,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	monotonic_to_bootbased(&p->real_start_time);
 	p->io_context = NULL;
 	p->audit_context = NULL;
+	if (clone_flags & CLONE_THREAD)
+		threadgroup_fork_read_lock(current);
 	cgroup_fork(p);
 #ifdef CONFIG_NUMA
 	p->mempolicy = mpol_dup(p->mempolicy);
@@ -1307,6 +1313,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	write_unlock_irq(&tasklist_lock);
 	proc_fork_connector(p);
 	cgroup_post_fork(p);
+	if (clone_flags & CLONE_THREAD)
+		threadgroup_fork_read_unlock(current);
 	perf_event_fork(p);
 	return p;
 
@@ -1345,6 +1353,8 @@ bad_fork_cleanup_policy:
 	mpol_put(p->mempolicy);
 bad_fork_cleanup_cgroup:
 #endif
+	if (clone_flags & CLONE_THREAD)
+		threadgroup_fork_read_unlock(current);
 	cgroup_exit(p, cgroup_callbacks_done);
 	delayacct_tsk_free(p);
 	module_put(task_thread_info(p)->exec_domain->module);
