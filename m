From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH user-cr] clone_x86_32: use correct 4th syscall arg
Date: Fri, 22 Jan 2010 18:35:32 -0600
Message-ID: <20100123003532.GB5285@us.ibm.com>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

The 4th arg to syscall is esi, not edi.  Wasn't too big a deal since
we yanked it out of regs->edi at process_32.c:sys_eclone(), but
it gets totally b0rked when ia32 regs fixup happens to use the
32-bit abi in x86-64.

Signed-off-by: Serge Hallyn <serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 clone_x86_32.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/clone_x86_32.c b/clone_x86_32.c
index 2d26385..54960e0 100644
--- a/clone_x86_32.c
+++ b/clone_x86_32.c
@@ -66,7 +66,7 @@ int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
 		 "b" (clone_flags_low),	/* flags -> 1st (ebx) */
 		 "c" (&my_args),	/* clone_args -> 2nd (ecx) */
 		 "d" (sizeof(my_args)),	/* args_size -> 3rd (edx) */
-		 "D" (pids)		/* pids -> 4th (edi) */
+		 "S" (pids)		/* pids -> 4th (esi) */
 		);
 
 	if (retval < 0) {
-- 
1.6.3.3
