From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH UPDATED 15/24] cfq-iosched: enable full blkcg hierarchy support
Date: Mon, 7 Jan 2013 08:34:05 -0800
Message-ID: <20130107163405.GE3926@htj.dyndns.org>
References: <1356726946-26037-1-git-send-email-tj@kernel.org>
	<1356726946-26037-16-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1356726946-26037-16-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

With the previous two patches, all cfqg scheduling decisions are based
on vfraction and ready for hierarchy support.  The only thing which
keeps the behavior flat is cfqg_flat_parent() which makes vfraction
calculation consider all non-root cfqgs children of the root cfqg.

Replace it with cfqg_parent() which returns the real parent.  This
enables full blkcg hierarchy support for cfq-iosched.  For example,
consider the following hierarchy.

        root
      /      \
   A:500      B:250
  /     \
 AA:500  AB:1000

For simplicity, let's say all the leaf nodes have active tasks and are
on service tree.  For each leaf node, vfraction would be

 AA: (500  / 1500) * (500 / 750) =~ 0.2222
 AB: (1000 / 1500) * (500 / 750) =~ 0.4444
  B:                 (250 / 750) =~ 0.3333

and vdisktime will be distributed accordingly.  For more detail,
please refer to Documentation/block/cfq-iosched.txt.

v2: cfq-iosched.txt updated to describe group scheduling as suggested
    by Vivek.

v3: blkio-controller.txt updated.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
blkio-controller.txt updated as per Vivek.

Thanks.

 Documentation/block/cfq-iosched.txt        |   58 +++++++++++++++++++++++++++++
 Documentation/cgroups/blkio-controller.txt |   37 ++++++++++++------
 block/cfq-iosched.c                        |   21 +++-------
 3 files changed, 89 insertions(+), 27 deletions(-)

--- a/Documentation/block/cfq-iosched.txt
+++ b/Documentation/block/cfq-iosched.txt
@@ -102,6 +102,64 @@ processing of request. Therefore, increa
 performace although this can cause the latency of some I/O to increase due
 to more number of requests.
 
+CFQ Group scheduling
+====================
+
+CFQ supports blkio cgroup and has "blkio." prefixed files in each
+blkio cgroup directory. It is weight-based and there are four knobs
+for configuration - weight[_device] and leaf_weight[_device].
+Internal cgroup nodes (the ones with children) can also have tasks in
+them, so the former two configure how much proportion the cgroup as a
+whole is entitled to at its parent's level while the latter two
+configure how much proportion the tasks in the cgroup have compared to
+its direct children.
+
+Another way to think about it is assuming that each internal node has
+an implicit leaf child node which hosts all the tasks whose weight is
+configured by leaf_weight[_device]. Let's assume a blkio hierarchy
+composed of five cgroups - root, A, B, AA and AB - with the following
+weights where the names represent the hierarchy.
+
+        weight leaf_weight
+ root :  125    125
+ A    :  500    750
+ B    :  250    500
+ AA   :  500    500
+ AB   : 1000    500
+
+root never has a parent making its weight is meaningless. For backward
+compatibility, weight is always kept in sync with leaf_weight. B, AA
+and AB have no child and thus its tasks have no children cgroup to
+compete with. They always get 100% of what the cgroup won at the
+parent level. Considering only the weights which matter, the hierarchy
+looks like the following.
+
+          root
+       /    |   \
+      A     B    leaf
+     500   250   125
+   /  |  \
+  AA  AB  leaf
+ 500 1000 750
+
+If all cgroups have active IOs and competing with each other, disk
+time will be distributed like the following.
+
+Distribution below root. The total active weight at this level is
+A:500 + B:250 + C:125 = 875.
+
+ root-leaf :   125 /  875      =~ 14%
+ A         :   500 /  875      =~ 57%
+ B(-leaf)  :   250 /  875      =~ 28%
+
+A has children and further distributes its 57% among the children and
+the implicit leaf node. The total active weight at this level is
+AA:500 + AB:1000 + A-leaf:750 = 2250.
+
+ A-leaf    : ( 750 / 2250) * A =~ 19%
+ AA(-leaf) : ( 500 / 2250) * A =~ 12%
+ AB(-leaf) : (1000 / 2250) * A =~ 25%
+
 CFQ IOPS Mode for group scheduling
 ===================================
 Basic CFQ design is to provide priority based time slices. Higher priority
--- a/Documentation/cgroups/blkio-controller.txt
+++ b/Documentation/cgroups/blkio-controller.txt
@@ -94,13 +94,11 @@ Throttling/Upper Limit policy
 
 Hierarchical Cgroups
 ====================
-- Currently none of the IO control policy supports hierarchical groups. But
-  cgroup interface does allow creation of hierarchical cgroups and internally
-  IO policies treat them as flat hierarchy.
-
-  So this patch will allow creation of cgroup hierarchcy but at the backend
-  everything will be treated as flat. So if somebody created a hierarchy like
-  as follows.
+- Currently only CFQ supports hierarchical groups. For throttling,
+  cgroup interface does allow creation of hierarchical cgroups and
+  internally it treats them as flat hierarchy.
+
+  If somebody created a hierarchy like as follows.
 
 			root
 			/  \
@@ -108,16 +106,20 @@ Hierarchical Cgroups
 			|
 		     test3
 
-  CFQ and throttling will practically treat all groups at same level.
+  CFQ will handle the hierarchy correctly but and throttling will
+  practically treat all groups at same level. For details on CFQ
+  hierarchy support, refer to Documentation/block/cfq-iosched.txt.
+  Throttling will treat the hierarchy as if it looks like the
+  following.
 
 				pivot
 			     /  /   \  \
 			root  test1 test2  test3
 
-  Down the line we can implement hierarchical accounting/control support
-  and also introduce a new cgroup file "use_hierarchy" which will control
-  whether cgroup hierarchy is viewed as flat or hierarchical by the policy..
-  This is how memory controller also has implemented the things.
+  Nesting cgroups, while allowed, isn't officially supported and blkio
+  genereates warning when cgroups nest. Once throttling implements
+  hierarchy support, hierarchy will be supported and the warning will
+  be removed.
 
 Various user visible config options
 ===================================
@@ -172,6 +174,12 @@ Proportional weight policy files
 	  dev     weight
 	  8:16    300
 
+- blkio.leaf_weight[_device]
+	- Equivalents of blkio.weight[_device] for the purpose of
+          deciding how much weight tasks in the given cgroup has while
+          competing with the cgroup's child cgroups. For details,
+          please refer to Documentation/block/cfq-iosched.txt.
+
 - blkio.time
 	- disk time allocated to cgroup per device in milliseconds. First
 	  two fields specify the major and minor number of the device and
@@ -279,6 +287,11 @@ Proportional weight policy files
 	  and minor number of the device and third field specifies the number
 	  of times a group was dequeued from a particular device.
 
+- blkio.*_recursive
+	- Recursive version of various stats. These files show the
+          same information as their non-recursive counterparts but
+          include stats from all the descendant cgroups.
+
 Throttling/Upper limit policy files
 -----------------------------------
 - blkio.throttle.read_bps_device
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -606,20 +606,11 @@ static inline struct cfq_group *blkg_to_
 	return pd_to_cfqg(blkg_to_pd(blkg, &blkcg_policy_cfq));
 }
 
-/*
- * Determine the parent cfqg for weight calculation.  Currently, cfqg
- * scheduling is flat and the root is the parent of everyone else.
- */
-static inline struct cfq_group *cfqg_flat_parent(struct cfq_group *cfqg)
+static inline struct cfq_group *cfqg_parent(struct cfq_group *cfqg)
 {
-	struct blkcg_gq *blkg = cfqg_to_blkg(cfqg);
-	struct cfq_group *root;
-
-	while (blkg->parent)
-		blkg = blkg->parent;
-	root = blkg_to_cfqg(blkg);
+	struct blkcg_gq *pblkg = cfqg_to_blkg(cfqg)->parent;
 
-	return root != cfqg ? root : NULL;
+	return pblkg ? blkg_to_cfqg(pblkg) : NULL;
 }
 
 static inline void cfqg_get(struct cfq_group *cfqg)
@@ -722,7 +713,7 @@ static void cfq_pd_reset_stats(struct bl
 
 #else	/* CONFIG_CFQ_GROUP_IOSCHED */
 
-static inline struct cfq_group *cfqg_flat_parent(struct cfq_group *cfqg) { return NULL; }
+static inline struct cfq_group *cfqg_parent(struct cfq_group *cfqg) { return NULL; }
 static inline void cfqg_get(struct cfq_group *cfqg) { }
 static inline void cfqg_put(struct cfq_group *cfqg) { }
 
@@ -1290,7 +1281,7 @@ cfq_group_service_tree_add(struct cfq_rb
 	 * stops once an already activated node is met.  vfraction
 	 * calculation should always continue to the root.
 	 */
-	while ((parent = cfqg_flat_parent(pos))) {
+	while ((parent = cfqg_parent(pos))) {
 		if (propagate) {
 			propagate = !parent->nr_active++;
 			parent->children_weight += pos->weight;
@@ -1341,7 +1332,7 @@ cfq_group_service_tree_del(struct cfq_rb
 	pos->children_weight -= pos->leaf_weight;
 
 	while (propagate) {
-		struct cfq_group *parent = cfqg_flat_parent(pos);
+		struct cfq_group *parent = cfqg_parent(pos);
 
 		/* @pos has 0 nr_active at this point */
 		WARN_ON_ONCE(pos->children_weight);
