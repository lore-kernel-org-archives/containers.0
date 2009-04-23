From: Dong-Jae Kang <baramsori72-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] range-bw: Another I/O scheduling policy of dm-ioband
	supporting the predicable I/O bandwidth (range bandwidth)
Date: Thu, 23 Apr 2009 18:10:14 +0900
Message-ID: <2891419e0904230210w40482535ma3fc25c1e429969d__22395.3112531037$1240478067$gmane$org@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001485f339387c95940468353f22
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
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

--001485f339387c95940468353f22
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

Hi, all

range-bw was implemented as another I/O scheduling policy of dm-ioband
to support predicable I/O bandwidth between minimum and maximum
bandwidth defined by administrator. So, basic advantages and defects
are same with dm-ioband. Here, minimum I/O bandwidth should be
guaranteed for stable performance or reliability of specific process
groups and I/O bandwidth over maximum should be throttled to protect
the limited I/O resource from over-provisioning in unnecessary usage
or to reserve the I/O bandwidth for another use.

Recently, as many contributors have discussed about similar issues
through the container ML, administrator of several business site
requires the predicable and consistent I/O bandwidth regardless of
system specification (especially disk) and he/she wants the method to
limit I/O bandwidth used by less important service or process group
such like io-throttle by Andrea , at the same time. I think the
proportional I/O bandwidth is also important such like
weight/io-weight policy in dm-ioband.

So, range-bw was implemented to include the two concepts, guaranteeing
of minimum bandwidth and limitation of maximum bandwidth according to
the importance or priority of specific process groups.

range-bw is based on newest version of dm-ioband, bio-cgroup V7(4
patch files), dm-ioband-V1.10.3(1 patch file) and these can be
referred in
http://people.valinux.co.jp/~ryov/dm-ioband/
http://people.valinux.co.jp/~ryov/bio-cgroup/
and the below range-bw patch file(dm-ioband-rangebw-1.10.3.patch)
including Ryo=92s patch set is also referred in:
http://www.corsetproject.net/browser/corset_source_code/resource_controller=
s/disk_controller/Range-BW-for-dmioband-V1.10.3
You have to apply this(dm-ioband-rangebw-1.10.3.patch) patch file
after applying dm-ioband and bio-cgroup patches.

The released range-bw may have some problems and improper code
although I try to test heavily. It is first release ^^
And it is required to reduce the overhead of I/O scheduling and to
optimize the source code.
Any comments or advices is welcome

Ryo Tsuruta, Can you check this patch file ?
for convenience, patch file is attached in this mail.

USAGE Example -------------------------------------------------
The basic usage is same with dm-ioband by Ryo Tsuruta. So, it is
helpful to refer the usage of dm-ioband.

# mount the cgroup for range-bw
mount -t cgroup -o bio none /root/cgroup/bio

# create the 3 groups
mkdir /root/cgroup/bio/bgroup1
mkdir /root/cgroup/bio/bgroup2
mkdir /root/cgroup/bio/bgroup3

# create the ioband device ( name : ioband1 )
echo "0 $(blockdev --getsize /dev/sdb2) ioband /dev/sdb2 1 0 0 none
range-bw 0 :0" | dmsetup create ioband1

# init ioband device ( type and policy )
dmsetup message ioband1 0 type cgroup
dmsetup message ioband1 0 policy range-bw

# attach the groups to the ioband device
dmsetup message ioband1 0 attach 2
dmsetup message ioband1 0 attach 3
dmsetup message ioband1 0 attach 4

# allocate the values ( min-bw and max-bw ) : XXX Kbytes
# range : about 3~5Mbytes
dmsetup message ioband1 0 min-bw 2:3000
dmsetup message ioband1 0 max-bw 2:5000

# range : about 7~10Mbytes
dmsetup message ioband1 0 min-bw 3:7000
dmsetup message ioband1 0 max-bw 3:10000

# range : about 15~20Mbytes
dmsetup message ioband1 0 min-bw 4:15000
dmsetup message ioband1 0 max-bw 4:20000

This patch file is for range-bw policy in
dm-ioband.---------------------------------------------------------------

diff -urN linux-2.6.30-rc1-orig/drivers/md/dm-ioband-ctl.c
linux-2.6.30-rc1/drivers/md/dm-ioband-ctl.c
--- linux-2.6.30-rc1-orig/drivers/md/dm-ioband-ctl.c	2009-04-20
18:16:00.000000000 +0900
+++ linux-2.6.30-rc1/drivers/md/dm-ioband-ctl.c	2009-04-21
13:00:41.000000000 +0900
@@ -789,6 +789,17 @@
 }

 /*
+ * Check the overflow of maximum bandwidth limit
+ */
+static int is_no_io_mode(struct ioband_group * gp)
+{
+        if(gp->c_io_mode =3D=3D NO_IO_MODE)
+                return 1;
+
+        return 0;
+}
+
+/*
  * Start to control the bandwidth once the number of uncompleted BIOs
  * exceeds the value of "io_throttle".
  */
@@ -799,9 +810,24 @@
 	struct ioband_device *dp =3D gp->c_banddev;
 	unsigned long flags;
 	int direct;
+        unsigned long now, time_step;

 	spin_lock_irqsave(&dp->g_lock, flags);

+        gp =3D ioband_group_get(gp, bio);
+
+        /*
+         * This part is for controlling the max bandwidth of range-bw poli=
cy
+         */
+        if(is_no_io_mode(gp)){=09
+                now =3D jiffies;
+                if(time_after(dp->g_next_time_period, now)){
+                        time_step =3D dp->g_next_time_period - now;
+                        range_bw_timer_register(gp->c_timer,
(time_step + TIME_COMPENSATOR), (unsigned long)gp);
+                        wait_event_lock_irq(gp->c_max_bw_over_waitq,
!is_no_io_mode(gp), dp->g_lock, do_nothing());
+                }
+        }
+
 	/*
 	 * The device is suspended while some of the ioband device
 	 * configurations are being changed.
@@ -811,7 +837,6 @@
 				    !is_device_suspended(dp), dp->g_lock,
 				    do_nothing());

-	gp =3D ioband_group_get(gp, bio);
 	prevent_burst_bios(gp, bio);
 	if (should_pushback_bio(gp)) {
 		spin_unlock_irqrestore(&dp->g_lock, flags);
diff -urN linux-2.6.30-rc1-orig/drivers/md/dm-ioband.h
linux-2.6.30-rc1/drivers/md/dm-ioband.h
--- linux-2.6.30-rc1-orig/drivers/md/dm-ioband.h	2009-04-20
18:16:00.000000000 +0900
+++ linux-2.6.30-rc1/drivers/md/dm-ioband.h	2009-04-20 18:12:50.000000000 +=
0900
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
@@ -74,6 +84,16 @@
 	int g_token_left;
 	/* left-over tokens from the previous epoch */
 	int g_token_extra;
+
+        /* members for range-bw policy */
+        int     g_min_bw_total;
+        unsigned long   g_next_time_period;
+        int     g_time_period_expired;
+        struct ioband_group * g_running_gp;
+        int     g_total_min_bw_token;
+        int     g_consumed_min_bw_token;
+        int     g_io_mode;
+
 };

 struct ioband_group_stat {
@@ -110,8 +130,31 @@

 	/* rfu */
 	/* struct bio_list	c_ordered_tag_bios; */
+
+        /* members for range-bw policy */
+        wait_queue_head_t       c_max_bw_over_waitq;
+        spinlock_t      c_lock;
+        struct timer_list * c_timer;
+        int     timer_set;
+        int     c_min_bw;
+        int     c_max_bw;
+        int     c_time_slice_expired;
+        int     c_min_bw_token;
+        int     c_max_bw_token;
+        int     c_consumed_min_bw_token;
+        int     c_is_over_max_bw;
+        int     c_io_mode;
+        unsigned long   c_time_slice;
+        unsigned long   c_time_slice_start;
+        unsigned long   c_time_slice_end;
+        int     c_wait_p_count;
+
 };

+extern void range_bw_timeover(unsigned long gp);
+extern void range_bw_timer_register(struct timer_list * ptimer,
unsigned long timeover, unsigned long gp);
+extern int policy_range_bw_init(struct ioband_device *dp, int argc,
char **argv);
+
 #define IOBAND_URGENT 1

 #define DEV_BIO_BLOCKED		1
diff -urN linux-2.6.30-rc1-orig/drivers/md/dm-ioband-policy.c
linux-2.6.30-rc1/drivers/md/dm-ioband-policy.c
--- linux-2.6.30-rc1-orig/drivers/md/dm-ioband-policy.c	2009-04-20
18:16:00.000000000 +0900
+++ linux-2.6.30-rc1/drivers/md/dm-ioband-policy.c	2009-04-20
16:12:55.000000000 +0900
@@ -453,5 +453,6 @@
 	{"default", policy_default_init},
 	{"weight", policy_weight_init},
 	{"weight-iosize", w2_policy_weight_init},
+        {"range-bw", policy_range_bw_init},
 	{NULL, policy_default_init}
 };
diff -urN linux-2.6.30-rc1-orig/drivers/md/dm-ioband-rangebw.c
linux-2.6.30-rc1/drivers/md/dm-ioband-rangebw.c
--- linux-2.6.30-rc1-orig/drivers/md/dm-ioband-rangebw.c	1970-01-01
09:00:00.000000000 +0900
+++ linux-2.6.30-rc1/drivers/md/dm-ioband-rangebw.c	2009-04-20
16:00:09.000000000 +0900
@@ -0,0 +1,562 @@
+/*
+ * dm-ioband-rangebw.c
+ *
+ * This is a I/O control policy to support the Range Bandwidth in Disk I/O=
.
+ * And this policy is for dm-ioband controller by Ryo Tsuruta,
Hirokazu Takahashi
+ *
+ * Copyright (C) 2008 - 2011 Electronics and Telecommunications
Research Institute(ETRI)
+ *
+ * This program is free software. you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License(GPL) as published =
by
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
+ * Functions for Range Bandwidth(range-bw) policy based on the time
slice and token.
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
+static const int time_slice_base =3D HZ / 10;
+static const int leftover_time_slice_base =3D HZ / 25;
+static const int range_time_slice_base =3D HZ / 50;
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
RANGE_IO_MODE or LEFTOVER_IO_MODE
+ */
+static int set_time_slice(struct ioband_group * gp)
+{
+        struct ioband_device *dp =3D gp->c_banddev;
+        int dp_io_mode, gp_io_mode;
+        unsigned long now =3D jiffies;
+
+        dp_io_mode =3D dp->g_io_mode;
+        gp_io_mode =3D gp->c_io_mode;
+
+        gp->c_time_slice_start =3D now;
+
+        if(dp_io_mode =3D=3D LEFTOVER_IO_MODE){
+                gp->c_time_slice_end =3D now + leftover_time_slice_base;
+                return 0;
+        }
+
+        if(gp_io_mode =3D=3D MINBW_IO_MODE)
+                gp->c_time_slice_end =3D now + gp->c_time_slice;
+        else if(gp_io_mode =3D=3D RANGE_IO_MODE)
+                gp->c_time_slice_end =3D now + range_time_slice_base;
+        else // gp_io_mode =3D=3D DEFAULT_IO_MODE
+                gp->c_time_slice_end =3D now + time_slice_base;
+
+        gp->c_time_slice_expired =3D TIME_SLICE_NOT_EXPIRED;
+
+        return 0;
+}
+
+/*
+ * Calculate the priority of given ioband_group
+ */
+static int range_bw_priority(struct ioband_group * gp)
+{
+	struct ioband_device *dp =3D gp->c_banddev;
+	int prio =3D 0;
+
+	if(dp->g_io_mode =3D=3D LEFTOVER_IO_MODE){
+		prio =3D random32() % MINBW_PRIO_BASE;
+		if(prio =3D=3D 0)
+			prio =3D 1;
+	}else if(gp->c_io_mode =3D=3D MINBW_IO_MODE){
+		prio =3D (gp->c_min_bw_token - gp->c_consumed_min_bw_token) * MINBW_PRIO=
_BASE;
+	}else if(gp->c_io_mode =3D=3D DEFAULT_IO_MODE){
+		prio =3D MINBW_PRIO_BASE;
+	}else if(gp->c_io_mode =3D=3D RANGE_IO_MODE){
+		prio =3D MINBW_PRIO_BASE / 2;
+	}else{
+		prio =3D 0;
+	}
+
+	return prio;
+}
+
+/*
+ * Check whether this group has right to issue an I/O in range-bw policy m=
ode.
+ *  Return 0 if it doesn't have right, otherwise return the non-zero value=
.
+ */
+static int has_right_to_issue(struct ioband_group *gp)
+{
+	struct ioband_device *dp =3D gp->c_banddev;
+	int prio;
+
+	if(gp->c_prio_blocked > 0 || gp->c_blocked - gp->c_prio_blocked > 0){
+		prio =3D range_bw_priority(gp);
+		if(prio <=3D 0)
+			return 1;
+		return prio;
+	}
+
+	if(gp =3D=3D dp->g_running_gp){
+
+		if(gp->c_time_slice_expired =3D=3D TIME_SLICE_EXPIRED){
+
+			gp->c_time_slice_expired =3D TIME_SLICE_NOT_EXPIRED;
+			gp->c_time_slice_end =3D 0;
+
+			return 0;
+		}
+
+		if(gp->c_time_slice_end =3D=3D 0)
+			set_time_slice(gp);
+
+		return range_bw_priority(gp);
+
+	}
+
+	dp->g_running_gp =3D gp;
+	set_time_slice(gp);
+
+	return range_bw_priority(gp);
+}
+
+/*
+ * Reset all variables related with range-bw token and time slice
+ */
+static int reset_range_bw_token(struct ioband_group * gp, unsigned long no=
w)
+{
+        struct ioband_device *dp =3D gp->c_banddev;
+        struct ioband_group *p;
+
+        list_for_each_entry(p, &dp->g_groups, c_list){
+                p->c_consumed_min_bw_token =3D 0;
+                p->c_is_over_max_bw =3D MAX_BW_UNDER;
+		if(p->c_io_mode !=3D DEFAULT_IO_MODE)
+			p->c_io_mode =3D MINBW_IO_MODE;
+        }
+
+        dp->g_consumed_min_bw_token =3D 0;
+
+        dp->g_next_time_period =3D now + HZ;
+        dp->g_time_period_expired =3D TIME_SLICE_NOT_EXPIRED;
+        dp->g_io_mode =3D MINBW_IO_MODE;
+
+	 list_for_each_entry(p, &dp->g_groups, c_list){
+        	if(waitqueue_active(&p->c_max_bw_over_waitq))
+                	wake_up_all(&p->c_max_bw_over_waitq);
+        }
+        return 0;
+}
+
+/*
+ * Use tokens(Increase the number of consumed token) to issue an I/O
for guranteeing the range-bw.
+ * and check the expiration of local and global time slice, and
overflow of max bw
+ */
+static int range_bw_consume_token(struct ioband_group *gp, int count, int =
flag)
+{
+        struct ioband_device *dp =3D gp->c_banddev;
+        struct ioband_group *p;
+        unsigned long now =3D jiffies;
+        int io_mode;
+
+        dp->g_current =3D gp;
+
+        if(dp->g_next_time_period =3D=3D 0){
+                dp->g_next_time_period =3D now + HZ;
+                dp->g_time_period_expired =3D TIME_SLICE_NOT_EXPIRED;
+        }
+
+        if(time_after(now, dp->g_next_time_period)){
+                reset_range_bw_token(gp, now);
+        }else{
+                gp->c_consumed_min_bw_token +=3D count;
+                dp->g_consumed_min_bw_token +=3D count;
+
+                if(gp->c_max_bw > 0 && gp->c_consumed_min_bw_token >=3D
gp->c_max_bw_token){
+                        gp->c_is_over_max_bw =3D MAX_BW_OVER;
+			gp->c_io_mode =3D NO_IO_MODE;
+			return R_YIELD;
+                }
+
+                if(gp->c_io_mode !=3D RANGE_IO_MODE &&
gp->c_min_bw_token <=3D gp->c_consumed_min_bw_token){
+                        gp->c_io_mode =3D RANGE_IO_MODE;
+
+                        if(dp->g_total_min_bw_token <=3D
dp->g_consumed_min_bw_token){
+                                list_for_each_entry(p, &dp->g_groups, c_li=
st){
+                                        if(p->c_io_mode =3D=3D
RANGE_IO_MODE || p->c_io_mode =3D=3D DEFAULT_IO_MODE){
+                                                io_mode =3D 1;
+                                        }else{
+                                                io_mode =3D 0;
+                                                break;
+                                        }
+                                }
+
+                                if(io_mode && dp->g_io_mode =3D=3D MINBW_I=
O_MODE)
+                                        dp->g_io_mode =3D LEFTOVER_IO_MODE=
;
+                        }
+                }
+        }
+
+        if(gp->c_time_slice_end !=3D 0 && time_after(now, gp->c_time_slice=
_end)){
+                gp->c_time_slice_expired =3D TIME_SLICE_EXPIRED;
+		return R_YIELD;
+        }
+
+        return R_OK;
+}
+
+/*
+ * Check if this group is able to receive a new bio.
+ * in range bw policy, we only check that ioband device should be blocked
+ */
+static int range_bw_queue_full(struct ioband_group *gp)
+{
+=09
+	return (gp->c_blocked >=3D gp->c_limit);
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
+	token_base =3D (1 << token_unit) / 4; // token_base is 1 or 2
+	token =3D bw * token_base;
+=09
+	return token;
+}
+
+
+/*
+ * Allocate the time slice for MINBW_IO_MODE to each group
+ */
+static void range_bw_time_slice_init(struct ioband_group * gp)
+{
+	struct ioband_device * dp =3D gp->c_banddev;
+	struct ioband_group * p;
+
+        list_for_each_entry(p, &dp->g_groups, c_list){
+		if(p->c_min_bw =3D=3D 0)
+			p->c_time_slice =3D time_slice_base;
+		else
+			p->c_time_slice =3D time_slice_base + ((time_slice_base *
p->c_min_bw) / dp->g_min_bw_total);
+        }
+}
+
+
+/*
+ * Allocate the min_bw and min_bw_token to the given group
+ */
+static void set_min_bw(struct ioband_group *gp, int new)
+{
+	struct ioband_device *dp =3D gp->c_banddev;
+	struct ioband_group * p;
+	int	token_unit;
+
+	dp->g_min_bw_total +=3D (new - gp->c_min_bw);
+	gp->c_min_bw =3D new;
+
+        if(new)
+                gp->c_io_mode =3D MINBW_IO_MODE;
+        else
+                gp->c_io_mode =3D DEFAULT_IO_MODE;
+=09
+	range_bw_time_slice_init(gp);
+
+	token_unit =3D dp->g_token_unit;
+	gp->c_min_bw_token =3D convert_bw_to_token(gp->c_min_bw, token_unit);
+	dp->g_total_min_bw_token =3D convert_bw_to_token(dp->g_min_bw_total,
token_unit);
+
+        if (dp->g_min_bw_total =3D=3D 0) {
+                list_for_each_entry(p, &dp->g_groups, c_list)
+                        p->c_limit =3D 1;
+        } else {
+                list_for_each_entry(p, &dp->g_groups, c_list) {
+                        p->c_limit =3D (dp->g_io_limit[0] + dp->g_io_limit=
[1]) *
+                                p->c_min_bw / dp->g_min_bw_total /
+                                OVER_IO_RATE + 1;
+                }
+        }
+
+	return;
+}
+
+/*
+ * Allocate the max_bw and max_bw_token to the pointed group
+ */
+static void set_max_bw(struct ioband_group *gp, int new)
+{
+	struct ioband_device *dp =3D gp->c_banddev;
+	int	token_unit;=09
+
+	token_unit =3D dp->g_token_unit;
+
+	gp->c_max_bw =3D new;
+	gp->c_max_bw_token =3D convert_bw_to_token(new, token_unit);
+
+	return;
+
+}
+
+static void init_range_bw_token_bucket(struct ioband_device *dp, int val)
+{
+	dp->g_token_bucket =3D ((dp->g_io_limit[0] + dp->g_io_limit[1]) *
+				 DEFAULT_BUCKET) << dp->g_token_unit;
+	if (!val)
+		val =3D DEFAULT_TOKENPOOL << dp->g_token_unit;
+	if (val < dp->g_token_bucket)
+		val =3D dp->g_token_bucket;
+	dp->g_carryover =3D val/dp->g_token_bucket;
+	dp->g_token_left =3D 0;
+}
+
+static int policy_range_bw_param(struct ioband_group *gp, char *cmd,
char *value)
+{
+	long val;
+	int r =3D 0, err;
+
+	err =3D strict_strtol(value, 0, &val);
+
+	if (!strcmp(cmd, "min-bw")) {
+		if (!err && 0 <=3D val && val <=3D (INT_MAX / 2))
+			set_min_bw(gp, val);
+		else
+			r =3D -EINVAL;
+	} else if (!strcmp(cmd, "max-bw")) {
+		if ((!err && 0 <=3D val && val <=3D (INT_MAX / 2) && gp->c_min_bw <=3D
val) || val =3D=3D 0)
+			set_max_bw(gp, val);
+		else
+			r =3D -EINVAL;
+	} else {
+		r =3D -EINVAL;
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
+		arg =3D __stringify(DEFAULT_MIN_BW);
+
+	init_waitqueue_head(&gp->c_max_bw_over_waitq);
+	spin_lock_init(&gp->c_lock);=09
+
+	gp->c_min_bw =3D 0;
+	gp->c_max_bw =3D 0;
+	gp->c_io_mode  =3D DEFAULT_IO_MODE;
+	gp->c_time_slice_expired =3D TIME_SLICE_NOT_EXPIRED;
+	gp->c_min_bw_token =3D 0;
+	gp->c_max_bw_token =3D 0;
+	gp->c_consumed_min_bw_token =3D 0;
+	gp->c_is_over_max_bw =3D MAX_BW_UNDER;
+	gp->c_time_slice_start =3D 0;
+	gp->c_time_slice_end =3D 0;
+	gp->c_wait_p_count =3D 0;//
+
+	gp->c_time_slice =3D time_slice_base;
+
+        gp->c_timer =3D kmalloc(sizeof(struct timer_list), GFP_KERNEL);
+        if(gp->c_timer =3D=3D NULL) return -EINVAL; // return value may
be not appropriate !!!
+        memset(gp->c_timer, 0, sizeof(struct timer_list));
+	gp->timer_set =3D 0;
+=09
+	ret =3D policy_range_bw_param(gp, "min-bw", arg);
+
+	return ret;
+}
+
+static void policy_range_bw_dtr(struct ioband_group *gp)
+{
+	struct ioband_device *dp =3D gp->c_banddev;
+
+	set_min_bw(gp, 0);
+	gp->c_time_slice =3D 0;
+	set_max_bw(gp, 0);
+
+	dp->g_running_gp =3D NULL;
+
+	if(gp->c_timer !=3D NULL){
+		del_timer(gp->c_timer);
+		kfree(gp->c_timer);
+	}
+}
+
+static void policy_range_bw_show(struct ioband_group *gp, int *szp,
+					char *result, unsigned int maxlen)
+{
+	struct ioband_group *p;
+	struct ioband_device *dp =3D gp->c_banddev;
+	struct rb_node *node;
+	int sz =3D *szp; /* used in DMEMIT() */
+
+	DMEMIT(" %d :%d", dp->g_token_bucket * dp->g_carryover, gp->c_min_bw);
+
+	for (node =3D rb_first(&gp->c_group_root); node; node =3D rb_next(node)) =
{
+		p =3D rb_entry(node, struct ioband_group, c_group_node);
+		DMEMIT(" %d:%d:%d", p->c_id, p->c_min_bw, p->c_max_bw);
+	}
+	*szp =3D sz;
+}
+
+static int range_bw_prepare_token(struct ioband_group *gp, struct bio
*bio, int flag)
+{
+	struct ioband_device *dp =3D gp->c_banddev;
+	int unit;
+	int bio_count;
+	int token_count =3D 0;
+
+	unit =3D (1 << dp->g_token_unit);
+	bio_count =3D bio_sectors(bio);
+
+	if(unit =3D=3D 8) // 1 token is used for 512 bytes
+		token_count =3D bio_count;
+	else if(unit =3D=3D 4) // 1 token is used for 1024 bytes
+		token_count =3D bio_count / 2;
+	else if(unit =3D=3D 2) // 1 token is used for 2048 bytes
+		token_count =3D bio_count / 4;
+	else if(unit =3D=3D 1) // 1 token is used for 4096 bytes
+		token_count =3D bio_count / 8;
+
+	return range_bw_consume_token(gp, token_count, flag);
+}
+
+void range_bw_timer_register(struct timer_list * ptimer, unsigned
long timeover, unsigned long  gp)
+{
+	struct ioband_group * group =3D (struct ioband_group *)gp;
+
+	if(group->timer_set =3D=3D 0){
+		init_timer(ptimer);
+		ptimer->expires =3D get_jiffies_64() + timeover;
+		ptimer->data =3D gp;
+		ptimer->function =3D range_bw_timeover;
+		add_timer(ptimer);
+		group->timer_set =3D 1;
+	}
+}
+
+/*
+ * Timer Handler function to protect the all processes's hanging in
lower min-bw configuration
+ */
+void range_bw_timeover(unsigned long gp)
+{
+	struct ioband_group * group =3D (struct ioband_group *)gp;
+
+	if(group->c_is_over_max_bw =3D=3D MAX_BW_OVER){
+		group->c_is_over_max_bw =3D MAX_BW_UNDER;
+	}
+
+	if(group->c_io_mode =3D=3D NO_IO_MODE){
+		group->c_io_mode =3D MINBW_IO_MODE;
+	}
+
+	if(waitqueue_active(&group->c_max_bw_over_waitq))
+		wake_up_all(&group->c_max_bw_over_waitq);
+=09
+	group->timer_set =3D 0;
+}
+
+/*
+ *  <Method>      <description>
+ * g_can_submit   : To determine whether a given group has the right to
+ *                  submit BIOs. The larger the return value the higher th=
e
+ *                  priority to submit. Zero means it has no right.
+ * g_prepare_bio  : Called right before submitting each BIO.
+ * g_restart_bios : Called if this ioband device has some BIOs blocked but=
 none
+ *                  of them can be submitted now. This method has to
+ *                  reinitialize the data to restart to submit BIOs and re=
turn
+ *                  0 or 1.
+ *                  The return value 0 means that it has become able to su=
bmit
+ *                  them now so that this ioband device will continue its =
work.
+ *                  The return value 1 means that it is still unable to su=
bmit
+ *                  them so that this device will stop its work. And this
+ *                  policy module has to reactivate the device when it get=
s
+ *                  to be able to submit BIOs.
+ * g_hold_bio     : To hold a given BIO until it is submitted.
+ *                  The default function is used when this method is undef=
ined.
+ * g_pop_bio      : To select and get the best BIO to submit.
+ * g_group_ctr    : To initalize the policy own members of struct ioband_g=
roup.
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
+	int r =3D 0;
+
+	if (argc < 1)
+		val =3D 0;
+	else {
+		r =3D strict_strtol(argv[0], 0, &val);
+		if (r || val < 0)
+			return -EINVAL;
+	}
+=09
+	dp->g_can_submit =3D has_right_to_issue;
+	dp->g_prepare_bio =3D range_bw_prepare_token;
+	dp->g_restart_bios =3D range_bw_restart_bios;
+	dp->g_group_ctr =3D policy_range_bw_ctr;
+	dp->g_group_dtr =3D policy_range_bw_dtr;
+	dp->g_set_param =3D policy_range_bw_param;
+	dp->g_should_block =3D range_bw_queue_full;
+	dp->g_show  =3D policy_range_bw_show;
+
+	dp->g_min_bw_total =3D 0;
+	dp->g_running_gp =3D NULL;
+	dp->g_total_min_bw_token =3D 0;
+	dp->g_io_mode =3D MINBW_IO_MODE;
+	dp->g_consumed_min_bw_token =3D 0;
+	dp->g_current =3D NULL;
+	dp->g_next_time_period =3D 0;
+	dp->g_time_period_expired =3D TIME_SLICE_NOT_EXPIRED;
+
+	dp->g_token_unit =3D PAGE_SHIFT - 9;
+	init_range_bw_token_bucket(dp, val);
+
+	return 0;
+}
diff -urN linux-2.6.30-rc1-orig/drivers/md/Makefile
linux-2.6.30-rc1/drivers/md/Makefile
--- linux-2.6.30-rc1-orig/drivers/md/Makefile	2009-04-20
18:16:00.000000000 +0900
+++ linux-2.6.30-rc1/drivers/md/Makefile	2009-04-20 16:42:47.000000000 +090=
0
@@ -8,7 +8,7 @@
 dm-snapshot-y	+=3D dm-snap.o dm-exception-store.o dm-snap-transient.o \
 		    dm-snap-persistent.o
 dm-mirror-y	+=3D dm-raid1.o
-dm-ioband-y	+=3D dm-ioband-ctl.o dm-ioband-policy.o dm-ioband-type.o
+dm-ioband-y	+=3D dm-ioband-ctl.o dm-ioband-policy.o dm-ioband-type.o
dm-ioband-rangebw.o
 md-mod-y	+=3D md.o bitmap.o
 raid456-y	+=3D raid5.o
 raid6_pq-y	+=3D raid6algos.o raid6recov.o raid6tables.o \


--=20
Best Regards,
Dong-Jae Kang

--001485f339387c95940468353f22
Content-Type: application/octet-stream;
	name="dm-ioband-rangebw-1.10.3.patch"
Content-Disposition: attachment; filename="dm-ioband-rangebw-1.10.3.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ftv8ezeo0

ZGlmZiAtdXJOIGxpbnV4LTIuNi4zMC1yYzEtb3JpZy9kcml2ZXJzL21kL2RtLWlvYmFuZC1jdGwu
YyBsaW51eC0yLjYuMzAtcmMxL2RyaXZlcnMvbWQvZG0taW9iYW5kLWN0bC5jCi0tLSBsaW51eC0y
LjYuMzAtcmMxLW9yaWcvZHJpdmVycy9tZC9kbS1pb2JhbmQtY3RsLmMJMjAwOS0wNC0yMCAxODox
NjowMC4wMDAwMDAwMDAgKzA5MDAKKysrIGxpbnV4LTIuNi4zMC1yYzEvZHJpdmVycy9tZC9kbS1p
b2JhbmQtY3RsLmMJMjAwOS0wNC0yMSAxMzowMDo0MS4wMDAwMDAwMDAgKzA5MDAKQEAgLTc4OSw2
ICs3ODksMTcgQEAKIH0KIAogLyoKKyAqIENoZWNrIHRoZSBvdmVyZmxvdyBvZiBtYXhpbXVtIGJh
bmR3aWR0aCBsaW1pdAorICovCitzdGF0aWMgaW50IGlzX25vX2lvX21vZGUoc3RydWN0IGlvYmFu
ZF9ncm91cCAqIGdwKQoreworICAgICAgICBpZihncC0+Y19pb19tb2RlID09IE5PX0lPX01PREUp
CisgICAgICAgICAgICAgICAgcmV0dXJuIDE7CisKKyAgICAgICAgcmV0dXJuIDA7Cit9CisKKy8q
CiAgKiBTdGFydCB0byBjb250cm9sIHRoZSBiYW5kd2lkdGggb25jZSB0aGUgbnVtYmVyIG9mIHVu
Y29tcGxldGVkIEJJT3MKICAqIGV4Y2VlZHMgdGhlIHZhbHVlIG9mICJpb190aHJvdHRsZSIuCiAg
Ki8KQEAgLTc5OSw5ICs4MTAsMjQgQEAKIAlzdHJ1Y3QgaW9iYW5kX2RldmljZSAqZHAgPSBncC0+
Y19iYW5kZGV2OwogCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CiAJaW50IGRpcmVjdDsKKyAgICAgICAg
dW5zaWduZWQgbG9uZyBub3csIHRpbWVfc3RlcDsKIAogCXNwaW5fbG9ja19pcnFzYXZlKCZkcC0+
Z19sb2NrLCBmbGFncyk7CiAKKyAgICAgICAgZ3AgPSBpb2JhbmRfZ3JvdXBfZ2V0KGdwLCBiaW8p
OworCisgICAgICAgIC8qCisgICAgICAgICAqIFRoaXMgcGFydCBpcyBmb3IgY29udHJvbGxpbmcg
dGhlIG1heCBiYW5kd2lkdGggb2YgcmFuZ2UtYncgcG9saWN5CisgICAgICAgICAqLworICAgICAg
ICBpZihpc19ub19pb19tb2RlKGdwKSl7CQorICAgICAgICAgICAgICAgIG5vdyA9IGppZmZpZXM7
CisgICAgICAgICAgICAgICAgaWYodGltZV9hZnRlcihkcC0+Z19uZXh0X3RpbWVfcGVyaW9kLCBu
b3cpKXsKKyAgICAgICAgICAgICAgICAgICAgICAgIHRpbWVfc3RlcCA9IGRwLT5nX25leHRfdGlt
ZV9wZXJpb2QgLSBub3c7CisgICAgICAgICAgICAgICAgICAgICAgICByYW5nZV9id190aW1lcl9y
ZWdpc3RlcihncC0+Y190aW1lciwgKHRpbWVfc3RlcCArIFRJTUVfQ09NUEVOU0FUT1IpLCAodW5z
aWduZWQgbG9uZylncCk7CisgICAgICAgICAgICAgICAgICAgICAgICB3YWl0X2V2ZW50X2xvY2tf
aXJxKGdwLT5jX21heF9id19vdmVyX3dhaXRxLCAhaXNfbm9faW9fbW9kZShncCksIGRwLT5nX2xv
Y2ssIGRvX25vdGhpbmcoKSk7CisgICAgICAgICAgICAgICAgfQorICAgICAgICB9CisKIAkvKgog
CSAqIFRoZSBkZXZpY2UgaXMgc3VzcGVuZGVkIHdoaWxlIHNvbWUgb2YgdGhlIGlvYmFuZCBkZXZp
Y2UKIAkgKiBjb25maWd1cmF0aW9ucyBhcmUgYmVpbmcgY2hhbmdlZC4KQEAgLTgxMSw3ICs4Mzcs
NiBAQAogCQkJCSAgICAhaXNfZGV2aWNlX3N1c3BlbmRlZChkcCksIGRwLT5nX2xvY2ssCiAJCQkJ
ICAgIGRvX25vdGhpbmcoKSk7CiAKLQlncCA9IGlvYmFuZF9ncm91cF9nZXQoZ3AsIGJpbyk7CiAJ
cHJldmVudF9idXJzdF9iaW9zKGdwLCBiaW8pOwogCWlmIChzaG91bGRfcHVzaGJhY2tfYmlvKGdw
KSkgewogCQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZkcC0+Z19sb2NrLCBmbGFncyk7CmRpZmYg
LXVyTiBsaW51eC0yLjYuMzAtcmMxLW9yaWcvZHJpdmVycy9tZC9kbS1pb2JhbmQuaCBsaW51eC0y
LjYuMzAtcmMxL2RyaXZlcnMvbWQvZG0taW9iYW5kLmgKLS0tIGxpbnV4LTIuNi4zMC1yYzEtb3Jp
Zy9kcml2ZXJzL21kL2RtLWlvYmFuZC5oCTIwMDktMDQtMjAgMTg6MTY6MDAuMDAwMDAwMDAwICsw
OTAwCisrKyBsaW51eC0yLjYuMzAtcmMxL2RyaXZlcnMvbWQvZG0taW9iYW5kLmgJMjAwOS0wNC0y
MCAxODoxMjo1MC4wMDAwMDAwMDAgKzA5MDAKQEAgLTgsNiArOCwxMCBAQAogCiAjaW5jbHVkZSA8
bGludXgvdmVyc2lvbi5oPgogI2luY2x1ZGUgPGxpbnV4L3dhaXQuaD4KKyNpbmNsdWRlIDxsaW51
eC9qaWZmaWVzLmg+CisjaW5jbHVkZSA8bGludXgvcmFuZG9tLmg+CisjaW5jbHVkZSA8bGludXgv
dGltZS5oPgorI2luY2x1ZGUgPGxpbnV4L3RpbWVyLmg+CiAKICNkZWZpbmUgRE1fTVNHX1BSRUZJ
WCAiaW9iYW5kIgogCkBAIC0xNiw2ICsyMCwxMiBAQAogI2RlZmluZSBJT0JBTkRfTkFNRV9NQVgg
MzEKICNkZWZpbmUgSU9CQU5EX0lEX0FOWSAoLTEpCiAKKyNkZWZpbmUgTUFYX0JXX09WRVIgICAg
ICAgICAgICAgMQorI2RlZmluZSBNQVhfQldfVU5ERVIgICAgICAgICAgICAwCisjZGVmaW5lIE5P
X0lPX01PREUgICAgICAgICAgICAgIDQKKworI2RlZmluZSBUSU1FX0NPTVBFTlNBVE9SICAgICAg
ICAxMAorCiBzdHJ1Y3QgaW9iYW5kX2dyb3VwOwogCiBzdHJ1Y3QgaW9iYW5kX2RldmljZSB7CkBA
IC03NCw2ICs4NCwxNiBAQAogCWludCBnX3Rva2VuX2xlZnQ7CiAJLyogbGVmdC1vdmVyIHRva2Vu
cyBmcm9tIHRoZSBwcmV2aW91cyBlcG9jaCAqLwogCWludCBnX3Rva2VuX2V4dHJhOworCisgICAg
ICAgIC8qIG1lbWJlcnMgZm9yIHJhbmdlLWJ3IHBvbGljeSAqLworICAgICAgICBpbnQgICAgIGdf
bWluX2J3X3RvdGFsOworICAgICAgICB1bnNpZ25lZCBsb25nICAgZ19uZXh0X3RpbWVfcGVyaW9k
OworICAgICAgICBpbnQgICAgIGdfdGltZV9wZXJpb2RfZXhwaXJlZDsKKyAgICAgICAgc3RydWN0
IGlvYmFuZF9ncm91cCAqIGdfcnVubmluZ19ncDsKKyAgICAgICAgaW50ICAgICBnX3RvdGFsX21p
bl9id190b2tlbjsKKyAgICAgICAgaW50ICAgICBnX2NvbnN1bWVkX21pbl9id190b2tlbjsKKyAg
ICAgICAgaW50ICAgICBnX2lvX21vZGU7CisKIH07CiAKIHN0cnVjdCBpb2JhbmRfZ3JvdXBfc3Rh
dCB7CkBAIC0xMTAsOCArMTMwLDMxIEBACiAKIAkvKiByZnUgKi8KIAkvKiBzdHJ1Y3QgYmlvX2xp
c3QJY19vcmRlcmVkX3RhZ19iaW9zOyAqLworCisgICAgICAgIC8qIG1lbWJlcnMgZm9yIHJhbmdl
LWJ3IHBvbGljeSAqLworICAgICAgICB3YWl0X3F1ZXVlX2hlYWRfdCAgICAgICBjX21heF9id19v
dmVyX3dhaXRxOworICAgICAgICBzcGlubG9ja190ICAgICAgY19sb2NrOworICAgICAgICBzdHJ1
Y3QgdGltZXJfbGlzdCAqIGNfdGltZXI7CisgICAgICAgIGludCAgICAgdGltZXJfc2V0OworICAg
ICAgICBpbnQgICAgIGNfbWluX2J3OworICAgICAgICBpbnQgICAgIGNfbWF4X2J3OworICAgICAg
ICBpbnQgICAgIGNfdGltZV9zbGljZV9leHBpcmVkOworICAgICAgICBpbnQgICAgIGNfbWluX2J3
X3Rva2VuOworICAgICAgICBpbnQgICAgIGNfbWF4X2J3X3Rva2VuOworICAgICAgICBpbnQgICAg
IGNfY29uc3VtZWRfbWluX2J3X3Rva2VuOworICAgICAgICBpbnQgICAgIGNfaXNfb3Zlcl9tYXhf
Ync7CisgICAgICAgIGludCAgICAgY19pb19tb2RlOworICAgICAgICB1bnNpZ25lZCBsb25nICAg
Y190aW1lX3NsaWNlOworICAgICAgICB1bnNpZ25lZCBsb25nICAgY190aW1lX3NsaWNlX3N0YXJ0
OworICAgICAgICB1bnNpZ25lZCBsb25nICAgY190aW1lX3NsaWNlX2VuZDsKKyAgICAgICAgaW50
ICAgICBjX3dhaXRfcF9jb3VudDsKKwogfTsKIAorZXh0ZXJuIHZvaWQgcmFuZ2VfYndfdGltZW92
ZXIodW5zaWduZWQgbG9uZyBncCk7CitleHRlcm4gdm9pZCByYW5nZV9id190aW1lcl9yZWdpc3Rl
cihzdHJ1Y3QgdGltZXJfbGlzdCAqIHB0aW1lciwgdW5zaWduZWQgbG9uZyB0aW1lb3ZlciwgdW5z
aWduZWQgbG9uZyBncCk7CitleHRlcm4gaW50IHBvbGljeV9yYW5nZV9id19pbml0KHN0cnVjdCBp
b2JhbmRfZGV2aWNlICpkcCwgaW50IGFyZ2MsIGNoYXIgKiphcmd2KTsKKwogI2RlZmluZSBJT0JB
TkRfVVJHRU5UIDEKIAogI2RlZmluZSBERVZfQklPX0JMT0NLRUQJCTEKZGlmZiAtdXJOIGxpbnV4
LTIuNi4zMC1yYzEtb3JpZy9kcml2ZXJzL21kL2RtLWlvYmFuZC1wb2xpY3kuYyBsaW51eC0yLjYu
MzAtcmMxL2RyaXZlcnMvbWQvZG0taW9iYW5kLXBvbGljeS5jCi0tLSBsaW51eC0yLjYuMzAtcmMx
LW9yaWcvZHJpdmVycy9tZC9kbS1pb2JhbmQtcG9saWN5LmMJMjAwOS0wNC0yMCAxODoxNjowMC4w
MDAwMDAwMDAgKzA5MDAKKysrIGxpbnV4LTIuNi4zMC1yYzEvZHJpdmVycy9tZC9kbS1pb2JhbmQt
cG9saWN5LmMJMjAwOS0wNC0yMCAxNjoxMjo1NS4wMDAwMDAwMDAgKzA5MDAKQEAgLTQ1Myw1ICs0
NTMsNiBAQAogCXsiZGVmYXVsdCIsIHBvbGljeV9kZWZhdWx0X2luaXR9LAogCXsid2VpZ2h0Iiwg
cG9saWN5X3dlaWdodF9pbml0fSwKIAl7IndlaWdodC1pb3NpemUiLCB3Ml9wb2xpY3lfd2VpZ2h0
X2luaXR9LAorICAgICAgICB7InJhbmdlLWJ3IiwgcG9saWN5X3JhbmdlX2J3X2luaXR9LAogCXtO
VUxMLCBwb2xpY3lfZGVmYXVsdF9pbml0fQogfTsKZGlmZiAtdXJOIGxpbnV4LTIuNi4zMC1yYzEt
b3JpZy9kcml2ZXJzL21kL2RtLWlvYmFuZC1yYW5nZWJ3LmMgbGludXgtMi42LjMwLXJjMS9kcml2
ZXJzL21kL2RtLWlvYmFuZC1yYW5nZWJ3LmMKLS0tIGxpbnV4LTIuNi4zMC1yYzEtb3JpZy9kcml2
ZXJzL21kL2RtLWlvYmFuZC1yYW5nZWJ3LmMJMTk3MC0wMS0wMSAwOTowMDowMC4wMDAwMDAwMDAg
KzA5MDAKKysrIGxpbnV4LTIuNi4zMC1yYzEvZHJpdmVycy9tZC9kbS1pb2JhbmQtcmFuZ2Vidy5j
CTIwMDktMDQtMjAgMTY6MDA6MDkuMDAwMDAwMDAwICswOTAwCkBAIC0wLDAgKzEsNTYyIEBACisv
KgorICogZG0taW9iYW5kLXJhbmdlYncuYworICoKKyAqIFRoaXMgaXMgYSBJL08gY29udHJvbCBw
b2xpY3kgdG8gc3VwcG9ydCB0aGUgUmFuZ2UgQmFuZHdpZHRoIGluIERpc2sgSS9PLgorICogQW5k
IHRoaXMgcG9saWN5IGlzIGZvciBkbS1pb2JhbmQgY29udHJvbGxlciBieSBSeW8gVHN1cnV0YSwg
SGlyb2thenUgVGFrYWhhc2hpCisgKgorICogQ29weXJpZ2h0IChDKSAyMDA4IC0gMjAxMSBFbGVj
dHJvbmljcyBhbmQgVGVsZWNvbW11bmljYXRpb25zIFJlc2VhcmNoIEluc3RpdHV0ZShFVFJJKQor
ICoKKyAqIFRoaXMgcHJvZ3JhbSBpcyBmcmVlIHNvZnR3YXJlLiB5b3UgY2FuIHJlZGlzdHJpYnV0
ZSBpdCBhbmQvb3IgbW9kaWZ5CisgKiBpdCB1bmRlciB0aGUgdGVybXMgb2YgdGhlIEdOVSBHZW5l
cmFsIFB1YmxpYyBMaWNlbnNlKEdQTCkgYXMgcHVibGlzaGVkIGJ5CisgKiB0aGUgRnJlZSBTb2Z0
d2FyZSBGb3VuZGF0aW9uLCBlaXRoZXIgdmVyc2lvbiAyIG9mIHRoZSBMaWNlbnNlLCBvcgorICog
KGF0IHlvdXIgb3B0aW9uKSBhbnkgbGF0ZXIgdmVyc2lvbi4KKyAqCisgKiBDb250YWN0IEluZm9y
bWF0aW9uOgorICogRG9uZy1KYWUsIEthbmcgPGRqa2FuZ0BldHJpLnJlLmtyPiwgQ2hlaS1Zb2ws
S2ltIDxnYXVyaUBldHJpLnJlLmtyPiwgCisgKiBTdW5nLUluLEp1bmcgPHNpanVuZ0BldHJpLnJl
LmtyPgorICovCisKKyNpbmNsdWRlIDxsaW51eC9iaW8uaD4KKyNpbmNsdWRlIDxsaW51eC93b3Jr
cXVldWUuaD4KKyNpbmNsdWRlIDxsaW51eC9yYnRyZWUuaD4KKyNpbmNsdWRlICJkbS5oIgorI2lu
Y2x1ZGUgImRtLWJpby1saXN0LmgiCisjaW5jbHVkZSAiZG0taW9iYW5kLmgiCisKKy8qCisgKiBG
dW5jdGlvbnMgZm9yIFJhbmdlIEJhbmR3aWR0aChyYW5nZS1idykgcG9saWN5IGJhc2VkIG9uIHRo
ZSB0aW1lIHNsaWNlIGFuZCB0b2tlbi4KKyAqLworI2RlZmluZSBERUZBVUxUX0JVQ0tFVCAgICAg
ICAgICAyCisjZGVmaW5lIERFRkFVTFRfVE9LRU5QT09MICAgICAgIDIwNDgKKworI2RlZmluZSBE
RUZBVUxUX01JTl9CVwkJMAorI2RlZmluZSBUSU1FX1NMSUNFX0VYUElSRUQgICAgICAxCisjZGVm
aW5lIFRJTUVfU0xJQ0VfTk9UX0VYUElSRUQgIDAKKworI2RlZmluZSBNSU5CV19JT19NT0RFICAg
ICAgICAgICAwCisjZGVmaW5lIExFRlRPVkVSX0lPX01PREUgICAgICAgIDEKKyNkZWZpbmUgUkFO
R0VfSU9fTU9ERSAgICAgICAgICAgMgorI2RlZmluZSBERUZBVUxUX0lPX01PREUgICAgICAgICAz
CisjZGVmaW5lIE5PX0lPX01PREUgCSAgICAgICAgNAorCisjZGVmaW5lIE1JTkJXX1BSSU9fQkFT
RSAgICAgICAgIDEwCisjZGVmaW5lIE9WRVJfSU9fUkFURQkJNAorCitzdGF0aWMgY29uc3QgaW50
IHRpbWVfc2xpY2VfYmFzZSA9IEhaIC8gMTA7CitzdGF0aWMgY29uc3QgaW50IGxlZnRvdmVyX3Rp
bWVfc2xpY2VfYmFzZSA9IEhaIC8gMjU7CitzdGF0aWMgY29uc3QgaW50IHJhbmdlX3RpbWVfc2xp
Y2VfYmFzZSA9IEhaIC8gNTA7CisKKy8qCisgKiBnX3Jlc3RhcnRfYmlvcyBmdW5jdGlvbiBmb3Ig
cmFuZ2UtYncgcG9saWN5CisgKi8KK3N0YXRpYyBpbnQgcmFuZ2VfYndfcmVzdGFydF9iaW9zKHN0
cnVjdCBpb2JhbmRfZGV2aWNlICpkcCkKK3sKKwlyZXR1cm4gMTsKK30KKworLyoKKyAqIEFsbG9j
YXRlIHRoZSB0aW1lIHNsaWNlIHdoZW4gSU8gbW9kZSBpcyBNSU5CV19JT19NT0RFLCBSQU5HRV9J
T19NT0RFIG9yIExFRlRPVkVSX0lPX01PREUgCisgKi8KK3N0YXRpYyBpbnQgc2V0X3RpbWVfc2xp
Y2Uoc3RydWN0IGlvYmFuZF9ncm91cCAqIGdwKQoreworICAgICAgICBzdHJ1Y3QgaW9iYW5kX2Rl
dmljZSAqZHAgPSBncC0+Y19iYW5kZGV2OworICAgICAgICBpbnQgZHBfaW9fbW9kZSwgZ3BfaW9f
bW9kZTsKKyAgICAgICAgdW5zaWduZWQgbG9uZyBub3cgPSBqaWZmaWVzOworCisgICAgICAgIGRw
X2lvX21vZGUgPSBkcC0+Z19pb19tb2RlOworICAgICAgICBncF9pb19tb2RlID0gZ3AtPmNfaW9f
bW9kZTsKKworICAgICAgICBncC0+Y190aW1lX3NsaWNlX3N0YXJ0ID0gbm93OworCisgICAgICAg
IGlmKGRwX2lvX21vZGUgPT0gTEVGVE9WRVJfSU9fTU9ERSl7CisgICAgICAgICAgICAgICAgZ3At
PmNfdGltZV9zbGljZV9lbmQgPSBub3cgKyBsZWZ0b3Zlcl90aW1lX3NsaWNlX2Jhc2U7CisgICAg
ICAgICAgICAgICAgcmV0dXJuIDA7CisgICAgICAgIH0KKworICAgICAgICBpZihncF9pb19tb2Rl
ID09IE1JTkJXX0lPX01PREUpCisgICAgICAgICAgICAgICAgZ3AtPmNfdGltZV9zbGljZV9lbmQg
PSBub3cgKyBncC0+Y190aW1lX3NsaWNlOworICAgICAgICBlbHNlIGlmKGdwX2lvX21vZGUgPT0g
UkFOR0VfSU9fTU9ERSkKKyAgICAgICAgICAgICAgICBncC0+Y190aW1lX3NsaWNlX2VuZCA9IG5v
dyArIHJhbmdlX3RpbWVfc2xpY2VfYmFzZTsKKyAgICAgICAgZWxzZSAvLyBncF9pb19tb2RlID09
IERFRkFVTFRfSU9fTU9ERQorICAgICAgICAgICAgICAgIGdwLT5jX3RpbWVfc2xpY2VfZW5kID0g
bm93ICsgdGltZV9zbGljZV9iYXNlOworCisgICAgICAgIGdwLT5jX3RpbWVfc2xpY2VfZXhwaXJl
ZCA9IFRJTUVfU0xJQ0VfTk9UX0VYUElSRUQ7CisKKyAgICAgICAgcmV0dXJuIDA7Cit9CisKKy8q
CisgKiBDYWxjdWxhdGUgdGhlIHByaW9yaXR5IG9mIGdpdmVuIGlvYmFuZF9ncm91cCAKKyAqLwor
c3RhdGljIGludCByYW5nZV9id19wcmlvcml0eShzdHJ1Y3QgaW9iYW5kX2dyb3VwICogZ3ApCit7
CisJc3RydWN0IGlvYmFuZF9kZXZpY2UgKmRwID0gZ3AtPmNfYmFuZGRldjsKKwlpbnQgcHJpbyA9
IDA7CisKKwlpZihkcC0+Z19pb19tb2RlID09IExFRlRPVkVSX0lPX01PREUpeworCQlwcmlvID0g
cmFuZG9tMzIoKSAlIE1JTkJXX1BSSU9fQkFTRTsKKwkJaWYocHJpbyA9PSAwKQorCQkJcHJpbyA9
IDE7CisJfWVsc2UgaWYoZ3AtPmNfaW9fbW9kZSA9PSBNSU5CV19JT19NT0RFKXsKKwkJcHJpbyA9
IChncC0+Y19taW5fYndfdG9rZW4gLSBncC0+Y19jb25zdW1lZF9taW5fYndfdG9rZW4pICogTUlO
QldfUFJJT19CQVNFOworCX1lbHNlIGlmKGdwLT5jX2lvX21vZGUgPT0gREVGQVVMVF9JT19NT0RF
KXsKKwkJcHJpbyA9IE1JTkJXX1BSSU9fQkFTRTsKKwl9ZWxzZSBpZihncC0+Y19pb19tb2RlID09
IFJBTkdFX0lPX01PREUpeworCQlwcmlvID0gTUlOQldfUFJJT19CQVNFIC8gMjsKKwl9ZWxzZXsK
KwkJcHJpbyA9IDA7CisJfQorCisJcmV0dXJuIHByaW87Cit9CisKKy8qCisgKiBDaGVjayB3aGV0
aGVyIHRoaXMgZ3JvdXAgaGFzIHJpZ2h0IHRvIGlzc3VlIGFuIEkvTyBpbiByYW5nZS1idyBwb2xp
Y3kgbW9kZS4KKyAqICBSZXR1cm4gMCBpZiBpdCBkb2Vzbid0IGhhdmUgcmlnaHQsIG90aGVyd2lz
ZSByZXR1cm4gdGhlIG5vbi16ZXJvIHZhbHVlLgorICovCitzdGF0aWMgaW50IGhhc19yaWdodF90
b19pc3N1ZShzdHJ1Y3QgaW9iYW5kX2dyb3VwICpncCkKK3sKKwlzdHJ1Y3QgaW9iYW5kX2Rldmlj
ZSAqZHAgPSBncC0+Y19iYW5kZGV2OworCWludCBwcmlvOworCisJaWYoZ3AtPmNfcHJpb19ibG9j
a2VkID4gMCB8fCBncC0+Y19ibG9ja2VkIC0gZ3AtPmNfcHJpb19ibG9ja2VkID4gMCl7CisJCXBy
aW8gPSByYW5nZV9id19wcmlvcml0eShncCk7CisJCWlmKHByaW8gPD0gMCkKKwkJCXJldHVybiAx
OworCQlyZXR1cm4gcHJpbzsKKwl9CisKKwlpZihncCA9PSBkcC0+Z19ydW5uaW5nX2dwKXsKKwor
CQlpZihncC0+Y190aW1lX3NsaWNlX2V4cGlyZWQgPT0gVElNRV9TTElDRV9FWFBJUkVEKXsKKwor
CQkJZ3AtPmNfdGltZV9zbGljZV9leHBpcmVkID0gVElNRV9TTElDRV9OT1RfRVhQSVJFRDsKKwkJ
CWdwLT5jX3RpbWVfc2xpY2VfZW5kID0gMDsKKworCQkJcmV0dXJuIDA7CisJCX0KKyAKKwkJaWYo
Z3AtPmNfdGltZV9zbGljZV9lbmQgPT0gMCkKKwkJCXNldF90aW1lX3NsaWNlKGdwKTsKKworCQly
ZXR1cm4gcmFuZ2VfYndfcHJpb3JpdHkoZ3ApOworCisJfQorCisJZHAtPmdfcnVubmluZ19ncCA9
IGdwOworCXNldF90aW1lX3NsaWNlKGdwKTsKKworCXJldHVybiByYW5nZV9id19wcmlvcml0eShn
cCk7Cit9CisKKy8qCisgKiBSZXNldCBhbGwgdmFyaWFibGVzIHJlbGF0ZWQgd2l0aCByYW5nZS1i
dyB0b2tlbiBhbmQgdGltZSBzbGljZSAKKyAqLworc3RhdGljIGludCByZXNldF9yYW5nZV9id190
b2tlbihzdHJ1Y3QgaW9iYW5kX2dyb3VwICogZ3AsIHVuc2lnbmVkIGxvbmcgbm93KQoreworICAg
ICAgICBzdHJ1Y3QgaW9iYW5kX2RldmljZSAqZHAgPSBncC0+Y19iYW5kZGV2OworICAgICAgICBz
dHJ1Y3QgaW9iYW5kX2dyb3VwICpwOworCisgICAgICAgIGxpc3RfZm9yX2VhY2hfZW50cnkocCwg
JmRwLT5nX2dyb3VwcywgY19saXN0KXsKKyAgICAgICAgICAgICAgICBwLT5jX2NvbnN1bWVkX21p
bl9id190b2tlbiA9IDA7CisgICAgICAgICAgICAgICAgcC0+Y19pc19vdmVyX21heF9idyA9IE1B
WF9CV19VTkRFUjsKKwkJaWYocC0+Y19pb19tb2RlICE9IERFRkFVTFRfSU9fTU9ERSkKKwkJCXAt
PmNfaW9fbW9kZSA9IE1JTkJXX0lPX01PREU7CisgICAgICAgIH0KKworICAgICAgICBkcC0+Z19j
b25zdW1lZF9taW5fYndfdG9rZW4gPSAwOworCisgICAgICAgIGRwLT5nX25leHRfdGltZV9wZXJp
b2QgPSBub3cgKyBIWjsKKyAgICAgICAgZHAtPmdfdGltZV9wZXJpb2RfZXhwaXJlZCA9IFRJTUVf
U0xJQ0VfTk9UX0VYUElSRUQ7CisgICAgICAgIGRwLT5nX2lvX21vZGUgPSBNSU5CV19JT19NT0RF
OworCisJIGxpc3RfZm9yX2VhY2hfZW50cnkocCwgJmRwLT5nX2dyb3VwcywgY19saXN0KXsKKyAg
ICAgICAgCWlmKHdhaXRxdWV1ZV9hY3RpdmUoJnAtPmNfbWF4X2J3X292ZXJfd2FpdHEpKQorICAg
ICAgICAgICAgICAgIAl3YWtlX3VwX2FsbCgmcC0+Y19tYXhfYndfb3Zlcl93YWl0cSk7CisgICAg
ICAgIH0KKyAgICAgICAgcmV0dXJuIDA7Cit9CisKKy8qCisgKiBVc2UgdG9rZW5zKEluY3JlYXNl
IHRoZSBudW1iZXIgb2YgY29uc3VtZWQgdG9rZW4pIHRvIGlzc3VlIGFuIEkvTyBmb3IgZ3VyYW50
ZWVpbmcgdGhlIHJhbmdlLWJ3LiAKKyAqIGFuZCBjaGVjayB0aGUgZXhwaXJhdGlvbiBvZiBsb2Nh
bCBhbmQgZ2xvYmFsIHRpbWUgc2xpY2UsIGFuZCBvdmVyZmxvdyBvZiBtYXggYncKKyAqLworc3Rh
dGljIGludCByYW5nZV9id19jb25zdW1lX3Rva2VuKHN0cnVjdCBpb2JhbmRfZ3JvdXAgKmdwLCBp
bnQgY291bnQsIGludCBmbGFnKQoreworICAgICAgICBzdHJ1Y3QgaW9iYW5kX2RldmljZSAqZHAg
PSBncC0+Y19iYW5kZGV2OworICAgICAgICBzdHJ1Y3QgaW9iYW5kX2dyb3VwICpwOworICAgICAg
ICB1bnNpZ25lZCBsb25nIG5vdyA9IGppZmZpZXM7CisgICAgICAgIGludCBpb19tb2RlOworCisg
ICAgICAgIGRwLT5nX2N1cnJlbnQgPSBncDsKKworICAgICAgICBpZihkcC0+Z19uZXh0X3RpbWVf
cGVyaW9kID09IDApeworICAgICAgICAgICAgICAgIGRwLT5nX25leHRfdGltZV9wZXJpb2QgPSBu
b3cgKyBIWjsKKyAgICAgICAgICAgICAgICBkcC0+Z190aW1lX3BlcmlvZF9leHBpcmVkID0gVElN
RV9TTElDRV9OT1RfRVhQSVJFRDsKKyAgICAgICAgfQorIAorICAgICAgICBpZih0aW1lX2FmdGVy
KG5vdywgZHAtPmdfbmV4dF90aW1lX3BlcmlvZCkpeworICAgICAgICAgICAgICAgIHJlc2V0X3Jh
bmdlX2J3X3Rva2VuKGdwLCBub3cpOworICAgICAgICB9ZWxzZXsKKyAgICAgICAgICAgICAgICBn
cC0+Y19jb25zdW1lZF9taW5fYndfdG9rZW4gKz0gY291bnQ7CisgICAgICAgICAgICAgICAgZHAt
PmdfY29uc3VtZWRfbWluX2J3X3Rva2VuICs9IGNvdW50OworCisgICAgICAgICAgICAgICAgaWYo
Z3AtPmNfbWF4X2J3ID4gMCAmJiBncC0+Y19jb25zdW1lZF9taW5fYndfdG9rZW4gPj0gZ3AtPmNf
bWF4X2J3X3Rva2VuKXsKKyAgICAgICAgICAgICAgICAgICAgICAgIGdwLT5jX2lzX292ZXJfbWF4
X2J3ID0gTUFYX0JXX09WRVI7CisJCQlncC0+Y19pb19tb2RlID0gTk9fSU9fTU9ERTsKKwkJCXJl
dHVybiBSX1lJRUxEOworICAgICAgICAgICAgICAgIH0KKworICAgICAgICAgICAgICAgIGlmKGdw
LT5jX2lvX21vZGUgIT0gUkFOR0VfSU9fTU9ERSAmJiBncC0+Y19taW5fYndfdG9rZW4gPD0gZ3At
PmNfY29uc3VtZWRfbWluX2J3X3Rva2VuKXsKKyAgICAgICAgICAgICAgICAgICAgICAgIGdwLT5j
X2lvX21vZGUgPSBSQU5HRV9JT19NT0RFOworCisgICAgICAgICAgICAgICAgICAgICAgICBpZihk
cC0+Z190b3RhbF9taW5fYndfdG9rZW4gPD0gZHAtPmdfY29uc3VtZWRfbWluX2J3X3Rva2VuKXsK
KyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgbGlzdF9mb3JfZWFjaF9lbnRyeShwLCAm
ZHAtPmdfZ3JvdXBzLCBjX2xpc3QpeworICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgIGlmKHAtPmNfaW9fbW9kZSA9PSBSQU5HRV9JT19NT0RFIHx8IHAtPmNfaW9fbW9kZSA9
PSBERUZBVUxUX0lPX01PREUpeworICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgaW9fbW9kZSA9IDE7CisgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgfWVsc2V7CisgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICBpb19tb2RlID0gMDsKKyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgIGJyZWFrOworICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgIH0KKyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgfQorCisgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgIGlmKGlvX21vZGUgJiYgZHAtPmdfaW9fbW9kZSA9PSBNSU5CV19J
T19NT0RFKQorICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGRwLT5nX2lv
X21vZGUgPSBMRUZUT1ZFUl9JT19NT0RFOworICAgICAgICAgICAgICAgICAgICAgICAgfQorICAg
ICAgICAgICAgICAgIH0KKyAgICAgICAgfQorCisgICAgICAgIGlmKGdwLT5jX3RpbWVfc2xpY2Vf
ZW5kICE9IDAgJiYgdGltZV9hZnRlcihub3csIGdwLT5jX3RpbWVfc2xpY2VfZW5kKSl7CisgICAg
ICAgICAgICAgICAgZ3AtPmNfdGltZV9zbGljZV9leHBpcmVkID0gVElNRV9TTElDRV9FWFBJUkVE
OworCQlyZXR1cm4gUl9ZSUVMRDsKKyAgICAgICAgfQorCisgICAgICAgIHJldHVybiBSX09LOwor
fQorCisvKgorICogQ2hlY2sgaWYgdGhpcyBncm91cCBpcyBhYmxlIHRvIHJlY2VpdmUgYSBuZXcg
YmlvLgorICogaW4gcmFuZ2UgYncgcG9saWN5LCB3ZSBvbmx5IGNoZWNrIHRoYXQgaW9iYW5kIGRl
dmljZSBzaG91bGQgYmUgYmxvY2tlZAorICovCitzdGF0aWMgaW50IHJhbmdlX2J3X3F1ZXVlX2Z1
bGwoc3RydWN0IGlvYmFuZF9ncm91cCAqZ3ApCit7CisJCisJcmV0dXJuIChncC0+Y19ibG9ja2Vk
ID49IGdwLT5jX2xpbWl0KTsKK30KKworLyoKKyAqIENvbnZlcnQgdGhlIGJ3IHZhbHVzZSB0byB0
aGUgbnVtYmVyIG9mIGJ3IHRva2VuCisgKiBidyA6IEtieXRlIHVuaXQgYmFuZHdpZHRoCisgKiB0
b2tlbl9iYXNlIDogdGhlIG51bWJlciBvZiB0b2tlbnMgdXNlZCBmb3Igb25lIDFLYnl0ZS1zaXpl
IElPCisgKiAtLSBBdHRlbnRpb24gOiBDdXJyZW50bHksIFdlIHN1cHBvcnQgdGhlIDUxMmJ5dGUg
b3IgMUtieXRlIHBlciAxIHRva2VuCisgKi8KK3N0YXRpYyBpbnQgY29udmVydF9id190b190b2tl
bihpbnQgYncsIGludCB0b2tlbl91bml0KQoreworCWludAl0b2tlbjsKKwlpbnQJdG9rZW5fYmFz
ZTsgCisKKwl0b2tlbl9iYXNlID0gKDEgPDwgdG9rZW5fdW5pdCkgLyA0OyAvLyB0b2tlbl9iYXNl
IGlzIDEgb3IgMgorCXRva2VuID0gYncgKiB0b2tlbl9iYXNlOworCQorCXJldHVybiB0b2tlbjsK
K30KKworCisvKgorICogQWxsb2NhdGUgdGhlIHRpbWUgc2xpY2UgZm9yIE1JTkJXX0lPX01PREUg
dG8gZWFjaCBncm91cCAKKyAqLworc3RhdGljIHZvaWQgcmFuZ2VfYndfdGltZV9zbGljZV9pbml0
KHN0cnVjdCBpb2JhbmRfZ3JvdXAgKiBncCkKK3sKKwlzdHJ1Y3QgaW9iYW5kX2RldmljZSAqIGRw
ID0gZ3AtPmNfYmFuZGRldjsKKwlzdHJ1Y3QgaW9iYW5kX2dyb3VwICogcDsKKworICAgICAgICBs
aXN0X2Zvcl9lYWNoX2VudHJ5KHAsICZkcC0+Z19ncm91cHMsIGNfbGlzdCl7CisJCWlmKHAtPmNf
bWluX2J3ID09IDApCisJCQlwLT5jX3RpbWVfc2xpY2UgPSB0aW1lX3NsaWNlX2Jhc2U7CisJCWVs
c2UKKwkJCXAtPmNfdGltZV9zbGljZSA9IHRpbWVfc2xpY2VfYmFzZSArICgodGltZV9zbGljZV9i
YXNlICogcC0+Y19taW5fYncpIC8gZHAtPmdfbWluX2J3X3RvdGFsKTsKKyAgICAgICAgfQorfQor
CisKKy8qCisgKiBBbGxvY2F0ZSB0aGUgbWluX2J3IGFuZCBtaW5fYndfdG9rZW4gdG8gdGhlIGdp
dmVuIGdyb3VwCisgKi8KK3N0YXRpYyB2b2lkIHNldF9taW5fYncoc3RydWN0IGlvYmFuZF9ncm91
cCAqZ3AsIGludCBuZXcpCit7CisJc3RydWN0IGlvYmFuZF9kZXZpY2UgKmRwID0gZ3AtPmNfYmFu
ZGRldjsKKwlzdHJ1Y3QgaW9iYW5kX2dyb3VwICogcDsKKwlpbnQJdG9rZW5fdW5pdDsKKworCWRw
LT5nX21pbl9id190b3RhbCArPSAobmV3IC0gZ3AtPmNfbWluX2J3KTsKKwlncC0+Y19taW5fYncg
PSBuZXc7CisKKyAgICAgICAgaWYobmV3KQorICAgICAgICAgICAgICAgIGdwLT5jX2lvX21vZGUg
PSBNSU5CV19JT19NT0RFOworICAgICAgICBlbHNlCisgICAgICAgICAgICAgICAgZ3AtPmNfaW9f
bW9kZSA9IERFRkFVTFRfSU9fTU9ERTsKKwkKKwlyYW5nZV9id190aW1lX3NsaWNlX2luaXQoZ3Ap
OworCisJdG9rZW5fdW5pdCA9IGRwLT5nX3Rva2VuX3VuaXQ7CisJZ3AtPmNfbWluX2J3X3Rva2Vu
ID0gY29udmVydF9id190b190b2tlbihncC0+Y19taW5fYncsIHRva2VuX3VuaXQpOworCWRwLT5n
X3RvdGFsX21pbl9id190b2tlbiA9IGNvbnZlcnRfYndfdG9fdG9rZW4oZHAtPmdfbWluX2J3X3Rv
dGFsLCB0b2tlbl91bml0KTsKKworICAgICAgICBpZiAoZHAtPmdfbWluX2J3X3RvdGFsID09IDAp
IHsKKyAgICAgICAgICAgICAgICBsaXN0X2Zvcl9lYWNoX2VudHJ5KHAsICZkcC0+Z19ncm91cHMs
IGNfbGlzdCkKKyAgICAgICAgICAgICAgICAgICAgICAgIHAtPmNfbGltaXQgPSAxOworICAgICAg
ICB9IGVsc2UgeworICAgICAgICAgICAgICAgIGxpc3RfZm9yX2VhY2hfZW50cnkocCwgJmRwLT5n
X2dyb3VwcywgY19saXN0KSB7CisgICAgICAgICAgICAgICAgICAgICAgICBwLT5jX2xpbWl0ID0g
KGRwLT5nX2lvX2xpbWl0WzBdICsgZHAtPmdfaW9fbGltaXRbMV0pICoKKyAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgcC0+Y19taW5fYncgLyBkcC0+Z19taW5fYndfdG90YWwgLworICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICBPVkVSX0lPX1JBVEUgKyAxOworICAgICAgICAg
ICAgICAgIH0KKyAgICAgICAgfQorCisJcmV0dXJuOworfQorCisvKgorICogQWxsb2NhdGUgdGhl
IG1heF9idyBhbmQgbWF4X2J3X3Rva2VuIHRvIHRoZSBwb2ludGVkIGdyb3VwCisgKi8KK3N0YXRp
YyB2b2lkIHNldF9tYXhfYncoc3RydWN0IGlvYmFuZF9ncm91cCAqZ3AsIGludCBuZXcpCit7CisJ
c3RydWN0IGlvYmFuZF9kZXZpY2UgKmRwID0gZ3AtPmNfYmFuZGRldjsKKwlpbnQJdG9rZW5fdW5p
dDsJCisKKwl0b2tlbl91bml0ID0gZHAtPmdfdG9rZW5fdW5pdDsKKworCWdwLT5jX21heF9idyA9
IG5ldzsKKwlncC0+Y19tYXhfYndfdG9rZW4gPSBjb252ZXJ0X2J3X3RvX3Rva2VuKG5ldywgdG9r
ZW5fdW5pdCk7CisKKwlyZXR1cm47CisKK30KKworc3RhdGljIHZvaWQgaW5pdF9yYW5nZV9id190
b2tlbl9idWNrZXQoc3RydWN0IGlvYmFuZF9kZXZpY2UgKmRwLCBpbnQgdmFsKQoreworCWRwLT5n
X3Rva2VuX2J1Y2tldCA9ICgoZHAtPmdfaW9fbGltaXRbMF0gKyBkcC0+Z19pb19saW1pdFsxXSkg
KgorCQkJCSBERUZBVUxUX0JVQ0tFVCkgPDwgZHAtPmdfdG9rZW5fdW5pdDsKKwlpZiAoIXZhbCkK
KwkJdmFsID0gREVGQVVMVF9UT0tFTlBPT0wgPDwgZHAtPmdfdG9rZW5fdW5pdDsKKwlpZiAodmFs
IDwgZHAtPmdfdG9rZW5fYnVja2V0KQorCQl2YWwgPSBkcC0+Z190b2tlbl9idWNrZXQ7CisJZHAt
PmdfY2FycnlvdmVyID0gdmFsL2RwLT5nX3Rva2VuX2J1Y2tldDsKKwlkcC0+Z190b2tlbl9sZWZ0
ID0gMDsKK30KKworc3RhdGljIGludCBwb2xpY3lfcmFuZ2VfYndfcGFyYW0oc3RydWN0IGlvYmFu
ZF9ncm91cCAqZ3AsIGNoYXIgKmNtZCwgY2hhciAqdmFsdWUpCit7CisJbG9uZyB2YWw7CisJaW50
IHIgPSAwLCBlcnI7CisKKwllcnIgPSBzdHJpY3Rfc3RydG9sKHZhbHVlLCAwLCAmdmFsKTsKKwor
CWlmICghc3RyY21wKGNtZCwgIm1pbi1idyIpKSB7CisJCWlmICghZXJyICYmIDAgPD0gdmFsICYm
IHZhbCA8PSAoSU5UX01BWCAvIDIpKQorCQkJc2V0X21pbl9idyhncCwgdmFsKTsKKwkJZWxzZQor
CQkJciA9IC1FSU5WQUw7CisJfSBlbHNlIGlmICghc3RyY21wKGNtZCwgIm1heC1idyIpKSB7CisJ
CWlmICgoIWVyciAmJiAwIDw9IHZhbCAmJiB2YWwgPD0gKElOVF9NQVggLyAyKSAmJiBncC0+Y19t
aW5fYncgPD0gdmFsKSB8fCB2YWwgPT0gMCkgCisJCQlzZXRfbWF4X2J3KGdwLCB2YWwpOworCQll
bHNlCisJCQlyID0gLUVJTlZBTDsKKwl9IGVsc2UgeworCQlyID0gLUVJTlZBTDsKKwl9CisKKwly
ZXR1cm4gcjsKK30KKworc3RhdGljIGludCBwb2xpY3lfcmFuZ2VfYndfY3RyKHN0cnVjdCBpb2Jh
bmRfZ3JvdXAgKmdwLCBjaGFyICphcmcpCit7CisJaW50IHJldDsKKworCWlmICghYXJnKQorCQlh
cmcgPSBfX3N0cmluZ2lmeShERUZBVUxUX01JTl9CVyk7CisKKwlpbml0X3dhaXRxdWV1ZV9oZWFk
KCZncC0+Y19tYXhfYndfb3Zlcl93YWl0cSk7CisJc3Bpbl9sb2NrX2luaXQoJmdwLT5jX2xvY2sp
OwkKKworCWdwLT5jX21pbl9idyA9IDA7CisJZ3AtPmNfbWF4X2J3ID0gMDsKKwlncC0+Y19pb19t
b2RlICA9IERFRkFVTFRfSU9fTU9ERTsKKwlncC0+Y190aW1lX3NsaWNlX2V4cGlyZWQgPSBUSU1F
X1NMSUNFX05PVF9FWFBJUkVEOworCWdwLT5jX21pbl9id190b2tlbiA9IDA7CisJZ3AtPmNfbWF4
X2J3X3Rva2VuID0gMDsKKwlncC0+Y19jb25zdW1lZF9taW5fYndfdG9rZW4gPSAwOworCWdwLT5j
X2lzX292ZXJfbWF4X2J3ID0gTUFYX0JXX1VOREVSOworCWdwLT5jX3RpbWVfc2xpY2Vfc3RhcnQg
PSAwOworCWdwLT5jX3RpbWVfc2xpY2VfZW5kID0gMDsKKwlncC0+Y193YWl0X3BfY291bnQgPSAw
Oy8vCisKKwlncC0+Y190aW1lX3NsaWNlID0gdGltZV9zbGljZV9iYXNlOworCisgICAgICAgIGdw
LT5jX3RpbWVyID0ga21hbGxvYyhzaXplb2Yoc3RydWN0IHRpbWVyX2xpc3QpLCBHRlBfS0VSTkVM
KTsKKyAgICAgICAgaWYoZ3AtPmNfdGltZXIgPT0gTlVMTCkgcmV0dXJuIC1FSU5WQUw7IC8vIHJl
dHVybiB2YWx1ZSBtYXkgYmUgbm90IGFwcHJvcHJpYXRlICEhIQorICAgICAgICBtZW1zZXQoZ3At
PmNfdGltZXIsIDAsIHNpemVvZihzdHJ1Y3QgdGltZXJfbGlzdCkpOworCWdwLT50aW1lcl9zZXQg
PSAwOworCSAKKwlyZXQgPSBwb2xpY3lfcmFuZ2VfYndfcGFyYW0oZ3AsICJtaW4tYnciLCBhcmcp
OworCisJcmV0dXJuIHJldDsKK30KKworc3RhdGljIHZvaWQgcG9saWN5X3JhbmdlX2J3X2R0cihz
dHJ1Y3QgaW9iYW5kX2dyb3VwICpncCkKK3sKKwlzdHJ1Y3QgaW9iYW5kX2RldmljZSAqZHAgPSBn
cC0+Y19iYW5kZGV2OworCisJc2V0X21pbl9idyhncCwgMCk7CisJZ3AtPmNfdGltZV9zbGljZSA9
IDA7CisJc2V0X21heF9idyhncCwgMCk7CisKKwlkcC0+Z19ydW5uaW5nX2dwID0gTlVMTDsKKwor
CWlmKGdwLT5jX3RpbWVyICE9IE5VTEwpeworCQlkZWxfdGltZXIoZ3AtPmNfdGltZXIpOworCQlr
ZnJlZShncC0+Y190aW1lcik7CisJfQorfQorCitzdGF0aWMgdm9pZCBwb2xpY3lfcmFuZ2VfYndf
c2hvdyhzdHJ1Y3QgaW9iYW5kX2dyb3VwICpncCwgaW50ICpzenAsCisJCQkJCWNoYXIgKnJlc3Vs
dCwgdW5zaWduZWQgaW50IG1heGxlbikKK3sKKwlzdHJ1Y3QgaW9iYW5kX2dyb3VwICpwOworCXN0
cnVjdCBpb2JhbmRfZGV2aWNlICpkcCA9IGdwLT5jX2JhbmRkZXY7CisJc3RydWN0IHJiX25vZGUg
Km5vZGU7CisJaW50IHN6ID0gKnN6cDsgLyogdXNlZCBpbiBETUVNSVQoKSAqLworCisJRE1FTUlU
KCIgJWQgOiVkIiwgZHAtPmdfdG9rZW5fYnVja2V0ICogZHAtPmdfY2FycnlvdmVyLCBncC0+Y19t
aW5fYncpOworCisJZm9yIChub2RlID0gcmJfZmlyc3QoJmdwLT5jX2dyb3VwX3Jvb3QpOyBub2Rl
OyBub2RlID0gcmJfbmV4dChub2RlKSkgeworCQlwID0gcmJfZW50cnkobm9kZSwgc3RydWN0IGlv
YmFuZF9ncm91cCwgY19ncm91cF9ub2RlKTsKKwkJRE1FTUlUKCIgJWQ6JWQ6JWQiLCBwLT5jX2lk
LCBwLT5jX21pbl9idywgcC0+Y19tYXhfYncpOworCX0KKwkqc3pwID0gc3o7Cit9CisKK3N0YXRp
YyBpbnQgcmFuZ2VfYndfcHJlcGFyZV90b2tlbihzdHJ1Y3QgaW9iYW5kX2dyb3VwICpncCwgc3Ry
dWN0IGJpbyAqYmlvLCBpbnQgZmxhZykKK3sKKwlzdHJ1Y3QgaW9iYW5kX2RldmljZSAqZHAgPSBn
cC0+Y19iYW5kZGV2OworCWludCB1bml0OworCWludCBiaW9fY291bnQ7IAorCWludCB0b2tlbl9j
b3VudCA9IDA7CisKKwl1bml0ID0gKDEgPDwgZHAtPmdfdG9rZW5fdW5pdCk7CisJYmlvX2NvdW50
ID0gYmlvX3NlY3RvcnMoYmlvKTsKKworCWlmKHVuaXQgPT0gOCkgLy8gMSB0b2tlbiBpcyB1c2Vk
IGZvciA1MTIgYnl0ZXMKKwkJdG9rZW5fY291bnQgPSBiaW9fY291bnQ7CisJZWxzZSBpZih1bml0
ID09IDQpIC8vIDEgdG9rZW4gaXMgdXNlZCBmb3IgMTAyNCBieXRlcworCQl0b2tlbl9jb3VudCA9
IGJpb19jb3VudCAvIDI7CisJZWxzZSBpZih1bml0ID09IDIpIC8vIDEgdG9rZW4gaXMgdXNlZCBm
b3IgMjA0OCBieXRlcworCQl0b2tlbl9jb3VudCA9IGJpb19jb3VudCAvIDQ7CisJZWxzZSBpZih1
bml0ID09IDEpIC8vIDEgdG9rZW4gaXMgdXNlZCBmb3IgNDA5NiBieXRlcworCQl0b2tlbl9jb3Vu
dCA9IGJpb19jb3VudCAvIDg7CisKKwlyZXR1cm4gcmFuZ2VfYndfY29uc3VtZV90b2tlbihncCwg
dG9rZW5fY291bnQsIGZsYWcpOworfQorCit2b2lkIHJhbmdlX2J3X3RpbWVyX3JlZ2lzdGVyKHN0
cnVjdCB0aW1lcl9saXN0ICogcHRpbWVyLCB1bnNpZ25lZCBsb25nIHRpbWVvdmVyLCB1bnNpZ25l
ZCBsb25nICBncCkKK3sKKwlzdHJ1Y3QgaW9iYW5kX2dyb3VwICogZ3JvdXAgPSAoc3RydWN0IGlv
YmFuZF9ncm91cCAqKWdwOworCisJaWYoZ3JvdXAtPnRpbWVyX3NldCA9PSAwKXsKKwkJaW5pdF90
aW1lcihwdGltZXIpOworCQlwdGltZXItPmV4cGlyZXMgPSBnZXRfamlmZmllc182NCgpICsgdGlt
ZW92ZXI7CisJCXB0aW1lci0+ZGF0YSA9IGdwOworCQlwdGltZXItPmZ1bmN0aW9uID0gcmFuZ2Vf
YndfdGltZW92ZXI7CisJCWFkZF90aW1lcihwdGltZXIpOworCQlncm91cC0+dGltZXJfc2V0ID0g
MTsKKwl9Cit9CisKKy8qCisgKiBUaW1lciBIYW5kbGVyIGZ1bmN0aW9uIHRvIHByb3RlY3QgdGhl
IGFsbCBwcm9jZXNzZXMncyBoYW5naW5nIGluIGxvd2VyIG1pbi1idyBjb25maWd1cmF0aW9uIAor
ICovCit2b2lkIHJhbmdlX2J3X3RpbWVvdmVyKHVuc2lnbmVkIGxvbmcgZ3ApCit7CisJc3RydWN0
IGlvYmFuZF9ncm91cCAqIGdyb3VwID0gKHN0cnVjdCBpb2JhbmRfZ3JvdXAgKilncDsKKworCWlm
KGdyb3VwLT5jX2lzX292ZXJfbWF4X2J3ID09IE1BWF9CV19PVkVSKXsKKwkJZ3JvdXAtPmNfaXNf
b3Zlcl9tYXhfYncgPSBNQVhfQldfVU5ERVI7CisJfQorCisJaWYoZ3JvdXAtPmNfaW9fbW9kZSA9
PSBOT19JT19NT0RFKXsKKwkJZ3JvdXAtPmNfaW9fbW9kZSA9IE1JTkJXX0lPX01PREU7CisJfQor
CisJaWYod2FpdHF1ZXVlX2FjdGl2ZSgmZ3JvdXAtPmNfbWF4X2J3X292ZXJfd2FpdHEpKQorCQl3
YWtlX3VwX2FsbCgmZ3JvdXAtPmNfbWF4X2J3X292ZXJfd2FpdHEpOworCQorCWdyb3VwLT50aW1l
cl9zZXQgPSAwOworfQorCisvKgorICogIDxNZXRob2Q+ICAgICAgPGRlc2NyaXB0aW9uPgorICog
Z19jYW5fc3VibWl0ICAgOiBUbyBkZXRlcm1pbmUgd2hldGhlciBhIGdpdmVuIGdyb3VwIGhhcyB0
aGUgcmlnaHQgdG8KKyAqICAgICAgICAgICAgICAgICAgc3VibWl0IEJJT3MuIFRoZSBsYXJnZXIg
dGhlIHJldHVybiB2YWx1ZSB0aGUgaGlnaGVyIHRoZQorICogICAgICAgICAgICAgICAgICBwcmlv
cml0eSB0byBzdWJtaXQuIFplcm8gbWVhbnMgaXQgaGFzIG5vIHJpZ2h0LgorICogZ19wcmVwYXJl
X2JpbyAgOiBDYWxsZWQgcmlnaHQgYmVmb3JlIHN1Ym1pdHRpbmcgZWFjaCBCSU8uCisgKiBnX3Jl
c3RhcnRfYmlvcyA6IENhbGxlZCBpZiB0aGlzIGlvYmFuZCBkZXZpY2UgaGFzIHNvbWUgQklPcyBi
bG9ja2VkIGJ1dCBub25lCisgKiAgICAgICAgICAgICAgICAgIG9mIHRoZW0gY2FuIGJlIHN1Ym1p
dHRlZCBub3cuIFRoaXMgbWV0aG9kIGhhcyB0bworICogICAgICAgICAgICAgICAgICByZWluaXRp
YWxpemUgdGhlIGRhdGEgdG8gcmVzdGFydCB0byBzdWJtaXQgQklPcyBhbmQgcmV0dXJuCisgKiAg
ICAgICAgICAgICAgICAgIDAgb3IgMS4KKyAqICAgICAgICAgICAgICAgICAgVGhlIHJldHVybiB2
YWx1ZSAwIG1lYW5zIHRoYXQgaXQgaGFzIGJlY29tZSBhYmxlIHRvIHN1Ym1pdAorICogICAgICAg
ICAgICAgICAgICB0aGVtIG5vdyBzbyB0aGF0IHRoaXMgaW9iYW5kIGRldmljZSB3aWxsIGNvbnRp
bnVlIGl0cyB3b3JrLgorICogICAgICAgICAgICAgICAgICBUaGUgcmV0dXJuIHZhbHVlIDEgbWVh
bnMgdGhhdCBpdCBpcyBzdGlsbCB1bmFibGUgdG8gc3VibWl0CisgKiAgICAgICAgICAgICAgICAg
IHRoZW0gc28gdGhhdCB0aGlzIGRldmljZSB3aWxsIHN0b3AgaXRzIHdvcmsuIEFuZCB0aGlzCisg
KiAgICAgICAgICAgICAgICAgIHBvbGljeSBtb2R1bGUgaGFzIHRvIHJlYWN0aXZhdGUgdGhlIGRl
dmljZSB3aGVuIGl0IGdldHMKKyAqICAgICAgICAgICAgICAgICAgdG8gYmUgYWJsZSB0byBzdWJt
aXQgQklPcy4KKyAqIGdfaG9sZF9iaW8gICAgIDogVG8gaG9sZCBhIGdpdmVuIEJJTyB1bnRpbCBp
dCBpcyBzdWJtaXR0ZWQuCisgKiAgICAgICAgICAgICAgICAgIFRoZSBkZWZhdWx0IGZ1bmN0aW9u
IGlzIHVzZWQgd2hlbiB0aGlzIG1ldGhvZCBpcyB1bmRlZmluZWQuCisgKiBnX3BvcF9iaW8gICAg
ICA6IFRvIHNlbGVjdCBhbmQgZ2V0IHRoZSBiZXN0IEJJTyB0byBzdWJtaXQuCisgKiBnX2dyb3Vw
X2N0ciAgICA6IFRvIGluaXRhbGl6ZSB0aGUgcG9saWN5IG93biBtZW1iZXJzIG9mIHN0cnVjdCBp
b2JhbmRfZ3JvdXAuCisgKiBnX2dyb3VwX2R0ciAgICA6IENhbGxlZCB3aGVuIHN0cnVjdCBpb2Jh
bmRfZ3JvdXAgaXMgcmVtb3ZlZC4KKyAqIGdfc2V0X3BhcmFtICAgIDogVG8gdXBkYXRlIHRoZSBw
b2xpY3kgb3duIGRhdGUuCisgKiAgICAgICAgICAgICAgICAgIFRoZSBwYXJhbWV0ZXJzIGNhbiBi
ZSBwYXNzZWQgdGhyb3VnaCAiZG1zZXR1cCBtZXNzYWdlIgorICogICAgICAgICAgICAgICAgICBj
b21tYW5kLgorICogZ19zaG91bGRfYmxvY2sgOiBDYWxsZWQgZXZlcnkgdGltZSB0aGlzIGlvYmFu
ZCBkZXZpY2UgcmVjZWl2ZSBhIEJJTy4KKyAqICAgICAgICAgICAgICAgICAgUmV0dXJuIDEgaWYg
YSBnaXZlbiBncm91cCBjYW4ndCByZWNlaXZlIGFueSBtb3JlIEJJT3MsCisgKiAgICAgICAgICAg
ICAgICAgIG90aGVyd2lzZSByZXR1cm4gMC4KKyAqIGdfc2hvdyAgICAgICAgIDogU2hvdyB0aGUg
Y29uZmlndXJhdGlvbi4KKyAqLworCitpbnQgcG9saWN5X3JhbmdlX2J3X2luaXQoc3RydWN0IGlv
YmFuZF9kZXZpY2UgKmRwLAorCQkJCQlpbnQgYXJnYywgY2hhciAqKmFyZ3YpCit7CisJbG9uZyB2
YWw7CisJaW50IHIgPSAwOworCisJaWYgKGFyZ2MgPCAxKQorCQl2YWwgPSAwOworCWVsc2Ugewor
CQlyID0gc3RyaWN0X3N0cnRvbChhcmd2WzBdLCAwLCAmdmFsKTsKKwkJaWYgKHIgfHwgdmFsIDwg
MCkKKwkJCXJldHVybiAtRUlOVkFMOworCX0KKwkKKwlkcC0+Z19jYW5fc3VibWl0ID0gaGFzX3Jp
Z2h0X3RvX2lzc3VlOworCWRwLT5nX3ByZXBhcmVfYmlvID0gcmFuZ2VfYndfcHJlcGFyZV90b2tl
bjsKKwlkcC0+Z19yZXN0YXJ0X2Jpb3MgPSByYW5nZV9id19yZXN0YXJ0X2Jpb3M7CisJZHAtPmdf
Z3JvdXBfY3RyID0gcG9saWN5X3JhbmdlX2J3X2N0cjsKKwlkcC0+Z19ncm91cF9kdHIgPSBwb2xp
Y3lfcmFuZ2VfYndfZHRyOworCWRwLT5nX3NldF9wYXJhbSA9IHBvbGljeV9yYW5nZV9id19wYXJh
bTsKKwlkcC0+Z19zaG91bGRfYmxvY2sgPSByYW5nZV9id19xdWV1ZV9mdWxsOworCWRwLT5nX3No
b3cgID0gcG9saWN5X3JhbmdlX2J3X3Nob3c7CisKKwlkcC0+Z19taW5fYndfdG90YWwgPSAwOwor
CWRwLT5nX3J1bm5pbmdfZ3AgPSBOVUxMOworCWRwLT5nX3RvdGFsX21pbl9id190b2tlbiA9IDA7
CisJZHAtPmdfaW9fbW9kZSA9IE1JTkJXX0lPX01PREU7CisJZHAtPmdfY29uc3VtZWRfbWluX2J3
X3Rva2VuID0gMDsKKwlkcC0+Z19jdXJyZW50ID0gTlVMTDsKKwlkcC0+Z19uZXh0X3RpbWVfcGVy
aW9kID0gMDsKKwlkcC0+Z190aW1lX3BlcmlvZF9leHBpcmVkID0gVElNRV9TTElDRV9OT1RfRVhQ
SVJFRDsKKworCWRwLT5nX3Rva2VuX3VuaXQgPSBQQUdFX1NISUZUIC0gOTsKKwlpbml0X3Jhbmdl
X2J3X3Rva2VuX2J1Y2tldChkcCwgdmFsKTsKKworCXJldHVybiAwOworfQpkaWZmIC11ck4gbGlu
dXgtMi42LjMwLXJjMS1vcmlnL2RyaXZlcnMvbWQvTWFrZWZpbGUgbGludXgtMi42LjMwLXJjMS9k
cml2ZXJzL21kL01ha2VmaWxlCi0tLSBsaW51eC0yLjYuMzAtcmMxLW9yaWcvZHJpdmVycy9tZC9N
YWtlZmlsZQkyMDA5LTA0LTIwIDE4OjE2OjAwLjAwMDAwMDAwMCArMDkwMAorKysgbGludXgtMi42
LjMwLXJjMS9kcml2ZXJzL21kL01ha2VmaWxlCTIwMDktMDQtMjAgMTY6NDI6NDcuMDAwMDAwMDAw
ICswOTAwCkBAIC04LDcgKzgsNyBAQAogZG0tc25hcHNob3QteQkrPSBkbS1zbmFwLm8gZG0tZXhj
ZXB0aW9uLXN0b3JlLm8gZG0tc25hcC10cmFuc2llbnQubyBcCiAJCSAgICBkbS1zbmFwLXBlcnNp
c3RlbnQubwogZG0tbWlycm9yLXkJKz0gZG0tcmFpZDEubwotZG0taW9iYW5kLXkJKz0gZG0taW9i
YW5kLWN0bC5vIGRtLWlvYmFuZC1wb2xpY3kubyBkbS1pb2JhbmQtdHlwZS5vCitkbS1pb2JhbmQt
eQkrPSBkbS1pb2JhbmQtY3RsLm8gZG0taW9iYW5kLXBvbGljeS5vIGRtLWlvYmFuZC10eXBlLm8g
ZG0taW9iYW5kLXJhbmdlYncubwogbWQtbW9kLXkJKz0gbWQubyBiaXRtYXAubwogcmFpZDQ1Ni15
CSs9IHJhaWQ1Lm8KIHJhaWQ2X3BxLXkJKz0gcmFpZDZhbGdvcy5vIHJhaWQ2cmVjb3YubyByYWlk
NnRhYmxlcy5vIFwK
--001485f339387c95940468353f22
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--001485f339387c95940468353f22--
