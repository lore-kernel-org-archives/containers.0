Return-Path: <SRS0=YWEV=GP=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E5ACC4361A
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:03:58 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 242D8223E0
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:03:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 242D8223E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 927C986758;
	Tue, 12 Jan 2021 22:03:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id iDW0WN9GHRcZ; Tue, 12 Jan 2021 22:03:55 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 6F92D86727;
	Tue, 12 Jan 2021 22:03:55 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 41A41C0893;
	Tue, 12 Jan 2021 22:03:55 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id E1432C013A
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:03:52 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id DD7E684485
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:03:52 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id uQERi11LzWzD
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:03:51 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 39F9E843BD
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:03:51 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kzRkd-0003bd-8g; Tue, 12 Jan 2021 22:02:55 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 05/42] fs: add attr_flags_to_mnt_flags helper
Date: Tue, 12 Jan 2021 23:00:47 +0100
Message-Id: <20210112220124.837960-6-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210112220124.837960-1-christian.brauner@ubuntu.com>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=e2Flmg4jYrA1/8xjvTMZVbDsoqOcpDdlFS5OCvIgQko=;
 m=j8IYdqF5TyXvVdakkdM1Yy728RCVQaFxu74H75eIEr4=;
 p=ookErxTPvXKLHiKI8N1UF+F7LAbqJ0lYoRIToMAm7ho=;
 g=f364f419030f1b33d11154114b1ba3e23cb27139
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCX/4YtQAKCRCRxhvAZXjcorDrAQCEJk/
 yRc+oltxarCyNyLv2069AFVsG/aLvco1LfYiPaQD+N9dUDwte64sa/Qg/9sztLw1Cd3AaxMsQxSED
 5kFOGgM=
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

Add a simple helper to translate uapi MOUNT_ATTR_* flags to MNT_* flags
which we will use in follow-up patches too.

Suggested-by: Christoph Hellwig <hch@lst.de>
Cc: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
patch not present

/* v3 */
patch not present

/* v4 */
patch introduced

/* v5 */
base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837

- Christoph Hellwig <hch@lst.de>:
  - Align "\" in defines further in.
---
 fs/namespace.c | 40 ++++++++++++++++++++++++----------------
 1 file changed, 24 insertions(+), 16 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 4aab396e5f21..a1cfcab217e1 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3453,6 +3453,28 @@ SYSCALL_DEFINE5(mount, char __user *, dev_name, char __user *, dir_name,
 	return ret;
 }
 
+#define FSMOUNT_VALID_FLAGS \
+	(MOUNT_ATTR_RDONLY | MOUNT_ATTR_NOSUID | MOUNT_ATTR_NODEV | \
+	 MOUNT_ATTR_NOEXEC | MOUNT_ATTR__ATIME | MOUNT_ATTR_NODIRATIME)
+
+static unsigned int attr_flags_to_mnt_flags(u64 attr_flags)
+{
+	unsigned int mnt_flags = 0;
+
+	if (attr_flags & MOUNT_ATTR_RDONLY)
+		mnt_flags |= MNT_READONLY;
+	if (attr_flags & MOUNT_ATTR_NOSUID)
+		mnt_flags |= MNT_NOSUID;
+	if (attr_flags & MOUNT_ATTR_NODEV)
+		mnt_flags |= MNT_NODEV;
+	if (attr_flags & MOUNT_ATTR_NOEXEC)
+		mnt_flags |= MNT_NOEXEC;
+	if (attr_flags & MOUNT_ATTR_NODIRATIME)
+		mnt_flags |= MNT_NODIRATIME;
+
+	return mnt_flags;
+}
+
 /*
  * Create a kernel mount representation for a new, prepared superblock
  * (specified by fs_fd) and attach to an open_tree-like file descriptor.
@@ -3475,24 +3497,10 @@ SYSCALL_DEFINE3(fsmount, int, fs_fd, unsigned int, flags,
 	if ((flags & ~(FSMOUNT_CLOEXEC)) != 0)
 		return -EINVAL;
 
-	if (attr_flags & ~(MOUNT_ATTR_RDONLY |
-			   MOUNT_ATTR_NOSUID |
-			   MOUNT_ATTR_NODEV |
-			   MOUNT_ATTR_NOEXEC |
-			   MOUNT_ATTR__ATIME |
-			   MOUNT_ATTR_NODIRATIME))
+	if (attr_flags & ~FSMOUNT_VALID_FLAGS)
 		return -EINVAL;
 
-	if (attr_flags & MOUNT_ATTR_RDONLY)
-		mnt_flags |= MNT_READONLY;
-	if (attr_flags & MOUNT_ATTR_NOSUID)
-		mnt_flags |= MNT_NOSUID;
-	if (attr_flags & MOUNT_ATTR_NODEV)
-		mnt_flags |= MNT_NODEV;
-	if (attr_flags & MOUNT_ATTR_NOEXEC)
-		mnt_flags |= MNT_NOEXEC;
-	if (attr_flags & MOUNT_ATTR_NODIRATIME)
-		mnt_flags |= MNT_NODIRATIME;
+	mnt_flags = attr_flags_to_mnt_flags(attr_flags);
 
 	switch (attr_flags & MOUNT_ATTR__ATIME) {
 	case MOUNT_ATTR_STRICTATIME:
-- 
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
