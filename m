From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 37/43] userns: Convert ext4 to user kuid/kgid where appropriate
Date: Sat,  7 Apr 2012 22:15:33 -0700
Message-ID: <1333862139-31737-37-git-send-email-ebiederm__49647.6015811369$1333862148$gmane$org@xmission.com>
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
 fs/ext4/balloc.c            |    4 ++--
 fs/ext4/ext4.h              |    4 ++--
 fs/ext4/ialloc.c            |    4 ++--
 fs/ext4/inode.c             |   34 ++++++++++++++++++++--------------
 fs/ext4/migrate.c           |    4 ++--
 fs/ext4/super.c             |   38 ++++++++++++++++++++++++++------------
 include/trace/events/ext4.h |    4 ++--
 7 files changed, 56 insertions(+), 36 deletions(-)

diff --git a/fs/ext4/balloc.c b/fs/ext4/balloc.c
index 4bbd07a..c45c411 100644
--- a/fs/ext4/balloc.c
+++ b/fs/ext4/balloc.c
@@ -461,8 +461,8 @@ static int ext4_has_free_clusters(struct ext4_sb_info *sbi,
 		return 1;
 
 	/* Hm, nope.  Are (enough) root reserved clusters available? */
-	if (sbi->s_resuid == current_fsuid() ||
-	    ((sbi->s_resgid != 0) && in_group_p(sbi->s_resgid)) ||
+	if (uid_eq(sbi->s_resuid, current_fsuid()) ||
+	    (!gid_eq(sbi->s_resgid, GLOBAL_ROOT_GID) && in_group_p(sbi->s_resgid)) ||
 	    capable(CAP_SYS_RESOURCE) ||
 		(flags & EXT4_MB_USE_ROOT_BLOCKS)) {
 
diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
index ab2594a..0b4aeb2 100644
--- a/fs/ext4/ext4.h
+++ b/fs/ext4/ext4.h
@@ -1153,8 +1153,8 @@ struct ext4_sb_info {
 	unsigned int s_mount_flags;
 	unsigned int s_def_mount_opt;
 	ext4_fsblk_t s_sb_block;
-	uid_t s_resuid;
-	gid_t s_resgid;
+	kuid_t s_resuid;
+	kgid_t s_resgid;
 	unsigned short s_mount_state;
 	unsigned short s_pad;
 	int s_addr_per_block_bits;
diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
index 409c2ee..9f9acac 100644
--- a/fs/ext4/ialloc.c
+++ b/fs/ext4/ialloc.c
@@ -808,8 +808,8 @@ got:
 	}
 	if (owner) {
 		inode->i_mode = mode;
-		inode->i_uid = owner[0];
-		inode->i_gid = owner[1];
+		i_uid_write(inode, owner[0]);
+		i_gid_write(inode, owner[1]);
 	} else if (test_opt(sb, GRPID)) {
 		inode->i_mode = mode;
 		inode->i_uid = current_fsuid();
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index c77b0bd..07eaf56 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -3630,6 +3630,8 @@ struct inode *ext4_iget(struct super_block *sb, unsigned long ino)
 	journal_t *journal = EXT4_SB(sb)->s_journal;
 	long ret;
 	int block;
+	uid_t i_uid;
+	gid_t i_gid;
 
 	inode = iget_locked(sb, ino);
 	if (!inode)
@@ -3645,12 +3647,14 @@ struct inode *ext4_iget(struct super_block *sb, unsigned long ino)
 		goto bad_inode;
 	raw_inode = ext4_raw_inode(&iloc);
 	inode->i_mode = le16_to_cpu(raw_inode->i_mode);
-	inode->i_uid = (uid_t)le16_to_cpu(raw_inode->i_uid_low);
-	inode->i_gid = (gid_t)le16_to_cpu(raw_inode->i_gid_low);
+	i_uid = (uid_t)le16_to_cpu(raw_inode->i_uid_low);
+	i_gid = (gid_t)le16_to_cpu(raw_inode->i_gid_low);
 	if (!(test_opt(inode->i_sb, NO_UID32))) {
-		inode->i_uid |= le16_to_cpu(raw_inode->i_uid_high) << 16;
-		inode->i_gid |= le16_to_cpu(raw_inode->i_gid_high) << 16;
+		i_uid |= le16_to_cpu(raw_inode->i_uid_high) << 16;
+		i_gid |= le16_to_cpu(raw_inode->i_gid_high) << 16;
 	}
+	i_uid_write(inode, i_uid);
+	i_gid_write(inode, i_gid);
 	set_nlink(inode, le16_to_cpu(raw_inode->i_links_count));
 
 	ext4_clear_state_flags(ei);	/* Only relevant on 32-bit archs */
@@ -3870,6 +3874,8 @@ static int ext4_do_update_inode(handle_t *handle,
 	struct ext4_inode_info *ei = EXT4_I(inode);
 	struct buffer_head *bh = iloc->bh;
 	int err = 0, rc, block;
+	uid_t i_uid;
+	gid_t i_gid;
 
 	/* For fields not not tracking in the in-memory inode,
 	 * initialise them to zero for new inodes. */
@@ -3878,27 +3884,27 @@ static int ext4_do_update_inode(handle_t *handle,
 
 	ext4_get_inode_flags(ei);
 	raw_inode->i_mode = cpu_to_le16(inode->i_mode);
+	i_uid = i_uid_read(inode);
+	i_gid = i_gid_read(inode);
 	if (!(test_opt(inode->i_sb, NO_UID32))) {
-		raw_inode->i_uid_low = cpu_to_le16(low_16_bits(inode->i_uid));
-		raw_inode->i_gid_low = cpu_to_le16(low_16_bits(inode->i_gid));
+		raw_inode->i_uid_low = cpu_to_le16(low_16_bits(i_uid));
+		raw_inode->i_gid_low = cpu_to_le16(low_16_bits(i_gid));
 /*
  * Fix up interoperability with old kernels. Otherwise, old inodes get
  * re-used with the upper 16 bits of the uid/gid intact
  */
 		if (!ei->i_dtime) {
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
-		raw_inode->i_uid_low =
-			cpu_to_le16(fs_high2lowuid(inode->i_uid));
-		raw_inode->i_gid_low =
-			cpu_to_le16(fs_high2lowgid(inode->i_gid));
+		raw_inode->i_uid_low = cpu_to_le16(fs_high2lowuid(i_uid));
+		raw_inode->i_gid_low = cpu_to_le16(fs_high2lowgid(i_gid));
 		raw_inode->i_uid_high = 0;
 		raw_inode->i_gid_high = 0;
 	}
@@ -4084,8 +4090,8 @@ int ext4_setattr(struct dentry *dentry, struct iattr *attr)
 
 	if (is_quota_modification(inode, attr))
 		dquot_initialize(inode);
-	if ((ia_valid & ATTR_UID && attr->ia_uid != inode->i_uid) ||
-		(ia_valid & ATTR_GID && attr->ia_gid != inode->i_gid)) {
+	if ((ia_valid & ATTR_UID && !uid_eq(attr->ia_uid, inode->i_uid)) ||
+	    (ia_valid & ATTR_GID && !gid_eq(attr->ia_gid, inode->i_gid))) {
 		handle_t *handle;
 
 		/* (user+group)*(old+new) structure, inode write (sb,
diff --git a/fs/ext4/migrate.c b/fs/ext4/migrate.c
index f39f80f..f1bb32e 100644
--- a/fs/ext4/migrate.c
+++ b/fs/ext4/migrate.c
@@ -466,8 +466,8 @@ int ext4_ext_migrate(struct inode *inode)
 	}
 	goal = (((inode->i_ino - 1) / EXT4_INODES_PER_GROUP(inode->i_sb)) *
 		EXT4_INODES_PER_GROUP(inode->i_sb)) + 1;
-	owner[0] = inode->i_uid;
-	owner[1] = inode->i_gid;
+	owner[0] = i_uid_read(inode);
+	owner[1] = i_gid_read(inode);
 	tmp_inode = ext4_new_inode(handle, inode->i_sb->s_root->d_inode,
 				   S_IFREG, NULL, goal, owner);
 	if (IS_ERR(tmp_inode)) {
diff --git a/fs/ext4/super.c b/fs/ext4/super.c
index ceebaf8..9d8eba0 100644
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -1448,6 +1448,8 @@ static int handle_mount_opt(struct super_block *sb, char *opt, int token,
 {
 	struct ext4_sb_info *sbi = EXT4_SB(sb);
 	const struct mount_opts *m;
+	kuid_t uid;
+	kgid_t gid;
 	int arg = 0;
 
 	if (args->from && match_int(args, &arg))
@@ -1464,10 +1466,20 @@ static int handle_mount_opt(struct super_block *sb, char *opt, int token,
 			 "Ignoring removed %s option", opt);
 		return 1;
 	case Opt_resuid:
-		sbi->s_resuid = arg;
+		uid = make_kuid(current_user_ns(), arg);
+		if (!uid_valid(uid)) {
+			ext4_msg(sb, KERN_ERR, "Invalid uid value %d", arg);
+			return -1;
+		}
+		sbi->s_resuid = uid;
 		return 1;
 	case Opt_resgid:
-		sbi->s_resgid = arg;
+		gid = make_kgid(current_user_ns(), arg);
+		if (!gid_valid(gid)) {
+			ext4_msg(sb, KERN_ERR, "Invalid gid value %d", arg);
+			return -1;
+		}
+		sbi->s_resgid = gid;
 		return 1;
 	case Opt_abort:
 		sbi->s_mount_flags |= EXT4_MF_FS_ABORTED;
@@ -1732,12 +1744,14 @@ static int _ext4_show_options(struct seq_file *seq, struct super_block *sb,
 		SEQ_OPTS_PRINT("%s", token2str(m->token));
 	}
 
-	if (nodefs || sbi->s_resuid != EXT4_DEF_RESUID ||
+	if (nodefs || !uid_eq(sbi->s_resuid, make_kuid(&init_user_ns, EXT4_DEF_RESUID)) ||
 	    le16_to_cpu(es->s_def_resuid) != EXT4_DEF_RESUID)
-		SEQ_OPTS_PRINT("resuid=%u", sbi->s_resuid);
-	if (nodefs || sbi->s_resgid != EXT4_DEF_RESGID ||
+		SEQ_OPTS_PRINT("resuid=%u",
+				from_kuid_munged(&init_user_ns, sbi->s_resuid));
+	if (nodefs || !gid_eq(sbi->s_resgid, make_kgid(&init_user_ns, EXT4_DEF_RESGID)) ||
 	    le16_to_cpu(es->s_def_resgid) != EXT4_DEF_RESGID)
-		SEQ_OPTS_PRINT("resgid=%u", sbi->s_resgid);
+		SEQ_OPTS_PRINT("resgid=%u",
+				from_kgid_munged(&init_user_ns, sbi->s_resgid));
 	def_errors = nodefs ? -1 : le16_to_cpu(es->s_errors);
 	if (test_opt(sb, ERRORS_RO) && def_errors != EXT4_ERRORS_RO)
 		SEQ_OPTS_PUTS("errors=remount-ro");
@@ -2996,8 +3010,8 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 	}
 	sb->s_fs_info = sbi;
 	sbi->s_mount_opt = 0;
-	sbi->s_resuid = EXT4_DEF_RESUID;
-	sbi->s_resgid = EXT4_DEF_RESGID;
+	sbi->s_resuid = make_kuid(&init_user_ns, EXT4_DEF_RESUID);
+	sbi->s_resgid = make_kgid(&init_user_ns, EXT4_DEF_RESGID);
 	sbi->s_inode_readahead_blks = EXT4_DEF_INODE_READAHEAD_BLKS;
 	sbi->s_sb_block = sb_block;
 	if (sb->s_bdev->bd_part)
@@ -3076,8 +3090,8 @@ static int ext4_fill_super(struct super_block *sb, void *data, int silent)
 	if (def_mount_opts & EXT4_DEFM_DISCARD)
 		set_opt(sb, DISCARD);
 
-	sbi->s_resuid = le16_to_cpu(es->s_def_resuid);
-	sbi->s_resgid = le16_to_cpu(es->s_def_resgid);
+	sbi->s_resuid = make_kuid(&init_user_ns, le16_to_cpu(es->s_def_resuid));
+	sbi->s_resgid = make_kgid(&init_user_ns, le16_to_cpu(es->s_def_resgid));
 	sbi->s_commit_interval = JBD2_DEFAULT_MAX_COMMIT_AGE * HZ;
 	sbi->s_min_batch_time = EXT4_DEF_MIN_BATCH_TIME;
 	sbi->s_max_batch_time = EXT4_DEF_MAX_BATCH_TIME;
@@ -4229,8 +4243,8 @@ static int ext4_unfreeze(struct super_block *sb)
 struct ext4_mount_options {
 	unsigned long s_mount_opt;
 	unsigned long s_mount_opt2;
-	uid_t s_resuid;
-	gid_t s_resgid;
+	kuid_t s_resuid;
+	kgid_t s_resgid;
 	unsigned long s_commit_interval;
 	u32 s_min_batch_time, s_max_batch_time;
 #ifdef CONFIG_QUOTA
diff --git a/include/trace/events/ext4.h b/include/trace/events/ext4.h
index 319538b..69d8a69 100644
--- a/include/trace/events/ext4.h
+++ b/include/trace/events/ext4.h
@@ -36,8 +36,8 @@ TRACE_EVENT(ext4_free_inode,
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
