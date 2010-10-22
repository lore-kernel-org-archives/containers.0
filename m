From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 3/7] cgroups: Allow to unbind subsystem from a cgroup
	hierarachy
Date: Fri, 22 Oct 2010 16:10:29 +0800
Message-ID: <4CC146F5.9060006__46286.8739887655$1287735007$gmane$org@cn.fujitsu.com>
References: <4CC146A4.9090505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CC146A4.9090505-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "akpm >> Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

This allows us to unbind a cgroup subsystem from a hierarchy
which has sub-cgroups in it.

Due to some complexity, for now subsytems that use css_get/put()
can't be unbound from such a hierarchy.

Usage:

# mount -t cgroup -o cpuset,cpuacct xxx /mnt
# mkdir /mnt/tmp
# echo $$ > /mnt/tmp/tasks

(remove it from the hierarchy)
# mount -o remount,cpuset xxx /mnt

Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   76 ++++++++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 61 insertions(+), 15 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 46df5f8..9ce3fdb 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1036,19 +1036,42 @@ static int hierarchy_attach_css(struct cgroup *cgrp, void *data)
 	return ret;
 }
 
-static int hierarchy_update_css_sets(struct cgroup *cgrp, void *data)
+static int hierarchy_remove_css(struct cgroup *cgrp, void *data)
 {
-	unsigned long added_bits = (unsigned long)data;
+	unsigned long removed_bits = (unsigned long)data;
 	int i;
+
+	/*
+	 * There might be some pointers to the cgroup_subsys_state
+	 * that we are going to destroy.
+	 */
+	synchronize_rcu();
+
+	for_each_set_bit(i, &removed_bits, CGROUP_SUBSYS_COUNT) {
+		subsys[i]->destroy(subsys[i], cgrp);
+		cgrp->subsys[i] = NULL;
+	}
+
+	return 0;
+}
+
+static void hierarchy_update_css_sets(struct cgroup *cgrp,
+				      unsigned long bits, bool add)
+{
 	struct cg_cgroup_link *link;
+	int i;
 
 	write_lock(&css_set_lock);
 	list_for_each_entry(link, &cgrp->css_sets, cgrp_link_list) {
 		struct css_set *cg = link->cg;
 		struct hlist_head *hhead;
 
-		for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT)
-			cg->subsys[i] = cgrp->subsys[i];
+		for_each_set_bit(i, &bits, CGROUP_SUBSYS_COUNT) {
+			if (add)
+				cg->subsys[i] = cgrp->subsys[i];
+			else
+				cg->subsys[i] = dummytop->subsys[i];
+		}
 
 		/* rehash */
 		hlist_del(&cg->hlist);
@@ -1056,7 +1079,21 @@ static int hierarchy_update_css_sets(struct cgroup *cgrp, void *data)
 		hlist_add_head(&cg->hlist, hhead);
 	}
 	write_unlock(&css_set_lock);
+}
 
+static int hierarchy_add_to_css_sets(struct cgroup *cgrp, void *data)
+{
+	unsigned long added_bits = (unsigned long)data;
+
+	hierarchy_update_css_sets(cgrp, added_bits, true);
+	return 0;
+}
+
+static int hierarchy_remove_from_css_sets(struct cgroup *cgrp, void *data)
+{
+	unsigned long removed_bits = (unsigned long)data;
+
+	hierarchy_update_css_sets(cgrp, removed_bits, false);
 	return 0;
 }
 
@@ -1076,7 +1113,7 @@ static int hierarchy_populate_dir(struct cgroup *cgrp, void *data)
 static int rebind_subsystems(struct cgroupfs_root *root,
 			      unsigned long final_bits)
 {
-	unsigned long added_bits, removed_bits;
+	unsigned long added_bits, removed_bits, changed_bits;
 	struct cgroup *cgrp = &root->top_cgroup;
 	int i;
 	int err;
@@ -1085,6 +1122,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 
 	removed_bits = root->actual_subsys_bits & ~final_bits;
 	added_bits = final_bits & ~root->actual_subsys_bits;
+	changed_bits = removed_bits | added_bits;
 
 	/* Check that any added subsystems are currently free */
 	for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT) {
@@ -1100,14 +1138,11 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 		}
 	}
 
-	/* removing will be supported later */
-	if (root->number_of_cgroups > 1 && removed_bits)
-		return -EBUSY;
-
 	if (root->number_of_cgroups > 1) {
-		for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT)
+		for_each_set_bit(i, &changed_bits, CGROUP_SUBSYS_COUNT)
 			if (!subsys[i]->can_bind)
 				return -EBUSY;
+	}
 
 	for_each_set_bit(i, &added_bits, CGROUP_SUBSYS_COUNT) {
 		BUG_ON(cgrp->subsys[i]);
@@ -1123,7 +1158,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 	if (err)
 		goto failed;
 
-	cgroup_walk_hierarchy(hierarchy_update_css_sets,
+	cgroup_walk_hierarchy(hierarchy_add_to_css_sets,
 			      (void *)added_bits, cgrp);
 
 	/* Process each subsystem */
@@ -1143,11 +1178,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
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
@@ -1173,6 +1204,21 @@ static int rebind_subsystems(struct cgroupfs_root *root,
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
+	cgroup_walk_hierarchy(hierarchy_remove_css,
+			      (void *)removed_bits, cgrp);
+
 	synchronize_rcu();
 
 	return 0;
-- 
1.7.0.1
