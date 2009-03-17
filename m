From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 0/6] /proc/pid/checkpointable
Date: Mon, 16 Mar 2009 23:39:40 -0700
Message-ID: <20090317063940.GF2377@us.ibm.com>
References: <20090317062754.GA2377@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090317062754.GA2377-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Fri, 13 Mar 2009 17:25:42 -0700
Subject: [PATCH 5/6] Define and use proc_pid_checkpointable()

Create a proc file, /proc/pid/checkpointable, which shows '1' if
task is checkpointable and '0' if it is not.

To determine whether a task is checkpointable, the handler for this
new proc file, shares the same code with sys_checkpoint().

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 checkpoint/checkpoint.c    |   23 ++++++++++++++++-------
 fs/proc/base.c             |   13 +++++++++++++
 include/linux/checkpoint.h |    7 +++++++
 3 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index c16f30c..ad0956c 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -264,22 +264,31 @@ static int cr_write_all_tasks(struct cr_ctx *ctx)
 	return ret;
 }
 
+int task_checkpointable(struct task_struct *t)
+{
+	if (t->state == TASK_DEAD) {
+		pr_warning("c/r: task %d is TASK_DEAD\n", task_pid_vnr(t));
+		return 0;
+	}
+
+	/* Verify that task is frozen, unless it is self-checkpoint */
+	if (t != current && !frozen(t))
+		return 0;
+
+	return 1;
+}
+
 static int cr_may_checkpoint_task(struct task_struct *t, struct cr_ctx *ctx)
 {
 	pr_debug("check %d\n", task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns));
 
-	if (t->state == TASK_DEAD) {
-		pr_warning("c/r: task %d is TASK_DEAD\n", task_pid_vnr(t));
+	/* verify that the task is checkpointable */
+	if (!task_checkpointable(t))
 		return -EAGAIN;
-	}
 
 	if (!ptrace_may_access(t, PTRACE_MODE_READ))
 		return -EPERM;
 
-	/* verify that the task is frozen (unless self) */
-	if (t != current && !frozen(t))
-		return -EBUSY;
-
 	/* FIXME: change this for nested containers */
 	if (task_nsproxy(t) != ctx->root_nsproxy)
 		return -EPERM;
diff --git a/fs/proc/base.c b/fs/proc/base.c
index bde92c3..989ca93 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2501,6 +2501,13 @@ static int proc_pid_personality(struct seq_file *m, struct pid_namespace *ns,
 	return 0;
 }
 
+#ifdef CONFIG_CHECKPOINT_RESTART
+static int proc_pid_checkpointable(struct task_struct *task, char *buffer)
+{
+	return sprintf(buffer, "%d\n", task_checkpointable(task));
+}
+#endif
+
 /*
  * Thread groups
  */
@@ -2580,6 +2587,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_TASK_IO_ACCOUNTING
 	INF("io",	S_IRUGO, proc_tgid_io_accounting),
 #endif
+#ifdef CONFIG_CHECKPOINT_RESTART
+	INF("checkpointable", S_IRUGO, proc_pid_checkpointable),
+#endif
 };
 
 static int proc_tgid_base_readdir(struct file * filp,
@@ -2915,6 +2925,9 @@ static const struct pid_entry tid_base_stuff[] = {
 #ifdef CONFIG_TASK_IO_ACCOUNTING
 	INF("io",	S_IRUGO, proc_tid_io_accounting),
 #endif
+#ifdef CONFIG_CHECKPOINT_RESTART
+	INF("checkpointable", S_IRUGO, proc_pid_checkpointable),
+#endif
 };
 
 static int proc_tid_base_readdir(struct file * filp,
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 484be56..d1f53a6 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -142,6 +142,8 @@ static inline int cr_enabled(void)
 	return 1;
 }
 
+int task_checkpointable(struct task_struct *t);
+
 #else /* !CONFIG_CHECKPOINT_RESTART */
 
 static inline void files_deny_checkpointing(struct files_struct *files) {}
@@ -162,5 +164,10 @@ static inline int cr_enabled(void)
 	return 0;
 }
 
+static inline int task_checkpointable(struct task_struct *t)
+{
+	return 0;
+}
+
 #endif /* CONFIG_CHECKPOINT_RESTART */
 #endif /* _CHECKPOINT_CKPT_H_ */
-- 
1.5.2.5
