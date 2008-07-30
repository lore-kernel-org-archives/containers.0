From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC][PATCH 1/2] CR: introduce sys_checkpoint and sys_restore
Date: Tue, 29 Jul 2008 23:25:25 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0807292324450.9868@takamine.ncl.cs.columbia.edu>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Create trivial sys_checkpoint and sys_restore system calls. They will
enable to checkpoint and restart an entire container, to and from a
checkpoint image file.

First create a template for both syscalls: they take a file descriptor
(for the image file) and flags as arguments. For sys_checkpoint the
first argument identifies the target container; for sys_restart it will
identify the checkpoint image.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

---
  Makefile                           |    2 +-
  arch/x86/kernel/syscall_table_32.S |    2 ++
  include/asm-x86/unistd_32.h        |    2 ++
  3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/Makefile b/Makefile
index 4bcd1cf..6e2334c 100644
--- a/Makefile
+++ b/Makefile
@@ -611,7 +611,7 @@ export mod_strip_cmd


  ifeq ($(KBUILD_EXTMOD),)
-core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/
+core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/ ckpt/

  vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y) $(init-m) \
  		     $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index d44395f..5543136 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -332,3 +332,5 @@ ENTRY(sys_call_table)
  	.long sys_dup3			/* 330 */
  	.long sys_pipe2
  	.long sys_inotify_init1
+	.long sys_checkpoint
+	.long sys_restart
diff --git a/include/asm-x86/unistd_32.h b/include/asm-x86/unistd_32.h
index d739467..88bdec4 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -338,6 +338,8 @@
  #define __NR_dup3		330
  #define __NR_pipe2		331
  #define __NR_inotify_init1	332
+#define __NR_checkpoint		333
+#define __NR_restart		334

  #ifdef __KERNEL__

-- 
1.5.4.3
