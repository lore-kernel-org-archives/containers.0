From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v15 2/7] res_counter: introduce ratelimiting attributes
Date: Tue, 28 Apr 2009 16:39:29 +0200
Message-ID: <20090428143927.GA990__16918.4498642155$1240929667$gmane$org@linux>
References: <1240908234-15434-1-git-send-email-righi.andrea@gmail.com>
	<1240908234-15434-3-git-send-email-righi.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1240908234-15434-3-git-send-email-righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Subject: io-throttle: reduce the size of res_counter

Reduce the size of struct res_counter after the introduction of
ratelimited resources:

- replace policy with a more generic unsigned long flags and encode the
  throttling policy using a single bit of flags

- remove the attribute capacity: max_usage is not used in ratelimited
  resources and capacity is not used in all the other cases (it has been
  introduced only for token-bucket ratelimited resources), so just merge
  capacitiy into max_usage

On a 64-bit architecture:

  vanilla:					sizeof(struct res_counter) = 48
  with-io-throttle:				sizeof(struct res_counter) = 72
  with-io-throttle-and-reduced-res-counter:	sizeof(struct res_counter) = 64

[ This patch must be applied on top of io-throttle v15. ]

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/blk-io-throttle.c     |   14 ++++++++------
 include/linux/res_counter.h |   40 +++++++++++++++++++++++++---------------
 kernel/res_counter.c        |   23 ++++++-----------------
 3 files changed, 39 insertions(+), 38 deletions(-)

diff --git a/block/blk-io-throttle.c b/block/blk-io-throttle.c
index 8dc2c93..a7edc47 100644
--- a/block/blk-io-throttle.c
+++ b/block/blk-io-throttle.c
@@ -257,10 +257,11 @@ static void iothrottle_show_limit(struct seq_file *m, dev_t dev,
 {
 	if (!res->limit)
 		return;
-	seq_printf(m, "%u %u %llu %llu %lli %llu %li\n",
+	/* maj min bw-limit ratelimit-policy usage bucket-size delta-time */
+	seq_printf(m, "%u %u %llu %lu %lli %llu %li\n",
 		MAJOR(dev), MINOR(dev),
-		res->limit, res->policy,
-		(long long)res->usage, res->capacity,
+		res->limit, res_counter_flagged(res, RES_COUNTER_POLICY),
+		(long long)res->usage, res->max_usage,
 		jiffies_to_clock_t(res_counter_ratelimit_delta_t(res)));
 }
 
@@ -361,7 +362,7 @@ static dev_t devname2dev_t(const char *buf)
  */
 static int iothrottle_parse_args(char *buf, size_t nbytes, int filetype,
 			dev_t *dev, unsigned long long *iolimit,
-			unsigned long long *strategy,
+			unsigned long *strategy,
 			unsigned long long *bucket_size)
 {
 	char *p;
@@ -396,7 +397,7 @@ static int iothrottle_parse_args(char *buf, size_t nbytes, int filetype,
 	/* throttling strategy (leaky bucket / token bucket) */
 	if (!s[2])
 		return -EINVAL;
-	ret = strict_strtoull(s[2], 10, strategy);
+	ret = strict_strtoul(s[2], 10, strategy);
 	if (ret < 0)
 		return ret;
 	switch (*strategy) {
@@ -429,7 +430,8 @@ static int iothrottle_write(struct cgroup *cgrp, struct cftype *cft,
 	struct iothrottle *iot;
 	struct iothrottle_node *n, *newn = NULL;
 	dev_t dev;
-	unsigned long long iolimit, strategy, bucket_size;
+	unsigned long long iolimit, bucket_size;
+	unsigned long strategy;
 	char *buf;
 	size_t nbytes = strlen(buffer);
 	int ret = 0;
diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 9bed6af..c18cee2 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -16,6 +16,15 @@
 #include <linux/cgroup.h>
 #include <linux/jiffies.h>
 
+/*
+ * res_counter flags
+ *
+ * bit 0 -- ratelimiting policy: leaky bucket / token bucket
+ */
+#define RES_COUNTER_POLICY	0
+
+#define res_counter_flagged(rc, flag)	((rc)->flags & (1 << (flag)))
+
 /* The various policies that can be used for ratelimiting resources */
 #define	RATELIMIT_LEAKY_BUCKET	0
 #define	RATELIMIT_TOKEN_BUCKET	1
@@ -23,35 +32,32 @@
 /**
  * struct res_counter - the core object to account cgroup resources
  *
+ * @flags:	resource counter attributes
  * @usage:	the current resource consumption level
- * @max_usage:	the maximal value of the usage from the counter creation
+ * @max_usage:	the maximal value of the usage from the counter creation,
+ *		or the maximum capacity of the resource (for ratelimited
+ *		resources)
  * @limit:	the limit that usage cannot be exceeded
  * @failcnt:	the number of unsuccessful attempts to consume the resource
- * @policy:	the limiting policy / algorithm
- * @capacity:	the maximum capacity of the resource
  * @timestamp:	timestamp of the last accounted resource request
- * @lock:	the lock to protect all of the above.
- *		The routines below consider this to be IRQ-safe
+ * @lock:	the lock to protect all of the above
+ * @parent:	Parent counter, used for hierarchial resource accounting
  *
  * The cgroup that wishes to account for some resource may include this counter
  * into its structures and use the helpers described beyond.
  */
 struct res_counter {
+	unsigned long flags;
 	unsigned long long usage;
 	unsigned long long max_usage;
 	unsigned long long limit;
 	unsigned long long failcnt;
-	unsigned long long policy;
-	unsigned long long capacity;
 	unsigned long long timestamp;
 	/*
 	 * the lock to protect all of the above.
 	 * the routines below consider this to be IRQ-safe
 	 */
 	spinlock_t lock;
-	/*
-	 * Parent counter, used for hierarchial resource accounting
-	 */
 	struct res_counter *parent;
 };
 
@@ -90,9 +96,7 @@ enum {
 	RES_USAGE,
 	RES_MAX_USAGE,
 	RES_LIMIT,
-	RES_POLICY,
 	RES_TIMESTAMP,
-	RES_CAPACITY,
 	RES_FAILCNT,
 };
 
@@ -183,15 +187,21 @@ static inline void res_counter_reset_failcnt(struct res_counter *cnt)
 
 static inline int
 res_counter_ratelimit_set_limit(struct res_counter *cnt,
-			unsigned long long policy,
+			unsigned long policy,
 			unsigned long long limit, unsigned long long max)
 {
 	unsigned long flags;
 
 	spin_lock_irqsave(&cnt->lock, flags);
 	cnt->limit = limit;
-	cnt->capacity = max;
-	cnt->policy = policy;
+	/*
+	 * In ratelimited res_counter max_usage is used to save the token
+	 * bucket capacity.
+	 */
+	cnt->max_usage = max;
+	cnt->flags = 0;
+	if (policy == RATELIMIT_TOKEN_BUCKET)
+		set_bit(RES_COUNTER_POLICY, &cnt->flags);
 	cnt->timestamp = get_jiffies_64();
 	cnt->usage = 0;
 	spin_unlock_irqrestore(&cnt->lock, flags);
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index 6f882c6..f6d97a2 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -21,7 +21,6 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 	spin_lock_init(&counter->lock);
 	counter->limit = (unsigned long long)LLONG_MAX;
 	counter->parent = parent;
-	counter->capacity = (unsigned long long)LLONG_MAX;
 	counter->timestamp = get_jiffies_64();
 }
 
@@ -102,12 +101,8 @@ res_counter_member(struct res_counter *counter, int member)
 		return &counter->max_usage;
 	case RES_LIMIT:
 		return &counter->limit;
-	case RES_POLICY:
-		return &counter->policy;
 	case RES_TIMESTAMP:
 		return &counter->timestamp;
-	case RES_CAPACITY:
-		return &counter->capacity;
 	case RES_FAILCNT:
 		return &counter->failcnt;
 	};
@@ -205,7 +200,7 @@ ratelimit_token_bucket(struct res_counter *res, ssize_t val)
 	res->timestamp = get_jiffies_64();
 	tok = (long long)res->usage * MSEC_PER_SEC;
 	if (delta) {
-		long long max = (long long)res->capacity * MSEC_PER_SEC;
+		long long max = (long long)res->max_usage * MSEC_PER_SEC;
 
 		tok += delta * res->limit;
 		tok = max_t(long long, tok, max);
@@ -221,18 +216,12 @@ res_counter_ratelimit_sleep(struct res_counter *res, ssize_t val)
 	unsigned long flags;
 
 	spin_lock_irqsave(&res->lock, flags);
-	if (res->limit)
-		switch (res->policy) {
-		case RATELIMIT_LEAKY_BUCKET:
-			sleep = ratelimit_leaky_bucket(res, val);
-			break;
-		case RATELIMIT_TOKEN_BUCKET:
+	if (res->limit) {
+		if (res_counter_flagged(res, RES_COUNTER_POLICY))
 			sleep = ratelimit_token_bucket(res, val);
-			break;
-		default:
-			WARN_ON(1);
-			break;
-		}
+		else
+			sleep = ratelimit_leaky_bucket(res, val);
+	}
 	spin_unlock_irqrestore(&res->lock, flags);
 	return sleep;
 }
