From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] [PATCH 1/5] cgroups: revamp subsys array
Date: Thu, 10 Dec 2009 14:00:29 +0800
Message-ID: <4B208E7D.8020306@cn.fujitsu.com>
References: <20091204085349.GA18867@andrew.cmu.edu>
	<20091204085508.GA18912@andrew.cmu.edu>
	<4B1E0283.70108@cn.fujitsu.com>
	<20091209055016.GA12342@andrew.cmu.edu>
	<4B1F3EB9.6080502@cn.fujitsu.com>
	<20091209082729.GA14114@andrew.cmu.edu>
	<4B20686E.3070907@cn.fujitsu.com>
	<20091210051912.GA11893@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091210051912.GA11893-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

>>> How does this sound as a possible solution, in cgroup_get_sb:
>>>
>>> 1) Take subsys_mutex
>>> 2) Call parse_cgroupfs_options()
>>> 3) Drop subsys_mutex
>>> 4) Call sget(), which gets sb->s_umount without subsys_mutex held
>>> 5) Take subsys_mutex
>>> 6) Call verify_cgroupfs_options()
>>> 7) Proceed as normal
>>>
>>> In which verify_cgroupfs_options will be a new function that ensures the
>>> invariants that rebind_subsystems expects are still there; if not, bail
>>> out by jumping to drop_new_super just as if parse_cgroupfs_options had
>>> failed in the first place.
>>>
>> The current code doesn't need this verify_cgroupfs_options, so why it
>> will become necessary? I think what we need is grab module refcnt in
>> parse_cgroupfs_options, and then we can drop subsys_mutex.
> 
> Oh, good point. I thought pinning the modules had to happen in rebinding
> since there's a case where rebind_subsystems is called without parsing,
> but that's just in kill_sb where no new subsystems are added. So, better
> would be to make sure we can't get owned while we drop the lock instead
> of checking afterwards if we got owned and bailing if so.
> 
>> But why you are using a rw semaphore? I think a mutex is fine.
> 
> The "most of cgroups wants to look at the subsys array" versus "module
> loading/unloading modifies the array" is clearly a readers/writers case.
> 

Yes, but it doesn't mean we should use rw lock or rw semaphore is
preferable than plain mutex.

- the read side of subsys_mutex is mainly at mount/remount/umount,
  the write side is in cgroup_load_subsys() and cgroup_unload_subsys().
  None is in critical path.

- In most callsites, cgroup_mutex is held just after acquiring
  subsys_mutex.

So what does it gain us to use this rw_sem?

>> And why not just use cgroup_mutex to protect the subsys[] array?
>> The adding and spreading of subsys_mutex looks ugly to me.
> 
> The reasoning for this is that there are various chunks of code that
> need to be protected by a mutex guarding subsys[] that aren't already
> under cgroup_mutex - like parse_cgroupfs_options, or the first stage
> of cgroup_load_subsys. Do you think those critical sections are small
> enough that sacrificing reentrancy for simplicity of code is worth it?
> 

Except parse_cgroupfs_options() which is called without cgroup_mutex
held, in all other callsites, cgroup_mutex is held right after acquiring
subsys_mutex.

So yes, I don't think use cgroup_mutex will harm scalibility.

In contrast, this subsys_mutex is quite ugly and deadlock-prone.
For example, see this:

static int cgroup_remount(struct super_block *sb, int *flags, char *data)
{
	...
        lock_kernel();
        mutex_lock(&cgrp->dentry->d_inode->i_mutex);
        down_read(&subsys_mutex);
        mutex_lock(&cgroup_mutex);
	...
}

Four locks here!
