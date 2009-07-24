From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 16/24] io-controller: noop changes for hierarchical fair
	queuing
Date: Fri, 24 Jul 2009 16:27:46 -0400
Message-ID: <1248467274-32073-17-git-send-email-vgoyal__47826.124871108$1248467721$gmane$org@redhat.com>
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

This patch changes noop to use queue scheduling code from elevator layer.
One can go back to old noop by deselecting CONFIG_IOSCHED_NOOP_HIER.

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched |   11 +++++++++++
 block/noop-iosched.c  |   13 +++++++++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index a7d0bf8..28cd500 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -25,6 +25,17 @@ config IOSCHED_NOOP
 	  that do their own scheduling and require only minimal assistance from
 	  the kernel.
 
+config IOSCHED_NOOP_HIER
+	bool "Noop Hierarchical Scheduling support"
+	depends on IOSCHED_NOOP && CGROUPS
+	select ELV_FAIR_QUEUING
+	select GROUP_IOSCHED
+	default n
+	---help---
+	  Enable hierarhical scheduling in noop. In this mode noop keeps
+	  one IO queue per cgroup instead of a global queue. Elevator
+	  fair queuing logic ensures fairness among various queues.
+
 config IOSCHED_AS
 	tristate "Anticipatory I/O scheduler"
 	default y
diff --git a/block/noop-iosched.c b/block/noop-iosched.c
index 731dbf2..5811ea2 100644
--- a/block/noop-iosched.c
+++ b/block/noop-iosched.c
@@ -82,6 +82,15 @@ static void noop_free_noop_queue(struct elevator_queue *e, void *sched_queue)
 	kfree(nq);
 }
 
+#ifdef CONFIG_IOSCHED_NOOP_HIER
+static struct elv_fs_entry noop_attrs[] = {
+	ELV_ATTR(fairness),
+	ELV_ATTR(slice_sync),
+	ELV_ATTR(group_idle),
+	__ATTR_NULL
+};
+#endif
+
 static struct elevator_type elevator_noop = {
 	.ops = {
 		.elevator_merge_req_fn		= noop_merged_requests,
@@ -92,6 +101,10 @@ static struct elevator_type elevator_noop = {
 		.elevator_alloc_sched_queue_fn	= noop_alloc_noop_queue,
 		.elevator_free_sched_queue_fn	= noop_free_noop_queue,
 	},
+#ifdef CONFIG_IOSCHED_NOOP_HIER
+	.elevator_features = ELV_IOSCHED_NEED_FQ | ELV_IOSCHED_SINGLE_IOQ,
+	.elevator_attrs = noop_attrs,
+#endif
 	.elevator_name = "noop",
 	.elevator_owner = THIS_MODULE,
 };
-- 
1.6.0.6
