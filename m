From: Matt Helsley <matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cgroup_freezer: allow migration
	regardless of freezer state and update locking
Date: Thu, 18 Oct 2012 15:21:55 -0700
Message-ID: <20121018222155.GB6223@us.ibm.com>
References: <1350426526-14254-1-git-send-email-tj@kernel.org>
	<20121017191606.GA6223@us.ibm.com>
	<20121018211434.GI13370@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20121018211434.GI13370-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, Matt Helsley <matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Oct 18, 2012 at 02:14:34PM -0700, Tejun Heo wrote:
> Hello, Matt.
> 
> On Wed, Oct 17, 2012 at 12:16:06PM -0700, Matt Helsley wrote:
> > > * Unfreezable kernel tasks don't prevent a cgroup from transitioning
> > >   into FROZEN from FREEZING.  There's nothing userland can do with or
> > >   about such tasks.
> > 
> > Seems like a non-problem. Do you have a testcase showing how kernel
> > threads prevent cgroups that should be freezable from being frozen?
> > It used to be that you couldn't move kernel threads out of the root
> > cgroup and the root cgroup was not freezable. So this was never a
> > problem before. Is there some change here that I'm unaware of?
> 
> Hmmm?  Nothing prevents kthreads from being moved around.  We only
> recently added the restriction to prevent migration of the kthreadd
> (the one which creates other kthreads).  You can reproduce it with
> khungtask or any other !freezable kthreads.

Ok. I don't immmediately see why that'd be a good idea but it's
possible..

> 
> > > * Tasks can be moved in and out of a frozen cgroup.  Tasks are made to
> > >   conform to the state of the new cgroup during migration.  This
> > >   behavior makes a lot more sense and removes the use of
> > >   ->can_attach() which makes co-mounting difficult.
> > 
> > One nice aspect of freezing the set of tasks in the cgroup as well as the
> > tasks themselves was you had a fixed set of tasks to work with (from
> > userspace or otherwise). With this change that will no longer be true.
> > This is a userspace-visible behavior change and userspace code may
> > have relied on this feature.
> >
> > Will this work for the CRIU folks? With this patch one of the tasks being
> > checkpointed could become thawed simply by some other process writing
> > the pid into a different cgroup's tasks file. In contrast, with the
> > current code they'd have to explicitly thaw its cgroup first.
> 
> Yeap, this is a userland visible behavior change.  Don't see any other
> way around it tho and if you can't prevent someone else moving things
> in/out of your cgroup, what prevents someone else echoing THAWED to
> freezer.state?

The userspace code would at least have to be aware that the group could
be frozen. That alone ought to encourage some tool writers to think
about how to share the cgroup's freezer.state and possibly other bits
with other tools and/or the user(s).

In general though, yes, there's alot of potential for users and tools
to step all over each others' toes when it comes to manipulating cgroup
state. Even tools aware of the freezer could still write THAWED to the
freezer state when another tool does not expect it.

<off_topic>
"Whoever" did the freeze needs a way to "lock" access to the freezer state,
change the freezer state itself, do something (e.g. CRIU) which relies on
the state not changing, and then release the lock. Plus the lock has to be
released by the kernel if "Whoever" dies without the chance to release it.
So I was thinking who holds the lock and its lifetime could be represented
in userspace by file descriptor(s).
</off_topic>

> As for CRIU, it isn't using cgroup freezer at the moment because
> frozen tasks can't be ptraced currently.  Something I'm hoping to
> change but not sure when it can be done.

OK, but that doesn't mean the frozen nature of the task list itself
won't be useful in the future.

Cheers,
	-Matt Helsley
