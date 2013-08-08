From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/14] cgroup: add __rcu modifier to cgroup->subsys[]
Date: Thu,  8 Aug 2013 16:13:43 -0400
Message-ID: <1375992831-4650-7-git-send-email-tj@kernel.org>
References: <1375992831-4650-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375992831-4650-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

For the planned unified hierarchy, each css (cgroup_subsys_state) will
be RCU protected so that it can be created and destroyed individually
while allowing RCU accesses.  Previous changes ensured that all
cgroup->subsys[] accesses use the cgroup_css() accessor.  This patch
adds __rcu modifier to cgroup->subsys[], add matching RCU dereference
in cgroup_css() and convert all assignments to either
rcu_assign_pointer() or RCU_INIT_POINTER().

This change prepares for the actual RCUfication of css's and doesn't
introduce any visible behavior change.  The conversion is verified
with sparse and all accesses are properly RCU annotated.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  2 +-
 kernel/cgroup.c        | 19 ++++++++++++++-----
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 8a5dc91..eb200b5 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -204,7 +204,7 @@ struct cgroup {
 	struct cgroup_name __rcu *name;
 
 	/* Private pointers for each registered subsystem */
-	struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];
+	struct cgroup_subsys_state __rcu *subsys[CGROUP_SUBSYS_COUNT];
 
 	struct cgroupfs_root *root;
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d63beff..c271016 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -229,11 +229,16 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cftype cfts[],
  * @subsys_id: the subsystem of interest
  *
  * Return @cgrp's css (cgroup_subsys_state) associated with @subsys_id.
+ * This function must be called either under cgroup_mutex or
+ * rcu_read_lock() and the caller is responsible for pinning the returned
+ * css if it wants to keep accessing it outside the said locks.  This
+ * function may return %NULL if @cgrp doesn't have @subsys_id enabled.
  */
 static struct cgroup_subsys_state *cgroup_css(struct cgroup *cgrp,
 					      int subsys_id)
 {
-	return cgrp->subsys[subsys_id];
+	return rcu_dereference_check(cgrp->subsys[subsys_id],
+				     lockdep_is_held(&cgroup_mutex));
 }
 
 /* convenient tests for these bits */
@@ -1072,8 +1077,10 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 			BUG_ON(!cgroup_css(cgroup_dummy_top, i));
 			BUG_ON(cgroup_css(cgroup_dummy_top, i)->cgroup != cgroup_dummy_top);
 
-			cgrp->subsys[i] = cgroup_dummy_top->subsys[i];
+			rcu_assign_pointer(cgrp->subsys[i],
+					   cgroup_css(cgroup_dummy_top, i));
 			cgroup_css(cgrp, i)->cgroup = cgrp;
+
 			list_move(&ss->sibling, &root->subsys_list);
 			ss->root = root;
 			if (ss->bind)
@@ -1088,8 +1095,10 @@ static int rebind_subsystems(struct cgroupfs_root *root,
 
 			if (ss->bind)
 				ss->bind(cgroup_css(cgroup_dummy_top, i));
+
 			cgroup_css(cgroup_dummy_top, i)->cgroup = cgroup_dummy_top;
-			cgrp->subsys[i] = NULL;
+			RCU_INIT_POINTER(cgrp->subsys[i], NULL);
+
 			cgroup_subsys[i]->root = &cgroup_dummy_root;
 			list_move(&ss->sibling, &cgroup_dummy_root.subsys_list);
 
@@ -4314,7 +4323,7 @@ static void init_cgroup_css(struct cgroup_subsys_state *css,
 		css->flags |= CSS_ROOT;
 
 	BUG_ON(cgroup_css(cgrp, ss->subsys_id));
-	cgrp->subsys[ss->subsys_id] = css;
+	rcu_assign_pointer(cgrp->subsys[ss->subsys_id], css);
 }
 
 /* invoke ->css_online() on a new CSS and mark it online if successful */
@@ -4962,7 +4971,7 @@ void cgroup_unload_subsys(struct cgroup_subsys *ss)
 	 * also takes care of freeing the css_id.
 	 */
 	ss->css_free(cgroup_css(cgroup_dummy_top, ss->subsys_id));
-	cgroup_dummy_top->subsys[ss->subsys_id] = NULL;
+	RCU_INIT_POINTER(cgroup_dummy_top->subsys[ss->subsys_id], NULL);
 
 	mutex_unlock(&cgroup_mutex);
 }
-- 
1.8.3.1
