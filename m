From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] user-cr: Extract headers from kernel source tree.
Date: Fri, 23 Oct 2009 14:38:23 -0400
Message-ID: <4AE1F81F.50400@librato.com>
References: <1254554424-2979-2-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1254554424-2979-2-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Pulled, thanks.

Matt Helsley wrote:
> Using kernel headers directly from userspace is strongly discouraged.
> 
> Sanitize kernel headers for userspace by extracting non-__KERNEL__
> portions of the various checkpoint headers and placing them in a
> similar organization of userspace headers.
> 
> The script is run from the top level of the user-cr source tree like:
> 
> 	./scripts/extract-headers.sh -s <path-to-kern-source> -o ./include
> 
> The patch includes a copy of the auto-generated headers and adjusts
> the user-cr programs to use them.
> 
> Programs should only include linux/checkpoint.h and
> linux/checkpoint_hdr.h. asm/checkpoint_hdr.h is included from
> linux/checkpoint_hdr.h
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> 
> Changelog:
> v3:
> 	Inverted headers/$(CKPT_HEADERS) rule dependency. This causes it
> 		to extract headers only when one or more are missing.
> 
> 	Moved all of the include definition hacks into a kernel header
> 		patch instead.
> 
> v2:
> 	Re-added KERNELSRC ?= ../linux
> 
> 	Merged checkpoint_syscalls.h with checkpoint.h and added a
> 		comment about the unistd code eventually going away.
> 		Thanks to Oren for pointing out the latter.
> 
> 	Added special-case code for stripping linux/un.h from the
> 		checkpoint_hdr.h; (s/linux/sys/ did not work)
> 
> 	Cleaned up do_cpp to make the "include" regex tricks more
> 		obvious to the casual reader.
> 
> 	Modified Makefile to re-extract headers for every build.
> 
> 	Removed the find command that filled CKPT_HEADERS.
> 		This was the easiest solution. Otherwise the Makefiles
> 		might become considerably more obfuscated.
> 
> 	Tested on and made changes for s390x:
> 
> 		Always include sys/types.h before linux/types.h to avoid
> 		conflicting definitions.
> 
> 		Define NUM_CR_WORDS if it's not already defined in
> 			asm/ptrace.h (seems some s390x installs don't
> 			define NUM_CR_WORDS anywhere outside the kernel
> 			source).
> ---
>  Makefile                             |   40 +-
>  ckptinfo.c                           |    1 +
>  clone_ppc.c                          |    1 +
>  clone_s390x.c                        |    1 +
>  clone_x86_32.c                       |    1 +
>  include/asm-powerpc/checkpoint_hdr.h |   21 +
>  include/asm-s390/checkpoint_hdr.h    |   89 ++++
>  include/asm-x86/checkpoint_hdr.h     |  126 ++++++
>  include/asm/checkpoint_hdr.h         |   15 +
>  include/linux/checkpoint.h           |   73 ++++
>  include/linux/checkpoint_hdr.h       |  749 ++++++++++++++++++++++++++++++++++
>  scripts/extract-headers.sh           |  250 +++++++++++
>  12 files changed, 1344 insertions(+), 23 deletions(-)
>  create mode 100644 include/asm-powerpc/checkpoint_hdr.h
>  create mode 100644 include/asm-s390/checkpoint_hdr.h
>  create mode 100644 include/asm-x86/checkpoint_hdr.h
>  create mode 100644 include/asm/checkpoint_hdr.h
>  create mode 100644 include/linux/checkpoint.h
>  create mode 100644 include/linux/checkpoint_hdr.h
>  create mode 100755 scripts/extract-headers.sh
> 
> diff --git a/Makefile b/Makefile
> index 7f5cb27..181cc1c 100644
> --- a/Makefile
> +++ b/Makefile
> @@ -1,24 +1,9 @@
> -
>  KERNELSRC ?= ../linux
> -KERNELBUILD ?= ../linux
> -
> -# default with 'make headers_install'
> -KERNELHDR ?= $(KERNELSRC)/usr/include
> -
> -ifneq "$(realpath $(KERNELHDR)/linux/checkpoint.h)" ""
> -# if .../usr/include contains our headers
> -CKPT_INCLUDE = -I$(KERNELHDR)
> -CKPT_HEADERS = $(KERNELHDR)/linux/checkpoint_hdr.h \
> -	       $(KERNELHDR)/asm/checkpoint_hdr.h
> -else
> -# else, usr the kernel source itself
> -# but first, find linux architecure
> -KERN_ARCH = $(shell readlink $(KERNELBUILD)/include/asm | sed 's/^asm-//')
> -CKPT_INCLUDE = -I$(KERNELSRC)/include \
> -	       -I$(KERNELSRC)/arch/$(KERN_ARCH)/include
> -CKPT_HEADERS = $(KERNELSRC)/include/linux/checkpoint_hdr.h \
> -	       $(KERNELSRC)/arch/$(KERN_ARCH)/include/asm/checkpoint_hdr.h
> -endif
> +
> +CKPT_INCLUDE = -I./include
> +CKPT_HEADERS = include/linux/checkpoint.h \
> +		include/linux/checkpoint_hdr.h \
> +		include/asm/checkpoint_hdr.h
>  
>  # detect architecture (for clone_with_pids)
>  SUBARCH = $(patsubst i%86,x86_32,$(shell uname -m))
> @@ -42,6 +27,8 @@ OTHER = ckptinfo_types.c
>  
>  LDLIBS = -lm
>  
> +.PHONY: all distclean clean headers install
> +
>  all: $(PROGS)
>  	@make -C test
>  
> @@ -63,13 +50,20 @@ endif
>  ckptinfo: ckptinfo_types.o
>  
>  ckptinfo_types.c: $(CKPT_HEADERS) ckptinfo.py
> -	@echo cat $(CKPT_HEADERS) | ./ckptinfo.py > ckptinfo_types.c
> -	@cat $(CKPT_HEADERS) | ./ckptinfo.py > ckptinfo_types.c
> +	cat $(CKPT_HEADERS) | ./ckptinfo.py > ckptinfo_types.c
>  
>  install:
>  	@echo /usr/bin/install -m 755 checkpoint restart ckptinfo $(INSTALL_DIR)
>  	@/usr/bin/install -m 755 checkpoint restart ckptinfo $(INSTALL_DIR)
>  
> +$(CKPT_HEADERS): %:
> +	./scripts/extract-headers.sh -s $(KERNELSRC) -o ./include
> +
> +headers: $(CKPT_HEADERS)
> +
> +distclean: clean
> +	@rm -f $(CKPT_HEADERS)
> +
>  clean:
> -	@rm -f $(PROGS) $(OTHER) *~ *.o
> +	@rm -f $(PROGS) $(OTHER) *~ *.o headers.h
>  	@make -C test clean
> diff --git a/ckptinfo.c b/ckptinfo.c
> index 6859742..9eea791 100644
> --- a/ckptinfo.c
> +++ b/ckptinfo.c
> @@ -18,6 +18,7 @@
>  #include <sys/stat.h>
>  #include <fcntl.h>
>  
> +#include <linux/checkpoint.h>
>  #include <linux/checkpoint_hdr.h>
>  #include <asm/checkpoint_hdr.h>
>  
> diff --git a/clone_ppc.c b/clone_ppc.c
> index 09b51b5..49797fd 100644
> --- a/clone_ppc.c
> +++ b/clone_ppc.c
> @@ -31,6 +31,7 @@ extern int __clone_with_pids(int (*fn)(void *arg),
>   * libc doesn't support clone_with_pid() yet...
>   * below is arch-dependent code to use the syscall
>   */
> +#include <linux/checkpoint.h>
>  #if defined(__NR_clone_with_pids)
>  
>  /* (see: http://lkml.indiana.edu/hypermail/linux/kernel/9604.3/0204.html) */
> diff --git a/clone_s390x.c b/clone_s390x.c
> index 661a5c4..dada822 100644
> --- a/clone_s390x.c
> +++ b/clone_s390x.c
> @@ -22,6 +22,7 @@
>   * libc doesn't support clone_with_pid() yet...
>   * below is arch-dependent code to use the syscall
>   */
> +#include <linux/checkpoint.h>
>  #if defined(__NR_clone_with_pids)
>  
>  /* this really belongs to some kernel header ! */
> diff --git a/clone_x86_32.c b/clone_x86_32.c
> index 05a689e..8ab3c3e 100644
> --- a/clone_x86_32.c
> +++ b/clone_x86_32.c
> @@ -20,6 +20,7 @@
>   * libc doesn't support clone_with_pid() yet...
>   * below is arch-dependent code to use the syscall
>   */
> +#include <linux/checkpoint.h>
>  #if defined(__NR_clone_with_pids)
>  
>  /* this really belongs to some kernel header ! */
> diff --git a/include/asm-powerpc/checkpoint_hdr.h b/include/asm-powerpc/checkpoint_hdr.h
> new file mode 100644
> index 0000000..105a184
> --- /dev/null
> +++ b/include/asm-powerpc/checkpoint_hdr.h
> @@ -0,0 +1,21 @@
> +/*
> + * Generated by extract-headers.sh.
> + */
> +#ifndef __ASM_POWERPC_CHECKPOINT_HDR_H_
> +#define __ASM_POWERPC_CHECKPOINT_HDR_H_
> +
> +
> +#include <linux/types.h>
> +
> +/* arch dependent constants */
> +#define CKPT_ARCH_NSIG 64
> +#define CKPT_TTY_NCC 10
> +
> +struct ckpt_hdr_header_arch {
> +	struct ckpt_hdr h;
> +	__u32 what;
> +} __attribute__((aligned(8)));
> +
> +
> +
> +#endif /* __ASM_POWERPC_CHECKPOINT_HDR_H_ */
> diff --git a/include/asm-s390/checkpoint_hdr.h b/include/asm-s390/checkpoint_hdr.h
> new file mode 100644
> index 0000000..ad1a2e2
> --- /dev/null
> +++ b/include/asm-s390/checkpoint_hdr.h
> @@ -0,0 +1,89 @@
> +/*
> + * Generated by extract-headers.sh.
> + */
> +#ifndef __ASM_S390_CHECKPOINT_HDR_H_
> +#define __ASM_S390_CHECKPOINT_HDR_H_
> +
> +/*
> + *  Checkpoint/restart - architecture specific headers s/390
> + *
> + *  Copyright IBM Corp. 2009
> + *
> + *  This file is subject to the terms and conditions of the GNU General Public
> + *  License.  See the file COPYING in the main directory of the Linux
> + *  distribution for more details.
> + */
> +
> +#include <linux/types.h>
> +#include <asm/ptrace.h>
> +
> +/*
> + * Notes
> + * NUM_GPRS defined in <asm/ptrace.h> to be 16
> + * NUM_FPRS defined in <asm/ptrace.h> to be 16
> + * NUM_APRS defined in <asm/ptrace.h> to be 16
> + * NUM_CR_WORDS defined in <asm/ptrace.h> to be 3
> + *              but is not yet in glibc headers.
> + */
> +
> +#define NUM_CR_WORDS 3
> +
> +struct ckpt_hdr_cpu {
> +	struct ckpt_hdr h;
> +	__u64 args[1];
> +	__u64 gprs[NUM_GPRS];
> +	__u64 orig_gpr2;
> +	__u16 svcnr;
> +	__u16 ilc;
> +	__u32 acrs[NUM_ACRS];
> +	__u64 ieee_instruction_pointer;
> +
> +	/* psw_t */
> +	__u64 psw_t_mask;
> +	__u64 psw_t_addr;
> +
> +	/* s390_fp_regs_t */
> +	__u32 fpc;
> +	union {
> +		float f;
> +		double d;
> +		__u64 ui;
> +		struct {
> +			__u32 fp_hi;
> +			__u32 fp_lo;
> +		} fp;
> +	} fprs[NUM_FPRS];
> +
> +	/* per_struct */
> +	__u64 per_control_regs[NUM_CR_WORDS];
> +	__u64 starting_addr;
> +	__u64 ending_addr;
> +	__u64 address;
> +	__u16 perc_atmid;
> +	__u8 access_id;
> +	__u8 single_step;
> +	__u8 instruction_fetch;
> +};
> +
> +struct ckpt_hdr_mm_context {
> +	struct ckpt_hdr h;
> +	unsigned long vdso_base;
> +	int noexec;
> +	int has_pgste;
> +	int alloc_pgste;
> +	unsigned long asce_bits;
> +	unsigned long asce_limit;
> +};
> +
> +#define CKPT_ARCH_NSIG 64
> +#define CKPT_TTY_NCC 8
> +
> +/* arch dependent constants */
> +
> +struct ckpt_hdr_header_arch {
> +	struct ckpt_hdr h;
> +};
> +
> +
> +
> +#endif /* __ASM_S390_CHECKPOINT_HDR_H_ */
> diff --git a/include/asm-x86/checkpoint_hdr.h b/include/asm-x86/checkpoint_hdr.h
> new file mode 100644
> index 0000000..4bf3b8a
> --- /dev/null
> +++ b/include/asm-x86/checkpoint_hdr.h
> @@ -0,0 +1,126 @@
> +/*
> + * Generated by extract-headers.sh.
> + */
> +#ifndef __ASM_X86_CHECKPOINT_HDR_H_
> +#define __ASM_X86_CHECKPOINT_HDR_H_
> +
> +/*
> + *  Checkpoint/restart - architecture specific headers x86
> + *
> + *  Copyright (C) 2008-2009 Oren Laadan
> + *
> + *  This file is subject to the terms and conditions of the GNU General Public
> + *  License.  See the file COPYING in the main directory of the Linux
> + *  distribution for more details.
> + */
> +
> +#include <linux/types.h>
> +
> +/*
> + * To maintain compatibility between 32-bit and 64-bit architecture flavors,
> + * keep data 64-bit aligned: use padding for structure members, and use
> + * __attribute__((aligned (8))) for the entire structure.
> + *
> + * Quoting Arnd Bergmann:
> + *   "This structure has an odd multiple of 32-bit members, which means
> + *   that if you put it into a larger structure that also contains 64-bit
> + *   members, the larger structure may get different alignment on x86-32
> + *   and x86-64, which you might want to avoid. I can't tell if this is
> + *   an actual problem here. ... In this case, I'm pretty sure that
> + *   sizeof(ckpt_hdr_task) on x86-32 is different from x86-64, since it
> + *   will be 32-bit aligned on x86-32."
> + */
> +
> +/* i387 structure seen from kernel/userspace */
> +
> +/* arch dependent header types */
> +enum {
> +	CKPT_HDR_CPU_FPU = 201,
> +	CKPT_HDR_MM_CONTEXT_LDT,
> +};
> +
> +/* arch dependent constants */
> +#define CKPT_ARCH_NSIG 64
> +#define CKPT_TTY_NCC 8
> +
> +struct ckpt_hdr_header_arch {
> +	struct ckpt_hdr h;
> +	/* FIXME: add HAVE_HWFP */
> +	__u16 has_fxsr;
> +	__u16 has_xsave;
> +	__u16 xstate_size;
> +	__u16 _pading;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_thread {
> +	struct ckpt_hdr h;
> +	__u32 thread_info_flags;
> +	__u16 gdt_entry_tls_entries;
> +	__u16 sizeof_tls_array;
> +} __attribute__((aligned(8)));
> +
> +/* designed to work for both x86_32 and x86_64 */
> +struct ckpt_hdr_cpu {
> +	struct ckpt_hdr h;
> +	/* see struct pt_regs (x86_64) */
> +	__u64 r15;
> +	__u64 r14;
> +	__u64 r13;
> +	__u64 r12;
> +	__u64 bp;
> +	__u64 bx;
> +	__u64 r11;
> +	__u64 r10;
> +	__u64 r9;
> +	__u64 r8;
> +	__u64 ax;
> +	__u64 cx;
> +	__u64 dx;
> +	__u64 si;
> +	__u64 di;
> +	__u64 orig_ax;
> +	__u64 ip;
> +	__u64 sp;
> +
> +	__u64 flags;
> +
> +	/* segment registers */
> +	__u64 fs;
> +	__u64 gs;
> +
> +	__u16 fsindex;
> +	__u16 gsindex;
> +	__u16 cs;
> +	__u16 ss;
> +	__u16 ds;
> +	__u16 es;
> +
> +	__u32 used_math;
> +
> +	/* debug registers */
> +	__u64 debugreg0;
> +	__u64 debugreg1;
> +	__u64 debugreg2;
> +	__u64 debugreg3;
> +	__u64 debugreg6;
> +	__u64 debugreg7;
> +
> +	/* thread_xstate contents follow (if used_math) */
> +} __attribute__((aligned(8)));
> +
> +#define CKPT_X86_SEG_NULL 0
> +#define CKPT_X86_SEG_USER32_CS 1
> +#define CKPT_X86_SEG_USER32_DS 2
> +#define CKPT_X86_SEG_TLS 0x4000 /* 0100 0000 0000 00xx */
> +#define CKPT_X86_SEG_LDT 0x8000 /* 100x xxxx xxxx xxxx */
> +
> +struct ckpt_hdr_mm_context {
> +	struct ckpt_hdr h;
> +	__u64 vdso;
> +	__u32 ldt_entry_size;
> +	__u32 nldt;
> +} __attribute__((aligned(8)));
> +
> +
> +
> +#endif /* __ASM_X86_CHECKPOINT_HDR_H_ */
> diff --git a/include/asm/checkpoint_hdr.h b/include/asm/checkpoint_hdr.h
> new file mode 100644
> index 0000000..859f58e
> --- /dev/null
> +++ b/include/asm/checkpoint_hdr.h
> @@ -0,0 +1,15 @@
> +/*
> + * Generated by extract-headers.sh.
> + */
> +#ifndef __ASM_CHECKPOINT_HDR_H_
> +#define __ASM_CHECKPOINT_HDR_H_
> +#if __powerpc__
> +#include <asm-powerpc/checkpoint_hdr.h>
> +#elif __s390x__
> +#include <asm-s390/checkpoint_hdr.h>
> +#elif __i386__ || __x86_64__
> +#include <asm-x86/checkpoint_hdr.h>
> +#else
> +#error "Architecture does not have definitons needed for checkpoint images."
> +#endif
> +#endif /* __ASM_CHECKPOINT_HDR_H_ */
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> new file mode 100644
> index 0000000..75fdb0a
> --- /dev/null
> +++ b/include/linux/checkpoint.h
> @@ -0,0 +1,73 @@
> +/*
> + * Generated by extract-headers.sh.
> + */
> +#ifndef _LINUX_CHECKPOINT_H_
> +#define _LINUX_CHECKPOINT_H_
> +
> +/*
> + *  Generic checkpoint-restart
> + *
> + *  Copyright (C) 2008-2009 Oren Laadan
> + *
> + *  This file is subject to the terms and conditions of the GNU General Public
> + *  License.  See the file COPYING in the main directory of the Linux
> + *  distribution for more details.
> + */
> +
> +#define CHECKPOINT_VERSION 2
> +
> +/* checkpoint user flags */
> +#define CHECKPOINT_SUBTREE 0x1
> +
> +/* restart user flags */
> +#define RESTART_TASKSELF 0x1
> +#define RESTART_FROZEN 0x2
> +#define RESTART_GHOST 0x4
> +
> +
> +#if __powerpc__
> +
> +#	ifndef __NR_checkpoint
> +#		define __NR_checkpoint 323
> +#	endif
> +
> +#	ifndef __NR_restart
> +#		define __NR_restart 324
> +#	endif
> +
> +#	ifndef __NR_clone_with_pids
> +#		define __NR_clone_with_pids 325
> +#	endif
> +
> +#elif __s390x__
> +
> +#	ifndef __NR_checkpoint
> +#		define __NR_checkpoint 332
> +#	endif
> +
> +#	ifndef __NR_restart
> +#		define __NR_restart 333
> +#	endif
> +
> +#	ifndef __NR_clone_with_pids
> +#		define __NR_clone_with_pids 334
> +#	endif
> +
> +#elif __i386__
> +
> +#	ifndef __NR_clone_with_pids
> +#		define __NR_clone_with_pids 337
> +#	endif
> +
> +#	ifndef __NR_checkpoint
> +#		define __NR_checkpoint 338
> +#	endif
> +
> +#	ifndef __NR_restart
> +#		define __NR_restart 339
> +#	endif
> +
> +#else
> +#error "Architecture does not have definitons for __NR_(checkpoint|restart)"
> +#endif
> +#endif /* _LINUX_CHECKPOINT_H_ */
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> new file mode 100644
> index 0000000..01f9957
> --- /dev/null
> +++ b/include/linux/checkpoint_hdr.h
> @@ -0,0 +1,749 @@
> +/*
> + * Generated by extract-headers.sh.
> + */
> +#ifndef _CHECKPOINT_CKPT_HDR_H_
> +#define _CHECKPOINT_CKPT_HDR_H_
> +
> +/*
> + *  Generic container checkpoint-restart
> + *
> + *  Copyright (C) 2008-2009 Oren Laadan
> + *
> + *  This file is subject to the terms and conditions of the GNU General Public
> + *  License.  See the file COPYING in the main directory of the Linux
> + *  distribution for more details.
> + */
> +
> +/* In userspace sys/types.h must be included before linux/types.h */
> +#include <sys/types.h>
> +
> +#include <linux/types.h>
> +
> +#include <sys/socket.h>
> +#include <sys/un.h>
> +#include <netinet/in.h>
> +
> +/*
> + * To maintain compatibility between 32-bit and 64-bit architecture flavors,
> + * keep data 64-bit aligned: use padding for structure members, and use
> + * __attribute__((aligned (8))) for the entire structure.
> + *
> + * Quoting Arnd Bergmann:
> + *   "This structure has an odd multiple of 32-bit members, which means
> + *   that if you put it into a larger structure that also contains 64-bit
> + *   members, the larger structure may get different alignment on x86-32
> + *   and x86-64, which you might want to avoid. I can't tell if this is
> + *   an actual problem here. ... In this case, I'm pretty sure that
> + *   sizeof(ckpt_hdr_task) on x86-32 is different from x86-64, since it
> + *   will be 32-bit aligned on x86-32."
> + */
> +
> +/*
> + * header format: 'struct ckpt_hdr' must prefix all other headers. Therfore
> + * when a header is passed around, the information about it (type, size)
> + * is readily available. Structs that include a struct ckpt_hdr are named
> + * struct ckpt_hdr_* by convention (usualy the struct ckpt_hdr is the first
> + * member).
> + */
> +struct ckpt_hdr {
> +	__u32 type;
> +	__u32 len;
> +} __attribute__((aligned(8)));
> +
> +#include <asm/checkpoint_hdr.h>
> +
> +/* header types */
> +enum {
> +	CKPT_HDR_HEADER = 1,
> +	CKPT_HDR_HEADER_ARCH,
> +	CKPT_HDR_BUFFER,
> +	CKPT_HDR_STRING,
> +	CKPT_HDR_OBJREF,
> +
> +	CKPT_HDR_TREE = 101,
> +	CKPT_HDR_TASK,
> +	CKPT_HDR_TASK_NS,
> +	CKPT_HDR_TASK_OBJS,
> +	CKPT_HDR_RESTART_BLOCK,
> +	CKPT_HDR_THREAD,
> +	CKPT_HDR_CPU,
> +	CKPT_HDR_NS,
> +	CKPT_HDR_UTS_NS,
> +	CKPT_HDR_IPC_NS,
> +	CKPT_HDR_CAPABILITIES,
> +	CKPT_HDR_USER_NS,
> +	CKPT_HDR_CRED,
> +	CKPT_HDR_USER,
> +	CKPT_HDR_GROUPINFO,
> +	CKPT_HDR_TASK_CREDS,
> +
> +	/* 201-299: reserved for arch-dependent */
> +
> +	CKPT_HDR_FILE_TABLE = 301,
> +	CKPT_HDR_FILE_DESC,
> +	CKPT_HDR_FILE_NAME,
> +	CKPT_HDR_FILE,
> +	CKPT_HDR_PIPE_BUF,
> +	CKPT_HDR_TTY,
> +	CKPT_HDR_TTY_LDISC,
> +
> +	CKPT_HDR_MM = 401,
> +	CKPT_HDR_VMA,
> +	CKPT_HDR_PGARR,
> +	CKPT_HDR_MM_CONTEXT,
> +
> +	CKPT_HDR_IPC = 501,
> +	CKPT_HDR_IPC_SHM,
> +	CKPT_HDR_IPC_MSG,
> +	CKPT_HDR_IPC_MSG_MSG,
> +	CKPT_HDR_IPC_SEM,
> +
> +	CKPT_HDR_SIGHAND = 601,
> +	CKPT_HDR_SIGNAL,
> +	CKPT_HDR_SIGNAL_TASK,
> +	CKPT_HDR_SIGPENDING,
> +
> +	CKPT_HDR_SOCKET = 701,
> +	CKPT_HDR_SOCKET_QUEUE,
> +	CKPT_HDR_SOCKET_BUFFER,
> +	CKPT_HDR_SOCKET_UNIX,
> +	CKPT_HDR_SOCKET_INET,
> +
> +	CKPT_HDR_TAIL = 9001,
> +
> +	CKPT_HDR_ERROR = 9999,
> +	CKPT_HDR_KERNEL_STACK = 10000,
> +};
> +
> +/* architecture */
> +enum {
> +	/* do not change order (will break ABI) */
> +	CKPT_ARCH_X86_32 = 1,
> +	CKPT_ARCH_S390X,
> +	CKPT_ARCH_PPC32,
> +	CKPT_ARCH_PPC64,
> +};
> +
> +/* shared objrects (objref) */
> +struct ckpt_hdr_objref {
> +	struct ckpt_hdr h;
> +	__u32 objtype;
> +	__s32 objref;
> +} __attribute__((aligned(8)));
> +
> +/* shared objects types */
> +enum obj_type {
> +	CKPT_OBJ_IGNORE = 0,
> +	CKPT_OBJ_INODE,
> +	CKPT_OBJ_FILE_TABLE,
> +	CKPT_OBJ_FILE,
> +	CKPT_OBJ_MM,
> +	CKPT_OBJ_SIGHAND,
> +	CKPT_OBJ_SIGNAL,
> +	CKPT_OBJ_NS,
> +	CKPT_OBJ_UTS_NS,
> +	CKPT_OBJ_IPC_NS,
> +	CKPT_OBJ_USER_NS,
> +	CKPT_OBJ_CRED,
> +	CKPT_OBJ_USER,
> +	CKPT_OBJ_GROUPINFO,
> +	CKPT_OBJ_SOCK,
> +	CKPT_OBJ_TTY,
> +	CKPT_OBJ_MAX
> +};
> +
> +/* kernel constants */
> +struct ckpt_const {
> +	/* task */
> +	__u16 task_comm_len;
> +	/* mm */
> +	__u16 mm_saved_auxv_len;
> +	/* signal */
> +	__u16 signal_nsig;
> +	/* uts */
> +	__u16 uts_sysname_len;
> +	__u16 uts_nodename_len;
> +	__u16 uts_release_len;
> +	__u16 uts_version_len;
> +	__u16 uts_machine_len;
> +	__u16 uts_domainname_len;
> +	/* rlimit */
> +	__u16 rlimit_nlimits;
> +	/* tty */
> +	__u16 n_tty_buf_size;
> +	__u16 tty_termios_ncc;
> +} __attribute__((aligned(8)));
> +
> +/* checkpoint image header */
> +struct ckpt_hdr_header {
> +	struct ckpt_hdr h;
> +	__u64 magic;
> +
> +	__u16 arch_id;
> +
> +	__u16 major;
> +	__u16 minor;
> +	__u16 patch;
> +	__u16 rev;
> +
> +	struct ckpt_const constants;
> +
> +	__u64 time;	/* when checkpoint taken */
> +	__u64 uflags;	/* uflags from checkpoint */
> +
> +	/*
> +	 * the header is followed by three strings:
> +	 *   char release[const.uts_release_len];
> +	 *   char version[const.uts_version_len];
> +	 *   char machine[const.uts_machine_len];
> +	 */
> +} __attribute__((aligned(8)));
> +
> +/* checkpoint image trailer */
> +struct ckpt_hdr_tail {
> +	struct ckpt_hdr h;
> +	__u64 magic;
> +} __attribute__((aligned(8)));
> +
> +/* task tree */
> +struct ckpt_hdr_tree {
> +	struct ckpt_hdr h;
> +	__s32 nr_tasks;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_pids {
> +	__s32 vpid;
> +	__s32 vppid;
> +	__s32 vtgid;
> +	__s32 vpgid;
> +	__s32 vsid;
> +} __attribute__((aligned(8)));
> +
> +/* pids */
> +#define CKPT_PID_NULL -1
> +
> +/* task data */
> +struct ckpt_hdr_task {
> +	struct ckpt_hdr h;
> +	__u32 state;
> +	__u32 exit_state;
> +	__u32 exit_code;
> +	__u32 exit_signal;
> +	__u32 pdeath_signal;
> +
> +	__u64 set_child_tid;
> +	__u64 clear_child_tid;
> +
> +	__u32 compat_robust_futex_head_len;
> +	__u32 compat_robust_futex_list; /* a compat __user ptr */
> +	__u32 robust_futex_head_len;
> +	__u64 robust_futex_list; /* a __user ptr */
> +} __attribute__((aligned(8)));
> +
> +/* Posix capabilities */
> +struct ckpt_capabilities {
> +	__u32 cap_i_0, cap_i_1; /* inheritable set */
> +	__u32 cap_p_0, cap_p_1; /* permitted set */
> +	__u32 cap_e_0, cap_e_1; /* effective set */
> +	__u32 cap_b_0, cap_b_1; /* bounding set */
> +	__u32 securebits;
> +	__u32 padding;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_task_creds {
> +	struct ckpt_hdr h;
> +	__s32 cred_ref;
> +	__s32 ecred_ref;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_cred {
> +	struct ckpt_hdr h;
> +	__u32 uid, suid, euid, fsuid;
> +	__u32 gid, sgid, egid, fsgid;
> +	__s32 user_ref;
> +	__s32 groupinfo_ref;
> +	struct ckpt_capabilities cap_s;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_groupinfo {
> +	struct ckpt_hdr h;
> +	__u32 ngroups;
> +	/*
> +	 * This is followed by ngroups __u32s
> +	 */
> +	__u32 groups[0];
> +} __attribute__((aligned(8)));
> +
> +/*
> + * todo - keyrings and LSM
> + * These may be better done with userspace help though
> + */
> +struct ckpt_hdr_user_struct {
> +	struct ckpt_hdr h;
> +	__u32 uid;
> +	__s32 userns_ref;
> +} __attribute__((aligned(8)));
> +
> +/*
> + * The user-struct mostly tracks system resource usage.
> + * Most of it's contents therefore will simply be set
> + * correctly as restart opens resources
> + */
> +struct ckpt_hdr_user_ns {
> +	struct ckpt_hdr h;
> +	__s32 creator_ref;
> +} __attribute__((aligned(8)));
> +
> +/* namespaces */
> +struct ckpt_hdr_task_ns {
> +	struct ckpt_hdr h;
> +	__s32 ns_objref;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_ns {
> +	struct ckpt_hdr h;
> +	__s32 uts_objref;
> +	__u32 ipc_objref;
> +} __attribute__((aligned(8)));
> +
> +/* cannot include <linux/tty.h> from userspace, so define: */
> +#define CKPT_NEW_UTS_LEN 64
> +
> +struct ckpt_hdr_utsns {
> +	struct ckpt_hdr h;
> +	char sysname[CKPT_NEW_UTS_LEN + 1];
> +	char nodename[CKPT_NEW_UTS_LEN + 1];
> +	char release[CKPT_NEW_UTS_LEN + 1];
> +	char version[CKPT_NEW_UTS_LEN + 1];
> +	char machine[CKPT_NEW_UTS_LEN + 1];
> +	char domainname[CKPT_NEW_UTS_LEN + 1];
> +} __attribute__((aligned(8)));
> +
> +/* task's shared resources */
> +struct ckpt_hdr_task_objs {
> +	struct ckpt_hdr h;
> +
> +	__s32 files_objref;
> +	__s32 mm_objref;
> +	__s32 sighand_objref;
> +	__s32 signal_objref;
> +} __attribute__((aligned(8)));
> +
> +/* restart blocks */
> +struct ckpt_hdr_restart_block {
> +	struct ckpt_hdr h;
> +	__u64 function_type;
> +	__u64 arg_0;
> +	__u64 arg_1;
> +	__u64 arg_2;
> +	__u64 arg_3;
> +	__u64 arg_4;
> +} __attribute__((aligned(8)));
> +
> +enum restart_block_type {
> +	CKPT_RESTART_BLOCK_NONE = 1,
> +	CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP,
> +	CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP,
> +	CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP,
> +	CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP,
> +	CKPT_RESTART_BLOCK_POLL,
> +	CKPT_RESTART_BLOCK_FUTEX
> +};
> +
> +/* file system */
> +struct ckpt_hdr_file_table {
> +	struct ckpt_hdr h;
> +	__s32 fdt_nfds;
> +} __attribute__((aligned(8)));
> +
> +/* file descriptors */
> +struct ckpt_hdr_file_desc {
> +	struct ckpt_hdr h;
> +	__s32 fd_objref;
> +	__s32 fd_descriptor;
> +	__u32 fd_close_on_exec;
> +} __attribute__((aligned(8)));
> +
> +enum file_type {
> +	CKPT_FILE_IGNORE = 0,
> +	CKPT_FILE_GENERIC,
> +	CKPT_FILE_PIPE,
> +	CKPT_FILE_FIFO,
> +	CKPT_FILE_SOCKET,
> +	CKPT_FILE_TTY,
> +	CKPT_FILE_MAX
> +};
> +
> +/* file objects */
> +struct ckpt_hdr_file {
> +	struct ckpt_hdr h;
> +	__u32 f_type;
> +	__u32 f_mode;
> +	__u32 f_flags;
> +	__s32 f_credref;
> +	__u64 f_pos;
> +	__u64 f_version;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_file_generic {
> +	struct ckpt_hdr_file common;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_file_pipe {
> +	struct ckpt_hdr_file common;
> +	__s32 pipe_objref;
> +} __attribute__((aligned(8)));
> +
> +/* socket */
> +struct ckpt_hdr_socket {
> +	struct ckpt_hdr h;
> +
> +	struct { /* struct socket */
> +		__u64 flags;
> +		__u8 state;
> +	} socket __attribute__ ((aligned(8)));
> +
> +	struct { /* struct sock_common */
> +		__u32 bound_dev_if;
> +		__u32 reuse;
> +		__u16 family;
> +		__u8 state;
> +	} sock_common __attribute__ ((aligned(8)));
> +
> +	struct { /* struct sock */
> +		__s64 rcvlowat;
> +		__u64 flags;
> +
> +		__s64 rcvtimeo;
> +		__s64 sndtimeo;
> +
> +		__u32 err;
> +		__u32 err_soft;
> +		__u32 priority;
> +		__s32 rcvbuf;
> +		__s32 sndbuf;
> +		__u16 type;
> +		__s16 backlog;
> +
> +		__u8 protocol;
> +		__u8 state;
> +		__u8 shutdown;
> +		__u8 userlocks;
> +		__u8 no_check;
> +
> +		struct linger linger;
> +	} sock __attribute__ ((aligned(8)));
> +} __attribute__ ((aligned(8)));
> +
> +struct ckpt_hdr_socket_queue {
> +	struct ckpt_hdr h;
> +	__u32 skb_count;
> +	__u32 total_bytes;
> +} __attribute__ ((aligned(8)));
> +
> +struct ckpt_hdr_socket_buffer {
> +	struct ckpt_hdr h;
> +	__s32 sk_objref;
> +	__s32 pr_objref;
> +};
> +
> +#define CKPT_UNIX_LINKED 1
> +struct ckpt_hdr_socket_unix {
> +	struct ckpt_hdr h;
> +	__s32 this;
> +	__s32 peer;
> +	__u32 peercred_uid;
> +	__u32 peercred_gid;
> +	__u32 flags;
> +	__u32 laddr_len;
> +	__u32 raddr_len;
> +	struct sockaddr_un laddr;
> +	struct sockaddr_un raddr;
> +} __attribute__ ((aligned(8)));
> +
> +struct ckpt_hdr_socket_inet {
> +	struct ckpt_hdr h;
> +	__u32 laddr_len;
> +	__u32 raddr_len;
> +	struct sockaddr_in laddr;
> +	struct sockaddr_in raddr;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_file_socket {
> +	struct ckpt_hdr_file common;
> +	__s32 sock_objref;
> +} __attribute__((aligned(8)));
> +
> +/* memory layout */
> +struct ckpt_hdr_mm {
> +	struct ckpt_hdr h;
> +	__u32 map_count;
> +	__s32 exe_objref;
> +
> +	__u64 def_flags;
> +	__u64 flags;
> +
> +	__u64 start_code, end_code, start_data, end_data;
> +	__u64 start_brk, brk, start_stack;
> +	__u64 arg_start, arg_end, env_start, env_end;
> +} __attribute__((aligned(8)));
> +
> +/* vma subtypes - index into restore_vma_dispatch[] */
> +enum vma_type {
> +	CKPT_VMA_IGNORE = 0,
> +	CKPT_VMA_VDSO,		/* special vdso vma */
> +	CKPT_VMA_ANON,		/* private anonymous */
> +	CKPT_VMA_FILE,		/* private mapped file */
> +	CKPT_VMA_SHM_ANON,	/* shared anonymous */
> +	CKPT_VMA_SHM_ANON_SKIP,	/* shared anonymous (skip contents) */
> +	CKPT_VMA_SHM_FILE,	/* shared mapped file, only msync */
> +	CKPT_VMA_SHM_IPC,	/* shared sysvipc */
> +	CKPT_VMA_SHM_IPC_SKIP,	/* shared sysvipc (skip contents) */
> +	CKPT_VMA_MAX,
> +};
> +
> +/* vma descriptor */
> +struct ckpt_hdr_vma {
> +	struct ckpt_hdr h;
> +	__u32 vma_type;
> +	__s32 vma_objref;	/* objref of backing file */
> +	__s32 ino_objref;	/* objref of shared segment */
> +	__u32 _padding;
> +	__u64 ino_size;		/* size of shared segment */
> +
> +	__u64 vm_start;
> +	__u64 vm_end;
> +	__u64 vm_page_prot;
> +	__u64 vm_flags;
> +	__u64 vm_pgoff;
> +} __attribute__((aligned(8)));
> +
> +/* page array */
> +struct ckpt_hdr_pgarr {
> +	struct ckpt_hdr h;
> +	__u64 nr_pages;		/* number of pages to saved */
> +} __attribute__((aligned(8)));
> +
> +/* signals */
> +struct ckpt_sigset {
> +	__u8 sigset[CKPT_ARCH_NSIG / 8];
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_sigaction {
> +	__u64 _sa_handler;
> +	__u64 sa_flags;
> +	__u64 sa_restorer;
> +	struct ckpt_sigset sa_mask;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_sighand {
> +	struct ckpt_hdr h;
> +	struct ckpt_sigaction action[0];
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_siginfo {
> +	__u32 signo;
> +	__u32 _errno;
> +	__u32 code;
> +
> +	__u32 pid;
> +	__s32 uid;
> +	__u32 sigval_int;
> +	__u64 sigval_ptr;
> +	__u64 utime;
> +	__u64 stime;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_sigpending {
> +	struct ckpt_hdr h;
> +	__u32 nr_pending;
> +	struct ckpt_sigset signal;
> +	struct ckpt_siginfo siginfo[0];
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_rlimit {
> +	__u64 rlim_cur;
> +	__u64 rlim_max;
> +} __attribute__((aligned(8)));
> +
> +/* cannot include <linux/resource.h> from userspace, so define: */
> +#define CKPT_RLIM_NLIMITS 16
> +
> +struct ckpt_hdr_signal {
> +	struct ckpt_hdr h;
> +	/* rlimit */
> +	struct ckpt_rlimit rlim[CKPT_RLIM_NLIMITS];
> +	/* itimer */
> +	__u64 it_real_value;
> +	__u64 it_real_incr;
> +	__u64 it_virt_value;
> +	__u64 it_virt_incr;
> +	__u64 it_prof_value;
> +	__u64 it_prof_incr;
> +	/* tty */
> +	__s32 tty_objref;
> +	__s32 tty_pgrp;
> +	__s32 tty_old_pgrp;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_signal_task {
> +	struct ckpt_hdr h;
> +	struct ckpt_sigset blocked;
> +} __attribute__((aligned(8)));
> +
> +/* ipc commons */
> +struct ckpt_hdr_ipcns {
> +	struct ckpt_hdr h;
> +	__u64 shm_ctlmax;
> +	__u64 shm_ctlall;
> +	__s32 shm_ctlmni;
> +
> +	__s32 msg_ctlmax;
> +	__s32 msg_ctlmnb;
> +	__s32 msg_ctlmni;
> +
> +	__s32 sem_ctl_msl;
> +	__s32 sem_ctl_mns;
> +	__s32 sem_ctl_opm;
> +	__s32 sem_ctl_mni;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_ipc {
> +	struct ckpt_hdr h;
> +	__u32 ipc_type;
> +	__u32 ipc_count;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_ipc_perms {
> +	struct ckpt_hdr h;
> +	__s32 id;
> +	__u32 key;
> +	__u32 uid;
> +	__u32 gid;
> +	__u32 cuid;
> +	__u32 cgid;
> +	__u32 mode;
> +	__u32 _padding;
> +	__u64 seq;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_ipc_shm {
> +	struct ckpt_hdr h;
> +	struct ckpt_hdr_ipc_perms perms;
> +	__u64 shm_segsz;
> +	__u64 shm_atim;
> +	__u64 shm_dtim;
> +	__u64 shm_ctim;
> +	__s32 shm_cprid;
> +	__s32 shm_lprid;
> +	__u32 mlock_uid;
> +	__u32 flags;
> +	__u32 objref;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_ipc_msg {
> +	struct ckpt_hdr h;
> +	struct ckpt_hdr_ipc_perms perms;
> +	__u64 q_stime;
> +	__u64 q_rtime;
> +	__u64 q_ctime;
> +	__u64 q_cbytes;
> +	__u64 q_qnum;
> +	__u64 q_qbytes;
> +	__s32 q_lspid;
> +	__s32 q_lrpid;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_ipc_msg_msg {
> +	struct ckpt_hdr h;
> +	__s32 m_type;
> +	__u32 m_ts;
> +} __attribute__((aligned(8)));
> +
> +struct ckpt_hdr_ipc_sem {
> +	struct ckpt_hdr h;
> +	struct ckpt_hdr_ipc_perms perms;
> +	__u64 sem_otime;
> +	__u64 sem_ctime;
> +	__u32 sem_nsems;
> +} __attribute__((aligned(8)));
> +
> +/* devices */
> +struct ckpt_hdr_file_tty {
> +	struct ckpt_hdr_file common;
> +	__s32 tty_objref;
> +};
> +
> +struct ckpt_hdr_tty {
> +	struct ckpt_hdr h;
> +
> +	__u16 driver_type;
> +	__u16 driver_subtype;
> +
> +	__s32 link_objref;
> +	__s32 file_objref;
> +	__u32 _padding;
> +
> +	__u32 index;
> +	__u32 ldisc;
> +	__u64 flags;
> +
> +	/* termios */
> +	struct {
> +		__u16 c_iflag;
> +		__u16 c_oflag;
> +		__u16 c_cflag;
> +		__u16 c_lflag;
> +		__u8 c_line;
> +		__u8 c_cc[CKPT_TTY_NCC];
> +	} __attribute__((aligned(8))) termios;
> +
> +	/* winsize */
> +	struct {
> +		__u16 ws_row;
> +		__u16 ws_col;
> +		__u16 ws_xpixel;
> +		__u16 ws_ypixel;
> +	} __attribute__((aligned(8))) winsize;
> +} __attribute__((aligned(8)));
> +
> +/* cannot include <linux/tty.h> from userspace, so define: */
> +#define CKPT_N_TTY_BUF_SIZE 4096
> +
> +struct ckpt_hdr_ldisc_n_tty {
> +	struct ckpt_hdr h;
> +
> +	__u32 column;
> +	__u32 datalen;
> +	__u32 canon_column;
> +	__u32 canon_datalen;
> +	__u32 canon_data;
> +
> +	__u16 minimum_to_wake;
> +
> +	__u8 stopped;
> +	__u8 hw_stopped;
> +	__u8 flow_stopped;
> +	__u8 packet;
> +	__u8 ctrl_status;
> +	__u8 lnext;
> +	__u8 erasing;
> +	__u8 raw;
> +	__u8 real_raw;
> +	__u8 icanon;
> +	__u8 closing;
> +	__u8 padding[3];
> +
> +	__u8 read_flags[CKPT_N_TTY_BUF_SIZE / 8];
> +
> +	/* if @datalen > 0, buffer contents follow (next object) */
> +} __attribute__((aligned(8)));
> +
> +#define CKPT_TST_OVERFLOW_16(a,b) ((sizeof(a) > sizeof(b)) && ((a) > SHORT_MAX))
> +
> +#define CKPT_TST_OVERFLOW_32(a,b) ((sizeof(a) > sizeof(b)) && ((a) > INT_MAX))
> +
> +#define CKPT_TST_OVERFLOW_64(a,b) ((sizeof(a) > sizeof(b)) && ((a) > LONG_MAX))
> +
> +
> +#endif /* _CHECKPOINT_CKPT_HDR_H_ */
> diff --git a/scripts/extract-headers.sh b/scripts/extract-headers.sh
> new file mode 100755
> index 0000000..360a889
> --- /dev/null
> +++ b/scripts/extract-headers.sh
> @@ -0,0 +1,250 @@
> +#!/bin/bash
> +#
> +# Copyright (C) 2009 IBM Corp.
> +# Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> +#
> +# This file is subject to the terms and conditions of the GNU General Public
> +# License.  See the file COPYING in the main directory of the Linux
> +# distribution for more details.
> +#
> +
> +#
> +# Sanitize checkpoint/restart kernel headers for userspace.
> +#
> +
> +function usage()
> +{
> +	echo "Usage: $0 [-h|--help] -s|--kernel-src=DIR"
> +}
> +
> +OUTPUT_INCLUDES="include"
> +OPTIONS=`getopt -o s:o:h --long kernel-src:,output:,help -- "$@"`
> +eval set -- "${OPTIONS}"
> +while true ; do
> +	case "$1" in
> +	-s|--kernel-src)
> +		KERNELSRC="$2"
> +		shift 2 ;;
> +	-o|--output)
> +		OUTPUT_INCLUDES="$2"
> +		shift 2 ;;
> +	-h|--help)
> +		usage
> +		exit 0 ;;
> +	--)
> +		shift
> +		break ;;
> +	*)
> +		echo "Unknown option: $1"
> +		shift
> +		echo "Unparsed options: $@"
> +		usage 1>&2
> +		exit 2 ;;
> +	esac
> +done
> +
> +if [ -z "${KERNELSRC}" -o '!' -d "${KERNELSRC}" ]; then
> +	usage 1>&2
> +	exit 2
> +fi
> +
> +# Match cpp includes
> +INCLUDE_PRE_REGEX='#[[:space:]]*include[[:space:]]*\([<"]'
> +INCLUDE_FILE_REGEX='[^">]*'
> +INCLUDE_POST_REGEX='[">]\)'
> +
> +# Match cpp includes with \1 being the included file
> +INCLUDE_REGEX="${INCLUDE_PRE_REGEX}${INCLUDE_FILE_REGEX}${INCLUDE_POST_REGEX}"
> +
> +# Match includes of linux/types.h (\1 == linux/types.h)
> +INCLUDE_LINUX_TYPES_REGEX="${INCLUDE_PRE_REGEX}linux\/types\.h${INCLUDE_POST_REGEX}"
> +
> +# Match includes of linux/* with \1 being everything preceding "linux/" and \2
> +# being everything following "linux/"
> +INCLUDE_LINUX_REGEX="${INCLUDE_PRE_REGEX}"'\)'"linux\/"'\('"${INCLUDE_FILE_REGEX}${INCLUDE_POST_REGEX}"
> +
> +#
> +# Run the kernel header through cpp to strip out __KERNEL__ sections but try
> +# to leave the rest untouched.
> +#
> +function do_cpp ()
> +{
> +	local CPP_FILE="$1"
> +	local START_DEFINE="$2"
> +	shift 2
> +
> +	#
> +	# Hide #include directives then run cpp. Make cpp keep comments, not
> +	# insert line numbers, avoid system/gcc/std defines, and only expand
> +	# directives. Strip cpp output until we get to #define START_DEFINE,
> +	# and collapse the excessive number of blank lines that cpp outputs
> +	# in place of directives. Finally, replace linux/ with sys/ prefixes
> +	# of include paths, except for linux/types.h (needed for __uXX types).
> +	#
> +	sed -e 's|'"${INCLUDE_REGEX}"'|/*#include \1*/|g' "${CPP_FILE}" | \
> +	cpp -CC -P -U__KERNEL__ -undef -nostdinc -fdirectives-only -dDI "$@" | \
> +	awk 'BEGIN { do_print = 0; }
> +	     /#[[:space:]]*define '"${START_DEFINE}"'/  { do_print = 1; next; }
> +	     (do_print == 1)				{ print }' | \
> +	cat -s | \
> +	sed -e 's|/\*'"${INCLUDE_REGEX}"'\*/|#include \1|g' | \
> +	sed -e "/${INCLUDE_LINUX_TYPES_REGEX}/n" \
> +	    -e "s|${INCLUDE_LINUX_REGEX}|#include \1sys/\2|"
> +	echo ''
> +}
> +
> +# Map KARCH to something suitable for CPP e.g. __i386__
> +function karch_to_cpparch ()
> +{
> +	local KARCH="$1"
> +	local WORDBITS="$2"
> +	shift 2;
> +
> +	case "${KARCH}" in
> +	x86)	[ "${WORDBITS}" == "32" ] && echo -n "i386"
> +		[ "${WORDBITS}" == "64" ] && echo -n "x86_64"
> +		[ -z "${WORDBITS}" ]      && echo -n 'i386__ || __x86_64' # HACK
> +		;;
> +	s390*)	echo -n "s390x" ;;
> +	*)	echo -n "${KARCH}" ;;
> +	esac
> +	return 0
> +}
> +
> +set -e
> +
> +mkdir -p "${OUTPUT_INCLUDES}/linux"
> +mkdir -p "${OUTPUT_INCLUDES}/asm"
> +
> +#
> +# Process include/linux/checkpoint_hdr.h -> include/linux/checkpoint_hdr.h
> +#
> +cat - > "${OUTPUT_INCLUDES}/linux/checkpoint_hdr.h" <<-EOFOO
> +/*
> + * Generated by $(basename "$0").
> + */
> +#ifndef _CHECKPOINT_CKPT_HDR_H_
> +#define _CHECKPOINT_CKPT_HDR_H_
> +
> +EOFOO
> +
> +do_cpp "${KERNELSRC}/include/linux/checkpoint_hdr.h" "_CHECKPOINT_CKPT_HDR_H_" \
> +>> "${OUTPUT_INCLUDES}/linux/checkpoint_hdr.h"
> +echo '#endif /* _CHECKPOINT_CKPT_HDR_H_ */' >> "${OUTPUT_INCLUDES}/linux/checkpoint_hdr.h"
> +
> +#
> +# Process include/linux/checkpoint.h -> include/linux/checkpoint.h
> +#     and arch/*/include/asm/unistd.h -> include/linux/checkpoint.h.
> +# Eventually the unistd.h portion will get into the glibc headers and
> +# we can drop that part of this script.
> +#
> +
> +(
> +#
> +# We use ARCH_COND to break up architecture-specific sections of the header.
> +#
> +ARCH_COND='#if'
> +REGEX='[[:space:]]*#[[:space:]]*define[[:space:]]+__NR_(checkpoint|restart|clone_with_pids)[[:space:]]+[[:digit:]]+'
> +
> +cat - <<-EOFOE
> +/*
> + * Generated by $(basename "$0").
> + */
> +#ifndef _LINUX_CHECKPOINT_H_
> +#define _LINUX_CHECKPOINT_H_
> +
> +EOFOE
> +
> +do_cpp "${KERNELSRC}/include/linux/checkpoint.h" "_LINUX_CHECKPOINT_H_"
> +
> +find "${KERNELSRC}/arch" -name 'unistd*.h' -print | sort | \
> +while read UNISTDH ; do
> +	[ -n "${UNISTDH}" ] || continue
> +	grep -q -E "${REGEX}" "${UNISTDH}" || continue
> +
> +	KARCH=$(echo "${UNISTDH}" | sed -e 's|.*/arch/\([^/]\+\)/.*|\1|')
> +	WORDBITS=$(basename "${UNISTDH}" | sed -e 's/unistd_*\([[:digit:]]\+\)\.h/\1/')
> +	CPPARCH="$(karch_to_cpparch "${KARCH}" "${WORDBITS}")"
> +	echo -e "${ARCH_COND} __${CPPARCH}__\\n"
> +	grep -E "${REGEX}" "${UNISTDH}" | \
> +	sed -e 's/^[[:space:]]*#[[:space:]]*define[[:space:]]\+__NR_\([^[:space:]]\+\)[[:space:]]\+\([^[:space:]]\+\).*$/#\tifndef __NR_\1\n#\t\tdefine __NR_\1 \2\n#\tendif\n/'
> +	ARCH_COND='#elif'
> +done
> +
> +cat - <<-EOFOFOE
> +#else
> +#error "Architecture does not have definitons for __NR_(checkpoint|restart)"
> +#endif
> +#endif /* _LINUX_CHECKPOINT_H_ */
> +EOFOFOE
> +
> +) > "${OUTPUT_INCLUDES}/linux/checkpoint.h"
> +
> +#
> +# Process arch/*/include/asm/checkpoint_hdr.h -> include/asm/checkpoint_hdr.h
> +# Use #if __arch1__ ... #elif __arch2___ ... #endif to wrap each portion.
> +#
> +ARCH_COND='#if'
> +
> +find "${KERNELSRC}/arch" -name 'checkpoint_hdr.h' -print | sort | \
> +while read ARCH_CHECKPOINT_HDR_H ; do
> +	[ -n "${ARCH_CHECKPOINT_HDR_H}" ] || continue
> +
> +	KARCH=$(echo "${ARCH_CHECKPOINT_HDR_H}" | sed -e 's|.*/arch/\([^/]\+\)/.*|\1|')
> +	UPCASE_KARCH=$(echo "${KARCH}" | tr 'a-z' 'A-Z')
> +	mkdir -p "${OUTPUT_INCLUDES}/asm-${KARCH}"
> +	cat - > "${OUTPUT_INCLUDES}/asm-${KARCH}/checkpoint_hdr.h" <<-EOFOEOF
> +	/*
> +	 * Generated by $(basename "$0").
> +	 */
> +	#ifndef __ASM_${UPCASE_KARCH}_CHECKPOINT_HDR_H_
> +	#define __ASM_${UPCASE_KARCH}_CHECKPOINT_HDR_H_
> +
> +	EOFOEOF
> +
> +	do_cpp "${KERNELSRC}/arch/${KARCH}/include/asm/checkpoint_hdr.h" '__ASM.*_CKPT_HDR_H' -D_CHECKPOINT_CKPT_HDR_H_ >> "${OUTPUT_INCLUDES}/asm-${KARCH}/checkpoint_hdr.h" 
> +
> +	cat - >> "${OUTPUT_INCLUDES}/asm-${KARCH}/checkpoint_hdr.h" <<-FOEOEOF
> +
> +	#endif /* __ASM_${UPCASE_KARCH}_CHECKPOINT_HDR_H_ */
> +	FOEOEOF
> +
> +	ARCH_COND='#elif'
> +done
> +
> +#
> +# Process arch/*/include/asm/checkpoint_hdr.h -> include/asm/checkpoint_hdr.h
> +# Use #if __arch1__ ... #elif __arch2___ ... #endif to wrap each portion.
> +#
> +(
> +ARCH_COND='#if'
> +
> +cat - <<-EOFOEOF
> +/*
> + * Generated by $(basename "$0").
> + */
> +#ifndef __ASM_CHECKPOINT_HDR_H_
> +#define __ASM_CHECKPOINT_HDR_H_
> +EOFOEOF
> +
> +find "${KERNELSRC}/arch" -name 'checkpoint_hdr.h' -print | sort | \
> +while read ARCH_CHECKPOINT_HDR_H ; do
> +	[ -n "${ARCH_CHECKPOINT_HDR_H}" ] || continue
> +
> +	KARCH=$(echo "${ARCH_CHECKPOINT_HDR_H}" | sed -e 's|.*/arch/\([^/]\+\)/.*|\1|')
> +	CPPARCH="$(karch_to_cpparch "${KARCH}" "")"
> +	cat - <<-EOFOEOF
> +	${ARCH_COND} __${CPPARCH}__
> +	#include <asm-${KARCH}/checkpoint_hdr.h>
> +	EOFOEOF
> +	ARCH_COND='#elif'
> +done
> +
> +cat - <<-FOEOEOF
> +#else
> +#error "Architecture does not have definitons needed for checkpoint images."
> +#endif
> +#endif /* __ASM_CHECKPOINT_HDR_H_ */
> +FOEOEOF
> +
> +) > "${OUTPUT_INCLUDES}/asm/checkpoint_hdr.h"
