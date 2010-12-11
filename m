From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][cr]: Ghost tasks must not be detached in kernel
Date: Fri, 10 Dec 2010 19:33:15 -0800
Message-ID: <20101211033315.GA12292@us.ibm.com>
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

Oren,

As discussed (a while ago)

https://lists.linux-foundation.org/pipermail/containers/2010-November/025905.html

here is a patch. I will send a follow-on user-cr patch to mark
the task detached in user-space.

---

From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Fri, 10 Dec 2010 18:37:17 -0800
Subject: [PATCH 1/1] Ghost tasks must not be detached in kernel

Ghost tasks are "temporary" tasks created during sys_restart() to
restore "orphaned" sessions/process groups (i.e. those in which the
original session/pgrp leader had exited before checkpoint but other
processes exist in that session/pgrp).

We only create the ghost task so we have a valid session/pgrp that
the other processes in the session/pgrp can use. Once those other
processes are created, the ghost tasks must silently vanish (without
sending another SIGCHLD).

do_ghost_task() was setting the exit_signal to -1 so the ghosts don't
send a signal. But rather than set the ->exit_signal here, the caller
(i.e user-space) can create the ghost task by explicitly setting the
CSIGNAL mask to 0xFF. i.e it is not something the we need to do in the
kernel.

The downside of marking the task detached in do_ghost_task() is that
with current/older kernels container-init does not wait for detached
tasks.  See:

	http://lkml.org/lkml/2010/6/16/272
	http://lkml.org/lkml/2010/7/12/213

This can lead to a kernel crash if the container-init pre-deceases a
ghost task.

Signed-off-by: Sukadev Bhattiprolu (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org)
---
 kernel/checkpoint/restart.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/kernel/checkpoint/restart.c b/kernel/checkpoint/restart.c
index 17270b8..2bb7197 100644
--- a/kernel/checkpoint/restart.c
+++ b/kernel/checkpoint/restart.c
@@ -972,7 +972,6 @@ static int do_ghost_task(void)
 	if (ret < 0)
 		ckpt_err(ctx, ret, "ghost restart failed\n");
 
-	current->exit_signal = -1;
 	restore_debug_exit(ctx);
 	ckpt_ctx_put(ctx);
 	do_exit(0);
-- 
1.6.0.4
