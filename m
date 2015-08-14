From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 3/8] dcache: Clearly separate the two directory rename
	cases in d_splice_alias
Date: Thu, 13 Aug 2015 23:31:47 -0500
Message-ID: <87fv3mjxsc.fsf_-___25441.8045668446$1439527141$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<87egjk9i61.fsf_-_@x220.int.ebiederm.org>
	<20150810043637.GC14139@ZenIV.linux.org.uk>
	<877foymrwt.fsf@x220.int.ebiederm.org>
	<87wpwyjxwc.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87wpwyjxwc.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org> (Eric W. Biederman's
	message of "Thu, 13 Aug 2015 23:29:23 -0500")
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


There are two scenarios that can result in an alias being found in
d_splice_alias.  The first scenario is a disconnected dentry being
looked up and reconnected (common with nfs file handles, and
open_by_handle_at).  The second scenario is a lookup on a directory
lazily discovering that it was renamed on the remote filesystem.

The locking challenge for handling these two scenarios is that
the instance of lookup calling d_splice_alias has already
taken the dentry->d_parent->d_inode->i_mutex.

If the mutex was not held the locking we could just do:
	rename_mutex = &inode->i_sb->s_vfs_rename_mutex;
	mutex_lock(rename_mutex);
	if (d_ancestor(alias, dentry)) {
		mutex_unlock(rename_mutex);
		pr_warn_ratelimited(...);
		return -ELOOP;
	}
	m1 = &dentry->d_parent->d_inode->i_mutex;
	mutex_lock_nested(m1, I_MUTEX_PARENT);
	if (!IS_ROOT(alias) && (alias->d_parent != dentry->d_parent)) {
		m2 = &alias->d_parent->d_inode->i_mutex;
		mutex_lock_nested(m2, I_MUTEX_PARENT2);
	}
	d_move(alias, dentry);
	if (m2)
		mutex_unlock(m2);
	mutex_unlock(m1);
	mutex_unlock(rename_mutex);

Which is essentially lock_rename and unlock_reaname with added
handling of the IS_ROOT case.

The problem is that as the lookup locking stands today grabbing the
s_vfs_rename_mutex must use mutex_trylock which can fail, so for reliability
reasons we need to avoid using the rename_mutex as much as possible.

For the case where a disconnected dentry is being connected (aka the
IS_ROOT case) the d_ancestor test can be placed under the rename_lock
removing any chance that taking locks will cause a failure.

For the lazy rename case things are trickier because when
dentry->d_parent and alias->d_parent are not equal the code need to
take the s_vfs_rename_mutex, or risk the d_ancestor call in
lock_rename being inaccurate.  As s_vfs_rename_mutex is take first
there are no locking ordering issues with taking
alias->d_parent->d_inode->i_mutex.  Furthermore as games with
rename_lock are unnecessary d_move instead of __d_move can be called.

Sleeping in d_splice_alias is not something new as
security_d_instantiate is a sleeping function.

Compared to the current implementation this change introduces a
function for each case __d_rename_alias and __d_connect_alias and
moves the acquisition of rename_lock down into those functions.

In the case of __d_rename_alias which was __d_unalias this allows the
existing lock ordering rules to be followed much more closely removing
the need for a trylock when acquiring
alias->d_parent->d_inode->i_mutex, and allowing the use of d_move.

A common helper that prints the warning message when a loop is
detected is factored out into d_alias_is_ancestor so that code does not
need to be duplicated in both cases.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c | 111 ++++++++++++++++++++++++++++++++++++------------------------
 1 file changed, 67 insertions(+), 44 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 53b7f1e63beb..c1eece74621f 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2711,41 +2711,77 @@ struct dentry *d_ancestor(struct dentry *p1, struct dentry *p2)
 	return NULL;
 }
 
+static struct dentry *d_alias_is_ancestor(struct dentry *alias,
+					  struct dentry *dentry)
+{
+	struct dentry *ancestor = d_ancestor(alias, dentry);
+	if (ancestor) {
+		pr_warn_ratelimited(
+			"VFS: Lookup of '%s' in %s %s would have caused loop\n",
+			dentry->d_name.name,
+			dentry->d_sb->s_type->name,
+			dentry->d_sb->s_id);
+	}
+	return ancestor;
+}
+
 /*
  * This helper attempts to cope with remotely renamed directories
  *
  * It assumes that the caller is already holding
- * dentry->d_parent->d_inode->i_mutex, and rename_lock
+ * dentry->d_parent->d_inode->i_mutex
  *
  * Note: If ever the locking in lock_rename() changes, then please
  * remember to update this too...
  */
-static int __d_unalias(struct inode *inode,
-		struct dentry *dentry, struct dentry *alias)
+static int __d_rename_alias(struct dentry *alias, struct dentry *dentry)
 {
-	struct mutex *m1 = NULL, *m2 = NULL;
-	int ret = -ESTALE;
+	struct mutex *rename_mutex = NULL, *parent_mutex = NULL;
 
-	/* If alias and dentry share a parent, then no extra locks required */
-	if (alias->d_parent == dentry->d_parent)
-		goto out_unalias;
+	/* Holding dentry->d_parent->d_inode->i_mutex guarantees this
+	 * that the equality or inequality alias->d_parent and
+	 * dentry->d_parent remains stable.
+	 */
+	if (alias->d_parent != dentry->d_parent) {
+		/* See lock_rename() */
+		rename_mutex = &dentry->d_sb->s_vfs_rename_mutex;
+		if (!mutex_trylock(rename_mutex))
+			return -ESTALE;
+
+		if (d_alias_is_ancestor(alias, dentry)) {
+			mutex_unlock(rename_mutex);
+			return -ELOOP;
+		}
+		parent_mutex = &alias->d_parent->d_inode->i_mutex;
+		mutex_lock_nested(parent_mutex, I_MUTEX_PARENT2);
+	}
+	d_move(alias, dentry);
+	if (parent_mutex) {
+		mutex_unlock(parent_mutex);
+		mutex_unlock(rename_mutex);
+	}
+	return 0;
+}
 
-	/* See lock_rename() */
-	if (!mutex_trylock(&dentry->d_sb->s_vfs_rename_mutex))
-		goto out_err;
-	m1 = &dentry->d_sb->s_vfs_rename_mutex;
-	if (!mutex_trylock(&alias->d_parent->d_inode->i_mutex))
-		goto out_err;
-	m2 = &alias->d_parent->d_inode->i_mutex;
-out_unalias:
+/*
+ * This helper connects disconnected dentries.
+ *
+ * It assumes that the caller is already holding
+ * dentry->d_parent->d_inode->i_mutex
+ *
+ */
+static int __d_connect_alias(struct inode *inode,
+			     struct dentry *alias, struct dentry *dentry)
+{
+	write_seqlock(&rename_lock);
+	if (unlikely(d_alias_is_ancestor(alias, dentry))) {
+		write_sequnlock(&rename_lock);
+		return -ELOOP;
+	}
 	__d_move(alias, dentry, false);
-	ret = 0;
-out_err:
-	if (m2)
-		mutex_unlock(m2);
-	if (m1)
-		mutex_unlock(m1);
-	return ret;
+	write_sequnlock(&rename_lock);
+	security_d_instantiate(alias, inode);
+	return 0;
 }
 
 /**
@@ -2786,30 +2822,17 @@ struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
 	if (S_ISDIR(inode->i_mode)) {
 		struct dentry *new = __d_find_any_alias(inode);
 		if (unlikely(new)) {
+			int err;
 			/* The reference to new ensures it remains an alias */
 			spin_unlock(&inode->i_lock);
-			write_seqlock(&rename_lock);
-			if (unlikely(d_ancestor(new, dentry))) {
-				write_sequnlock(&rename_lock);
+
+			if (!IS_ROOT(new))
+				err = __d_rename_alias(new, dentry);
+			else
+				err = __d_connect_alias(inode, new, dentry);
+			if (err) {
 				dput(new);
-				new = ERR_PTR(-ELOOP);
-				pr_warn_ratelimited(
-					"VFS: Lookup of '%s' in %s %s"
-					" would have caused loop\n",
-					dentry->d_name.name,
-					inode->i_sb->s_type->name,
-					inode->i_sb->s_id);
-			} else if (!IS_ROOT(new)) {
-				int err = __d_unalias(inode, dentry, new);
-				write_sequnlock(&rename_lock);
-				if (err) {
-					dput(new);
-					new = ERR_PTR(err);
-				}
-			} else {
-				__d_move(new, dentry, false);
-				write_sequnlock(&rename_lock);
-				security_d_instantiate(new, inode);
+				new = ERR_PTR(err);
 			}
 			iput(inode);
 			return new;
-- 
2.2.1
