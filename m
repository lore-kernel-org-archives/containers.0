Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99510C4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:01 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 139A820790
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 139A820790
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 7CDEF86A14;
	Thu, 29 Oct 2020 00:36:00 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hm2PifynK2yM; Thu, 29 Oct 2020 00:35:59 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id C179C8643D;
	Thu, 29 Oct 2020 00:35:59 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id ACB0FC1AD7;
	Thu, 29 Oct 2020 00:35:59 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id ABA96C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:56 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 90155203BA
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id L5h2OQG8Tfu0
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:55 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by silver.osuosl.org (Postfix) with ESMTPS id 3209B204C4
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:55 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kXvuU-0008Ep-1v; Thu, 29 Oct 2020 00:35:22 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH 06/34] fs: add id translation helpers
Date: Thu, 29 Oct 2020 01:32:24 +0100
Message-Id: <20201029003252.2128653-7-christian.brauner@ubuntu.com>
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

Add simple helpers to make it easy to map kuids into and from idmapped
mounts. We provide simple wrappers that filesystems can use to
e.g. initialize inodes similar to i_{uid,gid}_read() and
i_{uid,gid}_write(). Accessing an inode through an idmapped mount will
require the inode to be mapped according to the mount's user namespace.
If the fsids are used to compare against inodes or to initialize inodes
they are required to be shifted from the mount's user namespace. Passing
the initial user namespace to these helpers makes them a nop and so any
non-idmapped paths will not be impacted.

Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
 include/linux/fs.h | 75 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 75 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8314cd351673..8a891b80d0b4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -39,6 +39,7 @@
 #include <linux/fs_types.h>
 #include <linux/build_bug.h>
 #include <linux/stddef.h>
+#include <linux/cred.h>
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
@@ -1574,6 +1575,80 @@ static inline void i_gid_write(struct inode *inode, gid_t gid)
 	inode->i_gid = make_kgid(inode->i_sb->s_user_ns, gid);
 }
 
+static inline kuid_t kuid_into_mnt(struct user_namespace *to, kuid_t kuid)
+{
+#ifdef CONFIG_IDMAP_MOUNTS
+	return make_kuid(to, __kuid_val(kuid));
+#else
+	return kuid;
+#endif
+}
+
+static inline kgid_t kgid_into_mnt(struct user_namespace *to, kgid_t kgid)
+{
+#ifdef CONFIG_IDMAP_MOUNTS
+	return make_kgid(to, __kgid_val(kgid));
+#else
+	return kgid;
+#endif
+}
+
+static inline kuid_t i_uid_into_mnt(struct user_namespace *to,
+				    const struct inode *inode)
+{
+#ifdef CONFIG_IDMAP_MOUNTS
+	return kuid_into_mnt(to, inode->i_uid);
+#else
+	return inode->i_uid;
+#endif
+}
+
+static inline kgid_t i_gid_into_mnt(struct user_namespace *to,
+				    const struct inode *inode)
+{
+#ifdef CONFIG_IDMAP_MOUNTS
+	return kgid_into_mnt(to, inode->i_gid);
+#else
+	return inode->i_gid;
+#endif
+}
+
+static inline kuid_t kuid_from_mnt(struct user_namespace *to, kuid_t kuid)
+{
+#ifdef CONFIG_IDMAP_MOUNTS
+	return KUIDT_INIT(from_kuid(to, kuid));
+#else
+	return kuid;
+#endif
+}
+
+static inline kgid_t kgid_from_mnt(struct user_namespace *to, kgid_t kgid)
+{
+#ifdef CONFIG_IDMAP_MOUNTS
+	return KGIDT_INIT(from_kgid(to, kgid));
+#else
+	return kgid;
+#endif
+}
+
+static inline kuid_t fsuid_into_mnt(struct user_namespace *to)
+{
+#ifdef CONFIG_IDMAP_MOUNTS
+	return kuid_from_mnt(to, current_fsuid());
+#else
+	return current_fsuid();
+#endif
+}
+
+static inline kgid_t fsgid_into_mnt(struct user_namespace *to)
+{
+#ifdef CONFIG_IDMAP_MOUNTS
+	return kgid_from_mnt(to, current_fsgid());
+#else
+	return current_fsgid();
+#endif
+}
+
 extern struct timespec64 current_time(struct inode *inode);
 
 /*
-- 
2.29.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
