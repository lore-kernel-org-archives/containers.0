From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH][cr]: Mark ghost tasks as detached earlier
Date: Sat, 30 Oct 2010 00:01:51 -0700
Message-ID: <20101030070151.GA4850@us.ibm.com>
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
Cc: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

From ce9dd2fc7332597d46872f3f8c52ac0806f381d1 Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Fri, 29 Oct 2010 23:16:10 -0700
Subject: [PATCH 1/1] Mark ghost task as detached earlier

During restart() of an application, ghost tasks are be marked as "detached"
so they don't send a SIGCHLD to their parent when they exit. But this is
currently being done a little too late in the "life" of the ghost and
ends up confusing the container-init.

Suppose a ghost child of the container-init is waiting in do_ghost_task().
It is not yet detached. If the container-init is terminated for some
reason, the container-init sends SIGKILL to its children (including this
ghost). The container-init then waits for the un-detached children to
exit, expecting to be notified via SIGCHLD.

When the ghost-child receives the SIGKILL, it wakes up and marks itself
detached and proceeds to exit. Since it is now detached, it will not
notify the parent, thus leaving the container-init blocked indefintely.

Some background:

When running some tests on the C/R code we ran into the problem of the
container-init not waiting for detached processes. This problem was
extensively discssued here:

	http://lkml.org/lkml/2010/6/16/295

Eric Biederman had a fix for the problem:

	http://lkml.org/lkml/2010/7/12/213

When I applied this fix to the C/R tree and repeated the tests, I ran
into the above issue of the container-init hanging. Marking the ghost
as detached earlier seems to fix the confusion in the container-init.

Oren, is there a reason not to mark the ghost task detached earlier
than is currently being done ?

Signed-off-by: Sukadev Bhattiprolu (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org)
---
 kernel/checkpoint/restart.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index 17270b8..95789c0 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -953,6 +953,7 @@ static int do_ghost_task(void)
 	struct ckpt_ctx *ctx;
 	int ret;
 
+	current->exit_signal = -1;
 	ctx = wait_checkpoint_ctx();
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
@@ -972,7 +973,6 @@ static int do_ghost_task(void)
 	if (ret < 0)
 		ckpt_err(ctx, ret, "ghost restart failed\n");
 
-	current->exit_signal = -1;
 	restore_debug_exit(ctx);
 	ckpt_ctx_put(ctx);
 	do_exit(0);
-- 
1.6.6.1
