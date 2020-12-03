Return-Path: <SRS0=uLXG=FI=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A622EC4361A
	for <containers@archiver.kernel.org>; Fri,  4 Dec 2020 00:03:39 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 3082B22224
	for <containers@archiver.kernel.org>; Fri,  4 Dec 2020 00:03:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3082B22224
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by whitealder.osuosl.org (Postfix) with ESMTP id 49EC486AFF;
	Fri,  4 Dec 2020 00:03:38 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id BL5wXYk3ewLh; Fri,  4 Dec 2020 00:03:36 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by whitealder.osuosl.org (Postfix) with ESMTP id 82F9187F86;
	Fri,  4 Dec 2020 00:03:36 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 69845C1DA4;
	Fri,  4 Dec 2020 00:03:36 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 8877CC163C
 for <containers@lists.linux-foundation.org>;
 Fri,  4 Dec 2020 00:03:34 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 7A8AC2E416
 for <containers@lists.linux-foundation.org>;
 Fri,  4 Dec 2020 00:03:34 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 3ucqZ8rLHVBm
 for <containers@lists.linux-foundation.org>;
 Fri,  4 Dec 2020 00:03:24 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by silver.osuosl.org (Postfix) with ESMTPS id 235CE2E414
 for <containers@lists.linux-foundation.org>;
 Fri,  4 Dec 2020 00:03:05 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kkyXQ-0007ka-Jn; Fri, 04 Dec 2020 00:01:28 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v4 08/40] fs: add id translation helpers
Date: Fri,  4 Dec 2020 00:57:04 +0100
Message-Id: <20201203235736.3528991-9-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201203235736.3528991-1-christian.brauner@ubuntu.com>
References: <20201203235736.3528991-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Cc: Andy Lutomirski <luto@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 linux-ext4@vger.kernel.org, Mrunal Patel <mpatel@redhat.com>,
 Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>,
 selinux@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Lennart Poettering <lennart@poettering.net>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>,
 linux-security-module@vger.kernel.org,
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
mounts. We provide simple wrappers that filesystems can use to e.g.
initialize inodes similar to i_{uid,gid}_read() and i_{uid,gid}_write().
Accessing an inode through an idmapped mount will require the inode to
be mapped according to the mount's user namespace. If the fsids are used
to compare against inodes or to initialize inodes they are required to
be shifted from the mount's user namespace. Passing the initial user
namespace to these helpers makes them a nop and so any non-idmapped
paths will not be impacted.

Cc: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
/* v2 */
- Christoph Hellwig <hch@lst.de>:
  - Get rid of the ifdefs and the config option that hid idmapped mounts.

/* v3 */
unchanged

/* v4 */
- Serge Hallyn <serge@hallyn.com>:
  - Use "mnt_userns" to refer to a vfsmount's userns everywhere to make
    terminology consistent.
---
 include/linux/fs.h | 47 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8667d0cdc71e..0c820837d240 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -39,6 +39,7 @@
 #include <linux/fs_types.h>
 #include <linux/build_bug.h>
 #include <linux/stddef.h>
+#include <linux/cred.h>
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
@@ -1574,6 +1575,52 @@ static inline void i_gid_write(struct inode *inode, gid_t gid)
 	inode->i_gid = make_kgid(inode->i_sb->s_user_ns, gid);
 }
 
+static inline kuid_t kuid_into_mnt(struct user_namespace *mnt_userns,
+				   kuid_t kuid)
+{
+	return make_kuid(mnt_userns, __kuid_val(kuid));
+}
+
+static inline kgid_t kgid_into_mnt(struct user_namespace *mnt_userns,
+				   kgid_t kgid)
+{
+	return make_kgid(mnt_userns, __kgid_val(kgid));
+}
+
+static inline kuid_t i_uid_into_mnt(struct user_namespace *mnt_userns,
+				    const struct inode *inode)
+{
+	return kuid_into_mnt(mnt_userns, inode->i_uid);
+}
+
+static inline kgid_t i_gid_into_mnt(struct user_namespace *mnt_userns,
+				    const struct inode *inode)
+{
+	return kgid_into_mnt(mnt_userns, inode->i_gid);
+}
+
+static inline kuid_t kuid_from_mnt(struct user_namespace *mnt_userns,
+				   kuid_t kuid)
+{
+	return KUIDT_INIT(from_kuid(mnt_userns, kuid));
+}
+
+static inline kgid_t kgid_from_mnt(struct user_namespace *mnt_userns,
+				   kgid_t kgid)
+{
+	return KGIDT_INIT(from_kgid(mnt_userns, kgid));
+}
+
+static inline kuid_t fsuid_into_mnt(struct user_namespace *mnt_userns)
+{
+	return kuid_from_mnt(mnt_userns, current_fsuid());
+}
+
+static inline kgid_t fsgid_into_mnt(struct user_namespace *mnt_userns)
+{
+	return kgid_from_mnt(mnt_userns, current_fsgid());
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
