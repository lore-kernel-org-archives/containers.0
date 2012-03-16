From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 02/10] cgroup: build list of all cgroups under a given
	cgroupfs_root
Date: Fri, 16 Mar 2012 16:35:55 -0700
Message-ID: <1331940963-15756-3-git-send-email-tj@kernel.org>
References: <1331940963-15756-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1331940963-15756-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Build a list of all cgroups anchored at cgroupfs_root->allcg_list and
going through cgroup->allcg_node.  The list is protected by
cgroup_mutex and will be used to improve cgroup file handling.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |    2 ++
 kernel/cgroup.c        |   10 ++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 501adb1..908f26f 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -191,6 +191,8 @@ struct cgroup {
 	 */
 	struct list_head css_sets;
 
+	struct list_head allcg_node;	/* cgroupfs_root->allcg_list */
+
 	/*
 	 * Linked list running through all cgroups that can
 	 * potentially be reaped by the release agent. Protected by
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2e2f93b..fceee52 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -127,6 +127,9 @@ struct cgroupfs_root {
 	/* A list running through the active hierarchies */
 	struct list_head root_list;
 
+	/* All cgroups on this root, cgroup_mutex protected */
+	struct list_head allcg_list;
+
 	/* Hierarchy-specific flags */
 	unsigned long flags;
 
@@ -1350,11 +1353,14 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 static void init_cgroup_root(struct cgroupfs_root *root)
 {
 	struct cgroup *cgrp = &root->top_cgroup;
+
 	INIT_LIST_HEAD(&root->subsys_list);
 	INIT_LIST_HEAD(&root->root_list);
+	INIT_LIST_HEAD(&root->allcg_list);
 	root->number_of_cgroups = 1;
 	cgrp->root = root;
 	cgrp->top_cgroup = cgrp;
+	list_add_tail(&cgrp->allcg_node, &root->allcg_list);
 	init_cgroup_housekeeping(cgrp);
 }
 
@@ -3794,6 +3800,8 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	/* The cgroup directory was pre-locked for us */
 	BUG_ON(!mutex_is_locked(&cgrp->dentry->d_inode->i_mutex));
 
+	list_add_tail(&cgrp->allcg_node, &root->allcg_list);
+
 	err = cgroup_populate_dir(cgrp);
 	/* If err < 0, we have a half-filled directory - oh well ;) */
 
@@ -4002,6 +4010,8 @@ again:
 	list_del_init(&cgrp->sibling);
 	cgroup_unlock_hierarchy(cgrp->root);
 
+	list_del_init(&cgrp->allcg_node);
+
 	d = dget(cgrp->dentry);
 
 	cgroup_d_remove_dir(d);
-- 
1.7.7.3
