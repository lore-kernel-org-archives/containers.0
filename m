From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] user-cr: make powerpc eclone stack setup more robust
Date: Fri,  5 Feb 2010 15:00:01 -0600
Message-ID: <1265403602-1083-1-git-send-email-ntl@pobox.com>
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
List-Id: containers.vger.kernel.org

For ppc64, it's not sufficient to merely align the stack pointer
(clone_args->child_stack); we must also set up a stack frame (48
bytes).  Encapsulate the stack setup details in a helper function
(stack_setup_frame) which makes appropriate adjustments.

Although the genstack implementation provides zeroed stack pages, it's
best not to rely on that implementation detail, so explicitly zero the
back chain pointer in stack_setup_frame as well.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 clone_ppc.c |   26 ++++++++++++++++++--------
 1 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/clone_ppc.c b/clone_ppc.c
index f047a9e..2d8b0f8 100644
--- a/clone_ppc.c
+++ b/clone_ppc.c
@@ -31,6 +31,22 @@ extern int __eclone(int (*fn)(void *arg),
 		    size_t args_size,
 		    pid_t *pids);
 
+#ifdef __powerpc64__
+#define MIN_STACK_FRAME 48
+#else
+#define MIN_STACK_FRAME 16
+#endif
+
+static unsigned long stack_setup_frame(unsigned long base, unsigned long size)
+{
+	unsigned long *sp;
+
+	sp =  (unsigned long *)(((base + size - 1) & ~0xf) - MIN_STACK_FRAME);
+	*sp = 0;
+
+	return (unsigned long)sp;
+}
+
 int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
 	   struct clone_args *clone_args, pid_t *pids)
 {
@@ -38,15 +54,9 @@ int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
 	unsigned long child_sp;
 	int newpid;
 
-	/* The stack pointer for the child is communicated to the
-	 * kernel via clone_args.child_stack, and to the __eclone
-	 * assembly wrapper via the child_sp argument [r4].  So we
-	 * need to align child_sp here and ensure that the wrapper and
-	 * the kernel receive the same value.
-	 */
 	if (clone_args->child_stack)
-		child_sp = (clone_args->child_stack +
-			    clone_args->child_stack_size - 1) & ~0xf;
+		child_sp = stack_setup_frame(clone_args->child_stack,
+					     clone_args->child_stack_size);
 	else
 		child_sp = 0;
 
-- 
1.6.0.6
