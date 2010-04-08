From: Leonid Snegirev <leo-n4oKp6kCDthKyFCjRbgQbg@public.gmane.org>
Subject: [PATCH] c/r: restore tty pgrp properly
Date: Thu, 08 Apr 2010 15:50:56 +0000
Message-ID: <4BBDFB60.2080505@lvk.cs.msu.su>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: "Nikita V. Youshchenko" <yoush-/llMDZXAvAOHXe+LvDLADg@public.gmane.org>
List-Id: containers.vger.kernel.org

When restoring without keeping old PIDs, it is incorrect to set tty pgrp
to same numeric value as it was at checkpoint time. This pgrp may not
exist at restore time, and do_tiocspgrp() call from restore_signal()
returns -ESRCH.

This patch tries to solve this by searching process with pgid equal to 
tty->pgrp
at checkpoint time, save index of that process in checkpoint, and at use 
restore-time
pgid of that process to set tty->pgrp at restore.

Signed-off-by: Leonid Snegirev <leo-n4oKp6kCDthKyFCjRbgQbg@public.gmane.org>
---
 checkpoint/signal.c            |   16 +++++++++++++---
 include/linux/checkpoint_hdr.h |    2 +-
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index 9d0e9c3..9c90e96 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -323,6 +323,7 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, 
struct task_struct *t)
     cputime_t cputime;
     unsigned long flags;
     int i, ret = 0;
+    pid_t tty_pgrp, prgp_i;
 
     h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
     if (!h)
@@ -411,7 +412,16 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, 
struct task_struct *t)
         if (tty) {
             /* irq is already disabled */
             spin_lock(&tty->ctrl_lock);
-            h->tty_pgrp = ckpt_pid_nr(ctx, tty->pgrp);
+            h->tty_pgrp_owner = -1;
+            tty_pgrp = ckpt_pid_nr(ctx, tty->pgrp);
+            for (i = 0; i < ctx->nr_tasks; i++) {
+                pgrp_i = task_pgrp_nr_ns(ctx->tasks_arr[i],
+                        ctx->root_nsproxy->pid_ns);
+                if (tty_pgrp == pgrp_i) {
+                    h->tty_pgrp_owner = i;
+                    break;
+                }
+            }    
             spin_unlock(&tty->ctrl_lock);
             tty_kref_put(tty);
         }
@@ -537,13 +547,13 @@ static int restore_signal(struct ckpt_ctx *ctx)
         if (ret < 0)
             goto out;
         /* now restore the foreground group (job control) */
-        if (h->tty_pgrp) {
+        if (h->tty_pgrp_owner != -1) {
             /*
              * If tty_pgrp == CKPT_PID_NULL, below will
              * fail, so no need for explicit test
              */
             ret = do_tiocspgrp(tty, tty_pair_get_tty(tty),
-                       h->tty_pgrp);
+                    ctx->pids_arr[h->tty_pgrp_owner].vpgid);
             if (ret < 0)
                 goto out;
         }
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 41412d1..535e138 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -898,7 +898,7 @@ struct ckpt_hdr_signal {
     __u64 it_prof_incr;
     /* tty */
     __s32 tty_objref;
-    __s32 tty_pgrp;
+    __u32 tty_pgrp_owner;
     __s32 tty_old_pgrp;
 } __attribute__((aligned(8)));
 
-- 
1.5.6.5
