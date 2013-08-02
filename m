From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 21/23] cgroup: make cftype->[un]register_event() deal with
	cgroup_subsys_state instead of cgroup
Date: Fri, 2 Aug 2013 16:24:52 -0400
Message-ID: <20130802202452.GI29736@mtj.dyndns.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
	<1375393801-4817-22-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1375393801-4817-22-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup is in the process of converting to css (cgroup_subsys_state)
from cgroup as the principal subsystem interface handle.  This is
mostly to prepare for the unified hierarchy support where css's will
be created and destroyed dynamically but also helps cleaning up
subsystem implementations as css is usually what they are interested
in anyway.

cftype->[un]register_event() is among the remaining couple interfaces
which still use struct cgroup.  Convert it to cgroup_subsys_state.
The conversion is mostly mechanical and removes the last users of
mem_cgroup_from_cont() and cg_to_vmpressure(), which are removed.

v2: indentation update as suggested by Li Zefan.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Acked-by: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/cgroup.h     |   10 ++++++----
 include/linux/vmpressure.h |    6 ++++--
 kernel/cgroup.c            |   15 ++++++++-------
 mm/memcontrol.c            |   21 ++++++++-------------
 mm/vmpressure.c            |   21 +++++++++------------
 5 files changed, 35 insertions(+), 38 deletions(-)

--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -506,16 +506,18 @@ struct cftype {
 	 * you want to provide this functionality. Use eventfd_signal()
 	 * on eventfd to send notification to userspace.
 	 */
-	int (*register_event)(struct cgroup *cgrp, struct cftype *cft,
-			struct eventfd_ctx *eventfd, const char *args);
+	int (*register_event)(struct cgroup_subsys_state *css,
+			      struct cftype *cft, struct eventfd_ctx *eventfd,
+			      const char *args);
 	/*
 	 * unregister_event() callback will be called when userspace
 	 * closes the eventfd or on cgroup removing.
 	 * This callback must be implemented, if you want provide
 	 * notification functionality.
 	 */
-	void (*unregister_event)(struct cgroup *cgrp, struct cftype *cft,
-			struct eventfd_ctx *eventfd);
+	void (*unregister_event)(struct cgroup_subsys_state *css,
+				 struct cftype *cft,
+				 struct eventfd_ctx *eventfd);
 };
 
 /*
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -33,10 +33,12 @@ extern void vmpressure_init(struct vmpre
 extern struct vmpressure *memcg_to_vmpressure(struct mem_cgroup *memcg);
 extern struct cgroup_subsys_state *vmpressure_to_css(struct vmpressure *vmpr);
 extern struct vmpressure *css_to_vmpressure(struct cgroup_subsys_state *css);
-extern int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
+extern int vmpressure_register_event(struct cgroup_subsys_state *css,
+				     struct cftype *cft,
 				     struct eventfd_ctx *eventfd,
 				     const char *args);
-extern void vmpressure_unregister_event(struct cgroup *cg, struct cftype *cft,
+extern void vmpressure_unregister_event(struct cgroup_subsys_state *css,
+					struct cftype *cft,
 					struct eventfd_ctx *eventfd);
 #else
 static inline void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -159,9 +159,9 @@ struct css_id {
  */
 struct cgroup_event {
 	/*
-	 * Cgroup which the event belongs to.
+	 * css which the event belongs to.
 	 */
-	struct cgroup *cgrp;
+	struct cgroup_subsys_state *css;
 	/*
 	 * Control file which the event associated.
 	 */
@@ -3955,11 +3955,12 @@ static void cgroup_event_remove(struct w
 {
 	struct cgroup_event *event = container_of(work, struct cgroup_event,
 			remove);
-	struct cgroup *cgrp = event->cgrp;
+	struct cgroup_subsys_state *css = event->css;
+	struct cgroup *cgrp = css->cgroup;
 
 	remove_wait_queue(event->wqh, &event->wait);
 
-	event->cft->unregister_event(cgrp, event->cft, event->eventfd);
+	event->cft->unregister_event(css, event->cft, event->eventfd);
 
 	/* Notify userspace the event is going away. */
 	eventfd_signal(event->eventfd, 1);
@@ -3979,7 +3980,7 @@ static int cgroup_event_wake(wait_queue_
 {
 	struct cgroup_event *event = container_of(wait,
 			struct cgroup_event, wait);
-	struct cgroup *cgrp = event->cgrp;
+	struct cgroup *cgrp = event->css->cgroup;
 	unsigned long flags = (unsigned long)key;
 
 	if (flags & POLLHUP) {
@@ -4048,7 +4049,7 @@ static int cgroup_write_event_control(st
 	event = kzalloc(sizeof(*event), GFP_KERNEL);
 	if (!event)
 		return -ENOMEM;
-	event->cgrp = cgrp;
+	event->css = css;
 	INIT_LIST_HEAD(&event->list);
 	init_poll_funcptr(&event->pt, cgroup_event_ptable_queue_proc);
 	init_waitqueue_func_entry(&event->wait, cgroup_event_wake);
@@ -4099,7 +4100,7 @@ static int cgroup_write_event_control(st
 		goto out_put_cfile;
 	}
 
-	ret = event->cft->register_event(cgrp, event->cft,
+	ret = event->cft->register_event(css, event->cft,
 			event->eventfd, buffer);
 	if (ret)
 		goto out_put_cfile;
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1034,11 +1034,6 @@ static void memcg_check_events(struct me
 		preempt_enable();
 }
 
-static inline struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
-{
-	return mem_cgroup_from_css(cgroup_css(cont, mem_cgroup_subsys_id));
-}
-
 struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 {
 	/*
@@ -5620,10 +5615,10 @@ static void mem_cgroup_oom_notify(struct
 		mem_cgroup_oom_notify_cb(iter);
 }
 
-static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
+static int mem_cgroup_usage_register_event(struct cgroup_subsys_state *css,
 	struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_thresholds *thresholds;
 	struct mem_cgroup_threshold_ary *new;
 	enum res_type type = MEMFILE_TYPE(cft->private);
@@ -5703,10 +5698,10 @@ unlock:
 	return ret;
 }
 
-static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
+static void mem_cgroup_usage_unregister_event(struct cgroup_subsys_state *css,
 	struct cftype *cft, struct eventfd_ctx *eventfd)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_thresholds *thresholds;
 	struct mem_cgroup_threshold_ary *new;
 	enum res_type type = MEMFILE_TYPE(cft->private);
@@ -5782,10 +5777,10 @@ unlock:
 	mutex_unlock(&memcg->thresholds_lock);
 }
 
-static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
+static int mem_cgroup_oom_register_event(struct cgroup_subsys_state *css,
 	struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_eventfd_list *event;
 	enum res_type type = MEMFILE_TYPE(cft->private);
 
@@ -5807,10 +5802,10 @@ static int mem_cgroup_oom_register_event
 	return 0;
 }
 
-static void mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
+static void mem_cgroup_oom_unregister_event(struct cgroup_subsys_state *css,
 	struct cftype *cft, struct eventfd_ctx *eventfd)
 {
-	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_eventfd_list *ev, *tmp;
 	enum res_type type = MEMFILE_TYPE(cft->private);
 
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -74,11 +74,6 @@ static struct vmpressure *work_to_vmpres
 	return container_of(work, struct vmpressure, work);
 }
 
-static struct vmpressure *cg_to_vmpressure(struct cgroup *cg)
-{
-	return css_to_vmpressure(cgroup_css(cg, mem_cgroup_subsys_id));
-}
-
 static struct vmpressure *vmpressure_parent(struct vmpressure *vmpr)
 {
 	struct cgroup_subsys_state *css = vmpressure_to_css(vmpr);
@@ -283,7 +278,7 @@ void vmpressure_prio(gfp_t gfp, struct m
 
 /**
  * vmpressure_register_event() - Bind vmpressure notifications to an eventfd
- * @cg:		cgroup that is interested in vmpressure notifications
+ * @css:	css that is interested in vmpressure notifications
  * @cft:	cgroup control files handle
  * @eventfd:	eventfd context to link notifications with
  * @args:	event arguments (used to set up a pressure level threshold)
@@ -298,10 +293,11 @@ void vmpressure_prio(gfp_t gfp, struct m
  * cftype).register_event, and then cgroup core will handle everything by
  * itself.
  */
-int vmpressure_register_event(struct cgroup *cg, struct cftype *cft,
-			      struct eventfd_ctx *eventfd, const char *args)
+int vmpressure_register_event(struct cgroup_subsys_state *css,
+			      struct cftype *cft, struct eventfd_ctx *eventfd,
+			      const char *args)
 {
-	struct vmpressure *vmpr = cg_to_vmpressure(cg);
+	struct vmpressure *vmpr = css_to_vmpressure(css);
 	struct vmpressure_event *ev;
 	int level;
 
@@ -329,7 +325,7 @@ int vmpressure_register_event(struct cgr
 
 /**
  * vmpressure_unregister_event() - Unbind eventfd from vmpressure
- * @cg:		cgroup handle
+ * @css:	css handle
  * @cft:	cgroup control files handle
  * @eventfd:	eventfd context that was used to link vmpressure with the @cg
  *
@@ -341,10 +337,11 @@ int vmpressure_register_event(struct cgr
  * cftype).unregister_event, and then cgroup core will handle everything
  * by itself.
  */
-void vmpressure_unregister_event(struct cgroup *cg, struct cftype *cft,
+void vmpressure_unregister_event(struct cgroup_subsys_state *css,
+				 struct cftype *cft,
 				 struct eventfd_ctx *eventfd)
 {
-	struct vmpressure *vmpr = cg_to_vmpressure(cg);
+	struct vmpressure *vmpr = css_to_vmpressure(css);
 	struct vmpressure_event *ev;
 
 	mutex_lock(&vmpr->events_lock);
