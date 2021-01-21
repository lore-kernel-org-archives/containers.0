Return-Path: <SRS0=Ull0=GY=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AD55C433DB
	for <containers@archiver.kernel.org>; Thu, 21 Jan 2021 13:28:59 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id A630B206DC
	for <containers@archiver.kernel.org>; Thu, 21 Jan 2021 13:28:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A630B206DC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 6D8AB20530;
	Thu, 21 Jan 2021 13:28:58 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jxM6GAtzs02i; Thu, 21 Jan 2021 13:28:56 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 6936220380;
	Thu, 21 Jan 2021 13:28:56 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 56B04C088B;
	Thu, 21 Jan 2021 13:28:56 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id D8C90C013A
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:28:54 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id C6B5384EE9
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:28:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id XlHW4r4mRAhx
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:28:52 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by whitealder.osuosl.org (Postfix) with ESMTPS id A479784EB9
 for <containers@lists.linux-foundation.org>;
 Thu, 21 Jan 2021 13:28:52 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1l2Zux-0005g7-UT; Thu, 21 Jan 2021 13:22:32 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>,
 linux-fsdevel@vger.kernel.org
Subject: [PATCH v6 31/40] namespace: only take read lock in
 do_reconfigure_mnt()
Date: Thu, 21 Jan 2021 14:19:50 +0100
Message-Id: <20210121131959.646623-32-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210121131959.646623-1-christian.brauner@ubuntu.com>
References: <20210121131959.646623-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=I7aJzwt0DpkJRJifO843fvdrR3C7hhJVdcz6GAHs5To=;
 m=kYGZs6uxDqNnDWq6amn5PljPB3N7RA7sHRkNgwMp1lA=;
 p=O0TWEIwrbg8QrF14GljNCoXe8MA31Ulu2rf6pUWyHAo=;
 g=f6e4b4a5508c730a9bc5fc9fed06d285573d486d
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCYAl9pgAKCRCRxhvAZXjcoheiAQCNq6g
 R7W31jEDQ1qTDxON63E9c5BpR/hnvmNsehDL4bgEA04lytDQ5sUwwJM8ZlP0XfLmigSZ09W7wckQz
 f0PzmgI=
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

do_reconfigure_mnt() used to take the down_write(&sb->s_umount) lock
which seems unnecessary since we're not changing the superblock. We're
only checking whether it is already read-only. Setting other mount
attributes is protected by lock_mount_hash() afaict and not by s_umount.

The history of down_write(&sb->s_umount) lock being taken when setting
mount attributes dates back to the introduction of MNT_READONLY in [2].
This introduced the concept of having read-only mounts in contrast to
just having a read-only superblock. When it got introduced it was simply
plumbed into do_remount() which already took down_write(&sb->s_umount)
because it was only used to actually change the superblock before [2].
Afaict, it would've already been possible back then to only use
down_read(&sb->s_umount) for MS_BIND | MS_REMOUNT since actual mount
options were protected by the vfsmount lock already. But that would've
meant special casing the locking for MS_BIND | MS_REMOUNT in
do_remount() which people might not have considered worth it.
Then in [1] MS_BIND | MS_REMOUNT mount option changes were split out of
do_remount() into do_reconfigure_mnt() but the down_write(&sb->s_umount)
lock was simply copied over.
Now that we have this be a separate helper only take the
down_read(&sb->s_umount) lock since we're only interested in checking
whether the super block is currently read-only and blocking any writers
from changing it. Essentially, checking that the super block is
read-only has the advantage that we can avoid having to go into the
slowpath and through MNT_WRITE_HOLD and can simply set the read-only
flag on the mount in set_mount_attributes().

[1]: commit 43f5e655eff7 ("vfs: Separate changing mount flags full remount")
[2]: commit 2e4b7fcd9260 ("[PATCH] r/o bind mounts: honor mount writer counts at remount")

Link: https://lore.kernel.org/r/20210112220124.837960-4-christian.brauner@ubuntu.com
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
unchanged

/* v5 */
unchanged
base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837

/* v6 */
unchanged
base-commit: 19c329f6808995b142b3966301f217c831e7cf31
---
 fs/namespace.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 5fceb2854395..367f1c7cb6db 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -2527,10 +2527,6 @@ static int change_mount_ro_state(struct mount *mnt, unsigned int mnt_flags)
 	return 0;
 }
 
-/*
- * Update the user-settable attributes on a mount.  The caller must hold
- * sb->s_umount for writing.
- */
 static void set_mount_attributes(struct mount *mnt, unsigned int mnt_flags)
 {
 	mnt_flags |= mnt->mnt.mnt_flags & ~MNT_USER_SETTABLE_MASK;
@@ -2580,13 +2576,17 @@ static int do_reconfigure_mnt(struct path *path, unsigned int mnt_flags)
 	if (!can_change_locked_flags(mnt, mnt_flags))
 		return -EPERM;
 
-	down_write(&sb->s_umount);
+	/*
+	 * We're only checking whether the superblock is read-only not
+	 * changing it, so only take down_read(&sb->s_umount).
+	 */
+	down_read(&sb->s_umount);
 	lock_mount_hash();
 	ret = change_mount_ro_state(mnt, mnt_flags);
 	if (ret == 0)
 		set_mount_attributes(mnt, mnt_flags);
 	unlock_mount_hash();
-	up_write(&sb->s_umount);
+	up_read(&sb->s_umount);
 
 	mnt_warn_timestamp_expiry(path, &mnt->mnt);
 
-- 
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
