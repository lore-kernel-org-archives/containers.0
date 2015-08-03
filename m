From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 4/6] mnt: Track when a directory escapes a bind mount
Date: Mon, 03 Aug 2015 16:27:34 -0500
Message-ID: <87egjk9i61.fsf_-___13338.7941321873$1438637786$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <871tfkawu9.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Mon, 03 Aug 2015 16:25:18 -0500")
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org


When bind mounts are in use, and there is another path to the
filesystem it is possible to rename files or directories from a path
underneath the root of the bind mount to a path that is not underneath
the root of the bind mount.

When a directory is moved out from under the root of a bind mount path
name lookups that go up the directory tree potentially allow accessing
the entire dentry tree of the filesystem.  This is not expected, not
what is desired and winds up being a secruity problem for userspace.

Augment d_move, d_exchange, and __d_unalias with matching calls to
lock_namespace_rename and unlock_namespace_rename, to mark mounts
that directories have escaped from.

A few notes on the implementation:

- The escape count on struct mount must be incremented both before the
  rename and after.  If the count is not incremented before the rename
  it is possible to hit a scenario where the rename happens the code
  walks up the directory tree to somewhere outside of the bind mount
  before the count is touched.  Similary without a count after the
  rename it is possible for the code to look at the escape count
  validate a path is connected before the rename and assume cache the
  escape count, leading to not retesting the path is ok.

- A lock either namespace_sem or mount_lock needs to be held across
  the duration of renames where a directory could be escaping to
  guarantee pairing of the escape_count increments and to ensure
  that a mount is not added, escaped, and missed during the rename.

- The locking order must be mount_lock outside of rename_lock
  as prepend_path already takes the locks in this order.

- I have audited all callers of d_move and d_exchange and in every
  instance it appears safe for d_move and d_exchange to start
  sleeping.  d_splice_alias already sleeps in security_d_instantiate
  so no audit was needed for it to begin sleeping.

  As I can just take mount_lock I don't use that freedom in this
  change, but it can be relevant to small changes to the locking in
  this code.

- The largest change is in d_unalias, where the two cases are split
  apart so they can be handled separately.  In the easy case of a
  rename within the same directory all that is needed is __d_move
  (escaping a mount is impossible in that case).  In the more involved
  case mutexes need to be acquired, and now the spin locks need to be
  dropped so that proper lock aquisition order around __d_move can be
  arranged.

  As I read the code inode->i_lock needs to be held until
  ailas->d_parent->d_parent->i_mutex is taken.  The only case I can
  see that removes an inode from a dentry is d_delete called from a
  path like vfs_unlink.  Those paths all take the parent directories
  inode mutex.  Thus once the parent directories inode mutex is held
  it becomes unnecessary to hold inode->i_lock to ensure the alias
  remains an alias.

  Similarly the rename_lock does not need to be held once the
  s_vfs_rename_mutex is taken.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c    |  46 +++++++++++++++++----
 fs/mount.h     |  18 +++++++++
 fs/namespace.c | 123 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 180 insertions(+), 7 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 9f4de1007a8d..c25ef7ef8e7f 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2707,9 +2707,17 @@ static void __d_move(struct dentry *dentry, struct dentry *target,
  */
 void d_move(struct dentry *dentry, struct dentry *target)
 {
+	const struct dentry *unlock;
+
+	unlock = lock_namespace_rename(dentry, target, false);
+
 	write_seqlock(&rename_lock);
 	__d_move(dentry, target, false);
 	write_sequnlock(&rename_lock);
+
+	if (unlock)
+		unlock_namespace_rename(unlock, dentry, target, false);
+
 }
 EXPORT_SYMBOL(d_move);
 
@@ -2720,6 +2728,10 @@ EXPORT_SYMBOL(d_move);
  */
 void d_exchange(struct dentry *dentry1, struct dentry *dentry2)
 {
+	const struct dentry *unlock;
+
+	unlock = lock_namespace_rename(dentry1, dentry2, true);
+
 	write_seqlock(&rename_lock);
 
 	WARN_ON(!dentry1->d_inode);
@@ -2730,6 +2742,9 @@ void d_exchange(struct dentry *dentry1, struct dentry *dentry2)
 	__d_move(dentry1, dentry2, true);
 
 	write_sequnlock(&rename_lock);
+
+	if (unlock)
+		unlock_namespace_rename(unlock, dentry1, dentry2, true);
 }
 
 /**
@@ -2764,11 +2779,15 @@ static int __d_unalias(struct inode *inode,
 		struct dentry *dentry, struct dentry *alias)
 {
 	struct mutex *m1 = NULL, *m2 = NULL;
-	int ret = -ESTALE;
+	const struct dentry *unlock;
 
 	/* If alias and dentry share a parent, then no extra locks required */
-	if (alias->d_parent == dentry->d_parent)
-		goto out_unalias;
+	if (alias->d_parent == dentry->d_parent) {
+		__d_move(alias, dentry, false);
+		spin_unlock(&inode->i_lock);
+		write_sequnlock(&rename_lock);
+		return 0;
+	}
 
 	/* See lock_rename() */
 	if (!mutex_trylock(&dentry->d_sb->s_vfs_rename_mutex))
@@ -2777,16 +2796,30 @@ static int __d_unalias(struct inode *inode,
 	if (!mutex_trylock(&alias->d_parent->d_inode->i_mutex))
 		goto out_err;
 	m2 = &alias->d_parent->d_inode->i_mutex;
-out_unalias:
+
+	spin_unlock(&inode->i_lock);
+	write_sequnlock(&rename_lock);
+
+	unlock = lock_namespace_rename(alias, dentry, false);
+
+	write_seqlock(&rename_lock);
 	__d_move(alias, dentry, false);
-	ret = 0;
+	write_sequnlock(&rename_lock);
+
+	if (unlock)
+		unlock_namespace_rename(unlock, alias, dentry, false);
+
+	mutex_unlock(m2);
+	mutex_unlock(m1);
+	return 0;
 out_err:
 	spin_unlock(&inode->i_lock);
+	write_sequnlock(&rename_lock);
 	if (m2)
 		mutex_unlock(m2);
 	if (m1)
 		mutex_unlock(m1);
-	return ret;
+	return -ESTALE;
 }
 
 /**
@@ -2841,7 +2874,6 @@ struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
 					inode->i_sb->s_id);
 			} else if (!IS_ROOT(new)) {
 				int err = __d_unalias(inode, dentry, new);
-				write_sequnlock(&rename_lock);
 				if (err) {
 					dput(new);
 					new = ERR_PTR(err);
diff --git a/fs/mount.h b/fs/mount.h
index e8f22970fe59..d32d074cc0d4 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -38,6 +38,7 @@ struct mount {
 	struct mount *mnt_parent;
 	struct dentry *mnt_mountpoint;
 	struct vfsmount mnt;
+	unsigned mnt_escape_count;
 	union {
 		struct rcu_head mnt_rcu;
 		struct llist_node mnt_llist;
@@ -107,6 +108,23 @@ static inline void detach_mounts(struct dentry *dentry)
 	__detach_mounts(dentry);
 }
 
+extern const struct dentry *lock_namespace_rename(struct dentry *, struct dentry *, bool);
+extern void unlock_namespace_rename(const struct dentry *, struct dentry *, struct dentry *, bool);
+
+static inline unsigned read_mnt_escape_count(struct vfsmount *vfsmount)
+{
+	struct mount *mnt = real_mount(vfsmount);
+	unsigned ret = READ_ONCE(mnt->mnt_escape_count);
+	smp_rmb();
+	return ret;
+}
+
+static inline void cache_mnt_escape_count(unsigned *cache, unsigned escape_count)
+{
+	if (likely(escape_count & 1) == 0)
+		*cache = escape_count;
+}
+
 static inline void get_mnt_ns(struct mnt_namespace *ns)
 {
 	atomic_inc(&ns->count);
diff --git a/fs/namespace.c b/fs/namespace.c
index 2ce987af9afa..9faec24f3f23 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1681,6 +1681,129 @@ out_unlock:
 	namespace_unlock();
 }
 
+static void lock_escaped_mounts_begin(struct dentry *root)
+{
+	struct mountroot *mr;
+	struct mount *mnt;
+
+	mr = lookup_mountroot(root);
+	if (mr) {
+		/* Mark each mount from which a directory is escaping.
+		 */
+		hlist_for_each_entry(mnt, &mr->r_list, mnt_mr_list) {
+			/* Don't return to 0 if the couunt wraps */
+			if (unlikely(mnt->mnt_escape_count == (0U - 2)))
+				mnt->mnt_escape_count = 1;
+			else
+				mnt->mnt_escape_count++;
+			smp_wmb();
+		}
+	}
+}
+
+static void lock_escaped_mounts_end(struct dentry *root)
+{
+	struct mountroot *mr;
+	struct mount *mnt;
+
+	mr = lookup_mountroot(root);
+	if (mr) {
+		/* Mark each mount from which a directory is escaping.
+		 */
+		hlist_for_each_entry(mnt, &mr->r_list, mnt_mr_list) {
+			smp_wmb();
+			mnt->mnt_escape_count++;
+		}
+	}
+}
+
+static void handle_mount_escapes_begin(const struct dentry *ancestor,
+				       struct dentry *escapee)
+{
+	struct dentry *dentry;
+
+	/* Don't look for non-directory escapes */
+	if (!d_is_dir(escapee))
+		return;
+
+	for (dentry = escapee->d_parent; dentry != ancestor;
+	     dentry = dentry->d_parent) {
+
+		if (d_mountroot(dentry))
+			lock_escaped_mounts_begin(dentry);
+
+		/* In case there is no common ancestor */
+		if (IS_ROOT(dentry))
+			break;
+	}
+}
+
+static void handle_mount_escapes_end(const struct dentry *ancestor, struct dentry *escapee)
+{
+	struct dentry *dentry;
+
+	/* Don't look for non-directory escapes */
+	if (!d_is_dir(escapee))
+		return;
+
+	for (dentry = escapee->d_parent; dentry != ancestor;
+	     dentry = dentry->d_parent) {
+
+		if (d_mountroot(dentry))
+			lock_escaped_mounts_end(dentry);
+
+		/* In case there is no common ancestor */
+		if (IS_ROOT(dentry))
+			break;
+	}
+	return;
+}
+
+const struct dentry *lock_namespace_rename(struct dentry *dentry1,
+					   struct dentry *dentry2, bool exchange)
+{
+	const struct dentry *ancestor;
+
+	if (dentry1->d_parent == dentry2->d_parent)
+		return NULL;
+
+	if (!d_is_dir(dentry1) && (!exchange || !d_is_dir(dentry2)))
+		return NULL;
+
+	ancestor = d_common_ancestor(dentry1, dentry2);
+
+	read_seqlock_excl(&mount_lock);
+	if (!exchange) {
+		handle_mount_escapes_begin(ancestor, dentry1);
+	} else {
+		handle_mount_escapes_begin(ancestor, dentry1);
+		handle_mount_escapes_begin(ancestor, dentry2);
+	}
+
+	if (ancestor == NULL)
+		ancestor = ERR_PTR(-ENOENT);
+
+	return ancestor;
+}
+
+void unlock_namespace_rename(const struct dentry *ancestor, struct dentry *dentry1,
+			     struct dentry *dentry2, bool exchange)
+{
+	if (!ancestor)
+		return;
+
+	if (ancestor == ERR_PTR(-ENOENT))
+		ancestor = NULL;
+
+	if (!exchange) {
+		handle_mount_escapes_end(ancestor, dentry2);
+	} else {
+		handle_mount_escapes_end(ancestor, dentry2);
+		handle_mount_escapes_end(ancestor, dentry1);
+	}
+	read_sequnlock_excl(&mount_lock);
+}
+
 /* 
  * Is the caller allowed to modify his namespace?
  */
-- 
2.2.1
