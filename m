From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 10/10] userns: add support for readdir
Date: Fri, 22 Aug 2008 14:47:24 -0500
Message-ID: <20080822194724.GJ10360@us.ibm.com>
References: <20080822194513.GA10262@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080822194513.GA10262-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Now ls works correctly inside a userns!

(but don't go doing some sort of setattr like 'chown'  :)

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/ext3/file.c  |    4 ++++
 fs/ext3/inode.c |   22 ++++++++++++++++++++++
 fs/ext3/namei.c |    3 +++
 fs/ext3/xattr.c |    6 ++++++
 lib/fsuserns.c  |   42 +++++++++++++++++++++++++++++-------------
 5 files changed, 64 insertions(+), 13 deletions(-)

diff --git a/fs/ext3/file.c b/fs/ext3/file.c
index acc4913..b259061 100644
--- a/fs/ext3/file.c
+++ b/fs/ext3/file.c
@@ -106,6 +106,9 @@ force_commit:
 	return ret;
 }
 
+extern int ext3_getattr(struct vfsmount *mnt, struct dentry *dentry,
+					struct kstat *stat);
+
 const struct file_operations ext3_file_operations = {
 	.llseek		= generic_file_llseek,
 	.read		= do_sync_read,
@@ -134,5 +137,6 @@ const struct inode_operations ext3_file_inode_operations = {
 	.removexattr	= generic_removexattr,
 #endif
 	.permission	= ext3_permission,
+	.getattr	= ext3_getattr,
 };
 
diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
index 507d868..b252490 100644
--- a/fs/ext3/inode.c
+++ b/fs/ext3/inode.c
@@ -36,6 +36,7 @@
 #include <linux/mpage.h>
 #include <linux/uio.h>
 #include <linux/bio.h>
+#include <linux/security.h>
 #include "xattr.h"
 #include "acl.h"
 
@@ -3088,6 +3089,27 @@ err_out:
 	return error;
 }
 
+int ext3_getattr(struct vfsmount *mnt, struct dentry *dentry,
+					struct kstat *stat)
+{
+	struct inode *inode = dentry->d_inode;
+	int retval;
+	uid_t uid;
+	gid_t gid;
+
+	retval = security_inode_getattr(mnt, dentry);
+	if (retval)
+		return retval;
+
+	generic_fillattr(inode, stat);
+
+	retval = s_convert_uid_gid(inode, current->user->user_ns, &uid, &gid);
+	if (retval == 1) {
+		stat->uid = uid;
+		stat->gid = gid;
+	}
+	return 0;
+}
 
 /*
  * How many blocks doth make a writepage()?
diff --git a/fs/ext3/namei.c b/fs/ext3/namei.c
index e5be4bc..fe7350b 100644
--- a/fs/ext3/namei.c
+++ b/fs/ext3/namei.c
@@ -2410,6 +2410,8 @@ end_rename:
 	return retval;
 }
 
+extern int ext3_getattr(struct vfsmount *mnt, struct dentry *dentry,
+					struct kstat *stat);
 /*
  * directories can handle most operations...
  */
@@ -2431,6 +2433,7 @@ const struct inode_operations ext3_dir_inode_operations = {
 	.removexattr	= generic_removexattr,
 #endif
 	.permission	= ext3_permission,
+	.getattr	= ext3_getattr,
 };
 
 const struct inode_operations ext3_special_inode_operations = {
diff --git a/fs/ext3/xattr.c b/fs/ext3/xattr.c
index 500fec7..cf7dc63 100644
--- a/fs/ext3/xattr.c
+++ b/fs/ext3/xattr.c
@@ -345,6 +345,7 @@ ext3_xattr_get_userns(struct inode *inode, void *value, size_t value_size)
 		error = ext3_xattr_block_get(inode, name_index, name, value,
 					     value_size);
 	up_read(&EXT3_I(inode)->xattr_sem);
+	printk(KERN_NOTICE "%s: returning %d for %lu\n", __func__, error, inode->i_ino);
 	return error;
 }
 
@@ -1102,7 +1103,12 @@ retry:
 		error = PTR_ERR(handle);
 	} else {
 		int error2;
+		char *buf;
+		int i;
 
+		printk(KERN_NOTICE "%s: writing %d bytes:\n", __func__, value_len);
+		for (i=0, buf = (char *)value; i<value_len; i++,buf++)
+			printk(KERN_NOTICE "%s: %d %x\n", __func__, i, (int)*buf);
 		error = ext3_xattr_set_handle(handle, inode, name_index, name,
 					      value, value_len, 0);
 		error2 = ext3_journal_stop(handle);
diff --git a/lib/fsuserns.c b/lib/fsuserns.c
index ac0ca99..f0be780 100644
--- a/lib/fsuserns.c
+++ b/lib/fsuserns.c
@@ -179,7 +179,7 @@ int fsuserns_convert_uid_gid(struct user_namespace *ns, struct inode *inode,
 	struct fsuserns_conversion_table *t;
 	struct fsuserns_table_entries *ep;
 	size_t valuelen;
-	struct unsstore *unsstore;
+	struct unsstore *unsstore = NULL;
 	int i, ret;
 
 	t = find_table(sb);
@@ -196,23 +196,33 @@ int fsuserns_convert_uid_gid(struct user_namespace *ns, struct inode *inode,
 convert:
 	mutex_unlock(&fsuserns_table_mutex);
 
-	/* look for an xattr */
-	/* yes, 3 needs to be made adjustable */
-	valuelen = 3;
-	unsstore = kzalloc(3*sizeof(struct unsstore), GFP_KERNEL);
+	ret = xattrget(inode, NULL, 0);
+	if (ret <= 0)
+		goto notfound;
+	valuelen = ret;
+	unsstore = kzalloc(ret, GFP_KERNEL);
 	ret = xattrget(inode, unsstore, valuelen);
-	if (ret < 0)
-		return ret;
-	for (i=0; i<3; i++)
+	if (ret <= 0)
+		goto notfound;
+	for (i=0; i<(ret/sizeof(*unsstore)); i++) {
+		printk(KERN_NOTICE "%s: comparing unstore id %d to userns id %d\n",
+			__func__, unsstore[i].ns, ep->userns_id);
 		if (unsstore[i].ns == ep->userns_id)
-			break;
-	if (i==3)
-		goto out;
+			goto found;
+	}
+	goto notfound;
+
+found:
 	*retuid = unsstore[i].uid;
 	*retgid = unsstore[i].gid;
+	printk(KERN_NOTICE "%s: found a uid (%d) for nsid %d\n",
+			__func__, *retuid, ep->userns_id);
+	kfree(unsstore);
 	return 1;
 
-out:
+notfound:
+	kfree(unsstore);
+	printk(KERN_NOTICE "%s: no uid for my ns found\n", __func__);
 	/* The following is BAD CODE.  IT's for testing only */
 	if (current->uid == 0) {
 		if (inode->i_uid == ns->creator->uid) {
@@ -291,6 +301,12 @@ found:
 
 }
 
+/*
+ * Let's say uid 500 in the init_user_ns created (nsid=3), and uid 400
+ * there created (nsid=5).  Then root in nsid=5 creates a file.
+ * We want to store 500 as the inode->iuid.  In xattr security.userns
+ * we store (3,400) and (5,0)
+ */
 int fsuserns_store_creds(struct inode *inode, struct user_struct *user,
 	int (*xattrset)(struct inode *inode, const void *value, size_t value_len))
 {
@@ -327,7 +343,7 @@ int fsuserns_store_creds(struct inode *inode, struct user_struct *user,
 			unsstore[i].gid = current->gid;
 		else
 			unsstore[i].gid = lastns->creator_grp;
-		printk(KERN_NOTICE "%s: setting xattr with ns=%d,uid=%d\n", __func__,
+		printk(KERN_NOTICE "%s: setting xattr with ns=%d,uid=%d,gid=%d\n", __func__,
 				unsstore[i].ns, unsstore[i].uid, unsstore[i].gid);
 		user = ns->creator;
 		lastns = ns;
-- 
1.5.4.3
