From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 08/12] cgroup,
	memcg: move cgroup->event_list[_lock] and event callbacks into memcg
Date: Thu, 15 Aug 2013 12:02:26 -0400
Message-ID: <1376582550-12548-9-git-send-email-tj__46052.5699695156$1376582642$gmane$org@kernel.org>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1376582550-12548-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_event is being moved from cgroup core to memcg and the
implementation is already moved by the previous patch.  This patch
moves the data fields and callbacks.

* cgroup->event_list[_lock] are moved to mem_cgroup.

* cftype->[un]register_event() are moved to cgroup_event.  This makes
  it impossible for individual cftype definitions to specify their
  event callbacks.  This is worked around by simply hard-coding
  filename to event callback mapping in cgroup_write_event_control().
  This is awkward and inflexible, which is actually desirable given
  that we don't want to grow more usages of this feature.

* eventfd_ctx declaration is removed from cgroup.h, which makes
  vmpressure.h miss eventfd_ctx declaration.  Include eventfd.h from
  vmpressure.h.

v2: Use file name from dentry instead of cftype.  This will allow
    removing all cftype handling in the function.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/cgroup.h     | 24 -------------
 include/linux/vmpressure.h |  1 +
 kernel/cgroup.c            |  2 --
 mm/memcontrol.c            | 87 ++++++++++++++++++++++++++++++++--------------
 4 files changed, 61 insertions(+), 53 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index b83b348..d2cad3f 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -29,7 +29,6 @@ struct cgroup_subsys;
 struct inode;
 struct cgroup;
 struct css_id;
-struct eventfd_ctx;
 
 extern int cgroup_init_early(void);
 extern int cgroup_init(void);
@@ -239,10 +238,6 @@ struct cgroup {
 	struct rcu_head rcu_head;
 	struct work_struct destroy_work;
 
-	/* List of events which userspace want to receive */
-	struct list_head event_list;
-	spinlock_t event_list_lock;
-
 	/* directory xattrs */
 	struct simple_xattrs xattrs;
 };
@@ -506,25 +501,6 @@ struct cftype {
 	int (*trigger)(struct cgroup_subsys_state *css, unsigned int event);
 
 	int (*release)(struct inode *inode, struct file *file);
-
-	/*
-	 * register_event() callback will be used to add new userspace
-	 * waiter for changes related to the cftype. Implement it if
-	 * you want to provide this functionality. Use eventfd_signal()
-	 * on eventfd to send notification to userspace.
-	 */
-	int (*register_event)(struct cgroup_subsys_state *css,
-			      struct cftype *cft, struct eventfd_ctx *eventfd,
-			      const char *args);
-	/*
-	 * unregister_event() callback will be called when userspace
-	 * closes the eventfd or on cgroup removing.
-	 * This callback must be implemented, if you want provide
-	 * notification functionality.
-	 */
-	void (*unregister_event)(struct cgroup_subsys_state *css,
-				 struct cftype *cft,
-				 struct eventfd_ctx *eventfd);
 };
 
 /*
diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index b239482..324ea7a 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -7,6 +7,7 @@
 #include <linux/gfp.h>
 #include <linux/types.h>
 #include <linux/cgroup.h>
+#include <linux/eventfd.h>
 
 struct vmpressure {
 	unsigned long scanned;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 1579ca8..4368a6c 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1353,8 +1353,6 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_LIST_HEAD(&cgrp->pidlists);
 	mutex_init(&cgrp->pidlist_mutex);
 	cgrp->dummy_css.cgroup = cgrp;
-	INIT_LIST_HEAD(&cgrp->event_list);
-	spin_lock_init(&cgrp->event_list_lock);
 	simple_xattrs_init(&cgrp->xattrs);
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ef75925..9b833e1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -261,6 +261,22 @@ struct cgroup_event {
 	 */
 	struct list_head list;
 	/*
+	 * register_event() callback will be used to add new userspace
+	 * waiter for changes related to this event.  Use eventfd_signal()
+	 * on eventfd to send notification to userspace.
+	 */
+	int (*register_event)(struct cgroup_subsys_state *css,
+			      struct cftype *cft, struct eventfd_ctx *eventfd,
+			      const char *args);
+	/*
+	 * unregister_event() callback will be called when userspace closes
+	 * the eventfd or on cgroup removing.  This callback must be set,
+	 * if you want provide notification functionality.
+	 */
+	void (*unregister_event)(struct cgroup_subsys_state *css,
+				 struct cftype *cft,
+				 struct eventfd_ctx *eventfd);
+	/*
 	 * All fields below needed to unregister event when
 	 * userspace closes eventfd.
 	 */
@@ -373,6 +389,10 @@ struct mem_cgroup {
 	atomic_t	numainfo_updating;
 #endif
 
+	/* List of events which userspace want to receive */
+	struct list_head event_list;
+	spinlock_t event_list_lock;
+
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
 };
@@ -5963,7 +5983,7 @@ static void cgroup_event_remove(struct work_struct *work)
 
 	remove_wait_queue(event->wqh, &event->wait);
 
-	event->cft->unregister_event(css, event->cft, event->eventfd);
+	event->unregister_event(css, event->cft, event->eventfd);
 
 	/* Notify userspace the event is going away. */
 	eventfd_signal(event->eventfd, 1);
@@ -5983,7 +6003,7 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
 {
 	struct cgroup_event *event = container_of(wait,
 			struct cgroup_event, wait);
-	struct cgroup *cgrp = event->css->cgroup;
+	struct mem_cgroup *memcg = mem_cgroup_from_css(event->css);
 	unsigned long flags = (unsigned long)key;
 
 	if (flags & POLLHUP) {
@@ -5996,7 +6016,7 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
 		 * side will require wqh->lock via remove_wait_queue(),
 		 * which we hold.
 		 */
-		spin_lock(&cgrp->event_list_lock);
+		spin_lock(&memcg->event_list_lock);
 		if (!list_empty(&event->list)) {
 			list_del_init(&event->list);
 			/*
@@ -6005,7 +6025,7 @@ static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
 			 */
 			schedule_work(&event->remove);
 		}
-		spin_unlock(&cgrp->event_list_lock);
+		spin_unlock(&memcg->event_list_lock);
 	}
 
 	return 0;
@@ -6030,12 +6050,13 @@ static void cgroup_event_ptable_queue_proc(struct file *file,
 static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 				      struct cftype *cft, const char *buffer)
 {
-	struct cgroup *cgrp = css->cgroup;
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct cgroup_event *event;
 	struct cgroup_subsys_state *cfile_css;
 	unsigned int efd, cfd;
 	struct file *efile;
 	struct file *cfile;
+	const char *name;
 	char *endp;
 	int ret;
 
@@ -6090,6 +6111,31 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 	}
 
 	/*
+	 * Determine the event callbacks and set them in @event.  This used
+	 * to be done via struct cftype but cgroup core no longer knows
+	 * about these events.  The following is crude but the whole thing
+	 * is for compatibility anyway.
+	 */
+	name = cfile->f_dentry->d_name.name;
+
+	if (!strcmp(name, "memory.usage_in_bytes")) {
+		event->register_event = mem_cgroup_usage_register_event;
+		event->unregister_event = mem_cgroup_usage_unregister_event;
+	} else if (!strcmp(name, "memory.oom_control")) {
+		event->register_event = mem_cgroup_oom_register_event;
+		event->unregister_event = mem_cgroup_oom_unregister_event;
+	} else if (!strcmp(name, "memory.pressure_level")) {
+		event->register_event = vmpressure_register_event;
+		event->unregister_event = vmpressure_unregister_event;
+	} else if (!strcmp(name, "memory.memsw.usage_in_bytes")) {
+		event->register_event = mem_cgroup_usage_register_event;
+		event->unregister_event = mem_cgroup_usage_unregister_event;
+	} else {
+		ret = -EINVAL;
+		goto out_put_cfile;
+	}
+
+	/*
 	 * Verify @cfile should belong to @css.  Also, remaining events are
 	 * automatically removed on cgroup destruction but the removal is
 	 * asynchronous, so take an extra ref on @css.
@@ -6105,21 +6151,15 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 	if (ret)
 		goto out_put_cfile;
 
-	if (!event->cft->register_event || !event->cft->unregister_event) {
-		ret = -EINVAL;
-		goto out_put_css;
-	}
-
-	ret = event->cft->register_event(css, event->cft,
-			event->eventfd, buffer);
+	ret = event->register_event(css, event->cft, event->eventfd, buffer);
 	if (ret)
 		goto out_put_css;
 
 	efile->f_op->poll(efile, &event->pt);
 
-	spin_lock(&cgrp->event_list_lock);
-	list_add(&event->list, &cgrp->event_list);
-	spin_unlock(&cgrp->event_list_lock);
+	spin_lock(&memcg->event_list_lock);
+	list_add(&event->list, &memcg->event_list);
+	spin_unlock(&memcg->event_list_lock);
 
 	fput(cfile);
 	fput(efile);
@@ -6145,8 +6185,6 @@ static struct cftype mem_cgroup_files[] = {
 		.name = "usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
 		.read = mem_cgroup_read,
-		.register_event = mem_cgroup_usage_register_event,
-		.unregister_event = mem_cgroup_usage_unregister_event,
 	},
 	{
 		.name = "max_usage_in_bytes",
@@ -6206,14 +6244,10 @@ static struct cftype mem_cgroup_files[] = {
 		.name = "oom_control",
 		.read_map = mem_cgroup_oom_control_read,
 		.write_u64 = mem_cgroup_oom_control_write,
-		.register_event = mem_cgroup_oom_register_event,
-		.unregister_event = mem_cgroup_oom_unregister_event,
 		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
 	},
 	{
 		.name = "pressure_level",
-		.register_event = vmpressure_register_event,
-		.unregister_event = vmpressure_unregister_event,
 	},
 #ifdef CONFIG_NUMA
 	{
@@ -6261,8 +6295,6 @@ static struct cftype memsw_cgroup_files[] = {
 		.name = "memsw.usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
 		.read = mem_cgroup_read,
-		.register_event = mem_cgroup_usage_register_event,
-		.unregister_event = mem_cgroup_usage_unregister_event,
 	},
 	{
 		.name = "memsw.max_usage_in_bytes",
@@ -6453,6 +6485,8 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	mutex_init(&memcg->thresholds_lock);
 	spin_lock_init(&memcg->move_lock);
 	vmpressure_init(&memcg->vmpressure);
+	INIT_LIST_HEAD(&memcg->event_list);
+	spin_lock_init(&memcg->event_list_lock);
 
 	return &memcg->css;
 
@@ -6525,7 +6559,6 @@ static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
 static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
-	struct cgroup *cgrp = css->cgroup;
 	struct cgroup_event *event, *tmp;
 
 	/*
@@ -6533,12 +6566,12 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	 * Notify userspace about cgroup removing only after rmdir of cgroup
 	 * directory to avoid race between userspace and kernelspace.
 	 */
-	spin_lock(&cgrp->event_list_lock);
-	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
+	spin_lock(&memcg->event_list_lock);
+	list_for_each_entry_safe(event, tmp, &memcg->event_list, list) {
 		list_del_init(&event->list);
 		schedule_work(&event->remove);
 	}
-	spin_unlock(&cgrp->event_list_lock);
+	spin_unlock(&memcg->event_list_lock);
 
 	kmem_cgroup_css_offline(memcg);
 
-- 
1.8.3.1
