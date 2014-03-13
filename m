From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 05/11] cgroup: remove NULL checks from
	[pr_cont_]cgroup_{name|path}()
Date: Thu, 13 Mar 2014 15:50:07 -0400
Message-ID: <1394740213-17626-6-git-send-email-tj__48864.4858276986$1394740293$gmane$org@kernel.org>
References: <1394740213-17626-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1394740213-17626-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

The dummy hierarchy is now a fully functional one and dummy_top has a
kernfs_node associated with it.  Drop the NULL checks in
[pr_cont_]cont_{name|path}() which are no longer necessary.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h | 24 ++++--------------------
 1 file changed, 4 insertions(+), 20 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index acbb9a4..9f4f253 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -508,39 +508,23 @@ struct cgroup_subsys_state *seq_css(struct seq_file *seq);
 
 static inline int cgroup_name(struct cgroup *cgrp, char *buf, size_t buflen)
 {
-	/* dummy_top doesn't have a kn associated */
-	if (cgrp->kn)
-		return kernfs_name(cgrp->kn, buf, buflen);
-	else
-		return strlcpy(buf, "/", buflen);
+	return kernfs_name(cgrp->kn, buf, buflen);
 }
 
 static inline char * __must_check cgroup_path(struct cgroup *cgrp, char *buf,
 					      size_t buflen)
 {
-	/* dummy_top doesn't have a kn associated */
-	if (cgrp->kn)
-		return kernfs_path(cgrp->kn, buf, buflen);
-	strlcpy(buf, "/", buflen);
-	return (buflen <= 2) ? NULL : buf;
+	return kernfs_path(cgrp->kn, buf, buflen);
 }
 
 static inline void pr_cont_cgroup_name(struct cgroup *cgrp)
 {
-	/* dummy_top doesn't have a kn associated */
-	if (cgrp->kn)
-		pr_cont_kernfs_name(cgrp->kn);
-	else
-		pr_cont("/");
+	pr_cont_kernfs_name(cgrp->kn);
 }
 
 static inline void pr_cont_cgroup_path(struct cgroup *cgrp)
 {
-	/* dummy_top doesn't have a kn associated */
-	if (cgrp->kn)
-		pr_cont_kernfs_path(cgrp->kn);
-	else
-		pr_cont("/");
+	pr_cont_kernfs_path(cgrp->kn);
 }
 
 char *task_cgroup_path(struct task_struct *task, char *buf, size_t buflen);
-- 
1.8.5.3
