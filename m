From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 01/12] block: introduce the BFQ-v0 I/O
	scheduler
Date: Fri, 30 May 2014 11:36:08 -0400
Message-ID: <20140530153608.GA24871@htj.dyndns.org>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<1401354343-5527-2-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1401354343-5527-2-git-send-email-paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
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

Hello,

On Thu, May 29, 2014 at 11:05:32AM +0200, Paolo Valente wrote:
> diff --git a/block/bfq-ioc.c b/block/bfq-ioc.c
> new file mode 100644
> index 0000000..adfb5a1
> --- /dev/null
> +++ b/block/bfq-ioc.c
> @@ -0,0 +1,34 @@
> +/*
> + * BFQ: I/O context handling.
> + *
> + * Based on ideas and code from CFQ:
> + * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
> + *
> + * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
> + *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
> + */
> +
> +/**
> + * icq_to_bic - convert iocontext queue structure to bfq_io_cq.
> + * @icq: the iocontext queue.
> + */
> +static inline struct bfq_io_cq *icq_to_bic(struct io_cq *icq)
> +{
> +	/* bic->icq is the first member, %NULL will convert to %NULL */
> +	return container_of(icq, struct bfq_io_cq, icq);
> +}
> +
> +/**
> + * bfq_bic_lookup - search into @ioc a bic associated to @bfqd.
> + * @bfqd: the lookup key.
> + * @ioc: the io_context of the process doing I/O.
> + *
> + * Queue lock must be held.
> + */
> +static inline struct bfq_io_cq *bfq_bic_lookup(struct bfq_data *bfqd,
> +					       struct io_context *ioc)
> +{
> +	if (ioc)
> +		return icq_to_bic(ioc_lookup_icq(ioc, bfqd->queue));
> +	return NULL;
> +}

Ugh.... please don't split files into C files which get included into
other C files.  It is useful sometimes but the usage here seems
arbitrary.  If you wanna split it into multiple files, make them
proper header or source files which get linked together.  That said,
why split it up at all?  Sure, it's a largish file but just puttings
things in sensible order shouldn't be any more difficult to follow.

...
> +#define BFQQ_SEEK_THR	 (sector_t)(8 * 1024)
> +#define BFQQ_SEEKY(bfqq) ((bfqq)->seek_mean > BFQQ_SEEK_THR)

This probably comes from following cfq but it's only historical that
we have some helpers as functions and others as functions.  Might as
well make them proper functions if you're redoing the whole thing
anyway.  More on this later tho.

> +/*
> + * We regard a request as SYNC, if either it's a read or has the SYNC bit
> + * set (in which case it could also be a direct WRITE).
> + */
> +static inline int bfq_bio_sync(struct bio *bio)

Compiler should be able to decide whether inlining is beneficial or
not.  Applies to other helpers too.

> +static inline unsigned long bfq_serv_to_charge(struct request *rq,
> +					       struct bfq_queue *bfqq)
> +{
> +	return blk_rq_sectors(rq);
> +}

Are this type of simple wrappers actually helpful?  Does't it
obfuscate more than help?  It's not like "we're charging by sectors"
is a concept difficult to grasp requiring an extra layer of
interpretation.

> +static struct request *bfq_find_rq_fmerge(struct bfq_data *bfqd,
> +					  struct bio *bio)
> +{
> +	struct task_struct *tsk = current;
> +	struct bfq_io_cq *bic;
> +	struct bfq_queue *bfqq;
> +
> +	bic = bfq_bic_lookup(bfqd, tsk->io_context);
> +	if (bic == NULL)
> +		return NULL;
> +
> +	bfqq = bic_to_bfqq(bic, bfq_bio_sync(bio));
> +	if (bfqq != NULL)

Can we please avoid "!= NULL"?  This is unnecessary double negation.
Please just do "if (bfqq)".  Likewise, "if (!bic)".

> +/*
> + * If enough samples have been computed, return the current max budget
> + * stored in bfqd, which is dynamically updated according to the
> + * estimated disk peak rate; otherwise return the default max budget
> + */
> +static inline unsigned long bfq_max_budget(struct bfq_data *bfqd)
> +{
> +	if (bfqd->budgets_assigned < 194)
                                     ^^^
This constant seems to be repeated multiple times.  Maybe define it
with a meaningful explanation?

> +		return bfq_default_max_budget;
> +	else
> +		return bfqd->bfq_max_budget;
> +}
....
> +static unsigned long bfq_default_budget(struct bfq_data *bfqd,
> +					struct bfq_queue *bfqq)
> +{
> +	unsigned long budget;
> +
> +	/*
> +	 * When we need an estimate of the peak rate we need to avoid
> +	 * to give budgets that are too short due to previous measurements.
> +	 * So, in the first 10 assignments use a ``safe'' budget value.
> +	 */
> +	if (bfqd->budgets_assigned < 194 && bfqd->bfq_user_max_budget == 0)

Is it really necessary to let the userland configure max_budget
outside development and debugging?  I'll talk about this more but this
is something completely implementation dependent.  If a tunable needs
to be exposed, it usually is a much better idea to actually
characterize why something needs to be tuned and expose the underlying
semantics rather than just let userland directly diddle with internal
details.

> +		budget = bfq_default_max_budget;
> +	else
> +		budget = bfqd->bfq_max_budget;
> +
> +	return budget - budget / 4;
> +}
> +
> +/*
> + * Return min budget, which is a fraction of the current or default
> + * max budget (trying with 1/32)
> + */
> +static inline unsigned long bfq_min_budget(struct bfq_data *bfqd)
> +{
> +	if (bfqd->budgets_assigned < 194)
> +		return bfq_default_max_budget / 32;
> +	else
> +		return bfqd->bfq_max_budget / 32;
> +}

Does budget need to be unsigned long?  Using ulong for something which
isn't for bitops or a quantity closely related to address space is
usually wrong because it may be either 32 or 64bit and the quantity
not having anything to do with address space, it just ends up being
used as 32bit value.  Just use int?

Similar thing with using unsigned values for quantities which don't
really require the extra bit.  This is more debatable but using
unsigned often doesn't really buy anything.  It's not like C has
underflow protection.  You often just end up needing overly elaborate
underflow check when < 0 would do.

> +/*
> + * Move request from internal lists to the request queue dispatch list.
> + */
> +static void bfq_dispatch_insert(struct request_queue *q, struct request *rq)
> +{
> +	struct bfq_data *bfqd = q->elevator->elevator_data;
> +	struct bfq_queue *bfqq = RQ_BFQQ(rq);
> +
> +	/*
> +	 * For consistency, the next instruction should have been executed
> +	 * after removing the request from the queue and dispatching it.
> +	 * We execute instead this instruction before bfq_remove_request()
> +	 * (and hence introduce a temporary inconsistency), for efficiency.
> +	 * In fact, in a forced_dispatch, this prevents two counters related
> +	 * to bfqq->dispatched to risk to be uselessly decremented if bfqq
> +	 * is not in service, and then to be incremented again after
> +	 * incrementing bfqq->dispatched.
> +	 */

I'm having trouble following the above.  How is it "temporarily
inconsistent" when the whole thing is being performed atomically under
queue lock?

> +	bfqq->dispatched++;
> +	bfq_remove_request(rq);
> +	elv_dispatch_sort(q, rq);
> +
> +	if (bfq_bfqq_sync(bfqq))
> +		bfqd->sync_flight++;
> +}
...
> +static inline unsigned long bfq_bfqq_budget_left(struct bfq_queue *bfqq)
> +{
> +	struct bfq_entity *entity = &bfqq->entity;
> +	return entity->budget - entity->service;
> +}

Wouldn't it be easier to read if you collect all the trivial helpers
in one place?

> +/**
> + * __bfq_bfqq_recalc_budget - try to adapt the budget to the @bfqq behavior.
> + * @bfqd: device data.
> + * @bfqq: queue to update.
> + * @reason: reason for expiration.
> + *
> + * Handle the feedback on @bfqq budget.  See the body for detailed
> + * comments.

Would be nicer if it explained when this function is called.

> + */
> +static void __bfq_bfqq_recalc_budget(struct bfq_data *bfqd,
> +				     struct bfq_queue *bfqq,
> +				     enum bfqq_expiration reason)
> +{
> +	struct request *next_rq;
> +	unsigned long budget, min_budget;
> +
> +	budget = bfqq->max_budget;
> +	min_budget = bfq_min_budget(bfqd);
> +
> +	bfq_log_bfqq(bfqd, bfqq, "recalc_budg: last budg %lu, budg left %lu",
> +		bfqq->entity.budget, bfq_bfqq_budget_left(bfqq));
> +	bfq_log_bfqq(bfqd, bfqq, "recalc_budg: last max_budg %lu, min budg %lu",
> +		budget, bfq_min_budget(bfqd));
> +	bfq_log_bfqq(bfqd, bfqq, "recalc_budg: sync %d, seeky %d",
> +		bfq_bfqq_sync(bfqq), BFQQ_SEEKY(bfqd->in_service_queue));
> +
> +	if (bfq_bfqq_sync(bfqq)) {
> +		switch (reason) {
> +		/*
> +		 * Caveat: in all the following cases we trade latency
> +		 * for throughput.
> +		 */
> +		case BFQ_BFQQ_TOO_IDLE:
> +			if (budget > min_budget + BFQ_BUDGET_STEP)
> +				budget -= BFQ_BUDGET_STEP;
> +			else
> +				budget = min_budget;

Yeah, exactly, things like this could have been written like the
following if budgets were ints.

			budget = max(budget - BFQ_BUDGET_STOP, min_budget);

...
> +		}
> +	} else /* async queue */
> +	    /* async queues get always the maximum possible budget
> +	     * (their ability to dispatch is limited by
> +	     * @bfqd->bfq_max_budget_async_rq).
> +	     */
> +		budget = bfqd->bfq_max_budget;

	} else {
		/*
		 * Asnyc queues get...
		 */
	}

> +
> +	bfqq->max_budget = budget;
> +
> +	if (bfqd->budgets_assigned >= 194 && bfqd->bfq_user_max_budget == 0 &&
                                      ^^^
                                    the magic number again

> +	    bfqq->max_budget > bfqd->bfq_max_budget)
> +		bfqq->max_budget = bfqd->bfq_max_budget;

The following would be easier to follow.

	if (bfqd->budgets_assigned >= 194 && !bfqd->bfq_user_max_budget)
		bfqq->max_budget = min(bfqq->max_budget, bfqd->bfq_max_budget);

> +
> +	/*
> +	 * Make sure that we have enough budget for the next request.
> +	 * Since the finish time of the bfqq must be kept in sync with
> +	 * the budget, be sure to call __bfq_bfqq_expire() after the
> +	 * update.
> +	 */
> +	next_rq = bfqq->next_rq;
> +	if (next_rq != NULL)
> +		bfqq->entity.budget = max_t(unsigned long, bfqq->max_budget,
> +					    bfq_serv_to_charge(next_rq, bfqq));
> +	else
> +		bfqq->entity.budget = bfqq->max_budget;
> +
> +	bfq_log_bfqq(bfqd, bfqq, "head sect: %u, new budget %lu",
> +			next_rq != NULL ? blk_rq_sectors(next_rq) : 0,
> +			bfqq->entity.budget);
> +}
> +
> +static unsigned long bfq_calc_max_budget(u64 peak_rate, u64 timeout)
> +{
> +	unsigned long max_budget;
> +
> +	/*
> +	 * The max_budget calculated when autotuning is equal to the
> +	 * amount of sectors transfered in timeout_sync at the
> +	 * estimated peak rate.
> +	 */
> +	max_budget = (unsigned long)(peak_rate * 1000 *
> +				     timeout >> BFQ_RATE_SHIFT);

What's up with the "* 1000"? Is peak_rate in bytes/us and max_budget
in bytes/ms?  If so, would it be difficult to stick with single unit
of time or at least document it clearly?

> +
> +	return max_budget;

Why not just do the following?

	return (unsigned long)(peak_rate * 100 *...)

Also, what's up with the (unsigned long) conversion after all the
calculation is done?  The compiler is gonna do that implicitly anyway
and the cast won't even cause a warning even if the return type later
gets changed to something else.  The cast achieves nothing.

> +/*
> + * In addition to updating the peak rate, checks whether the process
> + * is "slow", and returns 1 if so. This slow flag is used, in addition
> + * to the budget timeout, to reduce the amount of service provided to
> + * seeky processes, and hence reduce their chances to lower the
> + * throughput. See the code for more details.
> + */
> +static int bfq_update_peak_rate(struct bfq_data *bfqd, struct bfq_queue *bfqq,

          bool

> +				int compensate)

                                bool

Applies to other booleans values too.

> +{
> +	u64 bw, usecs, expected, timeout;
> +	ktime_t delta;
> +	int update = 0;
> +
> +	if (!bfq_bfqq_sync(bfqq) || bfq_bfqq_budget_new(bfqq))
> +		return 0;
> +
> +	if (compensate)
> +		delta = bfqd->last_idling_start;
> +	else
> +		delta = ktime_get();
> +	delta = ktime_sub(delta, bfqd->last_budget_start);
> +	usecs = ktime_to_us(delta);
> +
> +	/* Don't trust short/unrealistic values. */
> +	if (usecs < 100 || usecs >= LONG_MAX)

LONG_MAX is the limit?  It's weird.  Why would the limit on time
measure be different on 32 and 64bit machines?  Also how would you
ever get a number that large?

> +		return 0;
> +
> +	/*
> +	 * Calculate the bandwidth for the last slice.  We use a 64 bit
> +	 * value to store the peak rate, in sectors per usec in fixed
> +	 * point math.  We do so to have enough precision in the estimate
> +	 * and to avoid overflows.
> +	 */
> +	bw = (u64)bfqq->entity.service << BFQ_RATE_SHIFT;
> +	do_div(bw, (unsigned long)usecs);
> +
> +	timeout = jiffies_to_msecs(bfqd->bfq_timeout[BLK_RW_SYNC]);
> +
> +	/*
> +	 * Use only long (> 20ms) intervals to filter out spikes for
> +	 * the peak rate estimation.
> +	 */
> +	if (usecs > 20000) {

Would it make sense to define this value as a fraction of max timeout?

> +		if (bw > bfqd->peak_rate) {
> +			bfqd->peak_rate = bw;
> +			update = 1;
> +			bfq_log(bfqd, "new peak_rate=%llu", bw);
> +		}
> +
> +		update |= bfqd->peak_rate_samples == BFQ_PEAK_RATE_SAMPLES - 1;
> +
> +		if (bfqd->peak_rate_samples < BFQ_PEAK_RATE_SAMPLES)
> +			bfqd->peak_rate_samples++;
> +
> +		if (bfqd->peak_rate_samples == BFQ_PEAK_RATE_SAMPLES &&
> +		    update && bfqd->bfq_user_max_budget == 0) {

The code here seems confusing.  Can you please try to reorder them so
that the condition being checked is clearer?

> +static void bfq_bfqq_expire(struct bfq_data *bfqd,
> +			    struct bfq_queue *bfqq,
> +			    int compensate,
> +			    enum bfqq_expiration reason)
> +{
> +	int slow;
> +
> +	/* Update disk peak rate for autotuning and check whether the

/*
 * Updated...

> +	 * process is slow (see bfq_update_peak_rate).
> +	 */
> +	slow = bfq_update_peak_rate(bfqd, bfqq, compensate);
> +
> +	/*
> +	 * As above explained, 'punish' slow (i.e., seeky), timed-out
> +	 * and async queues, to favor sequential sync workloads.
> +	 */
> +	if (slow || reason == BFQ_BFQQ_BUDGET_TIMEOUT)
> +		bfq_bfqq_charge_full_budget(bfqq);
> +
> +	bfq_log_bfqq(bfqd, bfqq,
> +		"expire (%d, slow %d, num_disp %d, idle_win %d)", reason,
> +		slow, bfqq->dispatched, bfq_bfqq_idle_window(bfqq));
> +
> +	/*
> +	 * Increase, decrease or leave budget unchanged according to
> +	 * reason.
> +	 */
> +	__bfq_bfqq_recalc_budget(bfqd, bfqq, reason);
> +	__bfq_bfqq_expire(bfqd, bfqq);
> +}
> +
> +/*
> + * Budget timeout is not implemented through a dedicated timer, but
> + * just checked on request arrivals and completions, as well as on
> + * idle timer expirations.
> + */
> +static int bfq_bfqq_budget_timeout(struct bfq_queue *bfqq)
> +{
> +	if (bfq_bfqq_budget_new(bfqq) ||
> +	    time_before(jiffies, bfqq->budget_timeout))
> +		return 0;
> +	return 1;
> +}

static bool...
{
	return !bfq_bfqq_budget_new(bfqq) &&
	       time_after_eq(jiffies, bfqq->budget_timeout);
}

> +/*
> + * If we expire a queue that is waiting for the arrival of a new
> + * request, we may prevent the fictitious timestamp back-shifting that
> + * allows the guarantees of the queue to be preserved (see [1] for
> + * this tricky aspect). Hence we return true only if this condition
> + * does not hold, or if the queue is slow enough to deserve only to be
> + * kicked off for preserving a high throughput.
> +*/
> +static inline int bfq_may_expire_for_budg_timeout(struct bfq_queue *bfqq)

		bool

I'll stop commenting about int -> bool conversions but please use bool
for booleans.

> +{
> +	bfq_log_bfqq(bfqq->bfqd, bfqq,
> +		"may_budget_timeout: wait_request %d left %d timeout %d",
> +		bfq_bfqq_wait_request(bfqq),
> +			bfq_bfqq_budget_left(bfqq) >=  bfqq->entity.budget / 3,
> +		bfq_bfqq_budget_timeout(bfqq));
> +
> +	return (!bfq_bfqq_wait_request(bfqq) ||
> +		bfq_bfqq_budget_left(bfqq) >=  bfqq->entity.budget / 3)
> +		&&
> +		bfq_bfqq_budget_timeout(bfqq);
> +}

	return (!bfq_bfqq_wait_request(bfqq) ||
		bfq_bfqq_budget_left(bfqq) >= bfqq->entity.budget / 3) &&
	       bfq_bfqq_budget_timeout(bfqq);

The indentations should indicate how the conditions group.

> +/*
> + * Dispatch one request from bfqq, moving it to the request queue
> + * dispatch list.
> + */
> +static int bfq_dispatch_request(struct bfq_data *bfqd,
> +				struct bfq_queue *bfqq)
> +{
...
> +	if (bfqd->busy_queues > 1 && ((!bfq_bfqq_sync(bfqq) &&
> +	    dispatched >= bfqd->bfq_max_budget_async_rq) ||
> +	    bfq_class_idle(bfqq)))
> +		goto expire;

The canonoical formatting would be like the following,

	if (bfqd->busy_queues > 1 &&
	    ((!bfq_bfqq_sync(bfqq) &&
	      dispatched >= bfqd->bfq_max_budget_async_rq) ||
	     bfq_class_idle(bfqq)))
		goto expire;

but as it's pretty ugly, why not do something like the following?
It'd be a lot easier to follow.

	if (bfqd->busy_queues > 1) {
		if (!bfq_bfqq_sync(bfqq) &&
		    dispatched >= bfqd->bfq_max_budget_async_rq)
			goto expire;
		if (bfq_class_idle(bfqq))
			goto expire;
	}

> +static int bfq_dispatch_requests(struct request_queue *q, int force)
> +{
...
> +	max_dispatch = bfqd->bfq_quantum;
> +	if (bfq_class_idle(bfqq))
> +		max_dispatch = 1;
> +
> +	if (!bfq_bfqq_sync(bfqq))
> +		max_dispatch = bfqd->bfq_max_budget_async_rq;

	if (!bfq_bfqq_sync(bfqq))
		max_dispatch = bfqd->bfq_max_budget_async_rq;
	else if (bfq_class_idle(bfqq))
		max_dispatch = 1;
	else
		max_dispatch = bfqd->bfq_quantum;

> +
> +	if (bfqq->dispatched >= max_dispatch) {
> +		if (bfqd->busy_queues > 1)
> +			return 0;
> +		if (bfqq->dispatched >= 4 * max_dispatch)
> +			return 0;
> +	}
> +
> +	if (bfqd->sync_flight != 0 && !bfq_bfqq_sync(bfqq))

	if (bfqd->sync_flight && ...)

> +		return 0;
> +
> +	bfq_clear_bfqq_wait_request(bfqq);
> +
> +	if (!bfq_dispatch_request(bfqd, bfqq))
> +		return 0;
> +
> +	bfq_log_bfqq(bfqd, bfqq, "dispatched one request of %d (max_disp %d)",
> +			bfqq->pid, max_dispatch);
> +
> +	return 1;
> +}
...
> +static void bfq_update_io_seektime(struct bfq_data *bfqd,
> +				   struct bfq_queue *bfqq,
> +				   struct request *rq)
> +{
> +	sector_t sdist;
> +	u64 total;
> +
> +	if (bfqq->last_request_pos < blk_rq_pos(rq))
> +		sdist = blk_rq_pos(rq) - bfqq->last_request_pos;
> +	else
> +		sdist = bfqq->last_request_pos - blk_rq_pos(rq);
> +
> +	/*
> +	 * Don't allow the seek distance to get too large from the
> +	 * odd fragment, pagein, etc.
> +	 */
> +	if (bfqq->seek_samples == 0) /* first request, not really a seek */
> +		sdist = 0;
> +	else if (bfqq->seek_samples <= 60) /* second & third seek */
> +		sdist = min(sdist, (bfqq->seek_mean * 4) + 2*1024*1024);
> +	else
> +		sdist = min(sdist, (bfqq->seek_mean * 4) + 2*1024*64);
> +
> +	bfqq->seek_samples = (7*bfqq->seek_samples + 256) / 8;
> +	bfqq->seek_total = (7*bfqq->seek_total + (u64)256*sdist) / 8;
> +	total = bfqq->seek_total + (bfqq->seek_samples/2);
> +	do_div(total, bfqq->seek_samples);
> +	bfqq->seek_mean = (sector_t)total;

The above looks pretty magic to me.  Care to explain a bit?

...
> +static void bfq_rq_enqueued(struct bfq_data *bfqd, struct bfq_queue *bfqq,
> +			    struct request *rq)
> +{
> +	struct bfq_io_cq *bic = RQ_BIC(rq);
> +
> +	if (rq->cmd_flags & REQ_META)
> +		bfqq->meta_pending++;
> +
> +	bfq_update_io_thinktime(bfqd, bic);
> +	bfq_update_io_seektime(bfqd, bfqq, rq);
> +	if (bfqq->entity.service > bfq_max_budget(bfqd) / 8 ||
> +	    !BFQQ_SEEKY(bfqq))
> +		bfq_update_idle_window(bfqd, bfqq, bic);
> +
> +	bfq_log_bfqq(bfqd, bfqq,
> +		     "rq_enqueued: idle_window=%d (seeky %d, mean %llu)",
> +		     bfq_bfqq_idle_window(bfqq), BFQQ_SEEKY(bfqq),
> +		     (long long unsigned)bfqq->seek_mean);
> +
> +	bfqq->last_request_pos = blk_rq_pos(rq) + blk_rq_sectors(rq);
> +
> +	if (bfqq == bfqd->in_service_queue && bfq_bfqq_wait_request(bfqq)) {
> +		int small_req = bfqq->queued[rq_is_sync(rq)] == 1 &&
> +				blk_rq_sectors(rq) < 32;
> +		int budget_timeout = bfq_bfqq_budget_timeout(bfqq);
> +
> +		/*
> +		 * There is just this request queued: if the request
> +		 * is small and the queue is not to be expired, then
> +		 * just exit.
> +		 *
> +		 * In this way, if the disk is being idled to wait for
> +		 * a new request from the in-service queue, we avoid
> +		 * unplugging the device and committing the disk to serve
> +		 * just a small request. On the contrary, we wait for
> +		 * the block layer to decide when to unplug the device:
> +		 * hopefully, new requests will be merged to this one
> +		 * quickly, then the device will be unplugged and
> +		 * larger requests will be dispatched.
> +		 */

Is the above comment correct?  How does an iosched see a request
before it gets unplugged?  By the time the request reaches an iosched,
it already got plug merged && unplugged.  Is this optimization
meaningful at all?

> +static void bfq_update_hw_tag(struct bfq_data *bfqd)
> +{
> +	bfqd->max_rq_in_driver = max(bfqd->max_rq_in_driver,
> +				     bfqd->rq_in_driver);
> +
> +	if (bfqd->hw_tag == 1)
> +		return;
> +
> +	/*
> +	 * This sample is valid if the number of outstanding requests
> +	 * is large enough to allow a queueing behavior.  Note that the
> +	 * sum is not exact, as it's not taking into account deactivated
> +	 * requests.
> +	 */
> +	if (bfqd->rq_in_driver + bfqd->queued < BFQ_HW_QUEUE_THRESHOLD)
> +		return;
> +
> +	if (bfqd->hw_tag_samples++ < BFQ_HW_QUEUE_SAMPLES)
> +		return;
> +
> +	bfqd->hw_tag = bfqd->max_rq_in_driver > BFQ_HW_QUEUE_THRESHOLD;
> +	bfqd->max_rq_in_driver = 0;
> +	bfqd->hw_tag_samples = 0;
> +}

This is a digression but I wonder whether ioscheds like bfq should
just throttle the number of outstanding requests to one rather than
trying to estimate the queue depth and then adjust its behavior.  It's
rather pointless to do all this work for queued devices anyway.  A
better behavior could be defaulting to [bc]fq for rotational devices
and something simpler (deadline or noop) for !rot ones.  Note that
blk-mq devices entirely bypass ioscheds anyway.

> +static void bfq_completed_request(struct request_queue *q, struct request *rq)
> +{
....
> +	/*
> +	 * If this is the in-service queue, check if it needs to be expired,
> +	 * or if we want to idle in case it has no pending requests.
> +	 */
> +	if (bfqd->in_service_queue == bfqq) {
> +		if (bfq_bfqq_budget_new(bfqq))
> +			bfq_set_budget_timeout(bfqd);
> +
> +		if (bfq_bfqq_must_idle(bfqq)) {
> +			bfq_arm_slice_timer(bfqd);
> +			goto out;
> +		} else if (bfq_may_expire_for_budg_timeout(bfqq))
> +			bfq_bfqq_expire(bfqd, bfqq, 0, BFQ_BFQQ_BUDGET_TIMEOUT);
> +		else if (RB_EMPTY_ROOT(&bfqq->sort_list) &&
> +			 (bfqq->dispatched == 0 ||
> +			  !bfq_bfqq_must_not_expire(bfqq)))
> +			bfq_bfqq_expire(bfqd, bfqq, 0,
> +					BFQ_BFQQ_NO_MORE_REQUESTS);

		if {
		} else if {
		} else if {
		}

...
> +static struct elv_fs_entry bfq_attrs[] = {
> +	BFQ_ATTR(quantum),
> +	BFQ_ATTR(fifo_expire_sync),
> +	BFQ_ATTR(fifo_expire_async),
> +	BFQ_ATTR(back_seek_max),
> +	BFQ_ATTR(back_seek_penalty),
> +	BFQ_ATTR(slice_idle),
> +	BFQ_ATTR(max_budget),
> +	BFQ_ATTR(max_budget_async_rq),
> +	BFQ_ATTR(timeout_sync),
> +	BFQ_ATTR(timeout_async),
> +	BFQ_ATTR(weights),

Again, please refrain from exposing knobs which reveal internal
details.  These unnecessarily lock us into specific implementation and
it's not like users can make sensible use of these konbs anyway.  If
you want some knobs exposed for debugging / development, keeping them
in a separate private patch or hiding them behind a kernel param would
work a lot better.

Thanks.

-- 
tejun
