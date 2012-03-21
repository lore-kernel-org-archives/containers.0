From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 09/12] cgroup: remove cgroup_add_file[s]()
Date: Wed, 21 Mar 2012 15:17:42 -0700
Message-ID: <1332368265-21586-10-git-send-email-tj@kernel.org>
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

No controller is using cgroup_add_files[s]().  Unexport them, and
convert cgroup_add_files() to handle NULL entry terminated array
instead of taking count explicitly and continue creation on failure
for internal use.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |   16 ---------------
 kernel/cgroup.c        |   51 ++++++++++++++++++-----------------------------
 2 files changed, 20 insertions(+), 47 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index ff5b764..45869d7 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -404,22 +404,6 @@ struct cgroup_scanner {
 	void *data;
 };
 
-/*
- * Add a new file to the given cgroup directory. Should only be
- * called by subsystems from within a populate() method
- */
-int cgroup_add_file(struct cgroup *cgrp, struct cgroup_subsys *subsys,
-		       const struct cftype *cft);
-
-/*
- * Add a set of new files to the given cgroup directory. Should
- * only be called by subsystems from within a populate() method
- */
-int cgroup_add_files(struct cgroup *cgrp,
-			struct cgroup_subsys *subsys,
-			const struct cftype cft[],
-			int count);
-
 int cgroup_add_cftypes(struct cgroup_subsys *ss, const struct cftype *cfts);
 
 int cgroup_is_removed(const struct cgroup *cgrp);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d6fe34a..02e131e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2619,9 +2619,8 @@ static umode_t cgroup_file_mode(const struct cftype *cft)
 	return mode;
 }
 
-int cgroup_add_file(struct cgroup *cgrp,
-		       struct cgroup_subsys *subsys,
-		       const struct cftype *cft)
+static int cgroup_add_file(struct cgroup *cgrp, struct cgroup_subsys *subsys,
+			   const struct cftype *cft)
 {
 	struct dentry *dir = cgrp->dentry;
 	struct dentry *dentry;
@@ -2653,22 +2652,23 @@ int cgroup_add_file(struct cgroup *cgrp,
 		error = PTR_ERR(dentry);
 	return error;
 }
-EXPORT_SYMBOL_GPL(cgroup_add_file);
 
-int cgroup_add_files(struct cgroup *cgrp,
-			struct cgroup_subsys *subsys,
-			const struct cftype cft[],
-			int count)
+static int cgroup_add_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
+			    const struct cftype cfts[])
 {
-	int i, err;
-	for (i = 0; i < count; i++) {
-		err = cgroup_add_file(cgrp, subsys, &cft[i]);
-		if (err)
-			return err;
+	const struct cftype *cft;
+	int err, ret = 0;
+
+	for (cft = cfts; cft->name[0] != '\0'; cft++) {
+		err = cgroup_add_file(cgrp, subsys, cft);
+		if (err) {
+			pr_warning("cgroup_add_files: failed to create %s, err=%d\n",
+				   cft->name, err);
+			ret = err;
+		}
 	}
-	return 0;
+	return ret;
 }
-EXPORT_SYMBOL_GPL(cgroup_add_files);
 
 static DEFINE_MUTEX(cgroup_cft_mutex);
 
@@ -2692,10 +2692,6 @@ static void cgroup_cfts_commit(struct cgroup_subsys *ss,
 {
 	LIST_HEAD(pending);
 	struct cgroup *cgrp, *n;
-	int count = 0;
-
-	while (cfts[count].name[0] != '\0')
-		count++;
 
 	/* %NULL @cfts indicates abort and don't bother if @ss isn't attached */
 	if (cfts && ss->root != &rootnode) {
@@ -2717,7 +2713,7 @@ static void cgroup_cfts_commit(struct cgroup_subsys *ss,
 		mutex_lock(&inode->i_mutex);
 		mutex_lock(&cgroup_mutex);
 		if (!cgroup_is_removed(cgrp))
-			cgroup_add_files(cgrp, ss, cfts, count);
+			cgroup_add_files(cgrp, ss, cfts);
 		mutex_unlock(&cgroup_mutex);
 		mutex_unlock(&inode->i_mutex);
 
@@ -3743,6 +3739,7 @@ static struct cftype files[] = {
 		.write_string = cgroup_release_agent_write,
 		.max_write_len = PATH_MAX,
 	},
+	{ }	/* terminate */
 };
 
 static int cgroup_populate_dir(struct cgroup *cgrp)
@@ -3750,7 +3747,7 @@ static int cgroup_populate_dir(struct cgroup *cgrp)
 	int err;
 	struct cgroup_subsys *ss;
 
-	err = cgroup_add_files(cgrp, NULL, files, ARRAY_SIZE(files));
+	err = cgroup_add_files(cgrp, NULL, files);
 	if (err < 0)
 		return err;
 
@@ -3761,16 +3758,8 @@ static int cgroup_populate_dir(struct cgroup *cgrp)
 		if (ss->populate && (err = ss->populate(ss, cgrp)) < 0)
 			return err;
 
-		list_for_each_entry(set, &ss->cftsets, node) {
-			const struct cftype *cft;
-
-			for (cft = set->cfts; cft->name[0] != '\0'; cft++) {
-				err = cgroup_add_file(cgrp, ss, cft);
-				if (err)
-					pr_warning("cgroup_populate_dir: failed to create %s, err=%d\n",
-						   cft->name, err);
-			}
-		}
+		list_for_each_entry(set, &ss->cftsets, node)
+			cgroup_add_files(cgrp, ss, set->cfts);
 	}
 
 	/* This cgroup is ready now */
-- 
1.7.7.3
