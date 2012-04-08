From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 35/43] userns: Convert ext2 to use kuid/kgid where appropriate.
Date: Sat,  7 Apr 2012 22:15:31 -0700
Message-ID: <1333862139-31737-35-git-send-email-ebiederm@xmission.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11unyn70b.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 fs/ext2/balloc.c |    5 +++--
 fs/ext2/ext2.h   |    8 ++++----
 fs/ext2/inode.c  |   20 ++++++++++++--------
 fs/ext2/super.c  |   31 +++++++++++++++++++++++--------
 4 files changed, 42 insertions(+), 22 deletions(-)

diff --git a/fs/ext2/balloc.c b/fs/ext2/balloc.c
index a8cbe1b..030c6d2 100644
--- a/fs/ext2/balloc.c
+++ b/fs/ext2/balloc.c
@@ -1193,8 +1193,9 @@ static int ext2_has_free_blocks(struct ext2_sb_info *sbi)
 	free_blocks = percpu_counter_read_positive(&sbi->s_freeblocks_counter);
 	root_blocks = le32_to_cpu(sbi->s_es->s_r_blocks_count);
 	if (free_blocks < root_blocks + 1 && !capable(CAP_SYS_RESOURCE) &&
-		sbi->s_resuid != current_fsuid() &&
-		(sbi->s_resgid == 0 || !in_group_p (sbi->s_resgid))) {
+		!uid_eq(sbi->s_resuid, current_fsuid()) &&
+		(gid_eq(sbi->s_resgid, GLOBAL_ROOT_GID) ||
+		 !in_group_p (sbi->s_resgid))) {
 		return 0;
 	}
 	return 1;
diff --git a/fs/ext2/ext2.h b/fs/ext2/ext2.h
index 0b2b4db..d9a17d0 100644
--- a/fs/ext2/ext2.h
+++ b/fs/ext2/ext2.h
@@ -82,8 +82,8 @@ struct ext2_sb_info {
 	struct buffer_head ** s_group_desc;
 	unsigned long  s_mount_opt;
 	unsigned long s_sb_block;
-	uid_t s_resuid;
-	gid_t s_resgid;
+	kuid_t s_resuid;
+	kgid_t s_resgid;
 	unsigned short s_mount_state;
 	unsigned short s_pad;
 	int s_addr_per_block_bits;
@@ -637,8 +637,8 @@ static inline void verify_offsets(void)
  */
 struct ext2_mount_options {
 	unsigned long s_mount_opt;
-	uid_t s_resuid;
-	gid_t s_resgid;
+	kuid_t s_resuid;
+	kgid_t s_resgid;
 };
 
 /*
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 740cad8..f9fa95f 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -1293,6 +1293,8 @@ struct inode *ext2_iget (struct super_block *sb, unsigned long ino)
 	struct inode *inode;
 	long ret = -EIO;
 	int n;
+	uid_t i_uid;
+	gid_t i_gid;
 
 	inode = iget_locked(sb, ino);
 	if (!inode)
@@ -1310,12 +1312,14 @@ struct inode *ext2_iget (struct super_block *sb, unsigned long ino)
 	}
 
 	inode->i_mode = le16_to_cpu(raw_inode->i_mode);
-	inode->i_uid = (uid_t)le16_to_cpu(raw_inode->i_uid_low);
-	inode->i_gid = (gid_t)le16_to_cpu(raw_inode->i_gid_low);
+	i_uid = (uid_t)le16_to_cpu(raw_inode->i_uid_low);
+	i_gid = (gid_t)le16_to_cpu(raw_inode->i_gid_low);
 	if (!(test_opt (inode->i_sb, NO_UID32))) {
-		inode->i_uid |= le16_to_cpu(raw_inode->i_uid_high) << 16;
-		inode->i_gid |= le16_to_cpu(raw_inode->i_gid_high) << 16;
+		i_uid |= le16_to_cpu(raw_inode->i_uid_high) << 16;
+		i_gid |= le16_to_cpu(raw_inode->i_gid_high) << 16;
 	}
+	i_uid_write(inode, i_uid);
+	i_gid_write(inode, i_gid);
 	set_nlink(inode, le16_to_cpu(raw_inode->i_links_count));
 	inode->i_size = le32_to_cpu(raw_inode->i_size);
 	inode->i_atime.tv_sec = (signed)le32_to_cpu(raw_inode->i_atime);
@@ -1413,8 +1417,8 @@ static int __ext2_write_inode(struct inode *inode, int do_sync)
 	struct ext2_inode_info *ei = EXT2_I(inode);
 	struct super_block *sb = inode->i_sb;
 	ino_t ino = inode->i_ino;
-	uid_t uid = inode->i_uid;
-	gid_t gid = inode->i_gid;
+	uid_t uid = i_uid_read(inode);
+	gid_t gid = i_gid_read(inode);
 	struct buffer_head * bh;
 	struct ext2_inode * raw_inode = ext2_get_inode(sb, ino, &bh);
 	int n;
@@ -1529,8 +1533,8 @@ int ext2_setattr(struct dentry *dentry, struct iattr *iattr)
 
 	if (is_quota_modification(inode, iattr))
 		dquot_initialize(inode);
-	if ((iattr->ia_valid & ATTR_UID && iattr->ia_uid != inode->i_uid) ||
-	    (iattr->ia_valid & ATTR_GID && iattr->ia_gid != inode->i_gid)) {
+	if ((iattr->ia_valid & ATTR_UID && !uid_eq(iattr->ia_uid, inode->i_uid)) ||
+	    (iattr->ia_valid & ATTR_GID && !gid_eq(iattr->ia_gid, inode->i_gid))) {
 		error = dquot_transfer(inode, iattr);
 		if (error)
 			return error;
diff --git a/fs/ext2/super.c b/fs/ext2/super.c
index e1025c7..38f8160 100644
--- a/fs/ext2/super.c
+++ b/fs/ext2/super.c
@@ -228,13 +228,15 @@ static int ext2_show_options(struct seq_file *seq, struct dentry *root)
 		seq_puts(seq, ",grpid");
 	if (!test_opt(sb, GRPID) && (def_mount_opts & EXT2_DEFM_BSDGROUPS))
 		seq_puts(seq, ",nogrpid");
-	if (sbi->s_resuid != EXT2_DEF_RESUID ||
+	if (!uid_eq(sbi->s_resuid, make_kuid(&init_user_ns, EXT2_DEF_RESUID)) ||
 	    le16_to_cpu(es->s_def_resuid) != EXT2_DEF_RESUID) {
-		seq_printf(seq, ",resuid=%u", sbi->s_resuid);
+		seq_printf(seq, ",resuid=%u",
+				from_kuid_munged(&init_user_ns, sbi->s_resuid));
 	}
-	if (sbi->s_resgid != EXT2_DEF_RESGID ||
+	if (!gid_eq(sbi->s_resgid, make_kgid(&init_user_ns, EXT2_DEF_RESGID)) ||
 	    le16_to_cpu(es->s_def_resgid) != EXT2_DEF_RESGID) {
-		seq_printf(seq, ",resgid=%u", sbi->s_resgid);
+		seq_printf(seq, ",resgid=%u",
+				from_kgid_munged(&init_user_ns, sbi->s_resgid));
 	}
 	if (test_opt(sb, ERRORS_RO)) {
 		int def_errors = le16_to_cpu(es->s_errors);
@@ -436,6 +438,8 @@ static int parse_options(char *options, struct super_block *sb)
 	struct ext2_sb_info *sbi = EXT2_SB(sb);
 	substring_t args[MAX_OPT_ARGS];
 	int option;
+	kuid_t uid;
+	kgid_t gid;
 
 	if (!options)
 		return 1;
@@ -462,12 +466,23 @@ static int parse_options(char *options, struct super_block *sb)
 		case Opt_resuid:
 			if (match_int(&args[0], &option))
 				return 0;
-			sbi->s_resuid = option;
+			uid = make_kuid(current_user_ns(), option);
+			if (!uid_valid(uid)) {
+				ext2_msg(sb, KERN_ERR, "Invalid uid value %d", option);
+				return -1;
+
+			}
+			sbi->s_resuid = uid;
 			break;
 		case Opt_resgid:
 			if (match_int(&args[0], &option))
 				return 0;
-			sbi->s_resgid = option;
+			gid = make_kgid(current_user_ns(), option);
+			if (!gid_valid(gid)) {
+				ext2_msg(sb, KERN_ERR, "Invalid gid value %d", option);
+				return -1;
+			}
+			sbi->s_resgid = gid;
 			break;
 		case Opt_sb:
 			/* handled by get_sb_block() instead of here */
@@ -841,8 +856,8 @@ static int ext2_fill_super(struct super_block *sb, void *data, int silent)
 	else
 		set_opt(sbi->s_mount_opt, ERRORS_RO);
 
-	sbi->s_resuid = le16_to_cpu(es->s_def_resuid);
-	sbi->s_resgid = le16_to_cpu(es->s_def_resgid);
+	sbi->s_resuid = make_kuid(&init_user_ns, le16_to_cpu(es->s_def_resuid));
+	sbi->s_resgid = make_kgid(&init_user_ns, le16_to_cpu(es->s_def_resgid));
 	
 	set_opt(sbi->s_mount_opt, RESERVATION);
 
-- 
1.7.2.5
