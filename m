From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHSET cgroup/for-3.16] cgroup: implement unified hierarchy, v2
Date: Tue, 15 Apr 2014 10:23:55 +0800
Message-ID: <534C983B.7080701@huawei.com>
References: <1397511430-2673-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1397511430-2673-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

> This patchset finally implements the default unified hierarchy.  The
> goal is providing enough flexibility while enforcing stricter common
> structure where appropriate to address the above listed issues.
> 
> Controllers which aren't bound to other hierarchies are
> automatically attached to the unified hierarchy, which is different in
> that controllers are enabled explicitly for each subtree.
> "cgroup.subtree_control" controls which controllers are enabled on the
> child cgroups.  Let's assume a hierarchy like the following.
> 
>   root - A - B - C
>                \ D
> 
> root's "cgroup.subtree_control" determines which controllers are
> enabled on A.  A's on B.  B's on C and D.  This coincides with the
> fact that controllers on the immediate sub-level are used to
> distribute the resources of the parent.  In fact, it's natural to
> assume that resource control knobs of a child belong to its parent.
> Enabling a controller in "cgroup.subtree_control" declares that
> distribution of the respective resources of the cgroup will be
> controlled.  Note that this means that controller enable states are
> shared among siblings.
> 
> The default hierarchy has an extra restriction - only cgroups which
> don't contain any task may have controllers enabled in
> "cgroup.subtree_control".  Combined with the other properties of the
> default hierarchy, this guarantees that, from the view point of
> controllers, tasks are only on the leaf cgroups.  In other words, only
> leaf csses may contain tasks.  This rules out situations where child
> cgroups compete against internal tasks of the parent.
> 

Right after bootup:

# mount -t cgroup -o __DEVEL__sane_behavior xxx /mnt
# ls /mnt
cgroup.controllers  cgroup.procs  cgroup.sane_behavior  cgroup.subtree_control
# cat /mnt/cgroup.controllers
cpuset cpu cpuacct memory devices freezer net_cls blkio perf_event hugetlb

I don't see any controller knobs...
