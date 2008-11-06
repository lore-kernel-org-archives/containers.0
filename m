From: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Subject: [patch 3/4] io controller: Core IO controller implementation logic
Date: Thu, 06 Nov 2008 10:30:25 -0500
Message-ID: <20081106153135.869625751__38582.9474464574$1225986664$gmane$org@redhat.com>
References: <20081106153022.215696930@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=bio-group-core-implementation.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Hirokazu Takahashi <taka-jCdQPDEk3ieIwRZHo2/mJg@public.gmane.org>
Cc: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Jeff Moyer <jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org


o Core IO controller implementation

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Index: linux2/mm/biocontrol.c
===================================================================
--- linux2.orig/mm/biocontrol.c	2008-11-06 05:27:36.000000000 -0500
+++ linux2/mm/biocontrol.c	2008-11-06 05:33:27.000000000 -0500
@@ -33,6 +33,7 @@
 #include <linux/err.h>
 #include <linux/biocontrol.h>
 
+void bio_group_inactive_timeout(unsigned long data);
 
 /* return corresponding bio_cgroup object of a cgroup */
 static inline struct bio_cgroup *cgroup_bio(struct cgroup *cgrp)
@@ -407,3 +408,706 @@ struct cgroup_subsys bio_cgroup_subsys =
 	.attach		= bio_cgroup_move_task,
 	.early_init	= 0,
 };
+
+struct bio_group* create_bio_group(struct bio_cgroup *biocg,
+						struct request_queue *q)
+{
+	unsigned long flags;
+	struct bio_group *biog = NULL;
+
+	biog = kzalloc(sizeof(struct bio_group), GFP_ATOMIC);
+	if (!biog)
+		return biog;
+
+	spin_lock_init(&biog->bio_group_lock);
+	biog->q = q;
+	biog->biocg = biocg;
+	INIT_LIST_HEAD(&biog->next);
+	biog->biog_inactive_timer.function = bio_group_inactive_timeout;
+	biog->biog_inactive_timer.data = (unsigned long)biog;
+	init_timer(&biog->biog_inactive_timer);
+	atomic_set(&biog->refcnt, 0);
+	spin_lock_irqsave(&biocg->biog_list_lock, flags);
+	list_add(&biog->next, &biocg->bio_group_list);
+	bio_group_get(biog);
+	spin_unlock_irqrestore(&biocg->biog_list_lock, flags);
+	return biog;
+}
+
+void* alloc_biog_io(void)
+{
+	return kzalloc(sizeof(struct biog_io), GFP_ATOMIC);
+}
+
+void free_biog_io(struct biog_io *biog_io)
+{
+	kfree(biog_io);
+}
+
+/*
+ * Upon succesful completion of bio, this function starts the inactive timer
+ * so that if a bio group stops contending for disk bandwidth, it is removed
+ * from the token allocation race.
+ */
+void biog_io_end(struct bio *bio, int error)
+{
+	struct biog_io *biog_io;
+	struct bio_group *biog;
+	unsigned long flags;
+	struct request_queue *q;
+
+	biog_io = bio->bi_private;
+	biog = biog_io->biog;
+	BUG_ON(!biog);
+
+	spin_lock_irqsave(&biog->bio_group_lock, flags);
+	q = biog->q;
+	BUG_ON(!q);
+
+	/* Restore the original bio fields */
+	bio->bi_end_io = biog_io->bi_end_io;
+	bio->bi_private = biog_io->bi_private;
+
+	/* If bio group is still empty, then start the inactive timer */
+	if (bio_group_on_queue(biog) && bio_group_empty(biog)) {
+		mod_timer(&biog->biog_inactive_timer,
+			jiffies + msecs_to_jiffies(q->biogroup_idletime));
+		bio_group_flag_set(BIOG_FLAG_TIMER_ACTIVE, biog);
+	}
+
+	spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+	free_biog_io(biog_io);
+	bio_group_put(biog);
+	bio_endio(bio, error);
+}
+
+/* Calculate how many tokens should be allocated to new group based on
+ * the number of share/weight of this group and the number of tokens and
+ * load which is already present on the queue.
+ */
+unsigned long calculate_nr_tokens(struct bio_group *biog,
+					struct request_queue *q)
+{
+	unsigned long nr_tokens, total_slice;
+
+	total_slice = q->biogroup_deftoken * q->nr_biog;
+	nr_tokens = total_slice * biog->biocg->shares/q->total_weight;
+
+	BUG_ON(!nr_tokens);
+	return nr_tokens;
+}
+
+unsigned long alloc_bio_group_key(struct request_queue *q)
+{
+	unsigned long key = 0;
+
+	if (!q->bio_groups.rb.rb_node)
+		return key;
+
+	/* Insert element at the end of tree */
+	key = q->max_key + 1;
+	return key;
+}
+
+/*
+ * The below is leftmost cache rbtree addon
+ */
+struct bio_group *bio_group_rb_first(struct group_rb_root *root)
+{
+	if (!root->left)
+		root->left = rb_first(&root->rb);
+
+	if (root->left)
+		return rb_entry(root->left, struct bio_group, rb_node);
+
+	return NULL;
+}
+
+void remove_bio_group_from_rbtree(struct bio_group *biog,
+					struct request_queue *q)
+{
+	struct group_rb_root *root;
+	struct rb_node *n;
+
+	root = &q->bio_groups;
+	n = &biog->rb_node;
+
+	if (root->left == n)
+		root->left = NULL;
+
+	rb_erase(n, &root->rb);
+	RB_CLEAR_NODE(n);
+
+	if (bio_group_blocked(biog))
+		q->nr_biog_blocked--;
+
+	q->nr_biog--;
+	q->total_weight -= biog->biocg->shares;
+
+	if (!q->total_weight)
+		q->max_key = 0;
+}
+
+
+void insert_bio_group_into_rbtree(struct bio_group *biog,
+					struct request_queue *q)
+{
+	struct rb_node **p;
+	struct rb_node *parent = NULL;
+	struct bio_group *__biog;
+	int leftmost = 1;
+
+	/* Check if any element being inserted has key less than max key */
+	if (biog->key < q->max_key)
+		BUG();
+
+	p = &q->bio_groups.rb.rb_node;
+	while (*p) {
+		parent = *p;
+		__biog = rb_entry(parent, struct bio_group, rb_node);
+
+		/* Should equal key case be a warning? */
+		if (biog->key < __biog->key)
+			p = &(*p)->rb_left;
+		else {
+			p = &(*p)->rb_right;
+			leftmost = 0;
+		}
+	}
+
+	/* Cache the leftmost element */
+	if (leftmost)
+		q->bio_groups.left = &biog->rb_node;
+
+	rb_link_node(&biog->rb_node, parent, p);
+	rb_insert_color(&biog->rb_node, &q->bio_groups.rb);
+
+	/* Update the tokens and weight in request_queue */
+	q->nr_biog++;
+	q->total_weight += biog->biocg->shares;
+	q->max_key = biog->key;
+	if (bio_group_blocked(biog))
+		q->nr_biog_blocked++;
+}
+
+void queue_bio_group(struct bio_group *biog, struct request_queue *q)
+{
+	biog->key = alloc_bio_group_key(q);
+	/* Take another reference on biog. will be decremented once biog
+	 * is off the tree */
+	bio_group_get(biog);
+	insert_bio_group_into_rbtree(biog, q);
+	bio_group_flag_set(BIOG_FLAG_ON_QUEUE, biog);
+	bio_group_flag_clear(BIOG_FLAG_BLOCKED, biog);
+	biog->slice_stamp = q->current_slice;
+}
+
+void start_new_token_slice(struct request_queue *q)
+{
+	struct rb_node *n;
+	struct bio_group *biog = NULL;
+	struct group_rb_root *root;
+	unsigned long flags;
+
+	q->current_slice++;
+
+	/* Traverse the tree and reset the blocked count to zero of all the
+	 * biogs */
+
+	root = &q->bio_groups;
+
+	if (!root->left)
+		root->left = rb_first(&root->rb);
+
+	if (root->left)
+		biog = rb_entry(root->left, struct bio_group, rb_node);
+
+	if (!biog)
+		return;
+
+	n = &biog->rb_node;
+
+	/* Reset blocked count */
+	q->nr_biog_blocked = 0;
+	q->newslice_count++;
+
+	do {
+		biog = rb_entry(n, struct bio_group, rb_node);
+		spin_lock_irqsave(&biog->bio_group_lock, flags);
+		bio_group_flag_clear(BIOG_FLAG_BLOCKED, biog);
+		spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+		n = rb_next(n);
+	} while (n);
+
+}
+
+int should_start_new_token_slice(struct request_queue *q)
+{
+	/*
+	 * if all the biog on the queue are blocked, then start a new
+	 * token slice
+	 */
+	if (q->nr_biog_blocked == q->nr_biog)
+		return 1;
+	return 0;
+}
+
+int is_bio_group_blocked(struct bio_group *biog)
+{
+	unsigned long flags, status = 0;
+
+	/* Do I really need to lock bio group */
+	spin_lock_irqsave(&biog->bio_group_lock, flags);
+		if (bio_group_blocked(biog))
+			status = 1;
+	spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+	return status;
+}
+
+int can_bio_group_dispatch(struct bio_group *biog, struct bio *bio)
+{
+	unsigned long temp = 0, flags;
+	struct request_queue *q;
+	long nr_sectors;
+	int can_dispatch = 0;
+
+	BUG_ON(!biog);
+	BUG_ON(!bio);
+
+	spin_lock_irqsave(&biog->bio_group_lock, flags);
+	nr_sectors = bio_sectors(bio);
+	q = biog->q;
+
+	if (time_after(q->current_slice, biog->slice_stamp)) {
+		temp = calculate_nr_tokens(biog, q);
+		biog->credit_tokens += temp;
+		biog->slice_stamp = q->current_slice;
+		biog->biocg->nr_token_slices++;
+	}
+
+	if ((biog->credit_tokens > 0) && (biog->credit_tokens > nr_sectors)) {
+		if (bio_group_flag_test_and_clear(BIOG_FLAG_BLOCKED, biog))
+			q->nr_biog_blocked--;
+		can_dispatch = 1;
+		goto out;
+	}
+
+	if (!bio_group_flag_test_and_set(BIOG_FLAG_BLOCKED, biog))
+		q->nr_biog_blocked++;
+
+out:
+	spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+	return can_dispatch;
+}
+
+/* Should be called without queue lock held */
+void bio_group_deactivate_timer(struct bio_group *biog)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&biog->bio_group_lock, flags);
+	if (bio_group_flag_test_and_clear(BIOG_FLAG_TIMER_ACTIVE, biog)) {
+		/* Drop the bio group lock so that timer routine could
+		 * finish in case it fires */
+		spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+		del_timer_sync(&biog->biog_inactive_timer);
+		return;
+	}
+	spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+}
+
+int attach_bio_group_io(struct bio_group *biog, struct bio *bio)
+{
+	int err = 0;
+	struct biog_io *biog_io;
+
+	biog_io = alloc_biog_io();
+	if (!biog_io) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	/* I already have a valid pointer to biog. So it should be ok
+	 * to get a reference to it. */
+	bio_group_get(biog);
+	biog_io->biog = biog;
+	biog_io->bi_end_io = bio->bi_end_io;
+	biog_io->bi_private = bio->bi_private;
+
+	bio->bi_end_io = biog_io_end;
+	bio->bi_private = biog_io;
+out:
+	return err;
+}
+
+int account_bio_to_bio_group(struct bio_group *biog, struct bio *bio)
+{
+	int err = 0;
+	unsigned long flags;
+	struct request_queue *q;
+
+	spin_lock_irqsave(&biog->bio_group_lock, flags);
+	err = attach_bio_group_io(biog, bio);
+	if (err)
+		goto out;
+
+	biog->nr_bio++;
+	q = biog->q;
+	if (!bio_group_on_queue(biog))
+		queue_bio_group(biog, q);
+
+out:
+	spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+	return err;
+}
+
+int add_bio_to_bio_group_queue(struct bio_group *biog, struct bio *bio)
+{
+	unsigned long flags;
+	struct request_queue *q;
+
+	spin_lock_irqsave(&biog->bio_group_lock, flags);
+	__bio_group_queue_bio_tail(biog, bio);
+	q = biog->q;
+	q->nr_queued_bio++;
+	queue_delayed_work(q->biogroup_workqueue, &q->biogroup_work, 0);
+	spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+	return 0;
+}
+
+/*
+ * It determines if the thread submitting the bio can itself continue to
+ * submit the bio or this bio needs to be buffered for later submission
+ */
+int can_biog_do_direct_dispatch(struct bio_group *biog)
+{
+	unsigned long flags, dispatch = 1;
+
+	spin_lock_irqsave(&biog->bio_group_lock, flags);
+	if (bio_group_blocked(biog)) {
+		dispatch = 0;
+		goto out;
+	}
+
+	/* Make sure there are not other queued bios on the biog. These
+	 * queued bios should get a chance to dispatch first */
+	if (!bio_group_queued_empty(biog))
+		dispatch = 0;
+out:
+	spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+	return dispatch;
+}
+
+void charge_bio_group_for_tokens(struct bio_group *biog, struct bio *bio)
+{
+	unsigned long flags;
+	long dispatched_tokens;
+
+	spin_lock_irqsave(&biog->bio_group_lock, flags);
+	dispatched_tokens = bio_sectors(bio);
+	biog->nr_bio--;
+
+	biog->credit_tokens -= dispatched_tokens;
+
+	/* debug aid. also update aggregate tokens and jiffies in biocg */
+	biog->biocg->aggregate_tokens += dispatched_tokens;
+	biog->biocg->jiffies = jiffies;
+
+	spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+}
+
+unsigned long __bio_group_try_to_dispatch(struct bio_group *biog,
+							struct bio *bio)
+{
+	struct request_queue *q;
+	int dispatched = 0;
+
+	BUG_ON(!biog);
+	BUG_ON(!bio);
+
+	q = biog->q;
+	BUG_ON(!q);
+retry:
+	if (!can_bio_group_dispatch(biog, bio)) {
+		if (should_start_new_token_slice(q)) {
+			start_new_token_slice(q);
+			goto retry;
+		}
+		goto out;
+	}
+
+	charge_bio_group_for_tokens(biog, bio);
+	dispatched = 1;
+out:
+	return dispatched;
+}
+
+unsigned long bio_group_try_to_dispatch(struct bio_group *biog, struct bio *bio)
+{
+	struct request_queue *q;
+	int dispatched = 0;
+	unsigned long flags;
+
+	q = biog->q;
+	BUG_ON(!q);
+
+	spin_lock_irqsave(q->queue_lock, flags);
+	dispatched = __bio_group_try_to_dispatch(biog, bio);
+	spin_unlock_irqrestore(q->queue_lock, flags);
+
+	return dispatched;
+}
+
+/* Should be called with queue lock and bio group lock held */
+void requeue_bio_group(struct request_queue *q, struct bio_group *biog)
+{
+	remove_bio_group_from_rbtree(biog, q);
+	biog->key = alloc_bio_group_key(q);
+	insert_bio_group_into_rbtree(biog, q);
+}
+
+/* Make a list of queued bios in this bio group which can be dispatched. */
+void make_release_bio_list(struct bio_group *biog,
+					struct bio_list *release_list)
+{
+	unsigned long flags, dispatched = 0;
+	struct bio *bio;
+	struct request_queue *q;
+
+	spin_lock_irqsave(&biog->bio_group_lock, flags);
+
+	while (1) {
+		if (bio_group_queued_empty(biog))
+			goto out;
+
+		if (bio_group_blocked(biog))
+			goto out;
+
+		/* Dequeue one bio from bio group */
+		bio = __bio_group_dequeue_bio(biog);
+		BUG_ON(!bio);
+		q = biog->q;
+		q->nr_queued_bio--;
+
+		/* Releasing lock as try to dispatch will acquire it again */
+		spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+		dispatched = __bio_group_try_to_dispatch(biog, bio);
+		spin_lock_irqsave(&biog->bio_group_lock, flags);
+
+		if (dispatched) {
+			/* Add the bio to release list */
+			bio_list_add(release_list, bio);
+			continue;
+		} else {
+			/* Put the bio back into biog */
+			__bio_group_queue_bio_head(biog, bio);
+			q->nr_queued_bio++;
+			goto out;
+		}
+	}
+out:
+	spin_unlock_irqrestore(&biog->bio_group_lock, flags);
+	return;
+}
+
+/*
+ * If a bio group is inactive for q->inactive_timeout, then this group is
+ * considered to be no more contending for the disk bandwidth and removed
+ * from the tree.
+ */
+void bio_group_inactive_timeout(unsigned long data)
+{
+	struct bio_group *biog = (struct bio_group *)data;
+	unsigned long flags, flags1;
+	struct request_queue *q;
+
+	q = biog->q;
+	BUG_ON(!q);
+
+	spin_lock_irqsave(q->queue_lock, flags);
+	spin_lock_irqsave(&biog->bio_group_lock, flags1);
+
+	BUG_ON(!bio_group_on_queue(biog));
+	BUG_ON(biog->nr_bio);
+
+	BUG_ON((biog->bio_group_flags > 7));
+	/* Remove biog from tree */
+	biog->biocg->nr_off_the_tree++;
+	remove_bio_group_from_rbtree(biog, q);
+	bio_group_flag_clear(BIOG_FLAG_ON_QUEUE, biog);
+	bio_group_flag_clear(BIOG_FLAG_BLOCKED, biog);
+	bio_group_flag_clear(BIOG_FLAG_TIMER_ACTIVE, biog);
+
+	/* dm_start_new_slice() takes bio_group_lock. Release it now */
+	spin_unlock_irqrestore(&biog->bio_group_lock, flags1);
+
+	/* Also check if new slice should be started */
+	if ((q->nr_biog) && should_start_new_token_slice(q))
+		start_new_token_slice(q);
+
+	spin_unlock_irqrestore(q->queue_lock, flags);
+	/* Drop the reference to biog */
+	bio_group_put(biog);
+	return;
+}
+
+/*
+ * It is called through worker thread and it takes care of releasing queued
+ * bios to underlying layer
+ */
+void bio_group_dispatch_queued_bio(struct request_queue *q)
+{
+	struct bio_group *biog;
+	unsigned long biog_scanned = 0;
+	unsigned long flags, flags1;
+	struct bio *bio = NULL;
+	int ret;
+	struct bio_list release_list;
+
+	bio_list_init(&release_list);
+
+	spin_lock_irqsave(q->queue_lock, flags);
+
+	while (1) {
+
+		if (!q->nr_biog)
+			goto out;
+
+		if (!q->nr_queued_bio)
+			goto out;
+
+		if (biog_scanned == q->nr_biog) {
+			/* Scanned the whole tree. No eligible biog found */
+			if (q->nr_queued_bio) {
+				queue_delayed_work(q->biogroup_workqueue,
+							&q->biogroup_work, 1);
+			}
+			goto out;
+		}
+
+		biog = bio_group_rb_first(&q->bio_groups);
+		BUG_ON(!biog);
+
+		make_release_bio_list(biog, &release_list);
+
+		/* If there are bios to dispatch, release these */
+		if (!bio_list_empty(&release_list)) {
+			if (q->nr_queued_bio)
+				queue_delayed_work(q->biogroup_workqueue,
+						&q->biogroup_work, 0);
+			goto dispatch_bio;
+		} else {
+			spin_lock_irqsave(&biog->bio_group_lock, flags1);
+			requeue_bio_group(q, biog);
+			biog_scanned++;
+			spin_unlock_irqrestore(&biog->bio_group_lock, flags1);
+			continue;
+		}
+	}
+
+dispatch_bio:
+		spin_unlock_irqrestore(q->queue_lock, flags);
+		bio = bio_list_pop(&release_list);
+		BUG_ON(!bio);
+
+		do {
+			/* Taint the bio with pass through flag */
+			bio->bi_flags |= (1UL << BIO_NOBIOGROUP);
+			do {
+				ret = q->make_request_fn(q, bio);
+			} while (ret);
+			bio = bio_list_pop(&release_list);
+		} while (bio);
+
+		return;
+out:
+	spin_unlock_irqrestore(q->queue_lock, flags);
+	return;
+}
+
+void blk_biogroup_work(struct work_struct *work)
+{
+	struct delayed_work *dw = container_of(work, struct delayed_work, work);
+	struct request_queue *q =
+		container_of(dw, struct request_queue, biogroup_work);
+
+	bio_group_dispatch_queued_bio(q);
+}
+
+/*
+ * This is core IO controller function which tries to dispatch bios to
+ * underlying layers based on cgroup weights.
+ *
+ * If the cgroup bio belongs to has got sufficient tokens, submitting
+ * task/thread is allowed to continue to submit the bio otherwise, bio
+ * is buffered here and submitting thread returns. This buffered bio will
+ * be dispatched to lower layers when cgroup has sufficient tokens.
+ *
+ * Return code:
+ * 0 --> continue submit the bio
+ * 1---> bio buffered by bio group layer. return
+ */
+int bio_group_controller(struct request_queue *q, struct bio *bio)
+{
+
+	struct bio_group *biog;
+	struct bio_cgroup *biocg;
+	int err = 0;
+	unsigned long flags, dispatched = 0;
+
+	/* This bio has already been subjected to resource constraints.
+	 * Let it pass through unconditionally. */
+	if (bio_flagged(bio, BIO_NOBIOGROUP)) {
+		bio->bi_flags &= ~(1UL << BIO_NOBIOGROUP);
+		return 0;
+	}
+
+	spin_lock_irqsave(q->queue_lock, flags);
+	biocg = bio_cgroup_from_bio(bio);
+	BUG_ON(!biocg);
+
+	/* If a biog is found, we also take a reference to it */
+	biog = bio_group_from_cgroup(biocg, q);
+	if (!biog) {
+		/* In case of success, returns with reference to biog */
+		biog = create_bio_group(biocg, q);
+		if (!biog) {
+			err = -ENOMEM;
+			goto end_io;
+		}
+	}
+
+	spin_unlock_irqrestore(q->queue_lock, flags);
+	bio_group_deactivate_timer(biog);
+	spin_lock_irqsave(q->queue_lock, flags);
+
+	err = account_bio_to_bio_group(biog, bio);
+	if (err)
+		goto end_io;
+
+	if (!can_biog_do_direct_dispatch(biog)) {
+		add_bio_to_bio_group_queue(biog, bio);
+		goto buffered;
+	}
+
+	dispatched = __bio_group_try_to_dispatch(biog, bio);
+
+	if (!dispatched) {
+		add_bio_to_bio_group_queue(biog, bio);
+		goto buffered;
+	}
+
+	bio_group_put(biog);
+	spin_unlock_irqrestore(q->queue_lock, flags);
+	return 0;
+
+buffered:
+	bio_group_put(biog);
+	spin_unlock_irqrestore(q->queue_lock, flags);
+	return 1;
+end_io:
+	bio_group_put(biog);
+	spin_unlock_irqrestore(q->queue_lock, flags);
+	bio_endio(bio, err);
+	return 1;
+}
Index: linux2/include/linux/bio.h
===================================================================
--- linux2.orig/include/linux/bio.h	2008-11-06 05:27:05.000000000 -0500
+++ linux2/include/linux/bio.h	2008-11-06 05:27:37.000000000 -0500
@@ -131,6 +131,7 @@ struct bio {
 #define BIO_BOUNCED	5	/* bio is a bounce bio */
 #define BIO_USER_MAPPED 6	/* contains user pages */
 #define BIO_EOPNOTSUPP	7	/* not supported */
+#define BIO_NOBIOGROUP 8       /* Don do bio group control on this bio */
 #define bio_flagged(bio, flag)	((bio)->bi_flags & (1 << (flag)))
 
 /*
Index: linux2/block/genhd.c
===================================================================
--- linux2.orig/block/genhd.c	2008-11-06 05:27:05.000000000 -0500
+++ linux2/block/genhd.c	2008-11-06 05:27:37.000000000 -0500
@@ -440,6 +440,120 @@ static ssize_t disk_removable_show(struc
 		       (disk->flags & GENHD_FL_REMOVABLE ? 1 : 0));
 }
 
+static ssize_t disk_biogroup_show(struct device *dev,
+				   struct device_attribute *attr, char *buf)
+{
+	struct gendisk *disk = dev_to_disk(dev);
+	struct request_queue *q = disk->queue;
+
+	return sprintf(buf, "%d\n", blk_queue_bio_group_enabled(q));
+}
+
+static ssize_t disk_biogroup_store(struct device *dev,
+			       struct device_attribute *attr,
+			       const char *buf, size_t count)
+{
+	struct gendisk *disk = dev_to_disk(dev);
+	struct request_queue *q = disk->queue;
+	int i = 0;
+
+	if (count > 0 && sscanf(buf, "%d", &i) > 0) {
+		spin_lock_irq(q->queue_lock);
+		if (i)
+			queue_flag_set(QUEUE_FLAG_BIOG_ENABLED, q);
+		else
+			queue_flag_clear(QUEUE_FLAG_BIOG_ENABLED, q);
+
+		spin_unlock_irq(q->queue_lock);
+	}
+	return count;
+}
+
+static ssize_t disk_newslice_count_show(struct device *dev,
+				   struct device_attribute *attr, char *buf)
+{
+	struct gendisk *disk = dev_to_disk(dev);
+	struct request_queue *q = disk->queue;
+
+	return sprintf(buf, "%lu\n", q->newslice_count);
+}
+
+static ssize_t disk_newslice_count_store(struct device *dev,
+			       struct device_attribute *attr,
+			       const char *buf, size_t count)
+{
+	struct gendisk *disk = dev_to_disk(dev);
+	struct request_queue *q = disk->queue;
+	unsigned long flags;
+	int i = 0;
+
+	if (count > 0 && sscanf(buf, "%d", &i) > 0) {
+		spin_lock_irqsave(q->queue_lock, flags);
+			q->newslice_count = i;
+		spin_unlock_irqrestore(q->queue_lock, flags);
+	}
+	return count;
+}
+
+static ssize_t disk_idletime_show(struct device *dev,
+				   struct device_attribute *attr, char *buf)
+{
+	struct gendisk *disk = dev_to_disk(dev);
+	struct request_queue *q = disk->queue;
+
+	return sprintf(buf, "%lu\n", q->biogroup_idletime);
+}
+
+static ssize_t disk_idletime_store(struct device *dev,
+			       struct device_attribute *attr,
+			       const char *buf, size_t count)
+{
+	struct gendisk *disk = dev_to_disk(dev);
+	struct request_queue *q = disk->queue;
+	int i = 0;
+
+	if (count > 0 && sscanf(buf, "%d", &i) > 0) {
+		spin_lock_irq(q->queue_lock);
+		if (i)
+			q->biogroup_idletime = i;
+		else
+			q->biogroup_idletime = 0;
+
+		spin_unlock_irq(q->queue_lock);
+	}
+	return count;
+}
+
+static ssize_t disk_deftoken_show(struct device *dev,
+				   struct device_attribute *attr, char *buf)
+{
+	struct gendisk *disk = dev_to_disk(dev);
+	struct request_queue *q = disk->queue;
+
+	return sprintf(buf, "%lu\n", q->biogroup_deftoken);
+}
+
+static ssize_t disk_deftoken_store(struct device *dev,
+			       struct device_attribute *attr,
+			       const char *buf, size_t count)
+{
+	struct gendisk *disk = dev_to_disk(dev);
+	struct request_queue *q = disk->queue;
+	int i = 0;
+
+	if (count > 0 && sscanf(buf, "%d", &i) > 0) {
+		spin_lock_irq(q->queue_lock);
+		if (i) {
+			if (i > 0x30)
+				q->biogroup_deftoken = i;
+		} else
+			q->biogroup_deftoken = 0;
+
+		spin_unlock_irq(q->queue_lock);
+	}
+	return count;
+}
+
 static ssize_t disk_ro_show(struct device *dev,
 				   struct device_attribute *attr, char *buf)
 {
@@ -524,6 +638,10 @@ static DEVICE_ATTR(ro, S_IRUGO, disk_ro_
 static DEVICE_ATTR(size, S_IRUGO, disk_size_show, NULL);
 static DEVICE_ATTR(capability, S_IRUGO, disk_capability_show, NULL);
 static DEVICE_ATTR(stat, S_IRUGO, disk_stat_show, NULL);
+static DEVICE_ATTR(biogroup, S_IRUGO | S_IWUSR, disk_biogroup_show, disk_biogroup_store);
+static DEVICE_ATTR(idletime, S_IRUGO | S_IWUSR, disk_idletime_show, disk_idletime_store);
+static DEVICE_ATTR(deftoken, S_IRUGO | S_IWUSR, disk_deftoken_show, disk_deftoken_store);
+static DEVICE_ATTR(newslice_count, S_IRUGO | S_IWUSR, disk_newslice_count_show, disk_newslice_count_store);
 #ifdef CONFIG_FAIL_MAKE_REQUEST
 static struct device_attribute dev_attr_fail =
 	__ATTR(make-it-fail, S_IRUGO|S_IWUSR, disk_fail_show, disk_fail_store);
@@ -539,6 +657,10 @@ static struct attribute *disk_attrs[] = 
 #ifdef CONFIG_FAIL_MAKE_REQUEST
 	&dev_attr_fail.attr,
 #endif
+	&dev_attr_biogroup.attr,
+	&dev_attr_idletime.attr,
+	&dev_attr_deftoken.attr,
+	&dev_attr_newslice_count.attr,
 	NULL
 };
 
Index: linux2/include/linux/blkdev.h
===================================================================
--- linux2.orig/include/linux/blkdev.h	2008-11-06 05:27:05.000000000 -0500
+++ linux2/include/linux/blkdev.h	2008-11-06 05:29:51.000000000 -0500
@@ -289,6 +289,11 @@ struct blk_cmd_filter {
 	struct kobject kobj;
 };
 
+struct group_rb_root {
+	struct rb_root	rb;
+	struct rb_node	*left;
+};
+
 struct request_queue
 {
 	/*
@@ -298,6 +303,33 @@ struct request_queue
 	struct request		*last_merge;
 	elevator_t		*elevator;
 
+	/* rb-tree which contains all the contending bio groups */
+	struct group_rb_root	bio_groups;
+
+	/* Total number of bio_group currently on the request queue */
+	unsigned long		nr_biog;
+	unsigned long		current_slice;
+
+	struct workqueue_struct *biogroup_workqueue;
+	struct delayed_work     biogroup_work;
+	unsigned long		nr_queued_bio;
+
+	/* What's the idletime after which a bio group is considered idle and
+	 * considered no more contending for the bandwidth. */
+	unsigned long		biogroup_idletime;
+	unsigned long		biogroup_deftoken;
+
+	/* Number of biog which can't issue IO because they don't have
+	 * suffifiet tokens */
+	unsigned long		nr_biog_blocked;
+
+	/* Sum of weight of all the cgroups present on this queue */
+	unsigned long		total_weight;
+
+	/* Debug Aid */
+	unsigned long		max_key;
+	unsigned long		newslice_count;
+
 	/*
 	 * the queue request freelist, one for reads and one for writes
 	 */
@@ -421,6 +453,7 @@ struct request_queue
 #define QUEUE_FLAG_ELVSWITCH	8	/* don't use elevator, just do FIFO */
 #define QUEUE_FLAG_BIDI		9	/* queue supports bidi requests */
 #define QUEUE_FLAG_NOMERGES    10	/* disable merge attempts */
+#define QUEUE_FLAG_BIOG_ENABLED    11	/* bio group enabled */
 
 static inline int queue_is_locked(struct request_queue *q)
 {
@@ -527,6 +560,7 @@ enum {
 #define blk_queue_stopped(q)	test_bit(QUEUE_FLAG_STOPPED, &(q)->queue_flags)
 #define blk_queue_nomerges(q)	test_bit(QUEUE_FLAG_NOMERGES, &(q)->queue_flags)
 #define blk_queue_flushing(q)	((q)->ordseq)
+#define blk_queue_bio_group_enabled(q)	test_bit(QUEUE_FLAG_BIOG_ENABLED, &(q)->queue_flags)
 
 #define blk_fs_request(rq)	((rq)->cmd_type == REQ_TYPE_FS)
 #define blk_pc_request(rq)	((rq)->cmd_type == REQ_TYPE_BLOCK_PC)
Index: linux2/block/blk-core.c
===================================================================
--- linux2.orig/block/blk-core.c	2008-11-06 05:27:05.000000000 -0500
+++ linux2/block/blk-core.c	2008-11-06 05:27:40.000000000 -0500
@@ -30,6 +30,7 @@
 #include <linux/cpu.h>
 #include <linux/blktrace_api.h>
 #include <linux/fault-inject.h>
+#include <linux/biocontrol.h>
 
 #include "blk.h"
 
@@ -502,6 +503,20 @@ struct request_queue *blk_alloc_queue_no
 	mutex_init(&q->sysfs_lock);
 	spin_lock_init(&q->__queue_lock);
 
+#ifdef CONFIG_CGROUP_BIO
+	/* Initialize default idle time */
+	q->biogroup_idletime = DEFAULT_IDLE_PERIOD;
+	q->biogroup_deftoken = DEFAULT_NR_TOKENS;
+
+	/* Also create biogroup worker threads. It needs to be conditional */
+	if (!bio_cgroup_disabled()) {
+		q->biogroup_workqueue = create_workqueue("biogroup");
+		if (!q->biogroup_workqueue)
+			panic("Failed to create biogroup\n");
+	}
+	INIT_DELAYED_WORK(&q->biogroup_work, blk_biogroup_work);
+#endif
+
 	return q;
 }
 EXPORT_SYMBOL(blk_alloc_queue_node);
Index: linux2/include/linux/biocontrol.h
===================================================================
--- linux2.orig/include/linux/biocontrol.h	2008-11-06 05:27:36.000000000 -0500
+++ linux2/include/linux/biocontrol.h	2008-11-06 05:27:37.000000000 -0500
@@ -12,6 +12,17 @@
 struct io_context;
 struct block_device;
 
+/* what's a good value. starting with 8 ms */
+#define DEFAULT_IDLE_PERIOD	8
+/* what's a good value. starting with 2000 */
+#define DEFAULT_NR_TOKENS      2000
+
+struct biog_io {
+	struct bio_group	*biog;
+	bio_end_io_t		*bi_end_io;
+	void			*bi_private;
+};
+
 struct bio_cgroup {
 	struct cgroup_subsys_state css;
 	/* Share/weight of the cgroup */
@@ -32,6 +43,46 @@ struct bio_cgroup {
 	unsigned long 		nr_token_slices;
 };
 
+/*
+ * This object keeps track of a group of bios on a particular request queue.
+ * A cgroup will have one bio_group on each block device request queue it
+ * is doing IO to.
+ */
+struct bio_group {
+	spinlock_t	bio_group_lock;
+
+	unsigned long	bio_group_flags;
+
+	/* reference counting. use bio_group_get() and bio_group_put() */
+	atomic_t	refcnt;
+
+	/* Pointer to the request queue this bio-group is currently associated
+	 * with */
+	struct request_queue	*q;
+
+	/* Pointer to parent bio_cgroup */
+	struct bio_cgroup	*biocg;
+
+	/* bio_groups are connected through a linked list in parent cgroup */
+	struct list_head	next;
+
+	long			credit_tokens;
+
+	/* Node which hangs in per request queue rb tree */
+	struct rb_node          rb_node;
+
+	/* Key to index inside rb-tree rooted at devices's request_queue. */
+	unsigned long           key;
+
+	unsigned long		slice_stamp;
+
+	struct timer_list	biog_inactive_timer;
+	unsigned long		nr_bio;
+
+	/* List where buffered bios are queued */
+	struct bio_list		bio_queue;
+};
+
 static inline int bio_cgroup_disabled(void)
 {
 	return bio_cgroup_subsys.disabled;
@@ -110,6 +161,69 @@ static inline void bio_cgroup_remove_pag
 	spin_unlock_irqrestore(&biocg->page_list_lock, flags);
 }
 
+static inline void bio_group_get(struct bio_group *biog)
+{
+	atomic_inc(&biog->refcnt);
+}
+
+static inline void bio_group_put(struct bio_group *biog)
+{
+	atomic_dec(&biog->refcnt);
+}
+
+#define BIOG_FLAG_TIMER_ACTIVE	0	/* Inactive timer armed status */
+#define BIOG_FLAG_ON_QUEUE	1	/* If biog is on request queue */
+#define BIOG_FLAG_BLOCKED	2	/* bio group is blocked */
+
+#define bio_group_timer_active(biog)	test_bit(BIOG_FLAG_TIMER_ACTIVE, &(biog)->bio_group_flags)
+#define bio_group_on_queue(biog)	test_bit(BIOG_FLAG_ON_QUEUE, &(biog)->bio_group_flags)
+#define bio_group_blocked(biog)		test_bit(BIOG_FLAG_BLOCKED, &(biog)->bio_group_flags)
+
+static inline void bio_group_flag_set(unsigned int flag, struct bio_group *biog)
+{
+	__set_bit(flag, &biog->bio_group_flags);
+}
+
+static inline void bio_group_flag_clear(unsigned int flag,
+						struct bio_group *biog)
+{
+	__clear_bit(flag, &biog->bio_group_flags);
+}
+
+static inline int bio_group_flag_test_and_clear(unsigned int flag,
+					    struct bio_group *biog)
+{
+	if (test_bit(flag, &biog->bio_group_flags)) {
+		__clear_bit(flag, &biog->bio_group_flags);
+		return 1;
+	}
+
+	return 0;
+}
+
+static inline int bio_group_flag_test_and_set(unsigned int flag,
+					  struct bio_group *biog)
+{
+	if (!test_bit(flag, &biog->bio_group_flags)) {
+		__set_bit(flag, &biog->bio_group_flags);
+		return 0;
+	}
+
+	return 1;
+}
+
+static inline int bio_group_empty(struct bio_group *biog)
+{
+	return !biog->nr_bio;
+}
+
+static inline int bio_group_queued_empty(struct bio_group *biog)
+{
+	if (bio_list_empty(&biog->bio_queue))
+		return 1;
+	return 0;
+}
+
 extern void clear_bio_cgroup(struct page_cgroup *pc);
 
 extern int bio_group_controller(struct request_queue *q, struct bio *bio);

-- 
