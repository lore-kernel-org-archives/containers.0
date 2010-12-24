From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v5 3/3] cgroups: make procs file writable
Date: Fri, 24 Dec 2010 16:24:52 -0500
Message-ID: <20101224212452.GA27275@ghc17.ghc.andrew.cmu.edu>
References: <20100811054851.GD8743@ghc17.ghc.andrew.cmu.edu>
	<AANLkTimRM8rDe+u7fTy853RK=1mnLJMK57Tci2OLPR7L@mail.gmail.com>
	<AANLkTim7HW0wNyqOPePFXmEMV8hx_fMKNMTAsSwkRzZX@mail.gmail.com>
	<AANLkTin7aK5uEFi0U+iU_9=cbfRTHfDzKsbWupn73fSL@mail.gmail.com>
	<20101216002603.6741874a.akpm@linux-foundation.org>
	<20101224033352.GA7804@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012240245040.775@chino.kir.corp.google.com>
	<20101224114500.GA18036@ghc17.ghc.andrew.cmu.edu>
	<20101224035331.b907b410.akpm@linux-foundation.org>
	<20101224120853.GA18518@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101224120853.GA18518-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Dec 24, 2010 at 07:08:53AM -0500, Ben Blum wrote:
> On Fri, Dec 24, 2010 at 03:53:31AM -0800, Andrew Morton wrote:
> > On Fri, 24 Dec 2010 06:45:00 -0500 Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> > 
> > > > kmalloc() is allowed while holding a spinlock and NODEMASK_ALLOC() takes a 
> > > > gfp_flags argument for that reason.
> > > 
> > > Ah, it's only with GFP_KERNEL and friends. So changing the uses in
> > > cpuset_can_attach to GFP_ATOMIC would solve this concern, then?
> > 
> > It would introduce an additional concern.  GFP_ATOMIC is bad, for a
> > number of reasons.  The main one of which is that it is vastly less
> > reliable than GFP_KERNEL.  And making the cpuset code less reliable
> > is a regression, no?
> > 
> > Please try to find a better solution.
> 
> Good point. How about pre-allocating the nodemasks in cpuset_can_attach,
> and having a cpuset_cancel_attach function which can free them up?
> 
> They could be stored in the struct cpuset (protected by cgroup_mutex)
> after being pre-allocated - but also only if a heap-allocation was
> required, so there might need to be an extra interface, like
> "NODEMASK_PREALLOC" (a no-op if heap not required, otherwise allocates
> and stores in the struct cpuset) and "NODEMASK_RETRIEVE"?
> 
> -- Ben

Oh, also, most (not all) times that NODEMASK_ALLOC is used in cpusets,
cgroup_mutex is also held. So how about just using static storage for
them? (There could be a new macro "NODEMASK_ALLOC_STATIC", for use when
the caller can never race against itself.) As long as the call-graph
isn't recursive, there shouldn't be a problem...

-- Ben
