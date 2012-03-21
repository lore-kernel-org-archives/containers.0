From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 12/12] cgroup: implement cgroup_rm_cftypes()
Date: Wed, 21 Mar 2012 15:17:45 -0700
Message-ID: <1332368265-21586-13-git-send-email-tj@kernel.org>
References: <1332368265-21586-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1332368265-21586-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Implement cgroup_rm_cftypes() which removes an array of cftypes from a
subsystem.  It can be called whether the target subsys is attached or
not.  cgroup core will remove the specified file from all existing
cgroups.

This will be used to improve sub-subsys modularity and will be helpful
for unified hierarchy.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |    1 +
 kernel/cgroup.c        |   54 +++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 45 insertions(+), 10 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index bfe5470..7e523e2 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -406,6 +406,7 @@ struct cgroup_scanner {
 };
 
 int cgroup_add_cftypes(struct cgroup_subsys *ss, const struct cftype *cfts);
+int cgroup_rm_cftypes(struct cgroup_subsys *ss, const struct cftype *cfts);
 
 int cgroup_is_removed(const struct cgroup *cgrp);
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 67daea9..e87c4c4 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2692,17 +2692,20 @@ out:
 	return error;
 }
 
-static int cgroup_add_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
-			    const struct cftype cfts[])
+static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
+			      const struct cftype cfts[], bool is_add)
 {
 	const struct cftype *cft;
 	int err, ret = 0;
 
 	for (cft = cfts; cft->name[0] != '\0'; cft++) {
-		err = cgroup_add_file(cgrp, subsys, cft);
+		if (is_add)
+			err = cgroup_add_file(cgrp, subsys, cft);
+		else
+			err = cgroup_rm_file(cgrp, cft);
 		if (err) {
-			pr_warning("cgroup_add_files: failed to create %s, err=%d\n",
-				   cft->name, err);
+			pr_warning("cgroup_addrm_files: failed to %s %s, err=%d\n",
+				   is_add ? "add" : "remove", cft->name, err);
 			ret = err;
 		}
 	}
@@ -2726,7 +2729,7 @@ static void cgroup_cfts_prepare(void)
 }
 
 static void cgroup_cfts_commit(struct cgroup_subsys *ss,
-			       const struct cftype *cfts)
+			       const struct cftype *cfts, bool is_add)
 	__releases(&cgroup_mutex) __releases(&cgroup_cft_mutex)
 {
 	LIST_HEAD(pending);
@@ -2752,7 +2755,7 @@ static void cgroup_cfts_commit(struct cgroup_subsys *ss,
 		mutex_lock(&inode->i_mutex);
 		mutex_lock(&cgroup_mutex);
 		if (!cgroup_is_removed(cgrp))
-			cgroup_add_files(cgrp, ss, cfts);
+			cgroup_addrm_files(cgrp, ss, cfts, is_add);
 		mutex_unlock(&cgroup_mutex);
 		mutex_unlock(&inode->i_mutex);
 
@@ -2788,13 +2791,44 @@ int cgroup_add_cftypes(struct cgroup_subsys *ss, const struct cftype *cfts)
 	cgroup_cfts_prepare();
 	set->cfts = cfts;
 	list_add_tail(&set->node, &ss->cftsets);
-	cgroup_cfts_commit(ss, cfts);
+	cgroup_cfts_commit(ss, cfts, true);
 
 	return 0;
 }
 EXPORT_SYMBOL_GPL(cgroup_add_cftypes);
 
 /**
+ * cgroup_rm_cftypes - remove an array of cftypes from a subsystem
+ * @ss: target cgroup subsystem
+ * @cfts: zero-length name terminated array of cftypes
+ *
+ * Unregister @cfts from @ss.  Files described by @cfts are removed from
+ * all existing cgroups to which @ss is attached and all future cgroups
+ * won't have them either.  This function can be called anytime whether @ss
+ * is attached or not.
+ *
+ * Returns 0 on successful unregistration, -ENOENT if @cfts is not
+ * registered with @ss.
+ */
+int cgroup_rm_cftypes(struct cgroup_subsys *ss, const struct cftype *cfts)
+{
+	struct cftype_set *set;
+
+	cgroup_cfts_prepare();
+
+	list_for_each_entry(set, &ss->cftsets, node) {
+		if (set->cfts == cfts) {
+			list_del_init(&set->node);
+			cgroup_cfts_commit(ss, cfts, false);
+			return 0;
+		}
+	}
+
+	cgroup_cfts_commit(ss, NULL, false);
+	return -ENOENT;
+}
+
+/**
  * cgroup_task_count - count the number of tasks in a cgroup.
  * @cgrp: the cgroup in question
  *
@@ -3786,7 +3820,7 @@ static int cgroup_populate_dir(struct cgroup *cgrp)
 	int err;
 	struct cgroup_subsys *ss;
 
-	err = cgroup_add_files(cgrp, NULL, files);
+	err = cgroup_addrm_files(cgrp, NULL, files, true);
 	if (err < 0)
 		return err;
 
@@ -3798,7 +3832,7 @@ static int cgroup_populate_dir(struct cgroup *cgrp)
 			return err;
 
 		list_for_each_entry(set, &ss->cftsets, node)
-			cgroup_add_files(cgrp, ss, set->cfts);
+			cgroup_addrm_files(cgrp, ss, set->cfts, true);
 	}
 
 	/* This cgroup is ready now */
-- 
1.7.7.3
