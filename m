From: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/2] the core of range-bw
Date: Mon, 4 May 2009 19:57:04 +0900
Message-ID: <2891419e0905040357r2b3f684r26d099785ae81539__13261.4822513007$1241434952$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, guijianfeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
List-Id: containers.vger.kernel.org

This is the core of the range-bw I/O controller

From: Dong-Jae Kang <djkang-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org> or  <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Range-BW is an I/O controller supports the process group-based range bandwidth
according to the priority or importance of the group.
Range bandwidth means the predicable I/O bandwidth with minimum and
maximum value
defined by administrator.

Signed-off-by: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Chei-Yol Kim <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>

===========================================================================================
diff -urN linux-2.6.29-orig/drivers/md/dm-ioband-ctl.c
linux-2.6.29-patch/drivers/md/dm-ioband-ctl.c
--- linux-2.6.29-orig/drivers/md/dm-ioband-ctl.c	2009-04-20
18:16:00.000000000 +0900
+++ linux-2.6.29-patch/drivers/md/dm-ioband-ctl.c	2009-05-04
16:43:12.000000000 +0900
@@ -789,6 +789,17 @@
 }

 /*
+ * Check the overflow of maximum bandwidth limit
+ */
+static int is_no_io_mode(struct ioband_group *gp)
+{
+	if (gp->c_io_mode == NO_IO_MODE)
+		return 1;
+
+	return 0;
+}
+
+/*
  * Start to control the bandwidth once the number of uncompleted BIOs
  * exceeds the value of "io_throttle".
  */
@@ -799,9 +810,25 @@
 	struct ioband_device *dp = gp->c_banddev;
 	unsigned long flags;
 	int direct;
+	unsigned long now, time_step;

 	spin_lock_irqsave(&dp->g_lock, flags);

+	gp = ioband_group_get(gp, bio);
+
+	/*
+	 * This part is for controlling the max bandwidth of range-bw policy
+	 */
+
+	if (is_no_io_mode(gp)) {
+		now = jiffies;
+		if (time_after(dp->g_next_time_period, now)) {
+			time_step = dp->g_next_time_period - now;
+			range_bw_timer_register(gp->c_timer, (time_step +
TIME_COMPENSATOR), (unsigned long)gp);
+			wait_event_lock_irq(gp->c_max_bw_over_waitq, !is_no_io_mode(gp),
dp->g_lock, do_nothing());
+		}
+	}
+
 	/*
 	 * The device is suspended while some of the ioband device
 	 * configurations are being changed.
@@ -811,7 +838,6 @@
 				    !is_device_suspended(dp), dp->g_lock,
 				    do_nothing());

-	gp = ioband_group_get(gp, bio);
 	prevent_burst_bios(gp, bio);
 	if (should_pushback_bio(gp)) {
 		spin_unlock_irqrestore(&dp->g_lock, flags);
diff -urN linux-2.6.29-orig/drivers/md/dm-ioband.h
linux-2.6.29-patch/drivers/md/dm-ioband.h
--- linux-2.6.29-orig/drivers/md/dm-ioband.h	2009-04-20 18:16:00.000000000 +0900
+++ linux-2.6.29-patch/drivers/md/dm-ioband.h	2009-05-04
16:44:03.000000000 +0900
@@ -8,6 +8,10 @@

 #include <linux/version.h>
 #include <linux/wait.h>
+#include <linux/jiffies.h>
+#include <linux/random.h>
+#include <linux/time.h>
+#include <linux/timer.h>

 #define DM_MSG_PREFIX "ioband"

@@ -16,6 +20,12 @@
 #define IOBAND_NAME_MAX 31
 #define IOBAND_ID_ANY (-1)

+#define MAX_BW_OVER             1
+#define MAX_BW_UNDER            0
+#define NO_IO_MODE              4
+
+#define TIME_COMPENSATOR        10
+
 struct ioband_group;

 struct ioband_device {
@@ -74,6 +84,17 @@
 	int g_token_left;
 	/* left-over tokens from the previous epoch */
 	int g_token_extra;
+
+	/* members for range-bw policy */
+	int     g_min_bw_total;
+	int     g_max_bw_total;
+	unsigned long   g_next_time_period;
+	int     g_time_period_expired;
+	struct ioband_group *g_running_gp;
+	int     g_total_min_bw_token;
+	int     g_consumed_min_bw_token;
+	int     g_io_mode;
+
 };

 struct ioband_group_stat {
@@ -110,8 +131,31 @@

 	/* rfu */
 	/* struct bio_list	c_ordered_tag_bios; */
+
+	/* members for range-bw policy */
+	wait_queue_head_t       c_max_bw_over_waitq;
+	spinlock_t      c_lock;
+	struct timer_list *c_timer;
+	int     timer_set;
+	int     c_min_bw;
+	int     c_max_bw;
+	int     c_time_slice_expired;
+	int     c_min_bw_token;
+	int     c_max_bw_token;
+	int     c_consumed_min_bw_token;
+	int     c_is_over_max_bw;
+	int     c_io_mode;
+	unsigned long   c_time_slice;
+	unsigned long   c_time_slice_start;
+	unsigned long   c_time_slice_end;
+	int     c_wait_p_count;
+
 };

+extern void range_bw_timeover(unsigned long gp);
+extern void range_bw_timer_register(struct timer_list *ptimer,
unsigned long timeover, unsigned long gp);
+extern int policy_range_bw_init(struct ioband_device *dp, int argc,
char **argv);
+
 #define IOBAND_URGENT 1

 #define DEV_BIO_BLOCKED		1
diff -urN linux-2.6.29-orig/drivers/md/dm-ioband-policy.c
linux-2.6.29-patch/drivers/md/dm-ioband-policy.c
--- linux-2.6.29-orig/drivers/md/dm-ioband-policy.c	2009-04-20
18:16:00.000000000 +0900
+++ linux-2.6.29-patch/drivers/md/dm-ioband-policy.c	2009-05-04
15:57:10.000000000 +0900
@@ -453,5 +453,6 @@
 	{"default", policy_default_init},
 	{"weight", policy_weight_init},
 	{"weight-iosize", w2_policy_weight_init},
+	{"range-bw", policy_range_bw_init},
 	{NULL, policy_default_init}
 };
diff -urN linux-2.6.29-orig/drivers/md/dm-ioband-rangebw.c
linux-2.6.29-patch/drivers/md/dm-ioband-rangebw.c
--- linux-2.6.29-orig/drivers/md/dm-ioband-rangebw.c	1970-01-01
09:00:00.000000000 +0900
+++ linux-2.6.29-patch/drivers/md/dm-ioband-rangebw.c	2009-05-04
16:59:20.000000000 +0900
@@ -0,0 +1,578 @@
+/*
+ * dm-ioband-rangebw.c
+ *
+ * This is a I/O control policy to support the Range Bandwidth in Disk I/O.
+ * And this policy is for dm-ioband controller by Ryo Tsuruta,
Hirokazu Takahashi
+ *
+ * Copyright (C) 2008 - 2011 Electronics and Telecommunications
Research Institute(ETRI)
+ *
+ * This program is free software. you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License(GPL) as published by
+ * the Free Software Foundation, either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * Contact Information:
+ * Dong-Jae, Kang <djkang-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>, Chei-Yol,Kim <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>,
+ * Sung-In,Jung <sijung-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>
+ */
+
+#include <linux/bio.h>
+#include <linux/workqueue.h>
+#include <linux/rbtree.h>
+#include "dm.h"
+#include "dm-bio-list.h"
+#include "dm-ioband.h"
+
+/*
+ * Functions for Range Bandwidth(range-bw) policy based on
+ * the time slice and token.
+ */
+#define DEFAULT_BUCKET          2
+#define DEFAULT_TOKENPOOL       2048
+
+#define DEFAULT_MIN_BW		0
+#define TIME_SLICE_EXPIRED      1
+#define TIME_SLICE_NOT_EXPIRED  0
+
+#define MINBW_IO_MODE           0
+#define LEFTOVER_IO_MODE        1
+#define RANGE_IO_MODE           2
+#define DEFAULT_IO_MODE         3
+#define NO_IO_MODE 	        4
+
+#define MINBW_PRIO_BASE         10
+#define OVER_IO_RATE		4
+
+static const int time_slice_base = HZ / 10;
+static const int range_time_slice_base = HZ / 50;
+
+/*
+ * g_restart_bios function for range-bw policy
+ */
+static int range_bw_restart_bios(struct ioband_device *dp)
+{
+	return 1;
+}
+
+/*
+ * Allocate the time slice when IO mode is MINBW_IO_MODE,
+ * RANGE_IO_MODE or LEFTOVER_IO_MODE
+ */
+static int set_time_slice(struct ioband_group *gp)
+{
+	struct ioband_device *dp = gp->c_banddev;
+	int dp_io_mode, gp_io_mode;
+	unsigned long now = jiffies;
+
+	dp_io_mode = dp->g_io_mode;
+	gp_io_mode = gp->c_io_mode;
+
+	gp->c_time_slice_start = now;
+
+	if (dp_io_mode == LEFTOVER_IO_MODE) {
+		gp->c_time_slice_end = now + gp->c_time_slice;
+		return 0;
+	}
+
+	if (gp_io_mode == MINBW_IO_MODE)
+		gp->c_time_slice_end = now + gp->c_time_slice;
+	else if (gp_io_mode == RANGE_IO_MODE)
+		gp->c_time_slice_end = now + range_time_slice_base;
+	else if (gp_io_mode == DEFAULT_IO_MODE)
+		gp->c_time_slice_end = now + time_slice_base;
+	else if (gp_io_mode == NO_IO_MODE) {
+		gp->c_time_slice_end = 0;
+		gp->c_time_slice_expired = TIME_SLICE_EXPIRED;
+		return 0;
+	}
+
+	gp->c_time_slice_expired = TIME_SLICE_NOT_EXPIRED;
+
+	return 0;
+}
+
+/*
+ * Calculate the priority of given ioband_group
+ */
+static int range_bw_priority(struct ioband_group *gp)
+{
+	struct ioband_device *dp = gp->c_banddev;
+	int prio = 0;
+
+	if (dp->g_io_mode == LEFTOVER_IO_MODE) {
+		prio = random32() % MINBW_PRIO_BASE;
+		if (prio == 0)
+			prio = 1;
+	} else if (gp->c_io_mode == MINBW_IO_MODE) {
+		prio = (gp->c_min_bw_token - gp->c_consumed_min_bw_token) * MINBW_PRIO_BASE;
+	} else if (gp->c_io_mode == DEFAULT_IO_MODE) {
+		prio = MINBW_PRIO_BASE;
+	} else if (gp->c_io_mode == RANGE_IO_MODE) {
+		prio = MINBW_PRIO_BASE / 2;
+	} else {
+		prio = 0;
+	}
+
+	return prio;
+}
+
+/*
+ * Check whether this group has right to issue an I/O in range-bw policy mode.
+ *  Return 0 if it doesn't have right, otherwise return the non-zero value.
+ */
+static int has_right_to_issue(struct ioband_group *gp)
+{
+	struct ioband_device *dp = gp->c_banddev;
+	int prio;
+
+	if (gp->c_prio_blocked > 0 || gp->c_blocked - gp->c_prio_blocked > 0) {
+		prio = range_bw_priority(gp);
+		if (prio <= 0)
+			return 1;
+		return prio;
+	}
+
+	if (gp == dp->g_running_gp) {
+
+		if (gp->c_time_slice_expired == TIME_SLICE_EXPIRED) {
+
+			gp->c_time_slice_expired = TIME_SLICE_NOT_EXPIRED;
+			gp->c_time_slice_end = 0;
+
+			return 0;
+		}
+
+		if (gp->c_time_slice_end == 0)
+			set_time_slice(gp);
+
+		return range_bw_priority(gp);
+
+	}
+
+	dp->g_running_gp = gp;
+	set_time_slice(gp);
+
+	return range_bw_priority(gp);
+}
+
+/*
+ * Reset all variables related with range-bw token and time slice
+ */
+static int reset_range_bw_token(struct ioband_group *gp, unsigned long now)
+{
+	struct ioband_device *dp = gp->c_banddev;
+	struct ioband_group *p;
+
+	list_for_each_entry(p, &dp->g_groups, c_list) {
+		p->c_consumed_min_bw_token = 0;
+		p->c_is_over_max_bw = MAX_BW_UNDER;
+		if (p->c_io_mode != DEFAULT_IO_MODE)
+			p->c_io_mode = MINBW_IO_MODE;
+	}
+
+	dp->g_consumed_min_bw_token = 0;
+
+	dp->g_next_time_period = now + HZ;
+	dp->g_time_period_expired = TIME_SLICE_NOT_EXPIRED;
+	dp->g_io_mode = MINBW_IO_MODE;
+
+	list_for_each_entry(p, &dp->g_groups, c_list) {
+		if (waitqueue_active(&p->c_max_bw_over_waitq))
+			wake_up_all(&p->c_max_bw_over_waitq);
+	}
+	return 0;
+}
+
+/*
+ * Use tokens(Increase the number of consumed token) to issue an I/O
for guranteeing the range-bw.
+ * and check the expiration of local and global time slice, and
overflow of max bw
+ */
+static int range_bw_consume_token(struct ioband_group *gp, int count, int flag)
+{
+	struct ioband_device *dp = gp->c_banddev;
+	struct ioband_group *p;
+	unsigned long now = jiffies;
+	int io_mode;
+
+	dp->g_current = gp;
+
+	if (dp->g_next_time_period == 0) {
+		dp->g_next_time_period = now + HZ;
+		dp->g_time_period_expired = TIME_SLICE_NOT_EXPIRED;
+	}
+
+	if (time_after(now, dp->g_next_time_period)) {
+		reset_range_bw_token(gp, now);
+	} else {
+		gp->c_consumed_min_bw_token += count;
+		dp->g_consumed_min_bw_token += count;
+
+		if (gp->c_max_bw > 0 && gp->c_consumed_min_bw_token >= gp->c_max_bw_token) {
+			gp->c_is_over_max_bw = MAX_BW_OVER;
+			gp->c_io_mode = NO_IO_MODE;
+			return R_YIELD;
+		}
+
+		if (gp->c_io_mode != RANGE_IO_MODE && gp->c_min_bw_token <=
gp->c_consumed_min_bw_token) {
+			gp->c_io_mode = RANGE_IO_MODE;
+
+			if (dp->g_total_min_bw_token <= dp->g_consumed_min_bw_token) {
+				list_for_each_entry(p, &dp->g_groups, c_list) {
+					if (p->c_io_mode == RANGE_IO_MODE || p->c_io_mode == DEFAULT_IO_MODE) {
+						io_mode = 1;
+					} else {
+						io_mode = 0;
+						break;
+					}
+				}
+
+				if (io_mode && dp->g_io_mode == MINBW_IO_MODE)
+					dp->g_io_mode = LEFTOVER_IO_MODE;
+			}
+		}
+	}
+
+	if (gp->c_time_slice_end != 0 && time_after(now, gp->c_time_slice_end)) {
+		gp->c_time_slice_expired = TIME_SLICE_EXPIRED;
+		return R_YIELD;
+	}
+
+	return R_OK;
+}
+
+/*
+ * Check if this group is able to receive a new bio.
+ * in range bw policy, we only check that ioband device should be blocked
+ */
+static int range_bw_queue_full(struct ioband_group *gp)
+{
+	return (gp->c_blocked >= gp->c_limit);
+}
+
+/*
+ * Convert the bw valuse to the number of bw token
+ * bw : Kbyte unit bandwidth
+ * token_base : the number of tokens used for one 1Kbyte-size IO
+ * -- Attention : Currently, We support the 512byte or 1Kbyte per 1 token
+ */
+static int convert_bw_to_token(int bw, int token_unit)
+{
+	int	token;
+	int	token_base;
+
+	token_base = (1 << token_unit) / 4;
+	token = bw * token_base;
+
+	return token;
+}
+
+
+/*
+ * Allocate the time slice for MINBW_IO_MODE to each group
+ */
+static void range_bw_time_slice_init(struct ioband_group *gp)
+{
+	struct ioband_device *dp = gp->c_banddev;
+	struct ioband_group *p;
+	int seed = 0;
+
+	if (gp->c_min_bw == 0 || gp->c_max_bw == 0)
+		seed = 1;
+	else
+		seed = 2;
+
+	list_for_each_entry(p, &dp->g_groups, c_list) {
+
+		if (dp->g_min_bw_total == 0 && dp->g_max_bw_total == 0)
+			p->c_time_slice = time_slice_base;
+		else if (dp->g_min_bw_total != 0)
+			p->c_time_slice = time_slice_base + ((time_slice_base *
((p->c_min_bw + p->c_max_bw) / seed)) / dp->g_min_bw_total);
+		else
+			p->c_time_slice = time_slice_base + ((time_slice_base *
((p->c_min_bw + p->c_max_bw) / seed)) / dp->g_max_bw_total);
+	}
+}
+
+
+/*
+ * Allocate the min_bw and min_bw_token to the given group
+ */
+static void set_min_bw(struct ioband_group *gp, int new)
+{
+	struct ioband_device *dp = gp->c_banddev;
+	struct ioband_group *p;
+	int	token_unit;
+
+	dp->g_min_bw_total += (new - gp->c_min_bw);
+	gp->c_min_bw = new;
+
+	if (new)
+		gp->c_io_mode = MINBW_IO_MODE;
+	else
+		gp->c_io_mode = DEFAULT_IO_MODE;
+
+	range_bw_time_slice_init(gp);
+
+	token_unit = dp->g_token_unit;
+	gp->c_min_bw_token = convert_bw_to_token(gp->c_min_bw, token_unit);
+	dp->g_total_min_bw_token = convert_bw_to_token(dp->g_min_bw_total,
token_unit);
+
+	if (dp->g_min_bw_total == 0) {
+		list_for_each_entry(p, &dp->g_groups, c_list)
+			p->c_limit = 1;
+	} else {
+		list_for_each_entry(p, &dp->g_groups, c_list) {
+			p->c_limit = (dp->g_io_limit[0] + dp->g_io_limit[1]) *
+				p->c_min_bw / dp->g_min_bw_total /
+				OVER_IO_RATE + 1;
+		}
+	}
+
+	return;
+}
+
+/*
+ * Allocate the max_bw and max_bw_token to the pointed group
+ */
+static void set_max_bw(struct ioband_group *gp, int new)
+{
+	struct ioband_device *dp = gp->c_banddev;
+	int	token_unit;
+
+	token_unit = dp->g_token_unit;
+
+	dp->g_max_bw_total += (new - gp->c_max_bw);
+	gp->c_max_bw = new;
+	gp->c_max_bw_token = convert_bw_to_token(new, token_unit);
+
+	range_bw_time_slice_init(gp);
+
+	return;
+
+}
+
+static void init_range_bw_token_bucket(struct ioband_device *dp, int val)
+{
+	dp->g_token_bucket = ((dp->g_io_limit[0] + dp->g_io_limit[1]) *
+				 DEFAULT_BUCKET) << dp->g_token_unit;
+	if (!val)
+		val = DEFAULT_TOKENPOOL << dp->g_token_unit;
+	if (val < dp->g_token_bucket)
+		val = dp->g_token_bucket;
+	dp->g_carryover = val/dp->g_token_bucket;
+	dp->g_token_left = 0;
+}
+
+static int policy_range_bw_param(struct ioband_group *gp, char *cmd,
char *value)
+{
+	long val;
+	int r = 0, err;
+
+	err = strict_strtol(value, 0, &val);
+
+	if (!strcmp(cmd, "min-bw")) {
+		if (!err && 0 <= val && val <= (INT_MAX / 2))
+			set_min_bw(gp, val);
+		else
+			r = -EINVAL;
+	} else if (!strcmp(cmd, "max-bw")) {
+		if ((!err && 0 <= val && val <= (INT_MAX / 2) && gp->c_min_bw <=
val) || val == 0)
+			set_max_bw(gp, val);
+		else
+			r = -EINVAL;
+	} else {
+		r = -EINVAL;
+	}
+
+	return r;
+}
+
+static int policy_range_bw_ctr(struct ioband_group *gp, char *arg)
+{
+	int ret;
+
+	if (!arg)
+		arg = __stringify(DEFAULT_MIN_BW);
+
+	init_waitqueue_head(&gp->c_max_bw_over_waitq);
+	spin_lock_init(&gp->c_lock);
+
+	gp->c_min_bw = 0;
+	gp->c_max_bw = 0;
+	gp->c_io_mode  = DEFAULT_IO_MODE;
+	gp->c_time_slice_expired = TIME_SLICE_NOT_EXPIRED;
+	gp->c_min_bw_token = 0;
+	gp->c_max_bw_token = 0;
+	gp->c_consumed_min_bw_token = 0;
+	gp->c_is_over_max_bw = MAX_BW_UNDER;
+	gp->c_time_slice_start = 0;
+	gp->c_time_slice_end = 0;
+	gp->c_wait_p_count = 0;
+
+	gp->c_time_slice = time_slice_base;
+
+	gp->c_timer = kmalloc(sizeof(struct timer_list), GFP_KERNEL);
+	if (gp->c_timer == NULL)
+		return -EINVAL;
+	memset(gp->c_timer, 0, sizeof(struct timer_list));
+	gp->timer_set = 0;
+
+	ret = policy_range_bw_param(gp, "min-bw", arg);
+
+	return ret;
+}
+
+static void policy_range_bw_dtr(struct ioband_group *gp)
+{
+	struct ioband_device *dp = gp->c_banddev;
+
+	set_min_bw(gp, 0);
+	gp->c_time_slice = 0;
+	set_max_bw(gp, 0);
+
+	dp->g_running_gp = NULL;
+
+	if (gp->c_timer != NULL) {
+		del_timer(gp->c_timer);
+		kfree(gp->c_timer);
+	}
+}
+
+static void policy_range_bw_show(struct ioband_group *gp, int *szp,
+					char *result, unsigned int maxlen)
+{
+	struct ioband_group *p;
+	struct ioband_device *dp = gp->c_banddev;
+	struct rb_node *node;
+	int sz = *szp; /* used in DMEMIT() */
+
+	DMEMIT(" %d :%d", dp->g_token_bucket * dp->g_carryover, gp->c_min_bw);
+
+	for (node = rb_first(&gp->c_group_root); node; node = rb_next(node)) {
+		p = rb_entry(node, struct ioband_group, c_group_node);
+		DMEMIT(" %d:%d:%d", p->c_id, p->c_min_bw, p->c_max_bw);
+	}
+	*szp = sz;
+}
+
+static int range_bw_prepare_token(struct ioband_group *gp, struct bio
*bio, int flag)
+{
+	struct ioband_device *dp = gp->c_banddev;
+	int unit;
+	int bio_count;
+	int token_count = 0;
+
+	unit = (1 << dp->g_token_unit);
+	bio_count = bio_sectors(bio);
+
+	if (unit == 8)
+		token_count = bio_count;
+	else if (unit == 4)
+		token_count = bio_count / 2;
+	else if (unit == 2)
+		token_count = bio_count / 4;
+	else if (unit == 1)
+		token_count = bio_count / 8;
+
+	return range_bw_consume_token(gp, token_count, flag);
+}
+
+void range_bw_timer_register(struct timer_list *ptimer, unsigned long
timeover, unsigned long  gp)
+{
+	struct ioband_group *group = (struct ioband_group *)gp;
+
+	if (group->timer_set == 0) {
+		init_timer(ptimer);
+		ptimer->expires = get_jiffies_64() + timeover;
+		ptimer->data = gp;
+		ptimer->function = range_bw_timeover;
+		add_timer(ptimer);
+		group->timer_set = 1;
+	}
+}
+
+/*
+ * Timer Handler function to protect the all processes's hanging in
lower min-bw configuration
+ */
+void range_bw_timeover(unsigned long gp)
+{
+	struct ioband_group *group = (struct ioband_group *)gp;
+
+	if (group->c_is_over_max_bw == MAX_BW_OVER)
+		group->c_is_over_max_bw = MAX_BW_UNDER;
+
+	if (group->c_io_mode == NO_IO_MODE)
+		group->c_io_mode = MINBW_IO_MODE;
+
+	if (waitqueue_active(&group->c_max_bw_over_waitq))
+		wake_up_all(&group->c_max_bw_over_waitq);
+
+	group->timer_set = 0;
+}
+
+/*
+ *  <Method>      <description>
+ * g_can_submit   : To determine whether a given group has the right to
+ *                  submit BIOs. The larger the return value the higher the
+ *                  priority to submit. Zero means it has no right.
+ * g_prepare_bio  : Called right before submitting each BIO.
+ * g_restart_bios : Called if this ioband device has some BIOs blocked but none
+ *                  of them can be submitted now. This method has to
+ *                  reinitialize the data to restart to submit BIOs and return
+ *                  0 or 1.
+ *                  The return value 0 means that it has become able to submit
+ *                  them now so that this ioband device will continue its work.
+ *                  The return value 1 means that it is still unable to submit
+ *                  them so that this device will stop its work. And this
+ *                  policy module has to reactivate the device when it gets
+ *                  to be able to submit BIOs.
+ * g_hold_bio     : To hold a given BIO until it is submitted.
+ *                  The default function is used when this method is undefined.
+ * g_pop_bio      : To select and get the best BIO to submit.
+ * g_group_ctr    : To initalize the policy own members of struct ioband_group.
+ * g_group_dtr    : Called when struct ioband_group is removed.
+ * g_set_param    : To update the policy own date.
+ *                  The parameters can be passed through "dmsetup message"
+ *                  command.
+ * g_should_block : Called every time this ioband device receive a BIO.
+ *                  Return 1 if a given group can't receive any more BIOs,
+ *                  otherwise return 0.
+ * g_show         : Show the configuration.
+ */
+
+int policy_range_bw_init(struct ioband_device *dp,
+					int argc, char **argv)
+{
+	long val;
+	int r = 0;
+
+	if (argc < 1)
+		val = 0;
+	else {
+		r = strict_strtol(argv[0], 0, &val);
+		if (r || val < 0)
+			return -EINVAL;
+	}
+
+	dp->g_can_submit = has_right_to_issue;
+	dp->g_prepare_bio = range_bw_prepare_token;
+	dp->g_restart_bios = range_bw_restart_bios;
+	dp->g_group_ctr = policy_range_bw_ctr;
+	dp->g_group_dtr = policy_range_bw_dtr;
+	dp->g_set_param = policy_range_bw_param;
+	dp->g_should_block = range_bw_queue_full;
+	dp->g_show  = policy_range_bw_show;
+
+	dp->g_min_bw_total = 0;
+	dp->g_running_gp = NULL;
+	dp->g_total_min_bw_token = 0;
+	dp->g_io_mode = MINBW_IO_MODE;
+	dp->g_consumed_min_bw_token = 0;
+	dp->g_current = NULL;
+	dp->g_next_time_period = 0;
+	dp->g_time_period_expired = TIME_SLICE_NOT_EXPIRED;
+
+	dp->g_token_unit = PAGE_SHIFT - 9;
+	init_range_bw_token_bucket(dp, val);
+
+	return 0;
+}
diff -urN linux-2.6.29-orig/drivers/md/Makefile
linux-2.6.29-patch/drivers/md/Makefile
--- linux-2.6.29-orig/drivers/md/Makefile	2009-04-20 18:16:00.000000000 +0900
+++ linux-2.6.29-patch/drivers/md/Makefile	2009-04-20 16:42:47.000000000 +0900
@@ -8,7 +8,7 @@
 dm-snapshot-y	+= dm-snap.o dm-exception-store.o dm-snap-transient.o \
 		    dm-snap-persistent.o
 dm-mirror-y	+= dm-raid1.o
-dm-ioband-y	+= dm-ioband-ctl.o dm-ioband-policy.o dm-ioband-type.o
+dm-ioband-y	+= dm-ioband-ctl.o dm-ioband-policy.o dm-ioband-type.o
dm-ioband-rangebw.o
 md-mod-y	+= md.o bitmap.o
 raid456-y	+= raid5.o
 raid6_pq-y	+= raid6algos.o raid6recov.o raid6tables.o \


-- 
Best Regards,
Dong-Jae Kang
