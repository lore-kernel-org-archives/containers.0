From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 6/6] Explain reason for task being uncheckpointable
Date: Tue, 17 Mar 2009 23:50:32 -0700
Message-ID: <20090318065032.GA21055@us.ibm.com>
References: <20090317174359.GA10796@us.ibm.com>
	<20090317175149.GG10796@us.ibm.com>
	<20090317185228.GC1039@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090317185228.GC1039-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
| >  #ifdef CONFIG_CHECKPOINT_RESTART
| > +static char *explain_checkpointable(int reason)
| > +{
| > +	char *message;
| > +
| > +	switch(reason) {
| > +	case CR_CHECKPOINTABLE: message = "1"; break;
| > +	case CR_DEAD: 		message = "0 (dead)"; break;
| > +	case CR_NOT_FROZEN: 	message = "0 (not frozen)"; break;
| > +	default:		message = "0 (unknown)"; break;
| 
| I don't think splitting it up this way is going to work long-term.
| It means you need one code for each type of message, and can't give
| any more detail beyond that (i.e. the value of
| current->nsproxy->uts_ns.refcount, or whatever).
| 
| I think it would be better to pass a buffer into __task_checkpointable,
| and let task_checkpointable() pass in a NULL buffer meaning "I
| (sys_checkpoint) don't care about the explanation".

Ok. I had tried it before, but was not happy about __task_checkpointable()
filling in a message buffer,  but I see your point. Here is an updated patch.

---

From 73dd3ec01320d62881cb5296aa4d68667571ef4c Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 17 Mar 2009 16:15:16 -0700
Subject: [PATCH 6/6] Explain reason for task being uncheckpointable

Try to give an useful message on why a task is uncheckpointable.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 checkpoint/checkpoint.c    |   16 ++++++++++++++--
 fs/proc/base.c             |    4 +++-
 include/linux/checkpoint.h |    1 +
 3 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index ad0956c..b4dbb22 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -264,19 +264,31 @@ static int cr_write_all_tasks(struct cr_ctx *ctx)
 	return ret;
 }
 
-int task_checkpointable(struct task_struct *t)
+int __task_checkpointable(struct task_struct *t, char *msg_buf, int len)
 {
 	if (t->state == TASK_DEAD) {
+		if (msg_buf)
+			scnprintf(msg_buf, len, "0 (task dead)\n");
 		pr_warning("c/r: task %d is TASK_DEAD\n", task_pid_vnr(t));
 		return 0;
 	}
 
 	/* Verify that task is frozen, unless it is self-checkpoint */
-	if (t != current && !frozen(t))
+	if (t != current && !frozen(t)) {
+		if (msg_buf)
+			scnprintf(msg_buf, len, "0 (task not frozen)\n");
 		return 0;
+	}
+
+	if (msg_buf)
+		scnprintf(msg_buf, len, "1\n");
 
 	return 1;
 }
+int task_checkpointable(struct task_struct *t)
+{
+	return __task_checkpointable(t, NULL, 0);
+}
 
 static int cr_may_checkpoint_task(struct task_struct *t, struct cr_ctx *ctx)
 {
diff --git a/fs/proc/base.c b/fs/proc/base.c
index 989ca93..2d054b7 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -2504,7 +2504,9 @@ static int proc_pid_personality(struct seq_file *m, struct pid_namespace *ns,
 #ifdef CONFIG_CHECKPOINT_RESTART
 static int proc_pid_checkpointable(struct task_struct *task, char *buffer)
 {
-	return sprintf(buffer, "%d\n", task_checkpointable(task));
+	__task_checkpointable(task, buffer, PAGE_SIZE);
+
+	return strlen(buffer);
 }
 #endif
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index d1f53a6..44adb0b 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -142,6 +142,7 @@ static inline int cr_enabled(void)
 	return 1;
 }
 
+int __task_checkpointable(struct task_struct *t, char *msg_buf, int len);
 int task_checkpointable(struct task_struct *t);
 
 #else /* !CONFIG_CHECKPOINT_RESTART */
-- 
1.5.2.5
