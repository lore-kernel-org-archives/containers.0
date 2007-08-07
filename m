From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 04/25] sysfs: Make sysfs_mount static
Date: Tue, 07 Aug 2007 15:11:16 -0600
Message-ID: <m1odhjjbij.fsf_-_@ebiederm.dsl.xmission.com>
References: <11860582832964-git-send-email-htejun@gmail.com>
	<m1643rkqb6.fsf@ebiederm.dsl.xmission.com>
	<m11wefkq88.fsf_-_@ebiederm.dsl.xmission.com>
	<m1wsw7jbml.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl6vjbjw.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1sl6vjbjw.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org> (Eric
	W. Biederman's message of "Tue, 07 Aug 2007 15:10:27 -0600")
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


This patch modifies the users of sysfs_mount to use sysfs_root
instead (which is what they are looking for).  It then
makes sysfs_mount static to keep people from using it
by accident.

The net result is slightly faster and cleaner code.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/sysfs/dir.c     |    4 +---
 fs/sysfs/mount.c   |    2 +-
 fs/sysfs/symlink.c |    7 +++----
 fs/sysfs/sysfs.h   |    1 -
 4 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 55d8299..39df3ce 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -735,10 +735,8 @@ int sysfs_create_dir(struct kobject * kobj)
 
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
index d1094c6..9fae7d5 100644
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
index f77ad61..46f8fd4 100644
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
index 8a0aea1..77253aa 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -51,7 +51,6 @@ struct sysfs_addrm_cxt {
 	int			cnt;
 };
 
-extern struct vfsmount * sysfs_mount;
 extern struct sysfs_dirent sysfs_root;
 extern struct kmem_cache *sysfs_dir_cachep;
 
-- 
1.5.1.1.181.g2de0
