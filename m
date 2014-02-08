From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 7/8] cgroup: rename cgroupfs_root->number_of_cgroups to
	->nr_cgrps and make it atomic_t
Date: Sat,  8 Feb 2014 11:38:28 -0500
Message-ID: <1391877509-10855-8-git-send-email-tj@kernel.org>
References: <1391877509-10855-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391877509-10855-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

root->number_of_cgroups is currently an integer protected with
cgroup_mutex.  Except for sanity checks and proc reporting, the only
place it's used is to check whether the root has any child during
remount; however, this is a bit flawed as the counter is not
decremented when the cgroup is unlinked but when it's released,
meaning that there could be an extended period where all cgroups are
removed but remount is still not allowed because some internal objects
are lingering.  While not perfect either, it'd be better to use
emptiness test on root->top_cgroup.children.

This patch updates cgroup_remount() to test top_cgroup's children
instead, which makes number_of_cgroups only actual usage statistics
printing in proc implemented in proc_cgroupstats_show().  Let's
shorten its name and make it an atomic_t so that we don't have to
worry about its synchronization.  It's purely auxiliary at this point.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  4 ++--
 kernel/cgroup.c        | 16 +++++++---------
 2 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8202abb..b14abaf 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -288,8 +288,8 @@ struct cgroupfs_root {
 	/* The root cgroup for this hierarchy */
 	struct cgroup top_cgroup;
 
-	/* Tracks how many cgroups are currently defined in hierarchy.*/
-	int number_of_cgroups;
+	/* Number of cgroups in the hierarchy, used only for /proc/cgroups */
+	atomic_t nr_cgrps;
 
 	/* A list running through the active hierarchies */
 	struct list_head root_list;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a48f4ca..13a8d2a 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -758,7 +758,7 @@ static void cgroup_put_root(struct cgroupfs_root *root)
 	}
 	mutex_lock(&cgroup_mutex);
 
-	BUG_ON(root->number_of_cgroups != 1);
+	BUG_ON(atomic_read(&root->nr_cgrps) != 1);
 	BUG_ON(!list_empty(&cgrp->children));
 
 	/* Rebind all subsystems back to the default hierarchy */
@@ -928,9 +928,7 @@ static void cgroup_free_fn(struct work_struct *work)
 {
 	struct cgroup *cgrp = container_of(work, struct cgroup, destroy_work);
 
-	mutex_lock(&cgroup_mutex);
-	cgrp->root->number_of_cgroups--;
-	mutex_unlock(&cgroup_mutex);
+	atomic_dec(&cgrp->root->nr_cgrps);
 
 	/*
 	 * We get a ref to the parent, and put the ref when this cgroup is
@@ -1318,7 +1316,7 @@ static int cgroup_remount(struct kernfs_root *kf_root, int *flags, char *data)
 	}
 
 	/* remounting is not allowed for populated hierarchies */
-	if (root->number_of_cgroups > 1) {
+	if (!list_empty(&root->top_cgroup.children)) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
@@ -1358,7 +1356,7 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 
 	atomic_set(&root->refcnt, 1);
 	INIT_LIST_HEAD(&root->root_list);
-	root->number_of_cgroups = 1;
+	atomic_set(&root->nr_cgrps, 1);
 	cgrp->root = root;
 	init_cgroup_housekeeping(cgrp);
 	idr_init(&root->cgroup_idr);
@@ -1461,7 +1459,7 @@ static int cgroup_setup_root(struct cgroupfs_root *root)
 	write_unlock(&css_set_lock);
 
 	BUG_ON(!list_empty(&root_cgrp->children));
-	BUG_ON(root->number_of_cgroups != 1);
+	BUG_ON(atomic_read(&root->nr_cgrps) != 1);
 
 	kernfs_activate(root_cgrp->kn);
 	ret = 0;
@@ -3707,7 +3705,7 @@ static long cgroup_create(struct cgroup *parent, const char *name,
 
 	/* allocation complete, commit to creation */
 	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
-	root->number_of_cgroups++;
+	atomic_inc(&root->nr_cgrps);
 
 	/*
 	 * Grab a reference on the root and parent so that they don't get
@@ -4279,7 +4277,7 @@ static int proc_cgroupstats_show(struct seq_file *m, void *v)
 	for_each_subsys(ss, i)
 		seq_printf(m, "%s\t%d\t%d\t%d\n",
 			   ss->name, ss->root->hierarchy_id,
-			   ss->root->number_of_cgroups, !ss->disabled);
+			   atomic_read(&ss->root->nr_cgrps), !ss->disabled);
 
 	mutex_unlock(&cgroup_mutex);
 	return 0;
-- 
1.8.5.3
