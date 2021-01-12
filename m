Return-Path: <SRS0=YWEV=GP=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7B08C433E0
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:04:12 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 67F6C221F5
	for <containers@archiver.kernel.org>; Tue, 12 Jan 2021 22:04:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67F6C221F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 286FA20495;
	Tue, 12 Jan 2021 22:04:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ZWe0vkSx95wK; Tue, 12 Jan 2021 22:04:07 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id D6C7A204A0;
	Tue, 12 Jan 2021 22:04:06 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id CD9B3C0FA8;
	Tue, 12 Jan 2021 22:04:06 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 3AABBC013A
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:04:05 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 29F6686166
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:04:05 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 2DtmAQucHfYw
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:04:03 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id 2119486149
 for <containers@lists.linux-foundation.org>;
 Tue, 12 Jan 2021 22:04:03 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kzRko-0003bd-DF; Tue, 12 Jan 2021 22:03:06 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH v5 09/42] mount: attach mappings to mounts
Date: Tue, 12 Jan 2021 23:00:51 +0100
Message-Id: <20210112220124.837960-10-christian.brauner@ubuntu.com>
X-Mailer: git-send-email 2.30.0
In-Reply-To: <20210112220124.837960-1-christian.brauner@ubuntu.com>
References: <20210112220124.837960-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
X-Patch-Hashes: v=1; h=sha256; i=RNdtgoKaLGCMkof4zQAU3N/xXjoHA/9IvgBRCO94lyQ=;
 m=m4sUTX63tJxvlN1Z3yC4IXx3n9AwTpPsjK1VR2fo7TE=;
 p=ACCirFhhOVkzdjl4ucxJqbt+8lVejkyYQx6FbUt2W0Y=;
 g=4082bc07095b82d49722a5cf3c1cbde1a8cff890
X-Patch-Sig: m=pgp; i=christian.brauner@ubuntu.com; s=0x0x91C61BC06578DCA2;
 b=iHUEABYKAB0WIQRAhzRXHqcMeLMyaSiRxhvAZXjcogUCX/4YtQAKCRCRxhvAZXjcojOHAPwJ60p
 Jde8zuYoECLqnZgXBRFHaHLBnEA7sZmKWUf76yQD/d0wHNPoB6SEzYiVZsKY/YVpkPJYpt2GB76b9
 R2Jp6g4=
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

In order to support per-mount idmappings vfsmounts will be marked with
user namespaces. The idmapping associated with that user namespace will
be used to map the ids of vfs objects when they are accessed through
that mount. By default all vfsmounts are marked with the initial user
namespace. The initial user namespace is used to indicate that a mount
is not idmapped. All operations behave as before.

Based on prior discussions we want to attach the whole user namespace
and not just a dedicated idmapping struct. This allows us to reuse all
the helpers that already exist for dealing with idmappings instead of
introducing a whole new range of helpers. In addition, if we decide in
the future that we are confident enough to enable unprivileged users to
setup idmapped mounts we can allow the user namespace an already
idmapped mounts has been marked with to be replaced with another one.
The permission checking would then take into account whether the caller
is privileged in the user namespace the mount is currently marked with
and that is about to be replaced with another one. For now, we will
enforce in later patches that once a mount has been idmapped it can't be
remapped. This keeps permission checking and life-cycle management
simple, especially since users can always create a new mount with a
different idmapping anyway.

The idea to attach user namespaces to vfsmounts has been floated around
in various forms at Linux Plumbers in ~2018 with the original idea
tracing back to a discussion during a conference in St. Petersburg
between Christoph, Tycho, and myself.

Cc: Christoph Hellwig <hch@lst.de>
Cc: David Howells <dhowells@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
patch introduced
- Christoph Hellwig <hch@lst.de>:
  - Split internal implementation into separate patch and move syscall
    implementation later.

/* v3 */
- David Howells <dhowells@redhat.com>:
  - Remove MNT_IDMAPPED flag. We can simply check the pointer and use
    smp_load_acquire() in later patches.

- Tycho Andersen <tycho@tycho.pizza>:
  - Use READ_ONCE() in mnt_user_ns().

/* v4 */
- Serge Hallyn <serge@hallyn.com>:
  - Use "mnt_userns" to refer to a vfsmount's userns everywhere to make
    terminology consistent.

- Christoph Hellwig <hch@lst.de>:
  - Drop the READ_ONCE() from this patch. At this point in the series we
    don't allowing changing the vfsmount's userns. The infra to do that
    is only introduced as almost the last patch in the series and there
    we immediately use smp_load_acquire() and smp_store_release().

/* v5 */
base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837
---
 fs/namespace.c        | 9 +++++++++
 include/linux/fs.h    | 1 +
 include/linux/mount.h | 6 ++++++
 3 files changed, 16 insertions(+)

diff --git a/fs/namespace.c b/fs/namespace.c
index 6efae2681bcd..ceb2943f8458 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -228,6 +228,7 @@ static struct mount *alloc_vfsmnt(const char *name)
 		INIT_HLIST_NODE(&mnt->mnt_mp_list);
 		INIT_LIST_HEAD(&mnt->mnt_umounting);
 		INIT_HLIST_HEAD(&mnt->mnt_stuck_children);
+		mnt->mnt.mnt_userns = &init_user_ns;
 	}
 	return mnt;
 
@@ -567,6 +568,11 @@ int sb_prepare_remount_readonly(struct super_block *sb)
 
 static void free_vfsmnt(struct mount *mnt)
 {
+	struct user_namespace *mnt_userns;
+
+	mnt_userns = mnt_user_ns(&mnt->mnt);
+	if (mnt_userns != &init_user_ns)
+		put_user_ns(mnt_userns);
 	kfree_const(mnt->mnt_devname);
 #ifdef CONFIG_SMP
 	free_percpu(mnt->mnt_pcp);
@@ -1075,6 +1081,9 @@ static struct mount *clone_mnt(struct mount *old, struct dentry *root,
 	mnt->mnt.mnt_flags &= ~(MNT_WRITE_HOLD|MNT_MARKED|MNT_INTERNAL);
 
 	atomic_inc(&sb->s_active);
+	mnt->mnt.mnt_userns = mnt_user_ns(&old->mnt);
+	if (mnt->mnt.mnt_userns != &init_user_ns)
+		mnt->mnt.mnt_userns = get_user_ns(mnt->mnt.mnt_userns);
 	mnt->mnt.mnt_sb = sb;
 	mnt->mnt.mnt_root = dget(root);
 	mnt->mnt_mountpoint = mnt->mnt.mnt_root;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 1da4c21fb588..0e2b8d235dca 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2278,6 +2278,7 @@ struct file_system_type {
 #define FS_HAS_SUBTYPE		4
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
 #define FS_DISALLOW_NOTIFY_PERM	16	/* Disable fanotify permission events */
+#define FS_ALLOW_IDMAP         32      /* FS has been updated to handle vfs idmappings. */
 #define FS_THP_SUPPORT		8192	/* Remove once all fs converted */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
 	int (*init_fs_context)(struct fs_context *);
diff --git a/include/linux/mount.h b/include/linux/mount.h
index aaf343b38671..52de25e08319 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -72,8 +72,14 @@ struct vfsmount {
 	struct dentry *mnt_root;	/* root of the mounted tree */
 	struct super_block *mnt_sb;	/* pointer to superblock */
 	int mnt_flags;
+	struct user_namespace *mnt_userns;
 } __randomize_layout;
 
+static inline struct user_namespace *mnt_user_ns(const struct vfsmount *mnt)
+{
+	return mnt->mnt_userns;
+}
+
 struct file; /* forward dec */
 struct path;
 
-- 
2.30.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
