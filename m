From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH v2 3/6] cgroups: Allow to unbind subsystem from a cgroup
	hierarchy
Date: Wed, 15 Dec 2010 17:35:33 +0800
Message-ID: <4D088BE5.1000708__32957.8954646879$1292405768$gmane$org@cn.fujitsu.com>
References: <4D088BB5.30903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D088BB5.30903-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This allows us to unbind a cgroup subsystem from a hierarchy
which has sub-cgroups in it.

If a subsystem is to support unbinding, when pinning a cgroup
via css refcnt, it should use __css_tryget() instead of css_get().

Usage:

 # mount -t cgroup -o cpuset,cpuacct xxx /mnt
 # mkdir /mnt/tmp
 # echo $$ > /mnt/tmp/tasks

 (remove it from the hierarchy)
 # mount -o remount,cpuset xxx /mnt

Changelog v2:

- Allow a cgroup subsystem to use css refcnt.
- Add more code comments.
- Use rcu_assign_pointer() in hierarchy_update_css_sets().
- Split can_bind flag to bindable and unbindable flags.

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/linux/cgroup.h |   17 ++++++
 kernel/cgroup.c        |  139 +++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 138 insertions(+), 18 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index d8c4e22..17579b2 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -110,6 +110,18 @@ static inline bool css_is_removed(struct cgroup_subsys_state *css)
 }
 
 /*
+ * For a subsystem which supports unbinding, call this to get css
+ * refcnt. Called with rcu_read_lock or cgroup_mutex held.
+ */
+
+static inline bool __css_tryget(struct cgroup_subsys_state *css)
+{
+	if (test_bit(CSS_ROOT, &css->flags))
+		return true;
+	return atomic_inc_not_zero(&css->refcnt);
+}
+
+/*
  * Call css_tryget() to take a reference on a css if your existing
  * (known-valid) reference isn't already ref-counted. Returns false if
  * the css has been destroyed.
@@ -495,6 +507,11 @@ struct cgroup_subsys {
 	 * which has child cgroups.
 	 */
 	bool bindable:1;
+	/*
+	 * Indicate if this subsystem can be removed from a cgroup hierarchy
+	 * which has child cgroups.
+	 */
+	bool unbindable:1;
 
 #define MAX_CGROUP_TYPE_NAMELEN 32
 	const char *name;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index caac80f..463575d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1055,12 +1055,61 @@ static int hierarchy_attach_css(struct cgroup *cgrp, void *data)
 }
 
 /*
- * After attaching new css objects to the cgroup, we need to entangle
- * them into the existing css_sets.
+ * Reset those css objects whose refcnts are cleared.
  */
-static int hierarchy_update_css_sets(struct cgroup *cgrp, void *data)
+static int hierarchy_reset_css_refs(struct cgroup *cgrp, void *data)
+{
+	unsigned long removed_bits = (unsigned long)data;
+	int i;
+
+	for_each_set_bit(i, &removed_bits, CGROUP_SUBSYS_COUNT) {
+		if (atomic_read(&css->refcnt) == 0)
+			atomic_set(&css->refcnt, 1);
+	}
+	return 0;
+}
+
+/*
+ * Clear all the css objects' refcnt to 0. If there's a refcnt > 1,
+ * return failure.
+ */
+static int hierarchy_clear_css_refs(struct cgroup *cgrp, void *data)
+{
+	unsigned long removed_bits = (unsigned long)data;
+	int i;
+
+	for_each_set_bit(i, &removed_bits, CGROUP_SUBSYS_COUNT) {
+		struct cgroup_subsys_state *css = cgrp->subsys[i];
+
+		if (atomic_cmpxchg(&css->refcnt, 1, 0) != 1)
+			goto failed;
+	}
+	return 0;
+failed:
+	hierarchy_reset_css_refs(struct cgroup *cgrp, void *data);
+	return -EBUSY;
+}
+
+/*
+ * We're removing some subsystems from cgroup hierarchy, and here we
+ * remove and destroy the css objects from each cgroup.
+ */
+static int hierarchy_remove_css(struct cgroup *cgrp, void *data)
+{
+	unsigned long removed_bits = (unsigned long)data;
+	int i;
+
+	for_each_set_bit(i, &removed_bits, CGROUP_SUBSYS_COUNT) {
+		subsys[i]->destroy(subsys[i], cgrp);
+		cgrp->subsys[i] = NULL;
+	}
+
+	return 0;
+}
+
+static int hierarchy_update_css_sets(struct cgroup *cgrp,
+				     unsigned long bits, bool add)
 {
-	unsigned long added_bits = (unsigned long)data;
 	int i;
 	struct cg_cgroup_link *link;
 
@@ -1069,8 +1118,14 @@ static int hierarchy_update_css_sets(struct cgroup *cgrp, void *data)
 		struct css_set *cg = link->cg;
 		struct hlist_head *hhead;
 
-		for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT)
-			rcu_assign_pointer(cg->subsys[i], cgrp->subsys[i]);
+		for_each_set_bit(i, &bits, CGROUP_SUBSYS_COUNT) {
+			if (add)
+				rcu_assign_pointer(cg->subsys[i],
+						   cgrp->subsys[i]);
+			else
+				rcu_assign_pointer(cg->subsys[i],
+						   dummytop->subsys[i]);
+		}
 
 		/* rehash */
 		hlist_del(&cg->hlist);
@@ -1083,6 +1138,30 @@ static int hierarchy_update_css_sets(struct cgroup *cgrp, void *data)
 }
 
 /*
+ * After attaching new css objects to the cgroup, we need to entangle
+ * them into the existing css_sets.
+ */
+static int hierarchy_add_to_css_sets(struct cgroup *cgrp, void *data)
+{
+	unsigned long added_bits = (unsigned long)data;
+
+	hierarchy_update_css_sets(cgrp, added_bits, true);
+	return 0;
+}
+
+/*
+ * Before dettaching and destroying css objects from the cgroup, we
+ * should detangle them from the existing css_sets.
+ */
+static int hierarchy_remove_from_css_sets(struct cgroup *cgrp, void *data)
+{
+	unsigned long removed_bits = (unsigned long)data;
+
+	hierarchy_update_css_sets(cgrp, removed_bits, false);
+	return 0;
+}
+
+/*
  * Re-populate each cgroup directory.
  *
  * Note root cgroup's inode mutex is held.
@@ -1127,18 +1206,17 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 		}
 	}
 
-	/* Removing will be supported later */
-	if (root->number_of_cgroups > 1 && removed_bits)
-		return -EBUSY;
-
 	/*
 	 * For non-trivial hierarchy, check that added subsystems
-	 * are all bindable
+	 * are all bindable and removed subsystems are all unbindable
 	 */
 	if (root->number_of_cgroups > 1) {
 		for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT)
 			if (!subsys[i]->bindable)
 				return -EBUSY;
+		for_each_set_bit(i, &removed_bits, CGROUP_SUBSYS_COUNT)
+			if (!subsys[i]->unbindable)
+				return -EBUSY;
 	}
 
 	/* Attach css objects to the top cgroup */
@@ -1154,9 +1232,14 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	err = cgroup_walk_hierarchy(hierarchy_attach_css,
 				    (void *)added_bits, cgrp);
 	if (err)
-		goto failed;
+		goto out;
+
+	err = cgroup_walk_hierarchy(hierarchy_clear_css_refs,
+				    (void *)removed_bits, cgrp);
+	if (err)
+		goto out_remove_css;
 
-	cgroup_walk_hierarchy(hierarchy_update_css_sets,
+	cgroup_walk_hierarchy(hierarchy_add_to_css_sets,
 			      (void *)added_bits, cgrp);
 
 	/* Process each subsystem */
@@ -1176,11 +1259,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 		} else if (bit & removed_bits) {
 			/* We're removing this subsystem */
 			BUG_ON(ss == NULL);
-			BUG_ON(cgrp->subsys[i] != dummytop->subsys[i]);
-			BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
 			mutex_lock(&ss->hierarchy_mutex);
-			dummytop->subsys[i]->cgroup = dummytop;
-			cgrp->subsys[i] = NULL;
 			if (ss->bind)
 				ss->bind(ss, dummytop);
 			subsys[i]->root = &rootnode;
@@ -1206,11 +1285,35 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 		}
 	}
 	root->subsys_bits = root->actual_subsys_bits = final_bits;
+
+	for_each_set_bit(i, &removed_bits, CGROUP_SUBSYS_COUNT) {
+		BUG_ON(cgrp->subsys[i] != dummytop->subsys[i]);
+		BUG_ON(cgrp->subsys[i]->cgroup != cgrp);
+
+		dummytop->subsys[i]->cgroup = dummytop;
+		cgrp->subsys[i] = NULL;
+	}
+
+	cgroup_walk_hierarchy(hierarchy_remove_from_css_sets,
+			      (void *)removed_bits, cgrp);
+
+	/*
+	 * There might be some pointers to the cgrouip_subsys_state
+	 * that we are going to destroy.
+	 */
+	synchronize_rcu();
+
+	cgroup_walk_hierarchy(hierarchy_remove_css,
+			      (void *)removed_bits, cgrp);
+
 	synchronize_rcu();
 
 	return 0;
 
-failed:
+out_remove_css:
+	cgroup_walk_hierarchy(hierarchy_remove_css,
+			      (void *)added_bits, cgrp);
+out:
 	for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT)
 		cgrp->subsys[i] = NULL;
 
-- 
1.6.3
