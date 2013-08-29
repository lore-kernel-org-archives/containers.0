From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3 06/12] cgroup, memcg: move cgroup_event implementation to
	memcg
Date: Thu, 29 Aug 2013 14:19:11 -0400
Message-ID: <20130829181911.GA8517__45390.7595867806$1377800375$gmane$org@mtj.dyndns.org>
References: <1376582550-12548-1-git-send-email-tj@kernel.org>
	<1376582550-12548-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1376582550-12548-7-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Michal.

Updated as requested.  If there's still somthing missing, please let
me know.  In case you're okay with the change, how do you wanna route
it?  01-05 are already in cgroup/for-3.12 and the rest can either be
applie to cgroup/for-3.12, which will likely to require some, mostly
trivial, adjustments to memcg patches in -mm, or these all can be
routed through -mm.  Any preference?

Thanks.

------ 8< ------
cgroup_event is way over-designed and tries to build a generic
flexible event mechanism into cgroup - fully customizable event
specification for each user of the interface.  This is utterly
unnecessary and overboard especially in the light of the planned
unified hierarchy as there's gonna be single agent.  Simply generating
events at fixed points, or if that's too restrictive, configureable
cadence or single set of configureable points should be enough.

In addition, it's adding overhead for future changes for cgroup core.

* Everything is being made per-css which is necessary as css's
  lifetime would no longer coincide with cgroup's in the planned
  unified hierarchy.  Keeping cgroup_event in cgroup proper means that
  it should be updated to be managed per-css, which is silly as no
  other subsystems will use this facility.

* The file system interface of cgroup will be restructured so that it
  uses sysfs.  The goal of the conversion is losing duplicate logic
  and taking advantage of features provided by sysfs such as revoke
  semantics on file deletion and decoupled synchronization from vfs
  layer.

  The conversion is likely to involve unifying all different file
  operation types into a single type and having operations which are
  as unusual as event callbacks adds unnecessary burden.  While making
  it specific to memcg doesn't remove all conversion work, it'd lower
  the amount of work necessary.  We don't have to worry how the
  unusual event callbacks would fit into the new structure.

Thankfully, memcg is the only user and gets to keep it.  Replacing it
with something simpler on sane_behavior is strongly recommended.

This patch moves cgroup_event and "cgroup.event_control"
implementation to mm/memcontrol.c.  Clearing of events on cgroup
destruction is moved from cgroup_destroy_locked() to
mem_cgroup_css_offline(), which shouldn't make any noticeable
difference.

cgroup_css() and __file_cft() are exported to enable the move;
however, this will soon be reverted once the event code is updated to
be memcg specific.

Note that "cgroup.event_control" will now exist only on the hierarchy
with memcg attached to it.  While this change is visible to userland,
it is unlikely to be noticeable as the file has never been meaningful
outside memcg.

Aside from the above change, this is pure code relocation.

v2: Per Li Zefan's comments, init/Kconfig updated accordingly and
    poll.h inclusion moved from cgroup.c to memcontrol.c.

v3: Per Michal's request, update patch description.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Acked-by: Kirill A. Shutemov <kirill.shutemov-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Cc: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/linux/cgroup.h |    5 
 init/Kconfig           |    3 
 kernel/cgroup.c        |  252 -------------------------------------------------
 mm/memcontrol.c        |  247 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 256 insertions(+), 251 deletions(-)

--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -907,6 +907,11 @@ unsigned short css_id(struct cgroup_subs
 struct cgroup_subsys_state *css_from_dir(struct dentry *dentry,
 					 struct cgroup_subsys *ss);
 
+/* XXX: temporary */
+struct cgroup_subsys_state *cgroup_css(struct cgroup *cgrp,
+				       struct cgroup_subsys *ss);
+struct cftype *__file_cft(struct file *file);
+
 #else /* !CONFIG_CGROUPS */
 
 static inline int cgroup_init_early(void) { return 0; }
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -844,7 +844,6 @@ config NUMA_BALANCING
 
 menuconfig CGROUPS
 	boolean "Control Group support"
-	depends on EVENTFD
 	help
 	  This option adds support for grouping sets of processes together, for
 	  use with process control subsystems such as Cpusets, CFS, memory
@@ -911,6 +910,7 @@ config MEMCG
 	bool "Memory Resource Controller for Control Groups"
 	depends on RESOURCE_COUNTERS
 	select MM_OWNER
+	select EVENTFD
 	help
 	  Provides a memory resource controller that manages both anonymous
 	  memory and page cache. (See Documentation/cgroups/memory.txt)
@@ -1163,7 +1163,6 @@ config UIDGID_STRICT_TYPE_CHECKS
 
 config SCHED_AUTOGROUP
 	bool "Automatic process group scheduling"
-	select EVENTFD
 	select CGROUPS
 	select CGROUP_SCHED
 	select FAIR_GROUP_SCHED
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -56,8 +56,6 @@
 #include <linux/pid_namespace.h>
 #include <linux/idr.h>
 #include <linux/vmalloc.h> /* TODO: replace with more sophisticated array */
-#include <linux/eventfd.h>
-#include <linux/poll.h>
 #include <linux/flex_array.h> /* used in cgroup_attach_task */
 #include <linux/kthread.h>
 
@@ -155,36 +153,6 @@ struct css_id {
 	unsigned short stack[0]; /* Array of Length (depth+1) */
 };
 
-/*
- * cgroup_event represents events which userspace want to receive.
- */
-struct cgroup_event {
-	/*
-	 * css which the event belongs to.
-	 */
-	struct cgroup_subsys_state *css;
-	/*
-	 * Control file which the event associated.
-	 */
-	struct cftype *cft;
-	/*
-	 * eventfd to signal userspace about the event.
-	 */
-	struct eventfd_ctx *eventfd;
-	/*
-	 * Each of these stored in a list by the cgroup.
-	 */
-	struct list_head list;
-	/*
-	 * All fields below needed to unregister event when
-	 * userspace closes eventfd.
-	 */
-	poll_table pt;
-	wait_queue_head_t *wqh;
-	wait_queue_t wait;
-	struct work_struct remove;
-};
-
 /* The list of hierarchy roots */
 
 static LIST_HEAD(cgroup_roots);
@@ -234,8 +202,8 @@ static int cgroup_addrm_files(struct cgr
  * keep accessing it outside the said locks.  This function may return
  * %NULL if @cgrp doesn't have @subsys_id enabled.
  */
-static struct cgroup_subsys_state *cgroup_css(struct cgroup *cgrp,
-					      struct cgroup_subsys *ss)
+struct cgroup_subsys_state *cgroup_css(struct cgroup *cgrp,
+				       struct cgroup_subsys *ss)
 {
 	if (ss)
 		return rcu_dereference_check(cgrp->subsys[ss->subsys_id],
@@ -2671,7 +2639,7 @@ static struct dentry *cgroup_lookup(stru
 /*
  * Check if a file is a control file
  */
-static inline struct cftype *__file_cft(struct file *file)
+struct cftype *__file_cft(struct file *file)
 {
 	if (file_inode(file)->i_fop != &cgroup_file_operations)
 		return ERR_PTR(-EINVAL);
@@ -3959,202 +3927,6 @@ static void cgroup_dput(struct cgroup *c
 	deactivate_super(sb);
 }
 
-/*
- * Unregister event and free resources.
- *
- * Gets called from workqueue.
- */
-static void cgroup_event_remove(struct work_struct *work)
-{
-	struct cgroup_event *event = container_of(work, struct cgroup_event,
-			remove);
-	struct cgroup_subsys_state *css = event->css;
-
-	remove_wait_queue(event->wqh, &event->wait);
-
-	event->cft->unregister_event(css, event->cft, event->eventfd);
-
-	/* Notify userspace the event is going away. */
-	eventfd_signal(event->eventfd, 1);
-
-	eventfd_ctx_put(event->eventfd);
-	kfree(event);
-	css_put(css);
-}
-
-/*
- * Gets called on POLLHUP on eventfd when user closes it.
- *
- * Called with wqh->lock held and interrupts disabled.
- */
-static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
-		int sync, void *key)
-{
-	struct cgroup_event *event = container_of(wait,
-			struct cgroup_event, wait);
-	struct cgroup *cgrp = event->css->cgroup;
-	unsigned long flags = (unsigned long)key;
-
-	if (flags & POLLHUP) {
-		/*
-		 * If the event has been detached at cgroup removal, we
-		 * can simply return knowing the other side will cleanup
-		 * for us.
-		 *
-		 * We can't race against event freeing since the other
-		 * side will require wqh->lock via remove_wait_queue(),
-		 * which we hold.
-		 */
-		spin_lock(&cgrp->event_list_lock);
-		if (!list_empty(&event->list)) {
-			list_del_init(&event->list);
-			/*
-			 * We are in atomic context, but cgroup_event_remove()
-			 * may sleep, so we have to call it in workqueue.
-			 */
-			schedule_work(&event->remove);
-		}
-		spin_unlock(&cgrp->event_list_lock);
-	}
-
-	return 0;
-}
-
-static void cgroup_event_ptable_queue_proc(struct file *file,
-		wait_queue_head_t *wqh, poll_table *pt)
-{
-	struct cgroup_event *event = container_of(pt,
-			struct cgroup_event, pt);
-
-	event->wqh = wqh;
-	add_wait_queue(wqh, &event->wait);
-}
-
-/*
- * Parse input and register new cgroup event handler.
- *
- * Input must be in format '<event_fd> <control_fd> <args>'.
- * Interpretation of args is defined by control file implementation.
- */
-static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
-				      struct cftype *cft, const char *buffer)
-{
-	struct cgroup *cgrp = dummy_css->cgroup;
-	struct cgroup_event *event;
-	struct cgroup_subsys_state *cfile_css;
-	unsigned int efd, cfd;
-	struct file *efile;
-	struct file *cfile;
-	char *endp;
-	int ret;
-
-	efd = simple_strtoul(buffer, &endp, 10);
-	if (*endp != ' ')
-		return -EINVAL;
-	buffer = endp + 1;
-
-	cfd = simple_strtoul(buffer, &endp, 10);
-	if ((*endp != ' ') && (*endp != '\0'))
-		return -EINVAL;
-	buffer = endp + 1;
-
-	event = kzalloc(sizeof(*event), GFP_KERNEL);
-	if (!event)
-		return -ENOMEM;
-
-	INIT_LIST_HEAD(&event->list);
-	init_poll_funcptr(&event->pt, cgroup_event_ptable_queue_proc);
-	init_waitqueue_func_entry(&event->wait, cgroup_event_wake);
-	INIT_WORK(&event->remove, cgroup_event_remove);
-
-	efile = eventfd_fget(efd);
-	if (IS_ERR(efile)) {
-		ret = PTR_ERR(efile);
-		goto out_kfree;
-	}
-
-	event->eventfd = eventfd_ctx_fileget(efile);
-	if (IS_ERR(event->eventfd)) {
-		ret = PTR_ERR(event->eventfd);
-		goto out_put_efile;
-	}
-
-	cfile = fget(cfd);
-	if (!cfile) {
-		ret = -EBADF;
-		goto out_put_eventfd;
-	}
-
-	/* the process need read permission on control file */
-	/* AV: shouldn't we check that it's been opened for read instead? */
-	ret = inode_permission(file_inode(cfile), MAY_READ);
-	if (ret < 0)
-		goto out_put_cfile;
-
-	event->cft = __file_cft(cfile);
-	if (IS_ERR(event->cft)) {
-		ret = PTR_ERR(event->cft);
-		goto out_put_cfile;
-	}
-
-	if (!event->cft->ss) {
-		ret = -EBADF;
-		goto out_put_cfile;
-	}
-
-	/*
-	 * Determine the css of @cfile, verify it belongs to the same
-	 * cgroup as cgroup.event_control, and associate @event with it.
-	 * Remaining events are automatically removed on cgroup destruction
-	 * but the removal is asynchronous, so take an extra ref.
-	 */
-	rcu_read_lock();
-
-	ret = -EINVAL;
-	event->css = cgroup_css(cgrp, event->cft->ss);
-	cfile_css = css_from_dir(cfile->f_dentry->d_parent, event->cft->ss);
-	if (event->css && event->css == cfile_css && css_tryget(event->css))
-		ret = 0;
-
-	rcu_read_unlock();
-	if (ret)
-		goto out_put_cfile;
-
-	if (!event->cft->register_event || !event->cft->unregister_event) {
-		ret = -EINVAL;
-		goto out_put_css;
-	}
-
-	ret = event->cft->register_event(event->css, event->cft,
-			event->eventfd, buffer);
-	if (ret)
-		goto out_put_css;
-
-	efile->f_op->poll(efile, &event->pt);
-
-	spin_lock(&cgrp->event_list_lock);
-	list_add(&event->list, &cgrp->event_list);
-	spin_unlock(&cgrp->event_list_lock);
-
-	fput(cfile);
-	fput(efile);
-
-	return 0;
-
-out_put_css:
-	css_put(event->css);
-out_put_cfile:
-	fput(cfile);
-out_put_eventfd:
-	eventfd_ctx_put(event->eventfd);
-out_put_efile:
-	fput(efile);
-out_kfree:
-	kfree(event);
-
-	return ret;
-}
-
 static u64 cgroup_clone_children_read(struct cgroup_subsys_state *css,
 				      struct cftype *cft)
 {
@@ -4180,11 +3952,6 @@ static struct cftype cgroup_base_files[]
 		.mode = S_IRUGO | S_IWUSR,
 	},
 	{
-		.name = "cgroup.event_control",
-		.write_string = cgroup_write_event_control,
-		.mode = S_IWUGO,
-	},
-	{
 		.name = "cgroup.clone_children",
 		.flags = CFTYPE_INSANE,
 		.read_u64 = cgroup_clone_children_read,
@@ -4676,7 +4443,6 @@ static int cgroup_destroy_locked(struct
 	__releases(&cgroup_mutex) __acquires(&cgroup_mutex)
 {
 	struct dentry *d = cgrp->dentry;
-	struct cgroup_event *event, *tmp;
 	struct cgroup_subsys *ss;
 	bool empty;
 
@@ -4734,18 +4500,6 @@ static int cgroup_destroy_locked(struct
 	dget(d);
 	cgroup_d_remove_dir(d);
 
-	/*
-	 * Unregister events and notify userspace.
-	 * Notify userspace about cgroup removing only after rmdir of cgroup
-	 * directory to avoid race between userspace and kernelspace.
-	 */
-	spin_lock(&cgrp->event_list_lock);
-	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
-		list_del_init(&event->list);
-		schedule_work(&event->remove);
-	}
-	spin_unlock(&cgrp->event_list_lock);
-
 	return 0;
 };
 
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -45,6 +45,7 @@
 #include <linux/swapops.h>
 #include <linux/spinlock.h>
 #include <linux/eventfd.h>
+#include <linux/poll.h>
 #include <linux/sort.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
@@ -239,6 +240,36 @@ struct mem_cgroup_eventfd_list {
 	struct eventfd_ctx *eventfd;
 };
 
+/*
+ * cgroup_event represents events which userspace want to receive.
+ */
+struct cgroup_event {
+	/*
+	 * css which the event belongs to.
+	 */
+	struct cgroup_subsys_state *css;
+	/*
+	 * Control file which the event associated.
+	 */
+	struct cftype *cft;
+	/*
+	 * eventfd to signal userspace about the event.
+	 */
+	struct eventfd_ctx *eventfd;
+	/*
+	 * Each of these stored in a list by the cgroup.
+	 */
+	struct list_head list;
+	/*
+	 * All fields below needed to unregister event when
+	 * userspace closes eventfd.
+	 */
+	poll_table pt;
+	wait_queue_head_t *wqh;
+	wait_queue_t wait;
+	struct work_struct remove;
+};
+
 static void mem_cgroup_threshold(struct mem_cgroup *memcg);
 static void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
 
@@ -5919,6 +5950,202 @@ static void kmem_cgroup_css_offline(stru
 }
 #endif
 
+/*
+ * Unregister event and free resources.
+ *
+ * Gets called from workqueue.
+ */
+static void cgroup_event_remove(struct work_struct *work)
+{
+	struct cgroup_event *event = container_of(work, struct cgroup_event,
+			remove);
+	struct cgroup_subsys_state *css = event->css;
+
+	remove_wait_queue(event->wqh, &event->wait);
+
+	event->cft->unregister_event(css, event->cft, event->eventfd);
+
+	/* Notify userspace the event is going away. */
+	eventfd_signal(event->eventfd, 1);
+
+	eventfd_ctx_put(event->eventfd);
+	kfree(event);
+	css_put(css);
+}
+
+/*
+ * Gets called on POLLHUP on eventfd when user closes it.
+ *
+ * Called with wqh->lock held and interrupts disabled.
+ */
+static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
+		int sync, void *key)
+{
+	struct cgroup_event *event = container_of(wait,
+			struct cgroup_event, wait);
+	struct cgroup *cgrp = event->css->cgroup;
+	unsigned long flags = (unsigned long)key;
+
+	if (flags & POLLHUP) {
+		/*
+		 * If the event has been detached at cgroup removal, we
+		 * can simply return knowing the other side will cleanup
+		 * for us.
+		 *
+		 * We can't race against event freeing since the other
+		 * side will require wqh->lock via remove_wait_queue(),
+		 * which we hold.
+		 */
+		spin_lock(&cgrp->event_list_lock);
+		if (!list_empty(&event->list)) {
+			list_del_init(&event->list);
+			/*
+			 * We are in atomic context, but cgroup_event_remove()
+			 * may sleep, so we have to call it in workqueue.
+			 */
+			schedule_work(&event->remove);
+		}
+		spin_unlock(&cgrp->event_list_lock);
+	}
+
+	return 0;
+}
+
+static void cgroup_event_ptable_queue_proc(struct file *file,
+		wait_queue_head_t *wqh, poll_table *pt)
+{
+	struct cgroup_event *event = container_of(pt,
+			struct cgroup_event, pt);
+
+	event->wqh = wqh;
+	add_wait_queue(wqh, &event->wait);
+}
+
+/*
+ * Parse input and register new cgroup event handler.
+ *
+ * Input must be in format '<event_fd> <control_fd> <args>'.
+ * Interpretation of args is defined by control file implementation.
+ */
+static int cgroup_write_event_control(struct cgroup_subsys_state *dummy_css,
+				      struct cftype *cft, const char *buffer)
+{
+	struct cgroup *cgrp = dummy_css->cgroup;
+	struct cgroup_event *event;
+	struct cgroup_subsys_state *cfile_css;
+	unsigned int efd, cfd;
+	struct file *efile;
+	struct file *cfile;
+	char *endp;
+	int ret;
+
+	efd = simple_strtoul(buffer, &endp, 10);
+	if (*endp != ' ')
+		return -EINVAL;
+	buffer = endp + 1;
+
+	cfd = simple_strtoul(buffer, &endp, 10);
+	if ((*endp != ' ') && (*endp != '\0'))
+		return -EINVAL;
+	buffer = endp + 1;
+
+	event = kzalloc(sizeof(*event), GFP_KERNEL);
+	if (!event)
+		return -ENOMEM;
+
+	INIT_LIST_HEAD(&event->list);
+	init_poll_funcptr(&event->pt, cgroup_event_ptable_queue_proc);
+	init_waitqueue_func_entry(&event->wait, cgroup_event_wake);
+	INIT_WORK(&event->remove, cgroup_event_remove);
+
+	efile = eventfd_fget(efd);
+	if (IS_ERR(efile)) {
+		ret = PTR_ERR(efile);
+		goto out_kfree;
+	}
+
+	event->eventfd = eventfd_ctx_fileget(efile);
+	if (IS_ERR(event->eventfd)) {
+		ret = PTR_ERR(event->eventfd);
+		goto out_put_efile;
+	}
+
+	cfile = fget(cfd);
+	if (!cfile) {
+		ret = -EBADF;
+		goto out_put_eventfd;
+	}
+
+	/* the process need read permission on control file */
+	/* AV: shouldn't we check that it's been opened for read instead? */
+	ret = inode_permission(file_inode(cfile), MAY_READ);
+	if (ret < 0)
+		goto out_put_cfile;
+
+	event->cft = __file_cft(cfile);
+	if (IS_ERR(event->cft)) {
+		ret = PTR_ERR(event->cft);
+		goto out_put_cfile;
+	}
+
+	if (!event->cft->ss) {
+		ret = -EBADF;
+		goto out_put_cfile;
+	}
+
+	/*
+	 * Determine the css of @cfile, verify it belongs to the same
+	 * cgroup as cgroup.event_control, and associate @event with it.
+	 * Remaining events are automatically removed on cgroup destruction
+	 * but the removal is asynchronous, so take an extra ref.
+	 */
+	rcu_read_lock();
+
+	ret = -EINVAL;
+	event->css = cgroup_css(cgrp, event->cft->ss);
+	cfile_css = css_from_dir(cfile->f_dentry->d_parent, event->cft->ss);
+	if (event->css && event->css == cfile_css && css_tryget(event->css))
+		ret = 0;
+
+	rcu_read_unlock();
+	if (ret)
+		goto out_put_cfile;
+
+	if (!event->cft->register_event || !event->cft->unregister_event) {
+		ret = -EINVAL;
+		goto out_put_css;
+	}
+
+	ret = event->cft->register_event(event->css, event->cft,
+			event->eventfd, buffer);
+	if (ret)
+		goto out_put_css;
+
+	efile->f_op->poll(efile, &event->pt);
+
+	spin_lock(&cgrp->event_list_lock);
+	list_add(&event->list, &cgrp->event_list);
+	spin_unlock(&cgrp->event_list_lock);
+
+	fput(cfile);
+	fput(efile);
+
+	return 0;
+
+out_put_css:
+	css_put(event->css);
+out_put_cfile:
+	fput(cfile);
+out_put_eventfd:
+	eventfd_ctx_put(event->eventfd);
+out_put_efile:
+	fput(efile);
+out_kfree:
+	kfree(event);
+
+	return ret;
+}
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -5966,6 +6193,12 @@ static struct cftype mem_cgroup_files[]
 		.read_u64 = mem_cgroup_hierarchy_read,
 	},
 	{
+		.name = "cgroup.event_control",
+		.write_string = cgroup_write_event_control,
+		.flags = CFTYPE_NO_PREFIX,
+		.mode = S_IWUGO,
+	},
+	{
 		.name = "swappiness",
 		.read_u64 = mem_cgroup_swappiness_read,
 		.write_u64 = mem_cgroup_swappiness_write,
@@ -6298,6 +6531,20 @@ static void mem_cgroup_invalidate_reclai
 static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	struct cgroup *cgrp = css->cgroup;
+	struct cgroup_event *event, *tmp;
+
+	/*
+	 * Unregister events and notify userspace.
+	 * Notify userspace about cgroup removing only after rmdir of cgroup
+	 * directory to avoid race between userspace and kernelspace.
+	 */
+	spin_lock(&cgrp->event_list_lock);
+	list_for_each_entry_safe(event, tmp, &cgrp->event_list, list) {
+		list_del_init(&event->list);
+		schedule_work(&event->remove);
+	}
+	spin_unlock(&cgrp->event_list_lock);
 
 	kmem_cgroup_css_offline(memcg);
