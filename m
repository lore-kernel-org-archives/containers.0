From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 11/12] block, bfq: boost the throughput
	on NCQ-capable flash-based devices
Date: Sat, 31 May 2014 07:52:16 -0400
Message-ID: <20140531115216.GB5057@htj.dyndns.org>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<1401354343-5527-12-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1401354343-5527-12-git-send-email-paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Paolo.

So, I've actually looked at the code.  Here are some questions.

On Thu, May 29, 2014 at 11:05:42AM +0200, Paolo Valente wrote:
> + * 1) all active queues have the same weight,
> + * 2) all active groups at the same level in the groups tree have the same
> + *    weight,
> + * 3) all active groups at the same level in the groups tree have the same
> + *    number of children.

3) basically disables it whenever blkcg is used.  Might as well just
skip the whole thing if there are any !root cgroups.  It's only
theoretically interesting.

>  static inline bool bfq_bfqq_must_not_expire(struct bfq_queue *bfqq)
>  {
>  	struct bfq_data *bfqd = bfqq->bfqd;

	bool symmetric_scenario, expire_non_wr;

> +#ifdef CONFIG_CGROUP_BFQIO
> +#define symmetric_scenario	  (!bfqd->active_numerous_groups && \
> +				   !bfq_differentiated_weights(bfqd))

	symmetric_scenario = xxx;

> +#else
> +#define symmetric_scenario	  (!bfq_differentiated_weights(bfqd))

	symmetric_scenario = yyy;

> +#endif
>  /*
>   * Condition for expiring a non-weight-raised queue (and hence not idling
>   * the device).
>   */
>  #define cond_for_expiring_non_wr  (bfqd->hw_tag && \
> -				   bfqd->wr_busy_queues > 0)
> +				   (bfqd->wr_busy_queues > 0 || \
> +				    (symmetric_scenario && \
> +				     blk_queue_nonrot(bfqd->queue))))

	expire_non_wr = zzz;

>  
>  	return bfq_bfqq_sync(bfqq) && (
>  		bfqq->wr_coeff > 1 ||
>  /**
> + * struct bfq_weight_counter - counter of the number of all active entities
> + *                             with a given weight.
> + * @weight: weight of the entities that this counter refers to.
> + * @num_active: number of active entities with this weight.
> + * @weights_node: weights tree member (see bfq_data's @queue_weights_tree
> + *                and @group_weights_tree).
> + */
> +struct bfq_weight_counter {
> +	short int weight;
> +	unsigned int num_active;
> +	struct rb_node weights_node;
> +};

This is way over-engineered.  In most cases, the only time you get the
same weight on all IO issuers would be when everybody is on the
default ioprio so might as well simply count the number of non-default
ioprios.  It'd be one integer instead of a tree of counters.

> @@ -306,6 +322,22 @@ enum bfq_device_speed {
>   * @rq_pos_tree: rbtree sorted by next_request position, used when
>   *               determining if two or more queues have interleaving
>   *               requests (see bfq_close_cooperator()).
> + * @active_numerous_groups: number of bfq_groups containing more than one
> + *                          active @bfq_entity.

You can safely assume that on any system which uses blkcg, the above
counter is >1.

This optimization may be theoretically interesting but doesn't seem
practical at all and would make the sytem behave distinctively
differently depending on something which is extremely subtle and seems
completely unrelated.  Furthermore, on any system which uses blkcg,
ext4, btrfs or has any task which has non-zero nice value, it won't
make any difference.  Its value is only theoretical.

Another thing to consider is that virtually all remotely modern
devices, rotational or not, are queued.  At this point, it's rather
pointless to design one behavior for !queued and another for queued.
Things should just be designed for queued devices.  I don't know what
the solution is but given that the benefits of NCQ for rotational
devices is extremely limited, sticking with single request model in
most cases and maybe allowing queued operation for specific workloads
might be a better approach.  As for ssds, just do something simple.
It's highly likely that most ssds won't travel this code path in the
near future anyway.

Thanks.

-- 
tejun
