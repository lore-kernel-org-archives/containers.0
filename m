From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 14/25] userns: Convert hfsplus to use kuid and kgid where
	appropriate
Date: Thu, 20 Sep 2012 04:41:55 -0700
Message-ID: <1348141326-23355-14-git-send-email-ebiederm@xmission.com>
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

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/hfsplus/catalog.c    |    4 ++--
 fs/hfsplus/hfsplus_fs.h |    4 ++--
 fs/hfsplus/inode.c      |    8 ++++----
 fs/hfsplus/options.c    |   15 ++++++++++++---
 init/Kconfig            |    1 -
 5 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/fs/hfsplus/catalog.c b/fs/hfsplus/catalog.c
index ec2a9c2..798d9c4 100644
--- a/fs/hfsplus/catalog.c
+++ b/fs/hfsplus/catalog.c
@@ -80,8 +80,8 @@ void hfsplus_cat_set_perms(struct inode *inode, struct hfsplus_perm *perms)
 
 	perms->userflags = HFSPLUS_I(inode)->userflags;
 	perms->mode = cpu_to_be16(inode->i_mode);
-	perms->owner = cpu_to_be32(inode->i_uid);
-	perms->group = cpu_to_be32(inode->i_gid);
+	perms->owner = cpu_to_be32(i_uid_read(inode));
+	perms->group = cpu_to_be32(i_gid_read(inode));
 
 	if (S_ISREG(inode->i_mode))
 		perms->dev = cpu_to_be32(inode->i_nlink);
diff --git a/fs/hfsplus/hfsplus_fs.h b/fs/hfsplus/hfsplus_fs.h
index 558dbb4..c571de2 100644
--- a/fs/hfsplus/hfsplus_fs.h
+++ b/fs/hfsplus/hfsplus_fs.h
@@ -149,8 +149,8 @@ struct hfsplus_sb_info {
 	u32 type;
 
 	umode_t umask;
-	uid_t uid;
-	gid_t gid;
+	kuid_t uid;
+	kgid_t gid;
 
 	int part, session;
 	unsigned long flags;
diff --git a/fs/hfsplus/inode.c b/fs/hfsplus/inode.c
index 3d8b4a6..2172aa5 100644
--- a/fs/hfsplus/inode.c
+++ b/fs/hfsplus/inode.c
@@ -233,12 +233,12 @@ static void hfsplus_get_perms(struct inode *inode,
 
 	mode = be16_to_cpu(perms->mode);
 
-	inode->i_uid = be32_to_cpu(perms->owner);
-	if (!inode->i_uid && !mode)
+	i_uid_write(inode, be32_to_cpu(perms->owner));
+	if (!i_uid_read(inode) && !mode)
 		inode->i_uid = sbi->uid;
 
-	inode->i_gid = be32_to_cpu(perms->group);
-	if (!inode->i_gid && !mode)
+	i_gid_write(inode, be32_to_cpu(perms->group));
+	if (!i_gid_read(inode) && !mode)
 		inode->i_gid = sbi->gid;
 
 	if (dir) {
diff --git a/fs/hfsplus/options.c b/fs/hfsplus/options.c
index 06fa561..ed257c6 100644
--- a/fs/hfsplus/options.c
+++ b/fs/hfsplus/options.c
@@ -135,14 +135,22 @@ int hfsplus_parse_options(char *input, struct hfsplus_sb_info *sbi)
 				printk(KERN_ERR "hfs: uid requires an argument\n");
 				return 0;
 			}
-			sbi->uid = (uid_t)tmp;
+			sbi->uid = make_kuid(current_user_ns(), (uid_t)tmp);
+			if (!uid_valid(sbi->uid)) {
+				printk(KERN_ERR "hfs: invalid uid specified\n");
+				return 0;
+			}
 			break;
 		case opt_gid:
 			if (match_int(&args[0], &tmp)) {
 				printk(KERN_ERR "hfs: gid requires an argument\n");
 				return 0;
 			}
-			sbi->gid = (gid_t)tmp;
+			sbi->gid = make_kgid(current_user_ns(), (gid_t)tmp);
+			if (!gid_valid(sbi->gid)) {
+				printk(KERN_ERR "hfs: invalid gid specified\n");
+				return 0;
+			}
 			break;
 		case opt_part:
 			if (match_int(&args[0], &sbi->part)) {
@@ -215,7 +223,8 @@ int hfsplus_show_options(struct seq_file *seq, struct dentry *root)
 	if (sbi->type != HFSPLUS_DEF_CR_TYPE)
 		seq_printf(seq, ",type=%.4s", (char *)&sbi->type);
 	seq_printf(seq, ",umask=%o,uid=%u,gid=%u", sbi->umask,
-		sbi->uid, sbi->gid);
+			from_kuid_munged(&init_user_ns, sbi->uid),
+			from_kgid_munged(&init_user_ns, sbi->gid));
 	if (sbi->part >= 0)
 		seq_printf(seq, ",part=%u", sbi->part);
 	if (sbi->session >= 0)
diff --git a/init/Kconfig b/init/Kconfig
index 6038d64..9cf8cb1 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -943,7 +943,6 @@ config UIDGID_CONVERTED
 	depends on CODA_FS = n
 	depends on FUSE_FS = n
 	depends on GFS2_FS = n
-	depends on HFSPLUS_FS = n
 	depends on HPFS_FS = n
 	depends on ISO9660_FS = n
 	depends on JFFS2_FS = n
-- 
1.7.5.4
