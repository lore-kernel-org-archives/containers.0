Return-Path: <SRS0=32ge=IK=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,
	DKIM_ADSP_CUSTOM_MED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7161DC433DB
	for <containers@archiver.kernel.org>; Fri, 12 Mar 2021 16:42:10 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 2F1D564FD9
	for <containers@archiver.kernel.org>; Fri, 12 Mar 2021 16:42:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F1D564FD9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp3.osuosl.org (Postfix) with ESMTP id D0CA660634;
	Fri, 12 Mar 2021 16:42:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
	by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 0LL6gKcgQhF2; Fri, 12 Mar 2021 16:42:08 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp3.osuosl.org (Postfix) with ESMTP id 30C8460650;
	Fri, 12 Mar 2021 16:42:08 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 0A33AC001A;
	Fri, 12 Mar 2021 16:42:08 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [IPv6:2605:bc80:3010::138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 072D9C0001
 for <containers@lists.linux-foundation.org>;
 Fri, 12 Mar 2021 16:42:06 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp1.osuosl.org (Postfix) with ESMTP id DBA35843CD
 for <containers@lists.linux-foundation.org>;
 Fri, 12 Mar 2021 16:42:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
 by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id t1-WTxgpQfeU
 for <containers@lists.linux-foundation.org>;
 Fri, 12 Mar 2021 16:42:03 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by smtp1.osuosl.org (Postfix) with ESMTP id ACC1D843DD
 for <containers@lists.linux-foundation.org>;
 Fri, 12 Mar 2021 16:42:03 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-94-113-225-162.net.upcbroadband.cz [94.113.225.162])
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 86ACF40CA4;
 Fri, 12 Mar 2021 16:42:02 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>
Subject: [PATCH v6 3/5] proc: Disable cancellation of subset=pid option
Date: Fri, 12 Mar 2021 17:41:46 +0100
Message-Id: <7bcb66c11afc2ac0032ee3bc1e64437481df7b9d.1615567183.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.29.3
In-Reply-To: <cover.1615567183.git.gladkov.alexey@gmail.com>
References: <cover.1615567183.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.4
 (raptor.unsafe.ru [0.0.0.0]); Fri, 12 Mar 2021 16:42:02 +0000 (UTC)
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Alexey Gladkov <legion@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Kees Cook <keescook@chromium.org>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

When procfs is mounted with subset=pid option, where is no way to
remount it with this option removed. This is done in order not to make
visible what ever was hidden since some checks occur during mount.

This patch makes the limitation explicit and prints an error message.

Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
---
 fs/proc/root.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/proc/root.c b/fs/proc/root.c
index 6a75ac717455..0d20bb67e79a 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -145,7 +145,7 @@ static int proc_parse_param(struct fs_context *fc, struct fs_parameter *param)
 	return 0;
 }
 
-static void proc_apply_options(struct proc_fs_info *fs_info,
+static int proc_apply_options(struct proc_fs_info *fs_info,
 			       struct fs_context *fc,
 			       struct user_namespace *user_ns)
 {
@@ -155,8 +155,12 @@ static void proc_apply_options(struct proc_fs_info *fs_info,
 		fs_info->pid_gid = make_kgid(user_ns, ctx->gid);
 	if (ctx->mask & (1 << Opt_hidepid))
 		fs_info->hide_pid = ctx->hidepid;
-	if (ctx->mask & (1 << Opt_subset))
+	if (ctx->mask & (1 << Opt_subset)) {
+		if (ctx->pidonly != PROC_PIDONLY_ON && fs_info->pidonly == PROC_PIDONLY_ON)
+			return invalf(fc, "proc: subset=pid cannot be unset\n");
 		fs_info->pidonly = ctx->pidonly;
+	}
+	return 0;
 }
 
 static int proc_fill_super(struct super_block *s, struct fs_context *fc)
@@ -172,7 +176,9 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 
 	fs_info->pid_ns = get_pid_ns(ctx->pid_ns);
 	fs_info->mounter_cred = get_cred(fc->cred);
-	proc_apply_options(fs_info, fc, current_user_ns());
+	ret = proc_apply_options(fs_info, fc, current_user_ns());
+	if (ret)
+		return ret;
 
 	/* User space would break if executables or devices appear on proc */
 	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
@@ -224,8 +230,7 @@ static int proc_reconfigure(struct fs_context *fc)
 	put_cred(fs_info->mounter_cred);
 	fs_info->mounter_cred = get_cred(fc->cred);
 
-	proc_apply_options(fs_info, fc, current_user_ns());
-	return 0;
+	return proc_apply_options(fs_info, fc, current_user_ns());
 }
 
 static int proc_get_tree(struct fs_context *fc)
-- 
2.29.3

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
