From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC - TAKE TWO - 10/12] block, bfq: add Early Queue Merge
	(EQM)
Date: Sat, 31 May 2014 20:03:31 -0400
Message-ID: <20140601000331.GA29085__13567.9055391394$1401581032$gmane$org@htj.dyndns.org>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
	<1401354343-5527-11-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1401354343-5527-11-git-send-email-paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
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
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mauro Andreolini <mauro.andreolini-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

On Thu, May 29, 2014 at 11:05:41AM +0200, Paolo Valente wrote:
> Unfortunately, in the following frequent case the mechanism
> implemented in CFQ for detecting cooperating processes and merging
> their queues is not responsive enough to handle also the fluctuating
> I/O pattern of the second type of processes. Suppose that one process
> of the second type issues a request close to the next request to serve
> of another process of the same type. At that time the two processes
> can be considered as cooperating. But, if the request issued by the
> first process is to be merged with some other already-queued request,
> then, from the moment at which this request arrives, to the moment
> when CFQ controls whether the two processes are cooperating, the two
> processes are likely to be already doing I/O in distant zones of the
> disk surface or device memory.

I don't really follow the last part.  So, the difference is that
cooperating queue setup also takes place during bio merge too, right?
Are you trying to say that it's beneficial to detect cooperating
queues before the issuing queue gets unplugged because the two queues
might deviate while plugged?  If so, the above paragraph is, while
quite wordy, a rather lousy description.

> CFQ uses however preemption to get a sequential read pattern out of
> the read requests performed by the second type of processes too.  As a
> consequence, CFQ uses two different mechanisms to achieve the same
> goal: boosting the throughput with interleaved I/O.

You mean the cfq_rq_close() preemption, right?  Hmmm... interesting.
I'm a bit bothered that we might do this multiple times for the same
bio/request.  e.g. if bio is back merged to an existing request which
would be the most common bio merge scenario anyway, is it really
meaningful to retry it for each merge and then again on submission?
cfq does it once when allocating the request.  That seems a lot more
reasonable to me.  It's doing that once for one start sector.  I mean,
plugging is usually extremely short compared to actual IO service
time.  It's there to mask the latencies between bio issues that the
same CPU is doing.  I can't see how this earliness can be actually
useful.  Do you have results to back this one up?  Or is this just
born out of thin air?

> +/*
> + * Must be called with the queue_lock held.

Use lockdep_assert_held() instead?

> + */
> +static int bfqq_process_refs(struct bfq_queue *bfqq)
> +{
> +	int process_refs, io_refs;
> +
> +	io_refs = bfqq->allocated[READ] + bfqq->allocated[WRITE];
> +	process_refs = atomic_read(&bfqq->ref) - io_refs - bfqq->entity.on_st;
> +	return process_refs;
> +}
...
> +static inline sector_t bfq_io_struct_pos(void *io_struct, bool request)
> +{
> +	if (request)
> +		return blk_rq_pos(io_struct);
> +	else
> +		return ((struct bio *)io_struct)->bi_iter.bi_sector;
> +}
> +
> +static inline sector_t bfq_dist_from(sector_t pos1,
> +				     sector_t pos2)
> +{
> +	if (pos1 >= pos2)
> +		return pos1 - pos2;
> +	else
> +		return pos2 - pos1;
> +}
> +
> +static inline int bfq_rq_close_to_sector(void *io_struct, bool request,
> +					 sector_t sector)
> +{
> +	return bfq_dist_from(bfq_io_struct_pos(io_struct, request), sector) <=
> +	       BFQQ_SEEK_THR;
> +}

You can simply write the following.

	abs64(sector0 - sector1) < BFQQ_SEEKTHR;

Note that abs64() works whether the source type is signed or unsigned.
Also, please don't do "void *" + type switch.  If it absoluately has
to take two different types of pointers, just take two different
pointers and BUG_ON() if both are set, but here this doesn't seem to
be the case.  Just pass around the actual sectors.  This applies to
all usages of void *io_struct.

> +static struct bfq_queue *bfqq_close(struct bfq_data *bfqd, sector_t sector)

bfqq_find_close() or find_close_bfqq()?

> +/*
> + * bfqd - obvious
> + * cur_bfqq - passed in so that we don't decide that the current queue
> + *            is closely cooperating with itself
> + * sector - used as a reference point to search for a close queue
> + */

If you're gonna do the above, please use proper function comment.
Please take a look at Documentation/kernel-doc-nano-HOWTO.txt.

> +static struct bfq_queue *bfq_close_cooperator(struct bfq_data *bfqd,
> +					      struct bfq_queue *cur_bfqq,
> +					      sector_t sector)
> +{
> +	struct bfq_queue *bfqq;
> +
> +	if (bfq_class_idle(cur_bfqq))
> +		return NULL;
> +	if (!bfq_bfqq_sync(cur_bfqq))
> +		return NULL;
> +	if (BFQQ_SEEKY(cur_bfqq))
> +		return NULL;

Why are some of these conditions tested twice?  Once here and once in
the caller?  Collect them into one place?

...
> +	if (bfqq->entity.parent != cur_bfqq->entity.parent)
> +		return NULL;

This is the only place this rq position tree is being used, right?
Any reason not to use per-parent tree instead?

> +	if (bfq_class_rt(bfqq) != bfq_class_rt(cur_bfqq))
> +		return NULL;

Test ioprio_class for equality?

> +/*
> + * Attempt to schedule a merge of bfqq with the currently in-service queue
> + * or with a close queue among the scheduled queues.
> + * Return NULL if no merge was scheduled, a pointer to the shared bfq_queue
> + * structure otherwise.
> + */
> +static struct bfq_queue *
> +bfq_setup_cooperator(struct bfq_data *bfqd, struct bfq_queue *bfqq,
> +		     void *io_struct, bool request)
> +{
> +	struct bfq_queue *in_service_bfqq, *new_bfqq;
> +
> +	if (bfqq->new_bfqq)
> +		return bfqq->new_bfqq;
> +
> +	if (!io_struct)
> +		return NULL;
> +
> +	in_service_bfqq = bfqd->in_service_queue;
> +
> +	if (in_service_bfqq == NULL || in_service_bfqq == bfqq ||
> +	    !bfqd->in_service_bic)
> +		goto check_scheduled;
> +
> +	if (bfq_class_idle(in_service_bfqq) || bfq_class_idle(bfqq))
> +		goto check_scheduled;
> +
> +	if (bfq_class_rt(in_service_bfqq) != bfq_class_rt(bfqq))
> +		goto check_scheduled;
> +
> +	if (in_service_bfqq->entity.parent != bfqq->entity.parent)
> +		goto check_scheduled;
> +
> +	if (bfq_rq_close_to_sector(io_struct, request, bfqd->last_position) &&
> +	    bfq_bfqq_sync(in_service_bfqq) && bfq_bfqq_sync(bfqq)) {
> +		new_bfqq = bfq_setup_merge(bfqq, in_service_bfqq);
> +		if (new_bfqq != NULL)
> +			return new_bfqq; /* Merge with in-service queue */
> +	}
> +
> +	/*
> +	 * Check whether there is a cooperator among currently scheduled
> +	 * queues. The only thing we need is that the bio/request is not
> +	 * NULL, as we need it to establish whether a cooperator exists.
> +	 */
> +check_scheduled:
> +	new_bfqq = bfq_close_cooperator(bfqd, bfqq,
> +					bfq_io_struct_pos(io_struct, request));
> +	if (new_bfqq)
> +		return bfq_setup_merge(bfqq, new_bfqq);

Why don't in_service_queue and scheduled search share the cooperation
conditions?  They should be the same, right?  Shouldn't the function
be structured like the following instead?

	if (bfq_try_close_cooperator(current_one, in_service_one))
		return in_service_one;

	found = bfq_find_close_cooperator();
	if (bfq_try_close_cooperator(current_one, found))
		return found;
	return NULL;

Thanks.

-- 
tejun
