From: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 08/14] sysfs: Rewrite sysfs_drop_dentry.
Date: Mon, 20 Aug 2007 21:36:30 +0900
Message-ID: <1187613390255-git-send-email-htejun@gmail.com>
References: <11876133893720-git-send-email-htejun@gmail.com>
Reply-To: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <11876133893720-git-send-email-htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Currently we find the dentry to drop by looking at sd->s_dentry.
We can just as easily accomplish the same task by looking up the
sysfs inode and finding all of the dentries from there, with the
added bonus that we don't need to play with the sysfs_assoc_lock.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/sysfs/dir.c |   53 ++++++++++++++++++++++++++---------------------------
 1 files changed, 26 insertions(+), 27 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index a6b0fb0..6250455 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -565,50 +565,49 @@ void sysfs_remove_one(struct sysfs_addrm_cxt *acxt, struct sysfs_dirent *sd)
  *	Drop dentry for @sd.  @sd must have been unlinked from its
  *	parent on entry to this function such that it can't be looked
  *	up anymore.
- *
- *	@sd->s_dentry which is protected with sysfs_assoc_lock points
- *	to the currently associated dentry but we're not holding a
- *	reference to it and racing with dput().  Grab dcache_lock and
- *	verify dentry before dropping it.  If @sd->s_dentry is NULL or
- *	dput() beats us, no need to bother.
  */
 static void sysfs_drop_dentry(struct sysfs_dirent *sd)
 {
-	struct dentry *dentry = NULL;
 	struct inode *inode;
+	struct dentry *dentry;
+
+	inode = ilookup(sysfs_sb, sd->s_ino);
+	if (!inode)
+		return;
 
-	/* We're not holding a reference to ->s_dentry dentry but the
-	 * field will stay valid as long as sysfs_assoc_lock is held.
+	/* Drop any existing dentries associated with sd.
+	 *
+	 * For the dentry to be properly freed we need to grab a
+	 * reference to the dentry under the dcache lock,  unhash it,
+	 * and then put it.  The playing with the dentry count allows
+	 * dput to immediately free the dentry  if it is not in use.
 	 */
-	spin_lock(&sysfs_assoc_lock);
+repeat:
 	spin_lock(&dcache_lock);
-
-	/* drop dentry if it's there and dput() didn't kill it yet */
-	if (sd->s_dentry && sd->s_dentry->d_inode) {
-		dentry = dget_locked(sd->s_dentry);
+	list_for_each_entry(dentry, &inode->i_dentry, d_alias) {
+		if (d_unhashed(dentry))
+			continue;
+		dget_locked(dentry);
 		spin_lock(&dentry->d_lock);
 		__d_drop(dentry);
 		spin_unlock(&dentry->d_lock);
+		spin_unlock(&dcache_lock);
+		dput(dentry);
+		goto repeat;
 	}
-
 	spin_unlock(&dcache_lock);
-	spin_unlock(&sysfs_assoc_lock);
-
-	dput(dentry);
 
 	/* adjust nlink and update timestamp */
-	inode = ilookup(sysfs_sb, sd->s_ino);
-	if (inode) {
-		mutex_lock(&inode->i_mutex);
+	mutex_lock(&inode->i_mutex);
 
-		inode->i_ctime = CURRENT_TIME;
+	inode->i_ctime = CURRENT_TIME;
+	drop_nlink(inode);
+	if (sysfs_type(sd) == SYSFS_DIR)
 		drop_nlink(inode);
-		if (sysfs_type(sd) == SYSFS_DIR)
-			drop_nlink(inode);
 
-		mutex_unlock(&inode->i_mutex);
-		iput(inode);
-	}
+	mutex_unlock(&inode->i_mutex);
+
+	iput(inode);
 }
 
 /**
-- 
1.5.0.3
