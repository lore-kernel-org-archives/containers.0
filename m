From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v6 4/5] fuse: Ensure posix acls are translated outside of
	init_user_ns
Date: Wed, 21 Feb 2018 14:29:07 -0600
Message-ID: <20180221202908.17258-4-ebiederm@xmission.com>
References: <878tbmf5vl.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <878tbmf5vl.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

Ensure the translation happens by failing to read or write
posix acls when the filesystem has not indicated it supports
posix acls.

This ensures that modern cached posix acl support is available
and used when dealing with posix acls.  This is important
because only that path has the code to convernt the uids and
gids in posix acls into the user namespace of a fuse filesystem.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/fuse/fuse_i.h |  1 +
 fs/fuse/inode.c  |  7 +++++++
 fs/fuse/xattr.c  | 43 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 51 insertions(+)

diff --git a/fs/fuse/fuse_i.h b/fs/fuse/fuse_i.h
index 7772e2b4057e..986fa2b043ab 100644
--- a/fs/fuse/fuse_i.h
+++ b/fs/fuse/fuse_i.h
@@ -979,6 +979,7 @@ ssize_t fuse_listxattr(struct dentry *entry, char *list, size_t size);
 int fuse_removexattr(struct inode *inode, const char *name);
 extern const struct xattr_handler *fuse_xattr_handlers[];
 extern const struct xattr_handler *fuse_acl_xattr_handlers[];
+extern const struct xattr_handler *fuse_no_acl_xattr_handlers[];
 
 struct posix_acl;
 struct posix_acl *fuse_get_acl(struct inode *inode, int type);
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index e018dc3999f4..a52cf2019a58 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -1097,6 +1097,13 @@ static int fuse_fill_super(struct super_block *sb, void *data, int silent)
 	    file->f_cred->user_ns != sb->s_user_ns)
 		goto err_fput;
 
+	/*
+	 * If we are not in the initial user namespace posix
+	 * acls must be translated.
+	 */
+	if (sb->s_user_ns != &init_user_ns)
+		sb->s_xattr = fuse_no_acl_xattr_handlers;
+
 	fc = kmalloc(sizeof(*fc), GFP_KERNEL);
 	err = -ENOMEM;
 	if (!fc)
diff --git a/fs/fuse/xattr.c b/fs/fuse/xattr.c
index 3caac46b08b0..433717640f78 100644
--- a/fs/fuse/xattr.c
+++ b/fs/fuse/xattr.c
@@ -192,6 +192,26 @@ static int fuse_xattr_set(const struct xattr_handler *handler,
 	return fuse_setxattr(inode, name, value, size, flags);
 }
 
+static bool no_xattr_list(struct dentry *dentry)
+{
+	return false;
+}
+
+static int no_xattr_get(const struct xattr_handler *handler,
+			struct dentry *dentry, struct inode *inode,
+			const char *name, void *value, size_t size)
+{
+	return -EOPNOTSUPP;
+}
+
+static int no_xattr_set(const struct xattr_handler *handler,
+			struct dentry *dentry, struct inode *nodee,
+			const char *name, const void *value,
+			size_t size, int flags)
+{
+	return -EOPNOTSUPP;
+}
+
 static const struct xattr_handler fuse_xattr_handler = {
 	.prefix = "",
 	.get    = fuse_xattr_get,
@@ -209,3 +229,26 @@ const struct xattr_handler *fuse_acl_xattr_handlers[] = {
 	&fuse_xattr_handler,
 	NULL
 };
+
+static const struct xattr_handler fuse_no_acl_access_xattr_handler = {
+	.name  = XATTR_NAME_POSIX_ACL_ACCESS,
+	.flags = ACL_TYPE_ACCESS,
+	.list  = no_xattr_list,
+	.get   = no_xattr_get,
+	.set   = no_xattr_set,
+};
+
+static const struct xattr_handler fuse_no_acl_default_xattr_handler = {
+	.name  = XATTR_NAME_POSIX_ACL_DEFAULT,
+	.flags = ACL_TYPE_ACCESS,
+	.list  = no_xattr_list,
+	.get   = no_xattr_get,
+	.set   = no_xattr_set,
+};
+
+const struct xattr_handler *fuse_no_acl_xattr_handlers[] = {
+	&fuse_no_acl_access_xattr_handler,
+	&fuse_no_acl_default_xattr_handler,
+	&fuse_xattr_handler,
+	NULL
+};
-- 
2.14.1
