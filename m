From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH] userns: Support fuse interacting with multiple user namespaces
Date: Tue, 30 Oct 2012 23:34:47 -0700
Message-ID: <87objjcfp4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


Use kuid_t and kgid_t in struct fuse_conn and struct fuse_mount_data.

The connection between between a fuse filesystem and a fuse daemon is
established when a fuse filesystem is mounted and provided with a file
descriptor the fuse daemon created by opening /dev/fuse.

For now restrict the communication of uids and gids between the fuse
filesystem and the fuse daemon to the initial user namespace.  Enforce
this by verifying the file descriptor passed to the mount of fuse was
opened in the initial user namespace.  Ensuring the mount happens in
the initial user namespace is not necessary as mounts from non-initial
user namespaces are not yet allowed.

In fuse_req_init_context convert the currrent fsuid and fsgid into the
initial user namespace for the request that will be sent to the fuse
daemon.

In fuse_fill_attr convert the uid and gid passed from the fuse daemon
from the initial user namespace into kuids and kgids.

In iattr_to_fattr called from fuse_setattr convert kuids and kgids
into the uids and gids in the initial user namespace before passing
them to the fuse filesystem.

In fuse_change_attributes_common called from fuse_dentry_revalidate,
fuse_permission, fuse_geattr, and fuse_setattr, and fuse_iget convert
the uid and gid from the fuse daemon into a kuid and a kgid to store
on the fuse inode.

By default fuse mounts are restricted to task whose uid, suid, and
euid matches the fuse user_id and whose gid, sgid, and egid matches
the fuse group id.  Convert the user_id and group_id mount options
into kuids and kgids at mount time, and use uid_eq and gid_eq to
compare the in fuse_allow_task.

Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/fuse/dev.c    |    4 ++--
 fs/fuse/dir.c    |   20 ++++++++++----------
 fs/fuse/fuse_i.h |    4 ++--
 fs/fuse/inode.c  |   23 ++++++++++++++---------
 init/Kconfig     |    1 -
 5 files changed, 28 insertions(+), 24 deletions(-)

diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index 8c23fa7..c163353 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -92,8 +92,8 @@ static void __fuse_put_request(struct fuse_req *req)
 
 static void fuse_req_init_context(struct fuse_req *req)
 {
-	req->in.h.uid = current_fsuid();
-	req->in.h.gid = current_fsgid();
+	req->in.h.uid = from_kuid_munged(&init_user_ns, current_fsuid());
+	req->in.h.gid = from_kgid_munged(&init_user_ns, current_fsgid());
 	req->in.h.pid = current->pid;
 }
 
diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index 324bc08..b7c09f9 100644
--- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -818,8 +818,8 @@ static void fuse_fillattr(struct inode *inode, struct fuse_attr *attr,
 	stat->ino = attr->ino;
 	stat->mode = (inode->i_mode & S_IFMT) | (attr->mode & 07777);
 	stat->nlink = attr->nlink;
-	stat->uid = attr->uid;
-	stat->gid = attr->gid;
+	stat->uid = make_kuid(&init_user_ns, attr->uid);
+	stat->gid = make_kgid(&init_user_ns, attr->gid);
 	stat->rdev = inode->i_rdev;
 	stat->atime.tv_sec = attr->atime;
 	stat->atime.tv_nsec = attr->atimensec;
@@ -1007,12 +1007,12 @@ int fuse_allow_task(struct fuse_conn *fc, struct task_struct *task)
 	rcu_read_lock();
 	ret = 0;
 	cred = __task_cred(task);
-	if (cred->euid == fc->user_id &&
-	    cred->suid == fc->user_id &&
-	    cred->uid  == fc->user_id &&
-	    cred->egid == fc->group_id &&
-	    cred->sgid == fc->group_id &&
-	    cred->gid  == fc->group_id)
+	if (uid_eq(cred->euid, fc->user_id) &&
+	    uid_eq(cred->suid, fc->user_id) &&
+	    uid_eq(cred->uid,  fc->user_id) &&
+	    gid_eq(cred->egid, fc->group_id) &&
+	    gid_eq(cred->sgid, fc->group_id) &&
+	    gid_eq(cred->gid,  fc->group_id))
 		ret = 1;
 	rcu_read_unlock();
 
@@ -1306,9 +1306,9 @@ static void iattr_to_fattr(struct iattr *iattr, struct fuse_setattr_in *arg)
 	if (ivalid & ATTR_MODE)
 		arg->valid |= FATTR_MODE,   arg->mode = iattr->ia_mode;
 	if (ivalid & ATTR_UID)
-		arg->valid |= FATTR_UID,    arg->uid = iattr->ia_uid;
+		arg->valid |= FATTR_UID,    arg->uid = from_kuid(&init_user_ns, iattr->ia_uid);
 	if (ivalid & ATTR_GID)
-		arg->valid |= FATTR_GID,    arg->gid = iattr->ia_gid;
+		arg->valid |= FATTR_GID,    arg->gid = from_kgid(&init_user_ns, iattr->ia_gid);
 	if (ivalid & ATTR_SIZE)
 		arg->valid |= FATTR_SIZE,   arg->size = iattr->ia_size;
 	if (ivalid & ATTR_ATIME) {
diff --git a/fs/fuse/fuse_i.h b/fs/fuse/fuse_i.h
index e24dd74..e105a53 100644
--- a/fs/fuse/fuse_i.h
+++ b/fs/fuse/fuse_i.h
@@ -333,10 +333,10 @@ struct fuse_conn {
 	atomic_t count;
 
 	/** The user id for this mount */
-	uid_t user_id;
+	kuid_t user_id;
 
 	/** The group id for this mount */
-	gid_t group_id;
+	kgid_t group_id;
 
 	/** The fuse mount flags for this mount */
 	unsigned flags;
diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
index f0eda12..73ca6b7 100644
--- a/fs/fuse/inode.c
+++ b/fs/fuse/inode.c
@@ -60,8 +60,8 @@ MODULE_PARM_DESC(max_user_congthresh,
 struct fuse_mount_data {
 	int fd;
 	unsigned rootmode;
-	unsigned user_id;
-	unsigned group_id;
+	kuid_t user_id;
+	kgid_t group_id;
 	unsigned fd_present:1;
 	unsigned rootmode_present:1;
 	unsigned user_id_present:1;
@@ -164,8 +164,8 @@ void fuse_change_attributes_common(struct inode *inode, struct fuse_attr *attr,
 	inode->i_ino     = fuse_squash_ino(attr->ino);
 	inode->i_mode    = (inode->i_mode & S_IFMT) | (attr->mode & 07777);
 	set_nlink(inode, attr->nlink);
-	inode->i_uid     = attr->uid;
-	inode->i_gid     = attr->gid;
+	inode->i_uid     = make_kuid(&init_user_ns, attr->uid);
+	inode->i_gid     = make_kgid(&init_user_ns, attr->gid);
 	inode->i_blocks  = attr->blocks;
 	inode->i_atime.tv_sec   = attr->atime;
 	inode->i_atime.tv_nsec  = attr->atimensec;
@@ -492,14 +492,18 @@ static int parse_fuse_opt(char *opt, struct fuse_mount_data *d, int is_bdev)
 		case OPT_USER_ID:
 			if (match_int(&args[0], &value))
 				return 0;
-			d->user_id = value;
+			d->user_id = make_kuid(current_user_ns(), value);
+			if (!uid_valid(d->user_id))
+				return 0;
 			d->user_id_present = 1;
 			break;
 
 		case OPT_GROUP_ID:
 			if (match_int(&args[0], &value))
 				return 0;
-			d->group_id = value;
+			d->group_id = make_kgid(current_user_ns(), value);
+			if (!gid_valid(d->group_id))
+				return 0;
 			d->group_id_present = 1;
 			break;
 
@@ -540,8 +544,8 @@ static int fuse_show_options(struct seq_file *m, struct dentry *root)
 	struct super_block *sb = root->d_sb;
 	struct fuse_conn *fc = get_fuse_conn_super(sb);
 
-	seq_printf(m, ",user_id=%u", fc->user_id);
-	seq_printf(m, ",group_id=%u", fc->group_id);
+	seq_printf(m, ",user_id=%u", from_kuid_munged(&init_user_ns, fc->user_id));
+	seq_printf(m, ",group_id=%u", from_kgid_munged(&init_user_ns, fc->group_id));
 	if (fc->flags & FUSE_DEFAULT_PERMISSIONS)
 		seq_puts(m, ",default_permissions");
 	if (fc->flags & FUSE_ALLOW_OTHER)
@@ -989,7 +993,8 @@ static int fuse_fill_super(struct super_block *sb, void *data, int silent)
 	if (!file)
 		goto err;
 
-	if (file->f_op != &fuse_dev_operations)
+	if ((file->f_op != &fuse_dev_operations) ||
+	    (file->f_cred->user_ns != &init_user_ns))
 		goto err_fput;
 
 	fc = kmalloc(sizeof(*fc), GFP_KERNEL);
diff --git a/init/Kconfig b/init/Kconfig
index b6369fb..38c1a1d 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1007,7 +1007,6 @@ config UIDGID_CONVERTED
 	depends on CEPH_FS = n
 	depends on CIFS = n
 	depends on CODA_FS = n
-	depends on FUSE_FS = n
 	depends on GFS2_FS = n
 	depends on NCP_FS = n
 	depends on NFSD = n
-- 
1.7.5.4
