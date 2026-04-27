Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E8A239B4BB;
	Mon, 27 Apr 2026 08:27:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777278429; cv=none; b=aaocYoCqEtzy5ofjYGNWF1n50B+fZdpJl96JK60frecQjgJ/0LzYNd8aoaCVefVc9SLNx/rMhymZndfHfNtrlOTS0+b2FYIpZ4zWq3xkpSRmloqnVJ8PkjTDjcbDKNS2KMN212wE9rRtcN8MS5WFofR8hVZ6xPsAUgLDXnWKgXQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777278429; c=relaxed/simple;
	bh=5zkkuQMPyAXleKE4/+XDYuvRaItMKHwmoNXSzv0Vp1g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CzyvbKvfsvqZ3sIZceBHHTxmU7GujSi5wQCE7utSqy43AReJMzCQGYHXSNTOWIklJa+9uCDWV61ZfF9Hsm3fArj1QUSkrikGYbFE9ly9R48DxJYa2IGuWsmtiyFYsfYPqrhoJraS2iIxGx6qPGbEXNGNHvV94xcyXu4yb/Z84qM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aNC2Iwj6; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aNC2Iwj6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8630AC19425;
	Mon, 27 Apr 2026 08:27:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1777278429;
	bh=5zkkuQMPyAXleKE4/+XDYuvRaItMKHwmoNXSzv0Vp1g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=aNC2Iwj6ezrquWrmD3ZUHBzkXuFURwGvfH47VDmPjxddXS8ABX6NolgrQjTylGpzM
	 dM1JKb0x4emJn6V3Rm51pe3OaJpntMLAFPwrq8GlXH3oAecjOnxGy91RP2iCNjGp1v
	 gdlDehlKzExbPT1syacj0xfhK76kyL8ZUdeMHRI6YCNHFJUSPrhBDmR4uJ3Yi8Cbyj
	 0XsyTBypSZYh67QERJ67+3MM8jgxxmEILIMxS32DuV0KyuqRTr2ZgiReHnkmiFQ85u
	 AKQQ/9XIfiILu7FOGbAeEt0d6d4j73Nz7x03iVsl27CjnrCBoy/XJYkSBK2YdcMjtw
	 +J6wb4+UXlcxg==
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
Subject: [PATCH v10 6/7] proc: handle subset=pid separately in userns visibility checks
Date: Mon, 27 Apr 2026 10:26:07 +0200
Message-ID: <4d5e760c3d534dd2e05578d119cc408450053a98.1777278334.git.legion@kernel.org>
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

When procfs is mounted with subset=pid, only the dynamic process-related
part of the filesystem remains visible. That part cannot be hidden by
overmounts, so checking whether an existing procfs mount is fully
visible does not make sense for this mode.

At the same time, a subset=pid procfs mount must not be used as evidence
that a later procfs mount would not reveal additional information. It
provides a restricted view of procfs, not the full filesystem view.

Mark subset=pid procfs instances as restricted variants. Ignore
restricted variants when looking for an already-visible mount, and allow
new restricted variants without consulting mnt_already_visible().

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 fs/namespace.c                 | 17 ++++++++++++++++-
 fs/proc/root.c                 |  3 +++
 include/linux/fs/super_types.h |  1 +
 3 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index ed13416370e3..389d8654f36f 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -6323,10 +6323,18 @@ static bool mnt_already_visible(struct mnt_namespace *ns,
 
 	guard(namespace_shared)();
 	hlist_for_each_entry(mnt, &ns->mnt_visible_mounts, mnt_ns_visible) {
+		const struct super_block *sb_visible = mnt->mnt.mnt_sb;
 		struct mount *child;
 		int mnt_flags;
 
-		if (mnt->mnt.mnt_sb->s_type != sb->s_type)
+		if (sb_visible->s_type != sb->s_type)
+			continue;
+
+		/*
+		 * Restricted variants are not compatible with anything, even
+		 * other restricted variants.
+		 */
+		if (sb_visible->s_iflags & SB_I_RESTRICTED_VARIANT)
 			continue;
 
 		/* A local view of the mount flags */
@@ -6388,6 +6396,13 @@ static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags
 		return true;
 	}
 
+	/*
+	 * Restricted variants don't need an already visible mount because they
+	 * don't expose the full filesystem view.
+	 */
+	if (s_iflags & SB_I_RESTRICTED_VARIANT)
+		return false;
+
 	return !mnt_already_visible(ns, sb, new_mnt_flags);
 }
 
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 1bf75a4ee146..99adddfeb4a4 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -275,6 +275,9 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 	s->s_time_gran = 1;
 	s->s_fs_info = fs_info;
 
+	if (fs_info->pidonly == PROC_PIDONLY_ON)
+		s->s_iflags |= SB_I_RESTRICTED_VARIANT;
+
 	/*
 	 * procfs isn't actually a stacking filesystem; however, there is
 	 * too much magic going on inside it to permit stacking things on
diff --git a/include/linux/fs/super_types.h b/include/linux/fs/super_types.h
index 182efbeb9520..a6cdc8f6de4e 100644
--- a/include/linux/fs/super_types.h
+++ b/include/linux/fs/super_types.h
@@ -326,6 +326,7 @@ struct super_block {
 #define SB_I_STABLE_WRITES 0x00000008	/* don't modify blks until WB is done */
 
 /* sb->s_iflags to limit user namespace mounts */
+#define SB_I_RESTRICTED_VARIANT		0x00000010
 #define SB_I_IMA_UNVERIFIABLE_SIGNATURE	0x00000020
 #define SB_I_UNTRUSTED_MOUNTER		0x00000040
 #define SB_I_EVM_HMAC_UNSUPPORTED	0x00000080
-- 
2.54.0

