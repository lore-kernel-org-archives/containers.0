From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v5 3/3] cgroups: make procs file writable
Date: Fri, 24 Dec 2010 23:24:33 -0500
Message-ID: <20101225042432.GB649@ghc17.ghc.andrew.cmu.edu>
References: <20100811054604.GA8743@ghc17.ghc.andrew.cmu.edu>
	<20100811054851.GD8743@ghc17.ghc.andrew.cmu.edu>
	<AANLkTimRM8rDe+u7fTy853RK=1mnLJMK57Tci2OLPR7L@mail.gmail.com>
	<AANLkTim7HW0wNyqOPePFXmEMV8hx_fMKNMTAsSwkRzZX@mail.gmail.com>
	<AANLkTin7aK5uEFi0U+iU_9=cbfRTHfDzKsbWupn73fSL@mail.gmail.com>
	<20101216002603.6741874a.akpm@linux-foundation.org>
	<20101224033352.GA7804@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101224033352.GA7804-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Dec 23, 2010 at 10:33:52PM -0500, Ben Blum wrote:
> On Thu, Dec 16, 2010 at 12:26:03AM -0800, Andrew Morton wrote:
> > Patches have gone a bit stale, sorry.  Refactoring in
> > kernel/cgroup_freezer.c necessitates a refresh and retest please.
> 
> commit 53feb29767c29c877f9d47dcfe14211b5b0f7ebd changed a bunch of stuff
> in kernel/cpuset.c to allocate nodemasks with NODEMASK_ALLOC (which
> wraps kmalloc) instead of on the stack.
> 
> 1. All these functions have 'void' return values, indicating that
>    calling them them must not fail. Sure there are bailout cases, but no
>    semblance of cross-function error propagation. Most importantly,
>    cpuset_attach is a subsystem callback, which MUST not fail given the
>    way it's used in cgroups, so relying on kmalloc is not safe.
> 
> 2. I'm working on a patch series which needs to hold tasklist_lock
>    across ss->attach callbacks (in cpuset_attach's "if (threadgroup)"
>    case, this is how safe traversal of tsk->thread_group will be
>    ensured), and kmalloc isn't allowed while holding a spin-lock. 
> 
> Why do we need heap-allocation here at all? In each case their scope is
> exactly the function's scope, and neither the commit nor the surrounding
> patch series give any explanation. I'd like to revert the patch if
> possible.
> 
> cc'ing Miao Xie (author) and David Rientjes (acker).
> 
> -- Ben
> 

By the way, there is still another issue on top of this.

cpuset_attach
-> do_migrate_pages
-> migrate_prep
-> lru_add_drain_all
-> __alloc_percpu, which does GFP_KERNEL, which can sleep.

This will be no good if we call ss->attach with tasklist_lock held. A
friend points out that even without the sleeping/etc you still don't
want to be doing a memory migration while holding a spinlock.

I think the best solution for this would be to add another subsystem
callback, "attach_thread", which would do the cheap once-per-thread
operations and be called under tasklist_lock. It'd look like this:

read_lock(tasklist_lock)
for each thread (c) {
    cgroup_task_migrate(c)
    for each subsys (ss) {
        ss->attach_thread(c)
    }
}
read_unlock(tasklist_lock)
for each subsys (ss) {
    ss->attach(leader)
}

For cpuset, this will need to keep the nodemask data between the
attach_thread and attach functions, so the nodemasks will need to be
global instead of local.

-- Ben

P.S. when i'm iterating over tsk->thread_group while using tasklist_lock
to protect it instead of rcu_read_lock, should i use list_for_each_entry
or list_for_each_entry_rcu? it has been a while since i wrote that bit.
