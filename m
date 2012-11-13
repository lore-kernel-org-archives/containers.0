From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/17] cgroup: open-code cgroup_create_dir()
Date: Mon, 12 Nov 2012 19:01:30 -0800
Message-ID: <1352775704-9023-4-git-send-email-tj@kernel.org>
References: <1352775704-9023-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1352775704-9023-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: mhocko-AlSwsSmVLrQ@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

The operation order of cgroup creation is about to change and
cgroup_create_dir() is more of a hindrance than a proper abstraction.
Open-code it by moving the parent nlink adjustment next to self nlink
adjustment in cgroup_create_file() and the rest to cgroup_create().

This patch doesn't introduce any behavior change.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 30 +++++-------------------------
 1 file changed, 5 insertions(+), 25 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ed0e177..b042673 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2652,6 +2652,7 @@ static int cgroup_create_file(struct dentry *dentry, umode_t mode,
 
 		/* start off with i_nlink == 2 (for "." entry) */
 		inc_nlink(inode);
+		inc_nlink(dentry->d_parent->d_inode);
 
 		/* start with the directory inode held, so that we can
 		 * populate it without racing with another mkdir */
@@ -2666,30 +2667,6 @@ static int cgroup_create_file(struct dentry *dentry, umode_t mode,
 	return 0;
 }
 
-/*
- * cgroup_create_dir - create a directory for an object.
- * @cgrp: the cgroup we create the directory for. It must have a valid
- *        ->parent field. And we are going to fill its ->dentry field.
- * @dentry: dentry of the new cgroup
- * @mode: mode to set on new directory.
- */
-static int cgroup_create_dir(struct cgroup *cgrp, struct dentry *dentry,
-				umode_t mode)
-{
-	struct dentry *parent;
-	int error = 0;
-
-	parent = cgrp->parent->dentry;
-	error = cgroup_create_file(dentry, S_IFDIR | mode, cgrp->root->sb);
-	if (!error) {
-		dentry->d_fsdata = cgrp;
-		inc_nlink(parent->d_inode);
-		rcu_assign_pointer(cgrp->dentry, dentry);
-	}
-
-	return error;
-}
-
 /**
  * cgroup_file_mode - deduce file mode of a control file
  * @cft: the control file in question
@@ -4138,10 +4115,13 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	list_add_tail_rcu(&cgrp->sibling, &cgrp->parent->children);
 	root->number_of_cgroups++;
 
-	err = cgroup_create_dir(cgrp, dentry, mode);
+	err = cgroup_create_file(dentry, S_IFDIR | mode, sb);
 	if (err < 0)
 		goto err_remove;
 
+	dentry->d_fsdata = cgrp;
+	rcu_assign_pointer(cgrp->dentry, dentry);
+
 	for_each_subsys(root, ss) {
 		/* each css holds a ref to the cgroup's dentry */
 		dget(dentry);
-- 
1.7.11.7
