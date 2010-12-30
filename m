From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v5 3/3] cgroups: make procs file writable
Date: Wed, 29 Dec 2010 21:49:02 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1012292149000.29486@chino.kir.corp.google.com>
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
	<alpine.DEB.2.00.1012291624210.6040@chino.kir.corp.google.com>
	<4D1C0464.5090801@cn.fujitsu.com>
	<alpine.DEB.2.00.1012292019540.27634@chino.kir.corp.google.com>
	<4D1C0CC6.4090107@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D1C0CC6.4090107-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Thu, 30 Dec 2010, Li Zefan wrote:

> > This needs to be done with cgroup_lock() instead of callback_mutex since 
> > the post_clone() callback will store to cs->mems_allowed on 
> > cgroup_clone().
> > 
> 
> Then cpuset_post_clone() breaks the lock rule:
> 
>  * A task must hold both mutexes to modify cpusets...
>  ...
>  * If a task is only holding callback_mutex, then it has read-only
>  * access to cpusets.
> 
> But that's Ok, because cgroup_clone() is called during the creation of
> the new cgroup, so no one can access the cpuset at that time.
> 

I'm saying that if cpusets implements a cgroup_clone() handler that the 
locking will break with only callback_mutex here because the only 
synchronization after the new cgroup dentry is added is cgroup_lock() that 
is always held when a post_clone callback is invoked and reading a mems 
file may race since it is accessible before the task is attached in the 
cgroup_clone() case.  It's not a problem right now but may subtly break if 
cpusets were to use cgroup_clone().
