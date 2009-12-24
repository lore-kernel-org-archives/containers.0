From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH] cgroups: fix 2.6.32 regression causing BUG_ON() in cgroup_diput()
Date: Thu, 24 Dec 2009 13:47:15 +0800
Message-ID: <4B330063.2030202@cn.fujitsu.com>
References: <4B32660A.8070106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753686AbZLXFr2@vger.kernel.org>
In-Reply-To: <4B32660A.8070106@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Anderson <anderson@redhat.com>
Cc: menage@google.com, linux-kernel@vger.kernel.org, Ben Blum <bblum@andrew.cmu.edu>, Andrew Morton <akpm@linux-foundation.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

CC: Andrew
CC: Container list

Dave Anderson wrote:
> 
> The LTP cgroup test suite generates a "kernel BUG at kernel/cgroup.c:790!"
> here in cgroup_diput():
> 
>                 /*
>                  * if we're getting rid of the cgroup, refcount should
> ensure
>                  * that there are no pidlists left.
>                  */
>                 BUG_ON(!list_empty(&cgrp->pidlists));
> 

Good catch. Thanks!

This BUG can be easily triggered if 2 threads are reading the same cgroup's
tasks file at the same time, and then the cgroup gets removed.

And this patch needs to be added to 2.6.32.x.

> The cgroup pidlist rework in 2.6.32 generates the BUG_ON, which is caused
> when pidlist_array_load() calls cgroup_pidlist_find():
> 
> (1) if a matching cgroup_pidlist is found, it down_write's the mutex of the
>     pre-existing cgroup_pidlist, and increments its use_count.
> (2) if no matching cgroup_pidlist is found, then a new one is allocated, it
>     down_write's its mutex, and the use_count is set to 0.
> (3) the matching, or new, cgroup_pidlist gets returned back to
> pidlist_array_load(),
>     which increments its use_count -- regardless whether new or
> pre-existing --
>     and up_write's the mutex.
> 
> So if a matching list is ever encountered by cgroup_pidlist_find() during
> the life of a cgroup directory, it results in an inflated use_count value,
> preventing it from ever getting released by cgroup_release_pid_array().
> Then if the directory is subsequently removed, cgroup_diput() hits the
> BUG_ON() when it finds that the directory's cgroup is still populated
> with a pidlist.
> 
> The patch simply removes the use_count increment when a matching
> pidlist is found by cgroup_pidlist_find(), because it gets bumped by
> the calling pidlist_array_load() function while still protected by the
> list's mutex.
> 
> Signed-off-by: Dave Anderson <anderson@redhat.com>
> 

Reviewed-by: Li Zefan <lizf@cn.fujitsu.com>
