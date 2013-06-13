From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/11] cgroup: split cgroup destruction into two steps
Date: Wed, 12 Jun 2013 21:04:57 -0700
Message-ID: <1371096298-24402-11-git-send-email-tj__21779.9978949644$1371096396$gmane$org@kernel.org>
References: <1371096298-24402-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371096298-24402-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, koverstreet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Split cgroup_destroy_locked() into two steps and put the latter half
into cgroup_offline_fn() which is executed from a work item.  The
latter half is responsible for offlining the css's, removing the
cgroup from internal lists, and propagating release notification to
the parent.  The separation is to allow using percpu refcnt for css.

Note that this allows for other cgroup operations to happen between
the first and second halves of destruction, including creating a new
cgroup with the same name.  As the target cgroup is marked DEAD in the
first half and cgroup internals don't care about the names of cgroups,
this should be fine.  A comment explaining this will be added by the
next patch which implements the actual percpu refcnting.

As RCU freeing is guaranteed to happen after the second step of
destruction, we can use the same work item for both.  This patch
renames cgroup->free_work to ->destroy_work and uses it for both
purposes.  INIT_WORK() is now performed right before queueing the work
item.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  2 +-
 kernel/cgroup.c        | 38 +++++++++++++++++++++++++++-----------
 2 files changed, 28 insertions(+), 12 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 81bfd02..e345d8b 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -233,7 +233,7 @@ struct cgroup {
 
 	/* For RCU-protected deletion */
 	struct rcu_head rcu_head;
-	struct work_struct free_work;
+	struct work_struct destroy_work;
 
 	/* List of events which userspace want to receive */
 	struct list_head event_list;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 9261acc..ebbfc04 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -208,6 +208,7 @@ static struct cgroup_name root_cgroup_name = { .name = "/" };
  */
 static int need_forkexit_callback __read_mostly;
 
+static void cgroup_offline_fn(struct work_struct *work);
 static int cgroup_destroy_locked(struct cgroup *cgrp);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 			      struct cftype cfts[], bool is_add);
@@ -830,7 +831,7 @@ static struct cgroup_name *cgroup_alloc_name(struct dentry *dentry)
 
 static void cgroup_free_fn(struct work_struct *work)
 {
-	struct cgroup *cgrp = container_of(work, struct cgroup, free_work);
+	struct cgroup *cgrp = container_of(work, struct cgroup, destroy_work);
 	struct cgroup_subsys *ss;
 
 	mutex_lock(&cgroup_mutex);
@@ -875,7 +876,8 @@ static void cgroup_free_rcu(struct rcu_head *head)
 {
 	struct cgroup *cgrp = container_of(head, struct cgroup, rcu_head);
 
-	schedule_work(&cgrp->free_work);
+	INIT_WORK(&cgrp->destroy_work, cgroup_free_fn);
+	schedule_work(&cgrp->destroy_work);
 }
 
 static void cgroup_diput(struct dentry *dentry, struct inode *inode)
@@ -1407,7 +1409,6 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_LIST_HEAD(&cgrp->allcg_node);
 	INIT_LIST_HEAD(&cgrp->release_list);
 	INIT_LIST_HEAD(&cgrp->pidlists);
-	INIT_WORK(&cgrp->free_work, cgroup_free_fn);
 	mutex_init(&cgrp->pidlist_mutex);
 	INIT_LIST_HEAD(&cgrp->event_list);
 	spin_lock_init(&cgrp->event_list_lock);
@@ -2994,12 +2995,13 @@ struct cgroup *cgroup_next_sibling(struct cgroup *pos)
 	/*
 	 * @pos could already have been removed.  Once a cgroup is removed,
 	 * its ->sibling.next is no longer updated when its next sibling
-	 * changes.  As CGRP_DEAD is set on removal which is fully
-	 * serialized, if we see it unasserted, it's guaranteed that the
-	 * next sibling hasn't finished its grace period even if it's
-	 * already removed, and thus safe to dereference from this RCU
-	 * critical section.  If ->sibling.next is inaccessible,
-	 * cgroup_is_dead() is guaranteed to be visible as %true here.
+	 * changes.  As CGRP_DEAD assertion is serialized and happens
+	 * before the cgroup is taken off the ->sibling list, if we see it
+	 * unasserted, it's guaranteed that the next sibling hasn't
+	 * finished its grace period even if it's already removed, and thus
+	 * safe to dereference from this RCU critical section.  If
+	 * ->sibling.next is inaccessible, cgroup_is_dead() is guaranteed
+	 * to be visible as %true here.
 	 */
 	if (likely(!cgroup_is_dead(pos))) {
 		next = list_entry_rcu(pos->sibling.next, struct cgroup, sibling);
@@ -4362,7 +4364,6 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	__releases(&cgroup_mutex) __acquires(&cgroup_mutex)
 {
 	struct dentry *d = cgrp->dentry;
-	struct cgroup *parent = cgrp->parent;
 	struct cgroup_event *event, *tmp;
 	struct cgroup_subsys *ss;
 	bool empty;
@@ -4426,6 +4427,21 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	}
 	spin_unlock(&cgrp->event_list_lock);
 
+	INIT_WORK(&cgrp->destroy_work, cgroup_offline_fn);
+	schedule_work(&cgrp->destroy_work);
+
+	return 0;
+};
+
+static void cgroup_offline_fn(struct work_struct *work)
+{
+	struct cgroup *cgrp = container_of(work, struct cgroup, destroy_work);
+	struct cgroup *parent = cgrp->parent;
+	struct dentry *d = cgrp->dentry;
+	struct cgroup_subsys *ss;
+
+	mutex_lock(&cgroup_mutex);
+
 	/* tell subsystems to initate destruction */
 	for_each_subsys(cgrp->root, ss)
 		offline_css(ss, cgrp);
@@ -4449,7 +4465,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	set_bit(CGRP_RELEASABLE, &parent->flags);
 	check_for_release(parent);
 
-	return 0;
+	mutex_unlock(&cgroup_mutex);
 }
 
 static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
-- 
1.8.2.1
