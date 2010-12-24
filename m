From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v5 3/3] cgroups: make procs file writable
Date: Fri, 24 Dec 2010 06:45:00 -0500
Message-ID: <20101224114500.GA18036@ghc17.ghc.andrew.cmu.edu>
References: <20100730235649.GA22644@ghc17.ghc.andrew.cmu.edu>
	<20100811054604.GA8743@ghc17.ghc.andrew.cmu.edu>
	<20100811054851.GD8743@ghc17.ghc.andrew.cmu.edu>
	<AANLkTimRM8rDe+u7fTy853RK=1mnLJMK57Tci2OLPR7L@mail.gmail.com>
	<AANLkTim7HW0wNyqOPePFXmEMV8hx_fMKNMTAsSwkRzZX@mail.gmail.com>
	<AANLkTin7aK5uEFi0U+iU_9=cbfRTHfDzKsbWupn73fSL@mail.gmail.com>
	<20101216002603.6741874a.akpm@linux-foundation.org>
	<20101224033352.GA7804@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012240245040.775@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1012240245040.775-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 24, 2010 at 02:49:43AM -0800, David Rientjes wrote:
> On Thu, 23 Dec 2010, Ben Blum wrote:
> 
> > On Thu, Dec 16, 2010 at 12:26:03AM -0800, Andrew Morton wrote:
> > > Patches have gone a bit stale, sorry.  Refactoring in
> > > kernel/cgroup_freezer.c necessitates a refresh and retest please.
> > 
> > commit 53feb29767c29c877f9d47dcfe14211b5b0f7ebd changed a bunch of stuff
> > in kernel/cpuset.c to allocate nodemasks with NODEMASK_ALLOC (which
> > wraps kmalloc) instead of on the stack.
> > 
> 
> It only wraps kmalloc for CONFIG_NODES_SHIFT > 8.
> 
> > 1. All these functions have 'void' return values, indicating that
> >    calling them them must not fail. Sure there are bailout cases, but no
> >    semblance of cross-function error propagation. Most importantly,
> >    cpuset_attach is a subsystem callback, which MUST not fail given the
> >    way it's used in cgroups, so relying on kmalloc is not safe.
> > 
> 
> Yes, that's a valid concern that should be addressed.

depending on the circumstances that would cause such a failure, and the
consequences of "ignoring" it, would doing a cop-out with WARN_ON() be
appropriate?

> > 2. I'm working on a patch series which needs to hold tasklist_lock
> >    across ss->attach callbacks (in cpuset_attach's "if (threadgroup)"
> >    case, this is how safe traversal of tsk->thread_group will be
> >    ensured), and kmalloc isn't allowed while holding a spin-lock. 
> > 
> 
> kmalloc() is allowed while holding a spinlock and NODEMASK_ALLOC() takes a 
> gfp_flags argument for that reason.

Ah, it's only with GFP_KERNEL and friends. So changing the uses in
cpuset_can_attach to GFP_ATOMIC would solve this concern, then?

Then there are no extra issues with my patchset, but note: the use cases
for calling ->attach are going to be hairy enough that it won't be
reasonable to require the caller to back-track if an allocation fails...

> > Why do we need heap-allocation here at all? In each case their scope is
> > exactly the function's scope, and neither the commit nor the surrounding
> > patch series give any explanation. I'd like to revert the patch if
> > possible.
> > 
> 
> Because some kernels, such as those with CONFIG_NODES_SHIFT > 8, cause 
> stack overflows with the large nodemasks.

Ah. I couldn't find any documentation for what the maximum number of
memory controllers could be. this makes sense.

Thanks!

-- Ben
