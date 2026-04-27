Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 77D9839B4BE;
	Mon, 27 Apr 2026 08:27:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777278427; cv=none; b=TiJVwFy5XMNkmZzEiwxNlK5NBAwMzoRSOm/G3xer0WGccwWUWzER9VoW8/3rWzTBeGyGdVEWSXzXysVgBZ9AK62uQa8pyxKjxJLNSfuN8z7RZaBH6y7WeSwY3a4JSkoLpEPAFHLB8N/u8h8Fo08Fificqg3YJSezSfkoetLXVyE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777278427; c=relaxed/simple;
	bh=emFPWOyEMyLlcW/YMcZlCPlaGylN8uSZzDUyULMPc8o=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=nwCofoOPOoSOtqb78VFHb296oz1FMOra8zPuXdqmh0uxP/8Ii6scFdi00L3e/zzfkPvBHoO+7uktn/yUW1dcy7Zkdxb/Ukosrhpb0MnoM0GoaejpYIHEAYVvv94PANUwKv8dXDda0gfJu+WxC/BMl5UeuFm0rNemD+ImAupXatU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WxVqFc28; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WxVqFc28"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 19106C2BCB6;
	Mon, 27 Apr 2026 08:27:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1777278427;
	bh=emFPWOyEMyLlcW/YMcZlCPlaGylN8uSZzDUyULMPc8o=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=WxVqFc28iXFB8sE0ZFly7W/hD51MjiTE13rAKK+zkGPUfW2W/XZnA1YjJySJhxkAs
	 FCXm4soHwd1QxI2ViEZGlLf5/dII+KKbPyyrsNtIlZqABWLOpNyURbRVAOatpJMBEG
	 0eKjTOCmZopMeSgMt5FZNYxEpHgA9oAAsjXoWA59A1TUVtWTo7dV1mShyfsL92BVFt
	 20Wqkg/db86cXzDyBnDCrqALi4Tr2mL4FJg6uf/Tn+qKzD/XexTTz1Y2XIE71CnhQk
	 D1JaDwPZfE6uXafyzEfjHYG6WQv38wzUwDAFNS9ffcpRgZm3LnZHhsyF91sDcvDDwF
	 j5bPRvk2Vvbsw==
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
Subject: [PATCH v10 5/7] proc: prevent reconfiguring subset=pid
Date: Mon, 27 Apr 2026 10:26:06 +0200
Message-ID: <13295f40f642af5d6e7038d681d43132ad80f7b2.1777278334.git.legion@kernel.org>
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

Changing subset=pid on an existing procfs instance is not safe. If a
full procfs mount has entries hidden by overmounts, switching it to
subset=pid would hide the top-level procfs entries from lookup and
readdir while leaving the existing overmounts reachable.

Reject attempts to change the subset=pid state during reconfigure before
applying any other procfs mount options, so a failed reconfigure cannot
partially update the instance.

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 fs/proc/root.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/proc/root.c b/fs/proc/root.c
index 89e5678129e4..1bf75a4ee146 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -223,12 +223,17 @@ static int proc_parse_param(struct fs_context *fc, struct fs_parameter *param)
 	return 0;
 }
 
-static void proc_apply_options(struct proc_fs_info *fs_info,
+static int proc_apply_options(struct proc_fs_info *fs_info,
 			       struct fs_context *fc,
 			       struct user_namespace *user_ns)
 {
 	struct proc_fs_context *ctx = fc->fs_private;
 
+	if ((ctx->mask & (1 << Opt_subset)) &&
+	    fc->purpose == FS_CONTEXT_FOR_RECONFIGURE &&
+	    ctx->pidonly != fs_info->pidonly)
+		return invalf(fc, "proc: subset=pid cannot be changed\n");
+
 	if (ctx->mask & (1 << Opt_gid))
 		fs_info->pid_gid = make_kgid(user_ns, ctx->gid);
 	if (ctx->mask & (1 << Opt_hidepid))
@@ -240,6 +245,7 @@ static void proc_apply_options(struct proc_fs_info *fs_info,
 		put_pid_ns(fs_info->pid_ns);
 		fs_info->pid_ns = get_pid_ns(ctx->pid_ns);
 	}
+	return 0;
 }
 
 static int proc_fill_super(struct super_block *s, struct fs_context *fc)
@@ -255,7 +261,9 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 
 	fs_info->pid_ns = get_pid_ns(ctx->pid_ns);
 	fs_info->mounter_cred = get_cred(fc->cred);
-	proc_apply_options(fs_info, fc, current_user_ns());
+	ret = proc_apply_options(fs_info, fc, current_user_ns());
+	if (ret)
+		return ret;
 
 	/* User space would break if executables or devices appear on proc */
 	s->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
@@ -304,8 +312,7 @@ static int proc_reconfigure(struct fs_context *fc)
 
 	sync_filesystem(sb);
 
-	proc_apply_options(fs_info, fc, current_user_ns());
-	return 0;
+	return proc_apply_options(fs_info, fc, current_user_ns());
 }
 
 static int proc_get_tree(struct fs_context *fc)
-- 
2.54.0

