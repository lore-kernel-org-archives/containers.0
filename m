Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1746D3AF667;
	Mon, 13 Apr 2026 11:22:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776079353; cv=none; b=IVaSoVu403HObIDtz9g4ohgK39/GNSClVad5RPXCcPjXeIRCRua3I73Ss5xKOIK0qeOjLUuqFxSTptd57iWWrcAgx7QTUVqbeAGlQZKMGchk+DjWTQWvfXBKEdAreBgr2qATcvRxYQGaC3zUqEnFeCgxXBoCyY5d8UQi3yRlxtQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776079353; c=relaxed/simple;
	bh=FQCr7qSm4xiBoSTBWH1BWq5L0Ay30j0R812NdJ+wUOo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=s95zweFacok+PRi1tGRqcFL5QMqbkZjzeibq0NE0bU2bpTER5PjTScwtL9VZEAui+4jARAya6lqC8iGNdwLjkzCDKjslXrBoSzXaQgdjuaU1moyy3RcPitBr/9jG+dP3sSPSK7Lm65eMNAGZrxhBQNMVxx2SRT+7KF5Bxozs7LY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LUlf+U5a; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LUlf+U5a"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E68BFC19421;
	Mon, 13 Apr 2026 11:22:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776079352;
	bh=FQCr7qSm4xiBoSTBWH1BWq5L0Ay30j0R812NdJ+wUOo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=LUlf+U5aaLSmGeHO6JW2lnpMimJXxFosndPsDyVSddbVMfaEMCtX5PmW2NwFmveiM
	 EOKLr72aSD30kD99QMxV2JT9bMZ2uW6ppBOlXPuSJWJCSO1FmX5ScbhMhHSbolaEM9
	 rOVmuMTKWGaLjUkFhN+hPlIk9745WDu2RTPoItxxj7ySY7DJWHMRQfsf6bcPtZ9Q7d
	 KaCwP9sE3fkWOPq4pfJtbfBBPWJnkVvw3xQDjUObK6BpQnG3bmdOOmM9+dKOL8zQo5
	 oWeBbCTIsf7YAghYOhuVVigN7VSs0ruAfJyNQSeTJn5KdAFkNYcCgBiGYqwTsYJRoP
	 p9a/32MzcsndQ==
From: Alexey Gladkov <legion@kernel.org>
To: Christian Brauner <brauner@kernel.org>,
	Dan Klishch <danilklishch@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Kees Cook <keescook@chromium.org>,
	containers@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v9 2/5] proc: subset=pid: Show /proc/self/net only for CAP_NET_ADMIN
Date: Mon, 13 Apr 2026 13:19:41 +0200
Message-ID: <fe88a8c3258de111c1d72d4aa28acb508f5b45fb.1776079055.git.legion@kernel.org>
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

Cache the mounters credentials and allow access to the net directories
contingent of the permissions of the mounter of proc.

Do not show /proc/self/net when proc is mounted with subset=pid option
and the mounter does not have CAP_NET_ADMIN. To avoid inadvertently
allowing access to /proc/<pid>/net, updating mounter credentials is not
supported.

Signed-off-by: Alexey Gladkov <legion@kernel.org>
---
 fs/proc/proc_net.c      | 8 ++++++++
 fs/proc/root.c          | 2 ++
 include/linux/proc_fs.h | 1 +
 3 files changed, 11 insertions(+)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 52f0b75cbce2..6e0ccef0169f 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -23,6 +23,7 @@
 #include <linux/uidgid.h>
 #include <net/net_namespace.h>
 #include <linux/seq_file.h>
+#include <linux/security.h>
 
 #include "internal.h"
 
@@ -270,6 +271,7 @@ static struct net *get_proc_task_net(struct inode *dir)
 	struct task_struct *task;
 	struct nsproxy *ns;
 	struct net *net = NULL;
+	struct proc_fs_info *fs_info = proc_sb_info(dir->i_sb);
 
 	rcu_read_lock();
 	task = pid_task(proc_pid(dir), PIDTYPE_PID);
@@ -282,6 +284,12 @@ static struct net *get_proc_task_net(struct inode *dir)
 	}
 	rcu_read_unlock();
 
+	if (net && (fs_info->pidonly == PROC_PIDONLY_ON) &&
+	    security_capable(fs_info->mounter_cred, net->user_ns, CAP_NET_ADMIN, CAP_OPT_NONE) < 0) {
+		put_net(net);
+		net = NULL;
+	}
+
 	return net;
 }
 
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 0f9100559471..6d18f9ee0375 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -254,6 +254,7 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 		return -ENOMEM;
 
 	fs_info->pid_ns = get_pid_ns(ctx->pid_ns);
+	fs_info->mounter_cred = get_cred(fc->cred);
 	proc_apply_options(fs_info, fc, current_user_ns());
 
 	/* User space would break if executables or devices appear on proc */
@@ -350,6 +351,7 @@ static void proc_kill_sb(struct super_block *sb)
 	kill_anon_super(sb);
 	if (fs_info) {
 		put_pid_ns(fs_info->pid_ns);
+		put_cred(fs_info->mounter_cred);
 		kfree_rcu(fs_info, rcu);
 	}
 }
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 19d1c5e5f335..ec123c277d49 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -67,6 +67,7 @@ enum proc_pidonly {
 struct proc_fs_info {
 	struct pid_namespace *pid_ns;
 	kgid_t pid_gid;
+	const struct cred *mounter_cred;
 	enum proc_hidepid hide_pid;
 	enum proc_pidonly pidonly;
 	struct rcu_head rcu;
-- 
2.53.0

