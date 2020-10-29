Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1369EC56201
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:07 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 7CC37207DE
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CC37207DE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 15B9C87391;
	Thu, 29 Oct 2020 00:36:06 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id RZHJ5-I-t2f0; Thu, 29 Oct 2020 00:36:05 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 3C3F0873B9;
	Thu, 29 Oct 2020 00:36:05 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 377DEC088B;
	Thu, 29 Oct 2020 00:36:05 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 09E4CC0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:04 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id DC8CA204C4
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id T4oLe9jnzFCS
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:59 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by silver.osuosl.org (Postfix) with ESMTPS id 9E50020781
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:57 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kXvuZ-0008Ep-AG; Thu, 29 Oct 2020 00:35:27 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH 09/34] inode: add idmapped mount aware init and permission
 helpers
Date: Thu, 29 Oct 2020 01:32:27 +0100
Message-Id: <20201029003252.2128653-10-christian.brauner@ubuntu.com>
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

The inode_owner_or_capable() helper determines whether the caller is the
owner of the inode or is capable with respect to that inode. Add a new
mapped_inode_owner_or_capable() helper to handle idmapped mounts. If the
If the inode is accessed through an idmapped mount we first need to map
it according to the mount's user namespace. Afterwards the checks are
identical to non-idmapped mounts. If the initial user namespace is
passed all operations are a nop so non-idmapped mounts will not see a
change in behavior and will also not see any performance impact. It also
means that the inode_owner_or_capable() helper can be implemented on top
of mapped_inode_owner_or_capable() by passing in the initial user
namespace.

Similarly, we add a new mapped_inode_init_owner() helper which
initializes a new inode on idmapped mounts by mapping the fsuid and
fsgid of the caller from the mount's user namespace. If the initial user
namespace is passed all operations are a nop so non-idmapped mounts will
not see a change in behavior and will also not see any performance
impact. It also means that the inode_init_owner() helper can be
implemented on top of mapped_inode_init_owner() by passing in the
initial user namespace.

Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
 fs/inode.c         | 53 ++++++++++++++++++++++++++++++++++++----------
 include/linux/fs.h |  4 ++++
 2 files changed, 46 insertions(+), 11 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 9d78c37b00b8..22de3cb3b1f4 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -2130,15 +2130,17 @@ void init_special_inode(struct inode *inode, umode_t mode, dev_t rdev)
 EXPORT_SYMBOL(init_special_inode);
 
 /**
- * inode_init_owner - Init uid,gid,mode for new inode according to posix standards
+ * mapped_inode_init_owner - Init uid,gid,mode for new inode according to posix
+ *                           standards on idmapped mounts
  * @inode: New inode
+ * @user_ns: User namespace the inode is accessed from
  * @dir: Directory inode
  * @mode: mode of the new inode
  */
-void inode_init_owner(struct inode *inode, const struct inode *dir,
-			umode_t mode)
+void mapped_inode_init_owner(struct inode *inode, struct user_namespace *user_ns,
+			 const struct inode *dir, umode_t mode)
 {
-	inode->i_uid = current_fsuid();
+	inode->i_uid = fsuid_into_mnt(user_ns);
 	if (dir && dir->i_mode & S_ISGID) {
 		inode->i_gid = dir->i_gid;
 
@@ -2146,34 +2148,63 @@ void inode_init_owner(struct inode *inode, const struct inode *dir,
 		if (S_ISDIR(mode))
 			mode |= S_ISGID;
 		else if ((mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP) &&
-			 !in_group_p(inode->i_gid) &&
-			 !capable_wrt_inode_uidgid(dir, CAP_FSETID))
+			 !in_group_p(i_gid_into_mnt(user_ns, inode)) &&
+			 !capable_wrt_mapped_inode_uidgid(user_ns, dir, CAP_FSETID))
 			mode &= ~S_ISGID;
 	} else
-		inode->i_gid = current_fsgid();
+		inode->i_gid = fsgid_into_mnt(user_ns);
 	inode->i_mode = mode;
 }
+EXPORT_SYMBOL(mapped_inode_init_owner);
+
+/**
+ * inode_init_owner - Init uid,gid,mode for new inode according to posix standards
+ * @inode: New inode
+ * @dir: Directory inode
+ * @mode: mode of the new inode
+ */
+void inode_init_owner(struct inode *inode, const struct inode *dir,
+			umode_t mode)
+{
+	return mapped_inode_init_owner(inode, &init_user_ns, dir, mode);
+}
 EXPORT_SYMBOL(inode_init_owner);
 
 /**
- * inode_owner_or_capable - check current task permissions to inode
+ * mapped_inode_owner_or_capable - check current task permissions to inode on idmapped mounts
+ * @user_ns: User namespace the inode is accessed from
  * @inode: inode being checked
  *
  * Return true if current either has CAP_FOWNER in a namespace with the
  * inode owner uid mapped, or owns the file.
  */
-bool inode_owner_or_capable(const struct inode *inode)
+bool mapped_inode_owner_or_capable(struct user_namespace *user_ns, const struct inode *inode)
 {
+	kuid_t i_uid;
 	struct user_namespace *ns;
 
-	if (uid_eq(current_fsuid(), inode->i_uid))
+	i_uid = i_uid_into_mnt(user_ns, inode);
+	if (uid_eq(current_fsuid(), i_uid))
 		return true;
 
 	ns = current_user_ns();
-	if (kuid_has_mapping(ns, inode->i_uid) && ns_capable(ns, CAP_FOWNER))
+	if (kuid_has_mapping(ns, i_uid) && ns_capable(ns, CAP_FOWNER))
 		return true;
 	return false;
 }
+EXPORT_SYMBOL(mapped_inode_owner_or_capable);
+
+/**
+ * inode_owner_or_capable - check current task permissions to inode
+ * @inode: inode being checked
+ *
+ * Return true if current either has CAP_FOWNER in a namespace with the
+ * inode owner uid mapped, or owns the file.
+ */
+bool inode_owner_or_capable(const struct inode *inode)
+{
+	return mapped_inode_owner_or_capable(&init_user_ns, inode);
+}
 EXPORT_SYMBOL(inode_owner_or_capable);
 
 /*
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 750ca4b3d89f..f9e2d292b7b6 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1777,6 +1777,8 @@ static inline int sb_start_intwrite_trylock(struct super_block *sb)
 
 
 extern bool inode_owner_or_capable(const struct inode *inode);
+extern bool mapped_inode_owner_or_capable(struct user_namespace *ns,
+				      const struct inode *inode);
 
 /*
  * VFS helper functions..
@@ -1820,6 +1822,8 @@ extern long compat_ptr_ioctl(struct file *file, unsigned int cmd,
  */
 extern void inode_init_owner(struct inode *inode, const struct inode *dir,
 			umode_t mode);
+extern void mapped_inode_init_owner(struct inode *inode, struct user_namespace *user_ns,
+			 const struct inode *dir, umode_t mode);
 extern bool may_open_dev(const struct path *path);
 
 /*
-- 
2.29.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
