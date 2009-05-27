From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v16][PATCH 03/43] c/r: create syscalls: sys_checkpoint,
	sys_restart
Date: Wed, 27 May 2009 13:32:29 -0400
Message-ID: <1243445589-32388-4-git-send-email-orenl__10991.0323437818$1243449119$gmane$org@cs.columbia.edu>
References: <1243445589-32388-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1243445589-32388-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Create trivial sys_checkpoint and sys_restore system calls. They will
enable to checkpoint and restart an entire container, to and from a
checkpoint image file descriptor.

The syscalls take a pid, a file descriptor (for the image file) and
flags as arguments. The pid identifies the top-most (root) task in the
process tree, e.g. the container init: for sys_checkpoint the first
argument identifies the pid of the target container/subtree; for
sys_restart it will identify the pid of restarting root task.

A checkpoint, much like a process coredump, dumps the state of multiple
processes at once, including the state of the container. The checkpoint
image is written to (and read from) the file descriptor directly from
the kernel. This way the data is generated and then pushed out naturally
as resources and tasks are scanned to save their state. This is the
approach taken by, e.g., Zap and OpenVZ.

By using a return value and not a file descriptor, we can distinguish
between a return from checkpoint, a return from restart (in case of a
checkpoint that includes self, i.e. a task checkpointing its own
container, or itself), and an error condition, in a manner analogous
to a fork() call.

We don't use copy_from_user()/copy_to_user() because it requires
holding the entire image in user space, and does not make sense for
restart.  Also, we don't use a pipe, pseudo-fs file and the like,
because they work by generating data on demand as the user pulls it
(unless the entire image is buffered in the kernel) and would require
more complex logic.  They also would significantly complicate
checkpoint that includes self.

Changelog[v16]:
  - Change sys_restart() first argument to be 'pid_t pid'

Changelog[v14]:
  - Change CONFIG_CHEKCPOINT_RESTART to CONFIG_CHECKPOINT (Ingo)
  - Remove line 'def_bool n' (default is already 'n')
  - Add CHECKPOINT_SUPPORT in Kconfig (Nathan Lynch)

Changelog[v5]:
  - Config is 'def_bool n' by default

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 arch/x86/Kconfig                   |    4 +++
 arch/x86/include/asm/unistd_32.h   |    2 +
 arch/x86/kernel/syscall_table_32.S |    2 +
 checkpoint/Kconfig                 |   14 ++++++++++++
 checkpoint/Makefile                |    5 ++++
 checkpoint/sys.c                   |   41 ++++++++++++++++++++++++++++++++++++
 include/linux/syscalls.h           |    2 +
 init/Kconfig                       |    2 +
 kernel/sys_ni.c                    |    4 +++
 9 files changed, 76 insertions(+), 0 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index a6efe0a..2891a26 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -77,6 +77,10 @@ config STACKTRACE_SUPPORT
 config HAVE_LATENCYTOP_SUPPORT
 	def_bool y
 
+config CHECKPOINT_SUPPORT
+	bool
+	default y if X86_32
+
 config FAST_CMPXCHG_LOCAL
 	bool
 	default y
diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
index 6e72d74..48557e1 100644
--- a/arch/x86/include/asm/unistd_32.h
+++ b/arch/x86/include/asm/unistd_32.h
@@ -340,6 +340,8 @@
 #define __NR_inotify_init1	332
 #define __NR_preadv		333
 #define __NR_pwritev		334
+#define __NR_checkpoint		335
+#define __NR_restart		336
 
 #ifdef __KERNEL__
 
diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
index ff5c873..e70b7ee 100644
--- a/arch/x86/kernel/syscall_table_32.S
+++ b/arch/x86/kernel/syscall_table_32.S
@@ -334,3 +334,5 @@ ENTRY(sys_call_table)
 	.long sys_inotify_init1
 	.long sys_preadv
 	.long sys_pwritev
+	.long sys_checkpoint
+	.long sys_restart
diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
new file mode 100644
index 0000000..1761b0a
--- /dev/null
+++ b/checkpoint/Kconfig
@@ -0,0 +1,14 @@
+# Architectures should define CHECKPOINT_SUPPORT when they have
+# implemented the hooks for processor state etc. needed by the
+# core checkpoint/restart code.
+
+config CHECKPOINT
+	bool "Enable checkpoint/restart (EXPERIMENTAL)"
+	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
+	help
+	  Application checkpoint/restart is the ability to save the
+	  state of a running application so that it can later resume
+	  its execution from the time at which it was checkpointed.
+
+	  Turning this option on will enable checkpoint and restart
+	  functionality in the kernel.
diff --git a/checkpoint/Makefile b/checkpoint/Makefile
new file mode 100644
index 0000000..8a32c6f
--- /dev/null
+++ b/checkpoint/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for linux checkpoint/restart.
+#
+
+obj-$(CONFIG_CHECKPOINT) += sys.o
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
new file mode 100644
index 0000000..9d4caff
--- /dev/null
+++ b/checkpoint/sys.c
@@ -0,0 +1,41 @@
+/*
+ *  Generic container checkpoint-restart
+ *
+ *  Copyright (C) 2008 Oren Laadan
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/sched.h>
+#include <linux/kernel.h>
+#include <linux/syscalls.h>
+
+/**
+ * sys_checkpoint - checkpoint a container
+ * @pid: pid of the container init(1) process
+ * @fd: file to which dump the checkpoint image
+ * @flags: checkpoint operation flags
+ *
+ * Returns positive identifier on success, 0 when returning from restart
+ * or negative value on error
+ */
+SYSCALL_DEFINE3(checkpoint, pid_t, pid, int, fd, unsigned long, flags)
+{
+	return -ENOSYS;
+}
+
+/**
+ * sys_restart - restart a container
+ * @crid: checkpoint image identifier
+ * @fd: file from which read the checkpoint image
+ * @flags: restart operation flags
+ *
+ * Returns negative value on error, or otherwise returns in the realm
+ * of the original checkpoint
+ */
+SYSCALL_DEFINE3(restart, pid_t, pid, int, fd, unsigned long, flags)
+{
+	return -ENOSYS;
+}
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 3052084..5dc3f9a 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -752,6 +752,8 @@ asmlinkage long sys_ppoll(struct pollfd __user *, unsigned int,
 			  size_t);
 asmlinkage long sys_pipe2(int __user *, int);
 asmlinkage long sys_pipe(int __user *);
+asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags);
+asmlinkage long sys_restart(int crid, int fd, unsigned long flags);
 
 int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
 
diff --git a/init/Kconfig b/init/Kconfig
index 7be4d38..adb4260 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1042,6 +1042,8 @@ config SLOW_WORK
 
 	  See Documentation/slow-work.txt.
 
+source "checkpoint/Kconfig"
+
 endmenu		# General setup
 
 config HAVE_GENERIC_DMA_COHERENT
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 27dad29..e9e749d 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -175,3 +175,7 @@ cond_syscall(compat_sys_timerfd_settime);
 cond_syscall(compat_sys_timerfd_gettime);
 cond_syscall(sys_eventfd);
 cond_syscall(sys_eventfd2);
+
+/* checkpoint/restart */
+cond_syscall(sys_checkpoint);
+cond_syscall(sys_restart);
-- 
1.6.0.4
