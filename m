From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 9/9] cgroup_freezer: implement proper hierarchy support
Date: Sat,  3 Nov 2012 01:38:35 -0700
Message-ID: <1351931915-1701-10-git-send-email-tj@kernel.org>
References: <1351931915-1701-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351931915-1701-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org
Cc: linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Up until now, cgroup_freezer didn't implement hierarchy properly.
cgroups could be arranged in hierarchy but it didn't make any
difference in how each cgroup_freezer behaved.  They all operated
separately.

This patch implements proper hierarchy support.  If a cgroup is
frozen, all its descendants are frozen.  A cgroup is thawed iff it and
all its ancestors are THAWED.  freezer.self_freezing shows the current
freezing state for the cgroup itself.  freezer.parent_freezing shows
whether the cgroup is freezing because any of its ancestors is
freezing.

freezer_post_create() locks the parent and new cgroup and inherits the
parent's state and freezer_change_state() applies new state top-down
using cgroup_for_each_descendant_pre() which guarantees that no child
can escape its parent's state.  update_if_frozen() uses
cgroup_for_each_descendant_post() to propagate frozen states
bottom-up.

Synchronization could be coarser and easier by using a single mutex to
protect all hierarchy operations.  Finer grained approach was used
because it wasn't too difficult for cgroup_freezer and I think it's
beneficial to have an example implementation and cgroup_freezer is
rather simple and can serve a good one.

As this makes cgroup_freezer properly hierarchical,
freezer_subsys.broken_hierarchy marking is removed.

Note that this patch changes userland visible behavior - freezing a
cgroup now freezes all its descendants too.  This behavior change is
intended and has been warned via .broken_hierarchy.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup_freezer.c | 161 ++++++++++++++++++++++++++++++++++++------------
 1 file changed, 123 insertions(+), 38 deletions(-)

diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
index 4f12d31..3262537 100644
--- a/kernel/cgroup_freezer.c
+++ b/kernel/cgroup_freezer.c
@@ -22,6 +22,13 @@
 #include <linux/freezer.h>
 #include <linux/seq_file.h>
 
+/*
+ * A cgroup is freezing if any FREEZING flags are set.  FREEZING_SELF is
+ * set if "FROZEN" is written to freezer.state cgroupfs file, and cleared
+ * for "THAWED".  FREEZING_PARENT is set if the parent freezer is FREEZING
+ * for whatever reason.  IOW, a cgroup has FREEZING_PARENT set if one of
+ * its ancestors has FREEZING_SELF set.
+ */
 enum freezer_state_flags {
 	CGROUP_FREEZER_ONLINE	= (1 << 0), /* freezer is fully online */
 	CGROUP_FREEZING_SELF	= (1 << 1), /* this freezer is freezing */
@@ -50,6 +57,15 @@ static inline struct freezer *task_freezer(struct task_struct *task)
 			    struct freezer, css);
 }
 
+static struct freezer *parent_freezer(struct freezer *freezer)
+{
+	struct cgroup *pcg = freezer->css.cgroup->parent;
+
+	if (pcg)
+		return cgroup_freezer(pcg);
+	return NULL;
+}
+
 bool cgroup_freezing(struct task_struct *task)
 {
 	bool ret;
@@ -74,17 +90,6 @@ static const char *freezer_state_strs(unsigned int state)
 	return "THAWED";
 };
 
-/*
- * State diagram
- * Transitions are caused by userspace writes to the freezer.state file.
- * The values in parenthesis are state labels. The rest are edge labels.
- *
- * (THAWED) --FROZEN--> (FREEZING) --FROZEN--> (FROZEN)
- *    ^ ^                    |                     |
- *    | \_______THAWED_______/                     |
- *    \__________________________THAWED____________/
- */
-
 struct cgroup_subsys freezer_subsys;
 
 static struct cgroup_subsys_state *freezer_create(struct cgroup *cgroup)
@@ -103,15 +108,34 @@ static struct cgroup_subsys_state *freezer_create(struct cgroup *cgroup)
  * freezer_post_create - commit creation of a freezer cgroup
  * @cgroup: cgroup being created
  *
- * We're committing to creation of @cgroup.  Mark it online.
+ * We're committing to creation of @cgroup.  Mark it online and inherit
+ * parent's freezing state while holding both parent's and our
+ * freezer->lock.
  */
 static void freezer_post_create(struct cgroup *cgroup)
 {
 	struct freezer *freezer = cgroup_freezer(cgroup);
+	struct freezer *parent = parent_freezer(freezer);
+
+	/*
+	 * The following double locking and freezing state inheritance
+	 * guarantee that @cgroup can never escape ancestors' freezing
+	 * states.  See cgroup_for_each_descendant_pre() for details.
+	 */
+	if (parent)
+		spin_lock_irq(&parent->lock);
+	spin_lock_nested(&freezer->lock, SINGLE_DEPTH_NESTING);
 
-	spin_lock_irq(&freezer->lock);
 	freezer->state |= CGROUP_FREEZER_ONLINE;
-	spin_unlock_irq(&freezer->lock);
+
+	if (parent && (parent->state & CGROUP_FREEZING)) {
+		freezer->state |= CGROUP_FREEZING_PARENT | CGROUP_FROZEN;
+		atomic_inc(&system_freezing_cnt);
+	}
+
+	spin_unlock(&freezer->lock);
+	if (parent)
+		spin_unlock_irq(&parent->lock);
 }
 
 /**
@@ -153,6 +177,7 @@ static void freezer_attach(struct cgroup *new_cgrp, struct cgroup_taskset *tset)
 {
 	struct freezer *freezer = cgroup_freezer(new_cgrp);
 	struct task_struct *task;
+	bool clear_frozen = false;
 
 	spin_lock_irq(&freezer->lock);
 
@@ -172,10 +197,25 @@ static void freezer_attach(struct cgroup *new_cgrp, struct cgroup_taskset *tset)
 		} else {
 			freeze_task(task);
 			freezer->state &= ~CGROUP_FROZEN;
+			clear_frozen = true;
 		}
 	}
 
 	spin_unlock_irq(&freezer->lock);
+
+	/*
+	 * Propagate FROZEN clearing upwards.  We may race with
+	 * update_if_frozen(), but as long as both work bottom-up, either
+	 * update_if_frozen() sees child's FROZEN cleared or we clear the
+	 * parent's FROZEN later.  No parent w/ !FROZEN children can be
+	 * left FROZEN.
+	 */
+	while (clear_frozen && (freezer = parent_freezer(freezer))) {
+		spin_lock_irq(&freezer->lock);
+		freezer->state &= ~CGROUP_FROZEN;
+		clear_frozen = freezer->state & CGROUP_FREEZING;
+		spin_unlock_irq(&freezer->lock);
+	}
 }
 
 static void freezer_fork(struct task_struct *task)
@@ -200,24 +240,47 @@ out:
 	rcu_read_unlock();
 }
 
-/*
- * We change from FREEZING to FROZEN lazily if the cgroup was only
- * partially frozen when we exitted write.  Caller must hold freezer->lock.
+/**
+ * update_if_frozen - update whether a cgroup finished freezing
+ * @cgroup: cgroup of interest
+ *
+ * Once FREEZING is initiated, transition to FROZEN is lazily updated by
+ * calling this function.  If the current state is FREEZING but not FROZEN,
+ * this function checks whether all tasks of this cgroup and the descendant
+ * cgroups finished freezing and, if so, sets FROZEN.
+ *
+ * The caller is responsible for grabbing RCU read lock and calling
+ * update_if_frozen() on all descendants prior to invoking this function.
  *
  * Task states and freezer state might disagree while tasks are being
  * migrated into or out of @cgroup, so we can't verify task states against
  * @freezer state here.  See freezer_attach() for details.
  */
-static void update_if_frozen(struct freezer *freezer)
+static void update_if_frozen(struct cgroup *cgroup)
 {
-	struct cgroup *cgroup = freezer->css.cgroup;
+	struct freezer *freezer = cgroup_freezer(cgroup);
+	struct cgroup *pos;
 	struct cgroup_iter it;
 	struct task_struct *task;
 
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	spin_lock_irq(&freezer->lock);
+
 	if (!(freezer->state & CGROUP_FREEZING) ||
 	    (freezer->state & CGROUP_FROZEN))
-		return;
+		goto out_unlock;
+
+	/* are all (live) children frozen? */
+	cgroup_for_each_child(pos, cgroup) {
+		struct freezer *child = cgroup_freezer(pos);
 
+		if ((child->state & CGROUP_FREEZER_ONLINE) &&
+		    !(child->state & CGROUP_FROZEN))
+			goto out_unlock;
+	}
+
+	/* are all tasks frozen? */
 	cgroup_iter_start(cgroup, &it);
 
 	while ((task = cgroup_iter_next(cgroup, &it))) {
@@ -229,27 +292,32 @@ static void update_if_frozen(struct freezer *freezer)
 			 * the usual frozen condition.
 			 */
 			if (!frozen(task) && !freezer_should_skip(task))
-				goto notyet;
+				goto out_iter_end;
 		}
 	}
 
 	freezer->state |= CGROUP_FROZEN;
-notyet:
+out_iter_end:
 	cgroup_iter_end(cgroup, &it);
+out_unlock:
+	spin_unlock_irq(&freezer->lock);
 }
 
 static int freezer_read(struct cgroup *cgroup, struct cftype *cft,
 			struct seq_file *m)
 {
-	struct freezer *freezer = cgroup_freezer(cgroup);
-	unsigned int state;
+	struct cgroup *pos;
 
-	spin_lock_irq(&freezer->lock);
-	update_if_frozen(freezer);
-	state = freezer->state;
-	spin_unlock_irq(&freezer->lock);
+	rcu_read_lock();
 
-	seq_puts(m, freezer_state_strs(state));
+	/* update states bottom-up */
+	cgroup_for_each_descendant_post(pos, cgroup)
+		update_if_frozen(pos);
+	update_if_frozen(cgroup);
+
+	rcu_read_unlock();
+
+	seq_puts(m, freezer_state_strs(cgroup_freezer(cgroup)->state));
 	seq_putc(m, '\n');
 	return 0;
 }
@@ -320,14 +388,39 @@ static void freezer_apply_state(struct freezer *freezer, bool freeze,
  * @freezer: freezer of interest
  * @freeze: whether to freeze or thaw
  *
- * Freeze or thaw @cgroup according to @freeze.
+ * Freeze or thaw @freezer according to @freeze.  The operations are
+ * recursive - all descendants of @freezer will be affected.
  */
 static void freezer_change_state(struct freezer *freezer, bool freeze)
 {
+	struct cgroup *pos;
+
 	/* update @freezer */
 	spin_lock_irq(&freezer->lock);
 	freezer_apply_state(freezer, freeze, CGROUP_FREEZING_SELF);
 	spin_unlock_irq(&freezer->lock);
+
+	/*
+	 * Update all its descendants in pre-order traversal.  Each
+	 * descendant will try to inherit its parent's FREEZING state as
+	 * CGROUP_FREEZING_PARENT.
+	 */
+	rcu_read_lock();
+	cgroup_for_each_descendant_pre(pos, freezer->css.cgroup) {
+		struct freezer *pos_f = cgroup_freezer(pos);
+		struct freezer *parent = parent_freezer(freezer);
+
+		/*
+		 * Our update to @parent->state is already visible which is
+		 * all we need.  No need to lock @parent.  For more info on
+		 * synchronization, see freezer_post_create().
+		 */
+		spin_lock_irq(&pos_f->lock);
+		freezer_apply_state(pos_f, parent->state & CGROUP_FREEZING,
+				    CGROUP_FREEZING_PARENT);
+		spin_unlock_irq(&pos_f->lock);
+	}
+	rcu_read_unlock();
 }
 
 static int freezer_write(struct cgroup *cgroup, struct cftype *cft,
@@ -390,12 +483,4 @@ struct cgroup_subsys freezer_subsys = {
 	.attach		= freezer_attach,
 	.fork		= freezer_fork,
 	.base_cftypes	= files,
-
-	/*
-	 * freezer subsys doesn't handle hierarchy at all.  Frozen state
-	 * should be inherited through the hierarchy - if a parent is
-	 * frozen, all its children should be frozen.  Fix it and remove
-	 * the following.
-	 */
-	.broken_hierarchy = true,
 };
-- 
1.7.11.7
