From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 18/25] sysfs: Rewrite sysfs_move_dir in terms of sysfs
	dirents
Date: Tue, 07 Aug 2007 15:28:10 -0600
Message-ID: <m1zm13ghlh.fsf_-_@ebiederm.dsl.xmission.com>
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
	<m1lkcnhwfu.fsf_-_@ebiederm.dsl.xmission.com>
	<m1hcnbhwcy.fsf_-_@ebiederm.dsl.xmission.com>
	<m1d4xzhwb2.fsf_-_@ebiederm.dsl.xmission.com>
	<m18x8nhw8r.fsf_-_@ebiederm.dsl.xmission.com>
	<m14pjbhw6y.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m14pjbhw6y.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 07 Aug 2007 15:27:33 -0600")
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


This patch rewrites sysfs_move_dir to perform it's checks
as much as possible on the underlying sysfs_dirents instead
of the contents of the dcache, making sysfs_move_dir
more like the rest of the sysfs directory modification
code.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/dir.c |   34 ++++++++++++++++++----------------
 1 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 3228f5a..94d705a 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -932,56 +932,58 @@ int sysfs_move_dir(struct kobject *kobj, struct kobject *new_parent_kobj)
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
1.5.1.1.181.g2de0
