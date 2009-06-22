From: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 02/20] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Mon, 22 Jun 2009 14:43:13 +0200
Message-ID: <20090622124313.GF28770__48359.0418742553$1245674623$gmane$org@gandalf.sssup.it>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

> From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Mon, Jun 22, 2009 02:16:12PM +0530
>
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

This core scheduler part has not changed too much from the bfq patches,
so I'll try to answer your questions; Vivek, please correct me where
my knowledge is outdated.  I preferred to leave out the questions about
code that was not in the original patches.

...
> > +static inline int elv_prio_slice(struct elv_fq_data *efqd, int sync,
> > +					unsigned short prio)
> 
> Why is the return type int and not unsigned int or unsigned long? Can
> the return value ever be negative?
> 
> > +{
> > +	const int base_slice = efqd->elv_slice[sync];
> > +
> > +	WARN_ON(prio >= IOPRIO_BE_NR);
> > +
> > +	return base_slice + (base_slice/ELV_SLICE_SCALE * (4 - prio));
> > +}
> > +
> > +static inline int
> > +elv_prio_to_slice(struct elv_fq_data *efqd, struct io_queue *ioq)
> > +{
> > +	return elv_prio_slice(efqd, elv_ioq_sync(ioq), ioq->entity.ioprio);
> > +}
> > +
> > +/* Mainly the BFQ scheduling code Follows */
> > +
> > +/*
> > + * Shift for timestamp calculations.  This actually limits the maximum
> > + * service allowed in one timestamp delta (small shift values increase it),
> > + * the maximum total weight that can be used for the queues in the system
> > + * (big shift values increase it), and the period of virtual time wraparounds.
> > + */
> > +#define WFQ_SERVICE_SHIFT	22
> > +
> > +/**
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
> 

yes


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

service is unsigned long, so it can be 32 bits in 32 bit machines,
while timestamps are always u64, so I think we need the cast.


> > +	do_div(d, weight);
> 
> On a 64 system both d and weight are 64 bit, but on a 32 bit system
> weight is 32 bits. do_div expects a 64 bit dividend and 32 bit divisor
> - no?
> 

yes.  here the situation is that we actually don't care about the type
of weight, as long as it can contain a 32 bit value, and weights should
never reach near the 2^32 boundary, otherwise we're prone to any kind
of numerical error.  there are no problems with weight being u32.


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

bfq_calc_finish() is used in two cases:

  1) we need to resync the finish time with the service received by an
    entity

  2) we need to assign a new finish time to an entity when it's enqueued

with preemptions 1) can happen with service = 0, and we need to reset the
finish time to the start time (depending on how preemptions are implemented),
so in this case we'd have a false positive (leading to a crashed system :) ).


> > +
> > +static inline struct io_queue *io_entity_to_ioq(struct io_entity *entity)
> > +{
> > +	struct io_queue *ioq = NULL;
> > +
> > +	BUG_ON(entity == NULL);
> > +	if (entity->my_sched_data == NULL)
> > +		ioq = container_of(entity, struct io_queue, entity);
> > +	return ioq;
> > +}
> > +
> > +/**
> > + * bfq_entity_of - get an entity from a node.
> > + * @node: the node field of the entity.
> > + *
> > + * Convert a node pointer to the relative entity.  This is used only
> > + * to simplify the logic of some functions and not as the generic
> > + * conversion mechanism because, e.g., in the tree walking functions,
> > + * the check for a %NULL value would be redundant.
> > + */
> > +static inline struct io_entity *bfq_entity_of(struct rb_node *node)
> > +{
> > +	struct io_entity *entity = NULL;
> > +
> > +	if (node != NULL)
> > +		entity = rb_entry(node, struct io_entity, rb_node);
> > +
> > +	return entity;
> > +}
> > +
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
> > +	BUG_ON(entity->tree != root);
> > +
> > +	entity->tree = NULL;
> > +	rb_erase(&entity->rb_node, root);
> 
> Don't you want to make entity->tree = NULL after rb_erase?
> 

this code assumes to be executed under spinlock, so order doesn't really
matter (tree is not affected by rb_erase(), it is a bfq private field).


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

the bfq_entity_of() call below returns NULL


> > +		st->first_idle = bfq_entity_of(next);
> > +	}
> > +
> > +	if (entity == st->last_idle) {
> > +		next = rb_prev(&entity->rb_node);
> 
> What happens if next is NULL?
> 

same as above


> > +		st->last_idle = bfq_entity_of(next);
> > +	}
> > +
> > +	bfq_extract(&st->idle, entity);
> > +}
> > +
> > +/**
> > + * bfq_insert - generic tree insertion.
> > + * @root: tree root.
> > + * @entity: entity to insert.
> > + *
> > + * This is used for the idle and the active tree, since they are both
> > + * ordered by finish time.
> > + */
> > +static void bfq_insert(struct rb_root *root, struct io_entity *entity)
> > +{
> > +	struct io_entity *entry;
> > +	struct rb_node **node = &root->rb_node;
> > +	struct rb_node *parent = NULL;
> > +
> > +	BUG_ON(entity->tree != NULL);
> > +
> > +	while (*node != NULL) {
> > +		parent = *node;
> > +		entry = rb_entry(parent, struct io_entity, rb_node);
> > +
> > +		if (bfq_gt(entry->finish, entity->finish))
> > +			node = &parent->rb_left;
> > +		else
> > +			node = &parent->rb_right;
> > +	}
> > +
> > +	rb_link_node(&entity->rb_node, parent, node);
> > +	rb_insert_color(&entity->rb_node, root);
> > +
> > +	entity->tree = root;
> > +}
> > +
> > +/**
> > + * bfq_update_min - update the min_start field of a entity.
> > + * @entity: the entity to update.
> > + * @node: one of its children.
> > + *
> > + * This function is called when @entity may store an invalid value for
> > + * min_start due to updates to the active tree.  The function  assumes
> > + * that the subtree rooted at @node (which may be its left or its right
> > + * child) has a valid min_start value.
> > + */
> > +static inline void bfq_update_min(struct io_entity *entity,
> > +					struct rb_node *node)
> > +{
> > +	struct io_entity *child;
> > +
> > +	if (node != NULL) {
> > +		child = rb_entry(node, struct io_entity, rb_node);
> > +		if (bfq_gt(entity->min_start, child->min_start))
> > +			entity->min_start = child->min_start;
> > +	}
> > +}
> 
> So.. we check to see if child's min_time is lesser than the root
> entities or node entities and set it to the minimum of the two?
> Can you use min_t here?
> 

no, it would not deal with wraparound correctly


> > +
> > +/**
> > + * bfq_update_active_node - recalculate min_start.
> > + * @node: the node to update.
> > + *
> > + * @node may have changed position or one of its children may have moved,
> > + * this function updates its min_start value.  The left and right subtrees
> > + * are assumed to hold a correct min_start value.
> > + */
> > +static inline void bfq_update_active_node(struct rb_node *node)
> > +{
> > +	struct io_entity *entity = rb_entry(node, struct io_entity, rb_node);
> > +
> > +	entity->min_start = entity->start;
> > +	bfq_update_min(entity, node->rb_right);
> > +	bfq_update_min(entity, node->rb_left);
> > +}
> 
> I don't like this every much, we set the min_time twice, this can be
> easily optimized to look at both left and right child and pick the
> minimum.
> 

it's a minimum between three values (the ->start fields of the two children
and of the node itself), you cannot be sure it will be set twice


> > +
> > +/**
> > + * bfq_update_active_tree - update min_start for the whole active tree.
> > + * @node: the starting node.
> > + *
> > + * @node must be the deepest modified node after an update.  This function
> > + * updates its min_start using the values held by its children, assuming
> > + * that they did not change, and then updates all the nodes that may have
> > + * changed in the path to the root.  The only nodes that may have changed
> > + * are the ones in the path or their siblings.
> > + */
> > +static void bfq_update_active_tree(struct rb_node *node)
> > +{
> > +	struct rb_node *parent;
> > +
> > +up:
> > +	bfq_update_active_node(node);
> > +
> > +	parent = rb_parent(node);
> > +	if (parent == NULL)
> > +		return;
> > +
> > +	if (node == parent->rb_left && parent->rb_right != NULL)
> > +		bfq_update_active_node(parent->rb_right);
> > +	else if (parent->rb_left != NULL)
> > +		bfq_update_active_node(parent->rb_left);
> > +
> > +	node = parent;
> > +	goto up;
> > +}
> > +
> 
> For these functions, take a look at the walk function in the group
> scheduler that does update_shares
> 

are you sure?  AFAICT walk_tg_tree() walks all over the tree, this just
walks a single path to a node up to the root, I don't see what the two
have in common.

in the original patches we cited (among the others):

  http://www.cs.berkeley.edu/~istoica/papers/eevdf-tr-95.pdf

which contains a description of the algorithm.


> > +/**
> > + * bfq_active_insert - insert an entity in the active tree of its group/device.
> > + * @st: the service tree of the entity.
> > + * @entity: the entity being inserted.
> > + *
> > + * The active tree is ordered by finish time, but an extra key is kept
> > + * per each node, containing the minimum value for the start times of
> > + * its children (and the node itself), so it's possible to search for
> > + * the eligible node with the lowest finish time in logarithmic time.
> > + */
> > +static void bfq_active_insert(struct io_service_tree *st,
> > +					struct io_entity *entity)
> > +{
> > +	struct rb_node *node = &entity->rb_node;
> > +
> > +	bfq_insert(&st->active, entity);
> > +
> > +	if (node->rb_left != NULL)
> > +		node = node->rb_left;
> > +	else if (node->rb_right != NULL)
> > +		node = node->rb_right;
> > +
> > +	bfq_update_active_tree(node);
> > +}
> > +
> > +/**
> > + * bfq_ioprio_to_weight - calc a weight from an ioprio.
> > + * @ioprio: the ioprio value to convert.
> > + */
> > +static bfq_weight_t bfq_ioprio_to_weight(int ioprio)
> > +{
> > +	WARN_ON(ioprio < 0 || ioprio >= IOPRIO_BE_NR);
> > +	return IOPRIO_BE_NR - ioprio;
> > +}
> > +
> > +void bfq_get_entity(struct io_entity *entity)
> > +{
> > +	struct io_queue *ioq = io_entity_to_ioq(entity);
> > +
> > +	if (ioq)
> > +		elv_get_ioq(ioq);
> > +}
> > +
> > +void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
> > +{
> > +	entity->ioprio = entity->new_ioprio;
> > +	entity->ioprio_class = entity->new_ioprio_class;
> > +	entity->sched_data = &iog->sched_data;
> > +}
> > +
> > +/**
> > + * bfq_find_deepest - find the deepest node that an extraction can modify.
> > + * @node: the node being removed.
> > + *
> > + * Do the first step of an extraction in an rb tree, looking for the
> > + * node that will replace @node, and returning the deepest node that
> > + * the following modifications to the tree can touch.  If @node is the
> > + * last node in the tree return %NULL.
> > + */
> > +static struct rb_node *bfq_find_deepest(struct rb_node *node)
> > +{
> > +	struct rb_node *deepest;
> > +
> > +	if (node->rb_right == NULL && node->rb_left == NULL)
> > +		deepest = rb_parent(node);
> 
> Why is the parent the deepest? Shouldn't node be the deepest?
> 

this is related to how the RB tree is updated (see below)


> > +	else if (node->rb_right == NULL)
> > +		deepest = node->rb_left;
> > +	else if (node->rb_left == NULL)
> > +		deepest = node->rb_right;
> > +	else {
> > +		deepest = rb_next(node);
> > +		if (deepest->rb_right != NULL)
> > +			deepest = deepest->rb_right;
> > +		else if (rb_parent(deepest) != node)
> > +			deepest = rb_parent(deepest);
> > +	}
> > +
> > +	return deepest;
> > +}
> 
> The function is not clear, could you please define deepest node
> better?
> 

according to the paper cited above, we need to update the min_start
value on the path from the deepest node modified by the extraction
up to the root.  this function tries to consider all the cases of RB
extraction, looking for the deepest node that (after all the rotations
etc.) will need an update to min_start.  one interesting property
of RB trees is that this can be done in O(log N) because there is a
single path that needs to be updated.


> > +
> > +/**
> > + * bfq_active_extract - remove an entity from the active tree.
> > + * @st: the service_tree containing the tree.
> > + * @entity: the entity being removed.
> > + */
> > +static void bfq_active_extract(struct io_service_tree *st,
> > +				struct io_entity *entity)
> > +{
> > +	struct rb_node *node;
> > +
> > +	node = bfq_find_deepest(&entity->rb_node);
> > +	bfq_extract(&st->active, entity);
> > +
> > +	if (node != NULL)
> > +		bfq_update_active_tree(node);
> > +}
> > +
> 
> Just to check my understanding, every time an active node is
> added/removed, we update the min_time of the entire tree.
> 

yes, but only O(log N) nodes need to be updated


> > +/**
> > + * bfq_idle_insert - insert an entity into the idle tree.
> > + * @st: the service tree containing the tree.
> > + * @entity: the entity to insert.
> > + */
> > +static void bfq_idle_insert(struct io_service_tree *st,
> > +					struct io_entity *entity)
> > +{
> > +	struct io_entity *first_idle = st->first_idle;
> > +	struct io_entity *last_idle = st->last_idle;
> > +
> > +	if (first_idle == NULL || bfq_gt(first_idle->finish, entity->finish))
> > +		st->first_idle = entity;
> > +	if (last_idle == NULL || bfq_gt(entity->finish, last_idle->finish))
> > +		st->last_idle = entity;
> > +
> > +	bfq_insert(&st->idle, entity);
> > +}
> > +
> > +/**
> > + * bfq_forget_entity - remove an entity from the wfq trees.
> > + * @st: the service tree.
> > + * @entity: the entity being removed.
> > + *
> > + * Update the device status and forget everything about @entity, putting
> > + * the device reference to it, if it is a queue.  Entities belonging to
> > + * groups are not refcounted.
> > + */
> > +static void bfq_forget_entity(struct io_service_tree *st,
> > +				struct io_entity *entity)
> > +{
> > +	struct io_queue *ioq = NULL;
> > +
> > +	BUG_ON(!entity->on_st);
> > +	entity->on_st = 0;
> > +	st->wsum -= entity->weight;
> > +	ioq = io_entity_to_ioq(entity);
> > +	if (!ioq)
> > +		return;
> > +	elv_put_ioq(ioq);
> > +}
> > +
> > +/**
> > + * bfq_put_idle_entity - release the idle tree ref of an entity.
> > + * @st: service tree for the entity.
> > + * @entity: the entity being released.
> > + */
> > +void bfq_put_idle_entity(struct io_service_tree *st,
> > +				struct io_entity *entity)
> > +{
> > +	bfq_idle_extract(st, entity);
> > +	bfq_forget_entity(st, entity);
> > +}
> > +
> > +/**
> > + * bfq_forget_idle - update the idle tree if necessary.
> > + * @st: the service tree to act upon.
> > + *
> > + * To preserve the global O(log N) complexity we only remove one entry here;
> > + * as the idle tree will not grow indefinitely this can be done safely.
> > + */
> > +void bfq_forget_idle(struct io_service_tree *st)
> > +{
> > +	struct io_entity *first_idle = st->first_idle;
> > +	struct io_entity *last_idle = st->last_idle;
> > +
> > +	if (RB_EMPTY_ROOT(&st->active) && last_idle != NULL &&
> > +	    !bfq_gt(last_idle->finish, st->vtime)) {
> > +		/*
> > +		 * Active tree is empty. Pull back vtime to finish time of
> > +		 * last idle entity on idle tree.
> > +		 * Rational seems to be that it reduces the possibility of
> > +		 * vtime wraparound (bfq_gt(V-F) < 0).
> > +		 */
> > +		st->vtime = last_idle->finish;
> > +	}
> > +
> > +	if (first_idle != NULL && !bfq_gt(first_idle->finish, st->vtime))
> > +		bfq_put_idle_entity(st, first_idle);
> > +}
> > +
> > +
> > +static struct io_service_tree *
> > +__bfq_entity_update_prio(struct io_service_tree *old_st,
> > +				struct io_entity *entity)
> > +{
> > +	struct io_service_tree *new_st = old_st;
> > +	struct io_queue *ioq = io_entity_to_ioq(entity);
> > +
> > +	if (entity->ioprio_changed) {
> > +		entity->ioprio = entity->new_ioprio;
> > +		entity->ioprio_class = entity->new_ioprio_class;
> > +		entity->ioprio_changed = 0;
> > +
> > +		/*
> > +		 * Also update the scaled budget for ioq. Group will get the
> > +		 * updated budget once ioq is selected to run next.
> > +		 */
> > +		if (ioq) {
> > +			struct elv_fq_data *efqd = ioq->efqd;
> > +			entity->budget = elv_prio_to_slice(efqd, ioq);
> > +		}
> > +
> > +		old_st->wsum -= entity->weight;
> > +		entity->weight = bfq_ioprio_to_weight(entity->ioprio);
> > +
> > +		/*
> > +		 * NOTE: here we may be changing the weight too early,
> > +		 * this will cause unfairness.  The correct approach
> > +		 * would have required additional complexity to defer
> > +		 * weight changes to the proper time instants (i.e.,
> > +		 * when entity->finish <= old_st->vtime).
> > +		 */
> > +		new_st = io_entity_service_tree(entity);
> > +		new_st->wsum += entity->weight;
> > +
> > +		if (new_st != old_st)
> > +			entity->start = new_st->vtime;
> > +	}
> > +
> > +	return new_st;
> > +}
> > +
> > +/**
> > + * __bfq_activate_entity - activate an entity.
> > + * @entity: the entity being activated.
> > + *
> > + * Called whenever an entity is activated, i.e., it is not active and one
> > + * of its children receives a new request, or has to be reactivated due to
> > + * budget exhaustion.  It uses the current budget of the entity (and the
> > + * service received if @entity is active) of the queue to calculate its
> > + * timestamps.
> > + */
> > +static void __bfq_activate_entity(struct io_entity *entity, int add_front)
> > +{
> > +	struct io_sched_data *sd = entity->sched_data;
> > +	struct io_service_tree *st = io_entity_service_tree(entity);
> > +
> > +	if (entity == sd->active_entity) {
> > +		BUG_ON(entity->tree != NULL);
> > +		/*
> > +		 * If we are requeueing the current entity we have
> > +		 * to take care of not charging to it service it has
> > +		 * not received.
> > +		 */
> > +		bfq_calc_finish(entity, entity->service);
> > +		entity->start = entity->finish;
> > +		sd->active_entity = NULL;
> > +	} else if (entity->tree == &st->active) {
> > +		/*
> > +		 * Requeueing an entity due to a change of some
> > +		 * next_active entity below it.  We reuse the old
> > +		 * start time.
> > +		 */
> > +		bfq_active_extract(st, entity);
> > +	} else if (entity->tree == &st->idle) {
> > +		/*
> > +		 * Must be on the idle tree, bfq_idle_extract() will
> > +		 * check for that.
> > +		 */
> > +		bfq_idle_extract(st, entity);
> > +		entity->start = bfq_gt(st->vtime, entity->finish) ?
> > +				       st->vtime : entity->finish;
> > +	} else {
> > +		/*
> > +		 * The finish time of the entity may be invalid, and
> > +		 * it is in the past for sure, otherwise the queue
> > +		 * would have been on the idle tree.
> > +		 */
> > +		entity->start = st->vtime;
> > +		st->wsum += entity->weight;
> > +		bfq_get_entity(entity);
> > +
> > +		BUG_ON(entity->on_st);
> > +		entity->on_st = 1;
> > +	}
> > +
> > +	st = __bfq_entity_update_prio(st, entity);
> > +	/*
> > +	 * This is to emulate cfq like functionality where preemption can
> > +	 * happen with-in same class, like sync queue preempting async queue
> > +	 * May be this is not a very good idea from fairness point of view
> > +	 * as preempting queue gains share. Keeping it for now.
> > +	 */
> > +	if (add_front) {
> > +		struct io_entity *next_entity;
> > +
> > +		/*
> > +		 * Determine the entity which will be dispatched next
> > +		 * Use sd->next_active once hierarchical patch is applied
> > +		 */
> > +		next_entity = bfq_lookup_next_entity(sd, 0);
> > +
> > +		if (next_entity && next_entity != entity) {
> > +			struct io_service_tree *new_st;
> > +			bfq_timestamp_t delta;
> > +
> > +			new_st = io_entity_service_tree(next_entity);
> > +
> > +			/*
> > +			 * At this point, both entities should belong to
> > +			 * same service tree as cross service tree preemption
> > +			 * is automatically taken care by algorithm
> > +			 */
> > +			BUG_ON(new_st != st);
> > +			entity->finish = next_entity->finish - 1;
> > +			delta = bfq_delta(entity->budget, entity->weight);
> > +			entity->start = entity->finish - delta;
> > +			if (bfq_gt(entity->start, st->vtime))
> > +				entity->start = st->vtime;
> > +		}
> > +	} else {
> > +		bfq_calc_finish(entity, entity->budget);
> > +	}
> > +	bfq_active_insert(st, entity);
> > +}
> > +
> > +/**
> > + * bfq_activate_entity - activate an entity.
> > + * @entity: the entity to activate.
> > + */
> > +void bfq_activate_entity(struct io_entity *entity, int add_front)
> > +{
> > +	__bfq_activate_entity(entity, add_front);
> > +}
> > +
> > +/**
> > + * __bfq_deactivate_entity - deactivate an entity from its service tree.
> > + * @entity: the entity to deactivate.
> > + * @requeue: if false, the entity will not be put into the idle tree.
> > + *
> > + * Deactivate an entity, independently from its previous state.  If the
> > + * entity was not on a service tree just return, otherwise if it is on
> > + * any scheduler tree, extract it from that tree, and if necessary
> > + * and if the caller did not specify @requeue, put it on the idle tree.
> > + *
> > + */
> > +int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
> > +{
> > +	struct io_sched_data *sd = entity->sched_data;
> > +	struct io_service_tree *st = io_entity_service_tree(entity);
> > +	int was_active = entity == sd->active_entity;
> > +	int ret = 0;
> > +
> > +	if (!entity->on_st)
> > +		return 0;
> > +
> > +	BUG_ON(was_active && entity->tree != NULL);
> > +
> > +	if (was_active) {
> > +		bfq_calc_finish(entity, entity->service);
> > +		sd->active_entity = NULL;
> > +	} else if (entity->tree == &st->active)
> > +		bfq_active_extract(st, entity);
> > +	else if (entity->tree == &st->idle)
> > +		bfq_idle_extract(st, entity);
> > +	else if (entity->tree != NULL)
> > +		BUG();
> > +
> > +	if (!requeue || !bfq_gt(entity->finish, st->vtime))
> > +		bfq_forget_entity(st, entity);
> > +	else
> > +		bfq_idle_insert(st, entity);
> > +
> > +	BUG_ON(sd->active_entity == entity);
> > +
> > +	return ret;
> > +}
> > +
> > +/**
> > + * bfq_deactivate_entity - deactivate an entity.
> > + * @entity: the entity to deactivate.
> > + * @requeue: true if the entity can be put on the idle tree
> > + */
> > +void bfq_deactivate_entity(struct io_entity *entity, int requeue)
> > +{
> > +	__bfq_deactivate_entity(entity, requeue);
> > +}
> > +
> > +/**
> > + * bfq_update_vtime - update vtime if necessary.
> > + * @st: the service tree to act upon.
> > + *
> > + * If necessary update the service tree vtime to have at least one
> > + * eligible entity, skipping to its start time.  Assumes that the
> > + * active tree of the device is not empty.
> > + *
> > + * NOTE: this hierarchical implementation updates vtimes quite often,
> > + * we may end up with reactivated tasks getting timestamps after a
> > + * vtime skip done because we needed a ->first_active entity on some
> > + * intermediate node.
> > + */
> > +static void bfq_update_vtime(struct io_service_tree *st)
> > +{
> > +	struct io_entity *entry;
> > +	struct rb_node *node = st->active.rb_node;
> > +
> > +	entry = rb_entry(node, struct io_entity, rb_node);
> > +	if (bfq_gt(entry->min_start, st->vtime)) {
> > +		st->vtime = entry->min_start;
> > +		bfq_forget_idle(st);
> > +	}
> > +}
> > +
> > +/**
> > + * bfq_first_active - find the eligible entity with the smallest finish time
> > + * @st: the service tree to select from.
> > + *
> > + * This function searches the first schedulable entity, starting from the
> > + * root of the tree and going on the left every time on this side there is
> > + * a subtree with at least one eligible (start <= vtime) entity.  The path
> > + * on the right is followed only if a) the left subtree contains no eligible
> > + * entities and b) no eligible entity has been found yet.
> > + */
> > +static struct io_entity *bfq_first_active_entity(struct io_service_tree *st)
> > +{
> > +	struct io_entity *entry, *first = NULL;
> > +	struct rb_node *node = st->active.rb_node;
> > +
> > +	while (node != NULL) {
> > +		entry = rb_entry(node, struct io_entity, rb_node);
> > +left:
> > +		if (!bfq_gt(entry->start, st->vtime))
> > +			first = entry;
> > +
> > +		BUG_ON(bfq_gt(entry->min_start, st->vtime));
> > +
> > +		if (node->rb_left != NULL) {
> > +			entry = rb_entry(node->rb_left,
> > +					 struct io_entity, rb_node);
> > +			if (!bfq_gt(entry->min_start, st->vtime)) {
> > +				node = node->rb_left;
> > +				goto left;
> > +			}
> > +		}
> > +		if (first != NULL)
> > +			break;
> > +		node = node->rb_right;
> 
> Please help me understand this, we sort the tree by finish time, but
> search by vtime, start_time. The worst case could easily be O(N),
> right?
> 

no, (again, the full answer is in the paper); the nice property of
min_start is that it partitions the tree in two regions, one with
eligible entities and one without any of them.  once we know that
there is one eligible entity (checking the min_start at the root)
we can find the node i with min(F_i) subject to S_i < V walking down
a single path from the root to the leftmost eligible entity.  (we
need to go to the right only if the subtree on the left contains 
no eligible entities at all.)  since the RB tree is balanced this
can be done in O(log N).


> > +	}
> > +
> > +	BUG_ON(first == NULL && !RB_EMPTY_ROOT(&st->active));
> > +	return first;
> > +}
> > +
> > +/**
> > + * __bfq_lookup_next_entity - return the first eligible entity in @st.
> > + * @st: the service tree.
> > + *
> > + * Update the virtual time in @st and return the first eligible entity
> > + * it contains.
> > + */
> > +static struct io_entity *__bfq_lookup_next_entity(struct io_service_tree *st)
> > +{
> > +	struct io_entity *entity;
> > +
> > +	if (RB_EMPTY_ROOT(&st->active))
> > +		return NULL;
> > +
> > +	bfq_update_vtime(st);
> > +	entity = bfq_first_active_entity(st);
> > +	BUG_ON(bfq_gt(entity->start, st->vtime));
> > +
> > +	return entity;
> > +}
> > +
> > +/**
> > + * bfq_lookup_next_entity - return the first eligible entity in @sd.
> > + * @sd: the sched_data.
> > + * @extract: if true the returned entity will be also extracted from @sd.
> > + *
> > + * NOTE: since we cache the next_active entity at each level of the
> > + * hierarchy, the complexity of the lookup can be decreased with
> > + * absolutely no effort just returning the cached next_active value;
> > + * we prefer to do full lookups to test the consistency of * the data
> > + * structures.
> > + */
> > +struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
> > +						 int extract)
> > +{
> > +	struct io_service_tree *st = sd->service_tree;
> > +	struct io_entity *entity;
> > +	int i;
> > +
> > +	/*
> > +	 * We should not call lookup when an entity is active, as doing lookup
> > +	 * can result in an erroneous vtime jump.
> > +	 */
> > +	BUG_ON(sd->active_entity != NULL);
> > +
> > +	for (i = 0; i < IO_IOPRIO_CLASSES; i++, st++) {
> > +		entity = __bfq_lookup_next_entity(st);
> > +		if (entity != NULL) {
> > +			if (extract) {
> > +				bfq_active_extract(st, entity);
> > +				sd->active_entity = entity;
> > +			}
> > +			break;
> > +		}
> > +	}
> > +
> > +	return entity;
> > +}
> > +
> > +void entity_served(struct io_entity *entity, bfq_service_t served)
> > +{
> > +	struct io_service_tree *st;
> > +
> > +	st = io_entity_service_tree(entity);
> > +	entity->service += served;
> > +	BUG_ON(st->wsum == 0);
> > +	st->vtime += bfq_delta(served, st->wsum);
> > +	bfq_forget_idle(st);
> 
> Forget idle checks to see if the st->vtime > first_idle->finish, if so
> it pushes the first_idle to later, right?
> 

yes, updating the weight sum accordingly


> > +}
> > +
> > +/**
> > + * bfq_flush_idle_tree - deactivate any entity on the idle tree of @st.
> > + * @st: the service tree being flushed.
> > + */
> > +void io_flush_idle_tree(struct io_service_tree *st)
> > +{
> > +	struct io_entity *entity = st->first_idle;
> > +
> > +	for (; entity != NULL; entity = st->first_idle)
> > +		__bfq_deactivate_entity(entity, 0);
> > +}
> > +
> > +/* Elevator fair queuing function */
> > +struct io_queue *rq_ioq(struct request *rq)
> > +{
> > +	return rq->ioq;
> > +}
> > +
> > +static inline struct io_queue *elv_active_ioq(struct elevator_queue *e)
> > +{
> > +	return e->efqd.active_queue;
> > +}
> > +
> > +void *elv_active_sched_queue(struct elevator_queue *e)
> > +{
> > +	return ioq_sched_queue(elv_active_ioq(e));
> > +}
> > +EXPORT_SYMBOL(elv_active_sched_queue);
> > +
> > +int elv_nr_busy_ioq(struct elevator_queue *e)
> > +{
> > +	return e->efqd.busy_queues;
> > +}
> > +EXPORT_SYMBOL(elv_nr_busy_ioq);
> > +
> > +int elv_hw_tag(struct elevator_queue *e)
> > +{
> > +	return e->efqd.hw_tag;
> > +}
> > +EXPORT_SYMBOL(elv_hw_tag);
> > +
> > +/* Helper functions for operating on elevator idle slice timer */
> > +int elv_mod_idle_slice_timer(struct elevator_queue *eq, unsigned long expires)
> > +{
> > +	struct elv_fq_data *efqd = &eq->efqd;
> > +
> > +	return mod_timer(&efqd->idle_slice_timer, expires);
> > +}
> > +EXPORT_SYMBOL(elv_mod_idle_slice_timer);
> > +
> > +int elv_del_idle_slice_timer(struct elevator_queue *eq)
> > +{
> > +	struct elv_fq_data *efqd = &eq->efqd;
> > +
> > +	return del_timer(&efqd->idle_slice_timer);
> > +}
> > +EXPORT_SYMBOL(elv_del_idle_slice_timer);
> > +
> > +unsigned int elv_get_slice_idle(struct elevator_queue *eq)
> > +{
> > +	return eq->efqd.elv_slice_idle;
> > +}
> > +EXPORT_SYMBOL(elv_get_slice_idle);
> > +
> > +void elv_ioq_served(struct io_queue *ioq, bfq_service_t served)
> > +{
> > +	entity_served(&ioq->entity, served);
> > +}
> > +
> > +/* Tells whether ioq is queued in root group or not */
> > +static inline int is_root_group_ioq(struct request_queue *q,
> > +					struct io_queue *ioq)
> > +{
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +
> > +	return (ioq->entity.sched_data == &efqd->root_group->sched_data);
> > +}
> > +
> > +/*
> > + * sysfs parts below -->
> > + */
> > +static ssize_t
> > +elv_var_show(unsigned int var, char *page)
> > +{
> > +	return sprintf(page, "%d\n", var);
> > +}
> > +
> > +static ssize_t
> > +elv_var_store(unsigned int *var, const char *page, size_t count)
> > +{
> > +	char *p = (char *) page;
> > +
> > +	*var = simple_strtoul(p, &p, 10);
> > +	return count;
> > +}
> > +
> > +#define SHOW_FUNCTION(__FUNC, __VAR, __CONV)				\
> > +ssize_t __FUNC(struct elevator_queue *e, char *page)		\
> > +{									\
> > +	struct elv_fq_data *efqd = &e->efqd;				\
> > +	unsigned int __data = __VAR;					\
> > +	if (__CONV)							\
> > +		__data = jiffies_to_msecs(__data);			\
> > +	return elv_var_show(__data, (page));				\
> > +}
> > +SHOW_FUNCTION(elv_slice_idle_show, efqd->elv_slice_idle, 1);
> > +EXPORT_SYMBOL(elv_slice_idle_show);
> > +SHOW_FUNCTION(elv_slice_sync_show, efqd->elv_slice[1], 1);
> > +EXPORT_SYMBOL(elv_slice_sync_show);
> > +SHOW_FUNCTION(elv_slice_async_show, efqd->elv_slice[0], 1);
> > +EXPORT_SYMBOL(elv_slice_async_show);
> > +#undef SHOW_FUNCTION
> > +
> > +#define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
> > +ssize_t __FUNC(struct elevator_queue *e, const char *page, size_t count)\
> > +{									\
> > +	struct elv_fq_data *efqd = &e->efqd;				\
> > +	unsigned int __data;						\
> > +	int ret = elv_var_store(&__data, (page), count);		\
> > +	if (__data < (MIN))						\
> > +		__data = (MIN);						\
> > +	else if (__data > (MAX))					\
> > +		__data = (MAX);						\
> > +	if (__CONV)							\
> > +		*(__PTR) = msecs_to_jiffies(__data);			\
> > +	else								\
> > +		*(__PTR) = __data;					\
> > +	return ret;							\
> > +}
> > +STORE_FUNCTION(elv_slice_idle_store, &efqd->elv_slice_idle, 0, UINT_MAX, 1);
> > +EXPORT_SYMBOL(elv_slice_idle_store);
> > +STORE_FUNCTION(elv_slice_sync_store, &efqd->elv_slice[1], 1, UINT_MAX, 1);
> > +EXPORT_SYMBOL(elv_slice_sync_store);
> > +STORE_FUNCTION(elv_slice_async_store, &efqd->elv_slice[0], 1, UINT_MAX, 1);
> > +EXPORT_SYMBOL(elv_slice_async_store);
> > +#undef STORE_FUNCTION
> > +
> > +void elv_schedule_dispatch(struct request_queue *q)
> > +{
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +
> > +	if (elv_nr_busy_ioq(q->elevator)) {
> > +		elv_log(efqd, "schedule dispatch");
> > +		kblockd_schedule_work(efqd->queue, &efqd->unplug_work);
> > +	}
> > +}
> > +EXPORT_SYMBOL(elv_schedule_dispatch);
> > +
> > +void elv_kick_queue(struct work_struct *work)
> > +{
> > +	struct elv_fq_data *efqd =
> > +		container_of(work, struct elv_fq_data, unplug_work);
> > +	struct request_queue *q = efqd->queue;
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(q->queue_lock, flags);
> > +	blk_start_queueing(q);
> > +	spin_unlock_irqrestore(q->queue_lock, flags);
> > +}
> > +
> > +void elv_shutdown_timer_wq(struct elevator_queue *e)
> > +{
> > +	del_timer_sync(&e->efqd.idle_slice_timer);
> > +	cancel_work_sync(&e->efqd.unplug_work);
> > +}
> > +EXPORT_SYMBOL(elv_shutdown_timer_wq);
> > +
> > +void elv_ioq_set_prio_slice(struct request_queue *q, struct io_queue *ioq)
> > +{
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +
> > +	ioq->slice_end = jiffies + ioq->entity.budget;
> > +	elv_log_ioq(efqd, ioq, "set_slice=%lu", ioq->entity.budget);
> > +}
> > +
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
> 

this came from cfq, it's a variation of an exponential moving average,
with ttime_samples used to scale the average value.


> > +
> > +/*
> > + * Disable idle window if the process thinks too long.
> > + * This idle flag can also be updated by io scheduler.
> > + */
> > +static void elv_ioq_update_idle_window(struct elevator_queue *eq,
> > +				struct io_queue *ioq, struct request *rq)
> > +{
> > +	int old_idle, enable_idle;
> > +	struct elv_fq_data *efqd = ioq->efqd;
> > +
> > +	/*
> > +	 * Don't idle for async or idle io prio class
> > +	 */
> > +	if (!elv_ioq_sync(ioq) || elv_ioq_class_idle(ioq))
> > +		return;
> > +
> > +	enable_idle = old_idle = elv_ioq_idle_window(ioq);
> > +
> > +	if (!efqd->elv_slice_idle)
> > +		enable_idle = 0;
> > +	else if (ioq_sample_valid(ioq->ttime_samples)) {
> > +		if (ioq->ttime_mean > efqd->elv_slice_idle)
> > +			enable_idle = 0;
> > +		else
> > +			enable_idle = 1;
> > +	}
> > +
> > +	/*
> > +	 * From think time perspective idle should be enabled. Check with
> > +	 * io scheduler if it wants to disable idling based on additional
> > +	 * considrations like seek pattern.
> > +	 */
> > +	if (enable_idle) {
> > +		if (eq->ops->elevator_update_idle_window_fn)
> > +			enable_idle = eq->ops->elevator_update_idle_window_fn(
> > +						eq, ioq->sched_queue, rq);
> > +		if (!enable_idle)
> > +			elv_log_ioq(efqd, ioq, "iosched disabled idle");
> > +	}
> > +
> > +	if (old_idle != enable_idle) {
> > +		elv_log_ioq(efqd, ioq, "idle=%d", enable_idle);
> > +		if (enable_idle)
> > +			elv_mark_ioq_idle_window(ioq);
> > +		else
> > +			elv_clear_ioq_idle_window(ioq);
> > +	}
> > +}
> > +
> > +struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask)
> > +{
> > +	struct io_queue *ioq = NULL;
> > +
> > +	ioq = kmem_cache_alloc_node(elv_ioq_pool, gfp_mask, q->node);
> > +	return ioq;
> > +}
> > +EXPORT_SYMBOL(elv_alloc_ioq);
> > +
> > +void elv_free_ioq(struct io_queue *ioq)
> > +{
> > +	kmem_cache_free(elv_ioq_pool, ioq);
> > +}
> > +EXPORT_SYMBOL(elv_free_ioq);
> > +
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
> > +	ioq->sched_queue = sched_queue;
> > +	if (is_sync && !elv_ioq_class_idle(ioq))
> > +		elv_mark_ioq_idle_window(ioq);
> > +	bfq_init_entity(&ioq->entity, iog);
> > +	ioq->entity.budget = elv_prio_to_slice(efqd, ioq);
> > +	if (is_sync)
> > +		ioq->last_end_request = jiffies;
> > +
> > +	return 0;
> > +}
> > +EXPORT_SYMBOL(elv_init_ioq);
> > +
> > +void elv_put_ioq(struct io_queue *ioq)
> > +{
> > +	struct elv_fq_data *efqd = ioq->efqd;
> > +	struct elevator_queue *e = container_of(efqd, struct elevator_queue,
> > +						efqd);
> > +
> > +	BUG_ON(atomic_read(&ioq->ref) <= 0);
> > +	if (!atomic_dec_and_test(&ioq->ref))
> > +		return;
> > +	BUG_ON(ioq->nr_queued);
> > +	BUG_ON(ioq->entity.tree != NULL);
> > +	BUG_ON(elv_ioq_busy(ioq));
> > +	BUG_ON(efqd->active_queue == ioq);
> > +
> > +	/* Can be called by outgoing elevator. Don't use q */
> > +	BUG_ON(!e->ops->elevator_free_sched_queue_fn);
> > +
> > +	e->ops->elevator_free_sched_queue_fn(e, ioq->sched_queue);
> > +	elv_log_ioq(efqd, ioq, "put_queue");
> > +	elv_free_ioq(ioq);
> > +}
> > +EXPORT_SYMBOL(elv_put_ioq);
> > +
> > +void elv_release_ioq(struct elevator_queue *e, struct io_queue **ioq_ptr)
> > +{
> > +	struct io_queue *ioq = *ioq_ptr;
> > +
> > +	if (ioq != NULL) {
> > +		/* Drop the reference taken by the io group */
> > +		elv_put_ioq(ioq);
> > +		*ioq_ptr = NULL;
> > +	}
> > +}
> > +
> > +/*
> > + * Normally next io queue to be served is selected from the service tree.
> > + * This function allows one to choose a specific io queue to run next
> > + * out of order. This is primarily to accomodate the close_cooperator
> > + * feature of cfq.
> > + *
> > + * Currently it is done only for root level as to begin with supporting
> > + * close cooperator feature only for root group to make sure default
> > + * cfq behavior in flat hierarchy is not changed.
> > + */
> > +void elv_set_next_ioq(struct request_queue *q, struct io_queue *ioq)
> > +{
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +	struct io_entity *entity = &ioq->entity;
> > +	struct io_sched_data *sd = &efqd->root_group->sched_data;
> > +	struct io_service_tree *st = io_entity_service_tree(entity);
> > +
> > +	BUG_ON(efqd->active_queue != NULL || sd->active_entity != NULL);
> > +	BUG_ON(!efqd->busy_queues);
> > +	BUG_ON(sd != entity->sched_data);
> > +	BUG_ON(!st);
> > +
> > +	bfq_update_vtime(st);
> > +	bfq_active_extract(st, entity);
> > +	sd->active_entity = entity;
> > +	entity->service = 0;
> > +	elv_log_ioq(efqd, ioq, "set_next_ioq");
> > +}
> > +
> > +/* Get next queue for service. */
> > +struct io_queue *elv_get_next_ioq(struct request_queue *q, int extract)
> > +{
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +	struct io_entity *entity = NULL;
> > +	struct io_queue *ioq = NULL;
> > +	struct io_sched_data *sd;
> > +
> > +	/*
> > +	 * We should not call lookup when an entity is active, as doing
> > +	 * lookup can result in an erroneous vtime jump.
> > +	 */
> > +	BUG_ON(efqd->active_queue != NULL);
> > +
> > +	if (!efqd->busy_queues)
> > +		return NULL;
> > +
> > +	sd = &efqd->root_group->sched_data;
> > +	entity = bfq_lookup_next_entity(sd, 1);
> > +
> > +	BUG_ON(!entity);
> > +	if (extract)
> > +		entity->service = 0;
> > +	ioq = io_entity_to_ioq(entity);
> > +
> > +	return ioq;
> > +}
> > +
> > +/*
> > + * coop tells that io scheduler selected a queue for us and we did not
> 
> coop?
> 
> > + * select the next queue based on fairness.
> > + */
> > +static void __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
> > +					int coop)
> > +{
> > +	struct request_queue *q = efqd->queue;
> > +
> > +	if (ioq) {
> > +		elv_log_ioq(efqd, ioq, "set_active, busy=%d",
> > +							efqd->busy_queues);
> > +		ioq->slice_end = 0;
> > +
> > +		elv_clear_ioq_wait_request(ioq);
> > +		elv_clear_ioq_must_dispatch(ioq);
> > +		elv_mark_ioq_slice_new(ioq);
> > +
> > +		del_timer(&efqd->idle_slice_timer);
> > +	}
> > +
> > +	efqd->active_queue = ioq;
> > +
> > +	/* Let iosched know if it wants to take some action */
> > +	if (ioq) {
> > +		if (q->elevator->ops->elevator_active_ioq_set_fn)
> > +			q->elevator->ops->elevator_active_ioq_set_fn(q,
> > +							ioq->sched_queue, coop);
> > +	}
> > +}
> > +
> > +/* Get and set a new active queue for service. */
> > +struct io_queue *elv_set_active_ioq(struct request_queue *q,
> > +						struct io_queue *ioq)
> > +{
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +	int coop = 0;
> > +
> > +	if (!ioq)
> > +		ioq = elv_get_next_ioq(q, 1);
> > +	else {
> > +		elv_set_next_ioq(q, ioq);
> > +		/*
> > +		 * io scheduler selected the next queue for us. Pass this
> > +		 * this info back to io scheudler. cfq currently uses it
> > +		 * to reset coop flag on the queue.
> > +		 */
> > +		coop = 1;
> > +	}
> > +	__elv_set_active_ioq(efqd, ioq, coop);
> > +	return ioq;
> > +}
> > +
> > +void elv_reset_active_ioq(struct elv_fq_data *efqd)
> > +{
> > +	struct request_queue *q = efqd->queue;
> > +	struct io_queue *ioq = elv_active_ioq(efqd->queue->elevator);
> > +
> > +	if (q->elevator->ops->elevator_active_ioq_reset_fn)
> > +		q->elevator->ops->elevator_active_ioq_reset_fn(q,
> > +							ioq->sched_queue);
> > +	efqd->active_queue = NULL;
> > +	del_timer(&efqd->idle_slice_timer);
> > +}
> > +
> > +void elv_activate_ioq(struct io_queue *ioq, int add_front)
> > +{
> > +	bfq_activate_entity(&ioq->entity, add_front);
> > +}
> > +
> > +void elv_deactivate_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
> > +					int requeue)
> > +{
> > +	bfq_deactivate_entity(&ioq->entity, requeue);
> > +}
> > +
> > +/* Called when an inactive queue receives a new request. */
> > +void elv_add_ioq_busy(struct elv_fq_data *efqd, struct io_queue *ioq)
> > +{
> > +	BUG_ON(elv_ioq_busy(ioq));
> > +	BUG_ON(ioq == efqd->active_queue);
> > +	elv_log_ioq(efqd, ioq, "add to busy");
> > +	elv_activate_ioq(ioq, 0);
> > +	elv_mark_ioq_busy(ioq);
> > +	efqd->busy_queues++;
> > +	if (elv_ioq_class_rt(ioq)) {
> > +		struct io_group *iog = ioq_to_io_group(ioq);
> > +		iog->busy_rt_queues++;
> > +	}
> > +}
> > +
> > +void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq,
> > +					int requeue)
> > +{
> > +	struct elv_fq_data *efqd = &e->efqd;
> > +
> > +	BUG_ON(!elv_ioq_busy(ioq));
> > +	BUG_ON(ioq->nr_queued);
> > +	elv_log_ioq(efqd, ioq, "del from busy");
> > +	elv_clear_ioq_busy(ioq);
> > +	BUG_ON(efqd->busy_queues == 0);
> > +	efqd->busy_queues--;
> > +	if (elv_ioq_class_rt(ioq)) {
> > +		struct io_group *iog = ioq_to_io_group(ioq);
> > +		iog->busy_rt_queues--;
> > +	}
> > +
> > +	elv_deactivate_ioq(efqd, ioq, requeue);
> > +}
> > +
> > +/*
> > + * Do the accounting. Determine how much service (in terms of time slices)
> > + * current queue used and adjust the start, finish time of queue and vtime
> > + * of the tree accordingly.
> > + *
> > + * Determining the service used in terms of time is tricky in certain
> > + * situations. Especially when underlying device supports command queuing
> > + * and requests from multiple queues can be there at same time, then it
> > + * is not clear which queue consumed how much of disk time.
> > + *
> > + * To mitigate this problem, cfq starts the time slice of the queue only
> > + * after first request from the queue has completed. This does not work
> > + * very well if we expire the queue before we wait for first and more
> > + * request to finish from the queue. For seeky queues, we will expire the
> > + * queue after dispatching few requests without waiting and start dispatching
> > + * from next queue.
> > + *
> > + * Not sure how to determine the time consumed by queue in such scenarios.
> > + * Currently as a crude approximation, we are charging 25% of time slice
> > + * for such cases. A better mechanism is needed for accurate accounting.
> > + */
> > +void __elv_ioq_slice_expired(struct request_queue *q, struct io_queue *ioq)
> > +{
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +	struct io_entity *entity = &ioq->entity;
> > +	long slice_unused = 0, slice_used = 0, slice_overshoot = 0;
> > +
> > +	assert_spin_locked(q->queue_lock);
> > +	elv_log_ioq(efqd, ioq, "slice expired");
> > +
> > +	if (elv_ioq_wait_request(ioq))
> > +		del_timer(&efqd->idle_slice_timer);
> > +
> > +	elv_clear_ioq_wait_request(ioq);
> > +
> > +	/*
> > +	 * if ioq->slice_end = 0, that means a queue was expired before first
> > +	 * reuqest from the queue got completed. Of course we are not planning
> > +	 * to idle on the queue otherwise we would not have expired it.
> > +	 *
> > +	 * Charge for the 25% slice in such cases. This is not the best thing
> > +	 * to do but at the same time not very sure what's the next best
> > +	 * thing to do.
> > +	 *
> > +	 * This arises from that fact that we don't have the notion of
> > +	 * one queue being operational at one time. io scheduler can dispatch
> > +	 * requests from multiple queues in one dispatch round. Ideally for
> > +	 * more accurate accounting of exact disk time used by disk, one
> > +	 * should dispatch requests from only one queue and wait for all
> > +	 * the requests to finish. But this will reduce throughput.
> > +	 */
> > +	if (!ioq->slice_end)
> > +		slice_used = entity->budget/4;
> > +	else {
> > +		if (time_after(ioq->slice_end, jiffies)) {
> > +			slice_unused = ioq->slice_end - jiffies;
> > +			if (slice_unused == entity->budget) {
> > +				/*
> > +				 * queue got expired immediately after
> > +				 * completing first request. Charge 25% of
> > +				 * slice.
> > +				 */
> > +				slice_used = entity->budget/4;
> > +			} else
> > +				slice_used = entity->budget - slice_unused;
> > +		} else {
> > +			slice_overshoot = jiffies - ioq->slice_end;
> > +			slice_used = entity->budget + slice_overshoot;
> > +		}
> > +	}
> > +
> > +	elv_log_ioq(efqd, ioq, "sl_end=%lx, jiffies=%lx", ioq->slice_end,
> > +			jiffies);
> > +	elv_log_ioq(efqd, ioq, "sl_used=%ld, budget=%ld overshoot=%ld",
> > +				slice_used, entity->budget, slice_overshoot);
> > +	elv_ioq_served(ioq, slice_used);
> > +
> > +	BUG_ON(ioq != efqd->active_queue);
> > +	elv_reset_active_ioq(efqd);
> > +
> > +	if (!ioq->nr_queued)
> > +		elv_del_ioq_busy(q->elevator, ioq, 1);
> > +	else
> > +		elv_activate_ioq(ioq, 0);
> > +}
> > +EXPORT_SYMBOL(__elv_ioq_slice_expired);
> > +
> > +/*
> > + *  Expire the ioq.
> > + */
> > +void elv_ioq_slice_expired(struct request_queue *q)
> > +{
> > +	struct io_queue *ioq = elv_active_ioq(q->elevator);
> > +
> > +	if (ioq)
> > +		__elv_ioq_slice_expired(q, ioq);
> > +}
> > +
> > +/*
> > + * Check if new_cfqq should preempt the currently active queue. Return 0 for
> > + * no or if we aren't sure, a 1 will cause a preemption attempt.
> > + */
> > +int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
> > +			struct request *rq)
> > +{
> > +	struct io_queue *ioq;
> > +	struct elevator_queue *eq = q->elevator;
> > +	struct io_entity *entity, *new_entity;
> > +
> > +	ioq = elv_active_ioq(eq);
> > +
> > +	if (!ioq)
> > +		return 0;
> > +
> > +	entity = &ioq->entity;
> > +	new_entity = &new_ioq->entity;
> > +
> > +	/*
> > +	 * Allow an RT request to pre-empt an ongoing non-RT cfqq timeslice.
> > +	 */
> > +
> > +	if (new_entity->ioprio_class == IOPRIO_CLASS_RT
> > +	    && entity->ioprio_class != IOPRIO_CLASS_RT)
> > +		return 1;
> > +	/*
> > +	 * Allow an BE request to pre-empt an ongoing IDLE clas timeslice.
> > +	 */
> > +
> > +	if (new_entity->ioprio_class == IOPRIO_CLASS_BE
> > +	    && entity->ioprio_class == IOPRIO_CLASS_IDLE)
> > +		return 1;
> > +
> > +	/*
> > +	 * Check with io scheduler if it has additional criterion based on
> > +	 * which it wants to preempt existing queue.
> > +	 */
> > +	if (eq->ops->elevator_should_preempt_fn)
> > +		return eq->ops->elevator_should_preempt_fn(q,
> > +						ioq_sched_queue(new_ioq), rq);
> > +
> > +	return 0;
> > +}
> > +
> > +static void elv_preempt_queue(struct request_queue *q, struct io_queue *ioq)
> > +{
> > +	elv_log_ioq(&q->elevator->efqd, ioq, "preempt");
> > +	elv_ioq_slice_expired(q);
> > +
> > +	/*
> > +	 * Put the new queue at the front of the of the current list,
> > +	 * so we know that it will be selected next.
> > +	 */
> > +
> > +	elv_activate_ioq(ioq, 1);
> > +	elv_ioq_set_slice_end(ioq, 0);
> > +	elv_mark_ioq_slice_new(ioq);
> > +}
> > +
> > +void elv_ioq_request_add(struct request_queue *q, struct request *rq)
> > +{
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +	struct io_queue *ioq = rq->ioq;
> > +
> > +	if (!elv_iosched_fair_queuing_enabled(q->elevator))
> > +		return;
> > +
> > +	BUG_ON(!efqd);
> > +	BUG_ON(!ioq);
> > +	efqd->rq_queued++;
> > +	ioq->nr_queued++;
> > +
> > +	if (!elv_ioq_busy(ioq))
> > +		elv_add_ioq_busy(efqd, ioq);
> > +
> > +	elv_ioq_update_io_thinktime(ioq);
> > +	elv_ioq_update_idle_window(q->elevator, ioq, rq);
> > +
> > +	if (ioq == elv_active_ioq(q->elevator)) {
> > +		/*
> > +		 * Remember that we saw a request from this process, but
> > +		 * don't start queuing just yet. Otherwise we risk seeing lots
> > +		 * of tiny requests, because we disrupt the normal plugging
> > +		 * and merging. If the request is already larger than a single
> > +		 * page, let it rip immediately. For that case we assume that
> > +		 * merging is already done. Ditto for a busy system that
> > +		 * has other work pending, don't risk delaying until the
> > +		 * idle timer unplug to continue working.
> > +		 */
> > +		if (elv_ioq_wait_request(ioq)) {
> > +			if (blk_rq_bytes(rq) > PAGE_CACHE_SIZE ||
> > +			    efqd->busy_queues > 1) {
> > +				del_timer(&efqd->idle_slice_timer);
> > +				blk_start_queueing(q);
> > +			}
> > +			elv_mark_ioq_must_dispatch(ioq);
> > +		}
> > +	} else if (elv_should_preempt(q, ioq, rq)) {
> > +		/*
> > +		 * not the active queue - expire current slice if it is
> > +		 * idle and has expired it's mean thinktime or this new queue
> > +		 * has some old slice time left and is of higher priority or
> > +		 * this new queue is RT and the current one is BE
> > +		 */
> > +		elv_preempt_queue(q, ioq);
> > +		blk_start_queueing(q);
> > +	}
> > +}
> > +
> > +void elv_idle_slice_timer(unsigned long data)
> > +{
> > +	struct elv_fq_data *efqd = (struct elv_fq_data *)data;
> > +	struct io_queue *ioq;
> > +	unsigned long flags;
> > +	struct request_queue *q = efqd->queue;
> > +
> > +	elv_log(efqd, "idle timer fired");
> > +
> > +	spin_lock_irqsave(q->queue_lock, flags);
> > +
> > +	ioq = efqd->active_queue;
> > +
> > +	if (ioq) {
> > +
> > +		/*
> > +		 * We saw a request before the queue expired, let it through
> > +		 */
> > +		if (elv_ioq_must_dispatch(ioq))
> > +			goto out_kick;
> > +
> > +		/*
> > +		 * expired
> > +		 */
> > +		if (elv_ioq_slice_used(ioq))
> > +			goto expire;
> > +
> > +		/*
> > +		 * only expire and reinvoke request handler, if there are
> > +		 * other queues with pending requests
> > +		 */
> > +		if (!elv_nr_busy_ioq(q->elevator))
> > +			goto out_cont;
> > +
> > +		/*
> > +		 * not expired and it has a request pending, let it dispatch
> > +		 */
> > +		if (ioq->nr_queued)
> > +			goto out_kick;
> > +	}
> > +expire:
> > +	elv_ioq_slice_expired(q);
> > +out_kick:
> > +	elv_schedule_dispatch(q);
> > +out_cont:
> > +	spin_unlock_irqrestore(q->queue_lock, flags);
> > +}
> > +
> > +void elv_ioq_arm_slice_timer(struct request_queue *q)
> > +{
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +	struct io_queue *ioq = elv_active_ioq(q->elevator);
> > +	unsigned long sl;
> > +
> > +	BUG_ON(!ioq);
> > +
> > +	/*
> > +	 * SSD device without seek penalty, disable idling. But only do so
> > +	 * for devices that support queuing, otherwise we still have a problem
> > +	 * with sync vs async workloads.
> > +	 */
> > +	if (blk_queue_nonrot(q) && efqd->hw_tag)
> > +		return;
> > +
> > +	/*
> > +	 * still requests with the driver, don't idle
> > +	 */
> > +	if (efqd->rq_in_driver)
> > +		return;
> > +
> > +	/*
> > +	 * idle is disabled, either manually or by past process history
> > +	 */
> > +	if (!efqd->elv_slice_idle || !elv_ioq_idle_window(ioq))
> > +		return;
> > +
> > +	/*
> > +	 * may be iosched got its own idling logic. In that case io
> > +	 * schduler will take care of arming the timer, if need be.
> > +	 */
> > +	if (q->elevator->ops->elevator_arm_slice_timer_fn) {
> > +		q->elevator->ops->elevator_arm_slice_timer_fn(q,
> > +						ioq->sched_queue);
> > +	} else {
> > +		elv_mark_ioq_wait_request(ioq);
> > +		sl = efqd->elv_slice_idle;
> > +		mod_timer(&efqd->idle_slice_timer, jiffies + sl);
> > +		elv_log_ioq(efqd, ioq, "arm idle: %lu", sl);
> > +	}
> > +}
> > +
> > +/* Common layer function to select the next queue to dispatch from */
> > +void *elv_fq_select_ioq(struct request_queue *q, int force)
> > +{
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +	struct io_queue *new_ioq = NULL, *ioq = elv_active_ioq(q->elevator);
> > +	struct io_group *iog;
> > +
> > +	if (!elv_nr_busy_ioq(q->elevator))
> > +		return NULL;
> > +
> > +	if (ioq == NULL)
> > +		goto new_queue;
> > +
> > +	/*
> > +	 * Force dispatch. Continue to dispatch from current queue as long
> > +	 * as it has requests.
> > +	 */
> > +	if (unlikely(force)) {
> > +		if (ioq->nr_queued)
> > +			goto keep_queue;
> > +		else
> > +			goto expire;
> > +	}
> > +
> > +	/*
> > +	 * The active queue has run out of time, expire it and select new.
> > +	 */
> > +	if (elv_ioq_slice_used(ioq) && !elv_ioq_must_dispatch(ioq))
> > +		goto expire;
> > +
> > +	/*
> > +	 * If we have a RT cfqq waiting, then we pre-empt the current non-rt
> > +	 * cfqq.
> > +	 */
> > +	iog = ioq_to_io_group(ioq);
> > +
> > +	if (!elv_ioq_class_rt(ioq) && iog->busy_rt_queues) {
> > +		/*
> > +		 * We simulate this as cfqq timed out so that it gets to bank
> > +		 * the remaining of its time slice.
> > +		 */
> > +		elv_log_ioq(efqd, ioq, "preempt");
> > +		goto expire;
> > +	}
> > +
> > +	/*
> > +	 * The active queue has requests and isn't expired, allow it to
> > +	 * dispatch.
> > +	 */
> > +
> > +	if (ioq->nr_queued)
> > +		goto keep_queue;
> > +
> > +	/*
> > +	 * If another queue has a request waiting within our mean seek
> > +	 * distance, let it run.  The expire code will check for close
> > +	 * cooperators and put the close queue at the front of the service
> > +	 * tree.
> > +	 */
> > +	new_ioq = elv_close_cooperator(q, ioq, 0);
> > +	if (new_ioq)
> > +		goto expire;
> > +
> > +	/*
> > +	 * No requests pending. If the active queue still has requests in
> > +	 * flight or is idling for a new request, allow either of these
> > +	 * conditions to happen (or time out) before selecting a new queue.
> > +	 */
> > +
> > +	if (timer_pending(&efqd->idle_slice_timer) ||
> > +	    (elv_ioq_nr_dispatched(ioq) && elv_ioq_idle_window(ioq))) {
> > +		ioq = NULL;
> > +		goto keep_queue;
> > +	}
> > +
> > +expire:
> > +	elv_ioq_slice_expired(q);
> > +new_queue:
> > +	ioq = elv_set_active_ioq(q, new_ioq);
> > +keep_queue:
> > +	return ioq;
> > +}
> > +
> > +/* A request got removed from io_queue. Do the accounting */
> > +void elv_ioq_request_removed(struct elevator_queue *e, struct request *rq)
> > +{
> > +	struct io_queue *ioq;
> > +	struct elv_fq_data *efqd;
> > +
> > +	if (!elv_iosched_fair_queuing_enabled(e))
> > +		return;
> > +
> > +	ioq = rq->ioq;
> > +	BUG_ON(!ioq);
> > +	ioq->nr_queued--;
> > +
> > +	efqd = ioq->efqd;
> > +	BUG_ON(!efqd);
> > +	efqd->rq_queued--;
> > +
> > +	if (elv_ioq_busy(ioq) && (elv_active_ioq(e) != ioq) && !ioq->nr_queued)
> > +		elv_del_ioq_busy(e, ioq, 1);
> > +}
> > +
> > +/* A request got dispatched. Do the accounting. */
> > +void elv_fq_dispatched_request(struct elevator_queue *e, struct request *rq)
> > +{
> > +	struct io_queue *ioq = rq->ioq;
> > +
> > +	if (!elv_iosched_fair_queuing_enabled(e))
> > +		return;
> > +
> > +	BUG_ON(!ioq);
> > +	elv_ioq_request_dispatched(ioq);
> > +	elv_ioq_request_removed(e, rq);
> > +	elv_clear_ioq_must_dispatch(ioq);
> > +}
> > +
> > +void elv_fq_activate_rq(struct request_queue *q, struct request *rq)
> > +{
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +
> > +	if (!elv_iosched_fair_queuing_enabled(q->elevator))
> > +		return;
> > +
> > +	efqd->rq_in_driver++;
> > +	elv_log_ioq(efqd, rq_ioq(rq), "activate rq, drv=%d",
> > +						efqd->rq_in_driver);
> > +}
> > +
> > +void elv_fq_deactivate_rq(struct request_queue *q, struct request *rq)
> > +{
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +
> > +	if (!elv_iosched_fair_queuing_enabled(q->elevator))
> > +		return;
> > +
> > +	WARN_ON(!efqd->rq_in_driver);
> > +	efqd->rq_in_driver--;
> > +	elv_log_ioq(efqd, rq_ioq(rq), "deactivate rq, drv=%d",
> > +						efqd->rq_in_driver);
> > +}
> > +
> > +/*
> > + * Update hw_tag based on peak queue depth over 50 samples under
> > + * sufficient load.
> > + */
> > +static void elv_update_hw_tag(struct elv_fq_data *efqd)
> > +{
> > +	if (efqd->rq_in_driver > efqd->rq_in_driver_peak)
> > +		efqd->rq_in_driver_peak = efqd->rq_in_driver;
> > +
> > +	if (efqd->rq_queued <= ELV_HW_QUEUE_MIN &&
> > +	    efqd->rq_in_driver <= ELV_HW_QUEUE_MIN)
> > +		return;
> > +
> > +	if (efqd->hw_tag_samples++ < 50)
> > +		return;
> > +
> > +	if (efqd->rq_in_driver_peak >= ELV_HW_QUEUE_MIN)
> > +		efqd->hw_tag = 1;
> > +	else
> > +		efqd->hw_tag = 0;
> > +
> > +	efqd->hw_tag_samples = 0;
> > +	efqd->rq_in_driver_peak = 0;
> > +}
> > +
> > +/*
> > + * If ioscheduler has functionality of keeping track of close cooperator, check
> > + * with it if it has got a closely co-operating queue.
> > + */
> > +static inline struct io_queue *elv_close_cooperator(struct request_queue *q,
> > +					struct io_queue *ioq, int probe)
> > +{
> > +	struct elevator_queue *e = q->elevator;
> > +	struct io_queue *new_ioq = NULL;
> > +
> > +	/*
> > +	 * Currently this feature is supported only for flat hierarchy or
> > +	 * root group queues so that default cfq behavior is not changed.
> > +	 */
> > +	if (!is_root_group_ioq(q, ioq))
> > +		return NULL;
> > +
> > +	if (q->elevator->ops->elevator_close_cooperator_fn)
> > +		new_ioq = e->ops->elevator_close_cooperator_fn(q,
> > +						ioq->sched_queue, probe);
> > +
> > +	/* Only select co-operating queue if it belongs to root group */
> > +	if (new_ioq && !is_root_group_ioq(q, new_ioq))
> > +		return NULL;
> > +
> > +	return new_ioq;
> > +}
> > +
> > +/* A request got completed from io_queue. Do the accounting. */
> > +void elv_ioq_completed_request(struct request_queue *q, struct request *rq)
> > +{
> > +	const int sync = rq_is_sync(rq);
> > +	struct io_queue *ioq;
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +
> > +	if (!elv_iosched_fair_queuing_enabled(q->elevator))
> > +		return;
> > +
> > +	ioq = rq->ioq;
> > +
> > +	elv_log_ioq(efqd, ioq, "complete");
> > +
> > +	elv_update_hw_tag(efqd);
> > +
> > +	WARN_ON(!efqd->rq_in_driver);
> > +	WARN_ON(!ioq->dispatched);
> > +	efqd->rq_in_driver--;
> > +	ioq->dispatched--;
> > +
> > +	if (sync)
> > +		ioq->last_end_request = jiffies;
> > +
> > +	/*
> > +	 * If this is the active queue, check if it needs to be expired,
> > +	 * or if we want to idle in case it has no pending requests.
> > +	 */
> > +
> > +	if (elv_active_ioq(q->elevator) == ioq) {
> > +		if (elv_ioq_slice_new(ioq)) {
> > +			elv_ioq_set_prio_slice(q, ioq);
> > +			elv_clear_ioq_slice_new(ioq);
> > +		}
> > +		/*
> > +		 * If there are no requests waiting in this queue, and
> > +		 * there are other queues ready to issue requests, AND
> > +		 * those other queues are issuing requests within our
> > +		 * mean seek distance, give them a chance to run instead
> > +		 * of idling.
> > +		 */
> > +		if (elv_ioq_slice_used(ioq) || elv_ioq_class_idle(ioq))
> > +			elv_ioq_slice_expired(q);
> > +		else if (!ioq->nr_queued && !elv_close_cooperator(q, ioq, 1)
> > +			 && sync && !rq_noidle(rq))
> > +			elv_ioq_arm_slice_timer(q);
> > +	}
> > +
> > +	if (!efqd->rq_in_driver)
> > +		elv_schedule_dispatch(q);
> > +}
> > +
> > +struct io_group *io_lookup_io_group_current(struct request_queue *q)
> > +{
> > +	struct elv_fq_data *efqd = &q->elevator->efqd;
> > +
> > +	return efqd->root_group;
> > +}
> > +EXPORT_SYMBOL(io_lookup_io_group_current);
> > +
> > +void *io_group_async_queue_prio(struct io_group *iog, int ioprio_class,
> > +					int ioprio)
> > +{
> > +	struct io_queue *ioq = NULL;
> > +
> > +	switch (ioprio_class) {
> > +	case IOPRIO_CLASS_RT:
> > +		ioq = iog->async_queue[0][ioprio];
> > +		break;
> > +	case IOPRIO_CLASS_BE:
> > +		ioq = iog->async_queue[1][ioprio];
> > +		break;
> > +	case IOPRIO_CLASS_IDLE:
> > +		ioq = iog->async_idle_queue;
> > +		break;
> > +	default:
> > +		BUG();
> > +	}
> > +
> > +	if (ioq)
> > +		return ioq->sched_queue;
> > +	return NULL;
> > +}
> > +EXPORT_SYMBOL(io_group_async_queue_prio);
> > +
> > +void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
> > +					int ioprio, struct io_queue *ioq)
> > +{
> > +	switch (ioprio_class) {
> > +	case IOPRIO_CLASS_RT:
> > +		iog->async_queue[0][ioprio] = ioq;
> > +		break;
> > +	case IOPRIO_CLASS_BE:
> > +		iog->async_queue[1][ioprio] = ioq;
> > +		break;
> > +	case IOPRIO_CLASS_IDLE:
> > +		iog->async_idle_queue = ioq;
> > +		break;
> > +	default:
> > +		BUG();
> > +	}
> > +
> > +	/*
> > +	 * Take the group reference and pin the queue. Group exit will
> > +	 * clean it up
> > +	 */
> > +	elv_get_ioq(ioq);
> > +}
> > +EXPORT_SYMBOL(io_group_set_async_queue);
> > +
> > +/*
> > + * Release all the io group references to its async queues.
> > + */
> > +void io_put_io_group_queues(struct elevator_queue *e, struct io_group *iog)
> > +{
> > +	int i, j;
> > +
> > +	for (i = 0; i < 2; i++)
> > +		for (j = 0; j < IOPRIO_BE_NR; j++)
> > +			elv_release_ioq(e, &iog->async_queue[i][j]);
> > +
> > +	/* Free up async idle queue */
> > +	elv_release_ioq(e, &iog->async_idle_queue);
> > +}
> > +
> > +struct io_group *io_alloc_root_group(struct request_queue *q,
> > +					struct elevator_queue *e, void *key)
> > +{
> > +	struct io_group *iog;
> > +	int i;
> > +
> > +	iog = kmalloc_node(sizeof(*iog), GFP_KERNEL | __GFP_ZERO, q->node);
> > +	if (iog == NULL)
> > +		return NULL;
> > +
> > +	for (i = 0; i < IO_IOPRIO_CLASSES; i++)
> > +		iog->sched_data.service_tree[i] = IO_SERVICE_TREE_INIT;
> > +
> > +	return iog;
> > +}
> > +
> > +void io_free_root_group(struct elevator_queue *e)
> > +{
> > +	struct io_group *iog = e->efqd.root_group;
> > +	struct io_service_tree *st;
> > +	int i;
> > +
> > +	for (i = 0; i < IO_IOPRIO_CLASSES; i++) {
> > +		st = iog->sched_data.service_tree + i;
> > +		io_flush_idle_tree(st);
> > +	}
> > +
> > +	io_put_io_group_queues(e, iog);
> > +	kfree(iog);
> > +}
> > +
> > +static void elv_slab_kill(void)
> > +{
> > +	/*
> > +	 * Caller already ensured that pending RCU callbacks are completed,
> > +	 * so we should have no busy allocations at this point.
> > +	 */
> > +	if (elv_ioq_pool)
> > +		kmem_cache_destroy(elv_ioq_pool);
> > +}
> > +
> > +static int __init elv_slab_setup(void)
> > +{
> > +	elv_ioq_pool = KMEM_CACHE(io_queue, 0);
> > +	if (!elv_ioq_pool)
> > +		goto fail;
> > +
> > +	return 0;
> > +fail:
> > +	elv_slab_kill();
> > +	return -ENOMEM;
> > +}
> > +
> > +/* Initialize fair queueing data associated with elevator */
> > +int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
> > +{
> > +	struct io_group *iog;
> > +	struct elv_fq_data *efqd = &e->efqd;
> > +
> > +	if (!elv_iosched_fair_queuing_enabled(e))
> > +		return 0;
> > +
> > +	iog = io_alloc_root_group(q, e, efqd);
> > +	if (iog == NULL)
> > +		return 1;
> > +
> > +	efqd->root_group = iog;
> > +	efqd->queue = q;
> > +
> > +	init_timer(&efqd->idle_slice_timer);
> > +	efqd->idle_slice_timer.function = elv_idle_slice_timer;
> > +	efqd->idle_slice_timer.data = (unsigned long) efqd;
> > +
> > +	INIT_WORK(&efqd->unplug_work, elv_kick_queue);
> > +
> > +	efqd->elv_slice[0] = elv_slice_async;
> > +	efqd->elv_slice[1] = elv_slice_sync;
> > +	efqd->elv_slice_idle = elv_slice_idle;
> > +	efqd->hw_tag = 1;
> > +
> > +	return 0;
> > +}
> > +
> > +/*
> > + * elv_exit_fq_data is called before we call elevator_exit_fn. Before
> > + * we ask elevator to cleanup its queues, we do the cleanup here so
> > + * that all the group and idle tree references to ioq are dropped. Later
> > + * during elevator cleanup, ioc reference will be dropped which will lead
> > + * to removal of ioscheduler queue as well as associated ioq object.
> > + */
> > +void elv_exit_fq_data(struct elevator_queue *e)
> > +{
> > +	struct elv_fq_data *efqd = &e->efqd;
> > +
> > +	if (!elv_iosched_fair_queuing_enabled(e))
> > +		return;
> > +
> > +	elv_shutdown_timer_wq(e);
> > +
> > +	BUG_ON(timer_pending(&efqd->idle_slice_timer));
> > +	io_free_root_group(e);
> > +}
> > +
> > +/*
> > + * This is called after the io scheduler has cleaned up its data structres.
> > + * I don't think that this function is required. Right now just keeping it
> > + * because cfq cleans up timer and work queue again after freeing up
> > + * io contexts. To me io scheduler has already been drained out, and all
> > + * the active queue have already been expired so time and work queue should
> > + * not been activated during cleanup process.
> > + *
> > + * Keeping it here for the time being. Will get rid of it later.
> > + */
> > +void elv_exit_fq_data_post(struct elevator_queue *e)
> > +{
> > +	struct elv_fq_data *efqd = &e->efqd;
> > +
> > +	if (!elv_iosched_fair_queuing_enabled(e))
> > +		return;
> > +
> > +	elv_shutdown_timer_wq(e);
> > +	BUG_ON(timer_pending(&efqd->idle_slice_timer));
> > +}
> > +
> > +
> > +static int __init elv_fq_init(void)
> > +{
> > +	if (elv_slab_setup())
> > +		return -ENOMEM;
> > +
> > +	/* could be 0 on HZ < 1000 setups */
> > +
> > +	if (!elv_slice_async)
> > +		elv_slice_async = 1;
> > +
> > +	if (!elv_slice_idle)
> > +		elv_slice_idle = 1;
> > +
> > +	return 0;
> > +}
> > +
> > +module_init(elv_fq_init);
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
> 

I have no strong opinions on that, during debugging it helped a lot
to identify the role of variables in the code, but common practice in
the kernel is avoiding typedefs, so they can go now.


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
> 
> > + * @active_entity: entity under service.
> > + * @next_active: head-of-the-line entity in the scheduler.
> > + * @service_tree: array of service trees, one per ioprio_class.
> > + *
> > + * bfq_sched_data is the basic scheduler queue.  It supports three
> > + * ioprio_classes, and can be used either as a toplevel queue or as
> > + * an intermediate queue on a hierarchical setup.
> > + * @next_active points to the active entity of the sched_data service
> > + * trees that will be scheduled next.
> > + *
> > + * The supported ioprio_classes are the same as in CFQ, in descending
> > + * priority order, IOPRIO_CLASS_RT, IOPRIO_CLASS_BE, IOPRIO_CLASS_IDLE.
> > + * Requests from higher priority queues are served before all the
> > + * requests from lower priority queues; among requests of the same
> > + * queue requests are served according to B-WF2Q+.
> > + * All the fields are protected by the queue lock of the containing bfqd.
> > + */
> > +struct io_sched_data {
> > +	struct io_entity *active_entity;
> > +	struct io_service_tree service_tree[IO_IOPRIO_CLASSES];
> > +};
> > +
> > +/**
> > + * struct bfq_entity - schedulable entity.
> > + * @rb_node: service_tree member.
> > + * @on_st: flag, true if the entity is on a tree (either the active or
> > + *         the idle one of its service_tree).
> > + * @finish: B-WF2Q+ finish timestamp (aka F_i).
> > + * @start: B-WF2Q+ start timestamp (aka S_i).
> 
> Could you mention what key is used in the rb_tree? start, finish
> sounds like a range, so my suspicion is that start is used.
> 

finish is used as the key, and min_start keeps the minimum ->start for
the subtree rooted at the given entity (as said in the comment below).


> > + * @tree: tree the entity is enqueued into; %NULL if not on a tree.
> > + * @min_start: minimum start time of the (active) subtree rooted at
> > + *             this entity; used for O(log N) lookups into active trees.
> 
> Used for O(log N) makes no sense to me, RBTree has a worst case
> lookup time of O(log N), but what is the comment saying?
> 

it's badly written (my fault), but it intended to say that this field is
used to allow the lookups to be done in O(log N).  without augmenting
the RB tree with min_start, lookups could not be done in O(log N),
because we want a constrained minimum search.


> > + * @service: service received during the last round of service.
> > + * @budget: budget used to calculate F_i; F_i = S_i + @budget / @weight.
> > + * @weight: weight of the queue, calculated as IOPRIO_BE_NR - @ioprio.
> > + * @parent: parent entity, for hierarchical scheduling.
> > + * @my_sched_data: for non-leaf nodes in the cgroup hierarchy, the
> > + *                 associated scheduler queue, %NULL on leaf nodes.
> > + * @sched_data: the scheduler queue this entity belongs to.
> > + * @ioprio: the ioprio in use.
> > + * @new_ioprio: when an ioprio change is requested, the new ioprio value
> > + * @ioprio_class: the ioprio_class in use.
> > + * @new_ioprio_class: when an ioprio_class change is requested, the new
> > + *                    ioprio_class value.
> > + * @ioprio_changed: flag, true when the user requested an ioprio or
> > + *                  ioprio_class change.
> > + *
> > + * A bfq_entity is used to represent either a bfq_queue (leaf node in the
> > + * cgroup hierarchy) or a bfq_group into the upper level scheduler.  Each
> > + * entity belongs to the sched_data of the parent group in the cgroup
> > + * hierarchy.  Non-leaf entities have also their own sched_data, stored
> > + * in @my_sched_data.
> > + *
> > + * Each entity stores independently its priority values; this would allow
> > + * different weights on different devices, but this functionality is not
> > + * exported to userspace by now.  Priorities are updated lazily, first
> > + * storing the new values into the new_* fields, then setting the
> > + * @ioprio_changed flag.  As soon as there is a transition in the entity
> > + * state that allows the priority update to take place the effective and
> > + * the requested priority values are synchronized.
> > + *
> > + * The weight value is calculated from the ioprio to export the same
> > + * interface as CFQ.  When dealing with ``well-behaved'' queues (i.e.,
> > + * queues that do not spend too much time to consume their budget and
> > + * have true sequential behavior, and when there are no external factors
> > + * breaking anticipation) the relative weights at each level of the
> > + * cgroups hierarchy should be guaranteed.
> > + * All the fields are protected by the queue lock of the containing bfqd.
> > + */
> > +struct io_entity {
> > +	struct rb_node rb_node;
> > +
> > +	int on_st;
> > +
> > +	bfq_timestamp_t finish;
> > +	bfq_timestamp_t start;
> > +
> > +	struct rb_root *tree;
> > +
> > +	bfq_timestamp_t min_start;
> > +
> > +	bfq_service_t service, budget;
> > +	bfq_weight_t weight;
> > +
> > +	struct io_entity *parent;
> > +
> > +	struct io_sched_data *my_sched_data;
> > +	struct io_sched_data *sched_data;
> > +
> > +	unsigned short ioprio, new_ioprio;
> > +	unsigned short ioprio_class, new_ioprio_class;
> > +
> > +	int ioprio_changed;
> > +};
> > +
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

yes


> > +	atomic_t ref;
> > +	unsigned int flags;
> > +
> > +	/* Pointer to generic elevator data structure */
> > +	struct elv_fq_data *efqd;
> > +	pid_t pid;
> 
> Why do we store the pid?
> 

originally it was for logging purposes


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
> 
> > +};
> > +
> > +extern int elv_slice_idle;
> > +extern int elv_slice_async;
> > +
> > +/* Logging facilities. */
> > +#define elv_log_ioq(efqd, ioq, fmt, args...) \
> > +	blk_add_trace_msg((efqd)->queue, "elv%d%c " fmt, (ioq)->pid,	\
> > +				elv_ioq_sync(ioq) ? 'S' : 'A', ##args)
> > +
> > +#define elv_log(efqd, fmt, args...) \
> > +	blk_add_trace_msg((efqd)->queue, "elv " fmt, ##args)
> > +
> > +#define ioq_sample_valid(samples)   ((samples) > 80)
> > +
> > +/* Some shared queue flag manipulation functions among elevators */
> > +
> > +enum elv_queue_state_flags {
> > +	ELV_QUEUE_FLAG_busy = 0,          /* has requests or is under service */
> > +	ELV_QUEUE_FLAG_sync,              /* synchronous queue */
> > +	ELV_QUEUE_FLAG_idle_window,	  /* elevator slice idling enabled */
> > +	ELV_QUEUE_FLAG_wait_request,	  /* waiting for a request */
> > +	ELV_QUEUE_FLAG_must_dispatch,	  /* must be allowed a dispatch */
> > +	ELV_QUEUE_FLAG_slice_new,	  /* no requests dispatched in slice */
> > +	ELV_QUEUE_FLAG_NR,
> > +};
> > +
> > +#define ELV_IO_QUEUE_FLAG_FNS(name)					\
> > +static inline void elv_mark_ioq_##name(struct io_queue *ioq)		\
> > +{                                                                       \
> > +	(ioq)->flags |= (1 << ELV_QUEUE_FLAG_##name);			\
> > +}                                                                       \
> > +static inline void elv_clear_ioq_##name(struct io_queue *ioq)		\
> > +{                                                                       \
> > +	(ioq)->flags &= ~(1 << ELV_QUEUE_FLAG_##name);			\
> > +}                                                                       \
> > +static inline int elv_ioq_##name(struct io_queue *ioq)         		\
> > +{                                                                       \
> > +	return ((ioq)->flags & (1 << ELV_QUEUE_FLAG_##name)) != 0;	\
> > +}
> > +
> > +ELV_IO_QUEUE_FLAG_FNS(busy)
> > +ELV_IO_QUEUE_FLAG_FNS(sync)
> > +ELV_IO_QUEUE_FLAG_FNS(wait_request)
> > +ELV_IO_QUEUE_FLAG_FNS(must_dispatch)
> > +ELV_IO_QUEUE_FLAG_FNS(idle_window)
> > +ELV_IO_QUEUE_FLAG_FNS(slice_new)
> > +
> > +static inline struct io_service_tree *
> > +io_entity_service_tree(struct io_entity *entity)
> > +{
> > +	struct io_sched_data *sched_data = entity->sched_data;
> > +	unsigned int idx = entity->ioprio_class - 1;
> > +
> > +	BUG_ON(idx >= IO_IOPRIO_CLASSES);
> > +	BUG_ON(sched_data == NULL);
> > +
> > +	return sched_data->service_tree + idx;
> > +}
> > +
> > +/* A request got dispatched from the io_queue. Do the accounting. */
> > +static inline void elv_ioq_request_dispatched(struct io_queue *ioq)
> > +{
> > +	ioq->dispatched++;
> > +}
> > +
> > +static inline int elv_ioq_slice_used(struct io_queue *ioq)
> > +{
> > +	if (elv_ioq_slice_new(ioq))
> > +		return 0;
> > +	if (time_before(jiffies, ioq->slice_end))
> > +		return 0;
> > +
> > +	return 1;
> > +}
> > +
> > +/* How many request are currently dispatched from the queue */
> > +static inline int elv_ioq_nr_dispatched(struct io_queue *ioq)
> > +{
> > +	return ioq->dispatched;
> > +}
> > +
> > +/* How many request are currently queued in the queue */
> > +static inline int elv_ioq_nr_queued(struct io_queue *ioq)
> > +{
> > +	return ioq->nr_queued;
> > +}
> > +
> > +static inline void elv_get_ioq(struct io_queue *ioq)
> > +{
> > +	atomic_inc(&ioq->ref);
> > +}
> > +
> > +static inline void elv_ioq_set_slice_end(struct io_queue *ioq,
> > +						unsigned long slice_end)
> > +{
> > +	ioq->slice_end = slice_end;
> > +}
> > +
> > +static inline int elv_ioq_class_idle(struct io_queue *ioq)
> > +{
> > +	return ioq->entity.ioprio_class == IOPRIO_CLASS_IDLE;
> > +}
> > +
> > +static inline int elv_ioq_class_rt(struct io_queue *ioq)
> > +{
> > +	return ioq->entity.ioprio_class == IOPRIO_CLASS_RT;
> > +}
> > +
> > +static inline int elv_ioq_ioprio_class(struct io_queue *ioq)
> > +{
> > +	return ioq->entity.new_ioprio_class;
> > +}
> > +
> > +static inline int elv_ioq_ioprio(struct io_queue *ioq)
> > +{
> > +	return ioq->entity.new_ioprio;
> > +}
> > +
> > +static inline void elv_ioq_set_ioprio_class(struct io_queue *ioq,
> > +						int ioprio_class)
> > +{
> > +	ioq->entity.new_ioprio_class = ioprio_class;
> > +	ioq->entity.ioprio_changed = 1;
> > +}
> > +
> > +static inline void elv_ioq_set_ioprio(struct io_queue *ioq, int ioprio)
> > +{
> > +	ioq->entity.new_ioprio = ioprio;
> > +	ioq->entity.ioprio_changed = 1;
> > +}
> > +
> > +static inline void *ioq_sched_queue(struct io_queue *ioq)
> > +{
> > +	if (ioq)
> > +		return ioq->sched_queue;
> > +	return NULL;
> > +}
> > +
> > +static inline struct io_group *ioq_to_io_group(struct io_queue *ioq)
> > +{
> > +	return container_of(ioq->entity.sched_data, struct io_group,
> > +						sched_data);
> > +}
> > +
> > +extern ssize_t elv_slice_idle_show(struct elevator_queue *q, char *name);
> > +extern ssize_t elv_slice_idle_store(struct elevator_queue *q, const char *name,
> > +						size_t count);
> > +extern ssize_t elv_slice_sync_show(struct elevator_queue *q, char *name);
> > +extern ssize_t elv_slice_sync_store(struct elevator_queue *q, const char *name,
> > +						size_t count);
> > +extern ssize_t elv_slice_async_show(struct elevator_queue *q, char *name);
> > +extern ssize_t elv_slice_async_store(struct elevator_queue *q, const char *name,
> > +						size_t count);
> > +
> > +/* Functions used by elevator.c */
> > +extern int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e);
> > +extern void elv_exit_fq_data(struct elevator_queue *e);
> > +extern void elv_exit_fq_data_post(struct elevator_queue *e);
> > +
> > +extern void elv_ioq_request_add(struct request_queue *q, struct request *rq);
> > +extern void elv_ioq_request_removed(struct elevator_queue *e,
> > +					struct request *rq);
> > +extern void elv_fq_dispatched_request(struct elevator_queue *e,
> > +					struct request *rq);
> > +
> > +extern void elv_fq_activate_rq(struct request_queue *q, struct request *rq);
> > +extern void elv_fq_deactivate_rq(struct request_queue *q, struct request *rq);
> > +
> > +extern void elv_ioq_completed_request(struct request_queue *q,
> > +				struct request *rq);
> > +
> > +extern void *elv_fq_select_ioq(struct request_queue *q, int force);
> > +extern struct io_queue *rq_ioq(struct request *rq);
> > +
> > +/* Functions used by io schedulers */
> > +extern void elv_put_ioq(struct io_queue *ioq);
> > +extern void __elv_ioq_slice_expired(struct request_queue *q,
> > +					struct io_queue *ioq);
> > +extern int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
> > +		void *sched_queue, int ioprio_class, int ioprio, int is_sync);
> > +extern void elv_schedule_dispatch(struct request_queue *q);
> > +extern int elv_hw_tag(struct elevator_queue *e);
> > +extern void *elv_active_sched_queue(struct elevator_queue *e);
> > +extern int elv_mod_idle_slice_timer(struct elevator_queue *eq,
> > +					unsigned long expires);
> > +extern int elv_del_idle_slice_timer(struct elevator_queue *eq);
> > +extern unsigned int elv_get_slice_idle(struct elevator_queue *eq);
> > +extern void *io_group_async_queue_prio(struct io_group *iog, int ioprio_class,
> > +					int ioprio);
> > +extern void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
> > +					int ioprio, struct io_queue *ioq);
> > +extern struct io_group *io_lookup_io_group_current(struct request_queue *q);
> > +extern int elv_nr_busy_ioq(struct elevator_queue *e);
> > +extern struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask);
> > +extern void elv_free_ioq(struct io_queue *ioq);
> > +
> > +#else /* CONFIG_ELV_FAIR_QUEUING */
> > +
> > +static inline int elv_init_fq_data(struct request_queue *q,
> > +					struct elevator_queue *e)
> > +{
> > +	return 0;
> > +}
> > +
> > +static inline void elv_exit_fq_data(struct elevator_queue *e) {}
> > +static inline void elv_exit_fq_data_post(struct elevator_queue *e) {}
> > +
> > +static inline void elv_fq_activate_rq(struct request_queue *q,
> > +					struct request *rq)
> > +{
> > +}
> > +
> > +static inline void elv_fq_deactivate_rq(struct request_queue *q,
> > +					struct request *rq)
> > +{
> > +}
> > +
> > +static inline void elv_fq_dispatched_request(struct elevator_queue *e,
> > +						struct request *rq)
> > +{
> > +}
> > +
> > +static inline void elv_ioq_request_removed(struct elevator_queue *e,
> > +						struct request *rq)
> > +{
> > +}
> > +
> > +static inline void elv_ioq_request_add(struct request_queue *q,
> > +					struct request *rq)
> > +{
> > +}
> > +
> > +static inline void elv_ioq_completed_request(struct request_queue *q,
> > +						struct request *rq)
> > +{
> > +}
> > +
> > +static inline void *ioq_sched_queue(struct io_queue *ioq) { return NULL; }
> > +static inline struct io_queue *rq_ioq(struct request *rq) { return NULL; }
> > +static inline void *elv_fq_select_ioq(struct request_queue *q, int force)
> > +{
> > +	return NULL;
> > +}
> > +#endif /* CONFIG_ELV_FAIR_QUEUING */
> > +#endif /* _BFQ_SCHED_H */
> > diff --git a/block/elevator.c b/block/elevator.c
> > index 7073a90..c2f07f5 100644
> > --- a/block/elevator.c
> > +++ b/block/elevator.c
> > @@ -231,6 +231,9 @@ static struct elevator_queue *elevator_alloc(struct request_queue *q,
> >  	for (i = 0; i < ELV_HASH_ENTRIES; i++)
> >  		INIT_HLIST_HEAD(&eq->hash[i]);
> > 
> > +	if (elv_init_fq_data(q, eq))
> > +		goto err;
> > +
> >  	return eq;
> >  err:
> >  	kfree(eq);
> > @@ -301,9 +304,11 @@ EXPORT_SYMBOL(elevator_init);
> >  void elevator_exit(struct elevator_queue *e)
> >  {
> >  	mutex_lock(&e->sysfs_lock);
> > +	elv_exit_fq_data(e);
> >  	if (e->ops->elevator_exit_fn)
> >  		e->ops->elevator_exit_fn(e);
> >  	e->ops = NULL;
> > +	elv_exit_fq_data_post(e);
> >  	mutex_unlock(&e->sysfs_lock);
> > 
> >  	kobject_put(&e->kobj);
> > @@ -314,6 +319,8 @@ static void elv_activate_rq(struct request_queue *q, struct request *rq)
> >  {
> >  	struct elevator_queue *e = q->elevator;
> > 
> > +	elv_fq_activate_rq(q, rq);
> > +
> >  	if (e->ops->elevator_activate_req_fn)
> >  		e->ops->elevator_activate_req_fn(q, rq);
> >  }
> > @@ -322,6 +329,8 @@ static void elv_deactivate_rq(struct request_queue *q, struct request *rq)
> >  {
> >  	struct elevator_queue *e = q->elevator;
> > 
> > +	elv_fq_deactivate_rq(q, rq);
> > +
> >  	if (e->ops->elevator_deactivate_req_fn)
> >  		e->ops->elevator_deactivate_req_fn(q, rq);
> >  }
> > @@ -446,6 +455,7 @@ void elv_dispatch_sort(struct request_queue *q, struct request *rq)
> >  	elv_rqhash_del(q, rq);
> > 
> >  	q->nr_sorted--;
> > +	elv_fq_dispatched_request(q->elevator, rq);
> > 
> >  	boundary = q->end_sector;
> >  	stop_flags = REQ_SOFTBARRIER | REQ_HARDBARRIER | REQ_STARTED;
> > @@ -486,6 +496,7 @@ void elv_dispatch_add_tail(struct request_queue *q, struct request *rq)
> >  	elv_rqhash_del(q, rq);
> > 
> >  	q->nr_sorted--;
> > +	elv_fq_dispatched_request(q->elevator, rq);
> > 
> >  	q->end_sector = rq_end_sector(rq);
> >  	q->boundary_rq = rq;
> > @@ -553,6 +564,7 @@ void elv_merge_requests(struct request_queue *q, struct request *rq,
> >  	elv_rqhash_del(q, next);
> > 
> >  	q->nr_sorted--;
> > +	elv_ioq_request_removed(e, next);
> >  	q->last_merge = rq;
> >  }
> > 
> > @@ -657,12 +669,8 @@ void elv_insert(struct request_queue *q, struct request *rq, int where)
> >  				q->last_merge = rq;
> >  		}
> > 
> > -		/*
> > -		 * Some ioscheds (cfq) run q->request_fn directly, so
> > -		 * rq cannot be accessed after calling
> > -		 * elevator_add_req_fn.
> > -		 */
> >  		q->elevator->ops->elevator_add_req_fn(q, rq);
> > +		elv_ioq_request_add(q, rq);
> >  		break;
> > 
> >  	case ELEVATOR_INSERT_REQUEUE:
> > @@ -872,13 +880,12 @@ void elv_dequeue_request(struct request_queue *q, struct request *rq)
> > 
> >  int elv_queue_empty(struct request_queue *q)
> >  {
> > -	struct elevator_queue *e = q->elevator;
> > -
> >  	if (!list_empty(&q->queue_head))
> >  		return 0;
> > 
> > -	if (e->ops->elevator_queue_empty_fn)
> > -		return e->ops->elevator_queue_empty_fn(q);
> > +	/* Hopefully nr_sorted works and no need to call queue_empty_fn */
> > +	if (q->nr_sorted)
> > +		return 0;
> > 
> >  	return 1;
> >  }
> > @@ -953,8 +960,11 @@ void elv_completed_request(struct request_queue *q, struct request *rq)
> >  	 */
> >  	if (blk_account_rq(rq)) {
> >  		q->in_flight--;
> > -		if (blk_sorted_rq(rq) && e->ops->elevator_completed_req_fn)
> > -			e->ops->elevator_completed_req_fn(q, rq);
> > +		if (blk_sorted_rq(rq)) {
> > +			if (e->ops->elevator_completed_req_fn)
> > +				e->ops->elevator_completed_req_fn(q, rq);
> > +			elv_ioq_completed_request(q, rq);
> > +		}
> >  	}
> > 
> >  	/*
> > @@ -1242,3 +1252,17 @@ struct request *elv_rb_latter_request(struct request_queue *q,
> >  	return NULL;
> >  }
> >  EXPORT_SYMBOL(elv_rb_latter_request);
> > +
> > +/* Get the io scheduler queue pointer. For cfq, it is stored in rq->ioq*/
> > +void *elv_get_sched_queue(struct request_queue *q, struct request *rq)
> > +{
> > +	return ioq_sched_queue(rq_ioq(rq));
> > +}
> > +EXPORT_SYMBOL(elv_get_sched_queue);
> > +
> > +/* Select an ioscheduler queue to dispatch request from. */
> > +void *elv_select_sched_queue(struct request_queue *q, int force)
> > +{
> > +	return ioq_sched_queue(elv_fq_select_ioq(q, force));
> > +}
> > +EXPORT_SYMBOL(elv_select_sched_queue);
> > diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
> > index b4f71f1..96a94c9 100644
> > --- a/include/linux/blkdev.h
> > +++ b/include/linux/blkdev.h
> > @@ -245,6 +245,11 @@ struct request {
> > 
> >  	/* for bidi */
> >  	struct request *next_rq;
> > +
> > +#ifdef CONFIG_ELV_FAIR_QUEUING
> > +	/* io queue request belongs to */
> > +	struct io_queue *ioq;
> > +#endif
> >  };
> > 
> >  static inline unsigned short req_get_ioprio(struct request *req)
> > diff --git a/include/linux/elevator.h b/include/linux/elevator.h
> > index c59b769..679c149 100644
> > --- a/include/linux/elevator.h
> > +++ b/include/linux/elevator.h
> > @@ -2,6 +2,7 @@
> >  #define _LINUX_ELEVATOR_H
> > 
> >  #include <linux/percpu.h>
> > +#include "../../block/elevator-fq.h"
> > 
> >  #ifdef CONFIG_BLOCK
> > 
> > @@ -29,6 +30,18 @@ typedef void (elevator_deactivate_req_fn) (struct request_queue *, struct reques
> > 
> >  typedef void *(elevator_init_fn) (struct request_queue *);
> >  typedef void (elevator_exit_fn) (struct elevator_queue *);
> > +#ifdef CONFIG_ELV_FAIR_QUEUING
> > +typedef void (elevator_free_sched_queue_fn) (struct elevator_queue*, void *);
> > +typedef void (elevator_active_ioq_set_fn) (struct request_queue*, void *, int);
> > +typedef void (elevator_active_ioq_reset_fn) (struct request_queue *, void*);
> > +typedef void (elevator_arm_slice_timer_fn) (struct request_queue*, void*);
> > +typedef int (elevator_should_preempt_fn) (struct request_queue*, void*,
> > +						struct request*);
> > +typedef int (elevator_update_idle_window_fn) (struct elevator_queue*, void*,
> > +						struct request*);
> > +typedef struct io_queue* (elevator_close_cooperator_fn) (struct request_queue*,
> > +						void*, int probe);
> > +#endif
> > 
> >  struct elevator_ops
> >  {
> > @@ -56,6 +69,17 @@ struct elevator_ops
> >  	elevator_init_fn *elevator_init_fn;
> >  	elevator_exit_fn *elevator_exit_fn;
> >  	void (*trim)(struct io_context *);
> > +
> > +#ifdef CONFIG_ELV_FAIR_QUEUING
> > +	elevator_free_sched_queue_fn *elevator_free_sched_queue_fn;
> > +	elevator_active_ioq_set_fn *elevator_active_ioq_set_fn;
> > +	elevator_active_ioq_reset_fn *elevator_active_ioq_reset_fn;
> > +
> > +	elevator_arm_slice_timer_fn *elevator_arm_slice_timer_fn;
> > +	elevator_should_preempt_fn *elevator_should_preempt_fn;
> > +	elevator_update_idle_window_fn *elevator_update_idle_window_fn;
> > +	elevator_close_cooperator_fn *elevator_close_cooperator_fn;
> > +#endif
> >  };
> > 
> >  #define ELV_NAME_MAX	(16)
> > @@ -76,6 +100,9 @@ struct elevator_type
> >  	struct elv_fs_entry *elevator_attrs;
> >  	char elevator_name[ELV_NAME_MAX];
> >  	struct module *elevator_owner;
> > +#ifdef CONFIG_ELV_FAIR_QUEUING
> > +	int elevator_features;
> > +#endif
> >  };
> > 
> >  /*
> > @@ -89,6 +116,10 @@ struct elevator_queue
> >  	struct elevator_type *elevator_type;
> >  	struct mutex sysfs_lock;
> >  	struct hlist_head *hash;
> > +#ifdef CONFIG_ELV_FAIR_QUEUING
> > +	/* fair queuing data */
> > +	struct elv_fq_data efqd;
> > +#endif
> >  };
> > 
> >  /*
> > @@ -209,5 +240,25 @@ enum {
> >  	__val;							\
> >  })
> > 
> > +/* iosched can let elevator know their feature set/capability */
> > +#ifdef CONFIG_ELV_FAIR_QUEUING
> > +
> > +/* iosched wants to use fq logic of elevator layer */
> > +#define	ELV_IOSCHED_NEED_FQ	1
> > +
> > +static inline int elv_iosched_fair_queuing_enabled(struct elevator_queue *e)
> > +{
> > +	return (e->elevator_type->elevator_features) & ELV_IOSCHED_NEED_FQ;
> > +}
> > +
> > +#else /* ELV_IOSCHED_FAIR_QUEUING */
> > +
> > +static inline int elv_iosched_fair_queuing_enabled(struct elevator_queue *e)
> > +{
> > +	return 0;
> > +}
> > +#endif /* ELV_IOSCHED_FAIR_QUEUING */
> > +extern void *elv_get_sched_queue(struct request_queue *q, struct request *rq);
> > +extern void *elv_select_sched_queue(struct request_queue *q, int force);
> >  #endif /* CONFIG_BLOCK */
> >  #endif
> > -- 
> > 1.6.0.6
> > 
> 
> -- 
> 	Balbir
