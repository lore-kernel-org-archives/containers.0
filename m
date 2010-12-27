From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v5 3/3] cgroups: make procs file writable
Date: Mon, 27 Dec 2010 18:18:01 +0900
Message-ID: <20101227181801.095e9a23.kamezawa.hiroyu@jp.fujitsu.com>
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
	<20101227084257.GA20986@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101227084257.GA20986-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 27 Dec 2010 03:42:57 -0500
Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:

> On Mon, Dec 27, 2010 at 04:42:07PM +0900, KAMEZAWA Hiroyuki wrote:

> > Okay, then, problem is cpuset, which allocates memory.
> > (But I feel that limitation -never_sleep- is not very good.)
> > 
> > BTW, mem cgroup chesk mm_owner(mm) == p to decide to take mmap_sem().
> > Your code does moving "thread_group_leader()". IIUC, this isn't guaranteed to
> > be the same. I wonder we can see problem with some stupid userland.
> 
> I'm not sure I understand the point of looking at mm->owner? My code
> does thread_group_leader() because if a task that's not the leader calls
> exec(), the thread_group list will be in an indeterminate state from the
> perspective of the task we hold on to (who was originally the leader).
> 

Hm. By following, only 'thread-group-leader' can go ahead.

+	threadgroup_fork_write_lock(leader);
+	read_lock(&tasklist_lock);
+	/* sanity check - if we raced with de_thread, we must abort */
+	if (!thread_group_leader(leader)) {
+		retval = -EAGAIN;
+		read_unlock(&tasklist_lock);
+		threadgroup_fork_write_unlock(leader);
+		goto list_teardown;
+	}

This moves each tasks under tasklist_lock().

+	list_for_each_entry_rcu(tsk, &leader->thread_group, thread_group) {
+		/* leave current thread as it is if it's already there */
+		oldcgrp = task_cgroup_from_root(tsk, root);
+		if (cgrp == oldcgrp)
+			continue;
+		/* attach each task to each subsystem */
+		for_each_subsys(root, ss) {
+			if (ss->attach_task)
+				ss->attach_task(cgrp, tsk);
+		}
+		/* we don't care whether these threads are exiting */
+		retval = cgroup_task_migrate(cgrp, oldcgrp, tsk, true);
+		BUG_ON(retval != 0 && retval != -ESRCH);
+	}

Hm. I'm not sure there can be a task, tsk == mm->owner here.
If tsk == mm->owner, attach task will take mmap_sem() and do something more.

In usual case, mm->owner = thread_group_leader, but it's not in special cases.



> > > Also, the tasklist_lock isn't used to synchronize fork events; that's
> > > what threadgroup_fork_lock (an rwsem) is for. It's for protecting the
> > > thread-group list while iterating over it - so that a race with exec()
> > > (de_thread(), specifically) doesn't change the threadgroup state. It's
> > > basically never safe to iterate over leader->thread_group unless you're
> > > in a no-sleep section.
> > > 
> > 
> > Thank you for explanation.
> > 
> > At first, cpuset should modify settings around 'mm' only when the thread == mm->owner.
> > ....is there any reason to allow all threads can affect the 'mm' ?
> 
> I don't follow... is this any different from the cgroup_attach_task()
> case?
> 

cpuset_attach() takes mmap_sem() to modify mm's settings. Because all threads
share mm, doing page migration whenever a thread moves seems to be wrong.
I think only a thread, thread-group-leader or mm->owner, in process should be
allowed to migrate pages. Then, cgroup_attach_proc() can avoid taking mmap_sem
under tasklist_lock.



> > About nodemask, I feel what's required is pre_pre_attach() to cache required memory
> > before attaching as radix_tree_preload(). Then, subsys can prepare for creating
> > working area.
> 
> To save on global memory footprint, we could pre-allocate two nodemasks,
> but I feel like it's not worth the increase in code complexity. This
> would need to be done in the other cases that unsafely do NODEMASK_ALLOC
> too... too much to keep track of for little gain.
> 

But NODEMASK_ALLOC cannot be on stack when we consider 4096node systems.


> > Hmm...but I wonder de_thread() should take threadgroup_fork_write_unlock().
> > 
> > I may not understand anything important but I feel taking tasklist_lock() is overkill.
> 
> Would rcu_read_lock() be any better? Everywhere else in the kernel that
> iterates over all threads in a group uses either rcu_read_lock or
> tasklist_lock.
> 

Because it means that can_attach()/attach() cannot sleep, it seems to make no
difference.

I wonder.... if you stops all clone()/fork() of the proc in moving, you can use
find_ge_pid(). Please see next_tgid() or next_tid() in fs/proc/base.c which
implements  scanning tasklist with sleep. Can't you use next_tid() ?

Thanks,
-Kame

P.S. I'll be offlined until 2010/01/04.
