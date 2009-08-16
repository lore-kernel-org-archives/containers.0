From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 13/24] io-controller: Separate out queue and data
Date: Sun, 16 Aug 2009 15:30:35 -0400
Message-ID: <1250451046-9966-14-git-send-email-vgoyal__1019.24357372827$1250453570$gmane$org@redhat.com>
References: <1250451046-9966-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1250451046-9966-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, righi.andr
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

o So far noop, deadline and AS had one common structure called *_data which
  contained both the queue information where requests are queued and also
  common data used for scheduling. This patch breaks down this common
  structure in two parts, *_queue and *_data. This is along the lines of
  cfq where all the reuquests are queued in queue and common data and tunables
  are part of data.

o It does not change the functionality but this re-organization helps once
  noop, deadline and AS are changed to use hierarchical fair queuing.

o looks like queue_empty function is not required and we can check for
  q->nr_sorted in elevator layer to see if ioscheduler queues are empty or
  not.

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/as-iosched.c       |  208 ++++++++++++++++++++++++++--------------------
 block/deadline-iosched.c |  117 ++++++++++++++++----------
 block/elevator.c         |  111 +++++++++++++++++++++----
 block/noop-iosched.c     |   59 ++++++-------
 include/linux/elevator.h |    9 ++-
 5 files changed, 320 insertions(+), 184 deletions(-)

diff --git a/block/as-iosched.c b/block/as-iosched.c
index b90acbe..ec6b940 100644
--- a/block/as-iosched.c
+++ b/block/as-iosched.c
@@ -76,13 +76,7 @@ enum anticipation_status {
 				 * or timed out */
 };
 
-struct as_data {
-	/*
-	 * run time data
-	 */
-
-	struct request_queue *q;	/* the "owner" queue */
-
+struct as_queue {
 	/*
 	 * requests (as_rq s) are present on both sort_list and fifo_list
 	 */
@@ -90,6 +84,14 @@ struct as_data {
 	struct list_head fifo_list[2];
 
 	struct request *next_rq[2];	/* next in sort order */
+	unsigned long last_check_fifo[2];
+	int write_batch_count;		/* max # of reqs in a write batch */
+	int current_write_count;	/* how many requests left this batch */
+	int write_batch_idled;		/* has the write batch gone idle? */
+};
+
+struct as_data {
+	struct request_queue *q;	/* the "owner" queue */
 	sector_t last_sector[2];	/* last SYNC & ASYNC sectors */
 
 	unsigned long exit_prob;	/* probability a task will exit while
@@ -103,21 +105,17 @@ struct as_data {
 	sector_t new_seek_mean;
 
 	unsigned long current_batch_expires;
-	unsigned long last_check_fifo[2];
 	int changed_batch;		/* 1: waiting for old batch to end */
 	int new_batch;			/* 1: waiting on first read complete */
-	int batch_data_dir;		/* current batch SYNC / ASYNC */
-	int write_batch_count;		/* max # of reqs in a write batch */
-	int current_write_count;	/* how many requests left this batch */
-	int write_batch_idled;		/* has the write batch gone idle? */
 
 	enum anticipation_status antic_status;
 	unsigned long antic_start;	/* jiffies: when it started */
 	struct timer_list antic_timer;	/* anticipatory scheduling timer */
-	struct work_struct antic_work;	/* Deferred unplugging */
+	struct work_struct antic_work;  /* Deferred unplugging */
 	struct io_context *io_context;	/* Identify the expected process */
 	int ioc_finished; /* IO associated with io_context is finished */
 	int nr_dispatched;
+	int batch_data_dir;		/* current batch SYNC / ASYNC */
 
 	/*
 	 * settings that change how the i/o scheduler behaves
@@ -258,13 +256,14 @@ static void as_put_io_context(struct request *rq)
 /*
  * rb tree support functions
  */
-#define RQ_RB_ROOT(ad, rq)	(&(ad)->sort_list[rq_is_sync((rq))])
+#define RQ_RB_ROOT(asq, rq)	(&(asq)->sort_list[rq_is_sync((rq))])
 
 static void as_add_rq_rb(struct as_data *ad, struct request *rq)
 {
 	struct request *alias;
+	struct as_queue *asq = elv_get_sched_queue(ad->q, rq);
 
-	while ((unlikely(alias = elv_rb_add(RQ_RB_ROOT(ad, rq), rq)))) {
+	while ((unlikely(alias = elv_rb_add(RQ_RB_ROOT(asq, rq), rq)))) {
 		as_move_to_dispatch(ad, alias);
 		as_antic_stop(ad);
 	}
@@ -272,7 +271,9 @@ static void as_add_rq_rb(struct as_data *ad, struct request *rq)
 
 static inline void as_del_rq_rb(struct as_data *ad, struct request *rq)
 {
-	elv_rb_del(RQ_RB_ROOT(ad, rq), rq);
+	struct as_queue *asq = elv_get_sched_queue(ad->q, rq);
+
+	elv_rb_del(RQ_RB_ROOT(asq, rq), rq);
 }
 
 /*
@@ -366,7 +367,7 @@ as_choose_req(struct as_data *ad, struct request *rq1, struct request *rq2)
  * what request to process next. Anticipation works on top of this.
  */
 static struct request *
-as_find_next_rq(struct as_data *ad, struct request *last)
+as_find_next_rq(struct as_data *ad, struct as_queue *asq, struct request *last)
 {
 	struct rb_node *rbnext = rb_next(&last->rb_node);
 	struct rb_node *rbprev = rb_prev(&last->rb_node);
@@ -382,7 +383,7 @@ as_find_next_rq(struct as_data *ad, struct request *last)
 	else {
 		const int data_dir = rq_is_sync(last);
 
-		rbnext = rb_first(&ad->sort_list[data_dir]);
+		rbnext = rb_first(&asq->sort_list[data_dir]);
 		if (rbnext && rbnext != &last->rb_node)
 			next = rb_entry_rq(rbnext);
 	}
@@ -789,9 +790,10 @@ static int as_can_anticipate(struct as_data *ad, struct request *rq)
 static void as_update_rq(struct as_data *ad, struct request *rq)
 {
 	const int data_dir = rq_is_sync(rq);
+	struct as_queue *asq = elv_get_sched_queue(ad->q, rq);
 
 	/* keep the next_rq cache up to date */
-	ad->next_rq[data_dir] = as_choose_req(ad, rq, ad->next_rq[data_dir]);
+	asq->next_rq[data_dir] = as_choose_req(ad, rq, asq->next_rq[data_dir]);
 
 	/*
 	 * have we been anticipating this request?
@@ -812,25 +814,26 @@ static void update_write_batch(struct as_data *ad)
 {
 	unsigned long batch = ad->batch_expire[BLK_RW_ASYNC];
 	long write_time;
+	struct as_queue *asq = elv_get_sched_queue(ad->q, NULL);
 
 	write_time = (jiffies - ad->current_batch_expires) + batch;
 	if (write_time < 0)
 		write_time = 0;
 
-	if (write_time > batch && !ad->write_batch_idled) {
+	if (write_time > batch && !asq->write_batch_idled) {
 		if (write_time > batch * 3)
-			ad->write_batch_count /= 2;
+			asq->write_batch_count /= 2;
 		else
-			ad->write_batch_count--;
-	} else if (write_time < batch && ad->current_write_count == 0) {
+			asq->write_batch_count--;
+	} else if (write_time < batch && asq->current_write_count == 0) {
 		if (batch > write_time * 3)
-			ad->write_batch_count *= 2;
+			asq->write_batch_count *= 2;
 		else
-			ad->write_batch_count++;
+			asq->write_batch_count++;
 	}
 
-	if (ad->write_batch_count < 1)
-		ad->write_batch_count = 1;
+	if (asq->write_batch_count < 1)
+		asq->write_batch_count = 1;
 }
 
 /*
@@ -901,6 +904,7 @@ static void as_remove_queued_request(struct request_queue *q,
 	const int data_dir = rq_is_sync(rq);
 	struct as_data *ad = q->elevator->elevator_data;
 	struct io_context *ioc;
+	struct as_queue *asq = elv_get_sched_queue(q, rq);
 
 	WARN_ON(RQ_STATE(rq) != AS_RQ_QUEUED);
 
@@ -914,8 +918,8 @@ static void as_remove_queued_request(struct request_queue *q,
 	 * Update the "next_rq" cache if we are about to remove its
 	 * entry
 	 */
-	if (ad->next_rq[data_dir] == rq)
-		ad->next_rq[data_dir] = as_find_next_rq(ad, rq);
+	if (asq->next_rq[data_dir] == rq)
+		asq->next_rq[data_dir] = as_find_next_rq(ad, asq, rq);
 
 	rq_fifo_clear(rq);
 	as_del_rq_rb(ad, rq);
@@ -929,23 +933,23 @@ static void as_remove_queued_request(struct request_queue *q,
  *
  * See as_antic_expired comment.
  */
-static int as_fifo_expired(struct as_data *ad, int adir)
+static int as_fifo_expired(struct as_data *ad, struct as_queue *asq, int adir)
 {
 	struct request *rq;
 	long delta_jif;
 
-	delta_jif = jiffies - ad->last_check_fifo[adir];
+	delta_jif = jiffies - asq->last_check_fifo[adir];
 	if (unlikely(delta_jif < 0))
 		delta_jif = -delta_jif;
 	if (delta_jif < ad->fifo_expire[adir])
 		return 0;
 
-	ad->last_check_fifo[adir] = jiffies;
+	asq->last_check_fifo[adir] = jiffies;
 
-	if (list_empty(&ad->fifo_list[adir]))
+	if (list_empty(&asq->fifo_list[adir]))
 		return 0;
 
-	rq = rq_entry_fifo(ad->fifo_list[adir].next);
+	rq = rq_entry_fifo(asq->fifo_list[adir].next);
 
 	return time_after(jiffies, rq_fifo_time(rq));
 }
@@ -954,7 +958,7 @@ static int as_fifo_expired(struct as_data *ad, int adir)
  * as_batch_expired returns true if the current batch has expired. A batch
  * is a set of reads or a set of writes.
  */
-static inline int as_batch_expired(struct as_data *ad)
+static inline int as_batch_expired(struct as_data *ad, struct as_queue *asq)
 {
 	if (ad->changed_batch || ad->new_batch)
 		return 0;
@@ -964,7 +968,7 @@ static inline int as_batch_expired(struct as_data *ad)
 		return time_after(jiffies, ad->current_batch_expires);
 
 	return time_after(jiffies, ad->current_batch_expires)
-		|| ad->current_write_count == 0;
+		|| asq->current_write_count == 0;
 }
 
 /*
@@ -973,6 +977,7 @@ static inline int as_batch_expired(struct as_data *ad)
 static void as_move_to_dispatch(struct as_data *ad, struct request *rq)
 {
 	const int data_dir = rq_is_sync(rq);
+	struct as_queue *asq = elv_get_sched_queue(ad->q, rq);
 
 	BUG_ON(RB_EMPTY_NODE(&rq->rb_node));
 
@@ -995,12 +1000,12 @@ static void as_move_to_dispatch(struct as_data *ad, struct request *rq)
 			ad->io_context = NULL;
 		}
 
-		if (ad->current_write_count != 0)
-			ad->current_write_count--;
+		if (asq->current_write_count != 0)
+			asq->current_write_count--;
 	}
 	ad->ioc_finished = 0;
 
-	ad->next_rq[data_dir] = as_find_next_rq(ad, rq);
+	asq->next_rq[data_dir] = as_find_next_rq(ad, asq, rq);
 
 	/*
 	 * take it off the sort and fifo list, add to dispatch queue
@@ -1024,9 +1029,16 @@ static void as_move_to_dispatch(struct as_data *ad, struct request *rq)
 static int as_dispatch_request(struct request_queue *q, int force)
 {
 	struct as_data *ad = q->elevator->elevator_data;
-	const int reads = !list_empty(&ad->fifo_list[BLK_RW_SYNC]);
-	const int writes = !list_empty(&ad->fifo_list[BLK_RW_ASYNC]);
 	struct request *rq;
+	struct as_queue *asq = elv_select_sched_queue(q, force);
+	int reads, writes;
+
+	if (!asq)
+		return 0;
+
+	reads = !list_empty(&asq->fifo_list[BLK_RW_SYNC]);
+	writes = !list_empty(&asq->fifo_list[BLK_RW_ASYNC]);
+
 
 	if (unlikely(force)) {
 		/*
@@ -1042,25 +1054,25 @@ static int as_dispatch_request(struct request_queue *q, int force)
 		ad->changed_batch = 0;
 		ad->new_batch = 0;
 
-		while (ad->next_rq[BLK_RW_SYNC]) {
-			as_move_to_dispatch(ad, ad->next_rq[BLK_RW_SYNC]);
+		while (asq->next_rq[BLK_RW_SYNC]) {
+			as_move_to_dispatch(ad, asq->next_rq[BLK_RW_SYNC]);
 			dispatched++;
 		}
-		ad->last_check_fifo[BLK_RW_SYNC] = jiffies;
+		asq->last_check_fifo[BLK_RW_SYNC] = jiffies;
 
-		while (ad->next_rq[BLK_RW_ASYNC]) {
-			as_move_to_dispatch(ad, ad->next_rq[BLK_RW_ASYNC]);
+		while (asq->next_rq[BLK_RW_ASYNC]) {
+			as_move_to_dispatch(ad, asq->next_rq[BLK_RW_ASYNC]);
 			dispatched++;
 		}
-		ad->last_check_fifo[BLK_RW_ASYNC] = jiffies;
+		asq->last_check_fifo[BLK_RW_ASYNC] = jiffies;
 
 		return dispatched;
 	}
 
 	/* Signal that the write batch was uncontended, so we can't time it */
 	if (ad->batch_data_dir == BLK_RW_ASYNC && !reads) {
-		if (ad->current_write_count == 0 || !writes)
-			ad->write_batch_idled = 1;
+		if (asq->current_write_count == 0 || !writes)
+			asq->write_batch_idled = 1;
 	}
 
 	if (!(reads || writes)
@@ -1069,14 +1081,14 @@ static int as_dispatch_request(struct request_queue *q, int force)
 		|| ad->changed_batch)
 		return 0;
 
-	if (!(reads && writes && as_batch_expired(ad))) {
+	if (!(reads && writes && as_batch_expired(ad, asq))) {
 		/*
 		 * batch is still running or no reads or no writes
 		 */
-		rq = ad->next_rq[ad->batch_data_dir];
+		rq = asq->next_rq[ad->batch_data_dir];
 
 		if (ad->batch_data_dir == BLK_RW_SYNC && ad->antic_expire) {
-			if (as_fifo_expired(ad, BLK_RW_SYNC))
+			if (as_fifo_expired(ad, asq, BLK_RW_SYNC))
 				goto fifo_expired;
 
 			if (as_can_anticipate(ad, rq)) {
@@ -1100,7 +1112,7 @@ static int as_dispatch_request(struct request_queue *q, int force)
 	 */
 
 	if (reads) {
-		BUG_ON(RB_EMPTY_ROOT(&ad->sort_list[BLK_RW_SYNC]));
+		BUG_ON(RB_EMPTY_ROOT(&asq->sort_list[BLK_RW_SYNC]));
 
 		if (writes && ad->batch_data_dir == BLK_RW_SYNC)
 			/*
@@ -1113,8 +1125,8 @@ static int as_dispatch_request(struct request_queue *q, int force)
 			ad->changed_batch = 1;
 		}
 		ad->batch_data_dir = BLK_RW_SYNC;
-		rq = rq_entry_fifo(ad->fifo_list[BLK_RW_SYNC].next);
-		ad->last_check_fifo[ad->batch_data_dir] = jiffies;
+		rq = rq_entry_fifo(asq->fifo_list[BLK_RW_SYNC].next);
+		asq->last_check_fifo[ad->batch_data_dir] = jiffies;
 		goto dispatch_request;
 	}
 
@@ -1124,7 +1136,7 @@ static int as_dispatch_request(struct request_queue *q, int force)
 
 	if (writes) {
 dispatch_writes:
-		BUG_ON(RB_EMPTY_ROOT(&ad->sort_list[BLK_RW_ASYNC]));
+		BUG_ON(RB_EMPTY_ROOT(&asq->sort_list[BLK_RW_ASYNC]));
 
 		if (ad->batch_data_dir == BLK_RW_SYNC) {
 			ad->changed_batch = 1;
@@ -1137,10 +1149,10 @@ dispatch_writes:
 			ad->new_batch = 0;
 		}
 		ad->batch_data_dir = BLK_RW_ASYNC;
-		ad->current_write_count = ad->write_batch_count;
-		ad->write_batch_idled = 0;
-		rq = rq_entry_fifo(ad->fifo_list[BLK_RW_ASYNC].next);
-		ad->last_check_fifo[BLK_RW_ASYNC] = jiffies;
+		asq->current_write_count = asq->write_batch_count;
+		asq->write_batch_idled = 0;
+		rq = rq_entry_fifo(asq->fifo_list[BLK_RW_ASYNC].next);
+		asq->last_check_fifo[BLK_RW_ASYNC] = jiffies;
 		goto dispatch_request;
 	}
 
@@ -1152,9 +1164,9 @@ dispatch_request:
 	 * If a request has expired, service it.
 	 */
 
-	if (as_fifo_expired(ad, ad->batch_data_dir)) {
+	if (as_fifo_expired(ad, asq, ad->batch_data_dir)) {
 fifo_expired:
-		rq = rq_entry_fifo(ad->fifo_list[ad->batch_data_dir].next);
+		rq = rq_entry_fifo(asq->fifo_list[ad->batch_data_dir].next);
 	}
 
 	if (ad->changed_batch) {
@@ -1187,6 +1199,7 @@ static void as_add_request(struct request_queue *q, struct request *rq)
 {
 	struct as_data *ad = q->elevator->elevator_data;
 	int data_dir;
+	struct as_queue *asq = elv_get_sched_queue(q, rq);
 
 	RQ_SET_STATE(rq, AS_RQ_NEW);
 
@@ -1205,7 +1218,7 @@ static void as_add_request(struct request_queue *q, struct request *rq)
 	 * set expire time and add to fifo list
 	 */
 	rq_set_fifo_time(rq, jiffies + ad->fifo_expire[data_dir]);
-	list_add_tail(&rq->queuelist, &ad->fifo_list[data_dir]);
+	list_add_tail(&rq->queuelist, &asq->fifo_list[data_dir]);
 
 	as_update_rq(ad, rq); /* keep state machine up to date */
 	RQ_SET_STATE(rq, AS_RQ_QUEUED);
@@ -1227,31 +1240,20 @@ static void as_deactivate_request(struct request_queue *q, struct request *rq)
 		atomic_inc(&RQ_IOC(rq)->aic->nr_dispatched);
 }
 
-/*
- * as_queue_empty tells us if there are requests left in the device. It may
- * not be the case that a driver can get the next request even if the queue
- * is not empty - it is used in the block layer to check for plugging and
- * merging opportunities
- */
-static int as_queue_empty(struct request_queue *q)
-{
-	struct as_data *ad = q->elevator->elevator_data;
-
-	return list_empty(&ad->fifo_list[BLK_RW_ASYNC])
-		&& list_empty(&ad->fifo_list[BLK_RW_SYNC]);
-}
-
 static int
 as_merge(struct request_queue *q, struct request **req, struct bio *bio)
 {
-	struct as_data *ad = q->elevator->elevator_data;
 	sector_t rb_key = bio->bi_sector + bio_sectors(bio);
 	struct request *__rq;
+	struct as_queue *asq = elv_get_sched_queue_current(q);
+
+	if (!asq)
+		return ELEVATOR_NO_MERGE;
 
 	/*
 	 * check for front merge
 	 */
-	__rq = elv_rb_find(&ad->sort_list[bio_data_dir(bio)], rb_key);
+	__rq = elv_rb_find(&asq->sort_list[bio_data_dir(bio)], rb_key);
 	if (__rq && elv_rq_merge_ok(__rq, bio)) {
 		*req = __rq;
 		return ELEVATOR_FRONT_MERGE;
@@ -1334,6 +1336,41 @@ static int as_may_queue(struct request_queue *q, int rw)
 	return ret;
 }
 
+/* Called with queue lock held */
+static void *as_alloc_as_queue(struct request_queue *q,
+				struct elevator_queue *eq, gfp_t gfp_mask)
+{
+	struct as_queue *asq;
+	struct as_data *ad = eq->elevator_data;
+
+	asq = kmalloc_node(sizeof(*asq), gfp_mask | __GFP_ZERO, q->node);
+	if (asq == NULL)
+		goto out;
+
+	INIT_LIST_HEAD(&asq->fifo_list[BLK_RW_SYNC]);
+	INIT_LIST_HEAD(&asq->fifo_list[BLK_RW_ASYNC]);
+	asq->sort_list[BLK_RW_SYNC] = RB_ROOT;
+	asq->sort_list[BLK_RW_ASYNC] = RB_ROOT;
+	if (ad)
+		asq->write_batch_count = ad->batch_expire[BLK_RW_ASYNC] / 10;
+	else
+		asq->write_batch_count = default_write_batch_expire / 10;
+
+	if (asq->write_batch_count < 2)
+		asq->write_batch_count = 2;
+out:
+	return asq;
+}
+
+static void as_free_as_queue(struct elevator_queue *e, void *sched_queue)
+{
+	struct as_queue *asq = sched_queue;
+
+	BUG_ON(!list_empty(&asq->fifo_list[BLK_RW_SYNC]));
+	BUG_ON(!list_empty(&asq->fifo_list[BLK_RW_ASYNC]));
+	kfree(asq);
+}
+
 static void as_exit_queue(struct elevator_queue *e)
 {
 	struct as_data *ad = e->elevator_data;
@@ -1341,9 +1378,6 @@ static void as_exit_queue(struct elevator_queue *e)
 	del_timer_sync(&ad->antic_timer);
 	cancel_work_sync(&ad->antic_work);
 
-	BUG_ON(!list_empty(&ad->fifo_list[BLK_RW_SYNC]));
-	BUG_ON(!list_empty(&ad->fifo_list[BLK_RW_ASYNC]));
-
 	put_io_context(ad->io_context);
 	kfree(ad);
 }
@@ -1367,10 +1401,6 @@ static void *as_init_queue(struct request_queue *q, struct elevator_queue *eq)
 	init_timer(&ad->antic_timer);
 	INIT_WORK(&ad->antic_work, as_work_handler);
 
-	INIT_LIST_HEAD(&ad->fifo_list[BLK_RW_SYNC]);
-	INIT_LIST_HEAD(&ad->fifo_list[BLK_RW_ASYNC]);
-	ad->sort_list[BLK_RW_SYNC] = RB_ROOT;
-	ad->sort_list[BLK_RW_ASYNC] = RB_ROOT;
 	ad->fifo_expire[BLK_RW_SYNC] = default_read_expire;
 	ad->fifo_expire[BLK_RW_ASYNC] = default_write_expire;
 	ad->antic_expire = default_antic_expire;
@@ -1378,9 +1408,6 @@ static void *as_init_queue(struct request_queue *q, struct elevator_queue *eq)
 	ad->batch_expire[BLK_RW_ASYNC] = default_write_batch_expire;
 
 	ad->current_batch_expires = jiffies + ad->batch_expire[BLK_RW_SYNC];
-	ad->write_batch_count = ad->batch_expire[BLK_RW_ASYNC] / 10;
-	if (ad->write_batch_count < 2)
-		ad->write_batch_count = 2;
 
 	return ad;
 }
@@ -1478,7 +1505,6 @@ static struct elevator_type iosched_as = {
 		.elevator_add_req_fn =		as_add_request,
 		.elevator_activate_req_fn =	as_activate_request,
 		.elevator_deactivate_req_fn = 	as_deactivate_request,
-		.elevator_queue_empty_fn =	as_queue_empty,
 		.elevator_completed_req_fn =	as_completed_request,
 		.elevator_former_req_fn =	elv_rb_former_request,
 		.elevator_latter_req_fn =	elv_rb_latter_request,
@@ -1486,6 +1512,8 @@ static struct elevator_type iosched_as = {
 		.elevator_init_fn =		as_init_queue,
 		.elevator_exit_fn =		as_exit_queue,
 		.trim =				as_trim,
+		.elevator_alloc_sched_queue_fn = as_alloc_as_queue,
+		.elevator_free_sched_queue_fn = as_free_as_queue,
 	},
 
 	.elevator_attrs = as_attrs,
diff --git a/block/deadline-iosched.c b/block/deadline-iosched.c
index 25af8b9..5b017da 100644
--- a/block/deadline-iosched.c
+++ b/block/deadline-iosched.c
@@ -23,25 +23,23 @@ static const int writes_starved = 2;    /* max times reads can starve a write */
 static const int fifo_batch = 16;       /* # of sequential requests treated as one
 				     by the above parameters. For throughput. */
 
-struct deadline_data {
-	/*
-	 * run time data
-	 */
-
+struct deadline_queue {
 	/*
 	 * requests (deadline_rq s) are present on both sort_list and fifo_list
 	 */
-	struct rb_root sort_list[2];	
+	struct rb_root sort_list[2];
 	struct list_head fifo_list[2];
-
 	/*
 	 * next in sort order. read, write or both are NULL
 	 */
 	struct request *next_rq[2];
 	unsigned int batching;		/* number of sequential requests made */
-	sector_t last_sector;		/* head position */
 	unsigned int starved;		/* times reads have starved writes */
+};
 
+struct deadline_data {
+	struct request_queue *q;
+	sector_t last_sector;		/* head position */
 	/*
 	 * settings that change how the i/o scheduler behaves
 	 */
@@ -56,7 +54,9 @@ static void deadline_move_request(struct deadline_data *, struct request *);
 static inline struct rb_root *
 deadline_rb_root(struct deadline_data *dd, struct request *rq)
 {
-	return &dd->sort_list[rq_data_dir(rq)];
+	struct deadline_queue *dq = elv_get_sched_queue(dd->q, rq);
+
+	return &dq->sort_list[rq_data_dir(rq)];
 }
 
 /*
@@ -87,9 +87,10 @@ static inline void
 deadline_del_rq_rb(struct deadline_data *dd, struct request *rq)
 {
 	const int data_dir = rq_data_dir(rq);
+	struct deadline_queue *dq = elv_get_sched_queue(dd->q, rq);
 
-	if (dd->next_rq[data_dir] == rq)
-		dd->next_rq[data_dir] = deadline_latter_request(rq);
+	if (dq->next_rq[data_dir] == rq)
+		dq->next_rq[data_dir] = deadline_latter_request(rq);
 
 	elv_rb_del(deadline_rb_root(dd, rq), rq);
 }
@@ -102,6 +103,7 @@ deadline_add_request(struct request_queue *q, struct request *rq)
 {
 	struct deadline_data *dd = q->elevator->elevator_data;
 	const int data_dir = rq_data_dir(rq);
+	struct deadline_queue *dq = elv_get_sched_queue(q, rq);
 
 	deadline_add_rq_rb(dd, rq);
 
@@ -109,7 +111,7 @@ deadline_add_request(struct request_queue *q, struct request *rq)
 	 * set expire time and add to fifo list
 	 */
 	rq_set_fifo_time(rq, jiffies + dd->fifo_expire[data_dir]);
-	list_add_tail(&rq->queuelist, &dd->fifo_list[data_dir]);
+	list_add_tail(&rq->queuelist, &dq->fifo_list[data_dir]);
 }
 
 /*
@@ -129,6 +131,11 @@ deadline_merge(struct request_queue *q, struct request **req, struct bio *bio)
 	struct deadline_data *dd = q->elevator->elevator_data;
 	struct request *__rq;
 	int ret;
+	struct deadline_queue *dq;
+
+	dq = elv_get_sched_queue_current(q);
+	if (!dq)
+		return ELEVATOR_NO_MERGE;
 
 	/*
 	 * check for front merge
@@ -136,7 +143,7 @@ deadline_merge(struct request_queue *q, struct request **req, struct bio *bio)
 	if (dd->front_merges) {
 		sector_t sector = bio->bi_sector + bio_sectors(bio);
 
-		__rq = elv_rb_find(&dd->sort_list[bio_data_dir(bio)], sector);
+		__rq = elv_rb_find(&dq->sort_list[bio_data_dir(bio)], sector);
 		if (__rq) {
 			BUG_ON(sector != blk_rq_pos(__rq));
 
@@ -207,10 +214,11 @@ static void
 deadline_move_request(struct deadline_data *dd, struct request *rq)
 {
 	const int data_dir = rq_data_dir(rq);
+	struct deadline_queue *dq = elv_get_sched_queue(dd->q, rq);
 
-	dd->next_rq[READ] = NULL;
-	dd->next_rq[WRITE] = NULL;
-	dd->next_rq[data_dir] = deadline_latter_request(rq);
+	dq->next_rq[READ] = NULL;
+	dq->next_rq[WRITE] = NULL;
+	dq->next_rq[data_dir] = deadline_latter_request(rq);
 
 	dd->last_sector = rq_end_sector(rq);
 
@@ -225,9 +233,9 @@ deadline_move_request(struct deadline_data *dd, struct request *rq)
  * deadline_check_fifo returns 0 if there are no expired requests on the fifo,
  * 1 otherwise. Requires !list_empty(&dd->fifo_list[data_dir])
  */
-static inline int deadline_check_fifo(struct deadline_data *dd, int ddir)
+static inline int deadline_check_fifo(struct deadline_queue *dq, int ddir)
 {
-	struct request *rq = rq_entry_fifo(dd->fifo_list[ddir].next);
+	struct request *rq = rq_entry_fifo(dq->fifo_list[ddir].next);
 
 	/*
 	 * rq is expired!
@@ -245,20 +253,26 @@ static inline int deadline_check_fifo(struct deadline_data *dd, int ddir)
 static int deadline_dispatch_requests(struct request_queue *q, int force)
 {
 	struct deadline_data *dd = q->elevator->elevator_data;
-	const int reads = !list_empty(&dd->fifo_list[READ]);
-	const int writes = !list_empty(&dd->fifo_list[WRITE]);
+	struct deadline_queue *dq = elv_select_sched_queue(q, force);
+	int reads, writes;
 	struct request *rq;
 	int data_dir;
 
+	if (!dq)
+		return 0;
+
+	reads = !list_empty(&dq->fifo_list[READ]);
+	writes = !list_empty(&dq->fifo_list[WRITE]);
+
 	/*
 	 * batches are currently reads XOR writes
 	 */
-	if (dd->next_rq[WRITE])
-		rq = dd->next_rq[WRITE];
+	if (dq->next_rq[WRITE])
+		rq = dq->next_rq[WRITE];
 	else
-		rq = dd->next_rq[READ];
+		rq = dq->next_rq[READ];
 
-	if (rq && dd->batching < dd->fifo_batch)
+	if (rq && dq->batching < dd->fifo_batch)
 		/* we have a next request are still entitled to batch */
 		goto dispatch_request;
 
@@ -268,9 +282,9 @@ static int deadline_dispatch_requests(struct request_queue *q, int force)
 	 */
 
 	if (reads) {
-		BUG_ON(RB_EMPTY_ROOT(&dd->sort_list[READ]));
+		BUG_ON(RB_EMPTY_ROOT(&dq->sort_list[READ]));
 
-		if (writes && (dd->starved++ >= dd->writes_starved))
+		if (writes && (dq->starved++ >= dd->writes_starved))
 			goto dispatch_writes;
 
 		data_dir = READ;
@@ -284,9 +298,9 @@ static int deadline_dispatch_requests(struct request_queue *q, int force)
 
 	if (writes) {
 dispatch_writes:
-		BUG_ON(RB_EMPTY_ROOT(&dd->sort_list[WRITE]));
+		BUG_ON(RB_EMPTY_ROOT(&dq->sort_list[WRITE]));
 
-		dd->starved = 0;
+		dq->starved = 0;
 
 		data_dir = WRITE;
 
@@ -299,48 +313,62 @@ dispatch_find_request:
 	/*
 	 * we are not running a batch, find best request for selected data_dir
 	 */
-	if (deadline_check_fifo(dd, data_dir) || !dd->next_rq[data_dir]) {
+	if (deadline_check_fifo(dq, data_dir) || !dq->next_rq[data_dir]) {
 		/*
 		 * A deadline has expired, the last request was in the other
 		 * direction, or we have run out of higher-sectored requests.
 		 * Start again from the request with the earliest expiry time.
 		 */
-		rq = rq_entry_fifo(dd->fifo_list[data_dir].next);
+		rq = rq_entry_fifo(dq->fifo_list[data_dir].next);
 	} else {
 		/*
 		 * The last req was the same dir and we have a next request in
 		 * sort order. No expired requests so continue on from here.
 		 */
-		rq = dd->next_rq[data_dir];
+		rq = dq->next_rq[data_dir];
 	}
 
-	dd->batching = 0;
+	dq->batching = 0;
 
 dispatch_request:
 	/*
 	 * rq is the selected appropriate request.
 	 */
-	dd->batching++;
+	dq->batching++;
 	deadline_move_request(dd, rq);
 
 	return 1;
 }
 
-static int deadline_queue_empty(struct request_queue *q)
+static void *deadline_alloc_deadline_queue(struct request_queue *q,
+				struct elevator_queue *eq, gfp_t gfp_mask)
 {
-	struct deadline_data *dd = q->elevator->elevator_data;
+	struct deadline_queue *dq;
 
-	return list_empty(&dd->fifo_list[WRITE])
-		&& list_empty(&dd->fifo_list[READ]);
+	dq = kmalloc_node(sizeof(*dq), gfp_mask | __GFP_ZERO, q->node);
+	if (dq == NULL)
+		goto out;
+
+	INIT_LIST_HEAD(&dq->fifo_list[READ]);
+	INIT_LIST_HEAD(&dq->fifo_list[WRITE]);
+	dq->sort_list[READ] = RB_ROOT;
+	dq->sort_list[WRITE] = RB_ROOT;
+out:
+	return dq;
+}
+
+static void deadline_free_deadline_queue(struct elevator_queue *e,
+						void *sched_queue)
+{
+	struct deadline_queue *dq = sched_queue;
+
+	kfree(dq);
 }
 
 static void deadline_exit_queue(struct elevator_queue *e)
 {
 	struct deadline_data *dd = e->elevator_data;
 
-	BUG_ON(!list_empty(&dd->fifo_list[READ]));
-	BUG_ON(!list_empty(&dd->fifo_list[WRITE]));
-
 	kfree(dd);
 }
 
@@ -356,10 +384,7 @@ deadline_init_queue(struct request_queue *q, struct elevator_queue *eq)
 	if (!dd)
 		return NULL;
 
-	INIT_LIST_HEAD(&dd->fifo_list[READ]);
-	INIT_LIST_HEAD(&dd->fifo_list[WRITE]);
-	dd->sort_list[READ] = RB_ROOT;
-	dd->sort_list[WRITE] = RB_ROOT;
+	dd->q = q;
 	dd->fifo_expire[READ] = read_expire;
 	dd->fifo_expire[WRITE] = write_expire;
 	dd->writes_starved = writes_starved;
@@ -446,13 +471,13 @@ static struct elevator_type iosched_deadline = {
 		.elevator_merge_req_fn =	deadline_merged_requests,
 		.elevator_dispatch_fn =		deadline_dispatch_requests,
 		.elevator_add_req_fn =		deadline_add_request,
-		.elevator_queue_empty_fn =	deadline_queue_empty,
 		.elevator_former_req_fn =	elv_rb_former_request,
 		.elevator_latter_req_fn =	elv_rb_latter_request,
 		.elevator_init_fn =		deadline_init_queue,
 		.elevator_exit_fn =		deadline_exit_queue,
+		.elevator_alloc_sched_queue_fn = deadline_alloc_deadline_queue,
+		.elevator_free_sched_queue_fn = deadline_free_deadline_queue,
 	},
-
 	.elevator_attrs = deadline_attrs,
 	.elevator_name = "deadline",
 	.elevator_owner = THIS_MODULE,
diff --git a/block/elevator.c b/block/elevator.c
index b2725cd..0b7c5a6 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -197,17 +197,54 @@ static struct elevator_type *elevator_get(const char *name)
 	return e;
 }
 
-static void *elevator_init_queue(struct request_queue *q,
-				 struct elevator_queue *eq)
+static void *
+elevator_init_data(struct request_queue *q, struct elevator_queue *eq)
 {
-	return eq->ops->elevator_init_fn(q, eq);
+	void *data = NULL;
+
+	if (eq->ops->elevator_init_fn) {
+		data = eq->ops->elevator_init_fn(q, eq);
+		if (data)
+			return data;
+		else
+			return ERR_PTR(-ENOMEM);
+	}
+
+	/* IO scheduler does not instanciate data (noop), it is not an error */
+	return NULL;
+}
+
+static void
+elevator_free_sched_queue(struct elevator_queue *eq, void *sched_queue)
+{
+	/* Not all io schedulers (cfq) strore sched_queue */
+	if (!sched_queue)
+		return;
+	eq->ops->elevator_free_sched_queue_fn(eq, sched_queue);
+}
+
+static void *
+elevator_alloc_sched_queue(struct request_queue *q, struct elevator_queue *eq)
+{
+	void *sched_queue = NULL;
+
+	if (eq->ops->elevator_alloc_sched_queue_fn) {
+		sched_queue = eq->ops->elevator_alloc_sched_queue_fn(q, eq,
+								GFP_KERNEL);
+		if (!sched_queue)
+			return ERR_PTR(-ENOMEM);
+
+	}
+
+	return sched_queue;
 }
 
 static void elevator_attach(struct request_queue *q, struct elevator_queue *eq,
-			   void *data)
+				void *data, void *sched_queue)
 {
 	q->elevator = eq;
 	eq->elevator_data = data;
+	eq->sched_queue = sched_queue;
 }
 
 static char chosen_elevator[16];
@@ -288,7 +325,7 @@ int elevator_init(struct request_queue *q, char *name)
 	struct elevator_type *e = NULL;
 	struct elevator_queue *eq;
 	int ret = 0;
-	void *data;
+	void *data = NULL, *sched_queue = NULL;
 
 	INIT_LIST_HEAD(&q->queue_head);
 	q->last_merge = NULL;
@@ -322,13 +359,21 @@ int elevator_init(struct request_queue *q, char *name)
 	if (!eq)
 		return -ENOMEM;
 
-	data = elevator_init_queue(q, eq);
-	if (!data) {
+	data = elevator_init_data(q, eq);
+
+	if (IS_ERR(data)) {
+		kobject_put(&eq->kobj);
+		return -ENOMEM;
+	}
+
+	sched_queue = elevator_alloc_sched_queue(q, eq);
+
+	if (IS_ERR(sched_queue)) {
 		kobject_put(&eq->kobj);
 		return -ENOMEM;
 	}
 
-	elevator_attach(q, eq, data);
+	elevator_attach(q, eq, data, sched_queue);
 	return ret;
 }
 EXPORT_SYMBOL(elevator_init);
@@ -336,6 +381,7 @@ EXPORT_SYMBOL(elevator_init);
 void elevator_exit(struct elevator_queue *e)
 {
 	mutex_lock(&e->sysfs_lock);
+	elevator_free_sched_queue(e, e->sched_queue);
 	elv_exit_fq_data(e);
 	if (e->ops->elevator_exit_fn)
 		e->ops->elevator_exit_fn(e);
@@ -1024,7 +1070,7 @@ EXPORT_SYMBOL_GPL(elv_unregister);
 static int elevator_switch(struct request_queue *q, struct elevator_type *new_e)
 {
 	struct elevator_queue *old_elevator, *e;
-	void *data;
+	void *data = NULL, *sched_queue = NULL;
 
 	/*
 	 * Allocate new elevator
@@ -1033,10 +1079,18 @@ static int elevator_switch(struct request_queue *q, struct elevator_type *new_e)
 	if (!e)
 		return 0;
 
-	data = elevator_init_queue(q, e);
-	if (!data) {
+	data = elevator_init_data(q, e);
+
+	if (IS_ERR(data)) {
 		kobject_put(&e->kobj);
-		return 0;
+		return -ENOMEM;
+	}
+
+	sched_queue = elevator_alloc_sched_queue(q, e);
+
+	if (IS_ERR(sched_queue)) {
+		kobject_put(&e->kobj);
+		return -ENOMEM;
 	}
 
 	/*
@@ -1053,7 +1107,7 @@ static int elevator_switch(struct request_queue *q, struct elevator_type *new_e)
 	/*
 	 * attach and start new elevator
 	 */
-	elevator_attach(q, e, data);
+	elevator_attach(q, e, data, sched_queue);
 
 	spin_unlock_irq(q->queue_lock);
 
@@ -1168,16 +1222,43 @@ struct request *elv_rb_latter_request(struct request_queue *q,
 }
 EXPORT_SYMBOL(elv_rb_latter_request);
 
-/* Get the io scheduler queue pointer. For cfq, it is stored in rq->ioq*/
+/* Get the io scheduler queue pointer. */
 void *elv_get_sched_queue(struct request_queue *q, struct request *rq)
 {
-	return elv_ioq_sched_queue(req_ioq(rq));
+	/*
+	 * io scheduler is not using fair queuing. Return sched_queue
+	 * pointer stored in elevator_queue. It will be null if io
+	 * scheduler never stored anything there to begin with (cfq)
+	 */
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return q->elevator->sched_queue;
+
+	/*
+	 * IO schedueler is using fair queuing infrasture. If io scheduler
+	 * has passed a non null rq, retrieve sched_queue pointer from
+	 * there. */
+	if (rq)
+		return elv_ioq_sched_queue(req_ioq(rq));
+
+	return NULL;
 }
 EXPORT_SYMBOL(elv_get_sched_queue);
 
 /* Select an ioscheduler queue to dispatch request from. */
 void *elv_select_sched_queue(struct request_queue *q, int force)
 {
+	if (!elv_iosched_fair_queuing_enabled(q->elevator))
+		return q->elevator->sched_queue;
+
 	return elv_ioq_sched_queue(elv_select_ioq(q, force));
 }
 EXPORT_SYMBOL(elv_select_sched_queue);
+
+/*
+ * Get the io scheduler queue pointer for current task.
+ */
+void *elv_get_sched_queue_current(struct request_queue *q)
+{
+	return q->elevator->sched_queue;
+}
+EXPORT_SYMBOL(elv_get_sched_queue_current);
diff --git a/block/noop-iosched.c b/block/noop-iosched.c
index 36fc210..d587832 100644
--- a/block/noop-iosched.c
+++ b/block/noop-iosched.c
@@ -7,7 +7,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 
-struct noop_data {
+struct noop_queue {
 	struct list_head queue;
 };
 
@@ -19,11 +19,14 @@ static void noop_merged_requests(struct request_queue *q, struct request *rq,
 
 static int noop_dispatch(struct request_queue *q, int force)
 {
-	struct noop_data *nd = q->elevator->elevator_data;
+	struct noop_queue *nq = elv_select_sched_queue(q, force);
 
-	if (!list_empty(&nd->queue)) {
+	if (!nq)
+		return 0;
+
+	if (!list_empty(&nq->queue)) {
 		struct request *rq;
-		rq = list_entry(nd->queue.next, struct request, queuelist);
+		rq = list_entry(nq->queue.next, struct request, queuelist);
 		list_del_init(&rq->queuelist);
 		elv_dispatch_sort(q, rq);
 		return 1;
@@ -33,24 +36,17 @@ static int noop_dispatch(struct request_queue *q, int force)
 
 static void noop_add_request(struct request_queue *q, struct request *rq)
 {
-	struct noop_data *nd = q->elevator->elevator_data;
+	struct noop_queue *nq = elv_get_sched_queue(q, rq);
 
-	list_add_tail(&rq->queuelist, &nd->queue);
-}
-
-static int noop_queue_empty(struct request_queue *q)
-{
-	struct noop_data *nd = q->elevator->elevator_data;
-
-	return list_empty(&nd->queue);
+	list_add_tail(&rq->queuelist, &nq->queue);
 }
 
 static struct request *
 noop_former_request(struct request_queue *q, struct request *rq)
 {
-	struct noop_data *nd = q->elevator->elevator_data;
+	struct noop_queue *nq = elv_get_sched_queue(q, rq);
 
-	if (rq->queuelist.prev == &nd->queue)
+	if (rq->queuelist.prev == &nq->queue)
 		return NULL;
 	return list_entry(rq->queuelist.prev, struct request, queuelist);
 }
@@ -58,30 +54,32 @@ noop_former_request(struct request_queue *q, struct request *rq)
 static struct request *
 noop_latter_request(struct request_queue *q, struct request *rq)
 {
-	struct noop_data *nd = q->elevator->elevator_data;
+	struct noop_queue *nq = elv_get_sched_queue(q, rq);
 
-	if (rq->queuelist.next == &nd->queue)
+	if (rq->queuelist.next == &nq->queue)
 		return NULL;
 	return list_entry(rq->queuelist.next, struct request, queuelist);
 }
 
-static void *noop_init_queue(struct request_queue *q, struct elevator_queue *eq)
+static void *noop_alloc_noop_queue(struct request_queue *q,
+				struct elevator_queue *eq, gfp_t gfp_mask)
 {
-	struct noop_data *nd;
+	struct noop_queue *nq;
 
-	nd = kmalloc_node(sizeof(*nd), GFP_KERNEL, q->node);
-	if (!nd)
-		return NULL;
-	INIT_LIST_HEAD(&nd->queue);
-	return nd;
+	nq = kmalloc_node(sizeof(*nq), gfp_mask | __GFP_ZERO, q->node);
+	if (nq == NULL)
+		goto out;
+
+	INIT_LIST_HEAD(&nq->queue);
+out:
+	return nq;
 }
 
-static void noop_exit_queue(struct elevator_queue *e)
+static void noop_free_noop_queue(struct elevator_queue *e, void *sched_queue)
 {
-	struct noop_data *nd = e->elevator_data;
+	struct noop_queue *nq = sched_queue;
 
-	BUG_ON(!list_empty(&nd->queue));
-	kfree(nd);
+	kfree(nq);
 }
 
 static struct elevator_type elevator_noop = {
@@ -89,11 +87,10 @@ static struct elevator_type elevator_noop = {
 		.elevator_merge_req_fn		= noop_merged_requests,
 		.elevator_dispatch_fn		= noop_dispatch,
 		.elevator_add_req_fn		= noop_add_request,
-		.elevator_queue_empty_fn	= noop_queue_empty,
 		.elevator_former_req_fn		= noop_former_request,
 		.elevator_latter_req_fn		= noop_latter_request,
-		.elevator_init_fn		= noop_init_queue,
-		.elevator_exit_fn		= noop_exit_queue,
+		.elevator_alloc_sched_queue_fn	= noop_alloc_noop_queue,
+		.elevator_free_sched_queue_fn	= noop_free_noop_queue,
 	},
 	.elevator_name = "noop",
 	.elevator_owner = THIS_MODULE,
diff --git a/include/linux/elevator.h b/include/linux/elevator.h
index 4414a61..2c6b0c7 100644
--- a/include/linux/elevator.h
+++ b/include/linux/elevator.h
@@ -30,8 +30,10 @@ typedef void (elevator_deactivate_req_fn) (struct request_queue *, struct reques
 typedef void *(elevator_init_fn) (struct request_queue *,
 					struct elevator_queue *);
 typedef void (elevator_exit_fn) (struct elevator_queue *);
-#ifdef CONFIG_ELV_FAIR_QUEUING
+typedef void* (elevator_alloc_sched_queue_fn) (struct request_queue *q,
+					struct elevator_queue *eq, gfp_t);
 typedef void (elevator_free_sched_queue_fn) (struct elevator_queue*, void *);
+#ifdef CONFIG_ELV_FAIR_QUEUING
 typedef void (elevator_active_ioq_set_fn) (struct request_queue*, void *, int);
 typedef void (elevator_active_ioq_reset_fn) (struct request_queue *, void*);
 typedef void (elevator_arm_slice_timer_fn) (struct request_queue*, void*);
@@ -68,8 +70,9 @@ struct elevator_ops
 	elevator_exit_fn *elevator_exit_fn;
 	void (*trim)(struct io_context *);
 
-#ifdef CONFIG_ELV_FAIR_QUEUING
+	elevator_alloc_sched_queue_fn *elevator_alloc_sched_queue_fn;
 	elevator_free_sched_queue_fn *elevator_free_sched_queue_fn;
+#ifdef CONFIG_ELV_FAIR_QUEUING
 	elevator_active_ioq_set_fn *elevator_active_ioq_set_fn;
 	elevator_active_ioq_reset_fn *elevator_active_ioq_reset_fn;
 
@@ -109,6 +112,7 @@ struct elevator_queue
 {
 	struct elevator_ops *ops;
 	void *elevator_data;
+	void *sched_queue;
 	struct kobject kobj;
 	struct elevator_type *elevator_type;
 	struct mutex sysfs_lock;
@@ -255,5 +259,6 @@ static inline int elv_iosched_fair_queuing_enabled(struct elevator_queue *e)
 #endif /* ELV_IOSCHED_FAIR_QUEUING */
 extern void *elv_get_sched_queue(struct request_queue *q, struct request *rq);
 extern void *elv_select_sched_queue(struct request_queue *q, int force);
+extern void *elv_get_sched_queue_current(struct request_queue *q);
 #endif /* CONFIG_BLOCK */
 #endif
-- 
1.6.0.6
