From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 06/13] cgroup: update cgroup name handling
Date: Tue, 28 Jan 2014 18:54:38 -0500
Message-ID: <1390953285-16360-7-git-send-email-tj@kernel.org>
References: <1390953285-16360-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390953285-16360-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

Straightforward updates to cgroup name handling in preparation of
kernfs conversion.

* cgroup_alloc_name() is updated to take const char * isntead of
  dentry * for name source.

* cgroup name formatting is separated out into cgroup_file_name().
  While at it, buffer length protection is added.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 35 ++++++++++++++++++++++-------------
 1 file changed, 22 insertions(+), 13 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index bdbd9ad..e832f90 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -67,6 +67,9 @@
  */
 #define CGROUP_PIDLIST_DESTROY_DELAY	HZ
 
+#define CGROUP_FILE_NAME_MAX		(MAX_CGROUP_TYPE_NAMELEN +	\
+					 MAX_CFTYPE_NAME + 2)
+
 /*
  * cgroup_tree_mutex nests above cgroup_mutex and protects cftypes, file
  * creation/removal and hierarchy changing operations including cgroup
@@ -799,17 +802,29 @@ static struct inode *cgroup_new_inode(umode_t mode, struct super_block *sb)
 	return inode;
 }
 
-static struct cgroup_name *cgroup_alloc_name(struct dentry *dentry)
+static struct cgroup_name *cgroup_alloc_name(const char *name_str)
 {
 	struct cgroup_name *name;
 
-	name = kmalloc(sizeof(*name) + dentry->d_name.len + 1, GFP_KERNEL);
+	name = kmalloc(sizeof(*name) + strlen(name_str) + 1, GFP_KERNEL);
 	if (!name)
 		return NULL;
-	strcpy(name->name, dentry->d_name.name);
+	strcpy(name->name, name_str);
 	return name;
 }
 
+static char *cgroup_file_name(struct cgroup *cgrp, const struct cftype *cft,
+			      char *buf)
+{
+	if (cft->ss && !(cft->flags & CFTYPE_NO_PREFIX) &&
+	    !(cgrp->root->flags & CGRP_ROOT_NOPREFIX))
+		snprintf(buf, CGROUP_FILE_NAME_MAX, "%s.%s",
+			 cft->ss->name, cft->name);
+	else
+		strncpy(buf, cft->name, CGROUP_FILE_NAME_MAX);
+	return buf;
+}
+
 static void cgroup_free_fn(struct work_struct *work)
 {
 	struct cgroup *cgrp = container_of(work, struct cgroup, destroy_work);
@@ -2428,7 +2443,7 @@ static int cgroup_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (cgroup_sane_behavior(cgrp))
 		return -EPERM;
 
-	name = cgroup_alloc_name(new_dentry);
+	name = cgroup_alloc_name(new_dentry->d_name.name);
 	if (!name)
 		return -ENOMEM;
 
@@ -2604,14 +2619,7 @@ static int cgroup_add_file(struct cgroup *cgrp, struct cftype *cft)
 	struct cfent *cfe;
 	int error;
 	umode_t mode;
-	char name[MAX_CGROUP_TYPE_NAMELEN + MAX_CFTYPE_NAME + 2] = { 0 };
-
-	if (cft->ss && !(cft->flags & CFTYPE_NO_PREFIX) &&
-	    !(cgrp->root->flags & CGRP_ROOT_NOPREFIX)) {
-		strcpy(name, cft->ss->name);
-		strcat(name, ".");
-	}
-	strcat(name, cft->name);
+	char name[CGROUP_FILE_NAME_MAX];
 
 	BUG_ON(!mutex_is_locked(&dir->d_inode->i_mutex));
 
@@ -2619,6 +2627,7 @@ static int cgroup_add_file(struct cgroup *cgrp, struct cftype *cft)
 	if (!cfe)
 		return -ENOMEM;
 
+	cgroup_file_name(cgrp, cft, name);
 	dentry = lookup_one_len(name, dir, strlen(name));
 	if (IS_ERR(dentry)) {
 		error = PTR_ERR(dentry);
@@ -4126,7 +4135,7 @@ static long cgroup_create(struct cgroup *parent, struct dentry *dentry,
 	if (!cgrp)
 		return -ENOMEM;
 
-	name = cgroup_alloc_name(dentry);
+	name = cgroup_alloc_name(dentry->d_name.name);
 	if (!name) {
 		err = -ENOMEM;
 		goto err_free_cgrp;
-- 
1.8.5.3
