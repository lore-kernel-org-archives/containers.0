From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH, v3 2/2] cgroups: introduce timer slack subsystem
Date: Thu, 3 Feb 2011 11:41:38 +0200
Message-ID: <20110203094138.GD1083__17609.5665352934$1296726140$gmane$org@shutemov.name>
References: <1296679656-31163-1-git-send-email-kirill@shutemov.name>
	<1296679656-31163-3-git-send-email-kirill@shutemov.name>
	<20110203054616.GT16432@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110203054616.GT16432-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
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
Cc: jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Feb 02, 2011 at 09:46:16PM -0800, Matt Helsley wrote:
> On Wed, Feb 02, 2011 at 10:47:36PM +0200, Kirill A. Shutsemov wrote:
> > From: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> > 
> > Provides a way of tasks grouping by timer slack value. Introduces per
> > cgroup max and min timer slack value. When a task attaches to a cgroup,
> > its timer slack value adjusts (if needed) to fit min-max range.
> > 
> > It also provides a way to set timer slack value for all tasks in the
> > cgroup at once.
> > 
> > This functionality is useful in mobile devices where certain background
> > apps are attached to a cgroup and minimum wakeups are desired.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
> > Idea-by: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> > ---
> >  include/linux/cgroup_subsys.h |    6 +
> >  include/linux/init_task.h     |    4 +-
> >  init/Kconfig                  |   10 ++
> >  kernel/Makefile               |    1 +
> >  kernel/cgroup_timer_slack.c   |  242 +++++++++++++++++++++++++++++++++++++++++
> >  kernel/sys.c                  |   24 +++-
> >  6 files changed, 280 insertions(+), 7 deletions(-)
> >  create mode 100644 kernel/cgroup_timer_slack.c
> > 
> > diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
> > index ccefff0..e399228 100644
> > --- a/include/linux/cgroup_subsys.h
> > +++ b/include/linux/cgroup_subsys.h
> > @@ -66,3 +66,9 @@ SUBSYS(blkio)
> >  #endif
> > 
> >  /* */
> > +
> > +#ifdef CONFIG_CGROUP_TIMER_SLACK
> > +SUBSYS(timer_slack)
> > +#endif
> > +
> > +/* */
> > diff --git a/include/linux/init_task.h b/include/linux/init_task.h
> > index caa151f..48eca8f 100644
> > --- a/include/linux/init_task.h
> > +++ b/include/linux/init_task.h
> > @@ -124,6 +124,8 @@ extern struct cred init_cred;
> >  # define INIT_PERF_EVENTS(tsk)
> >  #endif
> > 
> > +#define TIMER_SLACK_NS_DEFAULT 50000
> > +
> >  /*
> >   *  INIT_TASK is used to set up the first task table, touch at
> >   * your own risk!. Base=0, limit=0x1fffff (=2MB)
> > @@ -177,7 +179,7 @@ extern struct cred init_cred;
> >  	.cpu_timers	= INIT_CPU_TIMERS(tsk.cpu_timers),		\
> >  	.fs_excl	= ATOMIC_INIT(0),				\
> >  	.pi_lock	= __RAW_SPIN_LOCK_UNLOCKED(tsk.pi_lock),	\
> > -	.timer_slack_ns = 50000, /* 50 usec default slack */		\
> > +	.timer_slack_ns = TIMER_SLACK_NS_DEFAULT,			\
> >  	.pids = {							\
> >  		[PIDTYPE_PID]  = INIT_PID_LINK(PIDTYPE_PID),		\
> >  		[PIDTYPE_PGID] = INIT_PID_LINK(PIDTYPE_PGID),		\
> > diff --git a/init/Kconfig b/init/Kconfig
> > index be788c0..f21b4ce 100644
> > --- a/init/Kconfig
> > +++ b/init/Kconfig
> > @@ -596,6 +596,16 @@ config CGROUP_FREEZER
> >  	  Provides a way to freeze and unfreeze all tasks in a
> >  	  cgroup.
> > 
> > +config CGROUP_TIMER_SLACK
> > +	tristate "Timer slack cgroup subsystem"
> > +	help
> > +	  Provides a way of tasks grouping by timer slack value.
> > +	  Introduces per cgroup timer slack value which will override
> > +	  the default timer slack value once a task is attached to a
> > +	  cgroup.
> > +	  It's useful in mobile devices where certain background apps
> > +	  are attached to a cgroup and minimum wakeups are desired.
> 
> Again -- I don't think "minimum" is the right choice of words here.

Ok, I'll fix it.

> > +
> >  config CGROUP_DEVICE
> >  	bool "Device controller for cgroups"
> >  	help
> > diff --git a/kernel/Makefile b/kernel/Makefile
> > index 353d3fe..0b60239 100644
> > --- a/kernel/Makefile
> > +++ b/kernel/Makefile
> > @@ -61,6 +61,7 @@ obj-$(CONFIG_BACKTRACE_SELF_TEST) += backtracetest.o
> >  obj-$(CONFIG_COMPAT) += compat.o
> >  obj-$(CONFIG_CGROUPS) += cgroup.o
> >  obj-$(CONFIG_CGROUP_FREEZER) += cgroup_freezer.o
> > +obj-$(CONFIG_CGROUP_TIMER_SLACK) += cgroup_timer_slack.o
> >  obj-$(CONFIG_CPUSETS) += cpuset.o
> >  obj-$(CONFIG_CGROUP_NS) += ns_cgroup.o
> >  obj-$(CONFIG_UTS_NS) += utsname.o
> > diff --git a/kernel/cgroup_timer_slack.c b/kernel/cgroup_timer_slack.c
> > new file mode 100644
> > index 0000000..a343a50
> > --- /dev/null
> > +++ b/kernel/cgroup_timer_slack.c
> > @@ -0,0 +1,242 @@
> > +/*
> > + * cgroup_timer_slack.c - control group timer slack subsystem
> > + *
> > + * Copyright Nokia Corparation, 2011
> > + * Author: Kirill A. Shutemov
> > + *
> > + * This program is free software; you can redistribute it and/or modify
> > + * it under the terms of the GNU General Public License as published by
> > + * the Free Software Foundation; either version 2 of the License, or
> > + * (at your option) any later version.
> > + *
> > + * This program is distributed in the hope that it will be useful,
> > + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> > + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > + * GNU General Public License for more details.
> > + */
> > +#include <linux/cgroup.h>
> > +#include <linux/init_task.h>
> > +#include <linux/module.h>
> > +#include <linux/slab.h>
> > +
> > +struct cgroup_subsys timer_slack_subsys;
> > +struct timer_slack_cgroup {
> > +	struct cgroup_subsys_state css;
> > +	unsigned long min_slack_ns;
> > +	unsigned long max_slack_ns;
> > +};
> > +
> > +enum {
> > +	TIMER_SLACK_MIN,
> > +	TIMER_SLACK_MAX,
> > +};
> > +
> > +int dummy_timer_slack_check(struct task_struct *task, unsigned long slack_ns);
> 
> The above should be "extern" shouldn't it? Also, I think there's a way
> to eliminate it (more below).
> 
> > +extern int (*timer_slack_check)(struct task_struct *task,
> > +		unsigned long slack_ns);
> > +
> > +static struct timer_slack_cgroup *cgroup_to_tslack_cgroup(struct cgroup *cgroup)
> > +{
> > +	struct cgroup_subsys_state *css;
> > +
> > +	css = cgroup_subsys_state(cgroup, timer_slack_subsys.subsys_id);
> > +	return container_of(css, struct timer_slack_cgroup, css);
> > +}
> > +
> > +static int cgroup_timer_slack_check(struct task_struct *task,
> > +		unsigned long slack_ns)
> 
> nit: rename to cgroup_timer_slack_allowed() ?

cgroup_is_timer_slack_allowed() ?

> > +{
> > +	struct cgroup_subsys_state *css;
> > +	struct timer_slack_cgroup *tslack_cgroup;
> > +
> > +	css = task_subsys_state(task, timer_slack_subsys.subsys_id);
> > +	tslack_cgroup = container_of(css, struct timer_slack_cgroup, css);
> > +
> > +	if (slack_ns < tslack_cgroup->min_slack_ns)
> > +		return -EPERM;
> > +	if (slack_ns > tslack_cgroup->max_slack_ns)
> > +		return -EPERM;
> > +	return 0;
> > +}
> > +
> > +static struct cgroup_subsys_state *
> > +tslack_cgroup_create(struct cgroup_subsys *subsys, struct cgroup *cgroup)
> > +{
> > +	struct timer_slack_cgroup *tslack_cgroup;
> > +
> > +	tslack_cgroup = kmalloc(sizeof(*tslack_cgroup), GFP_KERNEL);
> > +	if (!tslack_cgroup)
> > +		return ERR_PTR(-ENOMEM);
> > +
> > +	if (cgroup->parent) {
> > +		struct timer_slack_cgroup *parent;
> > +		parent = cgroup_to_tslack_cgroup(cgroup->parent);
> > +		tslack_cgroup->min_slack_ns = parent->min_slack_ns;
> > +		tslack_cgroup->max_slack_ns = parent->max_slack_ns;
> > +	} else {
> > +		tslack_cgroup->min_slack_ns = 0UL;
> > +		tslack_cgroup->max_slack_ns = ULONG_MAX;
> > +	}
> > +
> > +	return &tslack_cgroup->css;
> > +}
> > +
> > +static void tslack_cgroup_destroy(struct cgroup_subsys *subsys,
> > +		struct cgroup *cgroup)
> > +{
> > +	kfree(cgroup_to_tslack_cgroup(cgroup));
> > +}
> > +
> > +/*
> > + * Adjust ->timer_slack_ns and ->default_max_slack_ns of the task to fit
> > + * limits of the cgroup.
> > + */
> > +static void tslack_adjust_task(struct timer_slack_cgroup *tslack_cgroup,
> > +		struct task_struct *tsk)
> > +{
> > +	if (tslack_cgroup->min_slack_ns > tsk->timer_slack_ns)
> > +		tsk->timer_slack_ns = tslack_cgroup->min_slack_ns;
> > +	else if (tslack_cgroup->max_slack_ns < tsk->timer_slack_ns)
> > +		tsk->timer_slack_ns = tslack_cgroup->max_slack_ns;
> > +
> > +	if (tslack_cgroup->min_slack_ns > tsk->default_timer_slack_ns)
> > +		tsk->default_timer_slack_ns = tslack_cgroup->min_slack_ns;
> > +	else if (tslack_cgroup->max_slack_ns < tsk->default_timer_slack_ns)
> > +		tsk->default_timer_slack_ns = tslack_cgroup->max_slack_ns;
> > +}
> > +
> > +static void tslack_cgroup_attach(struct cgroup_subsys *subsys,
> > +		struct cgroup *cgroup, struct cgroup *prev,
> > +		struct task_struct *tsk, bool threadgroup)
> > +{
> > +	tslack_adjust_task(cgroup_to_tslack_cgroup(cgroup), tsk);
> > +}
> > +
> > +static int tslack_write_set_slack_ns(struct cgroup *cgroup, struct cftype *cft,
> > +		u64 val)
> > +{
> > +	struct timer_slack_cgroup *tslack_cgroup;
> > +	struct cgroup_iter it;
> > +	struct task_struct *task;
> > +
> > +	tslack_cgroup = cgroup_to_tslack_cgroup(cgroup);
> > +	if (!val || val < tslack_cgroup->min_slack_ns ||
> 
> Why is a val of 0 disallowed? I know having slack is good, but for
> an administrator or tool that doesn't care about number of wakeups
> and cares more about wringing out performance a slack of
> 0 seems acceptable. Is this just here to be consistent with the
> values passed in via prctl?

Yes, it's to consistent with the prctl(). I don't think that it's good
idea to allow to set timer_slack outside of range prctl() allows. It may
lead to interface abuse.

> > +			val > tslack_cgroup->max_slack_ns )
> > +		return -EINVAL;
> 
> Shouldn't it be EPERM and not EINVAL?
> 
> The write(2) man page says: "Other errors may occur, depending on the
> object connected to fd." So I think EPERM is fine and more descriptive.

What do you think about -EINVAL for (val == 0) and -EPERM for rest?

> > +
> > +	/* Change timer slack value for all tasks in the cgroup */
> > +	cgroup_iter_start(cgroup, &it);
> > +	while ((task = cgroup_iter_next(cgroup, &it)))
> > +		task->timer_slack_ns = val;
> > +	cgroup_iter_end(cgroup, &it);
> > +
> > +	return 0;
> > +}
> > +
> > +static u64 tslack_read_range(struct cgroup *cgroup, struct cftype *cft)
> > +{
> > +	struct timer_slack_cgroup *tslack_cgroup;
> > +
> > +	tslack_cgroup = cgroup_to_tslack_cgroup(cgroup);
> > +	switch (cft->private) {
> > +	case TIMER_SLACK_MIN:
> > +		return tslack_cgroup->min_slack_ns;
> > +	case TIMER_SLACK_MAX:
> > +		return tslack_cgroup->max_slack_ns;
> > +	default:
> > +		BUG();
> > +	};
> > +}
> > +
> > +static int tslack_write_range(struct cgroup *cgroup, struct cftype *cft,
> > +		u64 val)
> > +{
> > +	struct timer_slack_cgroup *tslack_cgroup;
> > +	struct cgroup_iter it;
> > +	struct task_struct *task;
> > +
> > +	if (!val)
> > +		return -EINVAL;
> 
> Same question re: 0 slack...
> 
> > +
> > +	tslack_cgroup = cgroup_to_tslack_cgroup(cgroup);
> > +	switch (cft->private) {
> > +	case TIMER_SLACK_MIN:
> > +		if (val > tslack_cgroup->max_slack_ns)
> > +			return -EINVAL;
> > +		tslack_cgroup->min_slack_ns = val;
> > +		break;
> > +	case TIMER_SLACK_MAX:
> > +		if (val < tslack_cgroup->min_slack_ns)
> > +			return -EINVAL;
> > +		tslack_cgroup->max_slack_ns = val;
> > +		break;
> > +	default:
> > +		BUG();
> > +	}
> > +
> > +	/*
> > +	 * Adjust timer slack value for all tasks in the cgroup to fit
> > +	 * min-max range.
> > +	 */
> > +	cgroup_iter_start(cgroup, &it);
> > +	while ((task = cgroup_iter_next(cgroup, &it)))
> > +		tslack_adjust_task(tslack_cgroup, task);
> > +	cgroup_iter_end(cgroup, &it);
> > +
> > +	return 0;
> > +}
> > +
> > +static struct cftype files[] = {
> > +	{
> > +		.name = "set_slack_ns",
> > +		.write_u64 = tslack_write_set_slack_ns,
> > +	},
> > +	{
> > +		.name = "min_slack_ns",
> > +		.private = TIMER_SLACK_MIN,
> > +		.read_u64 = tslack_read_range,
> > +		.write_u64 = tslack_write_range,
> > +	},
> > +	{
> > +		.name = "max_slack_ns",
> > +		.private = TIMER_SLACK_MAX,
> > +		.read_u64 = tslack_read_range,
> > +		.write_u64 = tslack_write_range,
> > +	},
> > +};
> 
> Looks good, thanks!
> 
> > +
> > +static int tslack_cgroup_populate(struct cgroup_subsys *subsys,
> > +		struct cgroup *cgroup)
> > +{
> > +	return cgroup_add_files(cgroup, subsys, files, ARRAY_SIZE(files));
> > +}
> > +
> > +struct cgroup_subsys timer_slack_subsys = {
> > +	.name = "timer_slack",
> > +	.module = THIS_MODULE,
> > +#ifdef CONFIG_CGROUP_TIMER_SLACK
> > +	.subsys_id = timer_slack_subsys_id,
> > +#endif
> 
> Uhh... why is the #ifdef necessary? Won't it always be true if we're
> compiling this file?

Try to compile it as module. ;)

> > +	.create = tslack_cgroup_create,
> > +	.destroy = tslack_cgroup_destroy,
> > +	.attach = tslack_cgroup_attach,
> > +	.populate = tslack_cgroup_populate,
> > +};
> > +
> > +static int __init init_cgroup_timer_slack(void)
> > +{
> > +	BUG_ON(timer_slack_check != dummy_timer_slack_check);
> 
> You could just save the old timer_slack_check value into a static pointer
> and then restore it in exit_cgroup_timer_slack. That would eliminate the
> need for one of the two EXPORTs below but you wouldn't be able to do this
> BUG_ON check. I think that'd be a slight improvement.
> 
> > +	timer_slack_check = cgroup_timer_slack_check;
> > +	return cgroup_load_subsys(&timer_slack_subsys);
> 
> Shouldn't you load the subsystem first then set the timer_slack_check
> function pointer once you know that the load has succeeded?

I'll rework this part.

Thanks for reviewing.

-- 
 Kirill A. Shutemov
