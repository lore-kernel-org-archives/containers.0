From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 36/43] userns: Convert ext3 to use kuid/kgid where appropriate
Date: Sat,  7 Apr 2012 22:15:32 -0700
Message-ID: <1333862139-31737-36-git-send-email-ebiederm__20547.7746589624$1333862179$gmane$org@xmission.com>
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
 fs/ext3/balloc.c            |    5 +++--
 fs/ext3/ext3.h              |    8 ++++----
 fs/ext3/inode.c             |   32 ++++++++++++++++++++------------
 fs/ext3/super.c             |   35 +++++++++++++++++++++++++----------
 include/trace/events/ext3.h |    4 ++--
 5 files changed, 54 insertions(+), 30 deletions(-)

diff --git a/fs/ext3/balloc.c b/fs/ext3/balloc.c
index baac1b1..25cd608 100644
--- a/fs/ext3/balloc.c
+++ b/fs/ext3/balloc.c
@@ -1439,8 +1439,9 @@ static int ext3_has_free_blocks(struct ext3_sb_info *sbi, int use_reservation)
 	free_blocks = percpu_counter_read_positive(&sbi->s_freeblocks_counter);
 	root_blocks = le32_to_cpu(sbi->s_es->s_r_blocks_count);
 	if (free_blocks < root_blocks + 1 && !capable(CAP_SYS_RESOURCE) &&
-		!use_reservation && sbi->s_resuid != current_fsuid() &&
-		(sbi->s_resgid == 0 || !in_group_p (sbi->s_resgid))) {
+		!use_reservation && !uid_eq(sbi->s_resuid, current_fsuid()) &&
+		(gid_eq(sbi->s_resgid, GLOBAL_ROOT_GID) ||
+		 !in_group_p (sbi->s_resgid))) {
 		return 0;
 	}
 	return 1;
diff --git a/fs/ext3/ext3.h b/fs/ext3/ext3.h
index b6515fd..7977973 100644
--- a/fs/ext3/ext3.h
+++ b/fs/ext3/ext3.h
@@ -243,8 +243,8 @@ struct ext3_new_group_data {
  */
 struct ext3_mount_options {
 	unsigned long s_mount_opt;
-	uid_t s_resuid;
-	gid_t s_resgid;
+	kuid_t s_resuid;
+	kgid_t s_resgid;
 	unsigned long s_commit_interval;
 #ifdef CONFIG_QUOTA
 	int s_jquota_fmt;
@@ -637,8 +637,8 @@ struct ext3_sb_info {
 	struct buffer_head ** s_group_desc;
 	unsigned long  s_mount_opt;
 	ext3_fsblk_t s_sb_block;
-	uid_t s_resuid;
-	gid_t s_resgid;
+	kuid_t s_resuid;
+	kgid_t s_resgid;
 	unsigned short s_mount_state;
 	unsigned short s_pad;
 	int s_addr_per_block_bits;
diff --git a/fs/ext3/inode.c b/fs/ext3/inode.c
index 10d7812..a09790a 100644
--- a/fs/ext3/inode.c
+++ b/fs/ext3/inode.c
@@ -2891,6 +2891,8 @@ struct inode *ext3_iget(struct super_block *sb, unsigned long ino)
 	transaction_t *transaction;
 	long ret;
 	int block;
+	uid_t i_uid;
+	gid_t i_gid;
 
 	inode = iget_locked(sb, ino);
 	if (!inode)
@@ -2907,12 +2909,14 @@ struct inode *ext3_iget(struct super_block *sb, unsigned long ino)
 	bh = iloc.bh;
 	raw_inode = ext3_raw_inode(&iloc);
 	inode->i_mode = le16_to_cpu(raw_inode->i_mode);
-	inode->i_uid = (uid_t)le16_to_cpu(raw_inode->i_uid_low);
-	inode->i_gid = (gid_t)le16_to_cpu(raw_inode->i_gid_low);
+	i_uid = (uid_t)le16_to_cpu(raw_inode->i_uid_low);
+	i_gid = (gid_t)le16_to_cpu(raw_inode->i_gid_low);
 	if(!(test_opt (inode->i_sb, NO_UID32))) {
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
@@ -3068,6 +3072,8 @@ static int ext3_do_update_inode(handle_t *handle,
 	struct ext3_inode_info *ei = EXT3_I(inode);
 	struct buffer_head *bh = iloc->bh;
 	int err = 0, rc, block;
+	uid_t i_uid;
+	gid_t i_gid;
 
 again:
 	/* we can't allow multiple procs in here at once, its a bit racey */
@@ -3080,27 +3086,29 @@ again:
 
 	ext3_get_inode_flags(ei);
 	raw_inode->i_mode = cpu_to_le16(inode->i_mode);
+	i_uid = i_uid_read(inode);
+	i_gid = i_gid_read(inode);
 	if(!(test_opt(inode->i_sb, NO_UID32))) {
-		raw_inode->i_uid_low = cpu_to_le16(low_16_bits(inode->i_uid));
-		raw_inode->i_gid_low = cpu_to_le16(low_16_bits(inode->i_gid));
+		raw_inode->i_uid_low = cpu_to_le16(low_16_bits(i_uid));
+		raw_inode->i_gid_low = cpu_to_le16(low_16_bits(i_gid));
 /*
  * Fix up interoperability with old kernels. Otherwise, old inodes get
  * re-used with the upper 16 bits of the uid/gid intact
  */
 		if(!ei->i_dtime) {
 			raw_inode->i_uid_high =
-				cpu_to_le16(high_16_bits(inode->i_uid));
+				cpu_to_le16(high_16_bits(i_uid));
 			raw_inode->i_gid_high =
-				cpu_to_le16(high_16_bits(inode->i_gid));
+				cpu_to_le16(high_16_bits(i_gid));
 		} else {
 			raw_inode->i_uid_high = 0;
 			raw_inode->i_gid_high = 0;
 		}
 	} else {
 		raw_inode->i_uid_low =
-			cpu_to_le16(fs_high2lowuid(inode->i_uid));
+			cpu_to_le16(fs_high2lowuid(i_uid));
 		raw_inode->i_gid_low =
-			cpu_to_le16(fs_high2lowgid(inode->i_gid));
+			cpu_to_le16(fs_high2lowgid(i_gid));
 		raw_inode->i_uid_high = 0;
 		raw_inode->i_gid_high = 0;
 	}
@@ -3262,8 +3270,8 @@ int ext3_setattr(struct dentry *dentry, struct iattr *attr)
 
 	if (is_quota_modification(inode, attr))
 		dquot_initialize(inode);
-	if ((ia_valid & ATTR_UID && attr->ia_uid != inode->i_uid) ||
-		(ia_valid & ATTR_GID && attr->ia_gid != inode->i_gid)) {
+	if ((ia_valid & ATTR_UID && !uid_eq(attr->ia_uid, inode->i_uid)) ||
+	    (ia_valid & ATTR_GID && !gid_eq(attr->ia_gid, inode->i_gid))) {
 		handle_t *handle;
 
 		/* (user+group)*(old+new) structure, inode write (sb,
diff --git a/fs/ext3/super.c b/fs/ext3/super.c
index cf0b592..94ef7e6 100644
--- a/fs/ext3/super.c
+++ b/fs/ext3/super.c
@@ -617,13 +617,15 @@ static int ext3_show_options(struct seq_file *seq, struct dentry *root)
 		seq_puts(seq, ",grpid");
 	if (!test_opt(sb, GRPID) && (def_mount_opts & EXT3_DEFM_BSDGROUPS))
 		seq_puts(seq, ",nogrpid");
-	if (sbi->s_resuid != EXT3_DEF_RESUID ||
+	if (!uid_eq(sbi->s_resuid, make_kuid(&init_user_ns, EXT3_DEF_RESUID)) ||
 	    le16_to_cpu(es->s_def_resuid) != EXT3_DEF_RESUID) {
-		seq_printf(seq, ",resuid=%u", sbi->s_resuid);
+		seq_printf(seq, ",resuid=%u",
+				from_kuid_munged(&init_user_ns, sbi->s_resuid));
 	}
-	if (sbi->s_resgid != EXT3_DEF_RESGID ||
+	if (!gid_eq(sbi->s_resgid, make_kgid(&init_user_ns, EXT3_DEF_RESGID)) ||
 	    le16_to_cpu(es->s_def_resgid) != EXT3_DEF_RESGID) {
-		seq_printf(seq, ",resgid=%u", sbi->s_resgid);
+		seq_printf(seq, ",resgid=%u",
+				from_kgid_munged(&init_user_ns, sbi->s_resgid));
 	}
 	if (test_opt(sb, ERRORS_RO)) {
 		int def_errors = le16_to_cpu(es->s_errors);
@@ -967,6 +969,8 @@ static int parse_options (char *options, struct super_block *sb,
 	substring_t args[MAX_OPT_ARGS];
 	int data_opt = 0;
 	int option;
+	kuid_t uid;
+	kgid_t gid;
 #ifdef CONFIG_QUOTA
 	int qfmt;
 #endif
@@ -1000,12 +1004,23 @@ static int parse_options (char *options, struct super_block *sb,
 		case Opt_resuid:
 			if (match_int(&args[0], &option))
 				return 0;
-			sbi->s_resuid = option;
+			uid = make_kuid(current_user_ns(), option);
+			if (!uid_valid(uid)) {
+				ext3_msg(sb, KERN_ERR, "Invalid uid value %d", option);
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
+				ext3_msg(sb, KERN_ERR, "Invalid gid value %d", option);
+				return -1;
+			}
+			sbi->s_resgid = gid;
 			break;
 		case Opt_sb:
 			/* handled by get_sb_block() instead of here */
@@ -1651,8 +1666,8 @@ static int ext3_fill_super (struct super_block *sb, void *data, int silent)
 	}
 	sb->s_fs_info = sbi;
 	sbi->s_mount_opt = 0;
-	sbi->s_resuid = EXT3_DEF_RESUID;
-	sbi->s_resgid = EXT3_DEF_RESGID;
+	sbi->s_resuid = make_kuid(&init_user_ns, EXT3_DEF_RESUID);
+	sbi->s_resgid = make_kgid(&init_user_ns, EXT3_DEF_RESGID);
 	sbi->s_sb_block = sb_block;
 
 	blocksize = sb_min_blocksize(sb, EXT3_MIN_BLOCK_SIZE);
@@ -1716,8 +1731,8 @@ static int ext3_fill_super (struct super_block *sb, void *data, int silent)
 	else
 		set_opt(sbi->s_mount_opt, ERRORS_RO);
 
-	sbi->s_resuid = le16_to_cpu(es->s_def_resuid);
-	sbi->s_resgid = le16_to_cpu(es->s_def_resgid);
+	sbi->s_resuid = make_kuid(&init_user_ns, le16_to_cpu(es->s_def_resuid));
+	sbi->s_resgid = make_kgid(&init_user_ns, le16_to_cpu(es->s_def_resgid));
 
 	/* enable barriers by default */
 	set_opt(sbi->s_mount_opt, BARRIER);
diff --git a/include/trace/events/ext3.h b/include/trace/events/ext3.h
index 7b53c05..15d11a3 100644
--- a/include/trace/events/ext3.h
+++ b/include/trace/events/ext3.h
@@ -24,8 +24,8 @@ TRACE_EVENT(ext3_free_inode,
 		__entry->dev	= inode->i_sb->s_dev;
 		__entry->ino	= inode->i_ino;
 		__entry->mode	= inode->i_mode;
-		__entry->uid	= inode->i_uid;
-		__entry->gid	= inode->i_gid;
+		__entry->uid	= i_uid_read(inode);
+		__entry->gid	= i_gid_read(inode);
 		__entry->blocks	= inode->i_blocks;
 	),
 
-- 
1.7.2.5
