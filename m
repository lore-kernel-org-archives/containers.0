From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 09/28] io-controller: cfq changes to use hierarchical fair
	queuing code in elevaotor layer
Date: Thu, 24 Sep 2009 15:25:13 -0400
Message-ID: <1253820332-10246-10-git-send-email-vgoyal__11836.9155251004$1253822015$gmane$org@redhat.com>
References: <1253820332-10246-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253820332-10246-1-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmarchan-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Make cfq hierarhical.

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
Signed-off-by: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched |    8 ++++++
 block/cfq-iosched.c   |   64 ++++++++++++++++++++++++++++++++++++++++++++++--
 init/Kconfig          |    2 +-
 3 files changed, 70 insertions(+), 4 deletions(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index dd5224d..a91a807 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -54,6 +54,14 @@ config IOSCHED_CFQ
 	  working environment, suitable for desktop systems.
 	  This is the default I/O scheduler.
 
+config IOSCHED_CFQ_HIER
+	bool "CFQ Hierarchical Scheduling support"
+	depends on IOSCHED_CFQ && CGROUPS
+	select GROUP_IOSCHED
+	default n
+	---help---
+	  Enable hierarhical scheduling in cfq.
+
 choice
 	prompt "Default I/O scheduler"
 	default DEFAULT_CFQ
diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index 79ac161..0e665a9 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -1286,6 +1286,61 @@ static void cfq_init_cfqq(struct cfq_data *cfqd, struct cfq_queue *cfqq,
 	cfqq->pid = pid;
 }
 
+#ifdef CONFIG_IOSCHED_CFQ_HIER
+static void changed_cgroup(struct io_context *ioc, struct cfq_io_context *cic)
+{
+	struct cfq_queue *async_cfqq = cic_to_cfqq(cic, 0);
+	struct cfq_queue *sync_cfqq = cic_to_cfqq(cic, 1);
+	struct cfq_data *cfqd = cic->key;
+	struct io_group *iog, *__iog;
+	unsigned long flags;
+	struct request_queue *q;
+
+	if (unlikely(!cfqd))
+		return;
+
+	q = cfqd->queue;
+
+	spin_lock_irqsave(q->queue_lock, flags);
+
+	iog = elv_io_get_io_group(q, 0);
+
+	if (async_cfqq != NULL) {
+		__iog = cfqq_to_io_group(async_cfqq);
+		if (iog != __iog) {
+			/* cgroup changed, drop the reference to async queue */
+			cic_set_cfqq(cic, NULL, 0);
+			cfq_put_queue(async_cfqq);
+		}
+	}
+
+	if (sync_cfqq != NULL) {
+		__iog = cfqq_to_io_group(sync_cfqq);
+
+		/*
+		 * Drop reference to sync queue. A new sync queue will
+		 * be assigned in new group upon arrival of a fresh request.
+		 * If old queue has got requests, those reuests will be
+		 * dispatched over a period of time and queue will be freed
+		 * automatically.
+		 */
+		if (iog != __iog) {
+			cic_set_cfqq(cic, NULL, 1);
+			elv_exit_ioq(sync_cfqq->ioq);
+			cfq_put_queue(sync_cfqq);
+		}
+	}
+
+	spin_unlock_irqrestore(q->queue_lock, flags);
+}
+
+static void cfq_ioc_set_cgroup(struct io_context *ioc)
+{
+	call_for_each_cic(ioc, changed_cgroup);
+	ioc->cgroup_changed = 0;
+}
+#endif  /* CONFIG_IOSCHED_CFQ_HIER */
+
 static struct cfq_queue *
 cfq_find_alloc_queue(struct cfq_data *cfqd, int is_sync,
 		     struct io_context *ioc, gfp_t gfp_mask)
@@ -1297,7 +1352,7 @@ cfq_find_alloc_queue(struct cfq_data *cfqd, int is_sync,
 	struct io_group *iog = NULL;
 
 retry:
-	iog = elv_io_get_io_group(q, 0);
+	iog = elv_io_get_io_group(q, 1);
 
 	cic = cfq_cic_lookup(cfqd, ioc);
 	/* cic always exists here */
@@ -1386,7 +1441,7 @@ cfq_get_queue(struct cfq_data *cfqd, int is_sync, struct io_context *ioc,
 	const int ioprio_class = task_ioprio_class(ioc);
 	struct cfq_queue *async_cfqq = NULL;
 	struct cfq_queue *cfqq = NULL;
-	struct io_group *iog = elv_io_get_io_group(cfqd->queue, 0);
+	struct io_group *iog = elv_io_get_io_group(cfqd->queue, 1);
 
 	if (!is_sync) {
 		async_cfqq = elv_io_group_async_queue_prio(iog, ioprio_class,
@@ -1541,7 +1596,10 @@ out:
 	smp_read_barrier_depends();
 	if (unlikely(ioc->ioprio_changed))
 		cfq_ioc_set_ioprio(ioc);
-
+#ifdef CONFIG_IOSCHED_CFQ_HIER
+	if (unlikely(ioc->cgroup_changed))
+		cfq_ioc_set_cgroup(ioc);
+#endif
 	return cic;
 err_free:
 	cfq_cic_free(cic);
diff --git a/init/Kconfig b/init/Kconfig
index 29f701d..afcaa86 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -613,7 +613,7 @@ config CGROUP_MEM_RES_CTLR_SWAP
 	  size is 4096bytes, 512k per 1Gbytes of swap.
 
 config GROUP_IOSCHED
-	bool "Group IO Scheduler"
+	bool
 	depends on CGROUPS && ELV_FAIR_QUEUING
 	default n
 	---help---
-- 
1.6.0.6
