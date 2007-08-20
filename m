From: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 11/14] sysfs: Remove s_dentry
Date: Mon, 20 Aug 2007 21:36:30 +0900
Message-ID: <11876133901826-git-send-email-htejun@gmail.com>
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

The only uses of s_dentry left are the code that maintains
s_dentry and trivial users that don't actually need it.
So this patch removes the s_dentry maintenance code and
restructures the trivial uses to use something else.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/sysfs/dir.c   |   32 ++++----------------------------
 fs/sysfs/mount.c |    1 -
 fs/sysfs/sysfs.h |    1 -
 3 files changed, 4 insertions(+), 30 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index aee24e9..c55c811 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -289,22 +289,7 @@ static void sysfs_d_iput(struct dentry * dentry, struct inode * inode)
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
 
@@ -352,9 +337,6 @@ struct sysfs_dirent *sysfs_new_dirent(const char *name, umode_t mode, int type)
  *	@sd: target sysfs_dirent
  *	@dentry: dentry to associate
  *
- *	Associate @sd with @dentry.  This is protected by
- *	sysfs_assoc_lock to avoid race with sysfs_d_iput().
- *
  *	LOCKING:
  *	mutex_lock(sysfs_mutex)
  */
@@ -362,12 +344,6 @@ static void sysfs_attach_dentry(struct sysfs_dirent *sd, struct dentry *dentry)
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
 
@@ -846,7 +822,7 @@ int sysfs_rename_dir(struct kobject * kobj, const char *new_name)
 
 	/* rename */
 	d_add(new_dentry, NULL);
-	d_move(sd->s_dentry, new_dentry);
+	d_move(old_dentry, new_dentry);
 
 	error = 0;
 	goto out_unlock;
@@ -881,7 +857,7 @@ int sysfs_move_dir(struct kobject *kobj, struct kobject *new_parent_kobj)
 		error = PTR_ERR(old_dentry);
 		goto out_dput;
 	}
-	old_parent = sd->s_parent->s_dentry;
+	old_parent = old_dentry->d_parent;
 
 	new_parent = sysfs_get_dentry(new_parent_sd);
 	if (IS_ERR(new_parent)) {
@@ -907,7 +883,7 @@ again:
 	} else
 		error = 0;
 	d_add(new_dentry, NULL);
-	d_move(sd->s_dentry, new_dentry);
+	d_move(old_dentry, new_dentry);
 	dput(new_dentry);
 
 	/* Remove from old parent's list and insert into new parent's list. */
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index 8989cbb..28bf359 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -56,7 +56,6 @@ static int sysfs_fill_super(struct super_block *sb, void *data, int silent)
 		iput(inode);
 		return -ENOMEM;
 	}
-	sysfs_root.s_dentry = root;
 	root->d_fsdata = &sysfs_root;
 	sb->s_root = root;
 	return 0;
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index 179e6a2..791b3ed 100644
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
1.5.0.3
