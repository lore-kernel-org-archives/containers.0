From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 4/9] cgroup: move css_id commit from cgroup_populate_dir() to
	online_css()
Date: Wed, 28 Aug 2013 17:03:44 -0400
Message-ID: <1377723829-22814-5-git-send-email-tj@kernel.org>
References: <1377723829-22814-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1377723829-22814-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

css_id should be committed after a css is brought online fully.  This
is currently done form cgroup_populate_dir() but we're gonna reorder
operations such that cgroup_populate_dir() is called before css is
onlined.  Let's move css_id commit from cgroup_populate_dir() to
online_css().

This change makes it possible for cgroup creation to fail after css_id
is committed; however, as css is already fully initialized, the
cleanup isn't different from the cgroup being removed.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 53 +++++++++++++++++++++++++----------------------------
 1 file changed, 25 insertions(+), 28 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index a65be0c..6a3ad20 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4244,7 +4244,7 @@ static struct cftype cgroup_base_files[] = {
 static int cgroup_populate_dir(struct cgroup *cgrp, unsigned long subsys_mask)
 {
 	struct cgroup_subsys *ss;
-	int i, ret = 0;
+	int i, ret;
 
 	/* process cftsets of each subsystem */
 	for_each_subsys(ss, i) {
@@ -4255,29 +4255,14 @@ static int cgroup_populate_dir(struct cgroup *cgrp, unsigned long subsys_mask)
 
 		list_for_each_entry(set, &ss->cftsets, node) {
 			ret = cgroup_addrm_files(cgrp, set->cfts, true);
-			if (ret < 0)
-				goto err;
+			if (ret < 0) {
+				cgroup_clear_dir(cgrp, subsys_mask);
+				return ret;
+			}
 		}
 	}
 
-	/* This cgroup is ready now */
-	for_each_root_subsys(cgrp->root, ss) {
-		struct cgroup_subsys_state *css = cgroup_css(cgrp, ss);
-		struct css_id *id = rcu_dereference_protected(css->id, true);
-
-		/*
-		 * Update id->css pointer and make this css visible from
-		 * CSS ID functions. This pointer will be dereferened
-		 * from RCU-read-side without locks.
-		 */
-		if (id)
-			rcu_assign_pointer(id->css, css);
-	}
-
 	return 0;
-err:
-	cgroup_clear_dir(cgrp, subsys_mask);
-	return ret;
 }
 
 /*
@@ -4356,18 +4341,30 @@ static void init_css(struct cgroup_subsys_state *css, struct cgroup_subsys *ss,
 static int online_css(struct cgroup_subsys_state *css)
 {
 	struct cgroup_subsys *ss = css->ss;
-	int ret = 0;
+	struct css_id *id = rcu_dereference_protected(css->id, true);
+	int ret;
 
 	lockdep_assert_held(&cgroup_mutex);
 
-	if (ss->css_online)
+	if (ss->css_online) {
 		ret = ss->css_online(css);
-	if (!ret) {
-		css->flags |= CSS_ONLINE;
-		css->cgroup->nr_css++;
-		rcu_assign_pointer(css->cgroup->subsys[ss->subsys_id], css);
+		if (ret)
+			return ret;
 	}
-	return ret;
+
+	css->flags |= CSS_ONLINE;
+	css->cgroup->nr_css++;
+	rcu_assign_pointer(css->cgroup->subsys[ss->subsys_id], css);
+
+	/*
+	 * Update id->css pointer and make this css visible from CSS ID
+	 * functions. This pointer will be dereferened from RCU-read-side
+	 * without locks.
+	 */
+	if (id)
+		rcu_assign_pointer(id->css, css);
+
+	return 0;
 }
 
 /* if the CSS is online, invoke ->css_offline() on it and mark it offline */
@@ -5678,7 +5675,7 @@ static int alloc_css_id(struct cgroup_subsys_state *child_css)
 	child_id->stack[depth] = child_id->id;
 	/*
 	 * child_id->css pointer will be set after this cgroup is available
-	 * see cgroup_populate_dir()
+	 * see online_css()
 	 */
 	rcu_assign_pointer(child_css->id, child_id);
 
-- 
1.8.3.1
