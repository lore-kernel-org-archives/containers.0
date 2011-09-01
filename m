From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH][BUGFIX] cgroups: more safe tasklist locking in
	cgroup_attach_proc
Date: Thu, 1 Sep 2011 17:46:43 -0400
Message-ID: <20110901214643.GD10401__45030.3785539747$1314932875$gmane$org@unix33.andrew.cmu.edu>
References: <20110727171101.5e32d8eb@notabene.brown>
	<20110727150710.GB5242@unix33.andrew.cmu.edu>
	<20110727234235.GA2318@linux.vnet.ibm.com>
	<20110728110813.7ff84b13@notabene.brown>
	<20110728062616.GC15204@unix33.andrew.cmu.edu>
	<20110728171345.67d3797d@notabene.brown>
	<20110729142842.GA8462@unix33.andrew.cmu.edu>
	<20110815184957.GA16588@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110815184957.GA16588-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Aug 15, 2011 at 08:49:57PM +0200, Oleg Nesterov wrote:
> > -	rcu_read_lock();
> > +	read_lock(&tasklist_lock);
> >  	if (!thread_group_leader(leader)) {
> 
> Agreed, this should work.
> 
> But can't we avoid the global list? thread_group_leader() or not, we do
> not really care. We only need to ensure we can safely find all threads.
> 
> How about the patch below?

I was content with the tasklist_lock because cgroup_attach_proc is
already a pretty heavyweight operation, and probably pretty rare that a
user would want to do multiple of them at once quickly. I asked Andrew
to take the simple tasklist_lock patch just now, since it does fix the
bug at least.

Anyway, looking at this, hmm. I am not sure if this protects adequately?
In de_thread, the sighand lock is held only around the first half
(around zap_other_threads), and not around the following section where
leadership is transferred (esp. around the list_replace calls).
tasklist_lock is held here, though, so it seems like the right lock to
hold.

> 
> 
> With or without this/your patch this leader can die right after we
> drop the lock. ss->can_attach(leader) and ss->attach(leader) look
> suspicious. If a sub-thread execs, this task_struct has nothing to
> do with the threadgroup.

hmm. I thought I had this case covered, but it's been so long since I
actually wrote the code that if I did I can't remember how. I think
exiting is no issue since we hold a reference on the task_struct, but
exec may still be a problem. I'm thinking:

- cgroup_attach_proc drops the tasklist_lock
- a sub-thread execs, and in exec_mmap (after de_thread) changes the mm
- ss->attach, for example in memcg, wants to use leader->mm, which is
  now wrong

this seems to be possible as the code currently is. I wonder if the best
fix is just to have exec (maybe around de_thread) bounce off of or hold
threadgroup_fork_read_lock somewhere?

> 
> 
> 
> Also. This is off-topic, but... Why cgroup_attach_proc() and
> cgroup_attach_task() do ->attach_task() + cgroup_task_migrate()
> in the different order? cgroup_attach_proc() looks wrong even
> if currently doesn't matter.

(already submitted a patch for this)

Thanks,
Ben

> 
> 
> Oleg.
> 
> --- x/kernel/cgroup.c
> +++ x/kernel/cgroup.c
> @@ -2000,6 +2000,7 @@ int cgroup_attach_proc(struct cgroup *cg
>  	/* threadgroup list cursor and array */
>  	struct task_struct *tsk;
>  	struct flex_array *group;
> +	unsigned long flags;
>  	/*
>  	 * we need to make sure we have css_sets for all the tasks we're
>  	 * going to move -before- we actually start moving them, so that in
> @@ -2027,19 +2028,10 @@ int cgroup_attach_proc(struct cgroup *cg
>  		goto out_free_group_list;
>  
>  	/* prevent changes to the threadgroup list while we take a snapshot. */
> -	rcu_read_lock();
> -	if (!thread_group_leader(leader)) {
> -		/*
> -		 * a race with de_thread from another thread's exec() may strip
> -		 * us of our leadership, making while_each_thread unsafe to use
> -		 * on this task. if this happens, there is no choice but to
> -		 * throw this task away and try again (from cgroup_procs_write);
> -		 * this is "double-double-toil-and-trouble-check locking".
> -		 */
> -		rcu_read_unlock();
> -		retval = -EAGAIN;
> +	retval = -EAGAIN;
> +	if (!lock_task_sighand(leader, &flags))
>  		goto out_free_group_list;
> -	}
> +
>  	/* take a reference on each task in the group to go in the array. */
>  	tsk = leader;
>  	i = 0;
> @@ -2055,9 +2047,9 @@ int cgroup_attach_proc(struct cgroup *cg
>  		BUG_ON(retval != 0);
>  		i++;
>  	} while_each_thread(leader, tsk);
> +	unlock_task_sighand(leader, &flags);
>  	/* remember the number of threads in the array for later. */
>  	group_size = i;
> -	rcu_read_unlock();
>  
>  	/*
>  	 * step 1: check that we can legitimately attach to the cgroup.
> 
> 
