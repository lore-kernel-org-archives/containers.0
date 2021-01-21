Return-Path: <SRS0=Ull0=GY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C29CC433DB
	for <containers@archiver.kernel.org>; Thu, 21 Jan 2021 13:34:00 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A171F23A40
	for <containers@archiver.kernel.org>; Thu, 21 Jan 2021 13:33:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A171F23A40
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 30C8C86277;
	Thu, 21 Jan 2021 13:33:59 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id FnxPRp5s_IuM; Thu, 21 Jan 2021 13:33:58 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id AC382861F1;
	Thu, 21 Jan 2021 13:33:58 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A60E4C088B;
	Thu, 21 Jan 2021 13:33:58 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 2C40AC013A
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:33:57 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 1682686214
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:33:57 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id FJiav4Nt2hA2
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:33:52 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 820D7861F1
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:33:52 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1l2ZuM-0005g7-Ag; Thu, 21 Jan 2021 13:21:54 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>,
 linux-fsdevel@vger.kernel.org
Subject: [PATCH v6 23/40] exec: handle idmapped mounts
Date: Thu, 21 Jan 2021 14:19:42 +0100
Message-Id: <20210121131959.646623-24-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210121131959.646623-1-christian.brauner@ubuntu.com>
References: <20210121131959.646623-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=z3V1fTqinwXFXuBPT/F1/hXfgz5+RFdSDv1+bqcElO4=;
 m=pa7oyqjV6cs0De7RkFUKqnoILUWsjrd+GGkDcRnF7e4=;
 p=e3JlF/8T1cdyjaEUPbrFI9rl6HdxUVBqTEYS22fNFZk=;
 g=96f8f9f670a40251c9d649d880221f3c3f943146
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCYAl9pQAKCRCRxhvAZXjconUpAQCTIZQ
 8C3ba4lje18NvrTHsReci/Ovd9qdOQRTBQ2jEdwD/YSyNacQTQKobAyIgKGa8ALgMZ7LbpDA6GlTv
 S/f8HQw=
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

When executing a setuid binary the kernel will verify in bprm_fill_uid()
that the inode has a mapping in the caller's user namespace before
setting the callers uid and gid. Let bprm_fill_uid() handle idmapped
mounts. If the inode is accessed through an idmapped mount it is mapped
according to the mount's user namespace. Afterwards the checks are
identical to non-idmapped mounts. If the initial user namespace is
passed nothing changes so non-idmapped mounts will see identical
behavior as before.

Link: https://lore.kernel.org/r/20210112220124.837960-32-christian.brauner@ubuntu.com
Cc: Christoph Hellwig <hch@lst.de>
Cc: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
unchanged

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
base-commit: 19c329f6808995b142b3966301f217c831e7cf31

- Christoph Hellwig <hch@lst.de>:
  - Use new file_mnt_user_ns() helper.
---
 fs/exec.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index d803227805f6..48d1e8b1610b 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1580,6 +1580,7 @@ static void check_unsafe_exec(struct linux_binprm *bprm)
 static void bprm_fill_uid(struct linux_binprm *bprm, struct file *file)
 {
 	/* Handle suid and sgid on files */
+	struct user_namespace *mnt_userns;
 	struct inode *inode;
 	unsigned int mode;
 	kuid_t uid;
@@ -1596,13 +1597,15 @@ static void bprm_fill_uid(struct linux_binprm *bprm, struct file *file)
 	if (!(mode & (S_ISUID|S_ISGID)))
 		return;
 
+	mnt_userns = file_mnt_user_ns(file);
+
 	/* Be careful if suid/sgid is set */
 	inode_lock(inode);
 
 	/* reload atomically mode/uid/gid now that lock held */
 	mode = inode->i_mode;
-	uid = inode->i_uid;
-	gid = inode->i_gid;
+	uid = i_uid_into_mnt(mnt_userns, inode);
+	gid = i_gid_into_mnt(mnt_userns, inode);
 	inode_unlock(inode);
 
 	/* We ignore suid/sgid if there are no mappings for them in the ns */
-- 
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
