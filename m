Return-Path: <SRS0=YWEV=GP=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00700C433DB
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:16:08 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A6BA623122
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:16:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6BA623122
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 5B6A08560F;
	Tue, 12 Jan 2021 22:16:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5jdFCT2ts3k8; Tue, 12 Jan 2021 22:16:05 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id BFDF185659;
	Tue, 12 Jan 2021 22:16:05 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id B8A97C0893;
	Tue, 12 Jan 2021 22:16:05 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 920CAC013A
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:16:03 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 7FE1086B58
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:16:03 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id jfuGTkzzWurC
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:16:02 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by hemlock.osuosl.org (Postfix) with ESMTPS id CDAB986A07
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:16:02 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kzRli-0003bd-Qe; Tue, 12 Jan 2021 22:04:02 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 29/42] ioctl: handle idmapped mounts
Date: Tue, 12 Jan 2021 23:01:11 +0100
Message-Id: <20210112220124.837960-30-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210112220124.837960-1-christian.brauner@ubuntu.com>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=kAwitCaU5Zsp+82CuxVVPm6U8xXlPPtQ0Z0Dh6WXu44=;
 m=VC5Xd0Zl8AGaO0BlP8YtVNixey9scChiBadwiGTSB5k=;
 p=oTgP29ybjPTdbnArRS0UjBd62m6f1UrtDPAozi+SHu8=;
 g=c32d9c1a69a581553f7de28602c01b53e63879e6
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCX/4YuAAKCRCRxhvAZXjcolFtAP9Jyut
 NCwljnX8YPYbEbH0TGh2ZGqdwFl7dwrXEioMjsgEAxXesyAYTyhhGHAHOKEZri1frriOo39vmk6H9
 U/Lv1wg=
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, linux-xfs@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, Alban Crequy <alban@kinvolk.io>,
 linux-integrity@vger.kernel.org,
 Linus Torvalds <torvalds@linux-foundation.org>, Todd Kjos <tkjos@google.com>
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

Enable generic ioctls to handle idmapped mounts by passing down the
mount's user namespace. If the initial user namespace is passed nothing
changes so non-idmapped mounts will see identical behavior as before.

Cc: Christoph Hellwig <hch@lst.de>
Cc: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
patch introduced

/* v3 */
unchanged

/* v4 */
- Serge Hallyn <serge@hallyn.com>:
  - Use "mnt_userns" to refer to a vfsmount's userns everywhere to make
    terminology consistent.

/* v5 */
base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837

- Christoph Hellwig <hch@lst.de>:
  - Use new file_userns_helper().
---
 fs/remap_range.c   | 7 +++++--
 fs/verity/enable.c | 2 +-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/remap_range.c b/fs/remap_range.c
index 29a4a4dbfe12..dc68394ec9a1 100644
--- a/fs/remap_range.c
+++ b/fs/remap_range.c
@@ -432,13 +432,16 @@ EXPORT_SYMBOL(vfs_clone_file_range);
 /* Check whether we are allowed to dedupe the destination file */
 static bool allow_file_dedupe(struct file *file)
 {
+	struct user_namespace *mnt_userns = file_user_ns(file);
+	struct inode *inode = file_inode(file);
+
 	if (capable(CAP_SYS_ADMIN))
 		return true;
 	if (file->f_mode & FMODE_WRITE)
 		return true;
-	if (uid_eq(current_fsuid(), file_inode(file)->i_uid))
+	if (uid_eq(current_fsuid(), i_uid_into_mnt(mnt_userns, inode)))
 		return true;
-	if (!inode_permission(&init_user_ns, file_inode(file), MAY_WRITE))
+	if (!inode_permission(mnt_userns, inode, MAY_WRITE))
 		return true;
 	return false;
 }
diff --git a/fs/verity/enable.c b/fs/verity/enable.c
index 6809cf8a99b7..9a221e368fa6 100644
--- a/fs/verity/enable.c
+++ b/fs/verity/enable.c
@@ -369,7 +369,7 @@ int fsverity_ioctl_enable(struct file *filp, const void __user *uarg)
 	 * has verity enabled, and to stabilize the data being hashed.
 	 */
 
-	err = inode_permission(&init_user_ns, inode, MAY_WRITE);
+	err = inode_permission(file_user_ns(filp), inode, MAY_WRITE);
 	if (err)
 		return err;
 
-- 
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
