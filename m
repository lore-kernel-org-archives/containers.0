From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/24] io-controller: Core of the elevator fair queuing
Date: Wed, 19 Aug 2009 14:30:50 -0400
Message-ID: <20090819183050.GB4391__11912.9833220088$1250706736$gmane$org@redhat.com>
References: <1250451046-9966-1-git-send-email-vgoyal@redhat.com>
	<1250451046-9966-3-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1250451046-9966-3-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

On Sun, Aug 16, 2009 at 03:30:24PM -0400, Vivek Goyal wrote:
> o This is core of the io scheduler implemented at elevator layer. This is a mix
>   of cpu CFS scheduler and CFQ IO scheduler. Some of the bits from CFS have
>   to be derived so that we can support hierarchical scheduling. Without
>   cgroups or with-in group, we should essentially get same behavior as CFQ.
> 
> o This patch only shows non-hierarchical bits. Hierarhical code comes in later
>   patches.
> 
> o This code is the building base of introducing fair queuing logic in common
>   elevator layer so that it can be used by all the four IO schedulers.
> 
> Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
> Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
> Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---

One more fix for the scheduler. During testing I found that a writer can be
disptching for long time and not give reader as much disk time as CFQ does.
This patch fixes it. Will merge it in next posting.


o Requeue the aysnc ioq after one dispatch round. This emulates the CFQ
  behavior. This means that an async ioq will go back into the service tree
  with a new vtime (at the end of last entity) instead of incrementing the
  vtime as per the service received.

  CFQ expires the async queues if it has dispatched more than
  cfq_prio_to_maxrq() requests. All this happen with-in a jiffy and that would
  mean that vtime increase will be very less and async queue will continue
  to be served for long time.

  Hence like CFQ, requeue the aysnc queue after one dispatch round.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/elevator-fq.c |   52 +++++++++++++++++++++++++++++++---------------------
 1 file changed, 31 insertions(+), 21 deletions(-)

Index: linux13/block/elevator-fq.c
===================================================================
--- linux13.orig/block/elevator-fq.c	2009-08-17 16:16:06.000000000 -0400
+++ linux13/block/elevator-fq.c	2009-08-19 09:47:29.000000000 -0400
@@ -569,35 +569,37 @@ static struct io_entity *lookup_next_io_
 	return entity;
 }
 
-static void requeue_io_entity(struct io_entity *entity)
+static void requeue_io_entity(struct io_entity *entity, int add_front)
 {
 	struct io_service_tree *st = entity->st;
 	struct io_entity *next_entity;
 
-	next_entity = __lookup_next_io_entity(st);
+	if (add_front) {
+		next_entity = __lookup_next_io_entity(st);
 
-	/*
-	 * This is to emulate cfq like functionality where preemption can
-	 * happen with-in same class, like sync queue preempting async queue
-	 * May be this is not a very good idea from fairness point of view
-	 * as preempting queue gains share. Keeping it for now.
-	 *
-	 * This feature is also used by cfq close cooperator functionlity
-	 * where cfq selects a queue out of order to run next based on
-	 * close cooperator.
-	 */
+		/*
+		 * This is to emulate cfq like functionality where preemption
+		 * can happen with-in same class, like sync queue preempting
+		 * async queue.
+		 *
+		 * This feature is also used by cfq close cooperator
+		 * functionlity where cfq selects a queue out of order to run
+		 * next based on close cooperator.
+		 */
 
-	if (next_entity && next_entity != entity) {
-		__dequeue_io_entity(st, entity);
-		place_entity(st, entity, 1);
-		__enqueue_io_entity(st, entity, 1);
+		if (next_entity && next_entity == entity)
+			return;
 	}
+
+	__dequeue_io_entity(st, entity);
+	place_entity(st, entity, add_front);
+	__enqueue_io_entity(st, entity, add_front);
 }
 
-/* Requeue and ioq (already on the tree) to the front of service tree */
-static void requeue_ioq(struct io_queue *ioq)
+/* Requeue and ioq which is already on the tree */
+static void requeue_ioq(struct io_queue *ioq, int add_front)
 {
-	requeue_io_entity(&ioq->entity);
+	requeue_io_entity(&ioq->entity, add_front);
 }
 
 static void put_prev_io_entity(struct io_entity *entity)
@@ -2394,7 +2396,7 @@ io_queue *elv_set_active_ioq(struct requ
 	int coop = 0;
 
 	if (ioq) {
-		requeue_ioq(ioq);
+		requeue_ioq(ioq, 1);
 		/*
 		 * io scheduler selected the next queue for us. Pass this
 		 * this info back to io scheudler. cfq currently uses it
@@ -2557,8 +2559,16 @@ done:
 	ioq->nr_sectors = 0;
 
 	put_prev_ioq(ioq);
+
 	if (!ioq->nr_queued)
 		elv_del_ioq_busy(q->elevator, ioq);
+	else if (!elv_ioq_sync(ioq)) {
+		/*
+		 * Requeue async ioq so that these will be again placed at
+		 * the end of service tree giving a chance to sync queues.
+		 */
+		requeue_ioq(ioq, 0);
+	}
 }
 EXPORT_SYMBOL(elv_ioq_slice_expired);
 
@@ -2652,7 +2662,7 @@ static void elv_preempt_queue(struct req
 		 * so we know that it will be selected next.
 		 */
 
-		requeue_ioq(ioq);
+		requeue_ioq(ioq, 1);
 		ioq->slice_start = ioq->slice_end = 0;
 		elv_mark_ioq_slice_new(ioq);
 	}
