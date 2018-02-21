From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v6 3/5] fuse: Support fuse filesystems outside of init_user_ns
Date: Wed, 21 Feb 2018 14:29:06 -0600
Message-ID: <20180221202908.17258-3-ebiederm@xmission.com>
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

In order to support mounts from namespaces other than init_user_ns,
fuse must translate uids and gids to/from the userns of the process
servicing requests on /dev/fuse. This patch does that, with a couple
of restrictions on the namespace:

 - The userns for the fuse connection is fixed to the namespace
   from which /dev/fuse is opened.

 - The namespace must be the same as s_user_ns.

These restrictions simplify the implementation by avoiding the need to
pass around userns references and by allowing fuse to rely on the
checks in setattr_prepare for ownership changes.  Either restriction
could be relaxed in the future if needed.

For cuse the userns used is the opener of /dev/cuse.  Semantically the
cuse support does not appear safe for unprivileged users.  Practically
the permissions on /dev/cuse only make it accessible to the global root
user.  If something slips through the cracks in a user namespace the only
users who will be able to use the cuse device are those users mapped into
the user namespace.

Translation in the posix acl is updated to use the uuser namespace of
the filesystem.  Avoiding cases which might bypass this translation is
handled in a following change.

This change is stronlgy based on a similar change from Seth Forshee
and Dongsu Park.

Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/fuse/acl.c    |  4 ++--
 fs/fuse/cuse.c   |  7 ++++++-
 fs/fuse/dev.c    |  4 ++--
 fs/fuse/dir.c    | 14 +++++++-------
 fs/fuse/fuse_i.h |  6 +++++-
 fs/fuse/inode.c  | 31 +++++++++++++++++++------------
 6 files changed, 41 insertions(+), 25 deletions(-)

diff --git a/fs/fuse/acl.c b/fs/fuse/acl.c
index ec85765502f1..5a48cee6d7d3 100644
--- a/fs/fuse/acl.c
+++ b/fs/fuse/acl.c
@@ -34,7 +34,7 @@ struct posix_acl *fuse_get_acl(struct inode *inode, int type)
 		return ERR_PTR(-ENOMEM);
 	size = fuse_getxattr(inode, name, value, PAGE_SIZE);
 	if (size > 0)
-		acl = posix_acl_from_xattr(&init_user_ns, value, size);
+		acl = posix_acl_from_xattr(fc->user_ns, value, size);
 	else if ((size == 0) || (size == -ENODATA) ||
 		 (size == -EOPNOTSUPP && fc->no_getxattr))
 		acl = NULL;
@@ -81,7 +81,7 @@ int fuse_set_acl(struct inode *inode, struct posix_acl *acl, int type)
 		if (!value)
 			return -ENOMEM;
 
-		ret = posix_acl_to_xattr(&init_user_ns, acl, value, size);
+		ret = posix_acl_to_xattr(fc->user_ns, acl, value, size);
 		if (ret < 0) {
 			kfree(value);
 			return ret;
diff --git a/fs/fuse/cuse.c b/fs/fuse/cuse.c
index e9e97803442a..036ee477669e 100644
--- a/fs/fuse/cuse.c
+++ b/fs/fuse/cuse.c
@@ -48,6 +48,7 @@
 #include <linux/stat.h>
 #include <linux/module.h>
 #include <linux/uio.h>
+#include <linux/user_namespace.h>
 
 #include "fuse_i.h"
 
@@ -498,7 +499,11 @@ static int cuse_channel_open(struct inode *inode, struct file *file)
 	if (!cc)
 		return -ENOMEM;
 
-	fuse_conn_init(&cc->fc);
+	/*
+	 * Limit the cuse channel to requests that can
+	 * be represented in file->f_cred->user_ns.
+	 */
+	fuse_conn_init(&cc->fc, file->f_cred->user_ns);
 
 	fud = fuse_dev_alloc(&cc->fc);
 	if (!fud) {
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index 216db3f51a31..338cfda3eb8f 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -114,8 +114,8 @@ static void __fuse_put_request(struct fuse_req *req)
 
 static bool fuse_req_init_context(struct fuse_conn *fc, struct fuse_req *req)
 {
-	req->in.h.uid = from_kuid(&init_user_ns, current_fsuid());
-	req->in.h.gid = from_kgid(&init_user_ns, current_fsgid());
+	req->in.h.uid = from_kuid(fc->user_ns, current_fsuid());
+	req->in.h.gid = from_kgid(fc->user_ns, current_fsgid());
 	req->in.h.pid = pid_nr_ns(task_pid(current), fc->pid_ns);
 
 	return (req->in.h.uid != ((uid_t)-1)) && (req->in.h.gid != ((gid_t)-1));
diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index 24967382a7b1..ad1cfac1942f 100644
--- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -858,8 +858,8 @@ static void fuse_fillattr(struct inode *inode, struct fuse_attr *attr,
 	stat->ino = attr->ino;
 	stat->mode = (inode->i_mode & S_IFMT) | (attr->mode & 07777);
 	stat->nlink = attr->nlink;
-	stat->uid = make_kuid(&init_user_ns, attr->uid);
-	stat->gid = make_kgid(&init_user_ns, attr->gid);
+	stat->uid = make_kuid(fc->user_ns, attr->uid);
+	stat->gid = make_kgid(fc->user_ns, attr->gid);
 	stat->rdev = inode->i_rdev;
 	stat->atime.tv_sec = attr->atime;
 	stat->atime.tv_nsec = attr->atimensec;
@@ -1475,17 +1475,17 @@ static bool update_mtime(unsigned ivalid, bool trust_local_mtime)
 	return true;
 }
 
-static void iattr_to_fattr(struct iattr *iattr, struct fuse_setattr_in *arg,
-			   bool trust_local_cmtime)
+static void iattr_to_fattr(struct fuse_conn *fc, struct iattr *iattr,
+			   struct fuse_setattr_in *arg, bool trust_local_cmtime)
 {
 	unsigned ivalid = iattr->ia_valid;
 
 	if (ivalid & ATTR_MODE)
 		arg->valid |= FATTR_MODE,   arg->mode = iattr->ia_mode;
 	if (ivalid & ATTR_UID)
-		arg->valid |= FATTR_UID,    arg->uid = from_kuid(&init_user_ns, iattr->ia_uid);
+		arg->valid |= FATTR_UID,    arg->uid = from_kuid(fc->user_ns, iattr->ia_uid);
 	if (ivalid & ATTR_GID)
-		arg->valid |= FATTR_GID,    arg->gid = from_kgid(&init_user_ns, iattr->ia_gid);
+		arg->valid |= FATTR_GID,    arg->gid = from_kgid(fc->user_ns, iattr->ia_gid);
 	if (ivalid & ATTR_SIZE)
 		arg->valid |= FATTR_SIZE,   arg->size = iattr->ia_size;
 	if (ivalid & ATTR_ATIME) {
@@ -1646,7 +1646,7 @@ int fuse_do_setattr(struct dentry *dentry, struct iattr *attr,
 
 	memset(&inarg, 0, sizeof(inarg));
 	memset(&outarg, 0, sizeof(outarg));
-	iattr_to_fattr(attr, &inarg, trust_local_cmtime);
+	iattr_to_fattr(fc, attr, &inarg, trust_local_cmtime);
 	if (file) {
 		struct fuse_file *ff = file->private_data;
 		inarg.valid |= FATTR_FH;
diff --git a/fs/fuse/fuse_i.h b/fs/fuse/fuse_i.h
index c4c093bbf456..7772e2b4057e 100644
--- a/fs/fuse/fuse_i.h
+++ b/fs/fuse/fuse_i.h
@@ -26,6 +26,7 @@
 #include <linux/xattr.h>
 #include <linux/pid_namespace.h>
 #include <linux/refcount.h>
+#include <linux/user_namespace.h>
 
 /** Max number of pages that can be used in a single read request */
 #define FUSE_MAX_PAGES_PER_REQ 32
@@ -466,6 +467,9 @@ struct fuse_conn {
 	/** The pid namespace for this mount */
 	struct pid_namespace *pid_ns;
 
+	/** The user namespace for this mount */
+	struct user_namespace *user_ns;
+
 	/** Maximum read size */
 	unsigned max_read;
 
@@ -870,7 +874,7 @@ struct fuse_conn *fuse_conn_get(struct fuse_conn *fc);
 /**
  * Initialize fuse_conn
  */
-void fuse_conn_init(struct fuse_conn *fc);
+void fuse_conn_init(struct fuse_conn *fc, struct user_namespace *user_ns);
 
 /**
  * Release reference to fuse_conn
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index 624f18bbfd2b..e018dc3999f4 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -171,8 +171,8 @@ void fuse_change_attributes_common(struct inode *inode, struct fuse_attr *attr,
 	inode->i_ino     = fuse_squash_ino(attr->ino);
 	inode->i_mode    = (inode->i_mode & S_IFMT) | (attr->mode & 07777);
 	set_nlink(inode, attr->nlink);
-	inode->i_uid     = make_kuid(&init_user_ns, attr->uid);
-	inode->i_gid     = make_kgid(&init_user_ns, attr->gid);
+	inode->i_uid     = make_kuid(fc->user_ns, attr->uid);
+	inode->i_gid     = make_kgid(fc->user_ns, attr->gid);
 	inode->i_blocks  = attr->blocks;
 	inode->i_atime.tv_sec   = attr->atime;
 	inode->i_atime.tv_nsec  = attr->atimensec;
@@ -477,7 +477,8 @@ static int fuse_match_uint(substring_t *s, unsigned int *res)
 	return err;
 }
 
-static int parse_fuse_opt(char *opt, struct fuse_mount_data *d, int is_bdev)
+static int parse_fuse_opt(char *opt, struct fuse_mount_data *d, int is_bdev,
+			  struct user_namespace *user_ns)
 {
 	char *p;
 	memset(d, 0, sizeof(struct fuse_mount_data));
@@ -513,7 +514,7 @@ static int parse_fuse_opt(char *opt, struct fuse_mount_data *d, int is_bdev)
 		case OPT_USER_ID:
 			if (fuse_match_uint(&args[0], &uv))
 				return 0;
-			d->user_id = make_kuid(current_user_ns(), uv);
+			d->user_id = make_kuid(user_ns, uv);
 			if (!uid_valid(d->user_id))
 				return 0;
 			d->user_id_present = 1;
@@ -522,7 +523,7 @@ static int parse_fuse_opt(char *opt, struct fuse_mount_data *d, int is_bdev)
 		case OPT_GROUP_ID:
 			if (fuse_match_uint(&args[0], &uv))
 				return 0;
-			d->group_id = make_kgid(current_user_ns(), uv);
+			d->group_id = make_kgid(user_ns, uv);
 			if (!gid_valid(d->group_id))
 				return 0;
 			d->group_id_present = 1;
@@ -565,8 +566,8 @@ static int fuse_show_options(struct seq_file *m, struct dentry *root)
 	struct super_block *sb = root->d_sb;
 	struct fuse_conn *fc = get_fuse_conn_super(sb);
 
-	seq_printf(m, ",user_id=%u", from_kuid_munged(&init_user_ns, fc->user_id));
-	seq_printf(m, ",group_id=%u", from_kgid_munged(&init_user_ns, fc->group_id));
+	seq_printf(m, ",user_id=%u", from_kuid_munged(fc->user_ns, fc->user_id));
+	seq_printf(m, ",group_id=%u", from_kgid_munged(fc->user_ns, fc->group_id));
 	if (fc->default_permissions)
 		seq_puts(m, ",default_permissions");
 	if (fc->allow_other)
@@ -597,7 +598,7 @@ static void fuse_pqueue_init(struct fuse_pqueue *fpq)
 	fpq->connected = 1;
 }
 
-void fuse_conn_init(struct fuse_conn *fc)
+void fuse_conn_init(struct fuse_conn *fc, struct user_namespace *user_ns)
 {
 	memset(fc, 0, sizeof(*fc));
 	spin_lock_init(&fc->lock);
@@ -621,6 +622,7 @@ void fuse_conn_init(struct fuse_conn *fc)
 	fc->attr_version = 1;
 	get_random_bytes(&fc->scramble_key, sizeof(fc->scramble_key));
 	fc->pid_ns = get_pid_ns(task_active_pid_ns(current));
+	fc->user_ns = get_user_ns(user_ns);
 }
 EXPORT_SYMBOL_GPL(fuse_conn_init);
 
@@ -630,6 +632,7 @@ void fuse_conn_put(struct fuse_conn *fc)
 		if (fc->destroy_req)
 			fuse_request_free(fc->destroy_req);
 		put_pid_ns(fc->pid_ns);
+		put_user_ns(fc->user_ns);
 		fc->release(fc);
 	}
 }
@@ -1061,7 +1064,7 @@ static int fuse_fill_super(struct super_block *sb, void *data, int silent)
 
 	sb->s_flags &= ~(SB_NOSEC | SB_I_VERSION);
 
-	if (!parse_fuse_opt(data, &d, is_bdev))
+	if (!parse_fuse_opt(data, &d, is_bdev, sb->s_user_ns))
 		goto err;
 
 	if (is_bdev) {
@@ -1086,8 +1089,12 @@ static int fuse_fill_super(struct super_block *sb, void *data, int silent)
 	if (!file)
 		goto err;
 
-	if ((file->f_op != &fuse_dev_operations) ||
-	    (file->f_cred->user_ns != &init_user_ns))
+	/*
+	 * Require mount to happen from the same user namespace which
+	 * opened /dev/fuse to prevent potential attacks.
+	 */
+	if (file->f_op != &fuse_dev_operations ||
+	    file->f_cred->user_ns != sb->s_user_ns)
 		goto err_fput;
 
 	fc = kmalloc(sizeof(*fc), GFP_KERNEL);
@@ -1095,7 +1102,7 @@ static int fuse_fill_super(struct super_block *sb, void *data, int silent)
 	if (!fc)
 		goto err_fput;
 
-	fuse_conn_init(fc);
+	fuse_conn_init(fc, sb->s_user_ns);
 	fc->release = fuse_free_conn;
 
 	fud = fuse_dev_alloc(fc);
-- 
2.14.1
