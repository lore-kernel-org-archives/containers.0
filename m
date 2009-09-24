From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 21/28] io-controller: deadline changes for hierarchical fair
	queuing
Date: Thu, 24 Sep 2009 15:25:25 -0400
Message-ID: <1253820332-10246-22-git-send-email-vgoyal__31121.0804422901$1253823768$gmane$org@redhat.com>
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

This patch changes deadline to use queue scheduling code from elevator layer.
One can go back to old deadline by selecting CONFIG_IOSCHED_DEADLINE_HIER.

Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Acked-by: Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 block/Kconfig.iosched    |   11 +++++++++++
 block/deadline-iosched.c |    9 +++++++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
index 28cd500..cc87c87 100644
--- a/block/Kconfig.iosched
+++ b/block/Kconfig.iosched
@@ -55,6 +55,17 @@ config IOSCHED_DEADLINE
 	  a disk at any one time, its behaviour is almost identical to the
 	  anticipatory I/O scheduler and so is a good choice.
 
+config IOSCHED_DEADLINE_HIER
+	bool "Deadline Hierarchical Scheduling support"
+	depends on IOSCHED_DEADLINE && CGROUPS
+	select ELV_FAIR_QUEUING
+	select GROUP_IOSCHED
+	default n
+	---help---
+	  Enable hierarhical scheduling in deadline. In this mode deadline keeps
+	  one IO queue per cgroup instead of a global queue. Elevator
+	  fair queuing logic ensures fairness among various queues.
+
 config IOSCHED_CFQ
 	tristate "CFQ I/O scheduler"
 	select ELV_FAIR_QUEUING
diff --git a/block/deadline-iosched.c b/block/deadline-iosched.c
index 6e69ea3..e5bc823 100644
--- a/block/deadline-iosched.c
+++ b/block/deadline-iosched.c
@@ -13,6 +13,7 @@
 #include <linux/init.h>
 #include <linux/compiler.h>
 #include <linux/rbtree.h>
+#include "elevator-fq.h"
 
 /*
  * See Documentation/block/deadline-iosched.txt
@@ -461,6 +462,11 @@ static struct elv_fs_entry deadline_attrs[] = {
 	DD_ATTR(writes_starved),
 	DD_ATTR(front_merges),
 	DD_ATTR(fifo_batch),
+#ifdef CONFIG_IOSCHED_DEADLINE_HIER
+	ELV_ATTR(fairness),
+	ELV_ATTR(slice_sync),
+	ELV_ATTR(group_idle),
+#endif
 	__ATTR_NULL
 };
 
@@ -478,6 +484,9 @@ static struct elevator_type iosched_deadline = {
 		.elevator_alloc_sched_queue_fn = deadline_alloc_deadline_queue,
 		.elevator_free_sched_queue_fn = deadline_free_deadline_queue,
 	},
+#ifdef CONFIG_IOSCHED_DEADLINE_HIER
+	.elevator_features = ELV_IOSCHED_NEED_FQ | ELV_IOSCHED_SINGLE_IOQ,
+#endif
 	.elevator_attrs = deadline_attrs,
 	.elevator_name = "deadline",
 	.elevator_owner = THIS_MODULE,
-- 
1.6.0.6
