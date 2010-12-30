From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5 3/3] cgroups: make procs file writable
Date: Wed, 29 Dec 2010 16:26:53 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1012291624210.6040@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1012240245040.775@chino.kir.corp.google.com>
	<20101224114500.GA18036@ghc17.ghc.andrew.cmu.edu>
	<20101224035331.b907b410.akpm@linux-foundation.org>
	<20101224120853.GA18518@ghc17.ghc.andrew.cmu.edu>
	<20101224212452.GA27275@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012241333010.13509@chino.kir.corp.google.com>
	<20101224230901.GA30136@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012261345340.23173@chino.kir.corp.google.com>
	<20101227001233.GA10951@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012270227010.3960@chino.kir.corp.google.com>
	<20101227103701.GC20986@ghc17.ghc.andrew.cmu.edu>
	<alpine.DEB.2.00.1012270240400.3960@chino.kir.corp.google.com>
	<4D1A913C.5080702@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D1A913C.5080702-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 29 Dec 2010, Li Zefan wrote:

> > I think it would be appropriate to use a shared nodemask with file scope 
> > whenever you have cgroup_lock() to avoid the unnecessary kmalloc() even 
> > with GFP_KERNEL.  Cpusets are traditionally used on very large machines in 
> > the first place, so there is a higher likelihood that 
> > CONFIG_NODES_SHIFT > 8 whenever CONFIG_CPUSETS is enabled.
> > 
> > All users of NODEMASK_ALLOC() should be protected by cgroup_lock() other 
> > than cpuset_sprintf_memlist(), right?  That should be the only remaining 
> > user of NODEMASK_ALLOC() and works well since it can return -ENOMEM.
> > 
> 
> Changing cpuset->mems_allowed is protected by both cgroup_mutex and
> cpuset-specific lock (callback_mutex), so you can read it under either
> lock, so NODEMASK_ALLOC() is not needed. See cpuset_sprintf_cpulist().
> 

I'm not sure what you're saying.  Cpusets needs to allocate nodemasks for 
certain functions and doing on the stack can be problemantic if 
CONFIG_NODES_SHIFT is large because of overflow.  Thus, we can't have 
temporary nodemasks available on the stack where necessary in functions 
like cpuset_attach(), update_nodemask(), etc. that require them.  The 
suggestion was to use a statically allocated "scratch" nodemask since 
these functions are all protected by cgroup_lock().
