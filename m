From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 12/14] sysfs: Make sysfs_mount static
Date: Tue, 31 Jul 2007 04:40:25 -0600
Message-ID: <m1odhsrh46.fsf_-_@ebiederm.dsl.xmission.com>
References: <1182446577.8138.29.camel@localhost>
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
	<m1sl74rh6e.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1sl74rh6e.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 31 Jul 2007 04:39:05 -0600")
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


This patch modifies the users of sysfs_mount to use sysfs_root instead
(which is what they are looking for).  It then makes sysfs_mount
static to keep people from using it by accident.

The net result is slightly faster and clearer code.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/dir.c     |    4 +---
 fs/sysfs/mount.c   |    2 +-
 fs/sysfs/symlink.c |    7 +++----
 fs/sysfs/sysfs.h   |    1 -
 4 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index c17e601..1611cbd 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -671,10 +671,8 @@ int sysfs_create_dir(struct kobject * kobj)
 
 	if (kobj->parent)
 		parent_sd = kobj->parent->sd;
-	else if (sysfs_mount && sysfs_mount->mnt_sb)
-		parent_sd = sysfs_mount->mnt_sb->s_root->d_fsdata;
 	else
-		return -EFAULT;
+		parent_sd = &sysfs_root;
 
 	error = create_dir(kobj, parent_sd, kobject_name(kobj), &sd);
 	if (!error)
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index 3f652be..0ad731b 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -15,7 +15,7 @@
 /* Random magic number */
 #define SYSFS_MAGIC 0x62656572
 
-struct vfsmount *sysfs_mount;
+static struct vfsmount *sysfs_mount;
 struct super_block * sysfs_sb = NULL;
 struct kmem_cache *sysfs_dir_cachep;
 
diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
index 4ce687f..2b542dc 100644
--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -60,10 +60,9 @@ int sysfs_create_link(struct kobject * kobj, struct kobject * target, const char
 
 	BUG_ON(!name);
 
-	if (!kobj) {
-		if (sysfs_mount && sysfs_mount->mnt_sb)
-			parent_sd = sysfs_mount->mnt_sb->s_root->d_fsdata;
-	} else
+	if (!kobj)
+		parent_sd = &sysfs_root;
+	else
 		parent_sd = kobj->sd;
 
 	error = -EFAULT;
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index 60af864..265a16a 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -50,7 +50,6 @@ struct sysfs_addrm_cxt {
 	int			cnt;
 };
 
-extern struct vfsmount * sysfs_mount;
 extern struct sysfs_dirent sysfs_root;
 extern struct kmem_cache *sysfs_dir_cachep;
 
-- 
1.5.1.1.181.g2de0
