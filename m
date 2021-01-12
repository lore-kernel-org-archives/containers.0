Return-Path: <SRS0=YWEV=GP=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B72AC433E9
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:05:08 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 106EF223E0
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:05:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 106EF223E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 918A9866B3;
	Tue, 12 Jan 2021 22:05:07 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id f5ERDaHjEowm; Tue, 12 Jan 2021 22:05:07 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 1210786727;
	Tue, 12 Jan 2021 22:05:07 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id EC8C3C0893;
	Tue, 12 Jan 2021 22:05:06 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id F27D4C0893
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:05:05 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id E046685218
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:05:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id wWGYT71Ta2GJ
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:05:05 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by whitealder.osuosl.org (Postfix) with ESMTPS id 4793184FB1
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:05:05 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kzRl7-0003bd-87; Tue, 12 Jan 2021 22:03:25 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 15/42] fs: add file_user_ns() helper
Date: Tue, 12 Jan 2021 23:00:57 +0100
Message-Id: <20210112220124.837960-16-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210112220124.837960-1-christian.brauner@ubuntu.com>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=MZF5H2APPgBbS6dalQP77IpBwjL8HOOCA8mxwD5I4mI=;
 m=rorofWYhlCYDsCHBmUT6ySFEXdKQZ/BhNiBUrVhD44Y=;
 p=donUDu8QUHywwTXuK+sEKtSO4q8ThCf0JgX/00ZRl3c=;
 g=56b63087ece42342c8428cabd6c7826fd940bf53
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCX/4YtgAKCRCRxhvAZXjcoinBAP9Zb0X
 yPth7UfV2DKrmKc17yNpYOz/9nCdo68TG5JthyQD/fWKi5+wXROsRJbp1i3YxlH/gCo28bVGPOR3L
 W/gWZAw=
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

Add a simple helper to retrieve the user namespace associated with the
vfsmount of a file. Christoph correctly points out that this makes
codepaths (e.g. ioctls) way easier to follow that would otherwise
dereference via mnt_user_ns(file->f_path.mnt).

In order to make file_user_ns() static inline we'd need to include
mount.h in either file.h or fs.h which seems undesirable so let's simply
not force file_user_ns() to be inline.

Cc: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Suggested-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
patch not present

/* v3 */
patch not present

/* v4 */
patch not present

/* v5 */
patch introduced
base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837
---
 fs/namei.c         | 6 ++++++
 include/linux/fs.h | 1 +
 2 files changed, 7 insertions(+)

diff --git a/fs/namei.c b/fs/namei.c
index cd124e18cec5..d8dee449e92a 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -259,6 +259,12 @@ void putname(struct filename *name)
 		__putname(name);
 }
 
+struct user_namespace *file_user_ns(struct file *file)
+{
+	return mnt_user_ns(file->f_path.mnt);
+}
+EXPORT_SYMBOL(file_user_ns);
+
 /**
  * check_acl - perform ACL permission checking
  * @mnt_userns:	user namespace of the mount the inode was found from
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ef993857682b..89e41a821bad 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2585,6 +2585,7 @@ static inline struct file *file_clone_open(struct file *file)
 	return dentry_open(&file->f_path, file->f_flags, file->f_cred);
 }
 extern int filp_close(struct file *, fl_owner_t id);
+extern struct user_namespace *file_user_ns(struct file *file);
 
 extern struct filename *getname_flags(const char __user *, int, int *);
 extern struct filename *getname(const char __user *);
-- 
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
