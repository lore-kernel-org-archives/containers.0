From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 17/27] userns: Pass a userns parameter into posix_acl_to_xattr
	and posix_acl_from_xattr
Date: Wed, 19 Sep 2012 18:52:19 -0700
Message-ID: <1348105949-25454-17-git-send-email-ebiederm@xmission.com>
References: <871uhx1n71.fsf@xmission.com>
	<1348105949-25454-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348105949-25454-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dave Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

 - Pass the user namespace the uid and gid values in the xattr are stored
   in into posix_acl_from_xattr.

 - Pass the user namespace kuid and kgid values should be converted into
   when storing uid and gid values in an xattr in posix_acl_to_xattr.

- Modify all callers of posix_acl_from_xattr and posix_acl_to_xattr to
  pass in &init_user_ns.

In the short term this change is not strictly needed but it makes the
code clearer.  In the longer term this change is necessary to be able to
mount filesystems outside of the initial user namespace that natively
store posix acls in the linux xattr format.

Cc: Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Andreas Dilger <adilger.kernel-m1MBpc4rdrD3fQ9qLvQP4Q@public.gmane.org>
Cc: Jan Kara <jack-AlSwsSmVLrQ@public.gmane.org>
Cc: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/9p/acl.c                     |    8 ++++----
 fs/btrfs/acl.c                  |    8 ++++----
 fs/ext2/acl.c                   |    4 ++--
 fs/ext3/acl.c                   |    4 ++--
 fs/ext4/acl.c                   |    4 ++--
 fs/generic_acl.c                |    4 ++--
 fs/gfs2/acl.c                   |   14 +++++++-------
 fs/jffs2/acl.c                  |    4 ++--
 fs/jfs/acl.c                    |    4 ++--
 fs/jfs/xattr.c                  |    4 ++--
 fs/nfs/nfs3acl.c                |    4 ++--
 fs/nfsd/vfs.c                   |    8 ++++----
 fs/ocfs2/acl.c                  |    4 ++--
 fs/reiserfs/xattr_acl.c         |    4 ++--
 fs/xattr_acl.c                  |   14 ++++++++------
 fs/xfs/xfs_acl.c                |    4 ++--
 include/linux/posix_acl_xattr.h |    6 ++++--
 17 files changed, 53 insertions(+), 49 deletions(-)

diff --git a/fs/9p/acl.c b/fs/9p/acl.c
index 9a1d426..15b6791 100644
--- a/fs/9p/acl.c
+++ b/fs/9p/acl.c
@@ -37,7 +37,7 @@ static struct posix_acl *__v9fs_get_acl(struct p9_fid *fid, char *name)
 			return ERR_PTR(-ENOMEM);
 		size = v9fs_fid_xattr_get(fid, name, value, size);
 		if (size > 0) {
-			acl = posix_acl_from_xattr(value, size);
+			acl = posix_acl_from_xattr(&init_user_ns, value, size);
 			if (IS_ERR(acl))
 				goto err_out;
 		}
@@ -131,7 +131,7 @@ static int v9fs_set_acl(struct dentry *dentry, int type, struct posix_acl *acl)
 	buffer = kmalloc(size, GFP_KERNEL);
 	if (!buffer)
 		return -ENOMEM;
-	retval = posix_acl_to_xattr(acl, buffer, size);
+	retval = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
 	if (retval < 0)
 		goto err_free_out;
 	switch (type) {
@@ -251,7 +251,7 @@ static int v9fs_xattr_get_acl(struct dentry *dentry, const char *name,
 		return PTR_ERR(acl);
 	if (acl == NULL)
 		return -ENODATA;
-	error = posix_acl_to_xattr(acl, buffer, size);
+	error = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
 	posix_acl_release(acl);
 
 	return error;
@@ -304,7 +304,7 @@ static int v9fs_xattr_set_acl(struct dentry *dentry, const char *name,
 		return -EPERM;
 	if (value) {
 		/* update the cached acl value */
-		acl = posix_acl_from_xattr(value, size);
+		acl = posix_acl_from_xattr(&init_user_ns, value, size);
 		if (IS_ERR(acl))
 			return PTR_ERR(acl);
 		else if (acl) {
diff --git a/fs/btrfs/acl.c b/fs/btrfs/acl.c
index 761e2cd..0c16e3d 100644
--- a/fs/btrfs/acl.c
+++ b/fs/btrfs/acl.c
@@ -61,7 +61,7 @@ struct posix_acl *btrfs_get_acl(struct inode *inode, int type)
 		size = __btrfs_getxattr(inode, name, value, size);
 	}
 	if (size > 0) {
-		acl = posix_acl_from_xattr(value, size);
+		acl = posix_acl_from_xattr(&init_user_ns, value, size);
 	} else if (size == -ENOENT || size == -ENODATA || size == 0) {
 		/* FIXME, who returns -ENOENT?  I think nobody */
 		acl = NULL;
@@ -91,7 +91,7 @@ static int btrfs_xattr_acl_get(struct dentry *dentry, const char *name,
 		return PTR_ERR(acl);
 	if (acl == NULL)
 		return -ENODATA;
-	ret = posix_acl_to_xattr(acl, value, size);
+	ret = posix_acl_to_xattr(&init_user_ns, acl, value, size);
 	posix_acl_release(acl);
 
 	return ret;
@@ -141,7 +141,7 @@ static int btrfs_set_acl(struct btrfs_trans_handle *trans,
 			goto out;
 		}
 
-		ret = posix_acl_to_xattr(acl, value, size);
+		ret = posix_acl_to_xattr(&init_user_ns, acl, value, size);
 		if (ret < 0)
 			goto out;
 	}
@@ -169,7 +169,7 @@ static int btrfs_xattr_acl_set(struct dentry *dentry, const char *name,
 		return -EOPNOTSUPP;
 
 	if (value) {
-		acl = posix_acl_from_xattr(value, size);
+		acl = posix_acl_from_xattr(&init_user_ns, value, size);
 		if (IS_ERR(acl))
 			return PTR_ERR(acl);
 
diff --git a/fs/ext2/acl.c b/fs/ext2/acl.c
index 35d6a3c..70bb1bc 100644
--- a/fs/ext2/acl.c
+++ b/fs/ext2/acl.c
@@ -350,7 +350,7 @@ ext2_xattr_get_acl(struct dentry *dentry, const char *name, void *buffer,
 		return PTR_ERR(acl);
 	if (acl == NULL)
 		return -ENODATA;
-	error = posix_acl_to_xattr(acl, buffer, size);
+	error = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
 	posix_acl_release(acl);
 
 	return error;
@@ -371,7 +371,7 @@ ext2_xattr_set_acl(struct dentry *dentry, const char *name, const void *value,
 		return -EPERM;
 
 	if (value) {
-		acl = posix_acl_from_xattr(value, size);
+		acl = posix_acl_from_xattr(&init_user_ns, value, size);
 		if (IS_ERR(acl))
 			return PTR_ERR(acl);
 		else if (acl) {
diff --git a/fs/ext3/acl.c b/fs/ext3/acl.c
index c76832c..2cf6a80 100644
--- a/fs/ext3/acl.c
+++ b/fs/ext3/acl.c
@@ -369,7 +369,7 @@ ext3_xattr_get_acl(struct dentry *dentry, const char *name, void *buffer,
 		return PTR_ERR(acl);
 	if (acl == NULL)
 		return -ENODATA;
-	error = posix_acl_to_xattr(acl, buffer, size);
+	error = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
 	posix_acl_release(acl);
 
 	return error;
@@ -392,7 +392,7 @@ ext3_xattr_set_acl(struct dentry *dentry, const char *name, const void *value,
 		return -EPERM;
 
 	if (value) {
-		acl = posix_acl_from_xattr(value, size);
+		acl = posix_acl_from_xattr(&init_user_ns, value, size);
 		if (IS_ERR(acl))
 			return PTR_ERR(acl);
 		else if (acl) {
diff --git a/fs/ext4/acl.c b/fs/ext4/acl.c
index a5c29bb..42b95fc 100644
--- a/fs/ext4/acl.c
+++ b/fs/ext4/acl.c
@@ -374,7 +374,7 @@ ext4_xattr_get_acl(struct dentry *dentry, const char *name, void *buffer,
 		return PTR_ERR(acl);
 	if (acl == NULL)
 		return -ENODATA;
-	error = posix_acl_to_xattr(acl, buffer, size);
+	error = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
 	posix_acl_release(acl);
 
 	return error;
@@ -397,7 +397,7 @@ ext4_xattr_set_acl(struct dentry *dentry, const char *name, const void *value,
 		return -EPERM;
 
 	if (value) {
-		acl = posix_acl_from_xattr(value, size);
+		acl = posix_acl_from_xattr(&init_user_ns, value, size);
 		if (IS_ERR(acl))
 			return PTR_ERR(acl);
 		else if (acl) {
diff --git a/fs/generic_acl.c b/fs/generic_acl.c
index d0dddac..b3f3676 100644
--- a/fs/generic_acl.c
+++ b/fs/generic_acl.c
@@ -56,7 +56,7 @@ generic_acl_get(struct dentry *dentry, const char *name, void *buffer,
 	acl = get_cached_acl(dentry->d_inode, type);
 	if (!acl)
 		return -ENODATA;
-	error = posix_acl_to_xattr(acl, buffer, size);
+	error = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
 	posix_acl_release(acl);
 
 	return error;
@@ -77,7 +77,7 @@ generic_acl_set(struct dentry *dentry, const char *name, const void *value,
 	if (!inode_owner_or_capable(inode))
 		return -EPERM;
 	if (value) {
-		acl = posix_acl_from_xattr(value, size);
+		acl = posix_acl_from_xattr(&init_user_ns, value, size);
 		if (IS_ERR(acl))
 			return PTR_ERR(acl);
 	}
diff --git a/fs/gfs2/acl.c b/fs/gfs2/acl.c
index bd4a589..f850020 100644
--- a/fs/gfs2/acl.c
+++ b/fs/gfs2/acl.c
@@ -63,7 +63,7 @@ struct posix_acl *gfs2_get_acl(struct inode *inode, int type)
 	if (len == 0)
 		return NULL;
 
-	acl = posix_acl_from_xattr(data, len);
+	acl = posix_acl_from_xattr(&init_user_ns, data, len);
 	kfree(data);
 	return acl;
 }
@@ -88,13 +88,13 @@ static int gfs2_acl_set(struct inode *inode, int type, struct posix_acl *acl)
 	const char *name = gfs2_acl_name(type);
 
 	BUG_ON(name == NULL);
-	len = posix_acl_to_xattr(acl, NULL, 0);
+	len = posix_acl_to_xattr(&init_user_ns, acl, NULL, 0);
 	if (len == 0)
 		return 0;
 	data = kmalloc(len, GFP_NOFS);
 	if (data == NULL)
 		return -ENOMEM;
-	error = posix_acl_to_xattr(acl, data, len);
+	error = posix_acl_to_xattr(&init_user_ns, acl, data, len);
 	if (error < 0)
 		goto out;
 	error = __gfs2_xattr_set(inode, name, data, len, 0, GFS2_EATYPE_SYS);
@@ -166,12 +166,12 @@ int gfs2_acl_chmod(struct gfs2_inode *ip, struct iattr *attr)
 	if (error)
 		return error;
 
-	len = posix_acl_to_xattr(acl, NULL, 0);
+	len = posix_acl_to_xattr(&init_user_ns, acl, NULL, 0);
 	data = kmalloc(len, GFP_NOFS);
 	error = -ENOMEM;
 	if (data == NULL)
 		goto out;
-	posix_acl_to_xattr(acl, data, len);
+	posix_acl_to_xattr(&init_user_ns, acl, data, len);
 	error = gfs2_xattr_acl_chmod(ip, attr, data);
 	kfree(data);
 	set_cached_acl(&ip->i_inode, ACL_TYPE_ACCESS, acl);
@@ -212,7 +212,7 @@ static int gfs2_xattr_system_get(struct dentry *dentry, const char *name,
 	if (acl == NULL)
 		return -ENODATA;
 
-	error = posix_acl_to_xattr(acl, buffer, size);
+	error = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
 	posix_acl_release(acl);
 
 	return error;
@@ -245,7 +245,7 @@ static int gfs2_xattr_system_set(struct dentry *dentry, const char *name,
 	if (!value)
 		goto set_acl;
 
-	acl = posix_acl_from_xattr(value, size);
+	acl = posix_acl_from_xattr(&init_user_ns, value, size);
 	if (!acl) {
 		/*
 		 * acl_set_file(3) may request that we set default ACLs with
diff --git a/fs/jffs2/acl.c b/fs/jffs2/acl.c
index 922f146..42e4edc 100644
--- a/fs/jffs2/acl.c
+++ b/fs/jffs2/acl.c
@@ -363,7 +363,7 @@ static int jffs2_acl_getxattr(struct dentry *dentry, const char *name,
 		return PTR_ERR(acl);
 	if (!acl)
 		return -ENODATA;
-	rc = posix_acl_to_xattr(acl, buffer, size);
+	rc = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
 	posix_acl_release(acl);
 
 	return rc;
@@ -381,7 +381,7 @@ static int jffs2_acl_setxattr(struct dentry *dentry, const char *name,
 		return -EPERM;
 
 	if (value) {
-		acl = posix_acl_from_xattr(value, size);
+		acl = posix_acl_from_xattr(&init_user_ns, value, size);
 		if (IS_ERR(acl))
 			return PTR_ERR(acl);
 		if (acl) {
diff --git a/fs/jfs/acl.c b/fs/jfs/acl.c
index 45559dc..d254d6d 100644
--- a/fs/jfs/acl.c
+++ b/fs/jfs/acl.c
@@ -64,7 +64,7 @@ struct posix_acl *jfs_get_acl(struct inode *inode, int type)
 		else
 			acl = ERR_PTR(size);
 	} else {
-		acl = posix_acl_from_xattr(value, size);
+		acl = posix_acl_from_xattr(&init_user_ns, value, size);
 	}
 	kfree(value);
 	if (!IS_ERR(acl))
@@ -100,7 +100,7 @@ static int jfs_set_acl(tid_t tid, struct inode *inode, int type,
 		value = kmalloc(size, GFP_KERNEL);
 		if (!value)
 			return -ENOMEM;
-		rc = posix_acl_to_xattr(acl, value, size);
+		rc = posix_acl_to_xattr(&init_user_ns, acl, value, size);
 		if (rc < 0)
 			goto out;
 	}
diff --git a/fs/jfs/xattr.c b/fs/jfs/xattr.c
index 26683e1..42d67f9 100644
--- a/fs/jfs/xattr.c
+++ b/fs/jfs/xattr.c
@@ -685,7 +685,7 @@ static int can_set_system_xattr(struct inode *inode, const char *name,
 	 * POSIX_ACL_XATTR_ACCESS is tied to i_mode
 	 */
 	if (strcmp(name, POSIX_ACL_XATTR_ACCESS) == 0) {
-		acl = posix_acl_from_xattr(value, value_len);
+		acl = posix_acl_from_xattr(&init_user_ns, value, value_len);
 		if (IS_ERR(acl)) {
 			rc = PTR_ERR(acl);
 			printk(KERN_ERR "posix_acl_from_xattr returned %d\n",
@@ -710,7 +710,7 @@ static int can_set_system_xattr(struct inode *inode, const char *name,
 
 		return 0;
 	} else if (strcmp(name, POSIX_ACL_XATTR_DEFAULT) == 0) {
-		acl = posix_acl_from_xattr(value, value_len);
+		acl = posix_acl_from_xattr(&init_user_ns, value, value_len);
 		if (IS_ERR(acl)) {
 			rc = PTR_ERR(acl);
 			printk(KERN_ERR "posix_acl_from_xattr returned %d\n",
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index e4498dc..4a1aafb 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -70,7 +70,7 @@ ssize_t nfs3_getxattr(struct dentry *dentry, const char *name,
 		if (type == ACL_TYPE_ACCESS && acl->a_count == 0)
 			error = -ENODATA;
 		else
-			error = posix_acl_to_xattr(acl, buffer, size);
+			error = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
 		posix_acl_release(acl);
 	} else
 		error = -ENODATA;
@@ -92,7 +92,7 @@ int nfs3_setxattr(struct dentry *dentry, const char *name,
 	else
 		return -EOPNOTSUPP;
 
-	acl = posix_acl_from_xattr(value, size);
+	acl = posix_acl_from_xattr(&init_user_ns, value, size);
 	if (IS_ERR(acl))
 		return PTR_ERR(acl);
 	error = nfs3_proc_setacl(inode, type, acl);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a9269f1..3f67b8e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -480,7 +480,7 @@ set_nfsv4_acl_one(struct dentry *dentry, struct posix_acl *pacl, char *key)
 	if (buf == NULL)
 		goto out;
 
-	len = posix_acl_to_xattr(pacl, buf, buflen);
+	len = posix_acl_to_xattr(&init_user_ns, pacl, buf, buflen);
 	if (len < 0) {
 		error = len;
 		goto out;
@@ -549,7 +549,7 @@ _get_posix_acl(struct dentry *dentry, char *key)
 	if (buflen <= 0)
 		return ERR_PTR(buflen);
 
-	pacl = posix_acl_from_xattr(buf, buflen);
+	pacl = posix_acl_from_xattr(&init_user_ns, buf, buflen);
 	kfree(buf);
 	return pacl;
 }
@@ -2264,7 +2264,7 @@ nfsd_get_posix_acl(struct svc_fh *fhp, int type)
 	if (size < 0)
 		return ERR_PTR(size);
 
-	acl = posix_acl_from_xattr(value, size);
+	acl = posix_acl_from_xattr(&init_user_ns, value, size);
 	kfree(value);
 	return acl;
 }
@@ -2297,7 +2297,7 @@ nfsd_set_posix_acl(struct svc_fh *fhp, int type, struct posix_acl *acl)
 		value = kmalloc(size, GFP_KERNEL);
 		if (!value)
 			return -ENOMEM;
-		error = posix_acl_to_xattr(acl, value, size);
+		error = posix_acl_to_xattr(&init_user_ns, acl, value, size);
 		if (error < 0)
 			goto getout;
 		size = error;
diff --git a/fs/ocfs2/acl.c b/fs/ocfs2/acl.c
index a721907..260b162 100644
--- a/fs/ocfs2/acl.c
+++ b/fs/ocfs2/acl.c
@@ -452,7 +452,7 @@ static int ocfs2_xattr_get_acl(struct dentry *dentry, const char *name,
 		return PTR_ERR(acl);
 	if (acl == NULL)
 		return -ENODATA;
-	ret = posix_acl_to_xattr(acl, buffer, size);
+	ret = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
 	posix_acl_release(acl);
 
 	return ret;
@@ -475,7 +475,7 @@ static int ocfs2_xattr_set_acl(struct dentry *dentry, const char *name,
 		return -EPERM;
 
 	if (value) {
-		acl = posix_acl_from_xattr(value, size);
+		acl = posix_acl_from_xattr(&init_user_ns, value, size);
 		if (IS_ERR(acl))
 			return PTR_ERR(acl);
 		else if (acl) {
diff --git a/fs/reiserfs/xattr_acl.c b/fs/reiserfs/xattr_acl.c
index 44474f9..87d6911 100644
--- a/fs/reiserfs/xattr_acl.c
+++ b/fs/reiserfs/xattr_acl.c
@@ -30,7 +30,7 @@ posix_acl_set(struct dentry *dentry, const char *name, const void *value,
 		return -EPERM;
 
 	if (value) {
-		acl = posix_acl_from_xattr(value, size);
+		acl = posix_acl_from_xattr(&init_user_ns, value, size);
 		if (IS_ERR(acl)) {
 			return PTR_ERR(acl);
 		} else if (acl) {
@@ -77,7 +77,7 @@ posix_acl_get(struct dentry *dentry, const char *name, void *buffer,
 		return PTR_ERR(acl);
 	if (acl == NULL)
 		return -ENODATA;
-	error = posix_acl_to_xattr(acl, buffer, size);
+	error = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
 	posix_acl_release(acl);
 
 	return error;
diff --git a/fs/xattr_acl.c b/fs/xattr_acl.c
index bf472ca..11efd83 100644
--- a/fs/xattr_acl.c
+++ b/fs/xattr_acl.c
@@ -73,7 +73,8 @@ void posix_acl_fix_xattr_to_user(void *value, size_t size)
  * Convert from extended attribute to in-memory representation.
  */
 struct posix_acl *
-posix_acl_from_xattr(const void *value, size_t size)
+posix_acl_from_xattr(struct user_namespace *user_ns,
+		     const void *value, size_t size)
 {
 	posix_acl_xattr_header *header = (posix_acl_xattr_header *)value;
 	posix_acl_xattr_entry *entry = (posix_acl_xattr_entry *)(header+1), *end;
@@ -112,14 +113,14 @@ posix_acl_from_xattr(const void *value, size_t size)
 
 			case ACL_USER:
 				acl_e->e_uid =
-					make_kuid(&init_user_ns,
+					make_kuid(user_ns,
 						  le32_to_cpu(entry->e_id));
 				if (!uid_valid(acl_e->e_uid))
 					goto fail;
 				break;
 			case ACL_GROUP:
 				acl_e->e_gid =
-					make_kgid(&init_user_ns,
+					make_kgid(user_ns,
 						  le32_to_cpu(entry->e_id));
 				if (!gid_valid(acl_e->e_gid))
 					goto fail;
@@ -141,7 +142,8 @@ EXPORT_SYMBOL (posix_acl_from_xattr);
  * Convert from in-memory to extended attribute representation.
  */
 int
-posix_acl_to_xattr(const struct posix_acl *acl, void *buffer, size_t size)
+posix_acl_to_xattr(struct user_namespace *user_ns, const struct posix_acl *acl,
+		   void *buffer, size_t size)
 {
 	posix_acl_xattr_header *ext_acl = (posix_acl_xattr_header *)buffer;
 	posix_acl_xattr_entry *ext_entry = ext_acl->a_entries;
@@ -162,11 +164,11 @@ posix_acl_to_xattr(const struct posix_acl *acl, void *buffer, size_t size)
 		switch(acl_e->e_tag) {
 		case ACL_USER:
 			ext_entry->e_id =
-				cpu_to_le32(from_kuid(&init_user_ns, acl_e->e_uid));
+				cpu_to_le32(from_kuid(user_ns, acl_e->e_uid));
 			break;
 		case ACL_GROUP:
 			ext_entry->e_id =
-				cpu_to_le32(from_kgid(&init_user_ns, acl_e->e_gid));
+				cpu_to_le32(from_kgid(user_ns, acl_e->e_gid));
 			break;
 		default:
 			ext_entry->e_id = cpu_to_le32(ACL_UNDEFINED_ID);
diff --git a/fs/xfs/xfs_acl.c b/fs/xfs/xfs_acl.c
index ac702a6..1d32f1d 100644
--- a/fs/xfs/xfs_acl.c
+++ b/fs/xfs/xfs_acl.c
@@ -337,7 +337,7 @@ xfs_xattr_acl_get(struct dentry *dentry, const char *name,
 	if (acl == NULL)
 		return -ENODATA;
 
-	error = posix_acl_to_xattr(acl, value, size);
+	error = posix_acl_to_xattr(&init_user_ns, acl, value, size);
 	posix_acl_release(acl);
 
 	return error;
@@ -361,7 +361,7 @@ xfs_xattr_acl_set(struct dentry *dentry, const char *name,
 	if (!value)
 		goto set_acl;
 
-	acl = posix_acl_from_xattr(value, size);
+	acl = posix_acl_from_xattr(&init_user_ns, value, size);
 	if (!acl) {
 		/*
 		 * acl_set_file(3) may request that we set default ACLs with
diff --git a/include/linux/posix_acl_xattr.h b/include/linux/posix_acl_xattr.h
index 8bd5fcf..ad93ad0 100644
--- a/include/linux/posix_acl_xattr.h
+++ b/include/linux/posix_acl_xattr.h
@@ -64,7 +64,9 @@ static inline void posix_acl_fix_xattr_to_user(void *value, size_t size)
 }
 #endif
 
-struct posix_acl *posix_acl_from_xattr(const void *value, size_t size);
-int posix_acl_to_xattr(const struct posix_acl *acl, void *buffer, size_t size);
+struct posix_acl *posix_acl_from_xattr(struct user_namespace *user_ns, 
+				       const void *value, size_t size);
+int posix_acl_to_xattr(struct user_namespace *user_ns,
+		       const struct posix_acl *acl, void *buffer, size_t size);
 
 #endif	/* _POSIX_ACL_XATTR_H */
-- 
1.7.5.4
