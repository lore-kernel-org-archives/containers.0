From: Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
Subject: Re: [PATCH] ARM: Added user space support for c/r on ARM
Date: Fri, 30 Apr 2010 10:42:42 +0100
Message-ID: <k2o7d08b87d1004300242wcab639e4l176cc3674b9d3e3f__22632.1584349082$1272620608$gmane$org@mail.gmail.com>
References: <20100429233346.GZ32490@count0.beaverton.ibm.com>
	<1272439752-4021-1-git-send-email-christofferdall@christofferdall.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1272439752-4021-1-git-send-email-christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Christoffer Dall <christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org>, libc-ports <libc-ports-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Apr 28, 2010 at 8:29 AM, Christoffer Dall
<christofferdall-77OGu6e99YhyO3AAkE1OcX9LOBIZ5rWg@public.gmane.org> wrote:
> Hi Matt.
>
> Thanks for the feedback. I have changed the path according to your commen=
ts
> and am attaching it below.
>
> =A0- Let me know if I need to adjust my patch before inclusion with respe=
ct to
> =A0 the s/clone_with_pids// later.
>
> =A0- Much better with the 'local SYS_NR_DEF_REGEX' in get_unistd_regex().
> =A0 Thanks.
>
> =A0- I pondered about inserting arch-specific code when printing the head=
er
> =A0 content, and thought about a file function like add_arch_syscall_base=
()
> =A0 but it seems rhather synthetic as I think ARM is the only possible
> =A0 architecture, which would use it. Instead, I added whitespace around =
the
> =A0 line as you suggest.
>
> =A0- I agree regarding the make variables - it was simply a glitch. I
> =A0 adjusted the assignment in both Makefile and test/Makefile.

sorry, I forgot to include the changes to test/Makefile in the patch below.
>
>
> Thanks,
> Christoffer
>
> diff --git a/Makefile b/Makefile
> index 6c9ff93..37ed40a 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -18,6 +18,13 @@ CR_OBJS =3D checkpoint.o checkpoint-main.o restart.o r=
estart-main.o
> =A0# detect architecture (for eclone)
> =A0SUBARCH ?=3D $(patsubst i%86,x86_32,$(shell uname -m))
>
> +# handle cross-compilation
> +AR =A0:=3D ${CROSS_COMPILE}ar
> +AS =A0:=3D ${CROSS_COMPILE}as
> +CC =A0:=3D ${CROSS_COMPILE}gcc
> +CPP :=3D ${CROSS_COMPILE}cpp
> +LD =A0:=3D ${CROSS_COMPILE}ld
> +
> =A0# compile with debug ?
> =A0DEBUG =3D -DCHECKPOINT_DEBUG
>
> @@ -77,6 +84,11 @@ ASFLAGS +=3D -m64
> =A0$(LIB_ECLONE): clone_$(SUBARCH)_.o
> =A0endif
>
> +# also on ARM, need also assembly file
> +ifeq ($(SUBARCH),arm)
> +$(LIB_ECLONE): eclone_$(SUBARCH)_.o
> +endif
> +
> =A0# ckptinfo dependencies
> =A0ckptinfo: ckptinfo_types.o
>
> diff --git a/clone.h b/clone.h
> index 3569a45..b6b18ce 100644
> --- a/clone.h
> +++ b/clone.h
> @@ -25,6 +25,14 @@
> =A0# =A0 =A0define __NR_unshare 303
> =A0#elif __powerpc__
> =A0# =A0 =A0define __NR_unshare 282
> +#elif __arm__
> +# =A0 =A0define __NR_OABI_SYSCALL_BASE 0x900000
> +# =A0 =A0if defined(__thumb__) || defined(__ARM_EABI__)
> +# =A0 =A0 =A0 =A0define __NR_SYSCALL_BASE 0
> +# =A0 =A0else
> +# =A0 =A0 =A0 =A0define __NR_SYSCALL_BASE __NR_OABI_SYSCALL_BASE
> +# =A0 =A0endif
> +# =A0 =A0define __NR_unshare (__NR_SYSCALL_BASE+337)
> =A0#else
> =A0# =A0 =A0error "Architecture not supported"
> =A0#endif
> diff --git a/clone_arm.c b/clone_arm.c
> new file mode 100644
> index 0000000..b62b4ad
> --- /dev/null
> +++ b/clone_arm.c
> @@ -0,0 +1,79 @@
> +/*
> + * =A0clone_arm.c: support for eclone() on ARM
> + *
> + * =A0Author: =A0 =A0Christoffer Dall <christofferdall@christofferdall.d=
k>
> + *
> + * =A0This file is subject to the terms and conditions of the GNU Genera=
l Public
> + * =A0License. =A0See the file COPYING in the main directory of the Linux
> + * =A0distribution for more details.
> + */
> +
> +#define _GNU_SOURCE
> +
> +#include <unistd.h>
> +#include <errno.h>
> +#include <stdio.h>
> +#include <sys/types.h>
> +#include <sys/syscall.h>
> +#include <asm/unistd.h>
> +
> +/*
> + * libc doesn't support eclone() yet...
> + * below is arch-dependent code to use the syscall
> + */
> +#include <linux/checkpoint.h>
> +
> +#include "eclone.h"
> +
> +extern int __eclone(int clone_flags_low,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct clone_args *clone_args,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int args_size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pid_t *pids);
> +
> +static unsigned long get_stack_pointer(unsigned long base, unsigned long=
 size)
> +{
> + =A0 =A0 =A0 size_t page_size =3D sysconf(_SC_PAGESIZE);
> + =A0 =A0 =A0 return (base + size - page_size) - 1;
> +}
> +
> +int eclone(int (*fn)(void *), void *fn_arg, int clone_flags_low,
> + =A0 =A0 =A0 =A0 =A0struct clone_args *clone_args, pid_t *pids)
> +{
> + =A0 =A0 =A0 struct clone_args my_args;
> + =A0 =A0 =A0 long newpid;
> + =A0 =A0 =A0 void **sp =3D NULL;
> +
> + =A0 =A0 =A0 if (!fn) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fprintf(stderr, "Please provide a valid fun=
ction pointer "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "for the ch=
ild process.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (clone_args->child_stack) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sp =3D (void **)get_stack_pointer(clone_arg=
s->child_stack,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 clone_args->child_stack_size);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *--sp =3D fn_arg;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *--sp =3D fn;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fprintf(stderr, "The ARM architecture requi=
res a valid child "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "stack. clo=
n_args->child_stack was 0.\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> + =A0 =A0 =A0 }
> +
> +
> + =A0 =A0 =A0 my_args =3D *clone_args;
> + =A0 =A0 =A0 my_args.child_stack =3D (unsigned long long)sp;
> + =A0 =A0 =A0 my_args.child_stack_size =3D 0;
> +
> + =A0 =A0 =A0 newpid =3D __eclone(clone_flags_low,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &my_args,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(my_args),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pids);
> +
> + =A0 =A0 =A0 if (newpid < 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 errno =3D -newpid;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 newpid =3D -1;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return newpid;
> +}
> diff --git a/eclone_arm_.S b/eclone_arm_.S
> new file mode 100644
> index 0000000..0f71d0f
> --- /dev/null
> +++ b/eclone_arm_.S
> @@ -0,0 +1,86 @@
> +/*
> + * =A0eclone_arm_.S: ARM support for eclone()
> + *
> + * =A0Author: =A0 =A0Christoffer Dall <christofferdall@christofferdall.d=
k>
> + *
> + * =A0This file is subject to the terms and conditions of the GNU Genera=
l Public
> + * =A0License. =A0See the file COPYING in the main directory of the Linux
> + * =A0distribution for more details.
> + */
> +
> +#define _ERRNO_H =A0 =A0 =A0 1
> +#include <bits/errno.h>
> +#include <asm/unistd.h>
> +
> +
> +#define CLONE_VM =A0 =A0 =A00x00000100
> +#define CLONE_THREAD =A00x00010000
> +
> +#ifndef __NR_eclone
> +#define __NR_eclone 366
> +#endif
> +
> +/*
> + * Implements the following system call wrapper:
> + *
> + * =A0 =A0 extern int __eclone(int clone_flags_low,
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct clone_args *cl=
one_args,
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pid_t *pids);
> + *
> + * The system call wrapper and the system call themselves have slightly
> + * different layouts and the following transformation takes place in
> + * the code below:
> + *
> + */
> +
> + =A0 =A0 =A0 =A0.text
> + =A0 =A0 =A0 .align 4
> + =A0 =A0 =A0 .globl __eclone
> + =A0 =A0 =A0 .type __eclone,%function
> +__eclone:
> + =A0 =A0 =A0 @ save flags
> + =A0 =A0 =A0 mov =A0 =A0 ip, r0
> +
> + =A0 =A0 =A0 @ do the system call
> +#ifdef __ARM_EABI__
> + =A0 =A0 =A0 str =A0 =A0 r7, [sp, #-4]!
> + =A0 =A0 =A0 ldr =A0 =A0 r7, =3D__NR_eclone
> + =A0 =A0 =A0 swi =A0 =A0 0x0
> +#else
> + =A0 =A0 =A0 swi =A0 =A0 __NR_eclone
> +#endif
> + =A0 =A0 =A0 cmp =A0 =A0 r0, #0
> + =A0 =A0 =A0 beq =A0 =A0 1f
> +#ifdef __ARM_EABI__
> + =A0 =A0 =A0 ldr =A0 =A0 r7, [sp], #4
> +#endif
> + =A0 =A0 =A0 @ return to caller
> + =A0 =A0 =A0 bx =A0 =A0 =A0lr
> +
> +1:
> + =A0 =A0 =A0 tst =A0 =A0 ip, #CLONE_THREAD
> + =A0 =A0 =A0 bne =A0 =A0 3f
> + =A0 =A0 =A0 mov =A0 =A0 r0, #0xffff0fff
> + =A0 =A0 =A0 mov =A0 =A0 lr, pc
> + =A0 =A0 =A0 sub =A0 =A0 pc, r0, #31
> + =A0 =A0 =A0 mov =A0 =A0 r1, r0
> + =A0 =A0 =A0 tst =A0 =A0 ip, #CLONE_VM
> + =A0 =A0 =A0 movne =A0 r0, #-1
> +#ifdef __ARM_EABI__
> + =A0 =A0 =A0 ldr =A0 =A0 r7, =3D__NR_getpid
> + =A0 =A0 =A0 swieq =A0 0x0
> +#else
> + =A0 =A0 =A0 swieq =A0 __NR_getpid
> +#endif
> + =A0 =A0 =A0 str =A0 =A0 r0, [r1, #-1108]
> + =A0 =A0 =A0 str =A0 =A0 r0, [r1, #-1112]
> +3:
> + =A0 =A0 =A0 @ pick the function arg and call address off the stack and =
execute
> + =A0 =A0 =A0 ldr =A0 =A0 r0, [sp, #4]
> + =A0 =A0 =A0 mov =A0 =A0 lr, pc
> + =A0 =A0 =A0 ldr =A0 =A0 pc, [sp], #8
> +
> + =A0 =A0 =A0 @ and we are done, passing the return value through r0
> + =A0 =A0 =A0 @b =A0 =A0 =A0 PLTJMP(HIDDEN_JUMPTARGET(_exit))
> + =A0 =A0 =A0 b =A0 =A0 =A0 _exit
> +
> diff --git a/include/asm-arm/checkpoint_hdr.h b/include/asm-arm/checkpoin=
t_hdr.h
> new file mode 100644
> index 0000000..9295f85
> --- /dev/null
> +++ b/include/asm-arm/checkpoint_hdr.h
> @@ -0,0 +1,55 @@
> +/*
> + * Generated by extract-headers.sh.
> + */
> +#ifndef __ASM_ARM_CHECKPOINT_HDR_H_
> +#define __ASM_ARM_CHECKPOINT_HDR_H_
> +
> +/*
> + * =A0Checkpoint/restart - architecture specific headers ARM
> + *
> + * =A0Copyright (C) 2008-2010 Oren Laadan
> + * =A0Copyright (C) =A0 =A0 =A02010 Christoffer Dall
> + *
> + * =A0This file is subject to the terms and conditions of the GNU Genera=
l Public
> + * =A0License. =A0See the file COPYING in the main directory of the Linux
> + * =A0distribution for more details.
> + */
> +
> +#include <linux/types.h>
> +
> +/* ARM structure seen from kernel/userspace */
> +
> +#define CKPT_ARCH_ID CKPT_ARCH_ARM
> +
> +/* arch dependent constants */
> +#define CKPT_ARCH_NSIG 64
> +#define CKPT_TTY_NCC 8
> +
> +struct ckpt_hdr_header_arch {
> + =A0 =A0 =A0 struct ckpt_hdr h;
> + =A0 =A0 =A0 __u32 =A0 cpu_architecture;
> + =A0 =A0 =A0 __u8 =A0 =A0mmu; =A0 =A0 =A0 =A0 =A0 =A0/* Checkpointed on =
mmu system */
> + =A0 =A0 =A0 __u8 =A0 =A0aeabi; =A0 =A0 =A0 =A0 =A0/* Checkpointed on AE=
ABI kernel */
> + =A0 =A0 =A0 __u8 =A0 =A0oabi_compat; =A0 =A0/* Checkpointed on OABI com=
pat. system */
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_thread {
> + =A0 =A0 =A0 struct ckpt_hdr h;
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 syscall;
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 tp_value;
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 thumbee_state;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_cpu {
> + =A0 =A0 =A0 struct ckpt_hdr h;
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 uregs[18];
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_mm_context {
> + =A0 =A0 =A0 struct ckpt_hdr h;
> + =A0 =A0 =A0 __u32 =A0 =A0 =A0 =A0 =A0 end_brk;
> +} __attribute__((aligned(8)));
> +
> +
> +
> +#endif /* __ASM_ARM_CHECKPOINT_HDR_H_ */
> diff --git a/include/asm/checkpoint_hdr.h b/include/asm/checkpoint_hdr.h
> index 859f58e..7f18e0e 100644
> --- a/include/asm/checkpoint_hdr.h
> +++ b/include/asm/checkpoint_hdr.h
> @@ -3,7 +3,9 @@
> =A0*/
> =A0#ifndef __ASM_CHECKPOINT_HDR_H_
> =A0#define __ASM_CHECKPOINT_HDR_H_
> -#if __powerpc__
> +#if __arm__
> +#include <asm-arm/checkpoint_hdr.h>
> +#elif __powerpc__
> =A0#include <asm-powerpc/checkpoint_hdr.h>
> =A0#elif __s390x__
> =A0#include <asm-s390/checkpoint_hdr.h>
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index f6a6448..359023f 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -31,7 +31,25 @@
> =A0#define CHECKPOINT_FD_NONE -1
>
>
> -#if __powerpc__
> +#if __arm__
> +
> +# =A0 =A0 =A0define __NR_OABI_SYSCALL_BASE 0x900000
> +# =A0 =A0 =A0if defined(__thumb__) || defined(__ARM_EABI__)
> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define __NR_SYSCALL_BASE =A0 =A0 =A0 =A00
> +# =A0 =A0 =A0else
> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define __NR_SYSCALL_BASE =A0 =A0 =A0 =A0__N=
R_OABI_SYSCALL_BASE
> +# =A0 =A0 =A0endif
> +
> +
> +# =A0 =A0 =A0ifndef __NR_checkpoint
> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define __NR_checkpoint (__NR_SYSCALL_BASE+3=
67)
> +# =A0 =A0 =A0endif
> +
> +# =A0 =A0 =A0ifndef __NR_restart
> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define __NR_restart (__NR_SYSCALL_BASE+368)
> +# =A0 =A0 =A0endif
> +
> +#elif __powerpc__
>
> =A0# =A0 =A0 =A0ifndef __NR_checkpoint
> =A0# =A0 =A0 =A0 =A0 =A0 =A0 =A0define __NR_checkpoint 324
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hd=
r.h
> index 65d5256..214cd11 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -202,6 +202,8 @@ enum {
> =A0#define CKPT_ARCH_PPC32 CKPT_ARCH_PPC32
> =A0 =A0 =A0 =A0CKPT_ARCH_PPC64,
> =A0#define CKPT_ARCH_PPC64 CKPT_ARCH_PPC64
> + =A0 =A0 =A0 CKPT_ARCH_ARM,
> +#define CKPT_ARCH_ARM CKPT_ARCH_ARM
> =A0};
>
> =A0/* shared objrects (objref) */
> diff --git a/scripts/extract-headers.sh b/scripts/extract-headers.sh
> index 8c8ae69..19f63b4 100755
> --- a/scripts/extract-headers.sh
> +++ b/scripts/extract-headers.sh
> @@ -144,7 +144,27 @@ echo '#endif /* _CHECKPOINT_CKPT_HDR_H_ */' >> "${OU=
TPUT_INCLUDES}/linux/checkpo
> =A0# We use ARCH_COND to break up architecture-specific sections of the h=
eader.
> =A0#
> =A0ARCH_COND=3D'#if'
> -REGEX=3D'[[:space:]]*#[[:space:]]*define[[:space:]]*__NR_(checkpoint|res=
tart|clone_with_pids)[[:space:]]+[0-9]+'
> +ARM_SYSCALL_BASE=3D"# =A0 =A0define __NR_OABI_SYSCALL_BASE 0x900000\n\
> +# =A0 =A0 =A0if defined(__thumb__) || defined(__ARM_EABI__)\n\
> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define __NR_SYSCALL_BASE =A0 =A0 =A0 =A00\n\
> +# =A0 =A0 =A0else\n\
> +# =A0 =A0 =A0 =A0 =A0 =A0 =A0define __NR_SYSCALL_BASE =A0 =A0 =A0 =A0__N=
R_OABI_SYSCALL_BASE\n\
> +# =A0 =A0 =A0endif\n"
> +
> +# Get the regular expression for the current architecture
> +function get_unistd_regex()
> +{
> + =A0 =A0 =A0 local SYS_NR_DEF_REGEX=3D'[[:space:]]*#[[:space:]]*define[[=
:space:]]*__NR_(checkpoint|restart|clone_with_pids)[[:space:]]+'
> +
> + =A0 =A0 =A0 case "$1" in
> + =A0 =A0 =A0 arm) =A0 =A0echo -n "${SYS_NR_DEF_REGEX}"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 echo -n '\(__NR_SYSCALL_BASE\+[[:space:]]*[=
0-9]*\)'
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ;;
> + =A0 =A0 =A0 *) =A0 =A0 =A0echo -n "${SYS_NR_DEF_REGEX}"'[0-9]+'
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ;;
> + =A0 =A0 =A0 esac
> + =A0 =A0 =A0 return 0
> +}
>
> =A0cat - <<-EOFOE
> =A0/*
> @@ -160,11 +180,15 @@ do_cpp "${KERNELSRC}/include/linux/checkpoint.h" "_=
LINUX_CHECKPOINT_H_"
> =A0find "${KERNELSRC}/arch" -name 'unistd*.h' -print | sort | \
> =A0while read UNISTDH ; do
> =A0 =A0 =A0 =A0[ -n "${UNISTDH}" ] || continue
> - =A0 =A0 =A0 grep -q -E "${REGEX}" "${UNISTDH}" || continue
> =A0 =A0 =A0 =A0KARCH=3D$(echo "${UNISTDH}" | sed -e 's|.*/arch/\([^/]\+\)=
/.*|\1|')
> + =A0 =A0 =A0 REGEX=3D"$(get_unistd_regex "${KARCH}")"
> + =A0 =A0 =A0 grep -q -E "${REGEX}" "${UNISTDH}" || continue
> =A0 =A0 =A0 =A0WORDBITS=3D$(basename "${UNISTDH}" | sed -e 's/unistd_*\([=
[:digit:]]\+\)\.h/\1/')
> =A0 =A0 =A0 =A0CPPARCH=3D"$(karch_to_cpparch "${KARCH}" "${WORDBITS}")"
> =A0 =A0 =A0 =A0echo -e "${ARCH_COND} __${CPPARCH}__\\n"
> +
> + =A0 =A0 =A0 [ "${KARCH}" =3D=3D "arm" ] && echo -e "${ARM_SYSCALL_BASE}=
\n"
> +
> =A0 =A0 =A0 =A0grep -E "${REGEX}" "${UNISTDH}" | \
> =A0 =A0 =A0 =A0sed -e 's/^[ \t]*#[ \t]*define[ \t]*__NR_\([^ \t]\+\)[ \t]=
\+\([^ \t]\+\).*$/#\tifndef __NR_\1\n#\t\tdefine __NR_\1 \2\n#\tendif\n/'
> =A0 =A0 =A0 =A0ARCH_COND=3D'#elif'
> diff --git a/test/Makefile b/test/Makefile
> index cad40e0..516eee8 100644
> --- a/test/Makefile
> +++ b/test/Makefile
> @@ -1,3 +1,9 @@
> +# handle cross-compilation
> +AR =3D ${CROSS_COMPILE}ar
> +AS =3D ${CROSS_COMPILE}as
> +CC =3D ${CROSS_COMPILE}gcc
> +CPP =3D ${CROSS_COMPILE}cpp
> +LD =3D ${CROSS_COMPILE}ld
>
> =A0# extra warnings and fun
> =A0WARNS :=3D -Wall -Wstrict-prototypes -Wno-trigraphs
> --
> 1.5.6.5
>
>
