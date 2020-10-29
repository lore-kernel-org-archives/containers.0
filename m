Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18E2FC388F7
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:11 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 8059B20790
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8059B20790
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 4072A869D7;
	Thu, 29 Oct 2020 00:36:10 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YcEusOPMn_ue; Thu, 29 Oct 2020 00:36:09 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 88C0D86493;
	Thu, 29 Oct 2020 00:36:09 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 844F3C088B;
	Thu, 29 Oct 2020 00:36:09 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 39801C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:08 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 3470C87394
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:08 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id N7HKvGnkr08b
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:07 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 74B6D8744F
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:36:07 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kXvuj-0008Ep-Ic; Thu, 29 Oct 2020 00:35:37 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH 15/34] stat: add mapped_generic_fillattr()
Date: Thu, 29 Oct 2020 01:32:33 +0100
Message-Id: <20201029003252.2128653-16-christian.brauner@ubuntu.com>
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

The generic_fillattr() helper fills in the basic attributes associated with an
inode. Add a mapped_generic_fillattr() helper to handle idmapped mounts. If the
inode is accessed through an idmapped mount we need to map it according to the
mount's user namespace. If the initial user namespace is passed all operations
are a nop so non-idmapped mounts will not see a change in behavior and will
also not see any performance impact. This also means that the
non-idmapped-mount aware generic_fillattr() helper can be implemented on top of
the idmapped-mount aware mapped_generic_fillattr() helper.

Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
 fs/stat.c          | 18 +++++++++++++-----
 include/linux/fs.h |  1 +
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/stat.c b/fs/stat.c
index dacecdda2e79..ee6d92aec7ac 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -25,7 +25,8 @@
 #include "mount.h"
 
 /**
- * generic_fillattr - Fill in the basic attributes from the inode struct
+ * mapped_generic_fillattr - Fill in the basic attributes from the inode struct on idmapped mounts
+ * @user_ns: the user namespace from which we access this inode
  * @inode: Inode to use as the source
  * @stat: Where to fill in the attributes
  *
@@ -33,14 +34,15 @@
  * found on the VFS inode structure.  This is the default if no getattr inode
  * operation is supplied.
  */
-void generic_fillattr(struct inode *inode, struct kstat *stat)
+void mapped_generic_fillattr(struct user_namespace *mnt_user_ns,
+			 struct inode *inode, struct kstat *stat)
 {
 	stat->dev = inode->i_sb->s_dev;
 	stat->ino = inode->i_ino;
 	stat->mode = inode->i_mode;
 	stat->nlink = inode->i_nlink;
-	stat->uid = inode->i_uid;
-	stat->gid = inode->i_gid;
+	stat->uid = i_uid_into_mnt(mnt_user_ns, inode);
+	stat->gid = i_gid_into_mnt(mnt_user_ns, inode);
 	stat->rdev = inode->i_rdev;
 	stat->size = i_size_read(inode);
 	stat->atime = inode->i_atime;
@@ -49,6 +51,12 @@ void generic_fillattr(struct inode *inode, struct kstat *stat)
 	stat->blksize = i_blocksize(inode);
 	stat->blocks = inode->i_blocks;
 }
+EXPORT_SYMBOL(mapped_generic_fillattr);
+
+void generic_fillattr(struct inode *inode, struct kstat *stat)
+{
+	mapped_generic_fillattr(&init_user_ns, inode, stat);
+}
 EXPORT_SYMBOL(generic_fillattr);
 
 /**
@@ -87,7 +95,7 @@ int vfs_getattr_nosec(const struct path *path, struct kstat *stat,
 		return inode->i_op->getattr(path, stat, request_mask,
 					    query_flags);
 
-	generic_fillattr(inode, stat);
+	mapped_generic_fillattr(mnt_user_ns(path->mnt), inode, stat);
 	return 0;
 }
 EXPORT_SYMBOL(vfs_getattr_nosec);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f41d93b0e6d7..e66852dee65d 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -3162,6 +3162,7 @@ extern int page_symlink(struct inode *inode, const char *symname, int len);
 extern const struct inode_operations page_symlink_inode_operations;
 extern void kfree_link(void *);
 extern void generic_fillattr(struct inode *, struct kstat *);
+extern void mapped_generic_fillattr(struct user_namespace *, struct inode *, struct kstat *);
 extern int vfs_getattr_nosec(const struct path *, struct kstat *, u32, unsigned int);
 extern int vfs_getattr(const struct path *, struct kstat *, u32, unsigned int);
 void __inode_add_bytes(struct inode *inode, loff_t bytes);
-- 
2.29.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
