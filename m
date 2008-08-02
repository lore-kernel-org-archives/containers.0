From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/6] Container Freezer: Implement freezer cgroup subsystem
Date: Fri, 01 Aug 2008 17:11:31 -0700
Message-ID: <1217635891.25300.292.camel__4678.81167210198$1217636015$gmane$org@localhost.localdomain>
References: <20080801050659.924495279@us.ibm.com>
	<20080801050700.797996261@us.ibm.com> <200808020058.37407.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <200808020058.37407.rjw-KKrjLPT3xs0@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux-Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


On Sat, 2008-08-02 at 00:58 +0200, Rafael J. Wysocki wrote:
> On Friday, 1 of August 2008, Matt Helsley wrote:
> > This patch implements a new freezer subsystem in the control groups framework.
> > It provides a way to stop and resume execution of all tasks in a cgroup by
> > writing in the cgroup filesystem.
> > 
> > The freezer subsystem in the container filesystem defines a file named
> > freezer.state. Writing "FROZEN" to the state file will freeze all tasks in the
> > cgroup. Subsequently writing "RUNNING" will unfreeze the tasks in the cgroup.
> > Reading will return the current state.
> > 
> > * Examples of usage :
> > 
> >    # mkdir /containers/freezer
> >    # mount -t cgroup -ofreezer freezer  /containers
> >    # mkdir /containers/0
> >    # echo $some_pid > /containers/0/tasks
> > 
> > to get status of the freezer subsystem :
> > 
> >    # cat /containers/0/freezer.state
> >    RUNNING
> > 
> > to freeze all tasks in the container :
> > 
> >    # echo FROZEN > /containers/0/freezer.state
> >    # cat /containers/0/freezer.state
> >    FREEZING
> >    # cat /containers/0/freezer.state
> >    FROZEN
> > 
> > to unfreeze all tasks in the container :
> > 
> >    # echo RUNNING > /containers/0/freezer.state
> >    # cat /containers/0/freezer.state
> >    RUNNING
> > 
> > This is the basic mechanism which should do the right thing for user space task
> > in a simple scenario.
> > 
> > It's important to note that freezing can be incomplete. In that case we return
> > EBUSY. This means that some tasks in the cgroup are busy doing something that
> > prevents us from completely freezing the cgroup at this time. After EBUSY,
> > the cgroup will remain partially frozen -- reflected by freezer.state reporting
> > "FREEZING" when read. The state will remain "FREEZING" until one of these
> > things happens:
> > 
> > 	1) Userspace cancels the freezing operation by writing "RUNNING" to
> > 		the freezer.state file
> > 	2) Userspace retries the freezing operation by writing "FROZEN" to
> > 		the freezer.state file (writing "FREEZING" is not legal
> > 		and returns EIO)
> > 	3) The tasks that blocked the cgroup from entering the "FROZEN"
> > 		state disappear from the cgroup's set of tasks.
> > 
> > Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> > Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > Acked-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > Tested-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > ---
> >  include/linux/cgroup_freezer.h |   71 ++++++++
> >  include/linux/cgroup_subsys.h  |    6 
> >  include/linux/freezer.h        |   16 +-
> >  init/Kconfig                   |    7 
> >  kernel/Makefile                |    1 
> >  kernel/cgroup_freezer.c        |  328 +++++++++++++++++++++++++++++++++++++++++
> >  6 files changed, 425 insertions(+), 4 deletions(-)
> >  create mode 100644 include/linux/cgroup_freezer.h
> >  create mode 100644 kernel/cgroup_freezer.c
> > 
> > Index: linux-2.6.27-rc1-mm1/include/linux/cgroup_freezer.h
> > ===================================================================
> > --- /dev/null
> > +++ linux-2.6.27-rc1-mm1/include/linux/cgroup_freezer.h
> > @@ -0,0 +1,71 @@
> > +#ifndef _LINUX_CGROUP_FREEZER_H
> > +#define _LINUX_CGROUP_FREEZER_H
> > +/*
> > + * cgroup_freezer.h -  control group freezer subsystem interface
> > + *
> > + * Copyright IBM Corporation, 2007
> > + *
> > + * Author : Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> > + *
> > + * This program is free software; you can redistribute it and/or modify it
> > + * under the terms of version 2.1 of the GNU Lesser General Public License
> > + * as published by the Free Software Foundation.
> > + *
> > + * This program is distributed in the hope that it would be useful, but
> > + * WITHOUT ANY WARRANTY; without even the implied warranty of
> > + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
> > + */
> > +
> > +#include <linux/cgroup.h>
> > +
> > +#ifdef CONFIG_CGROUP_FREEZER
> > +
> > +enum freezer_state {
> > +	STATE_RUNNING = 0,
> > +	STATE_FREEZING,
> > +	STATE_FROZEN,
> > +};
> > +
> > +struct freezer {
> > +	struct cgroup_subsys_state css;
> > +	enum freezer_state state;
> > +	spinlock_t lock; /* protects _writes_ to state */
> > +};
> > +
> > +static inline struct freezer *cgroup_freezer(
> > +		struct cgroup *cgroup)
> > +{
> > +	return container_of(
> > +		cgroup_subsys_state(cgroup, freezer_subsys_id),
> > +		struct freezer, css);
> > +}
> > +
> > +static inline struct freezer *task_freezer(struct task_struct *task)
> > +{
> > +	return container_of(task_subsys_state(task, freezer_subsys_id),
> > +			    struct freezer, css);
> > +}
> > +
> > +static inline int cgroup_frozen(struct task_struct *task)
> > +{
> > +	struct freezer *freezer;
> > +	enum freezer_state state;
> > +
> > +	task_lock(task);
> > +	freezer = task_freezer(task);
> > +	state = freezer->state;
> > +	task_unlock(task);
> > +
> > +	return state == STATE_FROZEN;
> > +}
> > +
> > +#else /* !CONFIG_CGROUP_FREEZER */
> > +
> > +static inline int cgroup_frozen(struct task_struct *task)
> > +{
> > +	return 0;
> > +}
> > +
> > +#endif /* !CONFIG_CGROUP_FREEZER */
> > +
> > +#endif /* _LINUX_CGROUP_FREEZER_H */
> 
> Hmm.  I wonder if we really need a separate file for this.  I'd prefer it to be
> in freezer.h, unless there's a good reason not to place it in there.

	Yeah, it's a pretty small header so combining it with another header
would be nice. However if we combine it with freezer.h we'd be including
cgroup.h in unrelated filesystem code. An alternative might be to put it
into a cgroup header for "small" subsystems (which might just be
cgroup.h for now..).

Thanks for the review!

Cheers,
	-Matt
