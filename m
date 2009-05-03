From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] x86_64: ifdef out struct thread_struct::ip
Date: Mon, 4 May 2009 03:30:15 +0400
Message-ID: <20090503233015.GJ16631__36188.3217622109$1241393436$gmane$org@x200.localdomain>
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
To: mingo-X9Un+BFzKDI@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

struct thread_struct::ip isn't used on x86_64, struct pt_regs::ip is used
instead.

kgdb should be reading 0 always, but I can't check it.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 arch/x86/include/asm/processor.h |    2 ++
 arch/x86/kernel/kgdb.c           |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index a6732ff..a9ba743 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -427,7 +427,9 @@ struct thread_struct {
 	unsigned short		fsindex;
 	unsigned short		gsindex;
 #endif
+#ifdef CONFIG_X86_32
 	unsigned long		ip;
+#endif
 #ifdef CONFIG_X86_64
 	unsigned long		fs;
 #endif
diff --git a/arch/x86/kernel/kgdb.c b/arch/x86/kernel/kgdb.c
index eedfaeb..d07706f 100644
--- a/arch/x86/kernel/kgdb.c
+++ b/arch/x86/kernel/kgdb.c
@@ -141,7 +141,7 @@ void sleeping_thread_to_gdb_regs(unsigned long *gdb_regs, struct task_struct *p)
 	gdb_regs32[GDB_PS]	= *(unsigned long *)(p->thread.sp + 8);
 	gdb_regs32[GDB_CS]	= __KERNEL_CS;
 	gdb_regs32[GDB_SS]	= __KERNEL_DS;
-	gdb_regs[GDB_PC]	= p->thread.ip;
+	gdb_regs[GDB_PC]	= 0;
 	gdb_regs[GDB_R8]	= 0;
 	gdb_regs[GDB_R9]	= 0;
 	gdb_regs[GDB_R10]	= 0;
