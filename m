From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][usercr]: Ghost tasks must be detached
Date: Fri, 10 Dec 2010 19:35:48 -0800
Message-ID: <20101211033548.GA12584@us.ibm.com>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Fri, 10 Dec 2010 19:23:58 -0800
Subject: [PATCH 1/1] Ghost tasks must be detached

Ghost processes are created only to help restore orphaned sessions/pgrps.
As such once the session/pgrp is created the ghost must not send another
SIGCHLD to the parent but exit silently.  So create such tasks as
"detached".

See also:

https://lists.linux-foundation.org/pipermail/containers/2010-December/026076.html

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/restart.c b/restart.c
index 9fb5e9f..d7ba26b 100644
--- a/restart.c
+++ b/restart.c
@@ -1744,6 +1744,13 @@ static pid_t ckpt_fork_child(struct ckpt_ctx *ctx, struct task *child)
 		flags |= CLONE_THREAD | CLONE_SIGHAND | CLONE_VM;
 	else if (child->flags & TASK_SIBLING)
 		flags |= CLONE_PARENT;
+	else if (child->flags & (TASK_GHOST|TASK_DEAD)) {
+		/* 
+		 * Ghosts must vanish silently (without signalling parent)
+		 * when they are done.
+		 */
+		flags = 0xFF;
+	}
 
 	memset(&clone_args, 0, sizeof(clone_args));
 	clone_args.nr_pids = 1;
-- 
1.6.0.4
