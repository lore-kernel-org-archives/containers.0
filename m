From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 10/25] sysfs: Rewrite sysfs_get_dentry in terms of
	__sysfs_get_dentry
Date: Tue, 07 Aug 2007 15:18:27 -0600
Message-ID: <m1y7gnhwm4.fsf_-_@ebiederm.dsl.xmission.com>
References: <11860582832964-git-send-email-htejun@gmail.com>
	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>
	<m11wefkq88.fsf_-_@ebiederm.dsl.xmission.com>
	<m1wsw7jbml.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl6vjbjw.fsf_-_@ebiederm.dsl.xmission.com>
	<m1odhjjbij.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5s7jbh9.fsf_-_@ebiederm.dsl.xmission.com>
	<m1fy2vjbf9.fsf_-_@ebiederm.dsl.xmission.com>
	<m1bqdjjbcf.fsf_-_@ebiederm.dsl.xmission.com>
	<m17io7jba4.fsf_-_@ebiederm.dsl.xmission.com>
	<m13ayvjb82.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m13ayvjb82.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 07 Aug 2007 15:17:33 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, gregkh-l3A5Bk7waGM@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, satyam-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, cornelia.huck-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


This removes the last major user of s_dentry and makes
the locking in sysfs_get_dentry much simpler.  Hopefully
leading to more readable and maintainable code.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/dir.c |   23 ++++++-----------------
 1 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 59a9ce8..adb1b01 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -809,19 +809,15 @@ struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
 	struct dentry *parent_dentry, *dentry;
 	int i, depth;
 
-	/* Find the first parent which has valid s_dentry and get the
-	 * dentry.
+	/* Find the first parent which has valid dentry.
 	 */
 	mutex_lock(&sysfs_mutex);
- restart0:
-	spin_lock(&sysfs_assoc_lock);
- restart1:
-	spin_lock(&dcache_lock);
+ restart:
 
 	dentry = NULL;
 	depth = 0;
 	cur = sd;
-	while (!cur->s_dentry || !cur->s_dentry->d_inode) {
+	while (!(dentry = __sysfs_get_dentry(sysfs_sb, cur))) {
 		if (cur->s_flags & SYSFS_FLAG_REMOVED) {
 			dentry = ERR_PTR(-ENOENT);
 			depth = 0;
@@ -830,11 +826,6 @@ struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
 		cur = cur->s_parent;
 		depth++;
 	}
-	if (!IS_ERR(dentry))
-		dentry = dget_locked(cur->s_dentry);
-
-	spin_unlock(&dcache_lock);
-	spin_unlock(&sysfs_assoc_lock);
 
 	/* from the found dentry, look up depth times */
 	while (depth--) {
@@ -847,7 +838,7 @@ struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
 		 */
 		if (i != depth) {
 			dput(dentry);
-			goto restart0;
+			goto restart;
 		}
 
 		sysfs_get(cur);
@@ -866,18 +857,16 @@ struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
 		}
 
 		mutex_lock(&sysfs_mutex);
-		spin_lock(&sysfs_assoc_lock);
 
 		/* This, again, can happen if tree structure has
 		 * changed and we looked up the wrong thing.  Restart.
 		 */
-		if (cur->s_dentry != dentry) {
+		if (dentry->d_fsdata != cur) {
 			dput(dentry);
 			sysfs_put(cur);
-			goto restart1;
+			goto restart;
 		}
 
-		spin_unlock(&sysfs_assoc_lock);
 
 		sysfs_put(cur);
 	}
-- 
1.5.1.1.181.g2de0
