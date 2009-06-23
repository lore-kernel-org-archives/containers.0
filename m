From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/20] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Mon, 22 Jun 2009 22:05:15 -0400
Message-ID: <20090623020515.GA3620__39428.1111228794$1245722801$gmane$org@redhat.com>
References: <1245443858-8487-1-git-send-email-vgoyal@redhat.com>
	<1245443858-8487-3-git-send-email-vgoyal@redhat.com>
	<20090622084612.GD3728@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090622084612.GD3728-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jun 22, 2009 at 02:16:12PM +0530, Balbir Singh wrote:
> * Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> [2009-06-19 16:37:20]:
> 
> > This is common fair queuing code in elevator layer. This is controlled by
> > config option CONFIG_ELV_FAIR_QUEUING. This patch initially only introduces
> > flat fair queuing support where there is only one group, "root group" and all
> > the tasks belong to root group.
> > 
> > This elevator layer changes are backward compatible. That means any ioscheduler
> > using old interfaces will continue to work.
> > 
> > This code is essentially the CFQ code for fair queuing. The primary difference
> > is that flat rounding robin algorithm of CFQ has been replaced with BFQ (WF2Q+).
> >
> 
> The patch is quite long and to be honest requires a long time to
> review, which I don't mind. I suspect my frequently diverted mind is
> likely to miss a lot in a big patch like this. Could you consider
> splitting this further if possible. I think you'll notice the number
> of reviews will also increase.
>  

Hi Balbir,

Thanks for the review. Yes, this is a big patch. I will try to break it
down further.

Fabio has already responded to most of the questions. I will try to cover
rest.

[..]
> > +static inline struct io_queue *elv_close_cooperator(struct request_queue *q,
> > +					struct io_queue *ioq, int probe);
> > +struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
> > +						 int extract);
> > +
> > +static inline int elv_prio_slice(struct elv_fq_data *efqd, int sync,
> > +					unsigned short prio)
> 
> Why is the return type int and not unsigned int or unsigned long? Can
> the return value ever be negative?

Actually this function was a replacement for cfq_prio_slice() hence return
type int. But as slice value can never be negative, I can make it unsigned
int.

[..]
> > + * bfq_gt - compare two timestamps.
> > + * @a: first ts.
> > + * @b: second ts.
> > + *
> > + * Return @a > @b, dealing with wrapping correctly.
> > + */
> > +static inline int bfq_gt(bfq_timestamp_t a, bfq_timestamp_t b)
> > +{
> > +	return (s64)(a - b) > 0;
> > +}
> > +
> 
> a and b are of type u64, but cast to s64 to deal with wrapping?
> Correct?

Yes.

> 
> > +/**
> > + * bfq_delta - map service into the virtual time domain.
> > + * @service: amount of service.
> > + * @weight: scale factor.
> > + */
> > +static inline bfq_timestamp_t bfq_delta(bfq_service_t service,
> > +					bfq_weight_t weight)
> > +{
> > +	bfq_timestamp_t d = (bfq_timestamp_t)service << WFQ_SERVICE_SHIFT;
> > +
> 
> Why is the case required? Does the compiler complain? service is
> already of the correct type.
> 
> > +	do_div(d, weight);
> 
> On a 64 system both d and weight are 64 bit, but on a 32 bit system
> weight is 32 bits. do_div expects a 64 bit dividend and 32 bit divisor
> - no?
> 

d is of type "bfq_timestamp_t" which is u64 irrespective of 64 or 32 bit
system. I think it might make sense to change type of "weight" from
unsigned long to unsigned int so that it is 32bit on both 64 and 32bit
systems. Will do...


> > +	return d;
> > +}
> > +
> > +/**
> > + * bfq_calc_finish - assign the finish time to an entity.
> > + * @entity: the entity to act upon.
> > + * @service: the service to be charged to the entity.
> > + */
> > +static inline void bfq_calc_finish(struct io_entity *entity,
> > +				   bfq_service_t service)
> > +{
> > +	BUG_ON(entity->weight == 0);
> > +
> > +	entity->finish = entity->start + bfq_delta(service, entity->weight);
> > +}
> 
> Should we BUG_ON (entity->finish == entity->start)? Or is that
> expected when the entity has no service time left.
> 

As Fabio said, that with preemption logic, I guess theoritically, it is
possible that a io queue is preempted without any service received and
requeued back. Hence it might not be a very good idea to
BUG_ON(entity->finish == entity->start); 

[..]
> > +/**
> > + * bfq_extract - remove an entity from a tree.
> > + * @root: the tree root.
> > + * @entity: the entity to remove.
> > + */
> > +static inline void bfq_extract(struct rb_root *root, struct io_entity *entity)
> > +{
> 
> Extract is not common terminology, why not use bfq_remove()?
> 

*_remove() also sounds good. Will replace *_extract() with *_remove().

> > +	BUG_ON(entity->tree != root);
> > +
> > +	entity->tree = NULL;
> > +	rb_erase(&entity->rb_node, root);
> 
> Don't you want to make entity->tree = NULL after rb_erase?

As Fabio said that it happens under queue spinlock held. But from
readability point of view, it probably looks better to first remove it
from rb tree then reset entity fields. Will change the order...

> 
> > +}
> > +
> > +/**
> > + * bfq_idle_extract - extract an entity from the idle tree.
> > + * @st: the service tree of the owning @entity.
> > + * @entity: the entity being removed.
> > + */
> > +static void bfq_idle_extract(struct io_service_tree *st,
> > +				struct io_entity *entity)
> > +{
> > +	struct rb_node *next;
> > +
> > +	BUG_ON(entity->tree != &st->idle);
> > +
> > +	if (entity == st->first_idle) {
> > +		next = rb_next(&entity->rb_node);
> 
> What happens if next is NULL?
> 
> > +		st->first_idle = bfq_entity_of(next);
> > +	}
> > +
> > +	if (entity == st->last_idle) {
> > +		next = rb_prev(&entity->rb_node);
> 
> What happens if next is NULL?
> 
> > +		st->last_idle = bfq_entity_of(next);

bfq_entity_of() is capable of handling next == NULL.

I can change it to following if you think it is more readable.

	if (entity == st->first_idle) {
		next = rb_next(&entity->rb_node);
		if (next)
			st->first_idle = bfq_entity_of(next);
		else
			st->first_idle = NULL;
	}

[..]

> > +static void elv_ioq_update_io_thinktime(struct io_queue *ioq)
> > +{
> > +	struct elv_fq_data *efqd = ioq->efqd;
> > +	unsigned long elapsed = jiffies - ioq->last_end_request;
> > +	unsigned long ttime = min(elapsed, 2UL * efqd->elv_slice_idle);
> > +
> > +	ioq->ttime_samples = (7*ioq->ttime_samples + 256) / 8;
> > +	ioq->ttime_total = (7*ioq->ttime_total + 256*ttime) / 8;
> > +	ioq->ttime_mean = (ioq->ttime_total + 128) / ioq->ttime_samples;
> > +}
> 
> Not sure I understand the magical 7, 8, 2, 128 and 256. Please help me
> understand the algorithm.

Taken from CFQ. 

> > +int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
> > +			void *sched_queue, int ioprio_class, int ioprio,
> > +			int is_sync)
> > +{
> > +	struct elv_fq_data *efqd = &eq->efqd;
> > +	struct io_group *iog = io_lookup_io_group_current(efqd->queue);
> > +
> > +	RB_CLEAR_NODE(&ioq->entity.rb_node);
> > +	atomic_set(&ioq->ref, 0);
> > +	ioq->efqd = efqd;
> > +	elv_ioq_set_ioprio_class(ioq, ioprio_class);
> > +	elv_ioq_set_ioprio(ioq, ioprio);
> > +	ioq->pid = current->pid;
> 
> Is pid used for cgroup association later? I don't see why we save the
> pid otherwise? If yes, why not store the cgroup of the current->pid?
> 

This is just for logging purposes (blktrace), useful for CFQ where every task
context sets up one queue and this number becomes the identifier for the queue.
Look at elv_log_ioq(), which uses ioq->pid.

[..]
> > + * coop tells that io scheduler selected a queue for us and we did not
> 
> coop?

coop refers to "cooperating". I guess "coop" is not descriptive. I will
change the name to "cooperating" and also put more description for
clarity.

[..]
> > diff --git a/block/elevator-fq.h b/block/elevator-fq.h
> > new file mode 100644
> > index 0000000..5b6c1cc
> > --- /dev/null
> > +++ b/block/elevator-fq.h
> > @@ -0,0 +1,473 @@
> > +/*
> > + * BFQ: data structures and common functions prototypes.
> > + *
> > + * Based on ideas and code from CFQ:
> > + * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
> > + *
> > + * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
> > + *		      Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
> > + * Copyright (C) 2009 Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > + * 	              Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> > + */
> > +
> > +#include <linux/blkdev.h>
> > +
> > +#ifndef _BFQ_SCHED_H
> > +#define _BFQ_SCHED_H
> > +
> > +#define IO_IOPRIO_CLASSES	3
> > +
> > +typedef u64 bfq_timestamp_t;
> > +typedef unsigned long bfq_weight_t;
> > +typedef unsigned long bfq_service_t;
> 
> Does this abstraction really provide any benefit? Why not directly use
> the standard C types, make the code easier to read.

I think using standard C type is better now. Will get rid of these
abstractions. Fabio also seems to be ok with this change.

> 
> > +struct io_entity;
> > +struct io_queue;
> > +
> > +#ifdef CONFIG_ELV_FAIR_QUEUING
> > +
> > +#define ELV_ATTR(name) \
> > +	__ATTR(name, S_IRUGO|S_IWUSR, elv_##name##_show, elv_##name##_store)
> > +
> > +/**
> > + * struct bfq_service_tree - per ioprio_class service tree.
> 
> Comment is old, does not reflect the newer name

Yes, this is all over the code. I have not taken care of updating the
comments from original bfq code. Will do it.

> 
> > + * @active: tree for active entities (i.e., those backlogged).
> > + * @idle: tree for idle entities (i.e., those not backlogged, with V <= F_i).
> > + * @first_idle: idle entity with minimum F_i.
> > + * @last_idle: idle entity with maximum F_i.
> > + * @vtime: scheduler virtual time.
> > + * @wsum: scheduler weight sum; active and idle entities contribute to it.
> > + *
> > + * Each service tree represents a B-WF2Q+ scheduler on its own.  Each
> > + * ioprio_class has its own independent scheduler, and so its own
> > + * bfq_service_tree.  All the fields are protected by the queue lock
> > + * of the containing efqd.
> > + */
> > +struct io_service_tree {
> > +	struct rb_root active;
> > +	struct rb_root idle;
> > +
> > +	struct io_entity *first_idle;
> > +	struct io_entity *last_idle;
> > +
> > +	bfq_timestamp_t vtime;
> > +	bfq_weight_t wsum;
> > +};
> > +
> > +/**
> > + * struct bfq_sched_data - multi-class scheduler.
> 
> Again the naming convention is broken, you need to change several
> bfq's to io's :)

Yes. Will do. :-)

> > +/*
> > + * A common structure embedded by every io scheduler into their respective
> > + * queue structure.
> > + */
> > +struct io_queue {
> > +	struct io_entity entity;
> 
> So the io_queue has an abstract entity called io_entity that contains
> it QoS parameters? Correct?
> 
> > +	atomic_t ref;
> > +	unsigned int flags;
> > +
> > +	/* Pointer to generic elevator data structure */
> > +	struct elv_fq_data *efqd;
> > +	pid_t pid;
> 
> Why do we store the pid?

pid of the process which caused io queue creation.

> 
> > +
> > +	/* Number of requests queued on this io queue */
> > +	unsigned long nr_queued;
> > +
> > +	/* Requests dispatched from this queue */
> > +	int dispatched;
> > +
> > +	/* Keep a track of think time of processes in this queue */
> > +	unsigned long last_end_request;
> > +	unsigned long ttime_total;
> > +	unsigned long ttime_samples;
> > +	unsigned long ttime_mean;
> > +
> > +	unsigned long slice_end;
> > +
> > +	/* Pointer to io scheduler's queue */
> > +	void *sched_queue;
> > +};
> > +
> > +struct io_group {
> > +	struct io_sched_data sched_data;
> > +
> > +	/* async_queue and idle_queue are used only for cfq */
> > +	struct io_queue *async_queue[2][IOPRIO_BE_NR];
> 
> Again the 2 is confusing
> 

Taken from CFQ. CFQ supports 8 prio levels for RT and BE class. We
maintain one async queue pointer per prio level for both RT and BE class.
Above number 2 is for RT and BE class.

> > +	struct io_queue *async_idle_queue;
> > +
> > +	/*
> > +	 * Used to track any pending rt requests so we can pre-empt current
> > +	 * non-RT cfqq in service when this value is non-zero.
> > +	 */
> > +	unsigned int busy_rt_queues;
> > +};
> > +
> > +struct elv_fq_data {
> 
> What does fq stand for?

Fair queuing. Any suggestions to make it better?

> 
> > +	struct io_group *root_group;
> > +
> > +	struct request_queue *queue;
> > +	unsigned int busy_queues;
> > +
> > +	/* Number of requests queued */
> > +	int rq_queued;
> > +
> > +	/* Pointer to the ioscheduler queue being served */
> > +	void *active_queue;
> > +
> > +	int rq_in_driver;
> > +	int hw_tag;
> > +	int hw_tag_samples;
> > +	int rq_in_driver_peak;
> 
> Some comments of _in_driver and _in_driver_peak would be nice.

Taken from CFQ. So somebody familiar with CFQ code can quickly relate. 
But anyway, I will put two lines of comments.

> 
> > +
> > +	/*
> > +	 * elevator fair queuing layer has the capability to provide idling
> > +	 * for ensuring fairness for processes doing dependent reads.
> > +	 * This might be needed to ensure fairness among two processes doing
> > +	 * synchronous reads in two different cgroups. noop and deadline don't
> > +	 * have any notion of anticipation/idling. As of now, these are the
> > +	 * users of this functionality.
> > +	 */
> > +	unsigned int elv_slice_idle;
> > +	struct timer_list idle_slice_timer;
> > +	struct work_struct unplug_work;
> > +
> > +	unsigned int elv_slice[2];
> 
> Why [2] makes the code hearder to read

Taken from CFQ. it represents base slice length for sync and async queues.
With put a line of comment.

Thanks
Vivek
