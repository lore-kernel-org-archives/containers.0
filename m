From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC v2][PATCH 5/9] Create trivial sys_checkpoint and sys_restore
	system calls
Date: Wed, 20 Aug 2008 12:26:03 -0700
Message-ID: <20080820192603.AE9E8048@nimitz>
References: <20080820192557.98788FAB@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080820192557.98788FAB@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

Create trivial sys_checkpoint and sys_restore system calls. They will
enable to checkpoint and restart an entire container, to and from a
checkpoint image file.

First create a template for both syscalls: they take a file descriptor
(for the image file) and flags as arguments. For sys_checkpoint the
first argument identifies the target container; for sys_restart it will
identify the checkpoint image.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---

 oren-cr.git-dave/arch/x86/kernel/syscall_table_32.S |    2 ++
 oren-cr.git-dave/include/asm-x86/unistd_32.h        |    2 ++
 oren-cr.git-dave/include/linux/syscalls.h           |    3 +++
 3 files changed, 7 insertions(+)

diff -puN arch/x86/kernel/syscall_table_32.S~0006-Create-trivial-sys_checkpoint-and-sys_restore-system arch/x86/kernel/syscall_table_32.S
--- oren-cr.git/arch/x86/kernel/syscall_table_32.S~0006-Create-trivial-sys_checkpoint-and-sys_restore-system	2008-08-20 12:12:50.000000000 -0700
+++ oren-cr.git-dave/arch/x86/kernel/syscall_table_32.S	2008-08-20 12:12:50.000000000 -0700
@@ -332,3 +332,5 @@ ENTRY(sys_call_table)
 	.long sys_dup3			/* 330 */
 	.long sys_pipe2
 	.long sys_inotify_init1
+ 	.long sys_checkpoint
+ 	.long sys_restart
diff -puN include/asm-x86/unistd_32.h~0006-Create-trivial-sys_checkpoint-and-sys_restore-system include/asm-x86/unistd_32.h
--- oren-cr.git/include/asm-x86/unistd_32.h~0006-Create-trivial-sys_checkpoint-and-sys_restore-system	2008-08-20 12:12:50.000000000 -0700
+++ oren-cr.git-dave/include/asm-x86/unistd_32.h	2008-08-20 12:12:50.000000000 -0700
@@ -338,6 +338,8 @@
 #define __NR_dup3		330
 #define __NR_pipe2		331
 #define __NR_inotify_init1	332
+#define __NR_checkpoint		333
+#define __NR_restart		334
 
 #ifdef __KERNEL__
 
diff -puN include/linux/syscalls.h~0006-Create-trivial-sys_checkpoint-and-sys_restore-system include/linux/syscalls.h
--- oren-cr.git/include/linux/syscalls.h~0006-Create-trivial-sys_checkpoint-and-sys_restore-system	2008-08-20 12:12:50.000000000 -0700
+++ oren-cr.git-dave/include/linux/syscalls.h	2008-08-20 12:12:50.000000000 -0700
@@ -625,4 +625,7 @@ asmlinkage long sys_fallocate(int fd, in
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
+asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags);
+asmlinkage long sys_restart(int crid, int fd, unsigned long flags);
+
 #endif
_
