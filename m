From: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Subject: [C/R ARM][PATCH] ARM: Added user space support for c/r on ARM
Date: Mon, 26 Apr 2010 17:49:42 -0400
Message-ID: <1272318582-28493-1-git-send-email-christofferdall__35447.9520152838$1272499520$gmane$org@christofferdall.dk>
References: <1269220484-24279-1-git-send-email-christofferdall@christofferdall.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1269220484-24279-1-git-send-email-christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>, libc-ports <libc-ports-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org>
List-Id: containers.vger.kernel.org

General
--------

This is a first attempt to add C/R support for ARM. There are a number
of annoying changes in the extract-headers.sh and clone.h files due to
the way syscall numbers are defined on the ARM architecture.

Additionally there's introduced general support for CROSS_COMPILATION
and the SUBARCH variable is now conditionally set, depending on existing
values from the environment.

Eclone
--------

The code is based on the clone.S file from glibc. Some of the functionality
from glibc such as _syscall_error can not be linked with directly, so error
handling is performed a little different. In time, this code will hopefully
merge with libc and when that happens it is obvious how to link with libc
code instead of custom assembler.

The implementation has been tested with nsexec and seems to be working
properly.  However, during testing, the code to access TLS in the libc error
handler (syscall_error) did not function correctly and in fact resulted in a
segmentation fault later on in the code. Instead of using the error
handler, we simply return to the caller and let it modify errno.

Note: The code to set an error for the child if CLONE_THREAD is not
specified, looks much like the syscall_error code and should probably
be tested later on. However, with CLONE_THREAD set there should be no
problems.

Signed-off-by: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Acked-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 Makefile                         |   12 +++++
 clone.h                          |    8 ++++
 clone_arm.c                      |   79 ++++++++++++++++++++++++++++++++++
 eclone_arm_.S                    |   86 ++++++++++++++++++++++++++++++++++++++
 include/asm-arm/checkpoint_hdr.h |   54 ++++++++++++++++++++++++
 include/asm/checkpoint_hdr.h     |    4 +-
 include/linux/checkpoint.h       |   20 ++++++++-
 include/linux/checkpoint_hdr.h   |    2 +
 scripts/extract-headers.sh       |   24 ++++++++++-
 test/Makefile                    |    6 +++
 10 files changed, 291 insertions(+), 4 deletions(-)
 create mode 100644 clone_arm.c
 create mode 100644 eclone_arm_.S
 create mode 100644 include/asm-arm/checkpoint_hdr.h

diff --git a/Makefile b/Makefile
index 6c9ff93..ccbc9f7 100644
--- a/Makefile
+++ b/Makefile
@@ -18,6 +18,13 @@ CR_OBJS = checkpoint.o checkpoint-main.o restart.o restart-main.o
 # detect architecture (for eclone)
 SUBARCH ?= $(patsubst i%86,x86_32,$(shell uname -m))
 
+# handle cross-compilation
+AR = ${CROSS_COMPILE}ar
+AS = ${CROSS_COMPILE}as
+CC = ${CROSS_COMPILE}gcc
+CPP = ${CROSS_COMPILE}cpp
+LD = ${CROSS_COMPILE}ld
+
 # compile with debug ?
 DEBUG = -DCHECKPOINT_DEBUG
 
@@ -77,6 +84,11 @@ ASFLAGS += -m64
 $(LIB_ECLONE): clone_$(SUBARCH)_.o
 endif
 
+# also on ARM, need also assembly file
+ifeq ($(SUBARCH),arm)
+$(LIB_ECLONE): eclone_$(SUBARCH)_.o
+endif
+
 # ckptinfo dependencies
 ckptinfo: ckptinfo_types.o
 
diff --git a/clone.h b/clone.h
index 3569a45..b6b18ce 100644
--- a/clone.h
+++ b/clone.h
@@ -25,6 +25,14 @@
 #    define __NR_unshare 303
 #elif __powerpc__
 #    define __NR_unshare 282
+#elif __arm__
+#    define __NR_OABI_SYSCALL_BASE 0x900000
+#    if defined(__thumb__) || defined(__ARM_EABI__)
+#        define __NR_SYSCALL_BASE 0
+#    else
+#        define __NR_SYSCALL_BASE __NR_OABI_SYSCALL_BASE
+#    endif
+#    define __NR_unshare (__NR_SYSCALL_BASE+337)
 #else
 #    error "Architecture not supported"
 #endif
diff --git a/clone_arm.c b/clone_arm.c
new file mode 100644
index 0000000..b62b4ad
--- /dev/null
+++ b/clone_arm.c
@@ -0,0 +1,79 @@
+/*
+ *  clone_arm.c: support for eclone() on ARM
+ *
+ *  Author:	Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#define _GNU_SOURCE
+
+#include <unistd.h>
+#include <errno.h>
+#include <stdio.h>
+#include <sys/types.h>
+#include <sys/syscall.h>
+#include <asm/unistd.h>
+
+/*
+ * libc doesn't support eclone() yet...
+ * below is arch-dependent code to use the syscall
+ */
+#include <linux/checkpoint.h>
+
+#include "eclone.h"
+
+extern int __eclone(int clone_flags_low,
+		    struct clone_args *clone_args,
+		    unsigned int args_size,
+		    pid_t *pids);
+
+static unsigned long get_stack_pointer(unsigned long base, unsigned long size)
+{
+	size_t page_size = sysconf(_SC_PAGESIZE);
+	return (base + size - page_size) - 1;
+}
+
+int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
+	   struct clone_args *clone_args, pid_t *pids)
+{
+	struct clone_args my_args;
+	long newpid;
+	void **sp = NULL;
+
+	if (!fn) {
+		fprintf(stderr, "Please provide a valid function pointer "
+				"for the child process.\n");
+		return -1;
+	}
+
+	if (clone_args->child_stack) {
+		sp = (void **)get_stack_pointer(clone_args->child_stack,
+						clone_args->child_stack_size);
+		*--sp = fn_arg;
+		*--sp = fn;
+	} else {
+		fprintf(stderr, "The ARM architecture requires a valid child "
+				"stack. clon_args->child_stack was 0.\n");
+		return -1;
+	}
+
+
+	my_args = *clone_args;
+	my_args.child_stack = (unsigned long long)sp;
+	my_args.child_stack_size = 0;
+
+	newpid = __eclone(clone_flags_low,
+			  &my_args,
+			  sizeof(my_args),
+			  pids);
+
+	if (newpid < 0) {
+		errno = -newpid;
+		newpid = -1;
+	}
+
+	return newpid;
+}
diff --git a/eclone_arm_.S b/eclone_arm_.S
new file mode 100644
index 0000000..0f71d0f
--- /dev/null
+++ b/eclone_arm_.S
@@ -0,0 +1,86 @@
+/*
+ *  eclone_arm_.S: ARM support for eclone()
+ *
+ *  Author:	Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#define _ERRNO_H	1
+#include <bits/errno.h>
+#include <asm/unistd.h>
+
+
+#define CLONE_VM      0x00000100
+#define CLONE_THREAD  0x00010000
+
+#ifndef __NR_eclone
+#define __NR_eclone 366
+#endif
+
+/*
+ * Implements the following system call wrapper:
+ *
+ *	extern int __eclone(int clone_flags_low,
+ *			    struct clone_args *clone_args,
+ *			    pid_t *pids);
+ *
+ * The system call wrapper and the system call themselves have slightly
+ * different layouts and the following transformation takes place in
+ * the code below:
+ *
+ */
+
+        .text
+	.align 4
+	.globl __eclone
+	.type __eclone,%function
+__eclone:
+	@ save flags
+	mov	ip, r0
+
+	@ do the system call
+#ifdef __ARM_EABI__
+	str	r7, [sp, #-4]!
+	ldr	r7, =__NR_eclone
+	swi	0x0
+#else
+	swi	__NR_eclone
+#endif
+	cmp	r0, #0
+	beq	1f
+#ifdef __ARM_EABI__
+	ldr	r7, [sp], #4
+#endif
+	@ return to caller
+	bx	lr
+
+1:
+	tst	ip, #CLONE_THREAD
+	bne	3f
+	mov	r0, #0xffff0fff
+	mov	lr, pc
+	sub	pc, r0, #31
+	mov	r1, r0
+	tst	ip, #CLONE_VM
+	movne	r0, #-1
+#ifdef __ARM_EABI__
+	ldr	r7, =__NR_getpid
+	swieq	0x0
+#else
+	swieq	__NR_getpid
+#endif
+	str	r0, [r1, #-1108]
+	str	r0, [r1, #-1112]
+3:
+	@ pick the function arg and call address off the stack and execute
+	ldr	r0, [sp, #4]
+	mov	lr, pc
+	ldr 	pc, [sp], #8
+
+	@ and we are done, passing the return value through r0
+	@b       PLTJMP(HIDDEN_JUMPTARGET(_exit))
+	b	_exit
+
diff --git a/include/asm-arm/checkpoint_hdr.h b/include/asm-arm/checkpoint_hdr.h
new file mode 100644
index 0000000..cec7986
--- /dev/null
+++ b/include/asm-arm/checkpoint_hdr.h
@@ -0,0 +1,54 @@
+/*
+ * Generated by extract-headers.sh.
+ */
+#ifndef __ASM_ARM_CHECKPOINT_HDR_H_
+#define __ASM_ARM_CHECKPOINT_HDR_H_
+
+/*
+ *  Checkpoint/restart - architecture specific headers ARM
+ *
+ *  Copyright (C) 2008-2010 Oren Laadan
+ *  Copyright	  2010	    Christoffer Dall
+ *
+ *  This file is subject to the terms and conditions of the GNU General Public
+ *  License.  See the file COPYING in the main directory of the Linux
+ *  distribution for more details.
+ */
+
+#include <linux/types.h>
+
+/* ARM structure seen from kernel/userspace */
+
+#define CKPT_ARCH_ID CKPT_ARCH_ARM
+
+/* arch dependent constants */
+#define CKPT_ARCH_NSIG 64
+#define CKPT_TTY_NCC 8
+
+struct ckpt_hdr_header_arch {
+	struct ckpt_hdr h;
+	__u32	linux_arm_arch;
+	__u8	mmu;		/* Checkpointed on mmu system */
+	__u8	oabi_compat;	/* Checkpointed on old ABI compat. system */
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_thread {
+	struct ckpt_hdr h;
+	__u32		syscall;
+	__u32		tp_value;
+	__u32		thumbee_state;
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_cpu {
+	struct ckpt_hdr h;
+	__u32		uregs[18];
+} __attribute__((aligned(8)));
+
+struct ckpt_hdr_mm_context {
+	struct ckpt_hdr h;
+	__u32		end_brk;
+} __attribute__((aligned(8)));
+
+
+
+#endif /* __ASM_ARM_CHECKPOINT_HDR_H_ */
diff --git a/include/asm/checkpoint_hdr.h b/include/asm/checkpoint_hdr.h
index 859f58e..7f18e0e 100644
--- a/include/asm/checkpoint_hdr.h
+++ b/include/asm/checkpoint_hdr.h
@@ -3,7 +3,9 @@
  */
 #ifndef __ASM_CHECKPOINT_HDR_H_
 #define __ASM_CHECKPOINT_HDR_H_
-#if __powerpc__
+#if __arm__
+#include <asm-arm/checkpoint_hdr.h>
+#elif __powerpc__
 #include <asm-powerpc/checkpoint_hdr.h>
 #elif __s390x__
 #include <asm-s390/checkpoint_hdr.h>
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index f6a6448..359023f 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -31,7 +31,25 @@
 #define CHECKPOINT_FD_NONE -1
 
 
-#if __powerpc__
+#if __arm__
+
+#	define __NR_OABI_SYSCALL_BASE 0x900000
+#	if defined(__thumb__) || defined(__ARM_EABI__)
+#		define __NR_SYSCALL_BASE	0
+#	else
+#		define __NR_SYSCALL_BASE	__NR_OABI_SYSCALL_BASE
+#	endif
+
+
+#	ifndef __NR_checkpoint
+#		define __NR_checkpoint (__NR_SYSCALL_BASE+367)
+#	endif
+
+#	ifndef __NR_restart
+#		define __NR_restart (__NR_SYSCALL_BASE+368)
+#	endif
+
+#elif __powerpc__
 
 #	ifndef __NR_checkpoint
 #		define __NR_checkpoint 324
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 65d5256..214cd11 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -202,6 +202,8 @@ enum {
 #define CKPT_ARCH_PPC32 CKPT_ARCH_PPC32
 	CKPT_ARCH_PPC64,
 #define CKPT_ARCH_PPC64 CKPT_ARCH_PPC64
+	CKPT_ARCH_ARM,
+#define CKPT_ARCH_ARM CKPT_ARCH_ARM
 };
 
 /* shared objrects (objref) */
diff --git a/scripts/extract-headers.sh b/scripts/extract-headers.sh
index 8c8ae69..aacb6af 100755
--- a/scripts/extract-headers.sh
+++ b/scripts/extract-headers.sh
@@ -144,7 +144,25 @@ echo '#endif /* _CHECKPOINT_CKPT_HDR_H_ */' >> "${OUTPUT_INCLUDES}/linux/checkpo
 # We use ARCH_COND to break up architecture-specific sections of the header.
 #
 ARCH_COND='#if'
-REGEX='[[:space:]]*#[[:space:]]*define[[:space:]]*__NR_(checkpoint|restart|clone_with_pids)[[:space:]]+[0-9]+'
+ARM_SYSCALL_BASE="#	define __NR_OABI_SYSCALL_BASE 0x900000\n\
+#	if defined(__thumb__) || defined(__ARM_EABI__)\n\
+#		define __NR_SYSCALL_BASE	0\n\
+#	else\n\
+#		define __NR_SYSCALL_BASE	__NR_OABI_SYSCALL_BASE\n\
+#	endif\n"
+
+# Get the regular expression for the current architecture
+function get_unistd_regex()
+{
+	case "$1" in
+	arm)	echo -n '[[:space:]]*#[[:space:]]*define[[:space:]]*__NR_(checkpoint|restart|clone_with_pids)[[:space:]]+'
+		echo -n '\(__NR_SYSCALL_BASE\+[[:space:]]*[0-9]*\)'
+		;;
+	*)	echo -n '[[:space:]]*#[[:space:]]*define[[:space:]]*__NR_(checkpoint|restart|clone_with_pids)[[:space:]]+[0-9]+'
+		;;
+	esac
+	return 0
+}
 
 cat - <<-EOFOE
 /*
@@ -160,11 +178,13 @@ do_cpp "${KERNELSRC}/include/linux/checkpoint.h" "_LINUX_CHECKPOINT_H_"
 find "${KERNELSRC}/arch" -name 'unistd*.h' -print | sort | \
 while read UNISTDH ; do
 	[ -n "${UNISTDH}" ] || continue
-	grep -q -E "${REGEX}" "${UNISTDH}" || continue
 	KARCH=$(echo "${UNISTDH}" | sed -e 's|.*/arch/\([^/]\+\)/.*|\1|')
+	REGEX="$(get_unistd_regex "${KARCH}")"
+	grep -q -E "${REGEX}" "${UNISTDH}" || continue
 	WORDBITS=$(basename "${UNISTDH}" | sed -e 's/unistd_*\([[:digit:]]\+\)\.h/\1/')
 	CPPARCH="$(karch_to_cpparch "${KARCH}" "${WORDBITS}")"
 	echo -e "${ARCH_COND} __${CPPARCH}__\\n"
+	[ "${KARCH}" == "arm" ] && echo -e "${ARM_SYSCALL_BASE}\n"
 	grep -E "${REGEX}" "${UNISTDH}" | \
 	sed -e 's/^[ \t]*#[ \t]*define[ \t]*__NR_\([^ \t]\+\)[ \t]\+\([^ \t]\+\).*$/#\tifndef __NR_\1\n#\t\tdefine __NR_\1 \2\n#\tendif\n/'
 	ARCH_COND='#elif'
diff --git a/test/Makefile b/test/Makefile
index cad40e0..516eee8 100644
--- a/test/Makefile
+++ b/test/Makefile
@@ -1,3 +1,9 @@
+# handle cross-compilation
+AR = ${CROSS_COMPILE}ar
+AS = ${CROSS_COMPILE}as
+CC = ${CROSS_COMPILE}gcc
+CPP = ${CROSS_COMPILE}cpp
+LD = ${CROSS_COMPILE}ld
 
 # extra warnings and fun
 WARNS := -Wall -Wstrict-prototypes -Wno-trigraphs
-- 
1.5.6.5
