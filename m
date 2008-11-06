From: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Subject: [patch 4/4] io controller: Put IO controller to use in device mapper
	and standard make_request() function
Date: Thu, 06 Nov 2008 10:30:26 -0500
Message-ID: <20081106153135.944900461__11273.5794195489$1225986276$gmane$org@redhat.com>
References: <20081106153022.215696930@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=bio-cgroup-tweak-make-request-functions.patch
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


o Tweak standard make_request() function and also the device mapper make
  request functions to enable use of IO controller.

Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Index: linux17/drivers/md/dm.c
===================================================================
--- linux17.orig/drivers/md/dm.c	2008-11-05 18:12:42.000000000 -0500
+++ linux17/drivers/md/dm.c	2008-11-06 09:16:32.000000000 -0500
@@ -22,6 +22,7 @@
 #include <linux/hdreg.h>
 #include <linux/blktrace_api.h>
 #include <linux/smp_lock.h>
+#include <linux/biocontrol.h>
 
 #define DM_MSG_PREFIX "core"
 
@@ -885,6 +886,7 @@ static int dm_request(struct request_que
 	int r = -EIO;
 	int rw = bio_data_dir(bio);
 	struct mapped_device *md = q->queuedata;
+	int ret;
 
 	/*
 	 * There is no use in forwarding any barrier request since we can't
@@ -895,6 +897,13 @@ static int dm_request(struct request_que
 		return 0;
 	}
 
+	if (!bio_cgroup_disabled() && blk_queue_bio_group_enabled(q)) {
+		ret = bio_group_controller(q, bio);
+		if (ret)
+			/* Either bio got buffered for bio_endio() done */
+			return 0;
+	}
+
 	down_read(&md->io_lock);
 
 	disk_stat_inc(dm_disk(md), ios[rw]);
@@ -1081,6 +1090,10 @@ static struct mapped_device *alloc_dev(i
 	md->queue->unplug_fn = dm_unplug_all;
 	blk_queue_merge_bvec(md->queue, dm_merge_bvec);
 
+	/* Initialize queue spin lock */
+	md->queue->queue_lock = &md->queue->__queue_lock;
+	spin_lock_init(md->queue->queue_lock);
+
 	md->io_pool = mempool_create_slab_pool(MIN_IOS, _io_cache);
 	if (!md->io_pool)
 		goto bad_io_pool;
Index: linux17/block/blk-core.c
===================================================================
--- linux17.orig/block/blk-core.c	2008-11-06 09:14:20.000000000 -0500
+++ linux17/block/blk-core.c	2008-11-06 09:16:32.000000000 -0500
@@ -1117,10 +1117,18 @@ static int __make_request(struct request
 	int el_ret, nr_sectors, barrier, err;
 	const unsigned short prio = bio_prio(bio);
 	const int sync = bio_sync(bio);
-	int rw_flags;
+	int rw_flags, ret;
 
 	nr_sectors = bio_sectors(bio);
 
+	if (!bio_cgroup_disabled() && blk_queue_bio_group_enabled(q)) {
+		ret = bio_group_controller(q, bio);
+		if (ret) {
+			/* Either bio got buffered for bio_endio() done */
+			return 0;
+		}
+	}
+
 	/*
 	 * low level driver can indicate that it wants pages above a
 	 * certain limit bounced to low memory (ie for highmem, or even

-- 
