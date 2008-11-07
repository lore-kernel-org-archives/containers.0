From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2/7] proc: Implement support for automounts in task
	directories
Date: Fri, 7 Nov 2008 07:41:18 +0300
Message-ID: <20081107044118.GA21330@x200.localdomain>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org> <m1abcd2kqk.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751608AbYKGEiZ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1abcd2kqk.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Thu, Nov 06, 2008 at 02:48:35AM -0800, Eric W. Biederman wrote:
> --- a/fs/proc/Makefile
> +++ b/fs/proc/Makefile
> @@ -18,6 +18,7 @@ proc-y	+= meminfo.o
>  proc-y	+= stat.o
>  proc-y	+= uptime.o
>  proc-y	+= version.o
> +proc-y	+= automount.o
>  proc-$(CONFIG_PROC_SYSCTL)	+= proc_sysctl.o
>  proc-$(CONFIG_NET)		+= proc_net.o
>  proc-$(CONFIG_PROC_KCORE)	+= kcore.o

> --- a/include/linux/proc_fs.h
> +++ b/include/linux/proc_fs.h
> @@ -101,6 +101,7 @@ extern spinlock_t proc_subdir_lock;
>  
>  extern void proc_root_init(void);
>  
> +void proc_shrink_automounts(void);
>  void proc_flush_task(struct task_struct *task);
>  struct dentry *proc_pid_lookup(struct inode *dir, struct dentry * dentry, struct nameidata *);
>  int proc_pid_readdir(struct file * filp, void * dirent, filldir_t filldir);
> diff --git a/kernel/exit.c b/kernel/exit.c
> index 80137a5..8a8badb 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -161,6 +161,7 @@ void release_task(struct task_struct * p)
>  repeat:
>  	tracehook_prepare_release_task(p);
>  	atomic_dec(&p->user->processes);
> +	proc_shrink_automounts();

This, of course, won't compile when PROC_FS=n.
