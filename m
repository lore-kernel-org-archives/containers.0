Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1B4F939B495;
	Mon, 27 Apr 2026 08:26:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777278420; cv=none; b=Pazzz2Z2sOEJtbcxasROMi5tUGs60ll1C1WoK1IXaoa9vg4lecBnwN4k7IMDTr3aEUASxxL1Bh5ZHxZvpbpjiSzNh7yQ7NfyMLx8EuNNxDT2ecb0i5uEPKVOUiLEf+7TgFZEH3+az9fYxP2fjBj7YTPZ3wxgJqH1A1q3ikHAPLA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777278420; c=relaxed/simple;
	bh=U+1YtcWZiR0EbNPQMRPeDg2eGpcjr6DYpzp5NaT9tKU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OKeCUXw4G7zvVe0ojZhaK+Zx3P7cY9ArIS7hXrUQ6UvEeAVlJXkZZnxq40cqTuzmT2/GhYWFdO/llyQThA4/M1hLgAzniu65oDcO/WOyOjhQiYuNwBui4FdD88/RdugfdghHUUqhJU/gkCRm8/Tc7OXoBMCfpX4vThwwDGbCNqE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AWF/H8qx; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AWF/H8qx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B6D82C19425;
	Mon, 27 Apr 2026 08:26:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1777278419;
	bh=U+1YtcWZiR0EbNPQMRPeDg2eGpcjr6DYpzp5NaT9tKU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=AWF/H8qxP57Yyz3cNGGESauAUNI73eCg0p6RXAs6iQl/qojReGhmxPQYVQsyYO35h
	 93vOzh9L/0etN3o+01x2ZzfXC6vILKVG9UxQAPEIMgDBzW0B/JBkj3dbokbOnELe6o
	 bk9Pm6eaaIs89Qk417Fsl2O6O7XQaVmabjzfLT7uHf7MCJOMtQA6ICj5XrHsGBix1n
	 aE43rU3SXl397Y2COnNq3y0FINBSpwSWHbvy31SvMDMKevrSlCCI0Uby7mp/bhKbuV
	 DwNagrruuBhRM1HT7bE9ZtgILYIIFnhtc94KIc71jcf4M8py9Gr+X1/OXq5cEoTsSk
	 AgVMLzz+OjmJg==
From: Alexey Gladkov <legion@kernel.org>
To: Christian Brauner <brauner@kernel.org>,
	Dan Klishch <danilklishch@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Aleksa Sarai <cyphar@cyphar.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kees Cook <keescook@chromium.org>,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v10 2/7] fs: move SB_I_USERNS_VISIBLE to FS_USERNS_MOUNT_RESTRICTED
Date: Mon, 27 Apr 2026 10:26:03 +0200
Message-ID: <72887c5b6204dc3adf5a53104f0be6bd8bc4f6cd.1777278334.git.legion@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <cover.1777278334.git.legion@kernel.org>
References: <cover.1776079055.git.legion@kernel.org> <cover.1777278334.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Christian Brauner <brauner@kernel.org>

Whether a filesystem's mounts need to undergo a visibility check in user
namespaces is a static property of the filesystem type, not a runtime
property of each superblock instance. Both proc and sysfs always set
SB_I_USERNS_VISIBLE on their superblocks unconditionally (sysfs does so
on first creation, and subsequent mounts reuse the same superblock).

Move this flag from sb->s_iflags (SB_I_USERNS_VISIBLE) to
file_system_type->fs_flags (FS_USERNS_MOUNT_RESTRICTED) so the intent
is expressed at the filesystem type level where it belongs.

All check sites are updated to test sb->s_type->fs_flags instead of
sb->s_iflags. The SB_I_NOEXEC and SB_I_NODEV flags remain on the
superblock as they are runtime properties set during fill_super.

Signed-off-by: Christian Brauner <brauner@kernel.org>
---
 fs/namespace.c                 | 6 +++---
 fs/proc/root.c                 | 4 ++--
 fs/sysfs/mount.c               | 4 +---
 include/linux/fs.h             | 1 +
 include/linux/fs/super_types.h | 1 -
 kernel/acct.c                  | 2 +-
 6 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 539b74403072..ed13416370e3 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1099,7 +1099,7 @@ static void mnt_add_to_ns(struct mnt_namespace *ns, struct mount *mnt)
 	rb_link_node(&mnt->mnt_node, parent, link);
 	rb_insert_color(&mnt->mnt_node, &ns->mounts);
 
-	if ((mnt->mnt.mnt_sb->s_iflags & SB_I_USERNS_VISIBLE) &&
+	if ((mnt->mnt.mnt_sb->s_type->fs_flags & FS_USERNS_MOUNT_RESTRICTED) &&
 	    mnt->mnt.mnt_root == mnt->mnt.mnt_sb->s_root)
 		hlist_add_head(&mnt->mnt_ns_visible, &ns->mnt_visible_mounts);
 
@@ -6378,10 +6378,10 @@ static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags
 		return false;
 
 	/* Can this filesystem be too revealing? */
-	s_iflags = sb->s_iflags;
-	if (!(s_iflags & SB_I_USERNS_VISIBLE))
+	if (!(sb->s_type->fs_flags & FS_USERNS_MOUNT_RESTRICTED))
 		return false;
 
+	s_iflags = sb->s_iflags;
 	if ((s_iflags & required_iflags) != required_iflags) {
 		WARN_ONCE(1, "Expected s_iflags to contain 0x%lx\n",
 			  required_iflags);
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 0f9100559471..b65053f9f046 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -257,7 +257,7 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 	proc_apply_options(fs_info, fc, current_user_ns());
 
 	/* User space would break if executables or devices appear on proc */
-	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
+	s->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
 	s->s_flags |= SB_NODIRATIME | SB_NOSUID | SB_NOEXEC;
 	s->s_blocksize = 1024;
 	s->s_blocksize_bits = 10;
@@ -359,7 +359,7 @@ static struct file_system_type proc_fs_type = {
 	.init_fs_context	= proc_init_fs_context,
 	.parameters		= proc_fs_parameters,
 	.kill_sb		= proc_kill_sb,
-	.fs_flags		= FS_USERNS_MOUNT | FS_DISALLOW_NOTIFY_PERM,
+	.fs_flags		= FS_USERNS_MOUNT | FS_USERNS_MOUNT_RESTRICTED | FS_DISALLOW_NOTIFY_PERM,
 };
 
 void __init proc_root_init(void)
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index b199e8ff79b1..b45ea5d511e7 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -32,8 +32,6 @@ static int sysfs_get_tree(struct fs_context *fc)
 	if (ret)
 		return ret;
 
-	if (kfc->new_sb_created)
-		fc->root->d_sb->s_iflags |= SB_I_USERNS_VISIBLE;
 	return 0;
 }
 
@@ -93,7 +91,7 @@ static struct file_system_type sysfs_fs_type = {
 	.name			= "sysfs",
 	.init_fs_context	= sysfs_init_fs_context,
 	.kill_sb		= sysfs_kill_sb,
-	.fs_flags		= FS_USERNS_MOUNT,
+	.fs_flags		= FS_USERNS_MOUNT | FS_USERNS_MOUNT_RESTRICTED,
 };
 
 int __init sysfs_init(void)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8b3dd145b25e..4e6553359938 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2280,6 +2280,7 @@ struct file_system_type {
 #define FS_MGTIME		64	/* FS uses multigrain timestamps */
 #define FS_LBS			128	/* FS supports LBS */
 #define FS_POWER_FREEZE		256	/* Always freeze on suspend/hibernate */
+#define FS_USERNS_MOUNT_RESTRICTED 512	/* Restrict mount in userns if not already visible */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
 	int (*init_fs_context)(struct fs_context *);
 	const struct fs_parameter_spec *parameters;
diff --git a/include/linux/fs/super_types.h b/include/linux/fs/super_types.h
index 383050e7fdf5..182efbeb9520 100644
--- a/include/linux/fs/super_types.h
+++ b/include/linux/fs/super_types.h
@@ -326,7 +326,6 @@ struct super_block {
 #define SB_I_STABLE_WRITES 0x00000008	/* don't modify blks until WB is done */
 
 /* sb->s_iflags to limit user namespace mounts */
-#define SB_I_USERNS_VISIBLE		0x00000010 /* fstype already mounted */
 #define SB_I_IMA_UNVERIFIABLE_SIGNATURE	0x00000020
 #define SB_I_UNTRUSTED_MOUNTER		0x00000040
 #define SB_I_EVM_HMAC_UNSUPPORTED	0x00000080
diff --git a/kernel/acct.c b/kernel/acct.c
index 1e19722c64c3..9fdfee6f4729 100644
--- a/kernel/acct.c
+++ b/kernel/acct.c
@@ -249,7 +249,7 @@ static int acct_on(const char __user *name)
 		return -EINVAL;
 
 	/* Exclude procfs and sysfs. */
-	if (file_inode(file)->i_sb->s_iflags & SB_I_USERNS_VISIBLE)
+	if (file_inode(file)->i_sb->s_type->fs_flags & FS_USERNS_MOUNT_RESTRICTED)
 		return -EINVAL;
 
 	if (!(file->f_mode & FMODE_CAN_WRITE))
-- 
2.54.0

