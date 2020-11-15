Return-Path: <SRS0=LQYp=EV=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAFFAC63777
	for <containers@archiver.kernel.org>; Sun, 15 Nov 2020 10:39:01 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 993AC23A32
	for <containers@archiver.kernel.org>; Sun, 15 Nov 2020 10:39:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 993AC23A32
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 4CA81872C7;
	Sun, 15 Nov 2020 10:39:01 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id VFj+34SX4iLE; Sun, 15 Nov 2020 10:39:00 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7A6FB872B7;
	Sun, 15 Nov 2020 10:39:00 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 70161C0891;
	Sun, 15 Nov 2020 10:39:00 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D7414C07FF
 for <containers@lists.linux-foundation.org>;
 Sun, 15 Nov 2020 10:38:58 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id C1BCB85F0A
 for <containers@lists.linux-foundation.org>;
 Sun, 15 Nov 2020 10:38:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id I6UYmmioeb8j
 for <containers@lists.linux-foundation.org>;
 Sun, 15 Nov 2020 10:38:58 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 0F87385A80
 for <containers@lists.linux-foundation.org>;
 Sun, 15 Nov 2020 10:38:58 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1keFQU-0000Kt-1U; Sun, 15 Nov 2020 10:38:30 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 06/39] fs: add id translation helpers
Date: Sun, 15 Nov 2020 11:36:45 +0100
Message-Id: <20201115103718.298186-7-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201115103718.298186-1-christian.brauner@ubuntu.com>
References: <20201115103718.298186-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Jonathan Corbet <corbet@lwn.net>,
 smbarber@chromium.org, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, Jann Horn <jannh@google.com>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
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

Add simple helpers to make it easy to map kuids into and from idmapped
mounts. We provide simple wrappers that filesystems can use to
e.g. initialize inodes similar to i_{uid,gid}_read() and
i_{uid,gid}_write(). Accessing an inode through an idmapped mount will
require the inode to be mapped according to the mount's user namespace.
If the fsids are used to compare against inodes or to initialize inodes
they are required to be shifted from the mount's user namespace. Passing
the initial user namespace to these helpers makes them a nop and so any
non-idmapped paths will not be impacted.

Cc: Christoph Hellwig <hch@lst.de>
Cc: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
- Christoph Hellwig <hch@lst.de>:
  - Get rid of the ifdefs and the config option that hid idmapped mounts.
---
 include/linux/fs.h | 43 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 43 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 21cc971fd960..9e487cbf0f5c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -39,6 +39,7 @@
 #include <linux/fs_types.h>
 #include <linux/build_bug.h>
 #include <linux/stddef.h>
+#include <linux/cred.h>
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
@@ -1574,6 +1575,48 @@ static inline void i_gid_write(struct inode *inode, gid_t gid)
 	inode->i_gid = make_kgid(inode->i_sb->s_user_ns, gid);
 }
 
+static inline kuid_t kuid_into_mnt(struct user_namespace *to, kuid_t kuid)
+{
+	return make_kuid(to, __kuid_val(kuid));
+}
+
+static inline kgid_t kgid_into_mnt(struct user_namespace *to, kgid_t kgid)
+{
+	return make_kgid(to, __kgid_val(kgid));
+}
+
+static inline kuid_t i_uid_into_mnt(struct user_namespace *to,
+				    const struct inode *inode)
+{
+	return kuid_into_mnt(to, inode->i_uid);
+}
+
+static inline kgid_t i_gid_into_mnt(struct user_namespace *to,
+				    const struct inode *inode)
+{
+	return kgid_into_mnt(to, inode->i_gid);
+}
+
+static inline kuid_t kuid_from_mnt(struct user_namespace *to, kuid_t kuid)
+{
+	return KUIDT_INIT(from_kuid(to, kuid));
+}
+
+static inline kgid_t kgid_from_mnt(struct user_namespace *to, kgid_t kgid)
+{
+	return KGIDT_INIT(from_kgid(to, kgid));
+}
+
+static inline kuid_t fsuid_into_mnt(struct user_namespace *to)
+{
+	return kuid_from_mnt(to, current_fsuid());
+}
+
+static inline kgid_t fsgid_into_mnt(struct user_namespace *to)
+{
+	return kgid_from_mnt(to, current_fsgid());
+}
+
 extern struct timespec64 current_time(struct inode *inode);
 
 /*
-- 
2.29.2

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
