From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review  4/4] vfs: Do not allow escaping from bind mounts.
Date: Wed, 08 Apr 2015 18:34:12 -0500
Message-ID: <87iod68aa3.fsf_-___36570.22865159$1428536322$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <874moq9oyb.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Wed, 08 Apr 2015 18:31:56 -0500")
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

Rename can move a file or directory outside of a bind mount.  This has
allowed programs with paths below the renamed directory to traverse up
their directory tree to the real root of the filesystem instead of
just the root of their bind mount.

In the presence of such renames limit applications to what the bind
mount intended to reveal by marking mounts that have had dentries
renamed out of them with MNT_VIOLATED, marking mounts that can no
longer walk up to their parent mounts with MNT_UMOUNT_PENDING and then
lazily unmounting such mounts.

All moves go through __d_move so __d_move has been modified to mark
all mounts whose dentries have been moved outside of them.

Once the root dentry of a violated mount has been found a new function
mnt_set_violated is called to mark all mounts that have that dentry as
their root as violated.

The worst case performance of the changes to __d_move is two extra
trip from dentry and target to the root of their respective dentry
trees.

This closes a hole where it was possible in some circumstances to
follow .. past the root of a bind mount.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c    | 65 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/internal.h  |  1 +
 fs/namespace.c | 17 +++++++++++++++
 3 files changed, 81 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 6e68312494ed..7baecba354dd 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2535,6 +2535,56 @@ static void dentry_unlock_for_move(struct dentry *dentry, struct dentry *target)
 	spin_unlock(&dentry->d_lock);
 }
 
+static unsigned d_depth(const struct dentry *dentry)
+{
+	unsigned depth = 0;
+
+	while (!IS_ROOT(dentry)) {
+		dentry = dentry->d_parent;
+		depth++;
+	}
+	return depth;
+}
+
+static const struct dentry *d_common_ancestor(const struct dentry *left,
+					      const struct dentry *right)
+{
+	unsigned ldepth = d_depth(left);
+	unsigned rdepth = d_depth(right);
+
+	if (ldepth > rdepth) {
+		swap(left, right);
+		swap(ldepth, rdepth);
+	}
+
+	while (rdepth > ldepth) {
+		right = right->d_parent;
+		rdepth--;
+	}
+
+	while (right != left) {
+		if (IS_ROOT(right))
+			return NULL;
+		right = right->d_parent;
+		left = left->d_parent;
+	}
+
+	return right;
+}
+
+static void mark_violated_mounts(struct dentry *dentry,
+				 const struct dentry *ancestor)
+{
+	/* Mark all mountroots that are children of the common
+	 * ancestor and ancestors of dentry.
+	 */
+	struct dentry *p;
+	for (p = dentry->d_parent; p != ancestor; p = p->d_parent) {
+		if (d_mountroot(p))
+			mnt_set_violated(p);
+	}
+}
+
 /*
  * When switching names, the actual string doesn't strictly have to
  * be preserved in the target - because we're dropping the target
@@ -2563,11 +2613,22 @@ static void dentry_unlock_for_move(struct dentry *dentry, struct dentry *target)
 static void __d_move(struct dentry *dentry, struct dentry *target,
 		     bool exchange)
 {
+	const struct dentry *ancestor = d_common_ancestor(dentry, target);
+
 	if (!dentry->d_inode)
 		printk(KERN_WARNING "VFS: moving negative dcache entry\n");
 
-	BUG_ON(d_ancestor(dentry, target));
-	BUG_ON(d_ancestor(target, dentry));
+	BUG_ON(dentry == ancestor);
+	BUG_ON(target == ancestor);
+
+	/* If there is a common ancestor, mark mounts which may have
+	 * paths that are no longer able to follow d_parent up to
+	 * mnt_root after this move.
+	 */
+	if (ancestor) {
+		mark_violated_mounts(dentry, ancestor);
+		mark_violated_mounts(target, ancestor);
+	}
 
 	dentry_lock_for_move(dentry, target);
 
diff --git a/fs/internal.h b/fs/internal.h
index 046767f0042e..d6a6cbd1e7a1 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -71,6 +71,7 @@ extern int __mnt_want_write_file(struct file *);
 extern void __mnt_drop_write(struct vfsmount *);
 extern void __mnt_drop_write_file(struct file *);
 
+extern void mnt_set_violated(struct dentry *root);
 /*
  * fs_struct.c
  */
diff --git a/fs/namespace.c b/fs/namespace.c
index 75abc9fcaafa..083d96bdbd60 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1644,6 +1644,23 @@ out_unlock:
 	namespace_unlock();
 }
 
+void mnt_set_violated(struct dentry *root)
+{
+	struct mountroot *mr;
+
+	/* Locking the mount guarantees that root is a mountpoint and
+	 * pushes rcu path walkers onto the slow path.
+	 */
+	lock_mount_hash();
+	mr = lookup_mountroot(root);
+	if (mr) {
+		spin_lock(&root->d_lock);
+		root->d_flags |= DCACHE_MOUNT_VIOLATED;
+		spin_unlock(&root->d_lock);
+	}
+	unlock_mount_hash();
+}
+
 /* 
  * Is the caller allowed to modify his namespace?
  */
-- 
2.2.1
