From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/5] Track in-kernel when we expect checkpoint/restart to work
Date: Wed, 11 Mar 2009 21:25:03 -0700
Message-ID: <20090312042503.GA8703@us.ibm.com>
References: <20090312042416.GC7733@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090312042416.GC7733-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/5] Track in-kernel when we expect checkpoint/restart to work

Suggested by Ingo.

Checkpoint/restart is going to be a long effort to get things working.
We're going to have a lot of things that we know just don't work for
a long time.  That doesn't mean that it will be useless, it just means
that there's some complicated features that we are going to have to
work incrementally to fix.

This patch introduces a new mechanism to help the checkpoint/restart
developers.  A new function pair: task/process_deny_checkpoint() is
created.  When called, these tell the kernel that we *know* that the
process has performed some activity that will keep it from being
properly checkpointed.

The 'flag' is an atomic_t for now so that we can have some level
of atomicity and make sure to only warn once.

For now, this is a one-way trip.  Once a process is no longer
'may_checkpoint' capable, neither it nor its children ever will be.
This can, of course, be fixed up in the future.  We might want to
reset the flag when a new pid namespace is created, for instance.

Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c    |    6 ++++++
 include/linux/checkpoint.h |   28 +++++++++++++++++++++++++++-
 include/linux/sched.h      |    3 +++
 kernel/fork.c              |   10 ++++++++++
 4 files changed, 46 insertions(+), 1 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index e0af8a2..35e3c6b 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -233,6 +233,12 @@ static int cr_write_task(struct cr_ctx *ctx, struct task_struct *t)
 		return -EAGAIN;
 	}
 
+	if (!atomic_read(&t->may_checkpoint)) {
+		pr_warning("c/r: task %d may not checkpoint\n",
+			   task_pid_vnr(t));
+		return -EBUSY;
+	}
+
 	ret = cr_write_task_struct(ctx, t);
 	pr_debug("task_struct: ret %d\n", ret);
 	if (ret < 0)
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index e77393f..e0aa60a 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -10,9 +10,10 @@
  *  distribution for more details.
  */
 
-#include <linux/path.h>
 #include <linux/fs.h>
 #include <linux/fdtable.h>
+#include <linux/path.h>
+#include <linux/sched.h>
 
 #ifdef CONFIG_CHECKPOINT_RESTART
 
@@ -109,9 +110,23 @@ static inline void __files_deny_checkpointing(struct files_struct *files,
 		return;
 	printk(KERN_INFO "process performed an action that can not be "
 			"checkpointed at: %s:%d\n", file, line);
+	WARN_ON(1);
+}
+
+static inline void __task_deny_checkpointing(struct task_struct *task,
+		char *file, int line)
+{
+	if (!atomic_dec_and_test(&task->may_checkpoint))
+		return;
+
+	printk(KERN_INFO "process performed an action that can not be "
+			"checkpointed at: %s:%d\n", file, line);
+	WARN_ON(1);
 }
 #define files_deny_checkpointing(f)  \
 	__files_deny_checkpointing(f, __FILE__, __LINE__)
+#define process_deny_checkpointing(p)  \
+	__task_deny_checkpointing(p, __FILE__, __LINE__)
 
 int cr_explain_file(struct file *file, char *explain, int left);
 int cr_file_supported(struct file *file);
@@ -120,6 +135,15 @@ static inline int cr_enabled(void)
 	return 1;
 }
 
+/*
+ * For now, we're not going to have a distinction between
+ * tasks and processes for the purpose of c/r.  But, allow
+ * these two calls anyway to make new users at least think
+ * about it.
+ */
+#define task_deny_checkpointing(p)  \
+	__task_deny_checkpointing(p, __FILE__, __LINE__)
+
 #else /* !CONFIG_CHECKPOINT_RESTART */
 
 static inline void files_deny_checkpointing(struct files_struct *files) {}
@@ -127,6 +151,8 @@ static inline int cr_explain_file(struct file *file, char *explain, int left)
 {
 	return 0;
 }
+static inline void task_deny_checkpointing(struct task_struct *task) {}
+static inline void process_deny_checkpointing(struct task_struct *task) {}
 
 static inline int cr_file_supported(struct file *file)
 {
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 8c216e0..050b25c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1416,6 +1416,9 @@ struct task_struct {
 #ifdef CONFIG_TRACING
 	/* state flags for use by tracers */
 	unsigned long trace;
+#endif 
+#ifdef CONFIG_CHECKPOINT_RESTART
+	atomic_t may_checkpoint;
 #endif
 };
 
diff --git a/kernel/fork.c b/kernel/fork.c
index a66fbde..29c5a28 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -199,6 +199,13 @@ void __init fork_init(unsigned long mempages)
 	init_task.signal->rlim[RLIMIT_NPROC].rlim_max = max_threads/2;
 	init_task.signal->rlim[RLIMIT_SIGPENDING] =
 		init_task.signal->rlim[RLIMIT_NPROC];
+
+#ifdef CONFIG_CHECKPOINT_RESTART
+	/*
+	 * This probably won't stay set for long...
+	 */
+	atomic_set(&init_task.may_checkpoint, 1);
+#endif
 }
 
 int __attribute__((weak)) arch_dup_task_struct(struct task_struct *dst,
@@ -249,6 +256,9 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
 	tsk->btrace_seq = 0;
 #endif
 	tsk->splice_pipe = NULL;
+#ifdef CONFIG_CHECKPOINT_RESTART
+	atomic_set(&tsk->may_checkpoint, atomic_read(&orig->may_checkpoint));
+#endif
 	return tsk;
 
 out:
-- 
1.5.2.5
