From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 01/10] Introduce trivial sys_checkpoint and sys_restore system
	calls
Date: Sat, 18 Oct 2008 03:11:29 +0400
Message-ID: <1224285098-573-2-git-send-email-major__27954.2388314896$1224285260$gmane$org@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1224285098-573-1-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Right now they just return -ENOSYS. Later they will provide functionality
to checkpoint and restart a container.

Both syscalls take as arguments a file descriptor and flags.
Also sys_checkpoint take as the first argument a PID of container's init
(later it will be container ID); sys_restart takes as the first argument
a container ID (right now it will not be used).

Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 Makefile                           |    2 +-
 arch/x86/kernel/syscall_table_32.S |    2 +
 checkpoint/Makefile                |    1 +
 checkpoint/sys_core.c              |   38 ++++++++++++++++++++++++++++++++++++
 include/asm-x86/unistd_32.h        |    2 +
 5 files changed, 44 insertions(+), 1 deletions(-)
 create mode 100644 checkpoint/Makefile
 create mode 100644 checkpoint/sys_core.c

diff --git a/Makefile b/Makefile
index ea413fa..ce49afd 100644
--- a/Makefile
+++ b/Makefile
@@ -619,7 +619,7 @@ export mod_strip_cmd
 
 
 ifeq ($(KBUILD_EXTMOD),)
-core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/
+core-y		+= kernel/ mm/ fs/ ipc/ security/ crypto/ block/ checkpoint/
 
 vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(init-y) $(init-m) \
 		     $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index fd9d4f4..4a0d7fb 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -333,3 +333,5 @@ ENTRY(sys_call_table)
 	.long sys_pipe2
 	.long sys_inotify_init1
 	.long sys_hijack
+	.long sys_checkpoint
+	.long sys_restart		/* 335 */
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
new file mode 100644
index 0000000..2276fb1
--- /dev/null
+++ b/checkpoint/Makefile
@@ -0,0 +1 @@
+obj-y += sys_core.o
diff --git a/checkpoint/sys_core.c b/checkpoint/sys_core.c
new file mode 100644
index 0000000..1a97fb6
--- /dev/null
+++ b/checkpoint/sys_core.c
@@ -0,0 +1,38 @@
+/*
+ *  Copyright (C) 2008 Parallels, Inc.
+ *
+ *  Author: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License as
+ *  published by the Free Software Foundation, version 2 of the
+ *  License.
+ *
+ */
+
+#include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+
+/**
+ * sys_checkpoint - checkpoint a container from outside
+ * @pid: pid of the container init(1) process
+ * TODO: should switch to container id later
+ * @fd: file to which save the checkpoint image
+ * @flags: checkpoint operation flags
+ */
+asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
+{
+	return -ENOSYS;
+}
+
+/**
+ * sys_restart - restart a container
+ * @ctid: container id which should be used to restart a container
+ * @fd: file from which read the checkpoint image
+ * @flags: restart operation flags
+ */
+asmlinkage long sys_restart(int ctid, int fd, unsigned long flags)
+{
+	return -ENOSYS;
+}
diff --git a/include/asm-x86/unistd_32.h b/include/asm-x86/unistd_32.h
index 70280da..1a09604 100644
--- a/include/asm-x86/unistd_32.h
+++ b/include/asm-x86/unistd_32.h
@@ -339,6 +339,8 @@
 #define __NR_pipe2		331
 #define __NR_inotify_init1	332
 #define __NR_hijack		333
+#define __NR_checkpoint		334
+#define __NR_restart		335
 
 #ifdef __KERNEL__
 
-- 
1.5.6
