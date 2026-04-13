Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6BC893C3C15;
	Mon, 13 Apr 2026 11:22:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776079355; cv=none; b=kfzft3/O7V1+ADa0QAFm4JB0/wiS599/ftoTcfTpoUYkD3farJHmkr2EmBSGGb5VHbxbTMwxNtjWyg9FUyOR0JAJWBCQHwsl93yhphMtMcVkHp6OvNKfdMleCPik/8sXLTQo1b7nATCmSB0l49rQwre6FkZMd5grh5EXmQm6J/4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776079355; c=relaxed/simple;
	bh=L0acH809vek233P6WxGrNM6Yv7a2Wb2NzaBAvKvNzIc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=kCIjmrHcncua81zKSzSjbZ4c1dkOqfXitwsXUN4nwEa2uGG+dLxSUmLZ6xGYGBpcNqZE9cYgJecgjfJe+abTUkADJTgaGJgGe8LoiPbO2I6+WjL3W8FeBBeyctU2cjTvGKztNhZCcjLvZc3l3i0q4Q17zYc8dfZbCEy0DOYU7Gk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ktv5OFQH; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ktv5OFQH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 34EDDC2BCB1;
	Mon, 13 Apr 2026 11:22:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776079355;
	bh=L0acH809vek233P6WxGrNM6Yv7a2Wb2NzaBAvKvNzIc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ktv5OFQHgLIvOic/9YObLbszJ7eX1bJWEVVfDeNUDQoAzyKLR3qWd1cSVhd8TWEnA
	 E7p6f3ombm8oXl7EzVZJXQyL/E/OKFYZdTNl/P0tkn32b5IpSvj3g5n0xR4T52P93y
	 BPmNpuCT86dVEf2apY7fG3tmrDBF0M8F4SK8o55HQOeOwadNlPEe30BYVUd+NqW2qf
	 FQ56DsbrCqHB6+EGFFYTc465n2zStxSKX30ZxllnZfvqQVPN144P9CkZW7tIO6YBMq
	 SfVrfjYCemlYV9FUHLh0z67+Ny1ZyuTtrpKEyGm1ObQav/Ayp+BSE1INT1gK4T0Uy9
	 AuGcI2NXQX9MQ==
From: Alexey Gladkov <legion@kernel.org>
To: Christian Brauner <brauner@kernel.org>,
	Dan Klishch <danilklishch@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kees Cook <keescook@chromium.org>,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v9 3/5] proc: Disable cancellation of subset=pid option
Date: Mon, 13 Apr 2026 13:19:42 +0200
Message-ID: <e21427db30d64954bb363b7bdd67defabba6b530.1776079055.git.legion@kernel.org>
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

When procfs is mounted with subset=pid option, where is no way to
remount it with this option removed. This is done in order not to make
visible what ever was hidden since some checks occur during mount.

This patch makes the limitation explicit and prints an error message.

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 fs/proc/root.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/proc/root.c b/fs/proc/root.c
index 6d18f9ee0375..05558654df31 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -223,7 +223,7 @@ static int proc_parse_param(struct fs_context *fc, struct fs_parameter *param)
 	return 0;
 }
 
-static void proc_apply_options(struct proc_fs_info *fs_info,
+static int proc_apply_options(struct proc_fs_info *fs_info,
 			       struct fs_context *fc,
 			       struct user_namespace *user_ns)
 {
@@ -233,13 +233,17 @@ static void proc_apply_options(struct proc_fs_info *fs_info,
 		fs_info->pid_gid = make_kgid(user_ns, ctx->gid);
 	if (ctx->mask & (1 << Opt_hidepid))
 		fs_info->hide_pid = ctx->hidepid;
-	if (ctx->mask & (1 << Opt_subset))
+	if (ctx->mask & (1 << Opt_subset)) {
+		if (ctx->pidonly != PROC_PIDONLY_ON && fs_info->pidonly == PROC_PIDONLY_ON)
+			return invalf(fc, "proc: subset=pid cannot be unset\n");
 		fs_info->pidonly = ctx->pidonly;
+	}
 	if (ctx->mask & (1 << Opt_pidns) &&
 	    !WARN_ON_ONCE(fc->purpose == FS_CONTEXT_FOR_RECONFIGURE)) {
 		put_pid_ns(fs_info->pid_ns);
 		fs_info->pid_ns = get_pid_ns(ctx->pid_ns);
 	}
+	return 0;
 }
 
 static int proc_fill_super(struct super_block *s, struct fs_context *fc)
@@ -255,7 +259,9 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 
 	fs_info->pid_ns = get_pid_ns(ctx->pid_ns);
 	fs_info->mounter_cred = get_cred(fc->cred);
-	proc_apply_options(fs_info, fc, current_user_ns());
+	ret = proc_apply_options(fs_info, fc, current_user_ns());
+	if (ret)
+		return ret;
 
 	/* User space would break if executables or devices appear on proc */
 	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
@@ -304,8 +310,7 @@ static int proc_reconfigure(struct fs_context *fc)
 
 	sync_filesystem(sb);
 
-	proc_apply_options(fs_info, fc, current_user_ns());
-	return 0;
+	return proc_apply_options(fs_info, fc, current_user_ns());
 }
 
 static int proc_get_tree(struct fs_context *fc)
-- 
2.53.0

