From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 6/7] mnt: Track when a directory escapes a bind mount
Date: Sat, 15 Aug 2015 13:39:22 -0500
Message-ID: <878u9c5rc5.fsf_-_@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<87egjk9i61.fsf_-_@x220.int.ebiederm.org>
	<20150810043637.GC14139@ZenIV.linux.org.uk>
	<877foymrwt.fsf@x220.int.ebiederm.org>
	<87wpwyjxwc.fsf_-_@x220.int.ebiederm.org>
	<87fv3mjxsc.fsf_-_@x220.int.ebiederm.org>
	<20150815061617.GG14139@ZenIV.linux.org.uk>
	<874mk08l3g.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <874mk08l3g.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Sat, 15 Aug 2015 13:25:55 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


When bind mounts are in use, and there is another path to the
filesystem it is possible to rename files or directories from a path
underneath the root of the bind mount to a path that is not underneath
the root of the bind mount.

When a directory is moved out from under the root of a bind mount path
name lookups that go up the directory tree potentially allow accessing
the entire dentry tree of the filesystem.  This is not expected, not
what is desired and winds up being a secruity problem for userspace.

Augment d_move, d_exchange, and __d_unalias to call d_common_ancestor
and handle_possible_mount_escapes to mark any mount points that
directories escape from.

A few notes on the implementation:

- Only directory escapes are recorded as only those are relevant to
  new pathname lookup.  Escaped files are handled in prepend_path.

- A lock either namespace_sem or mount_lock needs to be held across
  the duration of renames where a directory could be escaping to
  ensure that a mount is not added, escaped, and missed during the
  rename.

- The mount_lock is used as it does not sleep.  I have audited all of
  thecallers of d_move and d_exchange and in every instance it appears
  safe for d_move and d_exchange to start sleeping.  But there is
  no point in adding sleeping behavior if that is unncessary.

- The locking order must be mount_lock outside of rename_lock
  as prepend_path already takes the locks in this order.

- d_splice_alias (which calls __d_unalias) is a painful when it comes
  to this kind of locking, as it mostly takes the spinlocks before the
  sleeping locks.  So I have implmented the suboptimal but stupid and
  correct version of the locking and always take mount_lock.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c           | 40 ++++++++++++++++++++++++++++++++++++++++
 fs/mount.h            |  2 ++
 fs/namespace.c        | 32 ++++++++++++++++++++++++++++++++
 include/linux/mount.h |  1 +
 4 files changed, 75 insertions(+)

diff --git a/fs/dcache.c b/fs/dcache.c
index 4e66bf92a481..ccc7daa0ae71 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2704,9 +2704,23 @@ static void __d_move(struct dentry *dentry, struct dentry *target,
  */
 void d_move(struct dentry *dentry, struct dentry *target)
 {
+	bool unlock = false;
+
+	if (d_is_dir(dentry) && (dentry->d_parent != target->d_parent)) {
+		const struct dentry *ancestor;
+
+		ancestor = d_common_ancestor(dentry, target);
+		read_seqlock_excl(&mount_lock);
+		unlock = true;
+		handle_possible_mount_escapee(ancestor, dentry);
+	}
+
 	write_seqlock(&rename_lock);
 	__d_move(dentry, target, false);
 	write_sequnlock(&rename_lock);
+	if (unlock)
+		read_sequnlock_excl(&mount_lock);
+
 }
 EXPORT_SYMBOL(d_move);
 
@@ -2717,6 +2731,23 @@ EXPORT_SYMBOL(d_move);
  */
 void d_exchange(struct dentry *dentry1, struct dentry *dentry2)
 {
+	bool d1_is_dir = d_is_dir(dentry1);
+	bool d2_is_dir = d_is_dir(dentry2);
+	bool unlock = false;
+
+	if ((d1_is_dir || d2_is_dir) &&
+	    (dentry1->d_parent != dentry2->d_parent)) {
+		const struct dentry *ancestor;
+
+		ancestor = d_common_ancestor(dentry1, dentry2);
+		read_seqlock_excl(&mount_lock);
+		unlock = true;
+		if (d1_is_dir)
+			handle_possible_mount_escapee(ancestor, dentry1);
+		if (d2_is_dir)
+			handle_possible_mount_escapee(ancestor, dentry2);
+	}
+
 	write_seqlock(&rename_lock);
 
 	WARN_ON(!dentry1->d_inode);
@@ -2727,6 +2758,8 @@ void d_exchange(struct dentry *dentry1, struct dentry *dentry2)
 	__d_move(dentry1, dentry2, true);
 
 	write_sequnlock(&rename_lock);
+	if (unlock)
+		read_sequnlock_excl(&mount_lock);
 }
 
 /**
@@ -2761,6 +2794,7 @@ static int __d_unalias(struct inode *inode,
 		struct dentry *dentry, struct dentry *alias)
 {
 	struct mutex *m1 = NULL, *m2 = NULL;
+	const struct dentry *ancestor;
 	int ret = -ESTALE;
 
 	/* If alias and dentry share a parent, then no extra locks required */
@@ -2774,6 +2808,8 @@ static int __d_unalias(struct inode *inode,
 	if (!mutex_trylock(&alias->d_parent->d_inode->i_mutex))
 		goto out_err;
 	m2 = &alias->d_parent->d_inode->i_mutex;
+	ancestor = d_common_ancestor(alias, dentry);
+	handle_possible_mount_escapee(ancestor, alias);
 out_unalias:
 	__d_move(alias, dentry, false);
 	ret = 0;
@@ -2825,9 +2861,11 @@ struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
 		if (unlikely(new)) {
 			/* The reference to new ensures it remains an alias */
 			spin_unlock(&inode->i_lock);
+			read_seqlock_excl(&mount_lock);
 			write_seqlock(&rename_lock);
 			if (unlikely(d_ancestor(new, dentry))) {
 				write_sequnlock(&rename_lock);
+				read_sequnlock_excl(&mount_lock);
 				dput(new);
 				new = ERR_PTR(-ELOOP);
 				pr_warn_ratelimited(
@@ -2839,6 +2877,7 @@ struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
 			} else if (!IS_ROOT(new)) {
 				int err = __d_unalias(inode, dentry, new);
 				write_sequnlock(&rename_lock);
+				read_sequnlock_excl(&mount_lock);
 				if (err) {
 					dput(new);
 					new = ERR_PTR(err);
@@ -2846,6 +2885,7 @@ struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
 			} else {
 				__d_move(new, dentry, false);
 				write_sequnlock(&rename_lock);
+				read_sequnlock_excl(&mount_lock);
 				security_d_instantiate(new, inode);
 			}
 			iput(inode);
diff --git a/fs/mount.h b/fs/mount.h
index e8f22970fe59..ad91963c83ac 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -107,6 +107,8 @@ static inline void detach_mounts(struct dentry *dentry)
 	__detach_mounts(dentry);
 }
 
+extern void handle_possible_mount_escapee(const struct dentry *, struct dentry *);
+
 static inline void get_mnt_ns(struct mnt_namespace *ns)
 {
 	atomic_inc(&ns->count);
diff --git a/fs/namespace.c b/fs/namespace.c
index af6abf476394..ddcd0b61a448 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1657,6 +1657,38 @@ out_unlock:
 	namespace_unlock();
 }
 
+static void mark_escaped_mounts(struct dentry *root)
+{
+	/* Must be called with mount_lock held */
+	struct mountroot *mr;
+	struct mount *mnt;
+
+	mr = lookup_mountroot(root);
+	if (mr) {
+		/* Mark each mount from which a directory is escaping.
+		 */
+		hlist_for_each_entry(mnt, &mr->r_list, mnt_mr_list)
+			mnt->mnt.mnt_flags |= MNT_DIR_ESCAPED;
+	}
+}
+
+void handle_possible_mount_escapee(const struct dentry *ancestor,
+				   struct dentry *escapee)
+{
+	struct dentry *dentry;
+
+	for (dentry = escapee->d_parent; dentry != ancestor;
+	     dentry = dentry->d_parent) {
+
+		if (d_mountroot(dentry))
+			mark_escaped_mounts(dentry);
+
+		/* In case there is no common ancestor */
+		if (IS_ROOT(dentry))
+			break;
+	}
+}
+
 /* 
  * Is the caller allowed to modify his namespace?
  */
diff --git a/include/linux/mount.h b/include/linux/mount.h
index f822c3c11377..e58bc12b19aa 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -62,6 +62,7 @@ struct mnt_namespace;
 #define MNT_SYNC_UMOUNT		0x2000000
 #define MNT_MARKED		0x4000000
 #define MNT_UMOUNT		0x8000000
+#define MNT_DIR_ESCAPED		0x10000000
 
 struct vfsmount {
 	struct dentry *mnt_root;	/* root of the mounted tree */
-- 
2.2.1
