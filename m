From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 13/25] sysfs: Simply sysfs_get_dentry
Date: Tue, 07 Aug 2007 15:22:13 -0600
Message-ID: <m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com>
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
	<m1y7gnhwm4.fsf_-_@ebiederm.dsl.xmission.com>
	<m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ps1zhwhp.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ps1zhwhp.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 07 Aug 2007 15:21:06 -0600")
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


Now that we know the sysfs tree structure cannot change under us
simplfy sysfs_get_dentry.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/dir.c |   48 ++++++------------------------------------------
 1 files changed, 6 insertions(+), 42 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index e0f49b7..a9bdb12 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -784,71 +784,35 @@ struct dentry *sysfs_get_dentry(struct sysfs_dirent *sd)
 {
 	struct sysfs_dirent *cur;
 	struct dentry *parent_dentry, *dentry;
-	int i, depth;
 
 	/* Find the first parent which has valid dentry.
 	 */
-	mutex_lock(&sysfs_mutex);
- restart:
-
 	dentry = NULL;
-	depth = 0;
 	cur = sd;
 	while (!(dentry = __sysfs_get_dentry(sysfs_sb, cur))) {
 		if (cur->s_flags & SYSFS_FLAG_REMOVED) {
 			dentry = ERR_PTR(-ENOENT);
-			depth = 0;
 			break;
 		}
 		cur = cur->s_parent;
-		depth++;
 	}
 
 	/* from the found dentry, look up depth times */
-	while (depth--) {
-		/* find and get depth'th ancestor */
-		for (cur = sd, i = 0; cur && i < depth; i++)
+	while (dentry->d_fsdata != sd) {
+		/* Find the first ancestor I have not looked up */
+		cur = sd;
+		while (cur->s_parent != dentry->d_fsdata)
 			cur = cur->s_parent;
 
-		/* This can happen if tree structure was modified due
-		 * to move/rename.  Restart.
-		 */
-		if (i != depth) {
-			dput(dentry);
-			goto restart;
-		}
-
-		sysfs_get(cur);
-
-		mutex_unlock(&sysfs_mutex);
-
 		/* look it up */
 		parent_dentry = dentry;
 		dentry = lookup_one_len_kern(cur->s_name, parent_dentry,
 					     strlen(cur->s_name));
 		dput(parent_dentry);
 
-		if (IS_ERR(dentry)) {
-			sysfs_put(cur);
-			return dentry;
-		}
-
-		mutex_lock(&sysfs_mutex);
-
-		/* This, again, can happen if tree structure has
-		 * changed and we looked up the wrong thing.  Restart.
-		 */
-		if (dentry->d_fsdata != cur) {
-			dput(dentry);
-			sysfs_put(cur);
-			goto restart;
-		}
-
-
-		sysfs_put(cur);
+		if (IS_ERR(dentry))
+			break;
 	}
-
-	mutex_unlock(&sysfs_mutex);
 	return dentry;
 }
 
-- 
1.5.1.1.181.g2de0
