From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review 10/13] vfs: Generalize filesystem nodev handling.
Date: Mon, 20 Jun 2016 12:21:27 -0500
Message-ID: <20160620172130.15712-10-ebiederm@xmission.com>
References: <87fus77pns.fsf@x220.int.ebiederm.org>
	<20160620172130.15712-1-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160620172130.15712-1-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Introduce a function may_open_dev that tests MNT_NODEV and a new
superblock flab SB_I_NODEV.  Use this new function in all of the
places where MNT_NODEV was previously tested.

Add the new SB_I_NODEV s_iflag to proc, sysfs, and mqueuefs as those
filesystems should never support device nodes, and a simple superblock
flags makes that very hard to get wrong.  With SB_I_NODEV set if any
device nodes somehow manage to show up on on a filesystem those
device nodes will be unopenable.

Acked-by: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/block_dev.c     | 2 +-
 fs/kernfs/mount.c  | 4 ++--
 fs/namei.c         | 8 +++++++-
 fs/proc/inode.c    | 4 ++--
 include/linux/fs.h | 2 ++
 ipc/mqueue.c       | 2 +-
 6 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 71ccab1d22c6..30b8d568203a 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -1857,7 +1857,7 @@ struct block_device *lookup_bdev(const char *pathname)
 	if (!S_ISBLK(inode->i_mode))
 		goto fail;
 	error = -EACCES;
-	if (path.mnt->mnt_flags & MNT_NODEV)
+	if (!may_open_dev(&path))
 		goto fail;
 	error = -ENOMEM;
 	bdev = bd_acquire(inode);
diff --git a/fs/kernfs/mount.c b/fs/kernfs/mount.c
index 1443df670260..b3d73ad52b22 100644
--- a/fs/kernfs/mount.c
+++ b/fs/kernfs/mount.c
@@ -152,8 +152,8 @@ static int kernfs_fill_super(struct super_block *sb, unsigned long magic)
 	struct dentry *root;
 
 	info->sb = sb;
-	/* Userspace would break if executables appear on sysfs */
-	sb->s_iflags |= SB_I_NOEXEC;
+	/* Userspace would break if executables or devices appear on sysfs */
+	sb->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
 	sb->s_blocksize = PAGE_SIZE;
 	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = magic;
diff --git a/fs/namei.c b/fs/namei.c
index 6a82fb7e2127..757a32725d92 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2881,6 +2881,12 @@ int vfs_create(struct inode *dir, struct dentry *dentry, umode_t mode,
 }
 EXPORT_SYMBOL(vfs_create);
 
+bool may_open_dev(const struct path *path)
+{
+	return !(path->mnt->mnt_flags & MNT_NODEV) &&
+		!(path->mnt->mnt_sb->s_iflags & SB_I_NODEV);
+}
+
 static int may_open(struct path *path, int acc_mode, int flag)
 {
 	struct dentry *dentry = path->dentry;
@@ -2899,7 +2905,7 @@ static int may_open(struct path *path, int acc_mode, int flag)
 		break;
 	case S_IFBLK:
 	case S_IFCHR:
-		if (path->mnt->mnt_flags & MNT_NODEV)
+		if (!may_open_dev(path))
 			return -EACCES;
 		/*FALLTHRU*/
 	case S_IFIFO:
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index f4817efb25a6..a5b2c33745b7 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -466,8 +466,8 @@ int proc_fill_super(struct super_block *s, void *data, int silent)
 	if (!proc_parse_options(data, ns))
 		return -EINVAL;
 
-	/* User space would break if executables appear on proc */
-	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC;
+	/* User space would break if executables or devices appear on proc */
+	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
 	s->s_flags |= MS_NODIRATIME | MS_NOSUID | MS_NOEXEC;
 	s->s_blocksize = 1024;
 	s->s_blocksize_bits = 10;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 9eef64f23a75..e05983170d23 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1327,6 +1327,7 @@ struct mm_struct;
 /* sb->s_iflags */
 #define SB_I_CGROUPWB	0x00000001	/* cgroup-aware writeback enabled */
 #define SB_I_NOEXEC	0x00000002	/* Ignore executables on this fs */
+#define SB_I_NODEV	0x00000004	/* Ignore devices on this fs */
 
 /* sb->s_iflags to limit user namespace mounts */
 #define SB_I_USERNS_VISIBLE		0x00000010 /* fstype already mounted */
@@ -1602,6 +1603,7 @@ extern int vfs_whiteout(struct inode *, struct dentry *);
  */
 extern void inode_init_owner(struct inode *inode, const struct inode *dir,
 			umode_t mode);
+extern bool may_open_dev(const struct path *path);
 /*
  * VFS FS_IOC_FIEMAP helper definitions.
  */
diff --git a/ipc/mqueue.c b/ipc/mqueue.c
index 5bdd50de7d05..0b13ace266f2 100644
--- a/ipc/mqueue.c
+++ b/ipc/mqueue.c
@@ -307,7 +307,7 @@ static int mqueue_fill_super(struct super_block *sb, void *data, int silent)
 	struct inode *inode;
 	struct ipc_namespace *ns = sb->s_fs_info;
 
-	sb->s_iflags |= SB_I_NOEXEC;
+	sb->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
 	sb->s_blocksize = PAGE_SIZE;
 	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = MQUEUE_MAGIC;
-- 
2.8.3
