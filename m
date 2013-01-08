From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 13/24] cfq-iosched: implement hierarchy-ready cfq_group
	charge scaling
Date: Tue, 8 Jan 2013 11:16:00 -0500
Message-ID: <20130108161600.GD29635@redhat.com>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
	<1356726946-26037-14-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1356726946-26037-14-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Dec 28, 2012 at 12:35:35PM -0800, Tejun Heo wrote:
> Currently, cfqg charges are scaled directly according to cfqg->weight.
> Regardless of the number of active cfqgs or the amount of active
> weights, a given weight value always scales charge the same way.  This
> works fine as long as all cfqgs are treated equally regardless of
> their positions in the hierarchy, which is what cfq currently
> implements.  It can't work in hierarchical settings because the
> interpretation of a given weight value depends on where the weight is
> located in the hierarchy.
> 
> This patch reimplements cfqg charge scaling so that it can be used to
> support hierarchy properly.  The scheme is fairly simple and
> light-weight.
> 
> * When a cfqg is added to the service tree, v(disktime)weight is
>   calculated.  It walks up the tree to root calculating the fraction
>   it has in the hierarchy.  At each level, the fraction can be
>   calculated as
> 
>     cfqg->weight / parent->level_weight
> 
>   By compounding these, the global fraction of vdisktime the cfqg has
>   claim to - vfraction - can be determined.
> 
> * When the cfqg needs to be charged, the charge is scaled inversely
>   proportionally to the vfraction.
> 
> The new scaling scheme uses the same CFQ_SERVICE_SHIFT for fixed point
> representation as before; however, the smallest scaling factor is now
> 1 (ie. 1 << CFQ_SERVICE_SHIFT).  This is different from before where 1
> was for CFQ_WEIGHT_DEFAULT and higher weight would result in smaller
> scaling factor.
> 
> While this shifts the global scale of vdisktime a bit, it doesn't
> change the relative relationships among cfqgs and the scheduling
> result isn't different.
> 
> cfq_group_notify_queue_add uses fixed CFQ_IDLE_DELAY when appending
> new cfqg to the service tree.  The specific value of CFQ_IDLE_DELAY
> didn't have any relevance to vdisktime before and is unlikely to cause
> any visible behavior difference now especially as the scale shift
> isn't that large.
> 
> As the new scheme now makes proper distinction between cfqg->weight
> and ->leaf_weight, reverse the weight aliasing for root cfqgs.  For
> root, both weights are now mapped to ->leaf_weight instead of the
> other way around.
> 
> Because we're still using cfqg_flat_parent(), this patch shouldn't
> change the scheduling behavior in any noticeable way.
> 
> v2: Beefed up comments on vfraction as requested by Vivek.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Looks good to me.

Acked-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Vivek
