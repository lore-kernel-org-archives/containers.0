From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH review 2/8] dcache: Reduce the scope of i_lock in
	d_splice_alias
Date: Thu, 13 Aug 2015 23:30:48 -0500
Message-ID: <87lhdejxtz.fsf_-___36205.147059127$1439527080$gmane$org@x220.int.ebiederm.org>
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


i_lock is only needed until __d_find_any_alias calls dget on the alias
dentry.  After that the reference to new ensures that dentry_kill and
d_delete will not remove the inode from the dentry, and remove the
dentry from the inode->d_entry list.

The inode i_lock came to be held over the the __d_move calls in
d_splice_alias through a series of introduction of locks with
increasing smaller scope.  First it was the dcache_lock, then
it was the dcache_inode_lock, and finally inode->i_lock.

Furthermore inode->i_lock is not held over any other calls
to d_move or __d_move so it can not provide any meaningful
rename protection.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/dcache.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index f762e76e85cc..53b7f1e63beb 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2715,7 +2715,7 @@ struct dentry *d_ancestor(struct dentry *p1, struct dentry *p2)
  * This helper attempts to cope with remotely renamed directories
  *
  * It assumes that the caller is already holding
- * dentry->d_parent->d_inode->i_mutex, inode->i_lock and rename_lock
+ * dentry->d_parent->d_inode->i_mutex, and rename_lock
  *
  * Note: If ever the locking in lock_rename() changes, then please
  * remember to update this too...
@@ -2741,7 +2741,6 @@ out_unalias:
 	__d_move(alias, dentry, false);
 	ret = 0;
 out_err:
-	spin_unlock(&inode->i_lock);
 	if (m2)
 		mutex_unlock(m2);
 	if (m1)
@@ -2787,10 +2786,11 @@ struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
 	if (S_ISDIR(inode->i_mode)) {
 		struct dentry *new = __d_find_any_alias(inode);
 		if (unlikely(new)) {
+			/* The reference to new ensures it remains an alias */
+			spin_unlock(&inode->i_lock);
 			write_seqlock(&rename_lock);
 			if (unlikely(d_ancestor(new, dentry))) {
 				write_sequnlock(&rename_lock);
-				spin_unlock(&inode->i_lock);
 				dput(new);
 				new = ERR_PTR(-ELOOP);
 				pr_warn_ratelimited(
@@ -2809,7 +2809,6 @@ struct dentry *d_splice_alias(struct inode *inode, struct dentry *dentry)
 			} else {
 				__d_move(new, dentry, false);
 				write_sequnlock(&rename_lock);
-				spin_unlock(&inode->i_lock);
 				security_d_instantiate(new, inode);
 			}
 			iput(inode);
-- 
2.2.1
