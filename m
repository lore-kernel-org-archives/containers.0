From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 11/25] sysfs: Remove s_dentry
Date: Tue, 07 Aug 2007 15:19:31 -0600
Message-ID: <m1tzrbhwkc.fsf_-_@ebiederm.dsl.xmission.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1y7gnhwm4.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 07 Aug 2007 15:18:27 -0600")
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


The only uses of s_dentry left are the code that maintains
s_dentry and trivial users that don't actually need it.
So this patch removes the s_dentry maintenance code and
restructures the trivial uses to use something else.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/dir.c   |   32 ++++----------------------------
 fs/sysfs/mount.c |    1 -
 fs/sysfs/sysfs.h |    1 -
 3 files changed, 4 insertions(+), 30 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index adb1b01..1078e60 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -247,22 +247,7 @@ static void sysfs_d_iput(struct dentry * dentry, struct inode * inode)
 {
 	struct sysfs_dirent * sd = dentry->d_fsdata;
 
-	if (sd) {
-		/* sd->s_dentry is protected with sysfs_assoc_lock.
-		 * This allows sysfs_drop_dentry() to dereference it.
-		 */
-		spin_lock(&sysfs_assoc_lock);
-
-		/* The dentry might have been deleted or another
-		 * lookup could have happened updating sd->s_dentry to
-		 * point the new dentry.  Ignore if it isn't pointing
-		 * to this dentry.
-		 */
-		if (sd->s_dentry == dentry)
-			sd->s_dentry = NULL;
-		spin_unlock(&sysfs_assoc_lock);
-		sysfs_put(sd);
-	}
+	sysfs_put(sd);
 	iput(inode);
 }
 
@@ -310,9 +295,6 @@ struct sysfs_dirent *sysfs_new_dirent(const char *name, umode_t mode, int type)
  *	@sd: target sysfs_dirent
  *	@dentry: dentry to associate
  *
- *	Associate @sd with @dentry.  This is protected by
- *	sysfs_assoc_lock to avoid race with sysfs_d_iput().
- *
  *	LOCKING:
  *	mutex_lock(sysfs_mutex)
  */
@@ -320,12 +302,6 @@ static void sysfs_attach_dentry(struct sysfs_dirent *sd, struct dentry *dentry)
 {
 	dentry->d_op = &sysfs_dentry_ops;
 	dentry->d_fsdata = sysfs_get(sd);
-
-	/* protect sd->s_dentry against sysfs_d_iput */
-	spin_lock(&sysfs_assoc_lock);
-	sd->s_dentry = dentry;
-	spin_unlock(&sysfs_assoc_lock);
-
 	d_rehash(dentry);
 }
 
@@ -927,7 +903,7 @@ int sysfs_rename_dir(struct kobject * kobj, const char *new_name)
 
 	/* rename */
 	d_add(new_dentry, NULL);
-	d_move(sd->s_dentry, new_dentry);
+	d_move(old_dentry, new_dentry);
 
 	error = 0;
 	goto out_unlock;
@@ -960,7 +936,7 @@ int sysfs_move_dir(struct kobject *kobj, struct kobject *new_parent_kobj)
 		error = PTR_ERR(old_dentry);
 		goto out_dput;
 	}
-	old_parent = sd->s_parent->s_dentry;
+	old_parent = old_dentry->d_parent;
 
 	new_parent = sysfs_get_dentry(new_parent_sd);
 	if (IS_ERR(new_parent)) {
@@ -986,7 +962,7 @@ again:
 	} else
 		error = 0;
 	d_add(new_dentry, NULL);
-	d_move(sd->s_dentry, new_dentry);
+	d_move(old_dentry, new_dentry);
 	dput(new_dentry);
 
 	/* Remove from old parent's list and insert into new parent's list. */
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index 9fae7d5..4968d31 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -57,7 +57,6 @@ static int sysfs_fill_super(struct super_block *sb, void *data, int silent)
 		iput(inode);
 		return -ENOMEM;
 	}
-	sysfs_root.s_dentry = root;
 	root->d_fsdata = &sysfs_root;
 	sb->s_root = root;
 	return 0;
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index 77253aa..8ed13cf 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -37,7 +37,6 @@ struct sysfs_dirent {
 	unsigned int		s_flags;
 	umode_t			s_mode;
 	ino_t			s_ino;
-	struct dentry		* s_dentry;
 	struct iattr		* s_iattr;
 	atomic_t		s_event;
 };
-- 
1.5.1.1.181.g2de0
