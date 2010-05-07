From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: [PATCH] cgroups: make cftype.unregister_event() void-returning
Date: Fri, 7 May 2010 14:46:27 +0300
Message-ID: <l2pcc557aab1005070446y1f9c8169v58a3f7847676eaa__41787.2453028851$1273232842$gmane$org@mail.gmail.com>
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
To: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Since we unable to handle error returned by cftype.unregister_event()
properly, let's make the callback void-returning.

mem_cgroup_unregister_event() has been rewritten to be "never fail"
function. On mem_cgroup_usage_register_event() we save old buffer
for thresholds array and reuse it in mem_cgroup_usage_unregister_event()
to avoid allocation.

Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
---
 include/linux/cgroup.h |    2 +-
 kernel/cgroup.c        |    1 -
 mm/memcontrol.c        |   64 ++++++++++++++++++++++++++++++------------------
 3 files changed, 41 insertions(+), 26 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8f78073..0c62160 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -397,7 +397,7 @@ struct cftype {
 	 * This callback must be implemented, if you want provide
 	 * notification functionality.
 	 */
-	int (*unregister_event)(struct cgroup *cgrp, struct cftype *cft,
+	void (*unregister_event)(struct cgroup *cgrp, struct cftype *cft,
 			struct eventfd_ctx *eventfd);
 };

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 06dbf97..6675e8c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2988,7 +2988,6 @@ static void cgroup_event_remove(struct work_struct *work)
 			remove);
 	struct cgroup *cgrp = event->cgrp;

-	/* TODO: check return code */
 	event->cft->unregister_event(cgrp, event->cft, event->eventfd);

 	eventfd_ctx_put(event->eventfd);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8cb2722..0a37b5d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -226,9 +226,19 @@ struct mem_cgroup {
 	/* thresholds for memory usage. RCU-protected */
 	struct mem_cgroup_threshold_ary *thresholds;

+	/*
+	 * Preallocated buffer to be used in mem_cgroup_unregister_event()
+	 * to make it "never fail".
+	 * It must be able to store at least thresholds->size - 1 entries.
+	 */
+	struct mem_cgroup_threshold_ary *__thresholds;
+
 	/* thresholds for mem+swap usage. RCU-protected */
 	struct mem_cgroup_threshold_ary *memsw_thresholds;

+	/* the same as __thresholds, but for memsw_thresholds */
+	struct mem_cgroup_threshold_ary *__memsw_thresholds;
+
 	/* For oom notifier event fd */
 	struct list_head oom_notify;

@@ -3575,17 +3585,27 @@ static int
mem_cgroup_usage_register_event(struct cgroup *cgrp,
 	else
 		rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);

-	/* To be sure that nobody uses thresholds before freeing it */
+	/* To be sure that nobody uses thresholds */
 	synchronize_rcu();

-	kfree(thresholds);
+	/*
+	 * Free old preallocated buffer and use thresholds as new
+	 * preallocated buffer.
+	 */
+	if (type == _MEM) {
+		kfree(memcg->__thresholds);
+		memcg->__thresholds = thresholds;
+	} else {
+		kfree(memcg->__memsw_thresholds);
+		memcg->__memsw_thresholds = thresholds;
+	}
 unlock:
 	mutex_unlock(&memcg->thresholds_lock);

 	return ret;
 }

-static int mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
+static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 	struct cftype *cft, struct eventfd_ctx *eventfd)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
@@ -3593,7 +3613,7 @@ static int
mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 	int type = MEMFILE_TYPE(cft->private);
 	u64 usage;
 	int size = 0;
-	int i, j, ret = 0;
+	int i, j;

 	mutex_lock(&memcg->thresholds_lock);
 	if (type == _MEM)
@@ -3623,17 +3643,15 @@ static int
mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 	/* Set thresholds array to NULL if we don't have thresholds */
 	if (!size) {
 		thresholds_new = NULL;
-		goto assign;
+		goto swap_buffers;
 	}

-	/* Allocate memory for new array of thresholds */
-	thresholds_new = kmalloc(sizeof(*thresholds_new) +
-			size * sizeof(struct mem_cgroup_threshold),
-			GFP_KERNEL);
-	if (!thresholds_new) {
-		ret = -ENOMEM;
-		goto unlock;
-	}
+	/* Use preallocated buffer for new array of thresholds */
+	if (type == _MEM)
+		thresholds_new = memcg->__thresholds;
+	else
+		thresholds_new = memcg->__memsw_thresholds;
+
 	thresholds_new->size = size;

 	/* Copy thresholds and find current threshold */
@@ -3654,20 +3672,20 @@ static int
mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 		j++;
 	}

-assign:
-	if (type == _MEM)
+swap_buffers:
+	/* Swap thresholds array and preallocated buffer */
+	if (type == _MEM) {
+		memcg->__thresholds = thresholds;
 		rcu_assign_pointer(memcg->thresholds, thresholds_new);
-	else
+	} else {
+		memcg->__memsw_thresholds = thresholds;
 		rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
+	}

-	/* To be sure that nobody uses thresholds before freeing it */
+	/* To be sure that nobody uses thresholds */
 	synchronize_rcu();

-	kfree(thresholds);
-unlock:
 	mutex_unlock(&memcg->thresholds_lock);
-
-	return ret;
 }

 static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
@@ -3695,7 +3713,7 @@ static int mem_cgroup_oom_register_event(struct
cgroup *cgrp,
 	return 0;
 }

-static int mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
+static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 	struct cftype *cft, struct eventfd_ctx *eventfd)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cgrp);
@@ -3714,8 +3732,6 @@ static int
mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
 	}

 	mutex_unlock(&memcg_oom_mutex);
-
-	return 0;
 }

 static int mem_cgroup_oom_control_read(struct cgroup *cgrp,
-- 
1.7.0.4
