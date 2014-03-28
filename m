From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 12/12] cgroup: implement dynamic subtree controller
	enable/disable on the default hierarchy
Date: Thu, 27 Mar 2014 22:41:01 -0400
Message-ID: <1395974461-12735-13-git-send-email-tj__20497.2219457433$1395974577$gmane$org@kernel.org>
References: <1395974461-12735-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1395974461-12735-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

cgroup is switching away from multiple hierarchies and will use one
unified default hierarchy where controllers can be dynamically enabled
and disabled per subtree.  The default hierarchy will serve as the
unified hierarchy to which all controllers are attached and a css on
the default hierarchy would need to also serve the tasks of descendant
cgroups which don't have the controller enabled - ie. the tree may be
collapsed from leaf towards root when viewed from specific
controllers.  This has been implemented through effective css in the
previous patches.

This patch finally implements dynamic subtree controller
enable/disable on the default hierarchy via a new knob -
"cgroup.subtree_control" which controls which controllers are enabled
on the child cgroups.  Let's assume a hierarchy like the following.

  root - A - B - C
               \ D

root's "cgroup.subtree_control" determines which controllers are
enabled on A.  A's on B.  B's on C and D.  This coincides with the
fact that controllers on the immediate sub-level are used to
distribute the resources of the parent.  In fact, it's natural to
assume that resource control knobs of a child belong to its parent.
Enabling a controller in "cgroup.subtree_control" declares that
distribution of the respective resources of the cgroup will be
controlled.  Note that this means that controller enable states are
shared among siblings.

The default hierarchy has an extra restriction - only cgroups which
don't contain any task may have controllers enabled in
"cgroup.subtree_control".  Combined with the other properties of the
default hierarchy, this guarantees that, from the view point of
controllers, tasks are only on the leaf cgroups.  In other words, only
leaf csses may contain tasks.  This rules out situations where child
cgroups compete against internal tasks of the parent, which is a
competition between two different types of entities without any clear
way to determine resource distribution between the two.  Different
controllers handle it differently and all the implemented behaviors
are ambiguous, ad-hoc, cumbersome and/or just wrong.  Having this
structural constraints imposed from cgroup core removes the burden
from controller implementations and enables showing one consistent
behavior across all controllers.

When a controller is enabled or disabled, css associations for the
controller in the subtrees of each child should be updated.  After
enabling, the whole subtree of a child should point to the new css of
the child.  After disabling, the whole subtree of a child should point
to the cgroup's css.  This is implemented by first updating cgroup
states such that cgroup_e_css() result points to the appropriate css
and then invoking cgroup_update_dfl_csses() which migrates all tasks
in the affected subtrees to the self cgroup on the default hierarchy.

* When read, "cgroup.subtree_control" lists all the currently enabled
  controllers on the children of the cgroup.

* White-space separated list of controller names prefixed with either
  '+' or '-' can be written to "cgroup.subtree_control".  The ones
  prefixed with '+' are enabled on the controller and '-' disabled.

* A controller can be enabled iff the parent's
  "cgroup.subtree_control" enables it and disabled iff no child's
  "cgroup.subtree_control" has it enabled.

* If a cgroup has tasks, no controller can be enabled via
  "cgroup.subtree_control".  Likewise, if "cgroup.subtree_control" has
  some controllers enabled, tasks can't be migrated into the cgroup.

* All controllers which aren't bound on other hierarchies are
  automatically associated with the root cgroup of the default
  hierarchy.  All the controllers which are bound to the default
  hierarchy are listed in the read-only file "cgroup.controllers" in
  the root directory.

This is still experimental and there are some holes, one of which is
that ->can_attach() failure during cgroup_update_dfl_csses() may leave
the cgroups in an undefined state.  The issues will be addressed by
future patches.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |   5 +
 kernel/cgroup.c        | 346 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 351 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index b6f5e40..dee6f3c 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -21,6 +21,7 @@
 #include <linux/percpu-refcount.h>
 #include <linux/seq_file.h>
 #include <linux/kernfs.h>
+#include <linux/wait.h>
 
 #ifdef CONFIG_CGROUPS
 
@@ -164,6 +165,7 @@ struct cgroup {
 
 	struct cgroup *parent;		/* my parent */
 	struct kernfs_node *kn;		/* cgroup kernfs entry */
+	struct kernfs_node *control_kn;	/* kn for "cgroup.subtree_control" */
 
 	/*
 	 * Monotonically increasing unique serial number which defines a
@@ -216,6 +218,9 @@ struct cgroup {
 	/* For css percpu_ref killing and RCU-protected deletion */
 	struct rcu_head rcu_head;
 	struct work_struct destroy_work;
+
+	/* used to wait for offlining of csses */
+	wait_queue_head_t offline_waitq;
 };
 
 #define MAX_CGROUP_ROOT_NAMELEN 64
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5faa115..4e958c7 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -182,6 +182,8 @@ static int rebind_subsystems(struct cgroup_root *dst_root,
 			     unsigned long ss_mask);
 static void cgroup_destroy_css_killed(struct cgroup *cgrp);
 static int cgroup_destroy_locked(struct cgroup *cgrp);
+static int create_css(struct cgroup *cgrp, struct cgroup_subsys *ss);
+static void kill_css(struct cgroup_subsys_state *css);
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
 			      bool is_add);
 static void cgroup_pidlist_destroy_all(struct cgroup *cgrp);
@@ -338,6 +340,14 @@ static int notify_on_release(const struct cgroup *cgrp)
 #define for_each_root(root)						\
 	list_for_each_entry((root), &cgroup_roots, root_list)
 
+/* iterate over child cgrps, lock should be held throughout iteration */
+#define cgroup_for_each_live_child(child, cgrp)				\
+	list_for_each_entry((child), &(cgrp)->children, sibling)	\
+		if (({ lockdep_assert_held(&cgroup_tree_mutex);		\
+		       cgroup_is_dead(child); }))			\
+			;						\
+		else
+
 /**
  * cgroup_lock_live_group - take cgroup_mutex and check that cgrp is alive.
  * @cgrp: the cgroup to be checked for liveness
@@ -1450,6 +1460,8 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 
 	for_each_subsys(ss, ssid)
 		INIT_LIST_HEAD(&cgrp->e_csets[ssid]);
+
+	init_waitqueue_head(&cgrp->offline_waitq);
 }
 
 static void init_cgroup_root(struct cgroup_root *root,
@@ -1937,6 +1949,14 @@ static int cgroup_migrate_prepare_dst(struct cgroup *dst_cgrp,
 
 	lockdep_assert_held(&cgroup_mutex);
 
+	/*
+	 * Except for the root, child_subsys_mask must be zero for a cgroup
+	 * with tasks so that child cgroups don't compete against tasks.
+	 */
+	if (dst_cgrp && cgroup_on_dfl(dst_cgrp) && dst_cgrp->parent &&
+	    dst_cgrp->child_subsys_mask)
+		return -EBUSY;
+
 	/* look up the dst cset for each src cset and link it to src */
 	list_for_each_entry_safe(src_cset, tmp_cset, preloaded_csets, mg_preload_node) {
 		struct css_set *dst_cset;
@@ -2302,6 +2322,317 @@ static int cgroup_sane_behavior_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
+static void cgroup_print_ss_mask(struct seq_file *seq, unsigned int ss_mask)
+{
+	struct cgroup_subsys *ss;
+	bool printed = false;
+	int ssid;
+
+	for_each_subsys(ss, ssid) {
+		if (ss_mask & (1 << ssid)) {
+			if (printed)
+				seq_putc(seq, ' ');
+			seq_printf(seq, "%s", ss->name);
+			printed = true;
+		}
+	}
+	if (printed)
+		seq_putc(seq, '\n');
+}
+
+/* show controllers which are currently attached to the default hierarchy */
+static int cgroup_controllers_show(struct seq_file *seq, void *v)
+{
+	struct cgroup *cgrp = seq_css(seq)->cgroup;
+
+	cgroup_print_ss_mask(seq, cgrp->root->subsys_mask);
+	return 0;
+}
+
+/* show controllers which are enabled for a given cgroup's children */
+static int cgroup_subtree_control_show(struct seq_file *seq, void *v)
+{
+	struct cgroup *cgrp = seq_css(seq)->cgroup;
+
+	cgroup_print_ss_mask(seq, cgrp->child_subsys_mask);
+	return 0;
+}
+
+/**
+ * cgroup_update_dfl_csses - update css assoc of a subtree in default hierarchy
+ * @cgrp: root of the subtree to update csses for
+ *
+ * @cgrp's child_subsys_mask has changed and its subtree's (self excluded)
+ * css associations need to be updated accordingly.  This function looks up
+ * all css_sets which are attached to the subtree, creates the matching
+ * updated css_sets and migrates the tasks to the new ones.
+ */
+static int cgroup_update_dfl_csses(struct cgroup *cgrp)
+{
+	LIST_HEAD(preloaded_csets);
+	struct cgroup_subsys_state *css;
+	struct css_set *src_cset;
+	int ret;
+
+	lockdep_assert_held(&cgroup_tree_mutex);
+	lockdep_assert_held(&cgroup_mutex);
+
+	/* look up all csses currently attached to @cgrp's subtree */
+	down_read(&css_set_rwsem);
+	css_for_each_descendant_pre(css, cgroup_css(cgrp, NULL)) {
+		struct cgrp_cset_link *link;
+
+		/* self is not affected by child_subsys_mask change */
+		if (css->cgroup == cgrp)
+			continue;
+
+		list_for_each_entry(link, &css->cgroup->cset_links, cset_link)
+			cgroup_migrate_add_src(link->cset, cgrp,
+					       &preloaded_csets);
+	}
+	up_read(&css_set_rwsem);
+
+	/* NULL dst indicates self on default hierarchy */
+	ret = cgroup_migrate_prepare_dst(NULL, &preloaded_csets);
+	if (ret)
+		goto out_finish;
+
+	list_for_each_entry(src_cset, &preloaded_csets, mg_preload_node) {
+		struct task_struct *last_task = NULL, *task;
+
+		/* src_csets precede dst_csets, break on the first dst_cset */
+		if (!src_cset->mg_src_cgrp)
+			break;
+
+		/*
+		 * All tasks in src_cset need to be migrated to the
+		 * matching dst_cset.  Empty it process by process.  We
+		 * walk tasks but migrate processes.  The leader might even
+		 * belong to a different cset but such src_cset would also
+		 * be among the target src_csets because the default
+		 * hierarchy enforces per-process membership.
+		 */
+		while (true) {
+			down_read(&css_set_rwsem);
+			task = list_first_entry_or_null(&src_cset->tasks,
+						struct task_struct, cg_list);
+			if (task) {
+				task = task->group_leader;
+				WARN_ON_ONCE(!task_css_set(task)->mg_src_cgrp);
+				get_task_struct(task);
+			}
+			up_read(&css_set_rwsem);
+
+			if (!task)
+				break;
+
+			/* guard against possible infinite loop */
+			if (WARN(last_task == task,
+				 "cgroup: update_dfl_csses failed to make progress, aborting in inconsistent state\n"))
+				goto out_finish;
+			last_task = task;
+
+			threadgroup_lock(task);
+			/* raced against de_thread() from another thread? */
+			if (!thread_group_leader(task)) {
+				threadgroup_unlock(task);
+				put_task_struct(task);
+				continue;
+			}
+
+			ret = cgroup_migrate(src_cset->dfl_cgrp, task, true);
+
+			threadgroup_unlock(task);
+			put_task_struct(task);
+
+			if (WARN(ret, "cgroup: failed to update controllers for the default hierarchy (%d), further operations may crash or hang\n", ret))
+				goto out_finish;
+		}
+	}
+
+out_finish:
+	cgroup_migrate_finish(&preloaded_csets);
+	return ret;
+}
+
+/* change the enabled child controllers for a cgroup in the default hierarchy */
+static int cgroup_subtree_control_write(struct cgroup_subsys_state *dummy_css,
+					struct cftype *cft, char *buffer)
+{
+	unsigned long enable_req = 0, disable_req = 0, enable, disable;
+	struct cgroup *cgrp = dummy_css->cgroup, *child;
+	struct cgroup_subsys *ss;
+	char *tok, *p;
+	int ssid, ret;
+
+	/*
+	 * Parse input - white space separated list of subsystem names
+	 * prefixed with either + or -.
+	 */
+	p = buffer;
+	while ((tok = strsep(&p, " \t\n"))) {
+		for_each_subsys(ss, ssid) {
+			if (ss->disabled || strcmp(tok + 1, ss->name))
+				continue;
+
+			if (*tok == '+') {
+				enable_req |= 1 << ssid;
+				disable_req &= ~(1 << ssid);
+			} else if (*tok == '-') {
+				disable_req |= 1 << ssid;
+				enable_req &= ~(1 << ssid);
+			} else {
+				return -EINVAL;
+			}
+			break;
+		}
+		if (ssid == CGROUP_SUBSYS_COUNT)
+			return -EINVAL;
+	}
+
+	/*
+	 * We're gonna grab cgroup_tree_mutex which nests outside kernfs
+	 * active_ref.  cgroup_lock_live_group() already provides enough
+	 * protection.  Ensure @cgrp stays accessible and break the
+	 * active_ref protection.
+	 */
+	cgroup_get(cgrp);
+	kernfs_break_active_protection(cgrp->control_kn);
+retry:
+	enable = enable_req;
+	disable = disable_req;
+
+	mutex_lock(&cgroup_tree_mutex);
+
+	for_each_subsys(ss, ssid) {
+		if (enable & (1 << ssid)) {
+			if (cgrp->child_subsys_mask & (1 << ssid)) {
+				enable &= ~(1 << ssid);
+				continue;
+			}
+
+			/*
+			 * Because css offlining is asynchronous, userland
+			 * might try to re-enable the same controller while
+			 * the previous instance is still around.  In such
+			 * cases, wait till it's gone using offline_waitq.
+			 */
+			cgroup_for_each_live_child(child, cgrp) {
+				wait_queue_t wait;
+
+				if (!cgroup_css(child, ss))
+					continue;
+
+				prepare_to_wait(&child->offline_waitq, &wait,
+						TASK_UNINTERRUPTIBLE);
+				mutex_unlock(&cgroup_tree_mutex);
+				schedule();
+				finish_wait(&child->offline_waitq, &wait);
+				goto retry;
+			}
+
+			/* unavailable or not enabled on the parent? */
+			if (!(cgrp_dfl_root.subsys_mask & (1 << ssid)) ||
+			    (cgrp->parent &&
+			     !(cgrp->parent->child_subsys_mask & (1 << ssid)))) {
+				ret = -ENOENT;
+				goto out_unlock_tree;
+			}
+		} else if (disable & (1 << ssid)) {
+			if (!(cgrp->child_subsys_mask & (1 << ssid))) {
+				disable &= ~(1 << ssid);
+				continue;
+			}
+
+			/* a child has it enabled? */
+			cgroup_for_each_live_child(child, cgrp) {
+				if (child->child_subsys_mask & (1 << ssid)) {
+					ret = -EBUSY;
+					goto out_unlock_tree;
+				}
+			}
+		}
+	}
+
+	if (!enable && !disable) {
+		ret = 0;
+		goto out_unlock_tree;
+	}
+
+	if (!cgroup_lock_live_group(cgrp)) {
+		ret = -ENODEV;
+		goto out_unlock_tree;
+	}
+
+	/*
+	 * Except for the root, child_subsys_mask must be zero for a cgroup
+	 * with tasks so that child cgroups don't compete against tasks.
+	 */
+	if (enable && cgrp->parent && !list_empty(&cgrp->cset_links)) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
+	/*
+	 * Create csses for enables and update child_subsys_mask.  This
+	 * changes cgroup_e_css() results which in turn makes the
+	 * subsequent cgroup_update_dfl_csses() associate all tasks in the
+	 * subtree to the updated csses.
+	 */
+	for_each_subsys(ss, ssid) {
+		if (!(enable & (1 << ssid)))
+			continue;
+
+		cgroup_for_each_live_child(child, cgrp) {
+			ret = create_css(child, ss);
+			if (ret)
+				goto err_undo_css;
+		}
+	}
+
+	cgrp->child_subsys_mask |= enable;
+	cgrp->child_subsys_mask &= ~disable;
+
+	ret = cgroup_update_dfl_csses(cgrp);
+	if (ret)
+		goto err_undo_css;
+
+	/* all tasks are now migrated away from the old csses, kill them */
+	for_each_subsys(ss, ssid) {
+		if (!(disable & (1 << ssid)))
+			continue;
+
+		cgroup_for_each_live_child(child, cgrp)
+			kill_css(cgroup_css(child, ss));
+	}
+
+	kernfs_activate(cgrp->kn);
+	ret = 0;
+out_unlock:
+	mutex_unlock(&cgroup_mutex);
+out_unlock_tree:
+	mutex_unlock(&cgroup_tree_mutex);
+	kernfs_unbreak_active_protection(cgrp->control_kn);
+	cgroup_put(cgrp);
+	return ret;
+
+err_undo_css:
+	cgrp->child_subsys_mask &= ~enable;
+	cgrp->child_subsys_mask |= disable;
+
+	for_each_subsys(ss, ssid) {
+		if (!(enable & (1 << ssid)))
+			continue;
+
+		cgroup_for_each_live_child(child, cgrp) {
+			struct cgroup_subsys_state *css = cgroup_css(child, ss);
+			if (css)
+				kill_css(css);
+		}
+	}
+	goto out_unlock;
+}
+
 static ssize_t cgroup_file_write(struct kernfs_open_file *of, char *buf,
 				 size_t nbytes, loff_t off)
 {
@@ -2442,6 +2773,8 @@ static int cgroup_add_file(struct cgroup *cgrp, struct cftype *cft)
 	kn = __kernfs_create_file(cgrp->kn, cgroup_file_name(cgrp, cft, name),
 				  cgroup_file_mode(cft), 0, cft->kf_ops, cft,
 				  NULL, false, key);
+	if (cft->seq_show == cgroup_subtree_control_show)
+		cgrp->control_kn = kn;
 	return PTR_ERR_OR_ZERO(kn);
 }
 
@@ -3539,6 +3872,17 @@ static struct cftype cgroup_base_files[] = {
 		.flags = CFTYPE_ONLY_ON_ROOT,
 		.seq_show = cgroup_sane_behavior_show,
 	},
+	{
+		.name = "cgroup.controllers",
+		.flags = CFTYPE_ONLY_ON_DFL | CFTYPE_ONLY_ON_ROOT,
+		.seq_show = cgroup_controllers_show,
+	},
+	{
+		.name = "cgroup.subtree_control",
+		.flags = CFTYPE_ONLY_ON_DFL,
+		.seq_show = cgroup_subtree_control_show,
+		.write_string = cgroup_subtree_control_write,
+	},
 
 	/*
 	 * Historical crazy stuff.  These don't have "cgroup."  prefix and
@@ -3707,6 +4051,8 @@ static void offline_css(struct cgroup_subsys_state *css)
 	css->flags &= ~CSS_ONLINE;
 	css->cgroup->nr_css--;
 	RCU_INIT_POINTER(css->cgroup->subsys[ss->id], NULL);
+
+	wake_up_all(&css->cgroup->offline_waitq);
 }
 
 /**
-- 
1.8.5.3
