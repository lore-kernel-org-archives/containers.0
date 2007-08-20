From: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 14/14] sysfs: Rewrite sysfs_move_dir in terms of sysfs
	dirents
Date: Mon, 20 Aug 2007 21:36:31 +0900
Message-ID: <11876133911799-git-send-email-htejun@gmail.com>
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

This patch rewrites sysfs_move_dir to perform it's checks
as much as possible on the underlying sysfs_dirents instead
of the contents of the dcache, making sysfs_move_dir
more like the rest of the sysfs directory modification
code.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/sysfs/dir.c |   34 ++++++++++++++++++----------------
 1 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 6432a94..a493c6f 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -842,56 +842,58 @@ int sysfs_move_dir(struct kobject *kobj, struct kobject *new_parent_kobj)
 	BUG_ON(!sd->s_parent);
 	new_parent_sd = new_parent_kobj->sd ? new_parent_kobj->sd : &sysfs_root;
 
+	error = 0;
+	if (sd->s_parent == new_parent_sd)
+		goto out;	/* nothing to move */
+
 	/* get dentries */
 	old_dentry = sysfs_get_dentry(sd);
 	if (IS_ERR(old_dentry)) {
 		error = PTR_ERR(old_dentry);
-		goto out_dput;
+		goto out;
 	}
 	old_parent = old_dentry->d_parent;
 
 	new_parent = sysfs_get_dentry(new_parent_sd);
 	if (IS_ERR(new_parent)) {
 		error = PTR_ERR(new_parent);
-		goto out_dput;
+		goto out;
 	}
 
-	if (old_parent->d_inode == new_parent->d_inode) {
-		error = 0;
-		goto out_dput;	/* nothing to move */
-	}
 again:
 	mutex_lock(&old_parent->d_inode->i_mutex);
 	if (!mutex_trylock(&new_parent->d_inode->i_mutex)) {
 		mutex_unlock(&old_parent->d_inode->i_mutex);
 		goto again;
 	}
+	mutex_lock(&sysfs_mutex);
 
-	new_dentry = lookup_one_len(kobj->name, new_parent, strlen(kobj->name));
-	if (IS_ERR(new_dentry)) {
-		error = PTR_ERR(new_dentry);
+	error = -EEXIST;
+	if (sysfs_find_dirent(new_parent_sd, sd->s_name))
 		goto out_unlock;
-	} else
-		error = 0;
+
+	error = -ENOMEM;
+	new_dentry = d_alloc_name(new_parent, sd->s_name);
+	if (!new_dentry)
+		goto out_unlock;
+
+	error = 0;
 	d_add(new_dentry, NULL);
 	d_move(old_dentry, new_dentry);
 	dput(new_dentry);
 
 	/* Remove from old parent's list and insert into new parent's list. */
-	mutex_lock(&sysfs_mutex);
-
 	sysfs_unlink_sibling(sd);
 	sysfs_get(new_parent_sd);
 	sysfs_put(sd->s_parent);
 	sd->s_parent = new_parent_sd;
 	sysfs_link_sibling(sd);
 
-	mutex_unlock(&sysfs_mutex);
-
  out_unlock:
+	mutex_unlock(&sysfs_mutex);
 	mutex_unlock(&new_parent->d_inode->i_mutex);
 	mutex_unlock(&old_parent->d_inode->i_mutex);
- out_dput:
+ out:
 	dput(new_parent);
 	dput(old_dentry);
 	dput(new_dentry);
-- 
1.5.0.3
