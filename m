From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/4] cgroup: make hierarchy_id use cyclic idr
Date: Sun, 14 Apr 2013 11:36:58 -0700
Message-ID: <1365964619-14762-4-git-send-email-tj@kernel.org>
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

We want to be able to lookup a hierarchy from its id and cyclic
allocation is a whole lot simpler with idr.  Convert to idr and use
idr_alloc_cyclc().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 28 ++++++++--------------------
 1 file changed, 8 insertions(+), 20 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index e15bdb7..75d85e8 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -242,8 +242,7 @@ static int root_count;
  * rules as other root ops - both cgroup_mutex and cgroup_root_mutex for
  * writes, either for reads.
  */
-static DEFINE_IDA(hierarchy_ida);
-static int next_hierarchy_id;
+static DEFINE_IDR(cgroup_hierarchy_idr);
 
 /* dummytop is a shorthand for the dummy hierarchy's top cgroup */
 #define dummytop (&rootnode.top_cgroup)
@@ -1458,27 +1457,16 @@ static void init_cgroup_root(struct cgroupfs_root *root)
 
 static int cgroup_init_root_id(struct cgroupfs_root *root)
 {
-	int ret;
+	int id;
 
 	lockdep_assert_held(&cgroup_mutex);
 	lockdep_assert_held(&cgroup_root_mutex);
 
-	do {
-		if (!ida_pre_get(&hierarchy_ida, GFP_KERNEL))
-			return -ENOMEM;
-		/* Try to allocate the next unused ID */
-		ret = ida_get_new_above(&hierarchy_ida, next_hierarchy_id,
-					&root->hierarchy_id);
-		if (ret == -ENOSPC)
-			/* Try again starting from 0 */
-			ret = ida_get_new(&hierarchy_ida, &root->hierarchy_id);
-		if (!ret) {
-			next_hierarchy_id = root->hierarchy_id + 1;
-		} else if (ret != -EAGAIN) {
-			/* Can only get here if the 31-bit IDR is full ... */
-			BUG_ON(ret);
-		}
-	} while (ret);
+	id = idr_alloc_cyclic(&cgroup_hierarchy_idr, root, 2, 0, GFP_KERNEL);
+	if (id < 0)
+		return id;
+
+	root->hierarchy_id = id;
 	return 0;
 }
 
@@ -1488,7 +1476,7 @@ static void cgroup_exit_root_id(struct cgroupfs_root *root)
 	lockdep_assert_held(&cgroup_root_mutex);
 
 	if (root->hierarchy_id) {
-		ida_remove(&hierarchy_ida, root->hierarchy_id);
+		idr_remove(&cgroup_hierarchy_idr, root->hierarchy_id);
 		root->hierarchy_id = 0;
 	}
 }
-- 
1.8.1.4
