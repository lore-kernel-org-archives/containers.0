From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC PATCH 3/9] cgroup: use root->top_root instead of root
Date: Mon, 17 Dec 2012 14:43:29 +0800
Message-ID: <1355726615-15224-4-git-send-email-gaofeng__24455.0574956977$1355726651$gmane$org@cn.fujitsu.com>
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

After adding container support for cgroup,the subsystems
can bind to many hierarchies.the root of cgroups will be
different even these roots have same subsys_mask.

Because these roots' top_root will always be same.use
top_root instead of root.

Also link cgroup's allcg_node to top_root's allcg_list.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 27ebeaf..2e14c8f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -315,7 +315,7 @@ static int notify_on_release(const struct cgroup *cgrp)
  * an active hierarchy
  */
 #define for_each_subsys(_root, _ss) \
-list_for_each_entry(_ss, &_root->subsys_list, sibling)
+list_for_each_entry(_ss, &_root->top_root->subsys_list, sibling)
 
 /* for_each_active_root() allows you to iterate across the active hierarchies */
 #define for_each_active_root(_root) \
@@ -519,7 +519,7 @@ static bool compare_css_sets(struct css_set *cg,
 		cg1 = cgl1->cgrp;
 		cg2 = cgl2->cgrp;
 		/* Hierarchies should be linked in the same order. */
-		BUG_ON(cg1->root != cg2->root);
+		BUG_ON(cg1->root->top_root != cg2->root->top_root);
 
 		/*
 		 * If this hierarchy is the hierarchy of the cgroup
@@ -528,7 +528,7 @@ static bool compare_css_sets(struct css_set *cg,
 		 * hierarchy, then this css_set should point to the
 		 * same cgroup as the old css_set.
 		 */
-		if (cg1->root == new_cgrp->root) {
+		if (cg1->root->top_root == new_cgrp->root->top_root) {
 			if (cg1 != new_cgrp)
 				return false;
 		} else {
@@ -703,7 +703,7 @@ static struct css_set *find_css_set(
 	/* Add reference counts and links from the new css_set. */
 	list_for_each_entry(link, &oldcg->cg_links, cg_link_list) {
 		struct cgroup *c = link->cgrp;
-		if (c->root == cgrp->root)
+		if (c->root->top_root == cgrp->root->top_root)
 			c = cgrp;
 		link_css_set(&tmp_cg_links, res, c);
 	}
@@ -745,7 +745,7 @@ static struct cgroup *task_cgroup_from_root(struct task_struct *task,
 		struct cg_cgroup_link *link;
 		list_for_each_entry(link, &css->cg_links, cg_link_list) {
 			struct cgroup *c = link->cgrp;
-			if (c->root == root) {
+			if (c->root->top_root == root->top_root) {
 				res = c;
 				break;
 			}
@@ -2840,7 +2840,8 @@ static void cgroup_cfts_commit(struct cgroup_subsys *ss,
 
 	/* %NULL @cfts indicates abort and don't bother if @ss isn't attached */
 	if (cfts && ss->root != &rootnode) {
-		list_for_each_entry(cgrp, &ss->root->allcg_list, allcg_node) {
+		list_for_each_entry(cgrp, &ss->root->top_root->allcg_list,
+				    allcg_node) {
 			dget(cgrp->dentry);
 			list_add_tail(&cgrp->cft_q_node, &pending);
 		}
@@ -4207,7 +4208,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	/* allocation complete, commit to creation */
 	dentry->d_fsdata = cgrp;
 	cgrp->dentry = dentry;
-	list_add_tail(&cgrp->allcg_node, &root->allcg_list);
+	list_add_tail(&cgrp->allcg_node, &root->top_root->allcg_list);
 	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
 	root->number_of_cgroups++;
 
-- 
1.7.7.6
