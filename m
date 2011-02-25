From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][cr]: Fix ghost task bug
Date: Thu, 24 Feb 2011 23:55:52 -0800
Message-ID: <20110225075552.GB24361@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From b32a8c440687955975180e909620eba50cb146c3 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 22 Feb 2011 10:44:55 -0800
Subject: [PATCH 1/1] Fix ghost task bug

Ghost tasks used to be marked as "detached" in do_ghost_task() but
this resulted in a crash which was fixed as discussed in:
https://lists.linux-foundation.org/pipermail/containers/2010-December/026076.html.

But that fix incorrectly attempted to mark a task as detached from user
space. It is not possible to "detach" a task from user space, which
means we must detach the thread in the kernel while still avoiding
the above crash.

The original crash occured because the container-init did not wait for
the detached children. When the detached children exited, they would
access a freed proc_mnt. Eric Biederman fixed this crash as discussed in
the above link.

While Eric's patch fixed the crash it could still leave the container
init hanging indefinitely due to the following race:

container-int:				ghost task
-----------------                      ------------
					do_ghost_task()

zap_pid_ns_processes()
- send SIGKILL
- do_wait()
   - at least one child exists
   - so wait for child to exit
   					wake up for the SIGKILL
					set ->exit_signal = -1
					exit without notifying parent

This leaves the container init waiting indefinitely.

To fix this hang, we have the children of container-init issue an extra wake
up call in exit_checkpoint(). Note that in exit_checkpoint() we do not know
if it is the ghost task that is exiting. Since this wake up applies to any
other task, we should further make sure that the parent is itself not exiting
(which could cause __wake_up_parent() to access invalid pointers in the
parent's task structure).

See this thread for more discussion:

https://lists.linux-foundation.org/pipermail/containers/2011-February/026459.html

Signed-off-by: Sukadev Bhattiprolu (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org)
Cc: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
---
 kernel/checkpoint/restart.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index b0ea8ec..8ecc052 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -972,6 +972,7 @@ static int do_ghost_task(void)
 	if (ret < 0)
 		ckpt_err(ctx, ret, "ghost restart failed\n");
 
+	current->exit_signal = -1;
 	restore_debug_exit(ctx);
 	ckpt_ctx_put(ctx);
 	do_exit(0);
@@ -1465,7 +1466,22 @@ void exit_checkpoint(struct task_struct *tsk)
 	/* restarting zombies will activate next task in restart */
 	if (tsk->flags & PF_RESTARTING) {
 		BUG_ON(ctx->active_pid == -1);
+
+		/*
+		 * if we are a "ghost" task, that was terminated by the
+		 * container-init (from zap_pid_ns_processes()), we should
+		 * wake up the parent since we are now a detached process.
+		 */
+		read_lock_irq(&tasklist_lock);
+                if (tsk->exit_state == EXIT_DEAD && !tsk->parent->exit_state) {
+                        ckpt_debug("[%d, %s]: exit_checkpoint(): notifying "
+					"parent\n", tsk->pid, tsk->comm);
+                        __wake_up_parent(tsk, tsk->parent);
+                }
+		read_unlock_irq(&tasklist_lock);
+
 		restore_task_done(ctx);
+
 	}
 
 	ckpt_ctx_put(ctx);
-- 
1.6.6.1
