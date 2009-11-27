From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH RFC v1 2/3] res_counter: implement thresholds
Date: Fri, 27 Nov 2009 13:55:03 +0200
Message-ID: <8524ba285f6dd59cda939c28da523f344cdab3da.1259321503.git.kirill__27509.5094032169$1259323380$gmane$org@shutemov.name>
References: <cover.1259255307.git.kirill@shutemov.name>
	<bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259321503.git.kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <bc4dc055a7307c8667da85a4d4d9d5d189af27d5.1259321503.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
In-Reply-To: <cover.1259321503.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
References: <cover.1259321503.git.kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

It allows to setup two thresholds: one above current usage and one
below. Callback threshold_notifier() will be called if a threshold is
crossed.

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
---
 include/linux/res_counter.h |   44 +++++++++++++++++++++++++++++++++++++++++++
 kernel/res_counter.c        |    4 +++
 2 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index fcb9884..bca99a5 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -9,6 +9,10 @@
  *
  * Author: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
  *
+ * Thresholds support
+ * Copyright (C) 2009 Nokia Corporation
+ * Author: Kirill A. Shutemov
+ *
  * See Documentation/cgroups/resource_counter.txt for more
  * info about what this counter is.
  */
@@ -42,6 +46,13 @@ struct res_counter {
 	 * the number of unsuccessful attempts to consume the resource
 	 */
 	unsigned long long failcnt;
+
+	unsigned long long threshold_above;
+	unsigned long long threshold_below;
+	void (*threshold_notifier)(struct res_counter *counter,
+			unsigned long long usage,
+			unsigned long long threshold);
+
 	/*
 	 * the lock to protect all of the above.
 	 * the routines below consider this to be IRQ-safe
@@ -145,6 +156,20 @@ static inline bool res_counter_soft_limit_check_locked(struct res_counter *cnt)
 	return false;
 }
 
+static inline void res_counter_threshold_notify_locked(struct res_counter *cnt)
+{
+	if (cnt->usage >= cnt->threshold_above) {
+		cnt->threshold_notifier(cnt, cnt->usage, cnt->threshold_above);
+		return;
+	}
+
+	if (cnt->usage < cnt->threshold_below) {
+		cnt->threshold_notifier(cnt, cnt->usage, cnt->threshold_below);
+		return;
+	}
+}
+
+
 /**
  * Get the difference between the usage and the soft limit
  * @cnt: The counter
@@ -238,4 +263,23 @@ res_counter_set_soft_limit(struct res_counter *cnt,
 	return 0;
 }
 
+static inline int
+res_counter_set_thresholds(struct res_counter *cnt,
+		unsigned long long threshold_above,
+		unsigned long long threshold_below)
+{
+	unsigned long flags;
+	int ret = -EINVAL;
+
+	spin_lock_irqsave(&cnt->lock, flags);
+	if ((cnt->usage < threshold_above) &&
+			(cnt->usage >= threshold_below)) {
+		cnt->threshold_above = threshold_above;
+		cnt->threshold_below = threshold_below;
+		ret = 0;
+	}
+	spin_unlock_irqrestore(&cnt->lock, flags);
+	return ret;
+}
+
 #endif
diff --git a/kernel/res_counter.c b/kernel/res_counter.c
index bcdabf3..646c29c 100644
--- a/kernel/res_counter.c
+++ b/kernel/res_counter.c
@@ -20,6 +20,8 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent)
 	spin_lock_init(&counter->lock);
 	counter->limit = RESOURCE_MAX;
 	counter->soft_limit = RESOURCE_MAX;
+	counter->threshold_above = RESOURCE_MAX;
+	counter->threshold_below = 0ULL;
 	counter->parent = parent;
 }
 
@@ -33,6 +35,7 @@ int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
 	counter->usage += val;
 	if (counter->usage > counter->max_usage)
 		counter->max_usage = counter->usage;
+	res_counter_threshold_notify_locked(counter);
 	return 0;
 }
 
@@ -73,6 +76,7 @@ void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
 		val = counter->usage;
 
 	counter->usage -= val;
+	res_counter_threshold_notify_locked(counter);
 }
 
 void res_counter_uncharge(struct res_counter *counter, unsigned long val)
-- 
1.6.5.3
