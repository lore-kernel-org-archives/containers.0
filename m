From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 13/25] userns: Convert hfs to use kuid and kgid where
	appropriate
Date: Thu, 20 Sep 2012 04:41:54 -0700
Message-ID: <1348141326-23355-13-git-send-email-ebiederm@xmission.com>
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
 fs/hfs/hfs_fs.h |    4 ++--
 fs/hfs/inode.c  |    4 ++--
 fs/hfs/super.c  |   16 +++++++++++++---
 init/Kconfig    |    1 -
 4 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/fs/hfs/hfs_fs.h b/fs/hfs/hfs_fs.h
index 8275175..693df9f 100644
--- a/fs/hfs/hfs_fs.h
+++ b/fs/hfs/hfs_fs.h
@@ -134,8 +134,8 @@ struct hfs_sb_info {
 						   permissions on all files */
 	umode_t s_dir_umask;			/* The umask applied to the
 						   permissions on all dirs */
-	uid_t s_uid;				/* The uid of all files */
-	gid_t s_gid;				/* The gid of all files */
+	kuid_t s_uid;				/* The uid of all files */
+	kgid_t s_gid;				/* The gid of all files */
 
 	int session, part;
 	struct nls_table *nls_io, *nls_disk;
diff --git a/fs/hfs/inode.c b/fs/hfs/inode.c
index ee1bc55..5d5c22d 100644
--- a/fs/hfs/inode.c
+++ b/fs/hfs/inode.c
@@ -594,9 +594,9 @@ int hfs_inode_setattr(struct dentry *dentry, struct iattr * attr)
 
 	/* no uig/gid changes and limit which mode bits can be set */
 	if (((attr->ia_valid & ATTR_UID) &&
-	     (attr->ia_uid != hsb->s_uid)) ||
+	     (!uid_eq(attr->ia_uid, hsb->s_uid))) ||
 	    ((attr->ia_valid & ATTR_GID) &&
-	     (attr->ia_gid != hsb->s_gid)) ||
+	     (!gid_eq(attr->ia_gid, hsb->s_gid))) ||
 	    ((attr->ia_valid & ATTR_MODE) &&
 	     ((S_ISDIR(inode->i_mode) &&
 	       (attr->ia_mode != inode->i_mode)) ||
diff --git a/fs/hfs/super.c b/fs/hfs/super.c
index 4eb873e..0b63d13 100644
--- a/fs/hfs/super.c
+++ b/fs/hfs/super.c
@@ -138,7 +138,9 @@ static int hfs_show_options(struct seq_file *seq, struct dentry *root)
 		seq_printf(seq, ",creator=%.4s", (char *)&sbi->s_creator);
 	if (sbi->s_type != cpu_to_be32(0x3f3f3f3f))
 		seq_printf(seq, ",type=%.4s", (char *)&sbi->s_type);
-	seq_printf(seq, ",uid=%u,gid=%u", sbi->s_uid, sbi->s_gid);
+	seq_printf(seq, ",uid=%u,gid=%u",
+			from_kuid_munged(&init_user_ns, sbi->s_uid),
+			from_kgid_munged(&init_user_ns, sbi->s_gid));
 	if (sbi->s_file_umask != 0133)
 		seq_printf(seq, ",file_umask=%o", sbi->s_file_umask);
 	if (sbi->s_dir_umask != 0022)
@@ -254,14 +256,22 @@ static int parse_options(char *options, struct hfs_sb_info *hsb)
 				printk(KERN_ERR "hfs: uid requires an argument\n");
 				return 0;
 			}
-			hsb->s_uid = (uid_t)tmp;
+			hsb->s_uid = make_kuid(current_user_ns(), (uid_t)tmp);
+			if (!uid_valid(hsb->s_uid)) {
+				printk(KERN_ERR "hfs: invalid uid %d\n", tmp);
+				return 0;
+			}
 			break;
 		case opt_gid:
 			if (match_int(&args[0], &tmp)) {
 				printk(KERN_ERR "hfs: gid requires an argument\n");
 				return 0;
 			}
-			hsb->s_gid = (gid_t)tmp;
+			hsb->s_gid = make_kgid(current_user_ns(), (gid_t)tmp);
+			if (!gid_valid(hsb->s_gid)) {
+				printk(KERN_ERR "hfs: invalid gid %d\n", tmp);
+				return 0;
+			}
 			break;
 		case opt_umask:
 			if (match_octal(&args[0], &tmp)) {
diff --git a/init/Kconfig b/init/Kconfig
index 39e55d6..6038d64 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -943,7 +943,6 @@ config UIDGID_CONVERTED
 	depends on CODA_FS = n
 	depends on FUSE_FS = n
 	depends on GFS2_FS = n
-	depends on HFS_FS = n
 	depends on HFSPLUS_FS = n
 	depends on HPFS_FS = n
 	depends on ISO9660_FS = n
-- 
1.7.5.4
