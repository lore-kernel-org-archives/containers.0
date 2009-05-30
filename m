From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][RFC] freezer: Add CHECKPOINTING state to safeguard
	container checkpoint
Date: Fri, 29 May 2009 20:04:44 -0700
Message-ID: <20090530030444.GF9285@us.ibm.com>
References: <20090505002620.2173735E178@count0.localdomain>
	<4A202AE9.1090801@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A202AE9.1090801-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Pavel Machek <pavel-AlSwsSmVLrQ@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, May 29, 2009 at 02:35:21PM -0400, Oren Laadan wrote:
> 
> Matt Helsley wrote:
> > The CHECKPOINTING state prevents userspace from unfreezing tasks until
> > sys_checkpoint() is finished. When doing container checkpoint userspace
> > will do:
> 
> [...]
> 
> >  /*
> > + * cgroup freezer state changes made without the aid of the cgroup filesystem
> > + * must go through this function to ensure proper locking is observed.
> > + */
> > +static int freezer_checkpointing(struct task_struct *task,
> > +				 enum freezer_state next_state)
> > +{
> > +	struct freezer *freezer;
> > +	enum freezer_state state;
> > +
> > +	task_lock(task);
> > +	freezer = task_freezer(task);
> > +	spin_lock_irq(&freezer->lock);
> > +	state = freezer->state;
> 
> After "echo FROZEN > /freezer/0/freezer_state", it is likely that
> freezer->state remains CGROUP_FREEZING --
> 
> Then, looking at freezer_read():
> 
> ...
>   if (state == CGROUP_FREEZING) {
> 	/* We change from FREEZING to FROZEN lazily if the cgroup was
> 	 * only partially frozen when we exitted write. */
> 	update_freezer_state(cgroup, freezer);
> 	state = freezer->state;
>   }
> ...
> 
> IOW, usually, only if someone reads the freezer_state file will
> the freezer->status reliably reflect the state.
> 
> So, I searched for where else freezer->state is consulted, and found:
> 
>   int cgroup_frozen(struct task_struct *task)
>   {
> 	struct freezer *freezer;
> 	enum freezer_state state;
> 
> 	task_lock(task);
> 	freezer = task_freezer(task);
> 	state = freezer->state;
> 	task_unlock(task);
> 
> 	return state == CGROUP_FROZEN;
>   }
> 
> Which is called (only?) from kernel/power/process.c:thaw_tasks().

Currently that is the only place it's called, yes.

> Here, too, unless some read from the freezer_state file, this
> test will incorrectly fail.

True. For kernel/power/process.c:thaw_tasks() we're really trying to
prevent resume from thawing tasks that were frozen via the cgroup
freezer.

So really CGROUP_FREEZING should also be tested for in that code path.
However that doesn't match the name so a name change would be in order
too.


I audited the rest of the cgroup freezer code without the CHECKPOINTING
patch and the remaining tests for CGROUP_FROZEN look fine to me:

can_attach:
	This looks OK. If we're not in the frozen state then it's OK to
	add a new task to the cgroup. So the analogous scenario is we're
	in CGROUP_FREEZING but all of the tasks are frozen. Adding a
	new task -- frozen or otherwise -- would not pose a problem.

BUG_ON() in freezer_fork:
	The forking task isn't frozen and hence its cgroup is not
	can't be FROZEN. But there's a BUG_ON() here "just in case" -- 
	it should never happen. So at worst it won't find bugs here until
	userspace does a read() on freezer.state.

Lastly, this means we'd need a new function for other parts of the
kernel which definitely want to know if the cgroup is frozen. That
function would have to  do a lazy update if the state is
CGROUP_FREEZING.

I'll make a patch which changes cgroup_frozen() and send it off for
mainline.

Then I'll re-add cgroup_frozen() for CHECKPOINTING and ensure that it
works with the lazy update.

Cheers,
	-Matt
