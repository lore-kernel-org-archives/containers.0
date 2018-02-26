From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v7 5/7] fuse: Simplfiy the posix acl handling logic.
Date: Mon, 26 Feb 2018 17:53:00 -0600
Message-ID: <20180226235302.12708-5-ebiederm@xmission.com>
References: <87po4rz4ui.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87po4rz4ui.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Rename the fuse connection flag posix_acl to cached_posix_acl as that
is what it actually means.  That fuse will cache and operate on the
cached value of the posix acl.

When fc->cached_posix_acl is not set, set ACL_DONT_CACHE on the inode
so that get_acl and friends won't cache the acl values even if they
are called.

Replace forget_all_cached_acls with fuse_forget_cached_acls.  This
wrapper only takes effect when cached_posix_acl is true to prevent
losing the nocache or noxattr status in when posix acls are not
cached.

Always use posix_acl_access_xattr_handler so the fuse code
benefits from the generic posix acl handlers as much as possible.
This will become important as the code works on translation
of uid and gid in the posix acls when fuse is not mounted in
the initial user namespace.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/fuse/acl.c    |  6 +++---
 fs/fuse/dir.c    | 11 +++++------
 fs/fuse/fuse_i.h |  5 +++--
 fs/fuse/inode.c  | 13 ++++++++++---
 fs/fuse/xattr.c  |  5 -----
 5 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/fs/fuse/acl.c b/fs/fuse/acl.c
index ec85765502f1..8fb2153dbf50 100644
--- a/fs/fuse/acl.c
+++ b/fs/fuse/acl.c
@@ -19,7 +19,7 @@ struct posix_acl *fuse_get_acl(struct inode *inode, int type)
 	void *value = NULL;
 	struct posix_acl *acl;
 
-	if (!fc->posix_acl || fc->no_getxattr)
+	if (fc->no_getxattr)
 		return NULL;
 
 	if (type == ACL_TYPE_ACCESS)
@@ -53,7 +53,7 @@ int fuse_set_acl(struct inode *inode, struct posix_acl *acl, int type)
 	const char *name;
 	int ret;
 
-	if (!fc->posix_acl || fc->no_setxattr)
+	if (fc->no_setxattr)
 		return -EOPNOTSUPP;
 
 	if (type == ACL_TYPE_ACCESS)
@@ -92,7 +92,7 @@ int fuse_set_acl(struct inode *inode, struct posix_acl *acl, int type)
 	} else {
 		ret = fuse_removexattr(inode, name);
 	}
-	forget_all_cached_acls(inode);
+	fuse_forget_cached_acls(inode);
 	fuse_invalidate_attr(inode);
 
 	return ret;
diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index 24967382a7b1..a44ca509db4f 100644
--- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -237,7 +237,7 @@ static int fuse_dentry_revalidate(struct dentry *entry, unsigned int flags)
 		if (ret || (outarg.attr.mode ^ inode->i_mode) & S_IFMT)
 			goto invalid;
 
-		forget_all_cached_acls(inode);
+		fuse_forget_cached_acls(inode);
 		fuse_change_attributes(inode, &outarg.attr,
 				       entry_attr_timeout(&outarg),
 				       attr_version);
@@ -930,7 +930,7 @@ static int fuse_update_get_attr(struct inode *inode, struct file *file,
 	int err = 0;
 
 	if (time_before64(fi->i_time, get_jiffies_64())) {
-		forget_all_cached_acls(inode);
+		fuse_forget_cached_acls(inode);
 		err = fuse_do_getattr(inode, stat, file);
 	} else if (stat) {
 		generic_fillattr(inode, stat);
@@ -1076,7 +1076,7 @@ static int fuse_perm_getattr(struct inode *inode, int mask)
 	if (mask & MAY_NOT_BLOCK)
 		return -ECHILD;
 
-	forget_all_cached_acls(inode);
+	fuse_forget_cached_acls(inode);
 	return fuse_do_getattr(inode, NULL, NULL);
 }
 
@@ -1246,7 +1246,7 @@ static int fuse_direntplus_link(struct file *file,
 		fi->nlookup++;
 		spin_unlock(&fc->lock);
 
-		forget_all_cached_acls(inode);
+		fuse_forget_cached_acls(inode);
 		fuse_change_attributes(inode, &o->attr,
 				       entry_attr_timeout(o),
 				       attr_version);
@@ -1764,8 +1764,7 @@ static int fuse_setattr(struct dentry *entry, struct iattr *attr)
 		 * If filesystem supports acls it may have updated acl xattrs in
 		 * the filesystem, so forget cached acls for the inode.
 		 */
-		if (fc->posix_acl)
-			forget_all_cached_acls(inode);
+		fuse_forget_cached_acls(inode);
 
 		/* Directory mode changed, may need to revalidate access */
 		if (d_is_dir(entry) && (attr->ia_valid & ATTR_MODE))
diff --git a/fs/fuse/fuse_i.h b/fs/fuse/fuse_i.h
index c4c093bbf456..3cf296d60bc0 100644
--- a/fs/fuse/fuse_i.h
+++ b/fs/fuse/fuse_i.h
@@ -619,7 +619,7 @@ struct fuse_conn {
 	unsigned no_lseek:1;
 
 	/** Does the filesystem support posix acls? */
-	unsigned posix_acl:1;
+	unsigned cached_posix_acl:1;
 
 	/** Check permissions based on the file mode or not? */
 	unsigned default_permissions:1;
@@ -913,6 +913,8 @@ void fuse_release_nowrite(struct inode *inode);
 
 u64 fuse_get_attr_version(struct fuse_conn *fc);
 
+void fuse_forget_cached_acls(struct inode *inode);
+
 /**
  * File-system tells the kernel to invalidate cache for the given node id.
  */
@@ -974,7 +976,6 @@ ssize_t fuse_getxattr(struct inode *inode, const char *name, void *value,
 ssize_t fuse_listxattr(struct dentry *entry, char *list, size_t size);
 int fuse_removexattr(struct inode *inode, const char *name);
 extern const struct xattr_handler *fuse_xattr_handlers[];
-extern const struct xattr_handler *fuse_acl_xattr_handlers[];
 
 struct posix_acl;
 struct posix_acl *fuse_get_acl(struct inode *inode, int type);
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 624f18bbfd2b..0c3ccca7c554 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -313,6 +313,8 @@ struct inode *fuse_iget(struct super_block *sb, u64 nodeid,
 		if (!fc->writeback_cache || !S_ISREG(attr->mode))
 			inode->i_flags |= S_NOCMTIME;
 		inode->i_generation = generation;
+		if (!fc->cached_posix_acl)
+			inode->i_acl = inode->i_default_acl = ACL_DONT_CACHE;
 		fuse_init_inode(inode, attr);
 		unlock_new_inode(inode);
 	} else if ((inode->i_mode ^ attr->mode) & S_IFMT) {
@@ -331,6 +333,12 @@ struct inode *fuse_iget(struct super_block *sb, u64 nodeid,
 	return inode;
 }
 
+void fuse_forget_cached_acls(struct inode *inode)
+{
+	if (get_fuse_conn(inode)->cached_posix_acl)
+		forget_all_cached_acls(inode);
+}
+
 int fuse_reverse_inval_inode(struct super_block *sb, u64 nodeid,
 			     loff_t offset, loff_t len)
 {
@@ -343,7 +351,7 @@ int fuse_reverse_inval_inode(struct super_block *sb, u64 nodeid,
 		return -ENOENT;
 
 	fuse_invalidate_attr(inode);
-	forget_all_cached_acls(inode);
+	fuse_forget_cached_acls(inode);
 	if (offset >= 0) {
 		pg_start = offset >> PAGE_SHIFT;
 		if (len <= 0)
@@ -915,8 +923,7 @@ static void process_init_reply(struct fuse_conn *fc, struct fuse_req *req)
 				fc->sb->s_time_gran = arg->time_gran;
 			if ((arg->flags & FUSE_POSIX_ACL)) {
 				fc->default_permissions = 1;
-				fc->posix_acl = 1;
-				fc->sb->s_xattr = fuse_acl_xattr_handlers;
+				fc->cached_posix_acl = 1;
 			}
 		} else {
 			ra_pages = fc->max_read / PAGE_SIZE;
diff --git a/fs/fuse/xattr.c b/fs/fuse/xattr.c
index 0520a4f47226..48a95e1bb020 100644
--- a/fs/fuse/xattr.c
+++ b/fs/fuse/xattr.c
@@ -200,11 +200,6 @@ static const struct xattr_handler fuse_xattr_handler = {
 };
 
 const struct xattr_handler *fuse_xattr_handlers[] = {
-	&fuse_xattr_handler,
-	NULL
-};
-
-const struct xattr_handler *fuse_acl_xattr_handlers[] = {
 	&posix_acl_access_xattr_handler,
 	&posix_acl_default_xattr_handler,
 	&fuse_xattr_handler,
-- 
2.14.1
