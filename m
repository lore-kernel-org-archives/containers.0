From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 07/25] userns: Convert adfs to use kuid and kgid where
	appropriate
Date: Thu, 20 Sep 2012 04:41:48 -0700
Message-ID: <1348141326-23355-7-git-send-email-ebiederm@xmission.com>
References: <877grox6ql.fsf@xmission.com>
	<1348141326-23355-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348141326-23355-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/adfs/adfs.h  |    4 ++--
 fs/adfs/inode.c |    4 ++--
 fs/adfs/super.c |   21 +++++++++++++--------
 init/Kconfig    |    1 -
 4 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/fs/adfs/adfs.h b/fs/adfs/adfs.h
index 718ac1f..585adaf 100644
--- a/fs/adfs/adfs.h
+++ b/fs/adfs/adfs.h
@@ -46,8 +46,8 @@ struct adfs_sb_info {
 	struct adfs_discmap *s_map;	/* bh list containing map		 */
 	struct adfs_dir_ops *s_dir;	/* directory operations			 */
 
-	uid_t		s_uid;		/* owner uid				 */
-	gid_t		s_gid;		/* owner gid				 */
+	kuid_t		s_uid;		/* owner uid				 */
+	kgid_t		s_gid;		/* owner gid				 */
 	umode_t		s_owner_mask;	/* ADFS owner perm -> unix perm		 */
 	umode_t		s_other_mask;	/* ADFS other perm -> unix perm		 */
 	int		s_ftsuffix;	/* ,xyz hex filetype suffix option */
diff --git a/fs/adfs/inode.c b/fs/adfs/inode.c
index 1dab6a1..e9bad50 100644
--- a/fs/adfs/inode.c
+++ b/fs/adfs/inode.c
@@ -304,8 +304,8 @@ adfs_notify_change(struct dentry *dentry, struct iattr *attr)
 	 * we can't change the UID or GID of any file -
 	 * we have a global UID/GID in the superblock
 	 */
-	if ((ia_valid & ATTR_UID && attr->ia_uid != ADFS_SB(sb)->s_uid) ||
-	    (ia_valid & ATTR_GID && attr->ia_gid != ADFS_SB(sb)->s_gid))
+	if ((ia_valid & ATTR_UID && !uid_eq(attr->ia_uid, ADFS_SB(sb)->s_uid)) ||
+	    (ia_valid & ATTR_GID && !gid_eq(attr->ia_gid, ADFS_SB(sb)->s_gid)))
 		error = -EPERM;
 
 	if (error)
diff --git a/fs/adfs/super.c b/fs/adfs/super.c
index bdaec92..22a0d7e 100644
--- a/fs/adfs/super.c
+++ b/fs/adfs/super.c
@@ -15,6 +15,7 @@
 #include <linux/seq_file.h>
 #include <linux/slab.h>
 #include <linux/statfs.h>
+#include <linux/user_namespace.h>
 #include "adfs.h"
 #include "dir_f.h"
 #include "dir_fplus.h"
@@ -130,10 +131,10 @@ static int adfs_show_options(struct seq_file *seq, struct dentry *root)
 {
 	struct adfs_sb_info *asb = ADFS_SB(root->d_sb);
 
-	if (asb->s_uid != 0)
-		seq_printf(seq, ",uid=%u", asb->s_uid);
-	if (asb->s_gid != 0)
-		seq_printf(seq, ",gid=%u", asb->s_gid);
+	if (!uid_eq(asb->s_uid, GLOBAL_ROOT_UID))
+		seq_printf(seq, ",uid=%u", from_kuid_munged(&init_user_ns, asb->s_uid));
+	if (!gid_eq(asb->s_gid, GLOBAL_ROOT_GID))
+		seq_printf(seq, ",gid=%u", from_kgid_munged(&init_user_ns, asb->s_gid));
 	if (asb->s_owner_mask != ADFS_DEFAULT_OWNER_MASK)
 		seq_printf(seq, ",ownmask=%o", asb->s_owner_mask);
 	if (asb->s_other_mask != ADFS_DEFAULT_OTHER_MASK)
@@ -175,12 +176,16 @@ static int parse_options(struct super_block *sb, char *options)
 		case Opt_uid:
 			if (match_int(args, &option))
 				return -EINVAL;
-			asb->s_uid = option;
+			asb->s_uid = make_kuid(current_user_ns(), option);
+			if (!uid_valid(asb->s_uid))
+				return -EINVAL;
 			break;
 		case Opt_gid:
 			if (match_int(args, &option))
 				return -EINVAL;
-			asb->s_gid = option;
+			asb->s_gid = make_kgid(current_user_ns(), option);
+			if (!gid_valid(asb->s_gid))
+				return -EINVAL;
 			break;
 		case Opt_ownmask:
 			if (match_octal(args, &option))
@@ -369,8 +374,8 @@ static int adfs_fill_super(struct super_block *sb, void *data, int silent)
 	sb->s_fs_info = asb;
 
 	/* set default options */
-	asb->s_uid = 0;
-	asb->s_gid = 0;
+	asb->s_uid = GLOBAL_ROOT_UID;
+	asb->s_gid = GLOBAL_ROOT_GID;
 	asb->s_owner_mask = ADFS_DEFAULT_OWNER_MASK;
 	asb->s_other_mask = ADFS_DEFAULT_OTHER_MASK;
 	asb->s_ftsuffix = 0;
diff --git a/init/Kconfig b/init/Kconfig
index 485c60a..20ddf0d 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -933,7 +933,6 @@ config UIDGID_CONVERTED
 
 	# Filesystems
 	depends on 9P_FS = n
-	depends on ADFS_FS = n
 	depends on AFFS_FS = n
 	depends on AFS_FS = n
 	depends on AUTOFS4_FS = n
-- 
1.7.5.4
