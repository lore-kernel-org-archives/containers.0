From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 11/14] sysfs: Remove s_dentry form sysfs_dirent.
Date: Tue, 31 Jul 2007 04:39:05 -0600
Message-ID: <m1sl74rh6e.fsf_-_@ebiederm.dsl.xmission.com>
References: <1182446577.8138.29.camel@localhost> <46ADF003.3010100@suse.de>
	<m1ps29vqin.fsf@ebiederm.dsl.xmission.com>
	<m1k5shuugc.fsf@ebiederm.dsl.xmission.com> <46AEAF79.6080404@suse.de>
	<m1fy35uso4.fsf@ebiederm.dsl.xmission.com> <46AEBA87.6000400@suse.de>
	<m1bqdtt34l.fsf@ebiederm.dsl.xmission.com> <46AEEF75.2030101@suse.de>
	<46AEEFA6.4000901@suse.de>
	<m14pjkubd2.fsf_-_@ebiederm.dsl.xmission.com>
	<m1zm1cswp0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1vec0swmi.fsf_-_@ebiederm.dsl.xmission.com>
	<m1r6moswhr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1myxcswfr.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ir80swdl.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejioswai.fsf_-_@ebiederm.dsl.xmission.com>
	<m1abtcsw8w.fsf_-_@ebiederm.dsl.xmission.com>
	<m16440sw6d.fsf_-_@ebiederm.dsl.xmission.com>
	<m11weosvzz.fsf_-_@ebiederm.dsl.xmission.com>
	<m1wswgrh8x.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1wswgrh8x.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 31 Jul 2007 04:37:34 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <teheo-l3A5Bk7waGM@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>, Dave Hansen <hansendc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


After the last round of refactoring nothing is really using
using s_dirent so remove it.  Which makes the code easier to work
with and follow.  And with a little luck makes it easier to
support multiple dentry trees for sysfs.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/dir.c   |   26 +-------------------------
 fs/sysfs/mount.c |    1 -
 fs/sysfs/sysfs.h |    1 -
 3 files changed, 1 insertions(+), 27 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index f8de6fb..c17e601 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -310,22 +310,7 @@ static void sysfs_d_iput(struct dentry * dentry, struct inode * inode)
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
 
@@ -373,9 +358,6 @@ struct sysfs_dirent *sysfs_new_dirent(const char *name, umode_t mode, int type)
  *	@sd: target sysfs_dirent
  *	@dentry: dentry to associate
  *
- *	Associate @sd with @dentry.  This is protected by
- *	sysfs_assoc_lock to avoid race with sysfs_d_iput().
- *
  *	LOCKING:
  *	mutex_lock(sysfs_mutex)
  */
@@ -383,12 +365,6 @@ static void sysfs_attach_dentry(struct sysfs_dirent *sd, struct dentry *dentry)
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
 
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index 919eaaf..3f652be 100644
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
index 3b4b989..60af864 100644
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
