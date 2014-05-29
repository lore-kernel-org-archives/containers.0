From: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Subject: [PATCH RFC - TAKE TWO - 08/12] block,
	bfq: preserve a low latency also with NCQ-capable drives
Date: Thu, 29 May 2014 11:05:39 +0200
Message-ID: <1401354343-5527-9-git-send-email-paolo.valente__34744.4039573476$1401354505$gmane$org@unimore.it>
References: <20140528221929.GG1419@htj.dyndns.org>
	<1401354343-5527-1-git-send-email-paolo.valente@unimore.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1401354343-5527-1-git-send-email-paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paolo Valente <posta_paolo-whZMOeQn8C0@public.gmane.org>
List-Id: containers.vger.kernel.org

I/O schedulers typically allow NCQ-capable drives to prefetch I/O
requests, as NCQ boosts the throughput exactly by prefetching and
internally reordering requests.

Unfortunately, as discussed in detail and shown experimentally in [1],
this may cause fairness and latency guarantees to be violated. The
main problem is that the internal scheduler of an NCQ-capable drive
may postpone the service of some unlucky (prefetched) requests as long
as it deems serving other requests more appropriate to boost the
throughput.

This patch addresses this issue by not disabling device idling for
weight-raised queues, even if the device supports NCQ. This allows BFQ
to start serving a new queue, and therefore allows the drive to
prefetch new requests, only after the idling timeout expires. At that
time, all the outstanding requests of the expired queue have been most
certainly served.

[1] P. Valente and M. Andreolini, "Improving Application
    Responsiveness with the BFQ Disk I/O Scheduler", Proceedings of
    the 5th Annual International Systems and Storage Conference
    (SYSTOR '12), June 2012.
    Slightly extended version:
http://www.algogroup.unimo.it/people/paolo/disk_sched/bf1-v1-suite-results.pdf

Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Arianna Avanzini <avanzini.arianna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/bfq-iosched.c | 5 +++--
 block/bfq.h         | 2 +-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/block/bfq-iosched.c b/block/bfq-iosched.c
index 661f948..0b24130 100644
--- a/block/bfq-iosched.c
+++ b/block/bfq-iosched.c
@@ -2051,7 +2051,8 @@ static void bfq_update_idle_window(struct bfq_data *bfqd,
 
 	if (atomic_read(&bic->icq.ioc->active_ref) == 0 ||
 	    bfqd->bfq_slice_idle == 0 ||
-		(bfqd->hw_tag && BFQQ_SEEKY(bfqq)))
+		(bfqd->hw_tag && BFQQ_SEEKY(bfqq) &&
+			bfqq->wr_coeff == 1))
 		enable_idle = 0;
 	else if (bfq_sample_valid(bic->ttime.ttime_samples)) {
 		if (bic->ttime.ttime_mean > bfqd->bfq_slice_idle &&
@@ -2874,7 +2875,7 @@ static int __init bfq_init(void)
 	device_speed_thresh[1] = (R_fast[1] + R_slow[1]) / 2;
 
 	elv_register(&iosched_bfq);
-	pr_info("BFQ I/O-scheduler version: v1");
+	pr_info("BFQ I/O-scheduler version: v2");
 
 	return 0;
 }
diff --git a/block/bfq.h b/block/bfq.h
index 5fa8b34..3b5763a7 100644
--- a/block/bfq.h
+++ b/block/bfq.h
@@ -1,5 +1,5 @@
 /*
- * BFQ-v1 for 3.15.0: data structures and common functions prototypes.
+ * BFQ-v2 for 3.15.0: data structures and common functions prototypes.
  *
  * Based on ideas and code from CFQ:
  * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
-- 
1.9.2
