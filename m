From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Subject: Re: [RFC] [PATCH 1/5] cgroups: revamp subsys array
Date: Thu, 10 Dec 2009 01:13:32 -0500
Message-ID: <20091210061332.GC11893__35744.2949818962$1260425666$gmane$org@andrew.cmu.edu>
References: <20091204085349.GA18867@andrew.cmu.edu>
	<20091204085508.GA18912@andrew.cmu.edu>
	<4B1E0283.70108@cn.fujitsu.com>
	<20091209055016.GA12342@andrew.cmu.edu>
	<4B1F3EB9.6080502@cn.fujitsu.com>
	<20091209082729.GA14114@andrew.cmu.edu>
	<4B20686E.3070907@cn.fujitsu.com>
	<20091210051912.GA11893@andrew.cmu.edu>
	<4B208E7D.8020306@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4B208E7D.8020306-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Dec 10, 2009 at 02:00:29PM +0800, Li Zefan wrote:
> Yes, but it doesn't mean we should use rw lock or rw semaphore is
> preferable than plain mutex.
> 
> - the read side of subsys_mutex is mainly at mount/remount/umount,
>   the write side is in cgroup_load_subsys() and cgroup_unload_subsys().
>   None is in critical path.
> 
> - In most callsites, cgroup_mutex is held just after acquiring
>   subsys_mutex.
> 
> So what does it gain us to use this rw_sem?
> 
> >> And why not just use cgroup_mutex to protect the subsys[] array?
> >> The adding and spreading of subsys_mutex looks ugly to me.
> > 
> > The reasoning for this is that there are various chunks of code that
> > need to be protected by a mutex guarding subsys[] that aren't already
> > under cgroup_mutex - like parse_cgroupfs_options, or the first stage
> > of cgroup_load_subsys. Do you think those critical sections are small
> > enough that sacrificing reentrancy for simplicity of code is worth it?
> > 
> 
> Except parse_cgroupfs_options() which is called without cgroup_mutex
> held, in all other callsites, cgroup_mutex is held right after acquiring
> subsys_mutex.
> 
> So yes, I don't think use cgroup_mutex will harm scalibility.
> 
> In contrast, this subsys_mutex is quite ugly and deadlock-prone.

to be fair the deadlock case would still be as much to worry about
if we were protecting subsys[] with cgroup_mutex instead.

> For example, see this:
> 
> static int cgroup_remount(struct super_block *sb, int *flags, char *data)
> {
> 	...
>         lock_kernel();
>         mutex_lock(&cgrp->dentry->d_inode->i_mutex);
>         down_read(&subsys_mutex);
>         mutex_lock(&cgroup_mutex);
> 	...
> }
> 
> Four locks here!
> 
> 

if we really don't care about performance in those places, it doesn't
really gain anything. when I presented the previous patch series, one
guy (at google) asked me if anything could be done about the "big ugly
cgroup_mutex" and that he wished most of cgroups could be less all under
one single lock. so, I wrote this with that in mind...

anyway, I think the best solution here is - whichever lock ends up being
used for this - have parse_cgroupfs_options and rebind_subsystems each
take the lock when they are called and drop before returning, instead of
having their calling functions hold the lock between calls. division of
labour would be that parse_cgroupfs_options takes the module refcounts,
and that rebind_subsystems drops them.
