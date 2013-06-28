From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/9] cgroup: fix error path of cgroup_addrm_files()
Date: Fri, 28 Jun 2013 16:45:38 -0700
Message-ID: <1372463145-4245-3-git-send-email-tj__31630.573111079$1372463178$gmane$org@kernel.org>
References: <1372463145-4245-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1372463145-4245-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_addrm_files() mishandled error return value from
cgroup_add_file() and returns error iff the last file fails to create.
As we're in the process of cleaning up file add/rm error handling and
will reliably propagate file creation failures, there's no point in
keeping adding files after a failure.

Replace the broken error collection logic with immediate error return.
While at it, add lockdep assertions and function comment.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 28 ++++++++++++++++++++++------
 1 file changed, 22 insertions(+), 6 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 64877de..3df8e92 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2780,11 +2780,26 @@ out:
 	return error;
 }
 
+/**
+ * cgroup_addrm_files - add or remove files to a cgroup directory
+ * @cgrp: the target cgroup
+ * @subsys: the subsystem of files to be added
+ * @cfts: array of cftypes to be added
+ * @is_add: whether to add or remove
+ *
+ * Depending on @is_add, add or remove files defined by @cfts on @cgrp.
+ * All @cfts should belong to @subsys.  For removals, this function never
+ * fails.  If addition fails, this function doesn't remove files already
+ * added.  The caller is responsible for cleaning up.
+ */
 static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 			      struct cftype cfts[], bool is_add)
 {
 	struct cftype *cft;
-	int err, ret = 0;
+	int ret;
+
+	lockdep_assert_held(&cgrp->dentry->d_inode->i_mutex);
+	lockdep_assert_held(&cgroup_mutex);
 
 	for (cft = cfts; cft->name[0] != '\0'; cft++) {
 		/* does cft->flags tell us to skip this file on @cgrp? */
@@ -2796,16 +2811,17 @@ static int cgroup_addrm_files(struct cgroup *cgrp, struct cgroup_subsys *subsys,
 			continue;
 
 		if (is_add) {
-			err = cgroup_add_file(cgrp, subsys, cft);
-			if (err)
+			ret = cgroup_add_file(cgrp, subsys, cft);
+			if (ret) {
 				pr_warn("cgroup_addrm_files: failed to add %s, err=%d\n",
-					cft->name, err);
-			ret = err;
+					cft->name, ret);
+				return ret;
+			}
 		} else {
 			cgroup_rm_file(cgrp, cft);
 		}
 	}
-	return ret;
+	return 0;
 }
 
 static void cgroup_cfts_prepare(void)
-- 
1.8.3.1
