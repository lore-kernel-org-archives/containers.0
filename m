From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 04/11] userns: Convert hpfs to use kuid and kgid where
	appropriate
Date: Fri, 21 Sep 2012 18:35:05 -0700
Message-ID: <1348277712-30055-4-git-send-email-ebiederm@xmission.com>
References: <877grmj115.fsf@xmission.com>
	<1348277712-30055-1-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1348277712-30055-1-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mikulas Patocka <mikulas-TTVWCEgN8Z9G4ohzP4jBZS1Fcj925eT/@public.gmane.org>
List-Id: containers.vger.kernel.org

From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Cc: Mikulas Patocka <mikulas-TTVWCEgN8Z9G4ohzP4jBZS1Fcj925eT/@public.gmane.org>
Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/hpfs/hpfs_fn.h |    4 ++--
 fs/hpfs/inode.c   |   19 +++++++++++--------
 fs/hpfs/namei.c   |    8 ++++----
 fs/hpfs/super.c   |   18 +++++++++++-------
 init/Kconfig      |    1 -
 5 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/fs/hpfs/hpfs_fn.h b/fs/hpfs/hpfs_fn.h
index ac1ead1..7102aae 100644
--- a/fs/hpfs/hpfs_fn.h
+++ b/fs/hpfs/hpfs_fn.h
@@ -63,8 +63,8 @@ struct hpfs_sb_info {
 	unsigned sb_dmap;		/* sector number of dnode bit map */
 	unsigned sb_n_free;		/* free blocks for statfs, or -1 */
 	unsigned sb_n_free_dnodes;	/* free dnodes for statfs, or -1 */
-	uid_t sb_uid;			/* uid from mount options */
-	gid_t sb_gid;			/* gid from mount options */
+	kuid_t sb_uid;			/* uid from mount options */
+	kgid_t sb_gid;			/* gid from mount options */
 	umode_t sb_mode;		/* mode from mount options */
 	unsigned sb_eas : 2;		/* eas: 0-ignore, 1-ro, 2-rw */
 	unsigned sb_err : 2;		/* on errs: 0-cont, 1-ro, 2-panic */
diff --git a/fs/hpfs/inode.c b/fs/hpfs/inode.c
index ed671e0..804a9a8 100644
--- a/fs/hpfs/inode.c
+++ b/fs/hpfs/inode.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/slab.h>
+#include <linux/user_namespace.h>
 #include "hpfs_fn.h"
 
 void hpfs_init_inode(struct inode *i)
@@ -60,14 +61,14 @@ void hpfs_read_inode(struct inode *i)
 	if (hpfs_sb(i->i_sb)->sb_eas) {
 		if ((ea = hpfs_get_ea(i->i_sb, fnode, "UID", &ea_size))) {
 			if (ea_size == 2) {
-				i->i_uid = le16_to_cpu(*(__le16*)ea);
+				i_uid_write(i, le16_to_cpu(*(__le16*)ea));
 				hpfs_inode->i_ea_uid = 1;
 			}
 			kfree(ea);
 		}
 		if ((ea = hpfs_get_ea(i->i_sb, fnode, "GID", &ea_size))) {
 			if (ea_size == 2) {
-				i->i_gid = le16_to_cpu(*(__le16*)ea);
+				i_gid_write(i, le16_to_cpu(*(__le16*)ea));
 				hpfs_inode->i_ea_gid = 1;
 			}
 			kfree(ea);
@@ -149,13 +150,13 @@ static void hpfs_write_inode_ea(struct inode *i, struct fnode *fnode)
 		hpfs_error(i->i_sb, "fnode %08x has some unknown HPFS386 stuctures", i->i_ino);
 	} else*/ if (hpfs_sb(i->i_sb)->sb_eas >= 2) {
 		__le32 ea;
-		if ((i->i_uid != hpfs_sb(i->i_sb)->sb_uid) || hpfs_inode->i_ea_uid) {
-			ea = cpu_to_le32(i->i_uid);
+		if (!uid_eq(i->i_uid, hpfs_sb(i->i_sb)->sb_uid) || hpfs_inode->i_ea_uid) {
+			ea = cpu_to_le32(i_uid_read(i));
 			hpfs_set_ea(i, fnode, "UID", (char*)&ea, 2);
 			hpfs_inode->i_ea_uid = 1;
 		}
-		if ((i->i_gid != hpfs_sb(i->i_sb)->sb_gid) || hpfs_inode->i_ea_gid) {
-			ea = cpu_to_le32(i->i_gid);
+		if (!gid_eq(i->i_gid, hpfs_sb(i->i_sb)->sb_gid) || hpfs_inode->i_ea_gid) {
+			ea = cpu_to_le32(i_gid_read(i));
 			hpfs_set_ea(i, fnode, "GID", (char *)&ea, 2);
 			hpfs_inode->i_ea_gid = 1;
 		}
@@ -261,9 +262,11 @@ int hpfs_setattr(struct dentry *dentry, struct iattr *attr)
 	hpfs_lock(inode->i_sb);
 	if (inode->i_ino == hpfs_sb(inode->i_sb)->sb_root)
 		goto out_unlock;
-	if ((attr->ia_valid & ATTR_UID) && attr->ia_uid >= 0x10000)
+	if ((attr->ia_valid & ATTR_UID) &&
+	    from_kuid(&init_user_ns, attr->ia_uid) >= 0x10000)
 		goto out_unlock;
-	if ((attr->ia_valid & ATTR_GID) && attr->ia_gid >= 0x10000)
+	if ((attr->ia_valid & ATTR_GID) &&
+	    from_kgid(&init_user_ns, attr->ia_gid) >= 0x10000)
 		goto out_unlock;
 	if ((attr->ia_valid & ATTR_SIZE) && attr->ia_size > inode->i_size)
 		goto out_unlock;
diff --git a/fs/hpfs/namei.c b/fs/hpfs/namei.c
index bc90824..345713d 100644
--- a/fs/hpfs/namei.c
+++ b/fs/hpfs/namei.c
@@ -91,8 +91,8 @@ static int hpfs_mkdir(struct inode *dir, struct dentry *dentry, umode_t mode)
 	inc_nlink(dir);
 	insert_inode_hash(result);
 
-	if (result->i_uid != current_fsuid() ||
-	    result->i_gid != current_fsgid() ||
+	if (!uid_eq(result->i_uid, current_fsuid()) ||
+	    !gid_eq(result->i_gid, current_fsgid()) ||
 	    result->i_mode != (mode | S_IFDIR)) {
 		result->i_uid = current_fsuid();
 		result->i_gid = current_fsgid();
@@ -179,8 +179,8 @@ static int hpfs_create(struct inode *dir, struct dentry *dentry, umode_t mode, b
 
 	insert_inode_hash(result);
 
-	if (result->i_uid != current_fsuid() ||
-	    result->i_gid != current_fsgid() ||
+	if (!uid_eq(result->i_uid, current_fsuid()) ||
+	    !gid_eq(result->i_gid, current_fsgid()) ||
 	    result->i_mode != (mode | S_IFREG)) {
 		result->i_uid = current_fsuid();
 		result->i_gid = current_fsgid();
diff --git a/fs/hpfs/super.c b/fs/hpfs/super.c
index 706a12c..a152783 100644
--- a/fs/hpfs/super.c
+++ b/fs/hpfs/super.c
@@ -251,7 +251,7 @@ static const match_table_t tokens = {
 	{Opt_err, NULL},
 };
 
-static int parse_opts(char *opts, uid_t *uid, gid_t *gid, umode_t *umask,
+static int parse_opts(char *opts, kuid_t *uid, kgid_t *gid, umode_t *umask,
 		      int *lowercase, int *eas, int *chk, int *errs,
 		      int *chkdsk, int *timeshift)
 {
@@ -276,12 +276,16 @@ static int parse_opts(char *opts, uid_t *uid, gid_t *gid, umode_t *umask,
 		case Opt_uid:
 			if (match_int(args, &option))
 				return 0;
-			*uid = option;
+			*uid = make_kuid(current_user_ns(), option);
+			if (!uid_valid(*uid))
+				return 0;
 			break;
 		case Opt_gid:
 			if (match_int(args, &option))
 				return 0;
-			*gid = option;
+			*gid = make_kgid(current_user_ns(), option);
+			if (!gid_valid(*gid))
+				return 0;
 			break;
 		case Opt_umask:
 			if (match_octal(args, &option))
@@ -378,8 +382,8 @@ HPFS filesystem options:\n\
 
 static int hpfs_remount_fs(struct super_block *s, int *flags, char *data)
 {
-	uid_t uid;
-	gid_t gid;
+	kuid_t uid;
+	kgid_t gid;
 	umode_t umask;
 	int lowercase, eas, chk, errs, chkdsk, timeshift;
 	int o;
@@ -455,8 +459,8 @@ static int hpfs_fill_super(struct super_block *s, void *options, int silent)
 	struct hpfs_sb_info *sbi;
 	struct inode *root;
 
-	uid_t uid;
-	gid_t gid;
+	kuid_t uid;
+	kgid_t gid;
 	umode_t umask;
 	int lowercase, eas, chk, errs, chkdsk, timeshift;
 
diff --git a/init/Kconfig b/init/Kconfig
index 44f580f..1db1b0f 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -935,7 +935,6 @@ config UIDGID_CONVERTED
 	depends on CODA_FS = n
 	depends on FUSE_FS = n
 	depends on GFS2_FS = n
-	depends on HPFS_FS = n
 	depends on JFFS2_FS = n
 	depends on JFS_FS = n
 	depends on NCP_FS = n
-- 
1.7.5.4
