From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v8 2/6] fuse: Simplfiy the posix acl handling logic.
Date: Fri,  2 Mar 2018 15:59:15 -0600
Message-ID: <20180302215919.27207-2-ebiederm@xmission.com>
References: <87r2p287i8.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r2p287i8.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Rename the fuse connection flag posix_acl to cached_posix_acl as that
is what it actually means.  That fuse will cache and operate on the
cached value of the posix acl.

Always use posix_acl_access_xattr_handler so the fuse code benefits
from the generic posix acl handlers as much as possible.  This will
become important as the code works on translation of uid and gid in
the posix acls when fuse is not mounted in the initial user namespace.

Update fuse_get_acl so that it does not cache the acl if the code is
not caching the acl.  This is all that is needed to ensure the
fuse_getxattr calls down into the fuse server when posix_acl_xattr_get
is called.  The updated code goes through fuse_getacl, and as such has
posix acl specific sanity checks and attribute handling but no real
difference from the previous code that skipped it.

It can safely be assumed that fuse filesystems where acls are not
cached in the kernel do not set fc->default_permissions as
default_permissions only checked posix acls if .get_acl was defined
and before the cached acl flag was introduced fuse did not implement a
get_acl method.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/fuse/acl.c    | 6 ++++--
 fs/fuse/dir.c    | 2 +-
 fs/fuse/fuse_i.h | 3 +--
 fs/fuse/inode.c  | 3 +--
 fs/fuse/xattr.c  | 5 -----
 5 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/fs/fuse/acl.c b/fs/fuse/acl.c
index ec85765502f1..cfa58ee0c10b 100644
--- a/fs/fuse/acl.c
+++ b/fs/fuse/acl.c
@@ -19,7 +19,7 @@ struct posix_acl *fuse_get_acl(struct inode *inode, int type)
 	void *value = NULL;
 	struct posix_acl *acl;
 
-	if (!fc->posix_acl || fc->no_getxattr)
+	if (fc->no_getxattr)
 		return NULL;
 
 	if (type == ACL_TYPE_ACCESS)
@@ -44,6 +44,8 @@ struct posix_acl *fuse_get_acl(struct inode *inode, int type)
 		acl = ERR_PTR(size);
 
 	kfree(value);
+	if (!IS_ERR(acl) && !fc->cached_posix_acl)
+		acl = to_uncacheable_acl(acl);
 	return acl;
 }
 
@@ -53,7 +55,7 @@ int fuse_set_acl(struct inode *inode, struct posix_acl *acl, int type)
 	const char *name;
 	int ret;
 
-	if (!fc->posix_acl || fc->no_setxattr)
+	if (fc->no_setxattr)
 		return -EOPNOTSUPP;
 
 	if (type == ACL_TYPE_ACCESS)
diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index 24967382a7b1..43a45e83d313 100644
--- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -1764,7 +1764,7 @@ static int fuse_setattr(struct dentry *entry, struct iattr *attr)
 		 * If filesystem supports acls it may have updated acl xattrs in
 		 * the filesystem, so forget cached acls for the inode.
 		 */
-		if (fc->posix_acl)
+		if (fc->cached_posix_acl)
 			forget_all_cached_acls(inode);
 
 		/* Directory mode changed, may need to revalidate access */
diff --git a/fs/fuse/fuse_i.h b/fs/fuse/fuse_i.h
index c4c093bbf456..74ce02fb16d6 100644
--- a/fs/fuse/fuse_i.h
+++ b/fs/fuse/fuse_i.h
@@ -619,7 +619,7 @@ struct fuse_conn {
 	unsigned no_lseek:1;
 
 	/** Does the filesystem support posix acls? */
-	unsigned posix_acl:1;
+	unsigned cached_posix_acl:1;
 
 	/** Check permissions based on the file mode or not? */
 	unsigned default_permissions:1;
@@ -974,7 +974,6 @@ ssize_t fuse_getxattr(struct inode *inode, const char *name, void *value,
 ssize_t fuse_listxattr(struct dentry *entry, char *list, size_t size);
 int fuse_removexattr(struct inode *inode, const char *name);
 extern const struct xattr_handler *fuse_xattr_handlers[];
-extern const struct xattr_handler *fuse_acl_xattr_handlers[];
 
 struct posix_acl;
 struct posix_acl *fuse_get_acl(struct inode *inode, int type);
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 624f18bbfd2b..507f780046c5 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -915,8 +915,7 @@ static void process_init_reply(struct fuse_conn *fc, struct fuse_req *req)
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
index 3caac46b08b0..ed64c508585a 100644
--- a/fs/fuse/xattr.c
+++ b/fs/fuse/xattr.c
@@ -199,11 +199,6 @@ static const struct xattr_handler fuse_xattr_handler = {
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
