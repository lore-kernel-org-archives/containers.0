Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D9443C456F;
	Mon, 13 Apr 2026 11:22:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776079357; cv=none; b=MhnCwWFCgP84S5jKdRV66f3WqmM863zOwvS0QEPEIg/j6nMgnutTXdw7+crvfUjZbqhsJ3KjVPtFjNRbgNtnbHz9tRhq2H6JWhCjIft4OJbJrmpLWSSLvI63DlNPd/7vr8wz359nWiX/R4jBPbb/6BqPiwrB72ppVpkT1YC5PWY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776079357; c=relaxed/simple;
	bh=5hgEljYltABvDGV+0FITDfNO2kQKx19vmq3Iy9sLHxo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=afg8uJlYNLI4c/nKgwx+CZSD/gNblcIKOK5JglYYSrFG5liYrMl/ISxTMYSaLoaONbVb2gLDecA4FRGV8X50qqVCe8bozhHw8dYqcICt77e2txvvc3YtD8W93++FktMwV4ZXX6HlL7kc3Oo8VpCFPEGuzeluJVTuMdiHG8NnT18=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SZNuRsaL; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SZNuRsaL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 79B0CC2BCB4;
	Mon, 13 Apr 2026 11:22:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776079357;
	bh=5hgEljYltABvDGV+0FITDfNO2kQKx19vmq3Iy9sLHxo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=SZNuRsaLnEKtT4yp7vU90mNtnFgMjD4IEvJ/0lSwV+oSSAhVazhyxhuRn2rwUq5Zv
	 /1N3dkNiW4xMW8iDKUinJv8rd7WQVhUeTIQzEciCUHXS1dAyTpGdXBZQUO2FO/RMTm
	 P413DtnKQau3a4yb+X10dv1zHMbAeB21Nsu2UnBFZWJukPiafbUkfQEzkqJD9fvJ7G
	 UcXzMUWU2hfKrrAavStK4rFwpjuxWDHwRlBBUGbQQjjsthgq3jArnw7MHWNd55WjAC
	 D3YGVHWua1BOyeZgmJ2Qwjg7WZ/bAIFZXJIjhk8JPHAjVJl+gEcPijbiVlX1hcCwvV
	 N4n1U6hINKNiQ==
From: Alexey Gladkov <legion@kernel.org>
To: Christian Brauner <brauner@kernel.org>,
	Dan Klishch <danilklishch@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kees Cook <keescook@chromium.org>,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v9 4/5] proc: Skip the visibility check if subset=pid is used
Date: Mon, 13 Apr 2026 13:19:43 +0200
Message-ID: <38572c1fb7cf55b4c27dd792adafa52f1216e3a3.1776079055.git.legion@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1776079055.git.legion@kernel.org>
References: <cover.1770979341.git.legion@kernel.org> <cover.1776079055.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When procfs is mounted with the subset=pid option, all system files and
directories from the root of the filesystem are not accessible in
userspace. Only dynamic information about processes is available, which
cannot be hidden with overmount.

For this reason, checking for full visibility is not relevant if mounting
is performed with the subset=pid option.

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 fs/fs_context.c            |  1 +
 fs/namespace.c             | 15 +++++++--------
 fs/proc/root.c             |  7 +++++++
 include/linux/fs_context.h |  1 +
 4 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/fs_context.c b/fs/fs_context.c
index a37b0a093505..2fd3d6422a38 100644
--- a/fs/fs_context.c
+++ b/fs/fs_context.c
@@ -545,6 +545,7 @@ void vfs_clean_context(struct fs_context *fc)
 	kfree(fc->source);
 	fc->source = NULL;
 	fc->exclusive = false;
+	fc->skip_visibility = false;
 
 	fc->purpose = FS_CONTEXT_FOR_RECONFIGURE;
 	fc->phase = FS_CONTEXT_AWAITING_RECONF;
diff --git a/fs/namespace.c b/fs/namespace.c
index 539b74403072..32aaedb020c1 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3755,7 +3755,7 @@ static int do_add_mount(struct mount *newmnt, const struct pinned_mountpoint *mp
 	return graft_tree(newmnt, mp);
 }
 
-static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags);
+static bool mount_too_revealing(struct fs_context *fc, int *new_mnt_flags);
 
 /*
  * Create a new mount using a superblock configuration and request it
@@ -3764,19 +3764,17 @@ static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags
 static int do_new_mount_fc(struct fs_context *fc, const struct path *mountpoint,
 			   unsigned int mnt_flags)
 {
-	struct super_block *sb;
 	struct vfsmount *mnt __free(mntput) = fc_mount(fc);
 	int error;
 
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
 
-	sb = fc->root->d_sb;
-	error = security_sb_kern_mount(sb);
+	error = security_sb_kern_mount(fc->root->d_sb);
 	if (unlikely(error))
 		return error;
 
-	if (unlikely(mount_too_revealing(sb, &mnt_flags))) {
+	if (unlikely(mount_too_revealing(fc, &mnt_flags))) {
 		errorfcp(fc, "VFS", "Mount too revealing");
 		return -EPERM;
 	}
@@ -4463,7 +4461,7 @@ SYSCALL_DEFINE3(fsmount, int, fs_fd, unsigned int, flags,
 		return ret;
 
 	ret = -EPERM;
-	if (mount_too_revealing(fc->root->d_sb, &mnt_flags)) {
+	if (mount_too_revealing(fc, &mnt_flags)) {
 		errorfcp(fc, "VFS", "Mount too revealing");
 		return ret;
 	}
@@ -6368,10 +6366,11 @@ static bool mnt_already_visible(struct mnt_namespace *ns,
 	return false;
 }
 
-static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags)
+static bool mount_too_revealing(struct fs_context *fc, int *new_mnt_flags)
 {
 	const unsigned long required_iflags = SB_I_NOEXEC | SB_I_NODEV;
 	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
+	const struct super_block *sb = fc->root->d_sb;
 	unsigned long s_iflags;
 
 	if (ns->user_ns == &init_user_ns)
@@ -6388,7 +6387,7 @@ static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags
 		return true;
 	}
 
-	return !mnt_already_visible(ns, sb, new_mnt_flags);
+	return (!fc->skip_visibility && !mnt_already_visible(ns, sb, new_mnt_flags));
 }
 
 bool mnt_may_suid(struct vfsmount *mnt)
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 05558654df31..6dc870b3061b 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -263,6 +263,13 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 	if (ret)
 		return ret;
 
+	/*
+	 * The dynamic part of procfs cannot be hidden using overmount.
+	 * Therefore, the check for "not fully visible" can be skipped.
+	 */
+	if (fs_info->pidonly)
+		fc->skip_visibility = true;
+
 	/* User space would break if executables or devices appear on proc */
 	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
 	s->s_flags |= SB_NODIRATIME | SB_NOSUID | SB_NOEXEC;
diff --git a/include/linux/fs_context.h b/include/linux/fs_context.h
index 0d6c8a6d7be2..d80b77df2628 100644
--- a/include/linux/fs_context.h
+++ b/include/linux/fs_context.h
@@ -110,6 +110,7 @@ struct fs_context {
 	bool			global:1;	/* Goes into &init_user_ns */
 	bool			oldapi:1;	/* Coming from mount(2) */
 	bool			exclusive:1;    /* create new superblock, reject existing one */
+	bool			skip_visibility:1; /* Skip visibility check for SB_I_USERNS_VISIBLE */
 };
 
 struct fs_context_operations {
-- 
2.53.0

