From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 24/24] map sync requests to group using bio tracking info
Date: Fri, 24 Jul 2009 16:27:54 -0400
Message-ID: <1248467274-32073-25-git-send-email-vgoyal__42481.5311715522$1248467602$gmane$org@redhat.com>
References: <1248467274-32073-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248467274-32073-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org
Cc: paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

o sync requests are mapped to the cgroup submitting tasks belongs to. This
  is an experimental patch where sync requets can be mapped to the group
  using bio tracking information and not submitting task's context.

o This patch implements this functionality only for noop, deadline and AS.

o Introducing this patch for experimental purposes to see if it is really
  meaningful or not.

o This behavior is turned on by setting /sys/block/<disk>/queue/iosched/map_sync  varibale.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/as-iosched.c       |    1 +
 block/deadline-iosched.c |    1 +
 block/elevator-fq.c      |    7 ++++++-
 block/elevator-fq.h      |    9 +++++++++
 block/noop-iosched.c     |    1 +
 5 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/block/as-iosched.c b/block/as-iosched.c
index 1282a78..d412e36 100644
--- a/block/as-iosched.c
+++ b/block/as-iosched.c
@@ -1768,6 +1768,7 @@ static struct elv_fs_entry as_attrs[] = {
 	ELV_ATTR(fairness),
 	ELV_ATTR(slice_sync),
 	ELV_ATTR(group_idle),
+	ELV_ATTR(map_sync),
 #endif
 	__ATTR_NULL
 };
diff --git a/block/deadline-iosched.c b/block/deadline-iosched.c
index 9811a0e..b69c29f 100644
--- a/block/deadline-iosched.c
+++ b/block/deadline-iosched.c
@@ -465,6 +465,7 @@ static struct elv_fs_entry deadline_attrs[] = {
 	ELV_ATTR(fairness),
 	ELV_ATTR(slice_sync),
 	ELV_ATTR(group_idle),
+	ELV_ATTR(map_sync),
 #endif
 	__ATTR_NULL
 };
diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 746c548..66b10eb 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -2073,6 +2073,7 @@ struct io_group *io_get_io_group_bio(struct request_queue *q, struct bio *bio,
 					int create)
 {
 	struct page *page = NULL;
+	struct elv_fq_data *efqd = &q->elevator->efqd;
 
 	/*
 	 * Determine the group from task context. Even calls from
@@ -2091,7 +2092,7 @@ struct io_group *io_get_io_group_bio(struct request_queue *q, struct bio *bio,
 	}
 
 	/* Map the sync bio to the right group using task context */
-	if (elv_bio_sync(bio))
+	if (elv_bio_sync(bio) && !efqd->map_sync)
 		goto sync;
 
 #ifdef CONFIG_TRACK_ASYNC_CONTEXT
@@ -2812,6 +2813,8 @@ SHOW_FUNCTION(elv_slice_async_show, efqd->elv_slice[0], 1);
 EXPORT_SYMBOL(elv_slice_async_show);
 SHOW_FUNCTION(elv_fairness_show, efqd->fairness, 0);
 EXPORT_SYMBOL(elv_fairness_show);
+SHOW_FUNCTION(elv_map_sync_show, efqd->map_sync, 0);
+EXPORT_SYMBOL(elv_map_sync_show);
 #undef SHOW_FUNCTION
 
 #define STORE_FUNCTION(__FUNC, __PTR, MIN, MAX, __CONV)			\
@@ -2838,6 +2841,8 @@ STORE_FUNCTION(elv_slice_async_store, &efqd->elv_slice[0], 1, UINT_MAX, 1);
 EXPORT_SYMBOL(elv_slice_async_store);
 STORE_FUNCTION(elv_fairness_store, &efqd->fairness, 0, 1, 0);
 EXPORT_SYMBOL(elv_fairness_store);
+STORE_FUNCTION(elv_map_sync_store, &efqd->map_sync, 0, 1, 0);
+EXPORT_SYMBOL(elv_map_sync_store);
 #undef STORE_FUNCTION
 
 void elv_schedule_dispatch(struct request_queue *q)
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 185550e..0581e55 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -347,6 +347,12 @@ struct elv_fq_data {
 	 * queue before new queue is scheduled in
 	 */
 	unsigned int fairness;
+
+	/*
+	 * Get io group bio belongs to from bio and not from submitting task
+	 * context
+	 */
+	unsigned int map_sync;
 };
 
 /* Logging facilities. */
@@ -551,6 +557,9 @@ extern void elv_put_iog(struct io_group *iog);
 extern ssize_t elv_group_idle_show(struct elevator_queue *q, char *name);
 extern ssize_t elv_group_idle_store(struct elevator_queue *q, const char *name,
 					size_t count);
+extern ssize_t elv_map_sync_show(struct elevator_queue *q, char *name);
+extern ssize_t elv_map_sync_store(struct elevator_queue *q, const char *name,
+					size_t count);
 static inline void elv_get_iog(struct io_group *iog)
 {
 	atomic_inc(&iog->ref);
diff --git a/block/noop-iosched.c b/block/noop-iosched.c
index 5811ea2..190f37b 100644
--- a/block/noop-iosched.c
+++ b/block/noop-iosched.c
@@ -87,6 +87,7 @@ static struct elv_fs_entry noop_attrs[] = {
 	ELV_ATTR(fairness),
 	ELV_ATTR(slice_sync),
 	ELV_ATTR(group_idle),
+	ELV_ATTR(map_sync),
 	__ATTR_NULL
 };
 #endif
-- 
1.6.0.6
