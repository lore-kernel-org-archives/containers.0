From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 09/12] memcg: remove cgroup_event->cft
Date: Thu, 15 Aug 2013 12:02:27 -0400
Message-ID: <1376582550-12548-10-git-send-email-tj__39126.5867547647$1376582682$gmane$org@kernel.org>
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

The only use of cgroup_event->cft is distinguishing "usage_in_bytes"
and "memsw.usgae_in_bytes" for mem_cgroup_usage_[un]register_event(),
which can be done by adding an explicit argument to the function and
implementing two wrappers so that the two cases can be distinguished
from the function alone.

Remove cgroup_event->cft and the related code including
[un]register_events() methods.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/vmpressure.h |  2 --
 mm/memcontrol.c            | 65 +++++++++++++++++++++++++---------------------
 mm/vmpressure.c            | 14 +++-------
 3 files changed, 38 insertions(+), 43 deletions(-)

diff --git a/include/linux/vmpressure.h b/include/linux/vmpressure.h
index 324ea7a..dd0b025 100644
--- a/include/linux/vmpressure.h
+++ b/include/linux/vmpressure.h
@@ -35,11 +35,9 @@ extern struct vmpressure *memcg_to_vmpressure(struct mem_cgroup *memcg);
 extern struct cgroup_subsys_state *vmpressure_to_css(struct vmpressure *vmpr);
 extern struct vmpressure *css_to_vmpressure(struct cgroup_subsys_state *css);
 extern int vmpressure_register_event(struct cgroup_subsys_state *css,
-				     struct cftype *cft,
 				     struct eventfd_ctx *eventfd,
 				     const char *args);
 extern void vmpressure_unregister_event(struct cgroup_subsys_state *css,
-					struct cftype *cft,
 					struct eventfd_ctx *eventfd);
 #else
 static inline void vmpressure(gfp_t gfp, struct mem_cgroup *memcg,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9b833e1..18e98ae 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -249,10 +249,6 @@ struct cgroup_event {
 	 */
 	struct cgroup_subsys_state *css;
 	/*
-	 * Control file which the event associated.
-	 */
-	struct cftype *cft;
-	/*
 	 * eventfd to signal userspace about the event.
 	 */
 	struct eventfd_ctx *eventfd;
@@ -266,15 +262,13 @@ struct cgroup_event {
 	 * on eventfd to send notification to userspace.
 	 */
 	int (*register_event)(struct cgroup_subsys_state *css,
-			      struct cftype *cft, struct eventfd_ctx *eventfd,
-			      const char *args);
+			      struct eventfd_ctx *eventfd, const char *args);
 	/*
 	 * unregister_event() callback will be called when userspace closes
 	 * the eventfd or on cgroup removing.  This callback must be set,
 	 * if you want provide notification functionality.
 	 */
 	void (*unregister_event)(struct cgroup_subsys_state *css,
-				 struct cftype *cft,
 				 struct eventfd_ctx *eventfd);
 	/*
 	 * All fields below needed to unregister event when
@@ -5659,13 +5653,12 @@ static void mem_cgroup_oom_notify(struct mem_cgroup *memcg)
 		mem_cgroup_oom_notify_cb(iter);
 }
 
-static int mem_cgroup_usage_register_event(struct cgroup_subsys_state *css,
-	struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
+static int __mem_cgroup_usage_register_event(struct cgroup_subsys_state *css,
+	struct eventfd_ctx *eventfd, const char *args, enum res_type type)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_thresholds *thresholds;
 	struct mem_cgroup_threshold_ary *new;
-	enum res_type type = MEMFILE_TYPE(cft->private);
 	u64 threshold, usage;
 	int i, size, ret;
 
@@ -5742,13 +5735,24 @@ unlock:
 	return ret;
 }
 
-static void mem_cgroup_usage_unregister_event(struct cgroup_subsys_state *css,
-	struct cftype *cft, struct eventfd_ctx *eventfd)
+static int mem_cgroup_usage_register_event(struct cgroup_subsys_state *css,
+	struct eventfd_ctx *eventfd, const char *args)
+{
+	return __mem_cgroup_usage_register_event(css, eventfd, args, _MEM);
+}
+
+static int memsw_cgroup_usage_register_event(struct cgroup_subsys_state *css,
+	struct eventfd_ctx *eventfd, const char *args)
+{
+	return __mem_cgroup_usage_register_event(css, eventfd, args, _MEMSWAP);
+}
+
+static void __mem_cgroup_usage_unregister_event(struct cgroup_subsys_state *css,
+	struct eventfd_ctx *eventfd, enum res_type type)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_thresholds *thresholds;
 	struct mem_cgroup_threshold_ary *new;
-	enum res_type type = MEMFILE_TYPE(cft->private);
 	u64 usage;
 	int i, j, size;
 
@@ -5821,14 +5825,24 @@ unlock:
 	mutex_unlock(&memcg->thresholds_lock);
 }
 
+static void mem_cgroup_usage_unregister_event(struct cgroup_subsys_state *css,
+	struct eventfd_ctx *eventfd)
+{
+	return __mem_cgroup_usage_unregister_event(css, eventfd, _MEM);
+}
+
+static void memsw_cgroup_usage_unregister_event(struct cgroup_subsys_state *css,
+	struct eventfd_ctx *eventfd)
+{
+	return __mem_cgroup_usage_unregister_event(css, eventfd, _MEMSWAP);
+}
+
 static int mem_cgroup_oom_register_event(struct cgroup_subsys_state *css,
-	struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
+	struct eventfd_ctx *eventfd, const char *args)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_eventfd_list *event;
-	enum res_type type = MEMFILE_TYPE(cft->private);
 
-	BUG_ON(type != _OOM_TYPE);
 	event = kmalloc(sizeof(*event),	GFP_KERNEL);
 	if (!event)
 		return -ENOMEM;
@@ -5847,13 +5861,10 @@ static int mem_cgroup_oom_register_event(struct cgroup_subsys_state *css,
 }
 
 static void mem_cgroup_oom_unregister_event(struct cgroup_subsys_state *css,
-	struct cftype *cft, struct eventfd_ctx *eventfd)
+	struct eventfd_ctx *eventfd)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_eventfd_list *ev, *tmp;
-	enum res_type type = MEMFILE_TYPE(cft->private);
-
-	BUG_ON(type != _OOM_TYPE);
 
 	spin_lock(&memcg_oom_lock);
 
@@ -5983,7 +5994,7 @@ static void cgroup_event_remove(struct work_struct *work)
 
 	remove_wait_queue(event->wqh, &event->wait);
 
-	event->unregister_event(css, event->cft, event->eventfd);
+	event->unregister_event(css, event->eventfd);
 
 	/* Notify userspace the event is going away. */
 	eventfd_signal(event->eventfd, 1);
@@ -6104,12 +6115,6 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 	if (ret < 0)
 		goto out_put_cfile;
 
-	event->cft = __file_cft(cfile);
-	if (IS_ERR(event->cft)) {
-		ret = PTR_ERR(event->cft);
-		goto out_put_cfile;
-	}
-
 	/*
 	 * Determine the event callbacks and set them in @event.  This used
 	 * to be done via struct cftype but cgroup core no longer knows
@@ -6128,8 +6133,8 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 		event->register_event = vmpressure_register_event;
 		event->unregister_event = vmpressure_unregister_event;
 	} else if (!strcmp(name, "memory.memsw.usage_in_bytes")) {
-		event->register_event = mem_cgroup_usage_register_event;
-		event->unregister_event = mem_cgroup_usage_unregister_event;
+		event->register_event = memsw_cgroup_usage_register_event;
+		event->unregister_event = memsw_cgroup_usage_unregister_event;
 	} else {
 		ret = -EINVAL;
 		goto out_put_cfile;
@@ -6151,7 +6156,7 @@ static int cgroup_write_event_control(struct cgroup_subsys_state *css,
 	if (ret)
 		goto out_put_cfile;
 
-	ret = event->register_event(css, event->cft, event->eventfd, buffer);
+	ret = event->register_event(css, event->eventfd, buffer);
 	if (ret)
 		goto out_put_css;
 
diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 13489b1..40ed6e8 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -279,7 +279,6 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
 /**
  * vmpressure_register_event() - Bind vmpressure notifications to an eventfd
  * @css:	css that is interested in vmpressure notifications
- * @cft:	cgroup control files handle
  * @eventfd:	eventfd context to link notifications with
  * @args:	event arguments (used to set up a pressure level threshold)
  *
@@ -289,13 +288,10 @@ void vmpressure_prio(gfp_t gfp, struct mem_cgroup *memcg, int prio)
  * threshold (one of vmpressure_str_levels, i.e. "low", "medium", or
  * "critical").
  *
- * This function should not be used directly, just pass it to (struct
- * cftype).register_event, and then cgroup core will handle everything by
- * itself.
+ * To be used as memcg event method.
  */
 int vmpressure_register_event(struct cgroup_subsys_state *css,
-			      struct cftype *cft, struct eventfd_ctx *eventfd,
-			      const char *args)
+			      struct eventfd_ctx *eventfd, const char *args)
 {
 	struct vmpressure *vmpr = css_to_vmpressure(css);
 	struct vmpressure_event *ev;
@@ -326,19 +322,15 @@ int vmpressure_register_event(struct cgroup_subsys_state *css,
 /**
  * vmpressure_unregister_event() - Unbind eventfd from vmpressure
  * @css:	css handle
- * @cft:	cgroup control files handle
  * @eventfd:	eventfd context that was used to link vmpressure with the @cg
  *
  * This function does internal manipulations to detach the @eventfd from
  * the vmpressure notifications, and then frees internal resources
  * associated with the @eventfd (but the @eventfd itself is not freed).
  *
- * This function should not be used directly, just pass it to (struct
- * cftype).unregister_event, and then cgroup core will handle everything
- * by itself.
+ * To be used as memcg event method.
  */
 void vmpressure_unregister_event(struct cgroup_subsys_state *css,
-				 struct cftype *cft,
 				 struct eventfd_ctx *eventfd)
 {
 	struct vmpressure *vmpr = css_to_vmpressure(css);
-- 
1.8.3.1
