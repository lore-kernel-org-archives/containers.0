From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH review  19/19] vfs: Do not allow escaping from bind mounts.
Date: Thu,  2 Apr 2015 20:56:23 -0500
Message-ID: <1428026183-14879-19-git-send-email-ebiederm__22773.3752145015$1428026554$gmane$org@xmission.com>
References: <87a8yqou41.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87a8yqou41.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Omar Sandoval <osandov-nWWhXC5lh1RBDgjK7y7TUQ@public.gmane.org>, Willy Tarreau <w@1wt.eu>
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
mnt_set_violated is called to:

- mark all mounts that have that dentry as their root as violated

- to mark all children of violated mounts that can no longer reach
  their parents.

- to schedule for unmounting all children of violated mounts that can
  no longer reach their parents.

The children that can't reach their parents are only scheduled for
unmounting because the sleeping namespace_sem can not be taken inside
of __d_move which can not sleep.

This change adds a field to struct mount mnt_pending_umount that is
used to thread the list of pending unmounts through struct mount.  As
there are small but unavioable races between scheduling an unmount and
the possibility of userspace calling umount_tree, umount_tree has been
modified to remove all mounts that are being unmounted from the
pending_umount list.

This closes a hole where it was possible in some circumstances
to follow .. past the root of a bind mount.

Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c    | 29 ++++++++++++++++++++++++++++
 fs/internal.h  |  1 +
 fs/mount.h     |  1 +
 fs/namespace.c | 61 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 92 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index cae4a42c1846..e04e2a23ad00 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2535,6 +2535,26 @@ static void dentry_unlock_for_move(struct dentry *dentry, struct dentry *target)
 	spin_unlock(&dentry->d_lock);
 }
 
+static void mark_violated_mounts(struct dentry *dentry, struct dentry *target)
+{
+	/* Mark all mountroots that are ancestors of dentry
+	 * that do not share a common ancestor with target
+	 *
+	 * This function assumes both dentries are part of a DAG.
+	 */
+	struct dentry *p;
+
+	for (p = dentry->d_parent; !IS_ROOT(p); p = p->d_parent) {
+		if (!d_mountroot(p))
+			continue;
+
+		if (d_ancestor(p, target))
+			break;
+
+		mnt_set_violated(p, dentry);
+	}
+}
+
 /*
  * When switching names, the actual string doesn't strictly have to
  * be preserved in the target - because we're dropping the target
@@ -2569,6 +2589,15 @@ static void __d_move(struct dentry *dentry, struct dentry *target,
 	BUG_ON(d_ancestor(dentry, target));
 	BUG_ON(d_ancestor(target, dentry));
 
+	/* If we are not splicing a dentry, mark mounts which may have
+	 * paths that are no longer able to follow d_parent up to
+	 * mnt_root after this move.
+	 */
+	if (!IS_ROOT(dentry) && !IS_ROOT(target)) {
+		mark_violated_mounts(dentry, target);
+		mark_violated_mounts(target, dentry);
+	}
+
 	dentry_lock_for_move(dentry, target);
 
 	write_seqcount_begin(&dentry->d_seq);
diff --git a/fs/internal.h b/fs/internal.h
index 046767f0042e..2f04050ab32f 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -71,6 +71,7 @@ extern int __mnt_want_write_file(struct file *);
 extern void __mnt_drop_write(struct vfsmount *);
 extern void __mnt_drop_write_file(struct file *);
 
+extern void mnt_set_violated(struct dentry *root, struct dentry *moving);
 /*
  * fs_struct.c
  */
diff --git a/fs/mount.h b/fs/mount.h
index a8be3033e022..0697b23fe417 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -41,6 +41,7 @@ struct mount {
 	union {
 		struct rcu_head mnt_rcu;
 		struct llist_node mnt_llist;
+		struct hlist_node mnt_pending_umount;
 	};
 #ifdef CONFIG_SMP
 	struct mnt_pcp __percpu *mnt_pcp;
diff --git a/fs/namespace.c b/fs/namespace.c
index 5b1b666439ac..c38d299ff26f 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -245,6 +245,7 @@ static struct mount *alloc_vfsmnt(const char *name)
 		mnt->mnt_writers = 0;
 #endif
 
+		INIT_HLIST_NODE(&mnt->mnt_pending_umount);
 		INIT_HLIST_NODE(&mnt->mnt_hash);
 		INIT_LIST_HEAD(&mnt->mnt_child);
 		INIT_LIST_HEAD(&mnt->mnt_mounts);
@@ -1485,6 +1486,7 @@ static void umount_tree(struct mount *mnt, enum umount_tree_flags how)
 	while (!list_empty(&tmp_list)) {
 		bool disconnect;
 		p = list_first_entry(&tmp_list, struct mount, mnt_list);
+		hlist_del_init(&mnt->mnt_pending_umount);
 		list_del_init(&p->mnt_expire);
 		list_del_init(&p->mnt_list);
 		__touch_mnt_namespace(p->mnt_ns);
@@ -1646,6 +1648,65 @@ out_unlock:
 	namespace_unlock();
 }
 
+static HLIST_HEAD(pending_umount);
+static void umount_pending_umounts(struct work_struct *unused)
+{
+	HLIST_HEAD(head);
+
+	namespace_lock();
+	lock_mount_hash();
+
+	hlist_move_list(&pending_umount, &head);
+
+	while (!hlist_empty(&head)) {
+		struct mount *mnt =
+			hlist_entry(head.first, struct mount, mnt_pending_umount);
+		umount_tree(mnt, UMOUNT_CONNECTED);
+	}
+
+	unlock_mount_hash();
+	namespace_unlock();
+}
+
+static DECLARE_WORK(pending_umount_work, umount_pending_umounts);
+
+void mnt_set_violated(struct dentry *root, struct dentry *moving)
+{
+	struct mountroot *mr;
+	struct mount *mnt;
+
+	lock_mount_hash();
+	mr = lookup_mountroot(root);
+	if (!mr)
+		goto out;
+
+	hlist_for_each_entry(mnt, &mr->r_list, mnt_mr_list) {
+		struct mount *child;
+		/* Be wary of this mount */
+		mnt->mnt.mnt_flags |= MNT_VIOLATED;
+
+		list_for_each_entry(child, &mnt->mnt_mounts, mnt_child) {
+			/* Ignore children that will continue to be connected */
+			if ((child->mnt_mountpoint != moving) &&
+			    !d_ancestor(moving, child->mnt_mountpoint))
+				continue;
+
+			/* Deal with mounts loosing the connection to
+			 * their parents
+			 */
+			if (!(child->mnt.mnt_flags & MNT_UMOUNT)) {
+				child->mnt.mnt_flags |= MNT_UNREACHABLE_PARENT;
+				hlist_add_head(&child->mnt_pending_umount, &pending_umount);
+				schedule_work(&pending_umount_work);
+			} else {
+				umount_mnt(child);
+			}
+		}
+	}
+out:
+	unlock_mount_hash();
+}
+
 /* 
  * Is the caller allowed to modify his namespace?
  */
-- 
2.2.1
