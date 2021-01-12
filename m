Return-Path: <SRS0=YWEV=GP=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C5D8C43331
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:03:51 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id B1068221F5
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:03:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1068221F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by fraxinus.osuosl.org (Postfix) with ESMTP id 319CE85FB6;
	Tue, 12 Jan 2021 22:03:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id yTlM3ctR_XhB; Tue, 12 Jan 2021 22:03:48 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by fraxinus.osuosl.org (Postfix) with ESMTP id DA7A985F67;
	Tue, 12 Jan 2021 22:03:48 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id BEF52C0893;
	Tue, 12 Jan 2021 22:03:48 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
 by lists.linuxfoundation.org (Postfix) with ESMTP id C2020C013A
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:03:47 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by silver.osuosl.org (Postfix) with ESMTP id 7668A20493
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:03:47 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id NvFZxupqTV8c
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:03:45 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by silver.osuosl.org (Postfix) with ESMTPS id ADBC620469
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:03:45 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kzRkU-0003bd-R2; Tue, 12 Jan 2021 22:02:46 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 02/42] mount: make {lock,unlock}_mount_hash() static
Date: Tue, 12 Jan 2021 23:00:44 +0100
Message-Id: <20210112220124.837960-3-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210112220124.837960-1-christian.brauner@ubuntu.com>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=vO6mqD1pvztvOW1otxIX/33XHCNZr+llU/zGWpmgRcU=;
 m=urR2rAIlQm7B+Wnhux1HQqMBhK+gzFRqnuakSaYsLEw=;
 p=FzHd8xIvHJqF6DeGhIkxr3GWqyk+wfjD+OZpRToKI4o=;
 g=a01f7f9b00b67a1698d6ed6ffbed46e285973451
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCX/4YtQAKCRCRxhvAZXjcorMkAQDuVqe
 kjayCqPe3qytw6oZ7nOgpZjngGZBcdjtF8EvVmQD/TTQi6iRuXo2TWtRa3j82P+plXgb3Vj3OCV7l
 LedXkwo=
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

The lock_mount_hash() and unlock_mount_hash() helpers are never called
outside a single file. Remove them from the header and make them static
to reflect this fact. There's no need to have them callable from other
places right now, as Christoph observed.

Suggested-by: Christoph Hellwig <hch@lst.de>
Cc: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
- Christoph Hellwig <hch@lst.de>:
  - Add a patch to make {lock,unlock)_mount_hash() static.

/* v3 */
unchanged

/* v4 */
unchanged

/* v5 */
base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837
---
 fs/mount.h     | 10 ----------
 fs/namespace.c | 10 ++++++++++
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/fs/mount.h b/fs/mount.h
index ce6c376e0bc2..0b6e08cf8afb 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -124,16 +124,6 @@ static inline void get_mnt_ns(struct mnt_namespace *ns)
 
 extern seqlock_t mount_lock;
 
-static inline void lock_mount_hash(void)
-{
-	write_seqlock(&mount_lock);
-}
-
-static inline void unlock_mount_hash(void)
-{
-	write_sequnlock(&mount_lock);
-}
-
 struct proc_mounts {
 	struct mnt_namespace *ns;
 	struct path root;
diff --git a/fs/namespace.c b/fs/namespace.c
index dc782ddf603e..8cb2c132525a 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -87,6 +87,16 @@ EXPORT_SYMBOL_GPL(fs_kobj);
  */
 __cacheline_aligned_in_smp DEFINE_SEQLOCK(mount_lock);
 
+static inline void lock_mount_hash(void)
+{
+	write_seqlock(&mount_lock);
+}
+
+static inline void unlock_mount_hash(void)
+{
+	write_sequnlock(&mount_lock);
+}
+
 static inline struct hlist_head *m_hash(struct vfsmount *mnt, struct dentry *dentry)
 {
 	unsigned long tmp = ((unsigned long)mnt / L1_CACHE_BYTES);
-- 
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
