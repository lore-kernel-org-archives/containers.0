From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 7/8] blkcg: implement per-queue policy activation
Date: Fri, 13 Apr 2012 11:23:50 -0400
Message-ID: <20120413152350.GD26383__31537.56441684$1334330640$gmane$org@redhat.com>
References: <1334273380-30233-1-git-send-email-tj@kernel.org>
	<1334273380-30233-8-git-send-email-tj@kernel.org>
	<20120413152122.GC26383@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120413152122.GC26383-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Fri, Apr 13, 2012 at 11:21:22AM -0400, Vivek Goyal wrote:
> On Thu, Apr 12, 2012 at 04:29:39PM -0700, Tejun Heo wrote:
> 
> [..]
> > @@ -111,12 +122,11 @@ static struct blkio_group *blkg_alloc(struct blkio_cgroup *blkcg,
> >  		struct blkio_policy_type *pol = blkio_policy[i];
> >  		struct blkg_policy_data *pd;
> >  
> > -		if (!pol)
> > +		if (!blkcg_policy_enabled(q, pol))
> >  			continue;
> >  
> >  		/* alloc per-policy data and attach it to blkg */
> > -		pd = kzalloc_node(sizeof(*pd) + pol->pdata_size, GFP_ATOMIC,
> > -				  q->node);
> > +		pd = kzalloc_node(blkg_pd_size(pol), GFP_ATOMIC, q->node);
> >  		if (!pd) {
> >  			blkg_free(blkg);
> >  			return NULL;
> > @@ -130,7 +140,7 @@ static struct blkio_group *blkg_alloc(struct blkio_cgroup *blkcg,
> >  	for (i = 0; i < BLKCG_MAX_POLS; i++) {
> >  		struct blkio_policy_type *pol = blkio_policy[i];
> >  
> > -		if (pol)
> > +		if (blkcg_policy_enabled(blkg->q, pol))
> >  			pol->ops.blkio_init_group_fn(blkg);
> >  	}
> 
> May be pol->ops.blkio_init_group_fn() can be called in the loop above
> where you are allocating the group. So you don't end up looping through
> policies twice and don't have to call blkcg_policy_enabled() twice.

Oh..., I guess you did it because you did not want to call into individual
policies till all the policy data allocations were successfully done.
Otherwise you need to call into policies again to undo all initializations.

So yes, it is fine as it is.

Thanks
Vivek
