From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/5] c/r: let entire thread group in sys_restart before
	restoring a thread
Date: Wed, 30 Sep 2009 21:47:11 -0400
Message-ID: <1254361634-30076-3-git-send-email-orenl@librato.com>
References: <1254361634-30076-1-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1254361634-30076-1-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Ensure that all members of a thread group are in sys_restart before
restoring any of them. Otherwise, restore may modify shared state and
crash or fault a thread still in userspace,

For thread groups, each thread scans the entire group and tests for
PF_RESTARTING on every member. If not all are set, then we wait, and
when woken up try again (unless signaled). If all are set, then we're
done and wakeup all threads.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/restart.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 5d936cf..37454c5 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -695,6 +695,54 @@ static int do_ghost_task(void)
 	/* NOT REACHED */
 }
 
+/*
+ * Ensure that all members of a thread group are in sys_restart before
+ * restoring any of them. Otherwise, restore may modify shared state
+ * and crash or fault a thread still in userspace,
+ */
+static int wait_sync_threads(void)
+{
+	struct task_struct *p, *leader;
+
+	if (thread_group_empty(current))
+		return 0;
+
+	p = leader = current->group_leader;
+
+	/*
+	 * Our PF_RESTARTING is already set. Each thread loops through
+	 * the group testing everyone's PF_RESTARTING. If not set on
+	 * all members, it sleeps to retry later. Otherwise it wakes
+	 * up all sleepers and returns.
+	 */
+ retry:
+	__set_current_state(TASK_INTERRUPTIBLE);
+
+	read_lock(&tasklist_lock);
+	do {
+		if (!(p->flags & PF_RESTARTING))
+			break;
+		p = next_thread(p);
+	} while (p != leader);
+
+	if (p != leader) {
+		read_unlock(&tasklist_lock);
+		if (signal_pending(current))
+			return -EINTR;
+		schedule();
+		goto retry;
+	}
+
+	do {
+		wake_up_process(p);
+		p = next_thread(p);
+	} while (p != leader);
+	read_unlock(&tasklist_lock);
+
+	__set_current_state(TASK_RUNNING);
+	return 0;
+}
+
 static int do_restore_task(void)
 {
 	struct ckpt_ctx *ctx;
@@ -706,6 +754,10 @@ static int do_restore_task(void)
 
 	current->flags |= PF_RESTARTING;
 
+	ret = wait_sync_threads();
+	if (ret < 0)
+		return ret;
+
 	/* wait for our turn, do the restore, and tell next task in line */
 	ret = wait_task_active(ctx);
 	if (ret < 0)
-- 
1.6.0.4
