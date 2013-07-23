From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH] vfs: Lock in place mounts from more privileged users
Date: Tue, 23 Jul 2013 11:30:29 -0700
Message-ID: <877gghruwq.fsf@xmission.com>
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
To: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


When creating a less privileged mount namespace or propogating mounts
from a more privileged to a less privileged mount namespace lock the
submounts so they may not be unmounted individually in the child mount
namespace revealing what is under them.

This enforces the reasonable expectation that it is not possible to
see under a mount point.  Most of the time mounts are on empty
directories and revealing that does not matter, however I have seen an
occassionaly sloppy configuration where there were interesting things
concealed under a mount point that probably should not be revealed.

Expirable submounts are not locked because they will eventually
unmount automatically so whatever is under them already needs
to be safe for unprivileged users to access.

From a practical standpoint these restrictions do not appear to be
significant for unprivileged users of the mount namespace.  Recursive
bind mounts and pivot_root continues to work, and mounts that are
created in a mount namespace may be unmounted there.  All of which
means that the common idiom of keeping a directory of interesting
files and using pivot_root to throw everything else away continues to
work just fine.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/namespace.c        |   34 ++++++++++++++++++++++++++++++++++
 include/linux/mount.h |    1 +
 2 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 7b1ca9b..7e16a73 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -831,6 +831,10 @@ static struct mount *clone_mnt(struct mount *old, struct dentry *root,
 	if ((flag & CL_UNPRIVILEGED) && (mnt->mnt.mnt_flags & MNT_READONLY))
 		mnt->mnt.mnt_flags |= MNT_LOCK_READONLY;
 
+	/* Don't allow unprivileged users to reveal what is under a mount */
+	if ((flag & CL_UNPRIVILEGED) && list_empty(&old->mnt_expire))
+		mnt->mnt.mnt_flags |= MNT_LOCKED;
+
 	atomic_inc(&sb->s_active);
 	mnt->mnt.mnt_sb = sb;
 	mnt->mnt.mnt_root = dget(root);
@@ -1327,6 +1331,8 @@ SYSCALL_DEFINE2(umount, char __user *, name, int, flags)
 		goto dput_and_out;
 	if (!check_mnt(mnt))
 		goto dput_and_out;
+	if (mnt->mnt.mnt_flags & MNT_LOCKED)
+		goto dput_and_out;
 
 	retval = do_umount(mnt, flags);
 dput_and_out:
@@ -1381,6 +1387,7 @@ struct mount *copy_tree(struct mount *mnt, struct dentry *dentry,
 	if (IS_ERR(q))
 		return q;
 
+	q->mnt.mnt_flags &= ~MNT_LOCKED;
 	q->mnt_mountpoint = mnt->mnt_mountpoint;
 
 	p = mnt;
@@ -1696,6 +1703,19 @@ static int do_change_type(struct path *path, int flag)
 	return err;
 }
 
+static bool has_locked_children(struct mount *mnt, struct dentry *dentry)
+{
+	struct mount *child;
+	list_for_each_entry(child, &mnt->mnt_mounts, mnt_child) {
+		if (!is_subdir(child->mnt_mountpoint, dentry))
+			continue;
+
+		if (child->mnt.mnt_flags & MNT_LOCKED)
+			return true;
+	}
+	return false;
+}
+
 /*
  * do loopback mount.
  */
@@ -1731,6 +1751,9 @@ static int do_loopback(struct path *path, const char *old_name,
 	if (!check_mnt(parent) || !check_mnt(old))
 		goto out2;
 
+	if (!recurse && has_locked_children(old, old_path.dentry))
+		goto out2;
+
 	if (recurse)
 		mnt = copy_tree(old, old_path.dentry, 0);
 	else
@@ -1741,6 +1764,8 @@ static int do_loopback(struct path *path, const char *old_name,
 		goto out2;
 	}
 
+	mnt->mnt.mnt_flags &= ~MNT_LOCKED;
+
 	err = graft_tree(mnt, parent, mp);
 	if (err) {
 		br_write_lock(&vfsmount_lock);
@@ -1853,6 +1878,9 @@ static int do_move_mount(struct path *path, const char *old_name)
 	if (!check_mnt(p) || !check_mnt(old))
 		goto out1;
 
+	if (old->mnt.mnt_flags & MNT_LOCKED)
+		goto out1;
+
 	err = -EINVAL;
 	if (old_path.dentry != old_path.mnt->mnt_root)
 		goto out1;
@@ -2630,6 +2658,8 @@ SYSCALL_DEFINE2(pivot_root, const char __user *, new_root,
 		goto out4;
 	if (!check_mnt(root_mnt) || !check_mnt(new_mnt))
 		goto out4;
+	if (new_mnt->mnt.mnt_flags & MNT_LOCKED)
+		goto out4;
 	error = -ENOENT;
 	if (d_unlinked(new.dentry))
 		goto out4;
@@ -2653,6 +2683,10 @@ SYSCALL_DEFINE2(pivot_root, const char __user *, new_root,
 	br_write_lock(&vfsmount_lock);
 	detach_mnt(new_mnt, &parent_path);
 	detach_mnt(root_mnt, &root_parent);
+	if (root_mnt->mnt.mnt_flags & MNT_LOCKED) {
+		new_mnt->mnt.mnt_flags |= MNT_LOCKED;
+		root_mnt->mnt.mnt_flags &= ~MNT_LOCKED;
+	}
 	/* mount old root on put_old */
 	attach_mnt(root_mnt, old_mnt, old_mp);
 	/* mount new_root on / */
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 73005f9..38cd98f 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -48,6 +48,7 @@ struct mnt_namespace;
 #define MNT_INTERNAL	0x4000
 
 #define MNT_LOCK_READONLY	0x400000
+#define MNT_LOCKED		0x800000
 
 struct vfsmount {
 	struct dentry *mnt_root;	/* root of the mounted tree */
-- 
1.7.5.4
