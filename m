From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v5 3/3] cgroups: make procs file writable
Date: Sun, 26 Dec 2010 19:12:33 -0500
Message-ID: <20101227001233.GA10951@ghc17.ghc.andrew.cmu.edu>
References: <20101216002603.6741874a.akpm@linux-foundation.org>
	<20101224033352.GA7804@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012240245040.775@chino.kir.corp.google.com>
	<20101224114500.GA18036@ghc17.ghc.andrew.cmu.edu>
	<20101224035331.b907b410.akpm@linux-foundation.org>
	<20101224120853.GA18518@ghc17.ghc.andrew.cmu.edu>
	<20101224212452.GA27275@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012241333010.13509@chino.kir.corp.google.com>
	<20101224230901.GA30136@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012261345340.23173@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1012261345340.23173-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
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

On Sun, Dec 26, 2010 at 01:48:58PM -0800, David Rientjes wrote:
> On Fri, 24 Dec 2010, Ben Blum wrote:
> 
> > I'll add a patch to my current series to do this. Should I leave alone
> > the other cases where an out-of-memory causes a silent failure?
> > (cpuset_change_nodemask, scan_for_empty_cpusets)
> > 
> 
> Both are protected by cgroup_lock, so I think it should be a pretty simple 
> change.  cpuset_change_nodemask() is interesting because a task within an 
> oom cpuset may be changing its own nodemask for more memory and that could 
> easily allow the NODEMASK_ALLOC() to fail for large CONFIG_NODES_SHIFT.  
> scan_for_empty_cpusets() is interesting to avoid leaving the hierarchy in 
> an inconsistent state.  So I think both of these would benefit from having 
> a statically allocated nodemask protected by cgroup_lock().

I was going to make a macro like NODEMASK_STATIC, but it turned out that
can_attach() needed the to/from nodemasks to be shared among three
functions for the attaching, so I defined them globally without making a
macro for it. I can make a separate patch for fixing the other cases,
but I'd like to see my current patches through first. (Or should I make
a bugfix patch first and send my other ones on top of that?)

-- Ben
