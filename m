From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] checkpoint: use syscall_get_error
Date: Fri, 12 Mar 2010 12:26:33 -0600
Message-ID: <1268418393-18325-3-git-send-email-ntl@pobox.com>
References: <1268418393-18325-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1268418393-18325-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

restore_retval() uses the result of syscall_get_return_value() to
determine whether a syscall is to return an error.  This isn't
portable and doesn't work on powerpc.  Instead, use
syscall_get_error(), which encapsulates the arch-specific logic for
determining syscall error state.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 checkpoint/restart.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 0891952..696e4a2 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -1316,7 +1316,8 @@ static int do_restore_coord(struct ckpt_ctx *ctx, pid_t pid)
 static long restore_retval(void)
 {
 	struct pt_regs *regs = task_pt_regs(current);
-	long ret;
+	long syscall_err;
+	long syscall_nr;
 
 	/*
 	 * For the restart, we entered the kernel via sys_restart(),
@@ -1352,13 +1353,14 @@ static long restore_retval(void)
 	 */
 
 	/* needed for all 3 cases: get old value/error/retval */
-	ret = syscall_get_return_value(current, regs);
+	syscall_nr = syscall_get_nr(current, regs);
+	syscall_err = syscall_get_error(current, regs);
 
-	/* if from a syscall and returning error, kick in signal handlig */
-	if (syscall_get_nr(current, regs) >= 0 && ret < 0)
+	/* if from a syscall and returning error, kick in signal handling */
+	if (syscall_nr >= 0 && syscall_err != 0)
 		set_tsk_thread_flag(current, TIF_SIGPENDING);
 
-	return ret;
+	return syscall_get_return_value(current, regs);
 }
 
 long do_restart(struct ckpt_ctx *ctx, pid_t pid, unsigned long flags)
-- 
1.6.0.6
