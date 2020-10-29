Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1544C55179
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:42:28 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6DF94206D9
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:42:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DF94206D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id ECA268736E;
	Thu, 29 Oct 2020 00:42:27 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LpoYxAWVmlef; Thu, 29 Oct 2020 00:42:27 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 2747086D11;
	Thu, 29 Oct 2020 00:42:27 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 15BC7C088B;
	Thu, 29 Oct 2020 00:42:27 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id A0230C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:42:25 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 99156868C9
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:42:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id pjfDmJRjcf0K
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:42:24 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by whitealder.osuosl.org (Postfix) with ESMTPS id C444C8687D
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:42:24 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kXvvH-0008Ep-6C; Thu, 29 Oct 2020 00:36:11 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH 34/34] fat: handle idmapped mounts
Date: Thu, 29 Oct 2020 01:32:52 +0100
Message-Id: <20201029003252.2128653-35-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.29.0
In-Reply-To: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
References: <20201029003252.2128653-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Miklos Szeredi <miklos@szeredi.hu>, smbarber@chromium.org,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 Jann Horn <jannh@google.com>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 Jonathan Corbet <corbet@lwn.net>, linux-unionfs@vger.kernel.org,
 linux-security-module@vger.kernel.org, linux-audit@redhat.com,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, Alban Crequy <alban@kinvolk.io>,
 linux-integrity@vger.kernel.org, Todd Kjos <tkjos@google.com>
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

Let fat handle idmapped mounts. This allows to have the same fat mount appear
in multiple locations with different id mappings. This allows to expose a vfat
formatted USB stick to multiple user with different ids on the host or in user
namespaces:

mount -o uid=1000,gid=1000 /dev/sdb /mnt

u1001@f2-vm:/lower1$ ls -ln /mnt/
total 4
-rwxr-xr-x 1 1000 1000 4 Oct 28 03:44 aaa
-rwxr-xr-x 1 1000 1000 0 Oct 28 01:09 bbb
-rwxr-xr-x 1 1000 1000 0 Oct 28 01:10 ccc
-rwxr-xr-x 1 1000 1000 0 Oct 28 03:46 ddd
-rwxr-xr-x 1 1000 1000 0 Oct 28 04:01 eee

mount2 --idmap both:1000:1001:1

u1001@f2-vm:/lower1$ ls -ln /lower1/
total 4
-rwxr-xr-x 1 1001 1001 4 Oct 28 03:44 aaa
-rwxr-xr-x 1 1001 1001 0 Oct 28 01:09 bbb
-rwxr-xr-x 1 1001 1001 0 Oct 28 01:10 ccc
-rwxr-xr-x 1 1001 1001 0 Oct 28 03:46 ddd
-rwxr-xr-x 1 1001 1001 0 Oct 28 04:01 eee

u1001@f2-vm:/lower1$ touch /lower1/fff

u1001@f2-vm:/lower1$ ls -ln /lower1/fff
-rwxr-xr-x 1 1001 1001 0 Oct 28 04:03 /lower1/fff

u1001@f2-vm:/lower1$ ls -ln /mnt/fff
-rwxr-xr-x 1 1000 1000 0 Oct 28 04:03 /mnt/fff

Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
 fs/fat/fat.h         |  2 ++
 fs/fat/file.c        | 27 +++++++++++++++++++--------
 fs/fat/namei_msdos.c |  7 +++++++
 fs/fat/namei_vfat.c  |  7 +++++++
 4 files changed, 35 insertions(+), 8 deletions(-)

diff --git a/fs/fat/fat.h b/fs/fat/fat.h
index 922a0c6ba46c..56d661e93d2a 100644
--- a/fs/fat/fat.h
+++ b/fs/fat/fat.h
@@ -398,6 +398,8 @@ extern long fat_generic_ioctl(struct file *filp, unsigned int cmd,
 extern const struct file_operations fat_file_operations;
 extern const struct inode_operations fat_file_inode_operations;
 extern int fat_setattr(struct dentry *dentry, struct iattr *attr);
+extern int fat_setattr_mapped(struct user_namespace *user_ns,
+			      struct dentry *dentry, struct iattr *attr);
 extern void fat_truncate_blocks(struct inode *inode, loff_t offset);
 extern int fat_getattr(const struct path *path, struct kstat *stat,
 		       u32 request_mask, unsigned int flags);
diff --git a/fs/fat/file.c b/fs/fat/file.c
index f9ee27cf4d7c..f97d46711b37 100644
--- a/fs/fat/file.c
+++ b/fs/fat/file.c
@@ -398,7 +398,7 @@ int fat_getattr(const struct path *path, struct kstat *stat,
 		u32 request_mask, unsigned int flags)
 {
 	struct inode *inode = d_inode(path->dentry);
-	generic_fillattr(inode, stat);
+	mapped_generic_fillattr(mnt_user_ns(path->mnt), inode, stat);
 	stat->blksize = MSDOS_SB(inode->i_sb)->cluster_size;
 
 	if (MSDOS_SB(inode->i_sb)->options.nfs == FAT_NFS_NOSTALE_RO) {
@@ -447,12 +447,13 @@ static int fat_sanitize_mode(const struct msdos_sb_info *sbi,
 	return 0;
 }
 
-static int fat_allow_set_time(struct msdos_sb_info *sbi, struct inode *inode)
+static int fat_allow_set_time(struct user_namespace *user_ns,
+			      struct msdos_sb_info *sbi, struct inode *inode)
 {
 	umode_t allow_utime = sbi->options.allow_utime;
 
-	if (!uid_eq(current_fsuid(), inode->i_uid)) {
-		if (in_group_p(inode->i_gid))
+	if (!uid_eq(current_fsuid(), i_uid_into_mnt(user_ns, inode))) {
+		if (in_group_p(i_gid_into_mnt(user_ns, inode)))
 			allow_utime >>= 3;
 		if (allow_utime & MAY_WRITE)
 			return 1;
@@ -466,7 +467,8 @@ static int fat_allow_set_time(struct msdos_sb_info *sbi, struct inode *inode)
 /* valid file mode bits */
 #define FAT_VALID_MODE	(S_IFREG | S_IFDIR | S_IRWXUGO)
 
-int fat_setattr(struct dentry *dentry, struct iattr *attr)
+int fat_setattr_mapped(struct user_namespace *user_ns, struct dentry *dentry,
+		       struct iattr *attr)
 {
 	struct msdos_sb_info *sbi = MSDOS_SB(dentry->d_sb);
 	struct inode *inode = d_inode(dentry);
@@ -476,11 +478,11 @@ int fat_setattr(struct dentry *dentry, struct iattr *attr)
 	/* Check for setting the inode time. */
 	ia_valid = attr->ia_valid;
 	if (ia_valid & TIMES_SET_FLAGS) {
-		if (fat_allow_set_time(sbi, inode))
+		if (fat_allow_set_time(user_ns, sbi, inode))
 			attr->ia_valid &= ~TIMES_SET_FLAGS;
 	}
 
-	error = setattr_prepare(dentry, attr);
+	error = setattr_mapped_prepare(user_ns, dentry, attr);
 	attr->ia_valid = ia_valid;
 	if (error) {
 		if (sbi->options.quiet)
@@ -550,15 +552,24 @@ int fat_setattr(struct dentry *dentry, struct iattr *attr)
 		fat_truncate_time(inode, &attr->ia_mtime, S_MTIME);
 	attr->ia_valid &= ~(ATTR_ATIME|ATTR_CTIME|ATTR_MTIME);
 
-	setattr_copy(inode, attr);
+	setattr_mapped_copy(user_ns, inode, attr);
 	mark_inode_dirty(inode);
 out:
 	return error;
 }
+EXPORT_SYMBOL_GPL(fat_setattr_mapped);
+
+int fat_setattr(struct dentry *dentry, struct iattr *attr)
+{
+	return fat_setattr_mapped(&init_user_ns, dentry, attr);
+}
 EXPORT_SYMBOL_GPL(fat_setattr);
 
 const struct inode_operations fat_file_inode_operations = {
 	.setattr	= fat_setattr,
 	.getattr	= fat_getattr,
 	.update_time	= fat_update_time,
+#ifdef CONFIG_IDMAP_MOUNTS
+	.setattr_mapped	= fat_setattr_mapped,
+#endif
 };
diff --git a/fs/fat/namei_msdos.c b/fs/fat/namei_msdos.c
index 9d062886fbc1..4b89d27d128d 100644
--- a/fs/fat/namei_msdos.c
+++ b/fs/fat/namei_msdos.c
@@ -639,6 +639,9 @@ static const struct inode_operations msdos_dir_inode_operations = {
 	.setattr	= fat_setattr,
 	.getattr	= fat_getattr,
 	.update_time	= fat_update_time,
+#ifdef CONFIG_IDMAP_MOUNTS
+	.setattr_mapped	= fat_setattr_mapped,
+#endif
 };
 
 static void setup(struct super_block *sb)
@@ -665,7 +668,11 @@ static struct file_system_type msdos_fs_type = {
 	.name		= "msdos",
 	.mount		= msdos_mount,
 	.kill_sb	= kill_block_super,
+#ifdef CONFIG_IDMAP_MOUNTS
+	.fs_flags	= FS_REQUIRES_DEV | FS_ALLOW_IDMAP,
+#else
 	.fs_flags	= FS_REQUIRES_DEV,
+#endif
 };
 MODULE_ALIAS_FS("msdos");
 
diff --git a/fs/fat/namei_vfat.c b/fs/fat/namei_vfat.c
index 0cdd0fb9f742..11fea59e1b77 100644
--- a/fs/fat/namei_vfat.c
+++ b/fs/fat/namei_vfat.c
@@ -1034,6 +1034,9 @@ static const struct inode_operations vfat_dir_inode_operations = {
 	.setattr	= fat_setattr,
 	.getattr	= fat_getattr,
 	.update_time	= fat_update_time,
+#ifdef CONFIG_IDMAP_MOUNTS
+	.setattr_mapped	= fat_setattr_mapped,
+#endif
 };
 
 static void setup(struct super_block *sb)
@@ -1062,7 +1065,11 @@ static struct file_system_type vfat_fs_type = {
 	.name		= "vfat",
 	.mount		= vfat_mount,
 	.kill_sb	= kill_block_super,
+#ifdef CONFIG_IDMAP_MOUNTS
+	.fs_flags	= FS_REQUIRES_DEV | FS_ALLOW_IDMAP,
+#else
 	.fs_flags	= FS_REQUIRES_DEV,
+#endif
 };
 MODULE_ALIAS_FS("vfat");
 
-- 
2.29.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
