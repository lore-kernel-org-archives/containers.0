From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v5 3/3] cgroups: make procs file writable
Date: Mon, 27 Dec 2010 03:42:57 -0500
Message-ID: <20101227084257.GA20986@ghc17.ghc.andrew.cmu.edu>
References: <AANLkTim7HW0wNyqOPePFXmEMV8hx_fMKNMTAsSwkRzZX@mail.gmail.com>
	<AANLkTin7aK5uEFi0U+iU_9=cbfRTHfDzKsbWupn73fSL@mail.gmail.com>
	<20101216002603.6741874a.akpm@linux-foundation.org>
	<20101224033352.GA7804@ghc17.ghc.andrew.cmu.edu>
	<20101225025508.GA649@ghc17.ghc.andrew.cmu.edu>
	<20101227095353.48d95687.nishimura@mxp.nes.nec.co.jp>
	<20101227042254.GA15417@ghc17.ghc.andrew.cmu.edu>
	<20101227160041.07bff52a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101227072123.GA19652@ghc17.ghc.andrew.cmu.edu>
	<20101227164207.b09318be.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101227164207.b09318be.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Dec 27, 2010 at 04:42:07PM +0900, KAMEZAWA Hiroyuki wrote:
> On Mon, 27 Dec 2010 02:21:23 -0500
> Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
>  
> > > IIUC, what you request is 'don't call any kind of function may sleep'.
> > > in can_attach() and attach() callback. That's impossible.
> > > Memory cgroup will go to sleep because of calling memory reclaim.
> > > 
> > > Is tasklist_lock the only way ? Can you catch "new thread" event in cgroup_fork() ?
> > > 
> > > For example,
> > > 
> > > ==
> > > void cgroup_fork(struct task_struct *child)
> > > {
> > > 	if (current->in_moving) {
> > > 		add_to_waitqueue somewhere.
> > > 	}
> > >         task_lock(current);
> > >         child->cgroups = current->cgroups;
> > >         get_css_set(child->cgroups);
> > >         task_unlock(current);
> > >         INIT_LIST_HEAD(&child->cg_list);
> > > }
> > > ==
> > > 
> > > ==
> > >  read_lock(&tasklist_lock);
> > >  list_for_each_entry_rcu(tsk, &leader->thread_group, thread_group) {
> > > 	tsk->in_moving = true;
> > >  }
> > >  read_unlock(&tasklist_lock);
> > > 
> > >  ->pre_attach()
> > >  ->attach()
> > > 
> > >  read_unlock(&tasklist_lock);
> > >  list_for_each_.....
> > > 	tsk->in_moving_cgroup = false;
> > > 
> > >  wakeup threads in waitq.
> > > ==
> > > 
> > > Ah yes, this will have some bug. But please avoid to take tasklist_lock() around
> > > all pre_attach() and attach().
> > > 
> > > Thanks,
> > > -Kame
> > > 
> > > 
> > > 
> > > 
> > > 
> > > Thanks,
> > > -Kame
> > 
> > You misunderstand slightly: the callbacks are split into a
> > once-per-thread function and a thread-independent function, and only the
> > former is not allowed to sleep. All of memcg's attachment is thread-
> > independent, so sleeping there is fine.
> > 
> Okay, then, problem is cpuset, which allocates memory.
> (But I feel that limitation -never_sleep- is not very good.)
> 
> BTW, mem cgroup chesk mm_owner(mm) == p to decide to take mmap_sem().
> Your code does moving "thread_group_leader()". IIUC, this isn't guaranteed to
> be the same. I wonder we can see problem with some stupid userland.

I'm not sure I understand the point of looking at mm->owner? My code
does thread_group_leader() because if a task that's not the leader calls
exec(), the thread_group list will be in an indeterminate state from the
perspective of the task we hold on to (who was originally the leader).

> > Also, the tasklist_lock isn't used to synchronize fork events; that's
> > what threadgroup_fork_lock (an rwsem) is for. It's for protecting the
> > thread-group list while iterating over it - so that a race with exec()
> > (de_thread(), specifically) doesn't change the threadgroup state. It's
> > basically never safe to iterate over leader->thread_group unless you're
> > in a no-sleep section.
> > 
> 
> Thank you for explanation.
> 
> At first, cpuset should modify settings around 'mm' only when the thread == mm->owner.
> ....is there any reason to allow all threads can affect the 'mm' ?

I don't follow... is this any different from the cgroup_attach_task()
case?

> About nodemask, I feel what's required is pre_pre_attach() to cache required memory
> before attaching as radix_tree_preload(). Then, subsys can prepare for creating
> working area.

To save on global memory footprint, we could pre-allocate two nodemasks,
but I feel like it's not worth the increase in code complexity. This
would need to be done in the other cases that unsafely do NODEMASK_ALLOC
too... too much to keep track of for little gain.

> Hmm...but I wonder de_thread() should take threadgroup_fork_write_unlock().
> 
> I may not understand anything important but I feel taking tasklist_lock() is overkill.

Would rcu_read_lock() be any better? Everywhere else in the kernel that
iterates over all threads in a group uses either rcu_read_lock or
tasklist_lock.

-- Ben

> 
> Thanks, 
> -Kame
> 
> 
