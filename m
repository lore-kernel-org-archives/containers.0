From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 10/14] cgroup: replace cgroup->css_kill_cnt with ->nr_css
Date: Thu,  8 Aug 2013 16:13:47 -0400
Message-ID: <1375992831-4650-11-git-send-email-tj@kernel.org>
References: <1375992831-4650-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375992831-4650-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Currently, css (cgroup_subsys_state) lifetime is tied to that of the
associated cgroup.  With the planned unified hierarchy, css's will be
dynamically created and destroyed within the lifetime of a cgroup.  To
enable such usages, css's will be individually RCU protected instead
of being tied to the cgroup.

cgroup->css_kill_cnt is used during cgroup destruction to wait for css
reference count disable; however, this model doesn't work once css's
lifetimes are managed separately from cgroup's.  This patch replaces
it with cgroup->nr_css which is an cgroup_mutex protected integer
counting the number of attached css's.  The count is incremented from
online_css() and decremented after refcnt kill is confirmed.  If the
count reaches zero and the cgroup is marked dead, the second stage of
cgroup destruction is kicked off.  If a cgroup doesn't have any css
attached at the time of rmdir, cgroup_destroy_locked() now invokes the
second stage directly as no css kill confirmation would happen.

cgroup_offline_fn() - the second step of cgroup destruction - is
renamed to cgroup_destroy_css_killed() and now expects to be called
with cgroup_mutex held.

While this patch changes how css destruction is punted to work items,
it shouldn't change any visible behavior.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  4 +++-
 kernel/cgroup.c        | 52 +++++++++++++++++++++++++++-----------------------
 2 files changed, 31 insertions(+), 25 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index eb200b5..80dca87 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -171,6 +171,9 @@ struct cgroup {
 	 */
 	int id;
 
+	/* the number of attached css's */
+	int nr_css;
+
 	/*
 	 * We link our 'sibling' struct into our parent's 'children'.
 	 * Our children link their 'sibling' into our 'children'.
@@ -234,7 +237,6 @@ struct cgroup {
 	/* For css percpu_ref killing and RCU-protected deletion */
 	struct rcu_head rcu_head;
 	struct work_struct destroy_work;
-	atomic_t css_kill_cnt;
 
 	/* List of events which userspace want to receive */
 	struct list_head event_list;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 88b1095..484af35 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -218,7 +218,7 @@ static int need_forkexit_callback __read_mostly;
 
 static struct cftype cgroup_base_files[];
 
-static void cgroup_offline_fn(struct work_struct *work);
+static void cgroup_destroy_css_killed(struct cgroup *cgrp);
 static int cgroup_destroy_locked(struct cgroup *cgrp);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
 			      bool is_add);
@@ -4335,6 +4335,7 @@ static int online_css(struct cgroup_subsys_state *css)
 		ret = ss->css_online(css);
 	if (!ret) {
 		css->flags |= CSS_ONLINE;
+		css->cgroup->nr_css++;
 		rcu_assign_pointer(css->cgroup->subsys[ss->subsys_id], css);
 	}
 	return ret;
@@ -4541,16 +4542,6 @@ static int cgroup_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 	return cgroup_create(c_parent, dentry, mode | S_IFDIR);
 }
 
-static void cgroup_css_killed(struct cgroup *cgrp)
-{
-	if (!atomic_dec_and_test(&cgrp->css_kill_cnt))
-		return;
-
-	/* percpu ref's of all css's are killed, kick off the next step */
-	INIT_WORK(&cgrp->destroy_work, cgroup_offline_fn);
-	schedule_work(&cgrp->destroy_work);
-}
-
 /*
  * This is called when the refcnt of a css is confirmed to be killed.
  * css_tryget() is now guaranteed to fail.
@@ -4561,7 +4552,17 @@ static void css_killed_work_fn(struct work_struct *work)
 		container_of(work, struct cgroup_subsys_state, destroy_work);
 	struct cgroup *cgrp = css->cgroup;
 
-	cgroup_css_killed(cgrp);
+	mutex_lock(&cgroup_mutex);
+
+	/*
+	 * If @cgrp is marked dead, it's waiting for refs of all css's to
+	 * be disabled before proceeding to the second phase of cgroup
+	 * destruction.  If we are the last one, kick it off.
+	 */
+	if (!--cgrp->nr_css && cgroup_is_dead(cgrp))
+		cgroup_destroy_css_killed(cgrp);
+
+	mutex_unlock(&cgroup_mutex);
 }
 
 /* css kill confirmation processing requires process context, bounce */
@@ -4630,11 +4631,10 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	 * Use percpu_ref_kill_and_confirm() to get notifications as each
 	 * css is confirmed to be seen as killed on all CPUs.  The
 	 * notification callback keeps track of the number of css's to be
-	 * killed and schedules cgroup_offline_fn() to perform the rest of
-	 * destruction once the percpu refs of all css's are confirmed to
-	 * be killed.
+	 * killed and invokes cgroup_destroy_css_killed() to perform the
+	 * rest of destruction once the percpu refs of all css's are
+	 * confirmed to be killed.
 	 */
-	atomic_set(&cgrp->css_kill_cnt, 1);
 	for_each_root_subsys(cgrp->root, ss) {
 		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss->subsys_id);
 
@@ -4644,10 +4644,8 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 		 */
 		percpu_ref_get(&css->refcnt);
 
-		atomic_inc(&cgrp->css_kill_cnt);
 		percpu_ref_kill_and_confirm(&css->refcnt, css_killed_ref_fn);
 	}
-	cgroup_css_killed(cgrp);
 
 	/*
 	 * Mark @cgrp dead.  This prevents further task migration and child
@@ -4665,6 +4663,15 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 	raw_spin_unlock(&release_list_lock);
 
 	/*
+	 * If @cgrp has css's attached, the second stage of cgroup
+	 * destruction is kicked off from css_killed_work_fn() after the
+	 * refs of all attached css's are killed.  If @cgrp doesn't have
+	 * any css, we kick it off here.
+	 */
+	if (!cgrp->nr_css)
+		cgroup_destroy_css_killed(cgrp);
+
+	/*
 	 * Clear and remove @cgrp directory.  The removal puts the base ref
 	 * but we aren't quite done with @cgrp yet, so hold onto it.
 	 */
@@ -4689,7 +4696,7 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
 };
 
 /**
- * cgroup_offline_fn - the second step of cgroup destruction
+ * cgroup_destroy_css_killed - the second step of cgroup destruction
  * @work: cgroup->destroy_free_work
  *
  * This function is invoked from a work item for a cgroup which is being
@@ -4698,14 +4705,13 @@ static int cgroup_destroy_locked(struct cgroup *cgrp)
  * is the second step of destruction described in the comment above
  * cgroup_destroy_locked().
  */
-static void cgroup_offline_fn(struct work_struct *work)
+static void cgroup_destroy_css_killed(struct cgroup *cgrp)
 {
-	struct cgroup *cgrp = container_of(work, struct cgroup, destroy_work);
 	struct cgroup *parent = cgrp->parent;
 	struct dentry *d = cgrp->dentry;
 	struct cgroup_subsys *ss;
 
-	mutex_lock(&cgroup_mutex);
+	lockdep_assert_held(&cgroup_mutex);
 
 	/*
 	 * css_tryget() is guaranteed to fail now.  Tell subsystems to
@@ -4739,8 +4745,6 @@ static void cgroup_offline_fn(struct work_struct *work)
 
 	set_bit(CGRP_RELEASABLE, &parent->flags);
 	check_for_release(parent);
-
-	mutex_unlock(&cgroup_mutex);
 }
 
 static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
-- 
1.8.3.1
