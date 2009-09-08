From: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 25/23] io-controller: fix queue vs group fairness
Date: Wed, 9 Sep 2009 01:13:34 +0200
Message-ID: <20090908231334.GJ17468__2163.8763173998$1252451511$gmane$org@gandalf.sssup.it>
References: <1251495072-7780-1-git-send-email-vgoyal@redhat.com>
	<20090908222827.GC3558@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090908222827.GC3558-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Date: Tue, Sep 08, 2009 06:28:27PM -0400
>
> 
> o I found an issue during test and that is if there is a mix of queue and group
...
>  So we need to keep track of process io queue's vdisktime, even it after got
>  deleted from io scheduler's service tree and use that same vdisktime if that
>  queue gets backlogged again. But trusting a ioq's vdisktime is bad because
>  it can lead to issues if a service tree min_vtime wrap around takes place 
>  between two requests of the queue. (Agreed that it can be not that easy to
>  hit but it is possible).
> 
>  Hence, keep a cache of io queues serviced recently and when a queue gets
>  backlogged, if it is found in cache, use that vdisktime otherwise assign
>  a new vdisktime. This cache of io queues (idle tree), is basically the idea
>  implemented by BFQ guys. I had gotten rid of idle trees in V9 and now I am
>  bringing it back. (Now I understand it better. :-)).
> 
>  There is one good side affect of keeping the cache of recently service io
>  queues. Now CFQ can differentiate between streaming readers and new processes
>  doing IO. Now for a new queue (which is not in the cache), we can assign a
>  lower vdisktime and for a streaming reader, we assign vdisktime based on disk
>  time used. This way small file readers or the processes doing small amount
>  of IO will have reduced latencies at the cost of little reduced throughput of
>  streaming readers.
> 

  just a little note: this patch seems to introduce a special case for
vdisktime = 0, assigning it the meaning of "bad timestamp," but the virtual
time space wraps, so 0 is a perfectly legal value, which can be reached by
service.  I have no idea if it can produce visible effects, but it doesn't
seem to be correct.


> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  block/cfq-iosched.c |    2 
>  block/elevator-fq.c |  252 ++++++++++++++++++++++++++++++++++++++++++++++++----
>  block/elevator-fq.h |    9 +
>  3 files changed, 246 insertions(+), 17 deletions(-)
> 
> Index: linux16/block/elevator-fq.c
> ===================================================================
> --- linux16.orig/block/elevator-fq.c	2009-09-08 15:44:21.000000000 -0400
> +++ linux16/block/elevator-fq.c	2009-09-08 15:47:45.000000000 -0400
> @@ -52,6 +52,8 @@ static struct kmem_cache *elv_ioq_pool;
>  #define elv_log_entity(entity, fmt, args...)
>  #endif
>  
> +static void check_idle_tree_release(struct io_service_tree *st);
> +
>  static inline struct io_queue *ioq_of(struct io_entity *entity)
>  {
>  	if (entity->my_sd == NULL)
> @@ -109,6 +111,11 @@ elv_prio_to_slice(struct elv_fq_data *ef
>  	return elv_weight_slice(efqd, elv_ioq_sync(ioq), ioq->entity.weight);
>  }
>  
> +static inline int vdisktime_gt(u64 a, u64 b)
> +{
> +	return (s64)(a - b) > 0;
> +}
> +
>  static inline u64 max_vdisktime(u64 min_vdisktime, u64 vdisktime)
>  {
>  	s64 delta = (s64)(vdisktime - min_vdisktime);
> @@ -145,6 +152,7 @@ static void update_min_vdisktime(struct 
>  	}
>  
>  	st->min_vdisktime = max_vdisktime(st->min_vdisktime, vdisktime);
> +	check_idle_tree_release(st);
>  }
>  
>  static inline struct io_entity *parent_entity(struct io_entity *entity)
> @@ -411,27 +419,46 @@ static void place_entity(struct io_servi
>  	struct rb_node *parent;
>  	struct io_entity *entry;
>  	int nr_active = st->nr_active - 1;
> +	struct io_queue *ioq = ioq_of(entity);
> +	int sync = 1;
> +
> +	if (ioq)
> +		sync = elv_ioq_sync(ioq);
> +
> +	if (add_front || !nr_active) {
> +		vdisktime = st->min_vdisktime;
> +		goto done;
> +	}
> +
> +	if (sync && entity->vdisktime
> +	    && vdisktime_gt(entity->vdisktime, st->min_vdisktime)) {
> +		/* vdisktime still in future. Use old vdisktime */
> +		vdisktime = entity->vdisktime;
> +		goto done;
> +	}
>  
>  	/*
> -	 * Currently put entity at the end of last entity. This probably will
> -	 * require adjustments as we move along
> +	 * Effectively a new queue. Assign sync queue a lower vdisktime so
> +	 * we can achieve better latencies for small file readers. For async
> +	 * queues, put them at the end of the existing queue.
> +	 * Group entities are always considered sync.
>  	 */
> -	if (io_entity_class_idle(entity)) {
> -		vdisktime = elv_delta_fair(ELV_IDLE_DELAY, entity);
> -		parent = rb_last(&st->active);
> -		if (parent) {
> -			entry = rb_entry(parent, struct io_entity, rb_node);
> -			vdisktime += entry->vdisktime;
> -		}
> -	} else if (!add_front && nr_active) {
> -		parent = rb_last(&st->active);
> -		if (parent) {
> -			entry = rb_entry(parent, struct io_entity, rb_node);
> -			vdisktime = entry->vdisktime;
> -		}
> -	} else
> +	if (sync) {
>  		vdisktime = st->min_vdisktime;
> +		goto done;
> +	}
>  
> +	/*
> +	 * Put entity at the end of the tree. Effectively async queues use
> +	 * this path.
> +	 */
> +	parent = rb_last(&st->active);
> +	if (parent) {
> +		entry = rb_entry(parent, struct io_entity, rb_node);
> +		vdisktime = entry->vdisktime;
> +	} else
> +		vdisktime = st->min_vdisktime;
> +done:
>  	entity->vdisktime = max_vdisktime(st->min_vdisktime, vdisktime);
>  	elv_log_entity(entity, "place_entity: vdisktime=%llu"
>  			" min_vdisktime=%llu", entity->vdisktime,
> @@ -447,6 +474,122 @@ static inline void io_entity_update_prio
>  		 */
>  		init_io_entity_service_tree(entity, parent_entity(entity));
>  		entity->ioprio_changed = 0;
> +
> +		/*
> +		 * Assign this entity a fresh vdisktime instead of using
> +		 * previous one as prio class will lead to service tree
> +		 * change and this vdisktime will not be valid on new
> +		 * service tree.
> +		 *
> +		 * TODO: Handle the case of only prio change.
> +		 */
> +		entity->vdisktime = 0;
> +	}
> +}
> +
> +static void
> +__dequeue_io_entity_idle(struct io_service_tree *st, struct io_entity *entity)
> +{
> +	if (st->rb_leftmost_idle == &entity->rb_node) {
> +		struct rb_node *next_node;
> +
> +		next_node = rb_next(&entity->rb_node);
> +		st->rb_leftmost_idle = next_node;
> +	}
> +
> +	rb_erase(&entity->rb_node, &st->idle);
> +	RB_CLEAR_NODE(&entity->rb_node);
> +}
> +
> +static void dequeue_io_entity_idle(struct io_entity *entity)
> +{
> +	struct io_queue *ioq = ioq_of(entity);
> +
> +	__dequeue_io_entity_idle(entity->st, entity);
> +	entity->on_idle_st = 0;
> +	if (ioq)
> +		elv_put_ioq(ioq);
> +}
> +
> +static void
> +__enqueue_io_entity_idle(struct io_service_tree *st, struct io_entity *entity)
> +{
> +	struct rb_node **node = &st->idle.rb_node;
> +	struct rb_node *parent = NULL;
> +	struct io_entity *entry;
> +	int leftmost = 1;
> +
> +	while (*node != NULL) {
> +		parent = *node;
> +		entry = rb_entry(parent, struct io_entity, rb_node);
> +
> +		if (vdisktime_gt(entry->vdisktime, entity->vdisktime))
> +			node = &parent->rb_left;
> +		else {
> +			node = &parent->rb_right;
> +			leftmost = 0;
> +		}
> +	}
> +
> +	/*
> +	 * Maintain a cache of leftmost tree entries (it is frequently
> +	 * used)
> +	 */
> +	if (leftmost)
> +		st->rb_leftmost_idle = &entity->rb_node;
> +
> +	rb_link_node(&entity->rb_node, parent, node);
> +	rb_insert_color(&entity->rb_node, &st->idle);
> +}
> +
> +static void enqueue_io_entity_idle(struct io_entity *entity)
> +{
> +	struct io_queue *ioq = ioq_of(entity);
> +	struct io_group *parent_iog;
> +
> +	/*
> +	 * Don't put an entity on idle tree if it has been marked for deletion.
> +	 * We are not expecting more io from this entity. No need to cache it
> +	 */
> +
> +	if (entity->exiting)
> +		return;
> +
> +	/*
> +	 * If parent group is exiting, don't put on idle tree. May be task got
> +	 * moved to a different cgroup and original cgroup got deleted
> +	 */
> +	parent_iog = iog_of(parent_entity(entity));
> +	if (parent_iog->entity.exiting)
> +		return;
> +
> +	if (ioq)
> +		elv_get_ioq(ioq);
> +	__enqueue_io_entity_idle(entity->st, entity);
> +	entity->on_idle_st = 1;
> +}
> +
> +static void check_idle_tree_release(struct io_service_tree *st)
> +{
> +	struct io_entity *leftmost;
> +
> +	if (!st->rb_leftmost_idle)
> +		return;
> +
> +	leftmost = rb_entry(st->rb_leftmost_idle, struct io_entity, rb_node);
> +
> +	if (vdisktime_gt(st->min_vdisktime, leftmost->vdisktime))
> +		dequeue_io_entity_idle(leftmost);
> +}
> +
> +static void flush_idle_tree(struct io_service_tree *st)
> +{
> +	struct io_entity *entity;
> +
> +	while(st->rb_leftmost_idle) {
> +		entity = rb_entry(st->rb_leftmost_idle, struct io_entity,
> +					rb_node);
> +		dequeue_io_entity_idle(entity);
>  	}
>  }
>  
> @@ -483,6 +626,9 @@ static void dequeue_io_entity(struct io_
>  	st->nr_active--;
>  	sd->nr_active--;
>  	debug_update_stats_dequeue(entity);
> +
> +	if (vdisktime_gt(entity->vdisktime, st->min_vdisktime))
> +		enqueue_io_entity_idle(entity);
>  }
>  
>  static void
> @@ -524,6 +670,16 @@ static void enqueue_io_entity(struct io_
>  	struct io_service_tree *st;
>  	struct io_sched_data *sd = io_entity_sched_data(entity);
>  
> +	if (entity->on_idle_st)
> +		dequeue_io_entity_idle(entity);
> +	else
> +		/*
> +		 * This entity was not in idle tree cache. Zero out vdisktime
> +		 * so that we don't rely on old vdisktime instead assign a
> +		 * fresh one.
> +		 */
> +		entity->vdisktime = 0;
> +
>  	io_entity_update_prio(entity);
>  	st = entity->st;
>  	st->nr_active++;
> @@ -574,6 +730,8 @@ static void requeue_io_entity(struct io_
>  	struct io_service_tree *st = entity->st;
>  	struct io_entity *next_entity;
>  
> +	entity->vdisktime = 0;
> +
>  	if (add_front) {
>  		next_entity = __lookup_next_io_entity(st);
>  
> @@ -1937,11 +2095,18 @@ static void io_free_root_group(struct el
>  {
>  	struct io_group *iog = e->efqd->root_group;
>  	struct io_cgroup *iocg = &io_root_cgroup;
> +	struct io_service_tree *st;
> +	int i;
>  
>  	spin_lock_irq(&iocg->lock);
>  	hlist_del_rcu(&iog->group_node);
>  	spin_unlock_irq(&iocg->lock);
>  
> +	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
> +		st = iog->sched_data.service_tree + i;
> +		flush_idle_tree(st);
> +	}
> +
>  	put_io_group_queues(e, iog);
>  	elv_put_iog(iog);
>  }
> @@ -2039,9 +2204,29 @@ EXPORT_SYMBOL(elv_put_iog);
>   */
>  static void __io_destroy_group(struct elv_fq_data *efqd, struct io_group *iog)
>  {
> +	struct io_service_tree *st;
> +	int i;
> +	struct io_entity *entity = &iog->entity;
> +
> +	/*
> +	 * Mark io group for deletion so that no new entry goes in
> +	 * idle tree. Any active queue which is removed from active
> +	 * tree will not be put in to idle tree.
> +	 */
> +	entity->exiting = 1;
> +
> +	/* We flush idle tree now, and don't put things in there any more. */
> +	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
> +		st = iog->sched_data.service_tree + i;
> +		flush_idle_tree(st);
> +	}
> +
>  	hlist_del(&iog->elv_data_node);
>  	put_io_group_queues(efqd->eq, iog);
>  
> +	if (entity->on_idle_st)
> +		dequeue_io_entity_idle(entity);
> +
>  	/*
>  	 * Put the reference taken at the time of creation so that when all
>  	 * queues are gone, group can be destroyed.
> @@ -2374,7 +2559,13 @@ static struct io_group *io_alloc_root_gr
>  static void io_free_root_group(struct elevator_queue *e)
>  {
>  	struct io_group *iog = e->efqd->root_group;
> +	struct io_service_tree *st;
> +	int i;
>  
> +	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
> +		st = iog->sched_data.service_tree + i;
> +		flush_idle_tree(st);
> +	}
>  	put_io_group_queues(e, iog);
>  	kfree(iog);
>  }
> @@ -3257,6 +3448,35 @@ done:
>  		elv_schedule_dispatch(q);
>  }
>  
> +/*
> + * The process associted with ioq (in case of cfq), is going away. Mark it
> + * for deletion.
> + */
> +void elv_exit_ioq(struct io_queue *ioq)
> +{
> +	struct io_entity *entity = &ioq->entity;
> +
> +	/*
> +	 * Async ioq's belong to io group and are cleaned up once group is
> +	 * being deleted. Not need to do any cleanup here even if cfq has
> +	 * dropped the reference to the queue
> +	 */
> +	if (!elv_ioq_sync(ioq))
> +		return;
> +
> +	/*
> + 	 * This queue is still under service. Just mark it so that once all
> +	 * the IO from queue is done, it is not put back in idle tree.
> +	 */
> +	if (entity->on_st) {
> +		entity->exiting = 1;
> +		return;
> +	} else if(entity->on_idle_st) {
> +		/* Remove ioq from idle tree */
> +		dequeue_io_entity_idle(entity);
> +	}
> +}
> +EXPORT_SYMBOL(elv_exit_ioq);
>  static void elv_slab_kill(void)
>  {
>  	/*
> Index: linux16/block/cfq-iosched.c
> ===================================================================
> --- linux16.orig/block/cfq-iosched.c	2009-09-08 15:43:36.000000000 -0400
> +++ linux16/block/cfq-iosched.c	2009-09-08 15:47:45.000000000 -0400
> @@ -1138,6 +1138,7 @@ static void cfq_exit_cfqq(struct cfq_dat
>  		elv_schedule_dispatch(cfqd->queue);
>  	}
>  
> +	elv_exit_ioq(cfqq->ioq);
>  	cfq_put_queue(cfqq);
>  }
>  
> @@ -1373,6 +1374,7 @@ static void changed_cgroup(struct io_con
>  		 */
>  		if (iog != __iog) {
>  			cic_set_cfqq(cic, NULL, 1);
> +			elv_exit_ioq(sync_cfqq->ioq);
>  			cfq_put_queue(sync_cfqq);
>  		}
>  	}
> Index: linux16/block/elevator-fq.h
> ===================================================================
> --- linux16.orig/block/elevator-fq.h	2009-09-08 15:43:36.000000000 -0400
> +++ linux16/block/elevator-fq.h	2009-09-08 15:47:45.000000000 -0400
> @@ -33,6 +33,10 @@ struct io_service_tree {
>  	u64 min_vdisktime;
>  	struct rb_node *rb_leftmost;
>  	unsigned int nr_active;
> +
> +        /* A cache of io entities which were served and expired */
> +        struct rb_root idle;
> +        struct rb_node *rb_leftmost_idle;
>  };
>  
>  struct io_sched_data {
> @@ -44,9 +48,12 @@ struct io_sched_data {
>  struct io_entity {
>  	struct rb_node rb_node;
>  	int on_st;
> +	int on_idle_st;
>  	u64 vdisktime;
>  	unsigned int weight;
>  	struct io_entity *parent;
> +	/* This io entity (queue or group) has been marked for deletion */
> +	unsigned int exiting;
>  
>  	struct io_sched_data *my_sd;
>  	struct io_service_tree *st;
> @@ -572,7 +579,7 @@ extern struct io_queue *elv_alloc_ioq(st
>  extern void elv_free_ioq(struct io_queue *ioq);
>  extern struct io_group *ioq_to_io_group(struct io_queue *ioq);
>  extern int elv_iog_should_idle(struct io_queue *ioq);
> -
> +extern void elv_exit_ioq(struct io_queue *ioq);
>  #else /* CONFIG_ELV_FAIR_QUEUING */
>  static inline struct elv_fq_data *
>  elv_alloc_fq_data(struct request_queue *q, struct elevator_queue *e)
