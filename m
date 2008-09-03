From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/9] Make checkpoint/restart functionality modular
Date: Wed, 3 Sep 2008 09:27:20 -0500
Message-ID: <20080903142720.GC13425__28174.3917883889$1220452411$gmane$org@us.ibm.com>
References: <1220439476-16465-1-git-send-email-major@openvz.org>
	<1220439476-16465-2-git-send-email-major@openvz.org>
	<1220439476-16465-3-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1220439476-16465-3-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Andrey Mirkin (major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> A config option CONFIG_CHECKPOINT is introduced.
> New structure cpt_operations is introduced to store pointers to
> checkpoint/restart functions from module.

Thanks Andrey.  The structure of this patchset is very nice, and I'm
finding it very easy to read, at least the first half.

The differences (in yours and Oren's) between checkpointing and
restarting yourself or another task should probably not be important
as people will want to be able to do both in the end, and I'm sure
both patchsets can do both.  And you have things like your own
printk helpers in patch 3 that, just as in Oren's set, will have to
go away.  But I'm not yet able to see what the real differences are.

Keeping on looking...

> Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> ---
>  cpt/Kconfig    |    7 +++++++
>  cpt/Makefile   |    4 ++++
>  cpt/cpt.h      |   19 +++++++++++++++++++
>  cpt/sys.c      |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
>  cpt/sys_core.c |   29 +++++++++++++++++++++++++++--
>  init/Kconfig   |    2 ++
>  6 files changed, 107 insertions(+), 2 deletions(-)
>  create mode 100644 cpt/Kconfig
>  create mode 100644 cpt/cpt.h
>  create mode 100644 cpt/sys.c
> 
> diff --git a/cpt/Kconfig b/cpt/Kconfig
> new file mode 100644
> index 0000000..b9bc72d
> --- /dev/null
> +++ b/cpt/Kconfig
> @@ -0,0 +1,7 @@
> +config CHECKPOINT
> +	tristate "Checkpoint & restart for containers"
> +	depends on EXPERIMENTAL
> +	default n
> +	help
> +	  This option adds module "cptrst", which allow to save a running
> +	  container to a file and restart it later using this image file.
> diff --git a/cpt/Makefile b/cpt/Makefile
> index 2276fb1..bfe75d5 100644
> --- a/cpt/Makefile
> +++ b/cpt/Makefile
> @@ -1 +1,5 @@
>  obj-y += sys_core.o
> +
> +obj-$(CONFIG_CHECKPOINT) += cptrst.o
> +
> +cptrst-objs := sys.o
> diff --git a/cpt/cpt.h b/cpt/cpt.h
> new file mode 100644
> index 0000000..381a9bf
> --- /dev/null
> +++ b/cpt/cpt.h
> @@ -0,0 +1,19 @@
> +/*
> + *  Copyright (C) 2008 Parallels, Inc.
> + *
> + *  Author: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> + *
> + *  This program is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU General Public License as
> + *  published by the Free Software Foundation, version 2 of the
> + *  License.
> + *
> + */
> +
> +struct cpt_operations
> +{
> +	struct module * owner;
> +	int (*checkpoint)(pid_t pid, int fd, unsigned long flags);
> +	int (*restart)(int ctid, int fd, unsigned long flags);
> +};
> +extern struct cpt_operations cpt_ops;
> diff --git a/cpt/sys.c b/cpt/sys.c
> new file mode 100644
> index 0000000..4051286
> --- /dev/null
> +++ b/cpt/sys.c
> @@ -0,0 +1,48 @@
> +/*
> + *  Copyright (C) 2008 Parallels, Inc.
> + *
> + *  Author: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> + *
> + *  This program is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU General Public License as
> + *  published by the Free Software Foundation, version 2 of the
> + *  License.
> + *
> + */
> +
> +#include <linux/sched.h>
> +#include <linux/fs.h>
> +#include <linux/file.h>
> +#include <linux/notifier.h>
> +#include <linux/module.h>
> +
> +#include "cpt.h"
> +
> +MODULE_LICENSE("GPL");
> +
> +static int checkpoint(pid_t pid, int fd, unsigned long flags)
> +{
> +	return -ENOSYS; 
> +}
> +
> +static int restart(int ctid, int fd, unsigned long flags)
> +{
> +	return -ENOSYS; 
> +}
> +
> +static int __init init_cptrst(void)
> +{
> +	cpt_ops.owner = THIS_MODULE;
> +	cpt_ops.checkpoint = checkpoint;
> +	cpt_ops.restart = restart;
> +	return 0;
> +}
> +module_init(init_cptrst);
> +
> +static void __exit exit_cptrst(void)
> +{
> +	cpt_ops.checkpoint = NULL;
> +	cpt_ops.restart = NULL;
> +	cpt_ops.owner = NULL;
> +}
> +module_exit(exit_cptrst);
> diff --git a/cpt/sys_core.c b/cpt/sys_core.c
> index 1a97fb6..5dd1191 100644
> --- a/cpt/sys_core.c
> +++ b/cpt/sys_core.c
> @@ -13,6 +13,13 @@
>  #include <linux/sched.h>
>  #include <linux/fs.h>
>  #include <linux/file.h>
> +#include <linux/notifier.h>
> +#include <linux/module.h>
> +
> +#include "cpt.h"
> +
> +struct cpt_operations cpt_ops = { NULL, NULL, NULL };
> +EXPORT_SYMBOL(cpt_ops);
> 
>  /**
>   * sys_checkpoint - checkpoint a container from outside
> @@ -23,7 +30,16 @@
>   */
>  asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
>  {
> -	return -ENOSYS;
> +	int ret;
> +
> +	ret = -ENOSYS;
> +
> +	if (try_module_get(cpt_ops.owner)) {
> +		if (cpt_ops.checkpoint)
> +			ret = cpt_ops.checkpoint(pid, fd, flags);
> +		module_put(cpt_ops.owner);
> +	}
> +	return ret;
>  }
> 
>  /**
> @@ -34,5 +50,14 @@ asmlinkage long sys_checkpoint(pid_t pid, int fd, unsigned long flags)
>   */
>  asmlinkage long sys_restart(int ctid, int fd, unsigned long flags)
>  {
> -	return -ENOSYS;
> +	int ret;
> +
> +	ret = -ENOSYS;
> +
> +	if (try_module_get(cpt_ops.owner)) {
> +		if (cpt_ops.restart)
> +			ret = cpt_ops.restart(ctid, fd, flags);
> +		module_put(cpt_ops.owner);
> +	}
> +	return ret;
>  }
> diff --git a/init/Kconfig b/init/Kconfig
> index 4bd4b0c..d29ed21 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -344,6 +344,8 @@ config CGROUP_FREEZER
>            Provides a way to freeze and unfreeze all tasks in a
>  	  cgroup
> 
> +source "cpt/Kconfig"
> +	  
>  config FAIR_GROUP_SCHED
>  	bool "Group scheduling for SCHED_OTHER"
>  	depends on GROUP_SCHED
> -- 
> 1.5.6
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
