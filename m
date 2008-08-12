From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 3/5] Container Freezer: Implement freezer cgroup subsystem
Date: Tue, 12 Aug 2008 15:56:10 -0700
Message-ID: <20080812155610.f4d40bb1.akpm__48649.3103825071$1218582115$gmane$org@linux-foundation.org>
References: <20080811235323.872291138@us.ibm.com>
	<20080811235325.121356317@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080811235325.121356317-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 11 Aug 2008 16:53:26 -0700
Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> This patch implements a new freezer subsystem in the control groups framework.
> It provides a way to stop and resume execution of all tasks in a cgroup by
> writing in the cgroup filesystem.
> 
> The freezer subsystem in the container filesystem defines a file named
> freezer.state. Writing "FROZEN" to the state file will freeze all tasks in the
> cgroup. Subsequently writing "RUNNING" will unfreeze the tasks in the cgroup.
> Reading will return the current state.
> 
> * Examples of usage :
> 
>    # mkdir /containers/freezer
>    # mount -t cgroup -ofreezer freezer  /containers
>    # mkdir /containers/0
>    # echo $some_pid > /containers/0/tasks
> 
> to get status of the freezer subsystem :
> 
>    # cat /containers/0/freezer.state
>    RUNNING
> 
> to freeze all tasks in the container :
> 
>    # echo FROZEN > /containers/0/freezer.state
>    # cat /containers/0/freezer.state
>    FREEZING
>    # cat /containers/0/freezer.state
>    FROZEN
> 
> to unfreeze all tasks in the container :
> 
>    # echo RUNNING > /containers/0/freezer.state
>    # cat /containers/0/freezer.state
>    RUNNING
> 
> This is the basic mechanism which should do the right thing for user space task
> in a simple scenario.
> 
> It's important to note that freezing can be incomplete. In that case we return
> EBUSY. This means that some tasks in the cgroup are busy doing something that
> prevents us from completely freezing the cgroup at this time. After EBUSY,
> the cgroup will remain partially frozen -- reflected by freezer.state reporting
> "FREEZING" when read. The state will remain "FREEZING" until one of these
> things happens:
> 
> 	1) Userspace cancels the freezing operation by writing "RUNNING" to
> 		the freezer.state file
> 	2) Userspace retries the freezing operation by writing "FROZEN" to
> 		the freezer.state file (writing "FREEZING" is not legal
> 		and returns EIO)
> 	3) The tasks that blocked the cgroup from entering the "FROZEN"
> 		state disappear from the cgroup's set of tasks.
> 
> ...

Is a Documentation/ update planned?  Documentation/cgroups.txt might be
the place, or not.

> +
> +#ifdef CONFIG_CGROUP_FREEZER
> +SUBSYS(freezer)
> +#endif
> +
> +/* */
> Index: linux-2.6.27-rc1-mm1/include/linux/freezer.h
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/include/linux/freezer.h
> +++ linux-2.6.27-rc1-mm1/include/linux/freezer.h
> @@ -47,22 +47,30 @@ static inline bool should_send_signal(st
>  /*
>   * Wake up a frozen process
>   *
> - * task_lock() is taken to prevent the race with refrigerator() which may
> + * task_lock() is needed to prevent the race with refrigerator() which may
>   * occur if the freezing of tasks fails.  Namely, without the lock, if the
>   * freezing of tasks failed, thaw_tasks() might have run before a task in
>   * refrigerator() could call frozen_process(), in which case the task would be
>   * frozen and no one would thaw it.
>   */
> -static inline int thaw_process(struct task_struct *p)
> +static inline int __thaw_process(struct task_struct *p)
>  {
> -	task_lock(p);
>  	if (frozen(p)) {
>  		p->flags &= ~PF_FROZEN;
> +		return 1;
> +	}
> +	clear_freeze_flag(p);
> +	return 0;
> +}
> +
> +static inline int thaw_process(struct task_struct *p)
> +{
> +	task_lock(p);
> +	if (__thaw_process(p) == 1) {
>  		task_unlock(p);
>  		wake_up_process(p);
>  		return 1;
>  	}
> -	clear_freeze_flag(p);
>  	task_unlock(p);
>  	return 0;
>  }

I wonder why these are inlined.

> @@ -83,6 +91,12 @@ static inline int try_to_freeze(void)
>  extern bool freeze_task(struct task_struct *p, bool sig_only);
>  extern void cancel_freezing(struct task_struct *p);
>  
> +#ifdef CONFIG_CGROUP_FREEZER
> +extern int cgroup_frozen(struct task_struct *task);
> +#else /* !CONFIG_CGROUP_FREEZER */
> +static inline int cgroup_frozen(struct task_struct *task) { return 0; }
> +#endif /* !CONFIG_CGROUP_FREEZER */
> +
>  /*
>   * The PF_FREEZER_SKIP flag should be set by a vfork parent right before it
>   * calls wait_for_completion(&vfork) and reset right after it returns from this
> Index: linux-2.6.27-rc1-mm1/init/Kconfig
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/init/Kconfig
> +++ linux-2.6.27-rc1-mm1/init/Kconfig
> @@ -299,6 +299,13 @@ config CGROUP_NS
>            for instance virtual servers and checkpoint/restart
>            jobs.
>  
> +config CGROUP_FREEZER
> +        bool "control group freezer subsystem"
> +        depends on CGROUPS

Should it depend on FREEZER also?

oh,

> --- linux-2.6.27-rc1-mm1.orig/kernel/power/Kconfig
> +++ linux-2.6.27-rc1-mm1/kernel/power/Kconfig
> @@ -86,7 +86,7 @@ config PM_SLEEP
>  	default y
>  
>  config FREEZER
> -	def_bool PM_SLEEP
> +	def_bool PM_SLEEP || CGROUP_FREEZER
>  

we did it that way.  Spose that makes sense.

> +        help
> +          Provides a way to freeze and unfreeze all tasks in a
> +	  cgroup.
> +
>  config CGROUP_DEVICE
>  	bool "Device controller for cgroups"
>  	depends on CGROUPS && EXPERIMENTAL
> Index: linux-2.6.27-rc1-mm1/kernel/Makefile
> ===================================================================
> --- linux-2.6.27-rc1-mm1.orig/kernel/Makefile
> +++ linux-2.6.27-rc1-mm1/kernel/Makefile
> @@ -54,6 +54,7 @@ obj-$(CONFIG_KEXEC) += kexec.o
>  obj-$(CONFIG_COMPAT) += compat.o
>  obj-$(CONFIG_CGROUPS) += cgroup.o
>  obj-$(CONFIG_CGROUP_DEBUG) += cgroup_debug.o
> +obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
>  obj-$(CONFIG_CPUSETS) += cpuset.o
>  obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
>  obj-$(CONFIG_UTS_NS) += utsname.o
> Index: linux-2.6.27-rc1-mm1/kernel/cgroup_freezer.c
> ===================================================================
> --- /dev/null
> +++ linux-2.6.27-rc1-mm1/kernel/cgroup_freezer.c
> @@ -0,0 +1,366 @@
> +/*
> + * cgroup_freezer.c -  control group freezer subsystem
> + *
> + * Copyright IBM Corporation, 2007
> + *
> + * Author : Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of version 2.1 of the GNU Lesser General Public License
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it would be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
> + */
> +
> +#include <linux/module.h>
> +#include <linux/cgroup.h>
> +#include <linux/fs.h>
> +#include <linux/uaccess.h>
> +#include <linux/freezer.h>
> +#include <linux/seq_file.h>
> +
> +enum freezer_state {
> +	STATE_RUNNING = 0,

That's a pretty vanilla-sounding identifier.  Let's hope this file
never ends up including drivers/net/sfc/net_driver.h by some means. 
That's rather unlikely, but someone could easily choose to implement a
new STATE_RUNNING somewhere else.

> +	STATE_FREEZING,
> +	STATE_FROZEN,
> +};
> +
> +struct freezer {
> +	struct cgroup_subsys_state css;
> +	enum freezer_state state;
> +	spinlock_t lock; /* protects _writes_ to state */
> +};
> +
> +static inline struct freezer *cgroup_freezer(
> +		struct cgroup *cgroup)
> +{
> +	return container_of(
> +		cgroup_subsys_state(cgroup, freezer_subsys_id),
> +		struct freezer, css);
> +}
> +
> +static inline struct freezer *task_freezer(struct task_struct *task)
> +{
> +	return container_of(task_subsys_state(task, freezer_subsys_id),
> +			    struct freezer, css);
> +}
> +
> +int cgroup_frozen(struct task_struct *task)
> +{
> +	struct freezer *freezer;
> +	enum freezer_state state;
> +
> +	task_lock(task);
> +	freezer = task_freezer(task);
> +	state = freezer->state;
> +	task_unlock(task);
> +
> +	return state == STATE_FROZEN;
> +}
> +
> +/*
> + * Buffer size for freezer state is limited by cgroups write_string()
> + * interface. See cgroups code for the current size.
> + */

Is this comment in the correct place?

> +static const char *freezer_state_strs[] = {
> +	"RUNNING",
> +	"FREEZING",
> +	"FROZEN",
> +};
> +
>
> ...
>
> +
> +/*
> + * caller must hold freezer->lock
> + */
> +static void check_if_frozen(struct cgroup *cgroup,
> +			     struct freezer *freezer)

check_if_frozen() is an unfortunate name, I suspect.  Normally one
would expect a check_foo() to return a bool and have no side-effects.

Perhaps some comments explaining what it does would help.

> +{
> +	struct cgroup_iter it;
> +	struct task_struct *task;
> +	unsigned int nfrozen = 0, ntotal = 0;
> +
> +	cgroup_iter_start(cgroup, &it);
> +	while ((task = cgroup_iter_next(cgroup, &it))) {
> +		ntotal++;
> +		/*
> +		 * Task is frozen or will freeze immediately when next it gets
> +		 * woken
> +		 */
> +		if (frozen(task) ||
> +		    (task_is_stopped_or_traced(task) && freezing(task)))
> +			nfrozen++;
> +	}
> +
> +	/*
> +	 * Transition to FROZEN when no new tasks can be added ensures
> +	 * that we never exist in the FROZEN state while there are unfrozen
> +	 * tasks.
> +	 */
> +	if (nfrozen == ntotal)
> +		freezer->state = STATE_FROZEN;
> +	cgroup_iter_end(cgroup, &it);
> +}
> +
>
> ...
>
> +static int freezer_write(struct cgroup *cgroup,
> +			 struct cftype *cft,
> +			 const char *buffer)
> +{
> +	int retval;
> +	enum freezer_state goal_state;
> +
> +	if (strcmp(buffer, freezer_state_strs[STATE_RUNNING]) == 0)

Did some higher-level code take care of removing the trailing \n?

> +		goal_state = STATE_RUNNING;
> +	else if (strcmp(buffer, freezer_state_strs[STATE_FROZEN]) == 0)
> +		goal_state = STATE_FROZEN;
> +	else
> +		return -EIO;
> +
> +	if (!cgroup_lock_live_group(cgroup))
> +		return -ENODEV;
> +	retval = freezer_change_state(cgroup, goal_state);
> +	cgroup_unlock();
> +	return retval;
> +}
> +
>
> ...
>
