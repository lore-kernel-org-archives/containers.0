From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/6] [RFC] Split do_linkat() out of sys_linkat
Date: Thu, 23 Sep 2010 14:53:30 -0700
Message-ID: <9eade1f1ec10c23dae296feda8af9fe87085e843.1285278339.git.matthltc__13999.4221892723$1285278917$gmane$org@us.ibm.com>
References: <1285278812-16972-1-git-send-email-matthltc@us.ibm.com>
	<6987185123220ec2034677299859c5a63eaf2aed.1285278339.git.matthltc@us.ibm.com>
	<d91e3660266d3a2956c4d1aebc9cb618081b21ef.1285278339.git.matthltc@us.ibm.com>
	<59e9d9fe9db11c6e06ef314541b1112f2b720a59.1285278339.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <59e9d9fe9db11c6e06ef314541b1112f2b720a59.1285278339.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <6987185123220ec2034677299859c5a63eaf2aed.1285278339.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <6987185123220ec2034677299859c5a63eaf2aed.1285278339.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, Amir Goldstein <amir73il-iA+eEnwkJgzk1uMJSBkQmQ@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Separate the __user pathname handling from the bulk of the syscall.
Since we're doing this to enable relinking of unlinked files by
sys_checkpoint and not sys_linkat we're not using a sys-wrapper.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Amir Goldstein <amir73il-iA+eEnwkJgzk1uMJSBkQmQ@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>
---
 fs/namei.c |   79 ++++++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 51 insertions(+), 28 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index eb279e3..8c9663d 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2456,6 +2456,51 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 	return error;
 }
 
+/* If the file has been unlinked then old_dentry doesn't match old_path */
+static int do_linkat(struct path *old_path, struct dentry *old_dentry,
+		     struct nameidata *nd, int flags)
+{
+	struct dentry *new_dentry;
+	int error = -EXDEV;
+
+	if (old_path->mnt != nd->path.mnt)
+		goto out;
+	new_dentry = lookup_create(nd, 0);
+	error = PTR_ERR(new_dentry);
+	if (IS_ERR(new_dentry))
+		goto out_unlock;
+	error = mnt_want_write(nd->path.mnt);
+	if (error)
+		goto out_dput;
+	error = security_path_link(old_dentry, &nd->path, new_dentry);
+	if (error)
+		goto out_drop_write;
+	error = vfs_link(old_dentry, nd->path.dentry->d_inode, new_dentry);
+out_drop_write:
+	mnt_drop_write(nd->path.mnt);
+out_dput:
+	dput(new_dentry);
+out_unlock:
+	mutex_unlock(&nd->path.dentry->d_inode->i_mutex);
+out:
+	return error;
+}
+
+static int do_kern_linkat(struct path *old_path, struct dentry *old_dentry,
+			  int newdfd, const char * newname, int flags)
+{
+	struct nameidata nd;
+	int error;
+
+	error = do_path_lookup(newdfd, newname, LOOKUP_PARENT, &nd);
+	if (error)
+		goto out;
+	error = do_linkat(old_path, old_dentry, &nd, flags);
+	path_put(&nd.path);
+out:
+	return error;
+}
+
 /*
  * Hardlinks are often used in delicate situations.  We avoid
  * security-related surprises by not following symlinks on the
@@ -2468,11 +2513,10 @@ int vfs_link(struct dentry *old_dentry, struct inode *dir, struct dentry *new_de
 SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 		int, newdfd, const char __user *, newname, int, flags)
 {
-	struct dentry *new_dentry;
 	struct nameidata nd;
 	struct path old_path;
-	int error;
 	char *to;
+	int error;
 
 	if ((flags & ~AT_SYMLINK_FOLLOW) != 0)
 		return -EINVAL;
@@ -2481,37 +2525,16 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 			     flags & AT_SYMLINK_FOLLOW ? LOOKUP_FOLLOW : 0,
 			     &old_path);
 	if (error)
-		return error;
-
-	error = user_path_parent(newdfd, newname, &nd, &to);
-	if (error)
 		goto out;
-	error = -EXDEV;
-	if (old_path.mnt != nd.path.mnt)
-		goto out_release;
-	new_dentry = lookup_create(&nd, 0);
-	error = PTR_ERR(new_dentry);
-	if (IS_ERR(new_dentry))
-		goto out_unlock;
-	error = mnt_want_write(nd.path.mnt);
-	if (error)
-		goto out_dput;
-	error = security_path_link(old_path.dentry, &nd.path, new_dentry);
+	error = user_path_parent(newdfd, newname, &nd, &to);
 	if (error)
-		goto out_drop_write;
-	error = vfs_link(old_path.dentry, nd.path.dentry->d_inode, new_dentry);
-out_drop_write:
-	mnt_drop_write(nd.path.mnt);
-out_dput:
-	dput(new_dentry);
-out_unlock:
-	mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
-out_release:
+		goto out_put_old_path;
+	error = do_linkat(&old_path, old_path.dentry, &nd, flags);
 	path_put(&nd.path);
 	putname(to);
-out:
+out_put_old_path:
 	path_put(&old_path);
-
+out:
 	return error;
 }
 
-- 
1.6.3.3
