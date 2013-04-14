From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/4] cgroup: drop hierarchy_id_lock
Date: Sun, 14 Apr 2013 11:36:57 -0700
Message-ID: <1365964619-14762-3-git-send-email-tj@kernel.org>
References: <1365964619-14762-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1365964619-14762-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay-tD+1rO4QERM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Now that hierarchy_id alloc / free are protected by the cgroup
mutexes, there's no need for this separate lock.  Drop it.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 823cb56..e15bdb7 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -237,9 +237,13 @@ struct cgroup_event {
 static LIST_HEAD(roots);
 static int root_count;
 
+/*
+ * Hierarchy ID allocation and mapping.  It follows the same exclusion
+ * rules as other root ops - both cgroup_mutex and cgroup_root_mutex for
+ * writes, either for reads.
+ */
 static DEFINE_IDA(hierarchy_ida);
 static int next_hierarchy_id;
-static DEFINE_SPINLOCK(hierarchy_id_lock);
 
 /* dummytop is a shorthand for the dummy hierarchy's top cgroup */
 #define dummytop (&rootnode.top_cgroup)
@@ -1456,10 +1460,12 @@ static int cgroup_init_root_id(struct cgroupfs_root *root)
 {
 	int ret;
 
+	lockdep_assert_held(&cgroup_mutex);
+	lockdep_assert_held(&cgroup_root_mutex);
+
 	do {
 		if (!ida_pre_get(&hierarchy_ida, GFP_KERNEL))
 			return -ENOMEM;
-		spin_lock(&hierarchy_id_lock);
 		/* Try to allocate the next unused ID */
 		ret = ida_get_new_above(&hierarchy_ida, next_hierarchy_id,
 					&root->hierarchy_id);
@@ -1472,18 +1478,17 @@ static int cgroup_init_root_id(struct cgroupfs_root *root)
 			/* Can only get here if the 31-bit IDR is full ... */
 			BUG_ON(ret);
 		}
-		spin_unlock(&hierarchy_id_lock);
 	} while (ret);
 	return 0;
 }
 
 static void cgroup_exit_root_id(struct cgroupfs_root *root)
 {
+	lockdep_assert_held(&cgroup_mutex);
+	lockdep_assert_held(&cgroup_root_mutex);
+
 	if (root->hierarchy_id) {
-		spin_lock(&hierarchy_id_lock);
 		ida_remove(&hierarchy_ida, root->hierarchy_id);
-		spin_unlock(&hierarchy_id_lock);
-
 		root->hierarchy_id = 0;
 	}
 }
@@ -4656,8 +4661,14 @@ int __init cgroup_init(void)
 	hash_add(css_set_table, &init_css_set.hlist, key);
 
 	/* allocate id for the dummy hierarchy */
+	mutex_lock(&cgroup_mutex);
+	mutex_lock(&cgroup_root_mutex);
+
 	BUG_ON(cgroup_init_root_id(&rootnode));
 
+	mutex_unlock(&cgroup_root_mutex);
+	mutex_unlock(&cgroup_mutex);
+
 	cgroup_kobj = kobject_create_and_add("cgroup", fs_kobj);
 	if (!cgroup_kobj) {
 		err = -ENOMEM;
-- 
1.8.1.4
