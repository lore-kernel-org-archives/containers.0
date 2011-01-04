From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH v5 3/3] cgroups: make procs file writable
Date: Tue, 4 Jan 2011 09:57:16 +0900
Message-ID: <20110104095716.ee71a57a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20101216002603.6741874a.akpm@linux-foundation.org>
	<20101224033352.GA7804@ghc17.ghc.andrew.cmu.edu>
	<20101225025508.GA649@ghc17.ghc.andrew.cmu.edu>
	<20101227095353.48d95687.nishimura@mxp.nes.nec.co.jp>
	<20101227042254.GA15417@ghc17.ghc.andrew.cmu.edu>
	<20101227160041.07bff52a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101227072123.GA19652@ghc17.ghc.andrew.cmu.edu>
	<20101227164207.b09318be.kamezawa.hiroyu@jp.fujitsu.com>
	<20101227084257.GA20986@ghc17.ghc.andrew.cmu.edu>
	<20101227181801.095e9a23.kamezawa.hiroyu@jp.fujitsu.com>
	<20101227101228.GB20986@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101227101228.GB20986-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
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

On Mon, 27 Dec 2010 05:12:28 -0500
Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:

> > > > About nodemask, I feel what's required is pre_pre_attach() to cache required memory
> > > > before attaching as radix_tree_preload(). Then, subsys can prepare for creating
> > > > working area.
> > > 
> > > To save on global memory footprint, we could pre-allocate two nodemasks,
> > > but I feel like it's not worth the increase in code complexity. This
> > > would need to be done in the other cases that unsafely do NODEMASK_ALLOC
> > > too... too much to keep track of for little gain.
> > > 
> > 
> > But NODEMASK_ALLOC cannot be on stack when we consider 4096node systems.
> 
> Hence global allocation, instead of on-stack. (Also, for this particular
> case, the state of the nodemasks needs to persist from pre_attach to
> attach_task to attach, so it can't be static inside the function
> either.)
> 

Yes, it can be global/static.



> > > > Hmm...but I wonder de_thread() should take threadgroup_fork_write_unlock().
> > > > 
> > > > I may not understand anything important but I feel taking tasklist_lock() is overkill.
> > > 
> > > Would rcu_read_lock() be any better? Everywhere else in the kernel that
> > > iterates over all threads in a group uses either rcu_read_lock or
> > > tasklist_lock.
> > > 
> > 
> > Because it means that can_attach()/attach() cannot sleep, it seems to make no
> > difference.
> 
> can_attach_task(), pre_attach(), and attach_task() cannot sleep, but
> can_attach() and attach() may. Careful not to confuse them. :P
> 
> > I wonder.... if you stops all clone()/fork() of the proc in moving, you can use
> > find_ge_pid(). Please see next_tgid() or next_tid() in fs/proc/base.c which
> > implements  scanning tasklist with sleep. Can't you use next_tid() ?
> 
> If I'm not mistaken, that approach is vulnerable to an exit() race -
> next_tid() may return NULL if pid_alive() fails, and then we stop
> iterating and miss some threads. (The relevant code is kernel/exit.c,
> __unhash_process, which is protected by tasklist_lock and sighand->lock,
> but nothing else.)
>

You can use pid array, find_ge_pid() (or some), if the linked-list
is not dependable. If CLONE_THREAD is blocked, it works to catch
all threads without races.

Thanks,
-Kame
