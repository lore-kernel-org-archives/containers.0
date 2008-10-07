From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH -mm 2/6] introduce ratelimiting attributes and functionality
	to res_counter
Date: Tue,  7 Oct 2008 12:03:34 +0200
Message-ID: <1223373818-13687-3-git-send-email-righi.andrea__39040.9065563746$1223374096$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <>
References: <>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, roberto-5KDOxZqKugI@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Introduce attributes and functions in res_counter to implement throttling-based
cgroup subsystems.

The following attributes have been added to struct res_counter:
 * @policy:     the limiting policy / algorithm
 * @capacity:   the maximum capacity of the resource
 * @timestamp:  timestamp of the last accounted resource request

Currently the available policies are: token-bucket and leaky-bucket and the
attribute @capacity is only used by token-bucket policy (to represent the
bucket size).

The following function has been implemented to return the amount of time a
cgroup should sleep to remain within the defined resource limits.

  unsigned long long
  res_counter_ratelimit_sleep(struct res_counter *res, ssize_t val);

[ Note: only the interfaces needed by the cgroup IO controller are implemented
right now ]

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/res_counter.h |   69 ++++++++++++++++++++++++++++++----------
 kernel/res_counter.c        |   73 ++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 124 insertions(+), 18 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 0ab55c4..80b9ab8 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -14,30 +14,36 @@
  */
 
 #include <linux/cgroup.h>
+#include <linux/jiffies.h>
 
-/*
- * The core object. the cgroup that wishes to account for some
- * resource may include this counter into its structures and use
- * the helpers described beyond
- */
+/* The various policies that can be used for ratelimiting resources */
+#define	RATELIMIT_LEAKY_BUCKET	0
+#define	RATELIMIT_TOKEN_BUCKET	1
 
+/**
+ * struct res_counter - the core object to account cgroup resources
+ *
+ * @usage:	the current resource consumption level
+ * @max_usage:	the maximal value of the usage from the counter creation
+ * @limit:	the limit that usage cannot be exceeded
+ * @failcnt:	the number of unsuccessful attempts to consume the resource
+ * @policy:	the limiting policy / algorithm
+ * @capacity:	the maximum capacity of the resource
+ * @timestamp:	timestamp of the last accounted resource request
+ * @lock:	the lock to protect all of the above.
+ *		The routines below consider this to be IRQ-safe
+ *
+ * The cgroup that wishes to account for some resource may include this counter
+ * into its structures and use the helpers described beyond.
+ */
 struct res_counter {
-	/*
-	 * the current resource consumption level
-	 */
 	unsigned long long usage;
-	/*
-	 * the maximal value of the usage from the counter creation
-	 */
 	unsigned long long max_usage;
-	/*
-	 * the limit that usage cannot exceed
-	 */
 	unsigned long long limit;
-	/*
-	 * the number of unsuccessful attempts to consume the resource
-	 */
 	unsigned long long failcnt;
+	unsigned long long policy;
+	unsigned long long capacity;
+	unsigned long long timestamp;
 	/*
 	 * the lock to protect all of the above.
 	 * the routines below consider this to be IRQ-safe
@@ -80,6 +86,9 @@ enum {
 	RES_USAGE,
 	RES_MAX_USAGE,
 	RES_LIMIT,
+	RES_POLICY,
+	RES_TIMESTAMP,
+	RES_CAPACITY,
 	RES_FAILCNT,
 };
 
@@ -126,6 +135,15 @@ static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
 	return false;
 }
 
+static inline unsigned long long
+res_counter_ratelimit_delta_t(struct res_counter *res)
+{
+	return (long long)get_jiffies_64() - (long long)res->timestamp;
+}
+
+unsigned long long
+res_counter_ratelimit_sleep(struct res_counter *res, ssize_t val);
+
 /*
  * Helper function to detect if the cgroup is within it's limit or
  * not. It's currently called from cgroup_rss_prepare()
@@ -159,6 +177,23 @@ static inline void res_counter_reset_failcnt(struct res_counter *cnt)
 	spin_unlock_irqrestore(&cnt->lock, flags);
 }
 
+static inline int
+res_counter_ratelimit_set_limit(struct res_counter *cnt,
+			unsigned long long policy,
+			unsigned long long limit, unsigned long long max)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	cnt->limit = limit;
+	cnt->capacity = max;
+	cnt->policy = policy;
+	cnt->timestamp = get_jiffies_64();
+	cnt->usage = 0;
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return 0;
+}
+
 static inline int res_counter_set_limit(struct res_counter *cnt,
 		unsigned long long limit)
 {
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index f275c8e..e55c674 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -9,6 +9,7 @@
 
 #include <linux/types.h>
 #include <linux/parser.h>
+#include <linux/jiffies.h>
 #include <linux/fs.h>
 #include <linux/slab.h>
 #include <linux/res_counter.h>
@@ -19,6 +20,8 @@ void res_counter_init(struct res_counter *counter)
 {
 	spin_lock_init(&counter->lock);
 	counter->limit = (unsigned long long)LLONG_MAX;
+	counter->capacity = (unsigned long long)LLONG_MAX;
+	counter->timestamp = get_jiffies_64();
 }
 
 int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
@@ -62,7 +65,6 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
 	spin_unlock_irqrestore(&counter->lock, flags);
 }
 
-
 static inline unsigned long long *
 res_counter_member(struct res_counter *counter, int member)
 {
@@ -73,6 +75,12 @@ res_counter_member(struct res_counter *counter, int member)
 		return &counter->max_usage;
 	case RES_LIMIT:
 		return &counter->limit;
+	case RES_POLICY:
+		return &counter->policy;
+	case RES_TIMESTAMP:
+		return &counter->timestamp;
+	case RES_CAPACITY:
+		return &counter->capacity;
 	case RES_FAILCNT:
 		return &counter->failcnt;
 	};
@@ -137,3 +145,66 @@ int res_counter_write(struct res_counter *counter, int member,
 	spin_unlock_irqrestore(&counter->lock, flags);
 	return 0;
 }
+
+static unsigned long long
+ratelimit_leaky_bucket(struct res_counter *res, ssize_t val)
+{
+	unsigned long long delta, t;
+
+	res->usage += val;
+	delta = res_counter_ratelimit_delta_t(res);
+	if (!delta)
+		return 0;
+	t = res->usage * USEC_PER_SEC;
+	t = usecs_to_jiffies(div_u64(t, res->limit));
+	if (t > delta)
+		return t - delta;
+	/* Reset i/o statistics */
+	res->usage = 0;
+	res->timestamp = get_jiffies_64();
+	return 0;
+}
+
+static unsigned long long
+ratelimit_token_bucket(struct res_counter *res, ssize_t val)
+{
+	unsigned long long delta;
+	long long tok;
+
+	res->usage -= val;
+	delta = jiffies_to_msecs(res_counter_ratelimit_delta_t(res));
+	res->timestamp = get_jiffies_64();
+	tok = (long long)res->usage * MSEC_PER_SEC;
+	if (delta) {
+		long long max = (long long)res->capacity * MSEC_PER_SEC;
+
+		tok += delta * res->limit;
+		if (tok > max)
+			tok = max;
+		res->usage = (unsigned long long)div_s64(tok, MSEC_PER_SEC);
+	}
+	return (tok < 0) ? msecs_to_jiffies(div_u64(-tok, res->limit)) : 0;
+}
+
+unsigned long long
+res_counter_ratelimit_sleep(struct res_counter *res, ssize_t val)
+{
+	unsigned long long sleep = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&res->lock, flags);
+	if (res->limit)
+		switch (res->policy) {
+		case RATELIMIT_LEAKY_BUCKET:
+			sleep = ratelimit_leaky_bucket(res, val);
+			break;
+		case RATELIMIT_TOKEN_BUCKET:
+			sleep = ratelimit_token_bucket(res, val);
+			break;
+		default:
+			WARN_ON(1);
+			break;
+		}
+	spin_unlock_irqrestore(&res->lock, flags);
+	return sleep;
+}
-- 
1.5.4.3
