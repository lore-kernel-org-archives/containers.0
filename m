From: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 02/19] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Tue, 09 Jun 2009 16:45:14 +0800
Message-ID: <4A2E211A.3030303__3956.40225983716$1244537247$gmane$org@cn.fujitsu.com>
References: <1244513342-11758-1-git-send-email-vgoyal@redhat.com>
	<1244513342-11758-3-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1244513342-11758-3-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Vivek Goyal wrote:
...
> +
> +ssize_t elv_slice_idle_store(struct request_queue *q, const char *name,
> +			  size_t count)
> +{
> +	struct elv_fq_data *efqd;
> +	unsigned int data;
> +	unsigned long flags;
> +
> +	char *p = (char *)name;
> +
> +	data = simple_strtoul(p, &p, 10);
> +
> +	if (data < 0)

Hi Vivek,

data can never be less than zero. Same problems also exist for other sysfs entry.

Signed-off-by: Gui Jianfeng <guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/elevator-fq.c |   40 +++++++++++++---------------------------
 block/elevator-fq.h |    6 +++---
 2 files changed, 16 insertions(+), 30 deletions(-)

diff --git a/block/elevator-fq.c b/block/elevator-fq.c
index 42d4279..8027f4c 100644
--- a/block/elevator-fq.c
+++ b/block/elevator-fq.c
@@ -2643,32 +2643,27 @@ ssize_t elv_fairness_store(struct request_queue *q, const char *name,
 ssize_t elv_slice_idle_show(struct request_queue *q, char *name)
 {
 	struct elv_fq_data *efqd;
-	unsigned int data;
+	unsigned long data;
 	unsigned long flags;
 
 	spin_lock_irqsave(q->queue_lock, flags);
 	efqd = &q->elevator->efqd;
 	data = jiffies_to_msecs(efqd->elv_slice_idle);
 	spin_unlock_irqrestore(q->queue_lock, flags);
-	return sprintf(name, "%d\n", data);
+	return sprintf(name, "%lu\n", data);
 }
 
 ssize_t elv_slice_idle_store(struct request_queue *q, const char *name,
 			  size_t count)
 {
 	struct elv_fq_data *efqd;
-	unsigned int data;
+	unsigned long data;
 	unsigned long flags;
 
 	char *p = (char *)name;
 
 	data = simple_strtoul(p, &p, 10);
 
-	if (data < 0)
-		data = 0;
-	else if (data > INT_MAX)
-		data = INT_MAX;
-
 	data = msecs_to_jiffies(data);
 
 	spin_lock_irqsave(q->queue_lock, flags);
@@ -2683,32 +2678,27 @@ ssize_t elv_slice_idle_store(struct request_queue *q, const char *name,
 ssize_t elv_async_slice_idle_show(struct request_queue *q, char *name)
 {
 	struct elv_fq_data *efqd;
-	unsigned int data;
+	unsigned long data;
 	unsigned long flags;
 
 	spin_lock_irqsave(q->queue_lock, flags);
 	efqd = &q->elevator->efqd;
 	data = jiffies_to_msecs(efqd->elv_async_slice_idle);
 	spin_unlock_irqrestore(q->queue_lock, flags);
-	return sprintf(name, "%d\n", data);
+	return sprintf(name, "%lu\n", data);
 }
 
 ssize_t elv_async_slice_idle_store(struct request_queue *q, const char *name,
 			  size_t count)
 {
 	struct elv_fq_data *efqd;
-	unsigned int data;
+	unsigned long data;
 	unsigned long flags;
 
 	char *p = (char *)name;
 
 	data = simple_strtoul(p, &p, 10);
 
-	if (data < 0)
-		data = 0;
-	else if (data > INT_MAX)
-		data = INT_MAX;
-
 	data = msecs_to_jiffies(data);
 
 	spin_lock_irqsave(q->queue_lock, flags);
@@ -2730,24 +2720,22 @@ ssize_t elv_slice_sync_show(struct request_queue *q, char *name)
 	efqd = &q->elevator->efqd;
 	data = efqd->elv_slice[1];
 	spin_unlock_irqrestore(q->queue_lock, flags);
-	return sprintf(name, "%d\n", data);
+	return sprintf(name, "%lu\n", data);
 }
 
 ssize_t elv_slice_sync_store(struct request_queue *q, const char *name,
 			  size_t count)
 {
 	struct elv_fq_data *efqd;
-	unsigned int data;
+	unsigned long data;
 	unsigned long flags;
 
 	char *p = (char *)name;
 
 	data = simple_strtoul(p, &p, 10);
 
-	if (data < 0)
-		data = 0;
 	/* 100ms is the limit for now*/
-	else if (data > 100)
+	if (data > 100)
 		data = 100;
 
 	spin_lock_irqsave(q->queue_lock, flags);
@@ -2762,31 +2750,29 @@ ssize_t elv_slice_sync_store(struct request_queue *q, const char *name,
 ssize_t elv_slice_async_show(struct request_queue *q, char *name)
 {
 	struct elv_fq_data *efqd;
-	unsigned int data;
+	unsigned long data;
 	unsigned long flags;
 
 	spin_lock_irqsave(q->queue_lock, flags);
 	efqd = &q->elevator->efqd;
 	data = efqd->elv_slice[0];
 	spin_unlock_irqrestore(q->queue_lock, flags);
-	return sprintf(name, "%d\n", data);
+	return sprintf(name, "%lu\n", data);
 }
 
 ssize_t elv_slice_async_store(struct request_queue *q, const char *name,
 			  size_t count)
 {
 	struct elv_fq_data *efqd;
-	unsigned int data;
+	unsigned long data;
 	unsigned long flags;
 
 	char *p = (char *)name;
 
 	data = simple_strtoul(p, &p, 10);
 
-	if (data < 0)
-		data = 0;
 	/* 100ms is the limit for now*/
-	else if (data > 100)
+	if (data > 100)
 		data = 100;
 
 	spin_lock_irqsave(q->queue_lock, flags);
diff --git a/block/elevator-fq.h b/block/elevator-fq.h
index 4fe843a..46e4dbc 100644
--- a/block/elevator-fq.h
+++ b/block/elevator-fq.h
@@ -338,13 +338,13 @@ struct elv_fq_data {
 	 * have any notion of anticipation/idling. As of now, these are the
 	 * users of this functionality.
 	 */
-	unsigned int elv_slice_idle;
+	unsigned long elv_slice_idle;
 	/* idle slice for async queue */
-	unsigned int elv_async_slice_idle;
+	unsigned long elv_async_slice_idle;
 	struct timer_list idle_slice_timer;
 	struct work_struct unplug_work;
 
-	unsigned int elv_slice[2];
+	unsigned long elv_slice[2];
 
 	/* Fields for keeping track of average disk rate */
 	unsigned long rate_sectors; /* number of sectors finished */
-- 
1.5.4.rc3
