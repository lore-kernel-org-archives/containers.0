From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC PATCH 4/9] introduce helper function cgroup_in_root
Date: Mon, 17 Dec 2012 14:43:30 +0800
Message-ID: <1355726615-15224-5-git-send-email-gaofeng__18562.8534797162$1355726670$gmane$org@cn.fujitsu.com>
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

After adding container support for cgroup,there will be
many roots.

Add a helper function cgroup_in_root,only operate the
cgroup when it's in the root.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2e14c8f..0195db1 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -850,6 +850,14 @@ static struct backing_dev_info cgroup_backing_dev_info = {
 static int alloc_css_id(struct cgroup_subsys *ss,
 			struct cgroup *parent, struct cgroup *child);
 
+static inline bool cgroup_in_root(struct cgroup *cgrp,
+				  struct cgroupfs_root *root)
+{
+	if (root == cgrp->root)
+		return true;
+	return false;
+}
+
 /*
  * Find out the top root by subsys_mask.
  */
@@ -2047,7 +2055,8 @@ int cgroup_attach_task_all(struct task_struct *from, struct task_struct *tsk)
 	cgroup_lock();
 	for_each_active_root(root) {
 		struct cgroup *from_cg = task_cgroup_from_root(from, root);
-
+		if (!cgroup_in_root(from_cg, root))
+			continue;
 		retval = cgroup_attach_task(from_cg, tsk);
 		if (retval)
 			break;
@@ -4786,6 +4795,10 @@ static int proc_cgroup_show(struct seq_file *m, void *v)
 		struct cgroup *cgrp;
 		int count = 0;
 
+		cgrp = task_cgroup_from_root(tsk, root);
+		if (!cgroup_in_root(cgrp, root))
+			continue;
+
 		seq_printf(m, "%d:", root->hierarchy_id);
 		for_each_subsys(root, ss)
 			seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
@@ -4793,7 +4806,7 @@ static int proc_cgroup_show(struct seq_file *m, void *v)
 			seq_printf(m, "%sname=%s", count ? "," : "",
 				   root->name);
 		seq_putc(m, ':');
-		cgrp = task_cgroup_from_root(tsk, root);
+
 		retval = cgroup_path(cgrp, buf, PAGE_SIZE);
 		if (retval < 0)
 			goto out_unlock;
-- 
1.7.7.6
