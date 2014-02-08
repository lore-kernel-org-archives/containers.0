From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 07/13] cgroup: make cgroup_subsys->base_cftypes use
	cgroup_add_cftypes()
Date: Sat,  8 Feb 2014 11:15:21 -0500
Message-ID: <1391876127-7134-8-git-send-email-tj__46828.3777860508$1391876206$gmane$org@kernel.org>
References: <1391876127-7134-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1391876127-7134-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Currently, cgroup_subsys->base_cftypes registration is different from
dynamic cftypes registartion.  Instead of going through
cgroup_add_cftypes(), cgroup_init_subsys() invokes
cgroup_init_cftsets() which makes use of cgroup_subsys->base_cftset
which doesn't involve dynamic allocation.

While avoiding dynamic allocation is somewhat nice, having two
separate paths for cftypes registration is nasty, especially as we're
planning to add more operations during cftypes registration.

This patch drops cgroup_init_cftsets() and cgroup_subsys->base_cftset
and registers base_cftypes using cgroup_add_cftypes().  This is done
as a separate step in cgroup_init() instead of a part of
cgroup_init_subsys().  This is because cgroup_init_subsys() can be
called very early during boot when kmalloc() isn't available yet.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  3 +--
 kernel/cgroup.c        | 29 ++++++++---------------------
 2 files changed, 9 insertions(+), 23 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 2255639..884d367 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -602,9 +602,8 @@ struct cgroup_subsys {
 	/* list of cftype_sets */
 	struct list_head cftsets;
 
-	/* base cftypes, automatically [de]registered with subsys itself */
+	/* base cftypes, automatically registered with subsys itself */
 	struct cftype *base_cftypes;
-	struct cftype_set base_cftset;
 };
 
 #define SUBSYS(_x) extern struct cgroup_subsys _x ## _cgrp_subsys;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3cef4a3..5935c2f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4501,25 +4501,6 @@ static int cgroup_rmdir(struct inode *unused_dir, struct dentry *dentry)
 	return ret;
 }
 
-static void __init cgroup_init_cftsets(struct cgroup_subsys *ss)
-{
-	INIT_LIST_HEAD(&ss->cftsets);
-
-	/*
-	 * base_cftset is embedded in subsys itself, no need to worry about
-	 * deregistration.
-	 */
-	if (ss->base_cftypes) {
-		struct cftype *cft;
-
-		for (cft = ss->base_cftypes; cft->name[0] != '\0'; cft++)
-			cft->ss = ss;
-
-		ss->base_cftset.cfts = ss->base_cftypes;
-		list_add_tail(&ss->base_cftset.node, &ss->cftsets);
-	}
-}
-
 static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 {
 	struct cgroup_subsys_state *css;
@@ -4529,8 +4510,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
 	mutex_lock(&cgroup_tree_mutex);
 	mutex_lock(&cgroup_mutex);
 
-	/* init base cftset */
-	cgroup_init_cftsets(ss);
+	INIT_LIST_HEAD(&ss->cftsets);
 
 	/* Create the top cgroup state for this subsystem */
 	ss->root = &cgroup_dummy_root;
@@ -4619,6 +4599,13 @@ int __init cgroup_init(void)
 	for_each_subsys(ss, i) {
 		if (!ss->early_init)
 			cgroup_init_subsys(ss);
+
+		/*
+		 * cftype registration needs kmalloc and can't be done
+		 * during early_init.  Register base cftypes separately.
+		 */
+		if (ss->base_cftypes)
+			WARN_ON(cgroup_add_cftypes(ss, ss->base_cftypes));
 	}
 
 	/* allocate id for the dummy hierarchy */
-- 
1.8.5.3
