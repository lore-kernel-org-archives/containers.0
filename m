From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [PATCH v5 3/3] cgroups: make procs file writable
Date: Mon, 27 Dec 2010 09:53:53 +0900
Message-ID: <20101227095353.48d95687.nishimura@mxp.nes.nec.co.jp>
References: <20100811054604.GA8743@ghc17.ghc.andrew.cmu.edu>
	<20100811054851.GD8743@ghc17.ghc.andrew.cmu.edu>
	<AANLkTimRM8rDe+u7fTy853RK=1mnLJMK57Tci2OLPR7L@mail.gmail.com>
	<AANLkTim7HW0wNyqOPePFXmEMV8hx_fMKNMTAsSwkRzZX@mail.gmail.com>
	<AANLkTin7aK5uEFi0U+iU_9=cbfRTHfDzKsbWupn73fSL@mail.gmail.com>
	<20101216002603.6741874a.akpm@linux-foundation.org>
	<20101224033352.GA7804@ghc17.ghc.andrew.cmu.edu>
	<20101225025508.GA649@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101225025508.GA649-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
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
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 24 Dec 2010 21:55:08 -0500
Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:

> On Thu, Dec 23, 2010 at 10:33:52PM -0500, Ben Blum wrote:
> > On Thu, Dec 16, 2010 at 12:26:03AM -0800, Andrew Morton wrote:
> > > Patches have gone a bit stale, sorry.  Refactoring in
> > > kernel/cgroup_freezer.c necessitates a refresh and retest please.
> > 
> > commit 53feb29767c29c877f9d47dcfe14211b5b0f7ebd changed a bunch of stuff
> > in kernel/cpuset.c to allocate nodemasks with NODEMASK_ALLOC (which
> > wraps kmalloc) instead of on the stack.
> > 
> > 1. All these functions have 'void' return values, indicating that
> >    calling them them must not fail. Sure there are bailout cases, but no
> >    semblance of cross-function error propagation. Most importantly,
> >    cpuset_attach is a subsystem callback, which MUST not fail given the
> >    way it's used in cgroups, so relying on kmalloc is not safe.
> > 
> > 2. I'm working on a patch series which needs to hold tasklist_lock
> >    across ss->attach callbacks (in cpuset_attach's "if (threadgroup)"
> >    case, this is how safe traversal of tsk->thread_group will be
> >    ensured), and kmalloc isn't allowed while holding a spin-lock. 
> > 
> > Why do we need heap-allocation here at all? In each case their scope is
> > exactly the function's scope, and neither the commit nor the surrounding
> > patch series give any explanation. I'd like to revert the patch if
> > possible.
> > 
> > cc'ing Miao Xie (author) and David Rientjes (acker).
> > 
> > -- Ben
> 
> Well even with the proposed solution to this there is still another
> problem that I see - that of mmap_sem. cpuset_attach() calls into
> mpol_rebind_mm() and do_migrate_pages(), which take mm->mmap_sem for
> writing and reading respectively. This is going to conflict with
> tasklist_lock... but moreover, the memcontrol subsys also touches the
> task's mm->mmap_sem, holding onto it between mem_cgroup_can_attach() and
> mem_cgroup_move_task() - as of b1dd693e5b9348bd68a80e679e03cf9c0973b01b.
> 
> So we have (currently, even without my patches):
> 
> cgroup_attach_task
> (1) cpuset_can_attach
> (2) mem_cgroup_can_attach
>      - down_read(&mm->mmap_sem);
> (3) cpuset_attach
>      - mpol_rebind_mm
>         - down_write(&mm->mmap_sem);
>         - up_write(&mm->mmap_sem);
>      - cpuset_migrate_mm
>         - do_migrate_pages
>            - down_read(&mm->mmap_sem);
>            - up_read(&mm->mmap_sem);
> (4) mem_cgroup_move_task
>      - mem_cgroup_clear_mc
>         - up_read(...);
> 
hmm, nice catch.

> Is there some interdependency I'm missing here that guarantees recursive
> locking/deadlock will be avoided? It all looks like typical-case code.
> 
Unfortunately, not.
I couldn't hit this because I mount all subsystems onto different
mount points in my environment.

> I think we should move taking the mmap_sem all the way up into
> cgroup_attach_task and cgroup_attach_proc; it will be held for writing
> the whole time. I don't quite understand the mempolicy stuff but maybe
> there can be ways to use mpol_rebind_mm and do_migrate_pages when the
> lock is already held.
> 
I agree.
Another solution(just an idea): avoid enabling both "move_charge" feature of memcg
and "memory_migrate" of cpuset at the same time iff they are mounted
under the same mount point. But, hmm... it's not a good idea to make a subsystem
take account of another subsystem, IMHO.


Thanks,
Daisuke Nishimura.
