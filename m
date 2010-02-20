From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] c/r: Fix x86-32 build without CONFIG_CHECKPOINT
Date: Fri, 19 Feb 2010 16:31:17 -0800
Message-ID: <fca30ee3fcd63dc97a9c7a9a4a7b878ab256d7e7.1266625869.git.matthltc@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

When building for x86-32 the ptregs_checkpoint and ptregs_restart
definitions are missing because they're surrounded by

	arch/x86/built-in.o: In function `sys_call_table':
	(.rodata+0x58c): undefined reference to `ptregs_checkpoint'
	arch/x86/built-in.o: In function `sys_call_table':
	(.rodata+0x590): undefined reference to `ptregs_restart'

The solution is to map these to sys_checkpoint from kernel/sys_ni.c
when CONFIG_CHECKPOINT is not defined.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/kernel/entry_32.S |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kernel/entry_32.S b/arch/x86/kernel/entry_32.S
index af8c81b..07f1d2d 100644
--- a/arch/x86/kernel/entry_32.S
+++ b/arch/x86/kernel/entry_32.S
@@ -784,6 +784,10 @@ PTREGSCALL4(eclone)
 #ifdef CONFIG_CHECKPOINT
 PTREGSCALL4(checkpoint)
 PTREGSCALL4(restart)
+#else
+/* Use the weak defs in kernel/sys_ni.c */
+#define ptregs_checkpoint sys_checkpoint
+#define ptregs_restart sys_restart
 #endif
 
 /* Clone is an oddball.  The 4th arg is in %edi */
-- 
1.6.3.3
