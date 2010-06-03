From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [RFC] [PATCH 2/2] cgroups: make procs file writable
Date: Thu, 3 Jun 2010 00:56:29 -0400
Message-ID: <20100603045629.GC21006__103.851469657634$1275541161$gmane$org@ghc02.ghc.andrew.cmu.edu>
References: <20100530013002.GA762@ghc01.ghc.andrew.cmu.edu>
	<20100530013303.GC762@ghc01.ghc.andrew.cmu.edu>
	<20100531175242.GA14691@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100531175242.GA14691-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, May 31, 2010 at 07:52:42PM +0200, Oleg Nesterov wrote:
> I only glanced into one function, cgroup_attach_proc(), and some things
> look "obviously wrong". Sorry, I can't really read these patches now,
> most probably I misunderstood the code...
> 
> > +int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
> > +{
> > +	int retval;
> > +	struct cgroup_subsys *ss, *failed_ss = NULL;
> > +	struct cgroup *oldcgrp;
> > +	struct css_set *oldcg;
> > +	struct cgroupfs_root *root = cgrp->root;
> > +	/* threadgroup list cursor */
> > +	struct task_struct *tsk;
> > +	/*
> > +	 * we need to make sure we have css_sets for all the tasks we're
> > +	 * going to move -before- we actually start moving them, so that in
> > +	 * case we get an ENOMEM we can bail out before making any changes.
> > +	 */
> > +	struct list_head newcg_list;
> > +	struct cg_list_entry *cg_entry, *temp_nobe;
> > +
> > +	/*
> > +	 * Note: Because of possible races with de_thread(), we can't
> > +	 * distinguish between the case where the user gives a non-leader tid
> > +	 * and the case where it changes out from under us. So both are allowed.
> > +	 */
> 
> OK, the caller has a reference to the argument, leader,
> 
> > +	leader = leader->group_leader;
> 
> But why it is safe to use leader->group_leader if we race with exec?

This line means "let's try to find who the leader is", since
attach_task_by_pid doesn't grab it for us. It's not "safe", and we still
check if it's really the leader later (just before the 'commit point').
Note that before this line 'leader' doesn't really mean the leader -
perhaps i should rename the variables :P

But maybe I also want to grab a reference on the new task? I can't
remember whether I need to or not. I'm not sure whether or not I need to
grab an rcu lock, but it doesn't seem necessary because of the commit
point check later on. Plus can_attach takes the rcu lock itself for
iterating if it needs it.

> 
> > +	list_for_each_entry_rcu(tsk, &leader->thread_group, thread_group) {
> 
> Even if we didn't change "leader" above, this is not safe in theory.
> We already discussed this, list_for_each_rcu(head) is only safe when
> we know that "head" itself is valid.
> 
> Suppose that this leader exits, then leader->thread_group.next exits
> too before we take rcu_read_lock().

Why is that a problem? I thought leader->thread_group is supposed to
stay sane as long as leader is the leader.

This looks like it needs a check to see if 'leader' is still really the
leader, but nothing more.

> 
> > +	oldcgrp = task_cgroup_from_root(leader, root);
> > +	if (cgrp != oldcgrp) {
> > +		retval = cgroup_task_migrate(cgrp, oldcgrp, leader, true);
> > +		BUG_ON(retval != 0 && retval != -ESRCH);
> > +	}
> > +	/* Now iterate over each thread in the group. */
> > +	list_for_each_entry_rcu(tsk, &leader->thread_group, thread_group) {
> > +		BUG_ON(tsk->signal != leader->signal);
> > +		/* leave current thread as it is if it's already there */
> > +		oldcgrp = task_cgroup_from_root(tsk, root);
> > +		if (cgrp == oldcgrp)
> > +			continue;
> > +		/* we don't care whether these threads are exiting */
> > +		retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, true);
> > +		BUG_ON(retval != 0 && retval != -ESRCH);
> > +	}
> 
> This looks strange. Why do we move leader outside of the loop ?
> Of course, list_for_each_entry() can't work to move all sub-threads,
> but "do while_each_thread()" can.

do/while_each_thread oves over all threads in the system, rather than
just the threadgroup... this isn't supposed to be a fast operation, but
that seems like overkill.

> 
> From 0/2:
> >
> > recentish changes to signal_struct's lifetime rules (which don't seem to
> > appear when I check out mmotm with git clone,
> 
> already in Linus's tree.
> 
> Oleg.
> 

-- Ben
