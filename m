Return-Path: <SRS0=Ull0=GY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10AF4C433DB
	for <containers@archiver.kernel.org>; Thu, 21 Jan 2021 13:21:47 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6184B206A3
	for <containers@archiver.kernel.org>; Thu, 21 Jan 2021 13:21:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6184B206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 97D4D8629C;
	Thu, 21 Jan 2021 13:21:45 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id kA5Ac8EIBMAb; Thu, 21 Jan 2021 13:21:44 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 8323C8624A;
	Thu, 21 Jan 2021 13:21:44 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 67FB3C088B;
	Thu, 21 Jan 2021 13:21:44 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B79A5C013A
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:21:42 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 961A62079D
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:21:42 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id iCyiTFazRdy9
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:21:40 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by silver.osuosl.org (Postfix) with ESMTPS id 12EBB204A7
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:21:39 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1l2Zsx-0005g7-Vb; Thu, 21 Jan 2021 13:20:28 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>,
 linux-fsdevel@vger.kernel.org
Subject: [PATCH v6 02/40] fs: add id translation helpers
Date: Thu, 21 Jan 2021 14:19:21 +0100
Message-Id: <20210121131959.646623-3-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210121131959.646623-1-christian.brauner@ubuntu.com>
References: <20210121131959.646623-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=DPHLY9J1WgTtTJIZfW+M0ys29DrUndhBq8NbMQ4LhTc=;
 m=Z8GBK4fC03sqIZqOXqQYkCcHQhdF7ERtuNE2eOhnSzE=;
 p=i6IwWhz0PkRJmocnM2jCkNT8zKQq005bIpkzoIXat+A=;
 g=ec4a8e87015d814e143e60b5b5e399b0589415a2
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCYAl9owAKCRCRxhvAZXjconzfAQDQavg
 rIQRRUmnUDAhPbiiIzXQemWyr2/c439+nPRr9LgEA1vZvPehXei8CIjRiOLT8+cPPAQyc9a5nYiYG
 h9Gl/gQ=
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Tycho Andersen <tycho@tycho.ws>,
 Paul Moore <paul@paul-moore.com>, Jonathan Corbet <corbet@lwn.net>,
 smbarber@chromium.org, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
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

Add simple helpers to make it easy to map kuids into and from idmapped
mounts. We provide simple wrappers that filesystems can use to e.g.
initialize inodes similar to i_{uid,gid}_read() and i_{uid,gid}_write().
Accessing an inode through an idmapped mount maps the i_uid and i_gid of
the inode to the mount's user namespace. If the fsids are used to
initialize inodes they are unmapped according to the mount's user
namespace. Passing the initial user namespace to these helpers makes
them a nop and so any non-idmapped paths will not be impacted.

Link: https://lore.kernel.org/r/20210112220124.837960-9-christian.brauner@ubuntu.com
Cc: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
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

/* v5 */
unchanged
base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837

/* v6 */
unchanged
base-commit: 19c329f6808995b142b3966301f217c831e7cf31
---
 include/linux/fs.h | 47 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index fd0b80e6361d..3165998e2294 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -40,6 +40,7 @@
 #include <linux/build_bug.h>
 #include <linux/stddef.h>
 #include <linux/mount.h>
+#include <linux/cred.h>
 
 #include <asm/byteorder.h>
 #include <uapi/linux/fs.h>
@@ -1573,6 +1574,52 @@ static inline void i_gid_write(struct inode *inode, gid_t gid)
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
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
