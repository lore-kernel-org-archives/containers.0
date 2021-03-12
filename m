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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 919A4C433DB
	for <containers@archiver.kernel.org>; Fri, 12 Mar 2021 16:42:09 +0000 (UTC)
Received: from smtp1.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4257564FEA
	for <containers@archiver.kernel.org>; Fri, 12 Mar 2021 16:42:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4257564FEA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp1.osuosl.org (Postfix) with ESMTP id EC5FE84415;
	Fri, 12 Mar 2021 16:42:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp1.osuosl.org ([127.0.0.1])
	by localhost (smtp1.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id iHG_dT7HX3ug; Fri, 12 Mar 2021 16:42:07 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [IPv6:2605:bc80:3010:104::8cd3:938])
	by smtp1.osuosl.org (Postfix) with ESMTP id B09DF843CD;
	Fri, 12 Mar 2021 16:42:07 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 9E65BC000A;
	Fri, 12 Mar 2021 16:42:07 +0000 (UTC)
Received: from smtp3.osuosl.org (smtp3.osuosl.org [IPv6:2605:bc80:3010::136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 7DB5AC0001
 for <containers@lists.linux-foundation.org>;
 Fri, 12 Mar 2021 16:42:05 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp3.osuosl.org (Postfix) with ESMTP id 7A18760623
 for <containers@lists.linux-foundation.org>;
 Fri, 12 Mar 2021 16:42:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp3.osuosl.org ([127.0.0.1])
 by localhost (smtp3.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id GJlNHtM1Xo4F
 for <containers@lists.linux-foundation.org>;
 Fri, 12 Mar 2021 16:42:04 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.8.0
Received: from raptor.unsafe.ru (raptor.unsafe.ru [5.9.43.93])
 by smtp3.osuosl.org (Postfix) with ESMTP id 1126F60610
 for <containers@lists.linux-foundation.org>;
 Fri, 12 Mar 2021 16:42:04 +0000 (UTC)
Received: from comp-core-i7-2640m-0182e6.redhat.com
 (ip-94-113-225-162.net.upcbroadband.cz [94.113.225.162])
 by raptor.unsafe.ru (Postfix) with ESMTPSA id 0053040CA5;
 Fri, 12 Mar 2021 16:42:03 +0000 (UTC)
From: Alexey Gladkov <gladkov.alexey@gmail.com>
To: LKML <linux-kernel@vger.kernel.org>,
 "Eric W . Biederman" <ebiederm@xmission.com>
Subject: [PATCH v6 4/5] proc: Relax check of mount visibility
Date: Fri, 12 Mar 2021 17:41:47 +0100
Message-Id: <16afddb2a1beb9e350083446a6c01828f26e376e.1615567183.git.gladkov.alexey@gmail.com>
X-Mailer: git-send-email 2.29.3
In-Reply-To: <cover.1615567183.git.gladkov.alexey@gmail.com>
References: <cover.1615567183.git.gladkov.alexey@gmail.com>
MIME-Version: 1.0
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.4
 (raptor.unsafe.ru [0.0.0.0]); Fri, 12 Mar 2021 16:42:03 +0000 (UTC)
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

Allow to mount procfs with subset=pid option even if the entire procfs
is not fully accessible to the user.

Signed-off-by: Alexey Gladkov <gladkov.alexey@gmail.com>
---
 fs/namespace.c     | 30 ++++++++++++++++++------------
 fs/proc/root.c     | 16 ++++++++++------
 include/linux/fs.h |  1 +
 3 files changed, 29 insertions(+), 18 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 9d33909d0f9e..f38570fdfc3f 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3951,7 +3951,8 @@ static bool mnt_already_visible(struct mnt_namespace *ns,
 		/* This mount is not fully visible if it's root directory
 		 * is not the root directory of the filesystem.
 		 */
-		if (mnt->mnt.mnt_root != mnt->mnt.mnt_sb->s_root)
+		if (!(sb->s_iflags & SB_I_DYNAMIC) &&
+		    mnt->mnt.mnt_root != mnt->mnt.mnt_sb->s_root)
 			continue;
 
 		/* A local view of the mount flags */
@@ -3971,18 +3972,23 @@ static bool mnt_already_visible(struct mnt_namespace *ns,
 		    ((mnt_flags & MNT_ATIME_MASK) != (new_flags & MNT_ATIME_MASK)))
 			continue;
 
-		/* This mount is not fully visible if there are any
-		 * locked child mounts that cover anything except for
-		 * empty directories.
+		/* If this filesystem is completely dynamic, then it
+		 * makes no sense to check for any child mounts.
 		 */
-		list_for_each_entry(child, &mnt->mnt_mounts, mnt_child) {
-			struct inode *inode = child->mnt_mountpoint->d_inode;
-			/* Only worry about locked mounts */
-			if (!(child->mnt.mnt_flags & MNT_LOCKED))
-				continue;
-			/* Is the directory permanetly empty? */
-			if (!is_empty_dir_inode(inode))
-				goto next;
+		if (!(sb->s_iflags & SB_I_DYNAMIC)) {
+			/* This mount is not fully visible if there are any
+			 * locked child mounts that cover anything except for
+			 * empty directories.
+			 */
+			list_for_each_entry(child, &mnt->mnt_mounts, mnt_child) {
+				struct inode *inode = child->mnt_mountpoint->d_inode;
+				/* Only worry about locked mounts */
+				if (!(child->mnt.mnt_flags & MNT_LOCKED))
+					continue;
+				/* Is the directory permanetly empty? */
+				if (!is_empty_dir_inode(inode))
+					goto next;
+			}
 		}
 		/* Preserve the locked attributes */
 		*new_mnt_flags |= mnt_flags & (MNT_LOCK_READONLY | \
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 0d20bb67e79a..c739ed94246c 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -145,18 +145,21 @@ static int proc_parse_param(struct fs_context *fc, struct fs_parameter *param)
 	return 0;
 }
 
-static int proc_apply_options(struct proc_fs_info *fs_info,
+static int proc_apply_options(struct super_block *s,
 			       struct fs_context *fc,
 			       struct user_namespace *user_ns)
 {
 	struct proc_fs_context *ctx = fc->fs_private;
+	struct proc_fs_info *fs_info = proc_sb_info(s);
 
 	if (ctx->mask & (1 << Opt_gid))
 		fs_info->pid_gid = make_kgid(user_ns, ctx->gid);
 	if (ctx->mask & (1 << Opt_hidepid))
 		fs_info->hide_pid = ctx->hidepid;
 	if (ctx->mask & (1 << Opt_subset)) {
-		if (ctx->pidonly != PROC_PIDONLY_ON && fs_info->pidonly == PROC_PIDONLY_ON)
+		if (ctx->pidonly == PROC_PIDONLY_ON)
+			s->s_iflags |= SB_I_DYNAMIC;
+		else if (fs_info->pidonly == PROC_PIDONLY_ON)
 			return invalf(fc, "proc: subset=pid cannot be unset\n");
 		fs_info->pidonly = ctx->pidonly;
 	}
@@ -176,9 +179,6 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 
 	fs_info->pid_ns = get_pid_ns(ctx->pid_ns);
 	fs_info->mounter_cred = get_cred(fc->cred);
-	ret = proc_apply_options(fs_info, fc, current_user_ns());
-	if (ret)
-		return ret;
 
 	/* User space would break if executables or devices appear on proc */
 	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
@@ -190,6 +190,10 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 	s->s_time_gran = 1;
 	s->s_fs_info = fs_info;
 
+	ret = proc_apply_options(s, fc, current_user_ns());
+	if (ret)
+		return ret;
+
 	/*
 	 * procfs isn't actually a stacking filesystem; however, there is
 	 * too much magic going on inside it to permit stacking things on
@@ -230,7 +234,7 @@ static int proc_reconfigure(struct fs_context *fc)
 	put_cred(fs_info->mounter_cred);
 	fs_info->mounter_cred = get_cred(fc->cred);
 
-	return proc_apply_options(fs_info, fc, current_user_ns());
+	return proc_apply_options(sb, fc, current_user_ns());
 }
 
 static int proc_get_tree(struct fs_context *fc)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index fd47deea7c17..2c9a47bad796 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1390,6 +1390,7 @@ extern int send_sigurg(struct fown_struct *fown);
 #define SB_I_USERNS_VISIBLE		0x00000010 /* fstype already mounted */
 #define SB_I_IMA_UNVERIFIABLE_SIGNATURE	0x00000020
 #define SB_I_UNTRUSTED_MOUNTER		0x00000040
+#define SB_I_DYNAMIC			0x00000080
 
 #define SB_I_SKIP_SYNC	0x00000100	/* Skip superblock at global sync */
 
-- 
2.29.3

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
