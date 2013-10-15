From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [REVIEW][PATCH 4/4] vfs: Lazily remove mounts on unlinked files and
	directories. v2
Date: Tue, 15 Oct 2013 13:18:36 -0700
Message-ID: <87vc0ywan7.fsf_-_@xmission.com>
References: <8761v7h2pt.fsf@tw-ebiederman.twitter.com>
	<CAJfpegtT7y-1HhbEVAMKkdQugTG_w7G_epGtQHGvQLpcZB5FVA@mail.gmail.com>
	<87li281wx6.fsf_-_@xmission.com> <87a9ioo37a.fsf_-_@xmission.com>
	<20131007043919.GB10284@mail.hallyn.com> <87vc191sf2.fsf@xmission.com>
	<CALCETrUaubASZyeoNZcYxn5-GJO68=Ng=GYmas7K_OBsjM7f0Q@mail.gmail.com>
	<87d2ngyb02.fsf@xmission.com>
	<20131008160601.GJ14242@tucsk.piliscsaba.szeredi.hu>
	<CALCETrWw=htmgxqq=RQztdJQ-a8c3860vmJh9Ni=Hhs0TkO3YA@mail.gmail.com>
	<20131008161135.GK14242@tucsk.piliscsaba.szeredi.hu>
	<87li23trll.fsf@tw-ebiederman.twitter.com>
	<CAJfpegv+h7xh_2e-X7is9dq1Fp06A0eKwsyWFMPX=azbbDCX5Q@mail.gmail.com>
	<87vc15mjuw.fsf@xmission.com>
	<CAJfpegvF89LzAvNB0h0otv7sKoS3rewZzQKAauQx3P+rCkCcSg@mail.gmail.com>
	<87iox38fkv.fsf@xmission.com> <87d2nb8dxy.fsf@xmission.com>
	<87iowyxpci.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87iowyxpci.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Tue, 15 Oct 2013 13:15:41 -0700")
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Linux-Fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Matthias Schniedermeyer <ms-QGhoYOTWWTg@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org


With the introduction of mount namespaces and bind mounts it became
possible to access files and directories that on some paths are mount
points but are not mount points on other paths.  It is very confusing
when rm -rf somedir returns -EBUSY simply because somedir is mounted
somewhere else.  With the addition of user namespaces allowing
unprivileged mounts this condition has gone from annoying to allowing
a DOS attack on other users in the system.

The possibility for mischief is removed by updating the vfs to support
rename, unlink and rmdir on a dentry that is a mountpoint and by
lazily unmounting mountpoints on deleted dentries.

In particular this change allows rename, unlink and rmdir system calls
on a dentry without a mountpoint in the current mount namespace to
succeed, and it allows rename, unlink, and rmdir performed on a
distributed filesystem to update the vfs cache even if when there is a
mount in some namespace on the original dentry.

There are two common patterns of maintaining mounts: Mounts on trusted
paths with the parent directory of the mount point and all ancestory
directories up to / owned by root and modifiable only by root
(i.e. /media/xxx, /dev, /dev/pts, /proc, /sys, /sys/fs/cgroup/{cpu,
cpuacct, ...}, /usr, /usr/local).  Mounts on unprivileged directories
maintained by fusermount.

In the case of mounts in trusted directories owned by root and
modifiable only by root the current parent directory permissions are
sufficient to ensure a mount point on a trusted path is not removed
or renamed by anyone other than root, even if there is a context
where the there are no mount points to prevent this.

In the case of mounts in directories owned by less privileged users
races with users modifying the path of a mount point are already a
danger.  fusermount already uses a combination of chdir,
/proc/<pid>/fd/NNN, and UMOUNT_NOFOLLOW to prevent these races.  The
removable of global rename, unlink, and rmdir protection really adds
nothing new to consider only a widening of the attack window, and
fusermount is already safe against unprivileged users modifying the
directory simultaneously.

In principle for perfect userspace programs returning -EBUSY for
unlink, rmdir, and rename of dentires that have mounts in the local
namespace is actually unnecessary.  Unfortunately not all userspace
programs are perfect so retaining -EBUSY for unlink, rmdir and rename
of dentries that have mounts in the current mount namespace plays an
important role of maintaining consistency with historical behavior and
making imperfect userspace applications hard to exploit.

v2: Remove spurious old_dentry.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/afs/dir.c           |    3 +-
 fs/dcache.c            |   80 ++++++++++++++++++++----------------------------
 fs/fuse/dir.c          |    3 +-
 fs/gfs2/dentry.c       |    4 +--
 fs/namei.c             |   30 ++++++------------
 fs/nfs/dir.c           |    5 +--
 fs/sysfs/dir.c         |    9 +-----
 include/linux/dcache.h |    3 +-
 8 files changed, 50 insertions(+), 87 deletions(-)

diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index 646337dc5201..7fb69d45f1b9 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -686,8 +686,7 @@ not_found:
 
 out_bad:
 	/* don't unhash if we have submounts */
-	if (check_submounts_and_drop(dentry) != 0)
-		goto out_skip;
+	shrink_submounts_and_drop(dentry);
 
 	_debug("dropping dentry %s/%s",
 	       parent->d_name.name, dentry->d_name.name);
diff --git a/fs/dcache.c b/fs/dcache.c
index 41000305d716..1e9bf96b0132 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1373,7 +1373,7 @@ int d_set_mounted(struct dentry *dentry)
 	int ret = -ENOENT;
 	write_seqlock(&rename_lock);
 	for (p = dentry->d_parent; !IS_ROOT(p); p = p->d_parent) {
-		/* Need exclusion wrt. check_submounts_and_drop() */
+		/* Need exclusion wrt. shrink_submounts_and_drop() */
 		spin_lock(&p->d_lock);
 		if (unlikely(d_unhashed(p))) {
 			spin_unlock(&p->d_lock);
@@ -1478,70 +1478,56 @@ void shrink_dcache_parent(struct dentry *parent)
 }
 EXPORT_SYMBOL(shrink_dcache_parent);
 
-static enum d_walk_ret check_and_collect(void *_data, struct dentry *dentry)
+struct detach_data {
+	struct dentry *found;
+};
+static enum d_walk_ret do_detach_submounts(void *ptr, struct dentry *dentry)
 {
-	struct select_data *data = _data;
-
-	if (d_mountpoint(dentry)) {
-		data->found = -EBUSY;
-		return D_WALK_QUIT;
-	}
-
-	return select_collect(_data, dentry);
-}
+	struct detach_data *data = ptr;
 
-static void check_and_drop(void *_data)
-{
-	struct select_data *data = _data;
+	if (d_mountpoint(dentry))
+		data->found = dentry;
 
-	if (d_mountpoint(data->start))
-		data->found = -EBUSY;
-	if (!data->found)
-		__d_drop(data->start);
+	return data->found ? D_WALK_QUIT : D_WALK_CONTINUE;
 }
 
 /**
- * check_submounts_and_drop - prune dcache, check for submounts and drop
+ * detach_submounts - check for submounts and detach them.
  *
- * All done as a single atomic operation relative to has_unlinked_ancestor().
- * Returns 0 if successfully unhashed @parent.  If there were submounts then
- * return -EBUSY.
+ * @dentry: dentry to find mount points under.
  *
- * @dentry: dentry to prune and drop
+ * If dentry or any of it's children is a mount point detach those mounts.
  */
-int check_submounts_and_drop(struct dentry *dentry)
+void detach_submounts(struct dentry *dentry)
 {
-	int ret = 0;
-
-	/* Negative dentries can be dropped without further checks */
-	if (!dentry->d_inode) {
-		d_drop(dentry);
-		goto out;
-	}
-
+	struct detach_data data;
 	for (;;) {
-		struct select_data data;
-
-		INIT_LIST_HEAD(&data.dispose);
-		data.start = dentry;
-		data.found = 0;
+		data.found = NULL;
+		d_walk(dentry, &data, do_detach_submounts, NULL);
 
-		d_walk(dentry, &data, check_and_collect, check_and_drop);
-		ret = data.found;
-
-		if (!list_empty(&data.dispose))
-			shrink_dentry_list(&data.dispose);
-
-		if (ret <= 0)
+		if (!data.found)
 			break;
 
+		detach_mounts(data.found);
 		cond_resched();
 	}
+	detach_mounts(dentry);
+}
 
-out:
-	return ret;
+/**
+ * shrink_submounts_and_drop - detach submounts, prune dcache, and drop
+ *
+ * All done as a single atomic operation reletaive to d_set_mounted().
+ *
+ * @dentry: dentry to detach, prune and drop
+ */
+void shrink_submounts_and_drop(struct dentry *dentry)
+{
+	d_drop(dentry);
+	detach_submounts(dentry);
+	shrink_dcache_parent(dentry);
 }
-EXPORT_SYMBOL(check_submounts_and_drop);
+EXPORT_SYMBOL(shrink_submounts_and_drop);
 
 /**
  * __d_alloc	-	allocate a dcache entry
diff --git a/fs/fuse/dir.c b/fs/fuse/dir.c
index 62b43b577bfc..b1cd7b79a325 100644
--- a/fs/fuse/dir.c
+++ b/fs/fuse/dir.c
@@ -259,8 +259,7 @@ out:
 
 invalid:
 	ret = 0;
-	if (check_submounts_and_drop(entry) != 0)
-		ret = 1;
+	shrink_submounts_and_drop(entry);
 	goto out;
 }
 
diff --git a/fs/gfs2/dentry.c b/fs/gfs2/dentry.c
index d3a5d4e29ba5..2ecc2b873829 100644
--- a/fs/gfs2/dentry.c
+++ b/fs/gfs2/dentry.c
@@ -93,9 +93,7 @@ invalid_gunlock:
 	if (!had_lock)
 		gfs2_glock_dq_uninit(&d_gh);
 invalid:
-	if (check_submounts_and_drop(dentry) != 0)
-		goto valid;
-
+	shrink_submounts_and_drop(dentry);
 	dput(parent);
 	return 0;
 
diff --git a/fs/namei.c b/fs/namei.c
index df7bd6e9c7b6..a12c1d31d4c8 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3574,10 +3574,6 @@ int vfs_rmdir(struct inode *dir, struct dentry *dentry)
 	dget(dentry);
 	mutex_lock(&dentry->d_inode->i_mutex);
 
-	error = -EBUSY;
-	if (d_mountpoint(dentry))
-		goto out;
-
 	error = security_inode_rmdir(dir, dentry);
 	if (error)
 		goto out;
@@ -3589,6 +3585,7 @@ int vfs_rmdir(struct inode *dir, struct dentry *dentry)
 
 	dentry->d_inode->i_flags |= S_DEAD;
 	dont_mount(dentry);
+	detach_mounts(dentry);
 
 out:
 	mutex_unlock(&dentry->d_inode->i_mutex);
@@ -3674,14 +3671,12 @@ int vfs_unlink(struct inode *dir, struct dentry *dentry)
 		return -EPERM;
 
 	mutex_lock(&dentry->d_inode->i_mutex);
-	if (d_mountpoint(dentry))
-		error = -EBUSY;
-	else {
-		error = security_inode_unlink(dir, dentry);
+	error = security_inode_unlink(dir, dentry);
+	if (!error) {
+		error = dir->i_op->unlink(dir, dentry);
 		if (!error) {
-			error = dir->i_op->unlink(dir, dentry);
-			if (!error)
-				dont_mount(dentry);
+			dont_mount(dentry);
+			detach_mounts(dentry);
 		}
 	}
 	mutex_unlock(&dentry->d_inode->i_mutex);
@@ -4008,10 +4003,6 @@ static int vfs_rename_dir(struct inode *old_dir, struct dentry *old_dentry,
 	if (target)
 		mutex_lock(&target->i_mutex);
 
-	error = -EBUSY;
-	if (d_mountpoint(old_dentry) || d_mountpoint(new_dentry))
-		goto out;
-
 	error = -EMLINK;
 	if (max_links && !target && new_dir != old_dir &&
 	    new_dir->i_nlink >= max_links)
@@ -4026,6 +4017,7 @@ static int vfs_rename_dir(struct inode *old_dir, struct dentry *old_dentry,
 	if (target) {
 		target->i_flags |= S_DEAD;
 		dont_mount(new_dentry);
+		detach_mounts(new_dentry);
 	}
 out:
 	if (target)
@@ -4051,16 +4043,14 @@ static int vfs_rename_other(struct inode *old_dir, struct dentry *old_dentry,
 	if (target)
 		mutex_lock(&target->i_mutex);
 
-	error = -EBUSY;
-	if (d_mountpoint(old_dentry)||d_mountpoint(new_dentry))
-		goto out;
-
 	error = old_dir->i_op->rename(old_dir, old_dentry, new_dir, new_dentry);
 	if (error)
 		goto out;
 
-	if (target)
+	if (target) {
 		dont_mount(new_dentry);
+		detach_mounts(new_dentry);
+	}
 	if (!(old_dir->i_sb->s_type->fs_flags & FS_RENAME_DOES_D_MOVE))
 		d_move(old_dentry, new_dentry);
 out:
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 854a8f05a610..e8e35acd8850 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1142,10 +1142,7 @@ out_zap_parent:
 		if (dentry->d_flags & DCACHE_DISCONNECTED)
 			goto out_valid;
 	}
-	/* If we have submounts, don't unhash ! */
-	if (check_submounts_and_drop(dentry) != 0)
-		goto out_valid;
-
+	shrink_submounts_and_drop(dentry);
 	dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%s/%s) is invalid\n",
 			__func__, dentry->d_parent->d_name.name,
diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 4d83cedb9fcb..477c66d4e2a8 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -327,7 +327,6 @@ static int sysfs_dentry_revalidate(struct dentry *dentry, unsigned int flags)
 	}
 
 	mutex_unlock(&sysfs_mutex);
-out_valid:
 	return 1;
 out_bad:
 	/* Remove the dentry from the dcache hashes.
@@ -341,13 +340,7 @@ out_bad:
 	 * to the dcache hashes.
 	 */
 	mutex_unlock(&sysfs_mutex);
-
-	/* If we have submounts we must allow the vfs caches
-	 * to lie about the state of the filesystem to prevent
-	 * leaks and other nasty things.
-	 */
-	if (check_submounts_and_drop(dentry) != 0)
-		goto out_valid;
+	shrink_submounts_and_drop(dentry);
 
 	return 0;
 }
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 59066e0b4ff1..17948b49f3d5 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -254,7 +254,8 @@ extern void d_prune_aliases(struct inode *);
 
 /* test whether we have any submounts in a subdir tree */
 extern int have_submounts(struct dentry *);
-extern int check_submounts_and_drop(struct dentry *);
+extern void detach_submounts(struct dentry *dentry);
+extern void shrink_submounts_and_drop(struct dentry *);
 
 /*
  * This adds the entry to the hash queues.
-- 
1.7.5.4
