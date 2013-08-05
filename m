From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.12] cgroup: make css_for_each_descendant()
	and friends include the origin css in the iteration
Date: Mon, 5 Aug 2013 11:29:41 -0400
Message-ID: <20130805152941.GB6440@redhat.com>
References: <20130804230703.GA12029@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130804230703.GA12029-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Aug 04, 2013 at 07:07:03PM -0400, Tejun Heo wrote:
> Hello,
> 
> I've been wanting to do this for some time and given all the recent
> API updates now seems like a pretty good opportunity.  Verified
> freezer and blkcg.  The conversions are mostly straight forward but
> I'd much appreciate acks from controller maintainers.
> 
> The patch is on top of
> 
>   cgroup/for-3.12 61584e3f4 ("cgroup: Merge branch 'for-3.11-fixes' into for-3.12")
> + [1] cgroup: use cgroup_subsys_state as the primary subsystem interface handle
> + [2] cgroup: make cgroup_event specific to memcg
> 
> and available in the following git branch.
> 
>  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-descendant-update
> 
> Thanks.
> 
> [1] https://lkml.org/lkml/2013/8/1/722
> [2] http://thread.gmane.org/gmane.linux.kernel.cgroups/8726
> 
> ------- 8< -------
> 
> >From 0e84b0865ab8a87f1c1443e4777c20c7f14e13b6 Mon Sep 17 00:00:00 2001
> From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Date: Sun, 4 Aug 2013 19:01:23 -0400
> 
> Previously, all css descendant iterators didn't include the origin
> (root of subtree) css in the iteration.  The reasons were maintaining
> consistency with css_for_each_child() and that at the time of
> introduction more use cases needed skipping the origin anyway;
> however, given that css_is_descendant() considers self to be a
> descendant, omitting the origin css has become more confusing and
> looking at the accumulated use cases rather clearly indicates that
> including origin would result in simpler code overall.
> 
> While this is a change which can easily lead to subtle bugs, cgroup
> API including the iterators has recently gone through major
> restructuring and no out-of-tree changes will be applicable without
> adjustments making this a relatively acceptable opportunity for this
> type of change.
> 
> The conversions are mostly straight-forward.  If the iteration block
> had explicit origin handling before or after, it's moved inside the
> iteration.  If not, if (pos == origin) continue; is added.  Some
> conversions add extra reference get/put around origin handling by
> consolidating origin handling and the rest.  While the extra ref
> operations aren't strictly necessary, this shouldn't cause any
> noticeable difference.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
> Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
> Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  block/blk-cgroup.c       |  8 ++------
>  block/blk-cgroup.h       |  4 +++-
>  block/blk-throttle.c     |  3 ---

block/ bits look good to me.

Acked-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Vivek
