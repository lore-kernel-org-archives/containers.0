From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC PATCH 2/9] cgroup: introduce the top root
Date: Mon, 17 Dec 2012 14:43:28 +0800
Message-ID: <1355726615-15224-3-git-send-email-gaofeng__37411.6002153189$1355726660$gmane$org@cn.fujitsu.com>
References: <1355726615-15224-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1355726615-15224-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

We will allow container to allocate new hierarchy,
and because the cgroup subsystems only can be linked
with one cgroupfs_root. so it's need to add a new field
top_root for cgroupfs_root to point out which subsystems
binds to this hierarchy.

Add a helper function find_top_root to help find out the
top_root.

also rename root_count to top_root_count.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   29 ++++++++++++++++++++++++-----
 1 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 7d095b7..27ebeaf 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -132,6 +132,9 @@ struct cgroupfs_root {
 	/* The pid namespace this hierarchy belongs to */
 	struct pid_namespace *pid_ns;
 
+	/* The top root,subsystem only links with top root */
+	struct cgroupfs_root *top_root;
+
 	/* A list running through the active hierarchies */
 	struct list_head root_list;
 
@@ -234,7 +237,7 @@ struct cgroup_event {
 /* The list of hierarchy roots */
 
 static LIST_HEAD(roots);
-static int root_count;
+static int top_root_count;
 
 static DEFINE_IDA(hierarchy_ida);
 static int next_hierarchy_id;
@@ -682,7 +685,7 @@ static struct css_set *find_css_set(
 		return NULL;
 
 	/* Allocate all the cg_cgroup_link objects that we'll need */
-	if (allocate_cg_links(root_count, &tmp_cg_links) < 0) {
+	if (allocate_cg_links(top_root_count, &tmp_cg_links) < 0) {
 		kfree(res);
 		return NULL;
 	}
@@ -847,6 +850,20 @@ static struct backing_dev_info cgroup_backing_dev_info = {
 static int alloc_css_id(struct cgroup_subsys *ss,
 			struct cgroup *parent, struct cgroup *child);
 
+/*
+ * Find out the top root by subsys_mask.
+ */
+static struct cgroupfs_root *find_top_root(unsigned long subsys_mask)
+{
+	struct cgroupfs_root *existing_root;
+	for_each_active_root(existing_root) {
+		if (!test_bit(ROOT_NAMESPACE, &existing_root->flags) &&
+		    existing_root->subsys_mask == subsys_mask)
+			return existing_root;
+	}
+	return NULL;
+}
+
 static struct inode *cgroup_new_inode(umode_t mode, struct super_block *sb)
 {
 	struct inode *inode = new_inode(sb);
@@ -1416,6 +1433,7 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 	INIT_LIST_HEAD(&root->root_list);
 	INIT_LIST_HEAD(&root->allcg_list);
 	root->number_of_cgroups = 1;
+	root->top_root = root;
 	cgrp->root = root;
 	cgrp->top_cgroup = cgrp;
 	init_cgroup_housekeeping(cgrp);
@@ -1656,7 +1674,7 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 		BUG_ON(ret);
 
 		list_add(&root->root_list, &roots);
-		root_count++;
+		top_root_count++;
 
 		sb->s_root->d_fsdata = root_cgrp;
 		root->top_cgroup.dentry = sb->s_root;
@@ -1749,7 +1767,8 @@ static void cgroup_kill_sb(struct super_block *sb) {
 
 	if (!list_empty(&root->root_list)) {
 		list_del(&root->root_list);
-		root_count--;
+		if (!test_bit(ROOT_NAMESPACE, &root->flags))
+			top_root_count--;
 	}
 
 	mutex_unlock(&cgroup_root_mutex);
@@ -4635,7 +4654,7 @@ int __init cgroup_init_early(void)
 	INIT_HLIST_NODE(&init_css_set.hlist);
 	css_set_count = 1;
 	init_cgroup_root(&rootnode);
-	root_count = 1;
+	top_root_count = 1;
 	init_task.cgroups = &init_css_set;
 
 	init_css_set_link.cg = &init_css_set;
-- 
1.7.7.6
