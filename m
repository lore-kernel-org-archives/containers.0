From: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v13][PATCH 01/14] Create syscalls: sys_checkpoint,
	sys_restart
Date: Tue, 27 Jan 2009 09:20:10 -0800
Message-ID: <497F424A.7060202__32053.9004555487$1233077063$gmane$org@oracle.com>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1233076092-8660-2-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1233076092-8660-2-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan wrote:
> Changelog[v5]:
>   - Config is 'def_bool n' by default

That's true by default; it doesn't have to be written/typed.


> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  arch/x86/include/asm/unistd_32.h   |    2 +
>  arch/x86/kernel/syscall_table_32.S |    2 +
>  checkpoint/Kconfig                 |   11 +++++++++
>  checkpoint/Makefile                |    5 ++++
>  checkpoint/sys.c                   |   41 ++++++++++++++++++++++++++++++++++++
>  include/linux/syscalls.h           |    2 +
>  init/Kconfig                       |    2 +
>  kernel/sys_ni.c                    |    4 +++
>  8 files changed, 69 insertions(+), 0 deletions(-)
>  create mode 100644 checkpoint/Kconfig
>  create mode 100644 checkpoint/Makefile
>  create mode 100644 checkpoint/sys.c
> 
> diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/unistd_32.h
> index f2bba78..a5f9e09 100644
> --- a/arch/x86/include/asm/unistd_32.h
> +++ b/arch/x86/include/asm/unistd_32.h
> @@ -338,6 +338,8 @@
>  #define __NR_dup3		330
>  #define __NR_pipe2		331
>  #define __NR_inotify_init1	332
> +#define __NR_checkpoint		333
> +#define __NR_restart		334
>  
>  #ifdef __KERNEL__
>  
> diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/syscall_table_32.S
> index d44395f..5543136 100644
> --- a/arch/x86/kernel/syscall_table_32.S
> +++ b/arch/x86/kernel/syscall_table_32.S
> @@ -332,3 +332,5 @@ ENTRY(sys_call_table)
>  	.long sys_dup3			/* 330 */
>  	.long sys_pipe2
>  	.long sys_inotify_init1
> +	.long sys_checkpoint
> +	.long sys_restart

> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> new file mode 100644
> index 0000000..375129c
> --- /dev/null
> +++ b/checkpoint/sys.c
> @@ -0,0 +1,41 @@
> +/*
> + *  Generic container checkpoint-restart
> + *
> + *  Copyright (C) 2008 Oren Laadan
> + *
> + *  This file is subject to the terms and conditions of the GNU General Public
> + *  License.  See the file COPYING in the main directory of the Linux
> + *  distribution for more details.
> + */
> +

#include <linux/syscalls.h>

and then use the new syscall definition macros.
See SYSCALL_DEFINE* in kernel/*.c (current git tree) for examples.

> +#include <linux/sched.h>
> +#include <linux/kernel.h>
> +
> +/**
> + * sys_checkpoint - checkpoint a container
> + * @pid: pid of the container init(1) process
> + * @fd: file to which dump the checkpoint image
> + * @flags: checkpoint operation flags
> + *
> + * Returns positive identifier on success, 0 when returning from restart
> + * or negative value on error
> + */
> +asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
> +{
> +	pr_debug("sys_checkpoint not implemented yet\n");
> +	return -ENOSYS;
> +}
> +/**
> + * sys_restart - restart a container
> + * @crid: checkpoint image identifier
> + * @fd: file from which read the checkpoint image
> + * @flags: restart operation flags
> + *
> + * Returns negative value on error, or otherwise returns in the realm
> + * of the original checkpoint
> + */
> +asmlinkage long sys_restart(int crid, int fd, unsigned long flags)
> +{
> +	pr_debug("sys_restart not implemented yet\n");
> +	return -ENOSYS;
> +}
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index 04fb47b..9750393 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -621,6 +621,8 @@ asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
>  asmlinkage long sys_eventfd(unsigned int count);
>  asmlinkage long sys_eventfd2(unsigned int count, int flags);
>  asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
> +asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags);
> +asmlinkage long sys_restart(int crid, int fd, unsigned long flags);
>  
>  int kernel_execve(const char *filename, char *const argv[], char *const envp[]);
>  
> diff --git a/init/Kconfig b/init/Kconfig
> index f763762..57364fe 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -814,6 +814,8 @@ config MARKERS
>  
>  source "arch/Kconfig"
>  
> +source "checkpoint/Kconfig"
> +
>  endmenu		# General setup
>  
>  config HAVE_GENERIC_DMA_COHERENT
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index e14a232..fcd65cc 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -174,3 +174,7 @@ cond_syscall(compat_sys_timerfd_settime);
>  cond_syscall(compat_sys_timerfd_gettime);
>  cond_syscall(sys_eventfd);
>  cond_syscall(sys_eventfd2);
> +
> +/* checkpoint/restart */
> +cond_syscall(sys_checkpoint);
> +cond_syscall(sys_restart);


-- 
~Randy
