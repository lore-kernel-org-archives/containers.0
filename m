From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [PATCH v5 3/3] cgroups: make procs file writable
Date: Mon, 27 Dec 2010 06:00:50 -0500
Message-ID: <20101227110050.GF20986@ghc17.ghc.andrew.cmu.edu>
References: <20101224035331.b907b410.akpm@linux-foundation.org>
	<20101224120853.GA18518@ghc17.ghc.andrew.cmu.edu>
	<20101224212452.GA27275@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012241333010.13509@chino.kir.corp.google.com>
	<20101224230901.GA30136@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012261345340.23173@chino.kir.corp.google.com>
	<20101227001233.GA10951@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012270227010.3960@chino.kir.corp.google.com>
	<20101227103701.GC20986@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012270240400.3960@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1012270240400.3960-X6Q0R45D7oAcqpCFd4KODRPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
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

On Mon, Dec 27, 2010 at 02:53:47AM -0800, David Rientjes wrote:
> On Mon, 27 Dec 2010, Ben Blum wrote:
> 
> > > I'm not sure what the benefit of defining it as a macro would be.  You're 
> > > defining these statically allocated nodemasks so they have file scope, I 
> > > hope (so they can be shared amongst the users who synchronize on 
> > > cgroup_lock() already).
> > 
> > In the attach() case, yes, but in other cases I was thinking they could
> > be put on the stack if CONFIG_NODES_SHIFT < 8, and static but still
> > per-function otherwise. Or should all the functions share the same
> > global nodemask?
> > 
> 
> I think it would be appropriate to use a shared nodemask with file scope 
> whenever you have cgroup_lock() to avoid the unnecessary kmalloc() even 
> with GFP_KERNEL.  Cpusets are traditionally used on very large machines in 
> the first place, so there is a higher likelihood that 
> CONFIG_NODES_SHIFT > 8 whenever CONFIG_CPUSETS is enabled.
> 
> All users of NODEMASK_ALLOC() should be protected by cgroup_lock() other 
> than cpuset_sprintf_memlist(), right?  That should be the only remaining 
> user of NODEMASK_ALLOC() and works well since it can return -ENOMEM.

Just checked; that looks right. Perhaps I should add cgroup_is_locked()
in cgroup.c and BUG_ON() checks for it in those functions, too?

-- Ben
