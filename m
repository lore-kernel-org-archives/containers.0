From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 6/6] Explain reason for task being uncheckpointable
Date: Tue, 17 Mar 2009 10:51:49 -0700
Message-ID: <20090317175149.GG10796@us.ibm.com>
References: <20090317174359.GA10796@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090317174359.GA10796-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Sat, 14 Mar 2009 10:21:07 -0700
Subject: [PATCH 6/6] Explain reason for task being uncheckpointable

Try to give an useful message on why a task is uncheckpointable.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 checkpoint/checkpoint.c    |   13 +++++++++----
 fs/proc/base.c             |   19 ++++++++++++++++++-
 include/linux/checkpoint.h |    7 +++++++
 3 files changed, 34 insertions(+), 5 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index ad0956c..c8c377d 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -264,18 +264,23 @@ static int cr_write_all_tasks(struct cr_ctx *ctx)
 	return ret;
 }
 
-int task_checkpointable(struct task_struct *t)
+int __task_checkpointable(struct task_struct *t)
 {
 	if (t->state == TASK_DEAD) {
 		pr_warning("c/r: task %d is TASK_DEAD\n", task_pid_vnr(t));
-		return 0;
+		return CR_DEAD;
 	}
 
 	/* Verify that task is frozen, unless it is self-checkpoint */
 	if (t != current && !frozen(t))
-		return 0;
+		return CR_NOT_FROZEN;
+
+	return CR_CHECKPOINTABLE;
+}
 
-	return 1;
+int task_checkpointable(struct task_struct *t)
+{
+	return __task_checkpointable(t) == CR_CHECKPOINTABLE;
 }
 
 static int cr_may_checkpoint_task(struct task_struct *t, struct cr_ctx *ctx)
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 989ca93..6e4c07c 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2502,9 +2502,26 @@ static int proc_pid_personality(struct seq_file *m, struct pid_namespace *ns,
 }
 
 #ifdef CONFIG_CHECKPOINT_RESTART
+static char *explain_checkpointable(int reason)
+{
+	char *message;
+
+	switch(reason) {
+	case CR_CHECKPOINTABLE: message = "1"; break;
+	case CR_DEAD: 		message = "0 (dead)"; break;
+	case CR_NOT_FROZEN: 	message = "0 (not frozen)"; break;
+	default:		message = "0 (unknown)"; break;
+	}
+	return message;
+}
+
 static int proc_pid_checkpointable(struct task_struct *task, char *buffer)
 {
-	return sprintf(buffer, "%d\n", task_checkpointable(task));
+	int rc;
+
+	rc = __task_checkpointable(task);
+
+	return scnprintf(buffer, PAGE_SIZE, "%s\n", explain_checkpointable(rc));
 }
 #endif
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index d1f53a6..a1eba73 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -142,6 +142,13 @@ static inline int cr_enabled(void)
 	return 1;
 }
 
+enum cr_uncheckpointable_reason {
+	CR_CHECKPOINTABLE = 0,
+	CR_DEAD,
+	CR_NOT_FROZEN
+};
+
+int __task_checkpointable(struct task_struct *t);
 int task_checkpointable(struct task_struct *t);
 
 #else /* !CONFIG_CHECKPOINT_RESTART */
-- 
1.5.2.5
