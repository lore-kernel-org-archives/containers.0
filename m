From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCHSET] cgroup: implement task_cgroup_path_from_hierarchy()
Date: Sun, 14 Apr 2013 20:22:33 -0700
Message-ID: <20130415032233.GI3050__7169.00019110671$1365996170$gmane$org@htj.dyndns.org>
References: <1365964619-14762-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1365964619-14762-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Apr 14, 2013 at 11:36:55AM -0700, Tejun Heo wrote:
> kdbus folks want a sane way to determine the cgroup path that a given
> task belongs to on a given hierarchy, which is a reasonble thing to
> expect from cgroup core.
> 
> This patchset make hierarchy_id allocation use idr instead of ida and
> implement task_cgroup_path_from_hierarchy().  In the process, the
> yucky ida cyclic allocation is replaced with idr_alloc_cyclic().
> 
>  0001-cgroup-refactor-hierarchy_id-handling.patch
>  0002-cgroup-drop-hierarchy_id_lock.patch
>  0003-cgroup-make-hierarchy_id-use-cyclic-idr.patch
>  0004-cgroup-implement-task_cgroup_path_from_hierarchy.patch
> 
> 0001-0002 prepare for conversion to idr, which 0003 does.
> 
> 0004 implements the new function.
> 
> This patchset is on top of next-20130412 as idr_alloc_cyclic() patch
> is currently in -mm.  Given that this isn't an urgent thing and the
> merge window is just around the corner, it'd be probably best to route
> these through cgroup/for-3.11 once v3.10-rc1 drops.
> 
> These patches are also available in the following git branch.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-task_cgroup_path_from_hierarchy
> 
> And it actually reduces LOC.  Woot Woot.
> 
>  include/linux/cgroup.h |    2
>  kernel/cgroup.c        |  128 +++++++++++++++++++++++++++++++++----------------
>  2 files changed, 89 insertions(+), 41 deletions(-)

Heh, I must have been tripping or something.  89 > 41.  It's still a
lot cleaner tho. :)

-- 
tejun
