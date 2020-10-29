Return-Path: <SRS0=MeFG=EE=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 934E3C4363A
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:06 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id F2B6C20790
	for <containers@archiver.kernel.org>; Thu, 29 Oct 2020 00:36:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2B6C20790
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ubuntu.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 597A320002;
	Thu, 29 Oct 2020 00:36:04 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 4NCaGNRw5LJj; Thu, 29 Oct 2020 00:35:57 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 7105C204E1;
	Thu, 29 Oct 2020 00:35:57 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 56EB8C1AD8;
	Thu, 29 Oct 2020 00:35:57 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 51F70C0051
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:56 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 3F30F87338
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:56 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id x07P31pt1unn
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:54 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from youngberry.canonical.com (youngberry.canonical.com
 [91.189.89.112])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 503A6872FB
 for <containers@lists.linux-foundation.org>;
 Thu, 29 Oct 2020 00:35:54 +0000 (UTC)
Received: from ip5f5af0a0.dynamic.kabel-deutschland.de ([95.90.240.160]
 helo=wittgenstein.fritz.box) by youngberry.canonical.com with esmtpsa
 (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128) (Exim 4.86_2)
 (envelope-from <christian.brauner@ubuntu.com>)
 id 1kXvuS-0008Ep-DZ; Thu, 29 Oct 2020 00:35:20 +0000
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
 Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org
Subject: [PATCH 05/34] fs: introduce MOUNT_ATTR_IDMAP
Date: Thu, 29 Oct 2020 01:32:23 +0100
Message-Id: <20201029003252.2128653-6-christian.brauner@ubuntu.com>
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

Introduce a new mount bind mount property to allow idmapping mounts. The
MOUNT_ATTR_IDMAP flag can be set via the new mount_setattr() syscall
together with a file descriptor referring to a user namespace.

The user namespace referenced by the namespace file descriptor will be
attached to the bind mount. All interactions with the filesystem going
through that mount will be shifted according to the mapping specified in that
user namespace.

Using user namespaces to mark mounts means we can reuse all the existing
infrastructure in the kernel that already exists to handle idmappings and can
also use this for permission checking to allow unprivileged user to create
idmapped mounts.

Idmapping a mount is decoupled from the caller's user and mount namespace.
This means idmapped mounts can be created in the initial user namespace
which is an important use-case for e.g. systemd-homed, portable usb-sticks
between systems, and other use-cases that have been brought up. For example,
assume a home directory where all files are owned by uid and gid 1000 and the
home directory is brought to a new laptop where the user has id 12345. The
system administrator can simply create a mount of this home directory with a
mapping of 1000:12345:1 other mappings to indicate the ids should be kept.
(With this it is e.g. also possible to create idmapped mounts on the host with
 an identity mapping 1:1:100000 where the root user is not mapped. A user with
 root access that e.g. has been pivot rooted into such a mount on the host will
 be not be able to execute, read, write, or create files as root.)

Given that idmapping a mount is decoupled from the caller's user namespace
a sufficiently privileged process such as a container manager can set up a
shifted mount for the container and the container can simply pivot root to
it. There's no need for the container to do anything. The mount will appear
correctly mapped independent of the user namespace the container uses. This
means we don't need to mark a mount as idmappable.

In order to create an idmapped mount the following conditions must be
fulfilled. The caller must either be privileged in the user namespace of
the superblock the mount belongs to or the mount must have already been
shifted before and the caller must be privileged in the user namespace that
this mount has been shifted to. The latter case means that shifted mounts
can e.g. be created by unprivileged users provided that the underlying
mount has already been idmapped to a user namespace they have privilege
over.

Once a mount has been idmapped it's idmapping cannot be changed. This is to
keep things simple. Callers that want another idmapping can simply create
another detached mount and idmap it.

The new CONFIG_IDMAP_MOUNTS option that can be used to compile the
kernel with idmapped mount support. It will default to off for quite
some time. Let's not be over confident.

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
 fs/Kconfig                 |   6 ++
 fs/internal.h              |   1 +
 fs/namespace.c             | 157 ++++++++++++++++++++++++++++++++++++-
 include/linux/fs.h         |   1 +
 include/linux/mount.h      |  20 ++++-
 include/uapi/linux/mount.h |   6 +-
 6 files changed, 186 insertions(+), 5 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index aa4c12282301..2d45ec3c7e04 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -15,6 +15,12 @@ config VALIDATE_FS_PARSER
 	  Enable this to perform validation of the parameter description for a
 	  filesystem when it is registered.
 
+config IDMAP_MOUNTS
+	bool "Support id mappings per mount"
+	default n
+	help
+	  This allows the vfs to create idmappings per vfsmount.
+
 if BLOCK
 
 config FS_IOMAP
diff --git a/fs/internal.h b/fs/internal.h
index a5a6c470dc07..b6046b5186cd 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -88,6 +88,7 @@ struct mount_kattr {
 	unsigned int propagation;
 	unsigned int lookup_flags;
 	bool recurse;
+	struct user_namespace *userns;
 };
 
 extern struct vfsmount *lookup_mnt(const struct path *);
diff --git a/fs/namespace.c b/fs/namespace.c
index e9c515b012a4..aef39fc74afa 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -25,6 +25,7 @@
 #include <linux/proc_ns.h>
 #include <linux/magic.h>
 #include <linux/memblock.h>
+#include <linux/proc_fs.h>
 #include <linux/task_work.h>
 #include <linux/sched/task.h>
 #include <uapi/linux/mount.h>
@@ -210,6 +211,9 @@ static struct mount *alloc_vfsmnt(const char *name)
 		INIT_HLIST_NODE(&mnt->mnt_mp_list);
 		INIT_LIST_HEAD(&mnt->mnt_umounting);
 		INIT_HLIST_HEAD(&mnt->mnt_stuck_children);
+#ifdef CONFIG_IDMAP_MOUNTS
+		mnt->mnt.mnt_user_ns = &init_user_ns;
+#endif
 	}
 	return mnt;
 
@@ -555,6 +559,13 @@ int sb_prepare_remount_readonly(struct super_block *sb)
 
 static void free_vfsmnt(struct mount *mnt)
 {
+#ifdef CONFIG_IDMAP_MOUNTS
+	if ((mnt->mnt.mnt_flags & MNT_IDMAPPED) &&
+	    mnt_user_ns(&mnt->mnt) != &init_user_ns) {
+		put_user_ns(mnt->mnt.mnt_user_ns);
+		mnt->mnt.mnt_user_ns = NULL;
+	}
+#endif
 	kfree_const(mnt->mnt_devname);
 #ifdef CONFIG_SMP
 	free_percpu(mnt->mnt_pcp);
@@ -1063,6 +1074,11 @@ static struct mount *clone_mnt(struct mount *old, struct dentry *root,
 	mnt->mnt.mnt_flags &= ~(MNT_WRITE_HOLD|MNT_MARKED|MNT_INTERNAL);
 
 	atomic_inc(&sb->s_active);
+#ifdef CONFIG_IDMAP_MOUNTS
+	mnt->mnt.mnt_user_ns = old->mnt.mnt_user_ns;
+	if (mnt_user_ns(&old->mnt) != &init_user_ns)
+		mnt->mnt.mnt_user_ns = get_user_ns(mnt->mnt.mnt_user_ns);
+#endif
 	mnt->mnt.mnt_sb = sb;
 	mnt->mnt.mnt_root = dget(root);
 	mnt->mnt_mountpoint = mnt->mnt.mnt_root;
@@ -3454,7 +3470,8 @@ static int build_attr_flags(unsigned int attr_flags, unsigned int *flags)
 			   MOUNT_ATTR_NODEV |
 			   MOUNT_ATTR_NOEXEC |
 			   MOUNT_ATTR__ATIME |
-			   MOUNT_ATTR_NODIRATIME))
+			   MOUNT_ATTR_NODIRATIME |
+			   MOUNT_ATTR_IDMAP))
 		return -EINVAL;
 
 	if (attr_flags & MOUNT_ATTR_RDONLY)
@@ -3467,6 +3484,8 @@ static int build_attr_flags(unsigned int attr_flags, unsigned int *flags)
 		aflags |= MNT_NOEXEC;
 	if (attr_flags & MOUNT_ATTR_NODIRATIME)
 		aflags |= MNT_NODIRATIME;
+	if (attr_flags & MOUNT_ATTR_IDMAP)
+		aflags |= MNT_IDMAPPED;
 
 	*flags = aflags;
 	return 0;
@@ -3494,6 +3513,14 @@ SYSCALL_DEFINE3(fsmount, int, fs_fd, unsigned int, flags,
 	if ((flags & ~(FSMOUNT_CLOEXEC)) != 0)
 		return -EINVAL;
 
+	if (attr_flags & ~(MOUNT_ATTR_RDONLY |
+			   MOUNT_ATTR_NOSUID |
+			   MOUNT_ATTR_NODEV |
+			   MOUNT_ATTR_NOEXEC |
+			   MOUNT_ATTR__ATIME |
+			   MOUNT_ATTR_NODIRATIME))
+		return -EINVAL;
+
 	ret = build_attr_flags(attr_flags, &mnt_flags);
 	if (ret)
 		return ret;
@@ -3836,6 +3863,7 @@ static int do_mount_setattr(struct path *path, struct mount_kattr *kattr)
 	 */
 	m = mnt;
 	do {
+		unsigned int old_flags;
 		last = m;
 
 		if (!can_change_locked_flags(m, all_raised)) {
@@ -3843,11 +3871,61 @@ static int do_mount_setattr(struct path *path, struct mount_kattr *kattr)
 			break;
 		}
 
-		if (rdonly_set && !(m->mnt.mnt_flags & MNT_READONLY)) {
+		old_flags = READ_ONCE(m->mnt.mnt_flags);
+		if (rdonly_set && !(old_flags & MNT_READONLY)) {
 			err = mnt_hold_writers(m);
 			if (err)
 				break;
 		}
+
+#ifdef CONFIG_IDMAP_MOUNTS
+		if (kattr->attr_set & MNT_IDMAPPED) {
+			struct user_namespace *user_ns;
+			struct vfsmount *vmnt;
+
+			/*
+			 * Once a mount has been idmapped we don't allow it to
+			 * change its mapping. It makes things simpler and
+			 * callers can just create a detached mount they can
+			 * idmap. So make sure that this mount is the root of
+			 * an anon namespace.
+			 */
+			if ((old_flags & MNT_IDMAPPED) && !is_anon_ns(m->mnt_ns)) {
+				err = -EPERM;
+				break;
+			}
+
+			/*
+			 * The underlying filesystem doesn't support idmapped
+			 * mounts yet.
+			 */
+			vmnt = &m->mnt;
+			if (!(vmnt->mnt_sb->s_type->fs_flags & FS_ALLOW_IDMAP)) {
+				err = -EINVAL;
+				break;
+			}
+
+			/* We're controlling the superblock. */
+			if (ns_capable(vmnt->mnt_sb->s_user_ns, CAP_SYS_ADMIN)) {
+				err = 0;
+				continue;
+			}
+
+			/*
+			 * The mount is already shifted to a user namespace
+			 * that we have control over. (We already verified that
+			 * this is the root of an anon namespace above.)
+			 */
+			user_ns = READ_ONCE(vmnt->mnt_user_ns);
+			if ((old_flags & MNT_IDMAPPED) && ns_capable(user_ns, CAP_SYS_ADMIN)) {
+				err = 0;
+				continue;
+			}
+
+			err = -EPERM;
+			break;
+		}
+#endif
 	} while (kattr->recurse && (m = next_mnt(m, mnt)));
 
 	m = mnt;
@@ -3860,6 +3938,20 @@ static int do_mount_setattr(struct path *path, struct mount_kattr *kattr)
 			new_flags &= ~kattr->attr_clr;
 			/* Raise flags user wants us to set. */
 			new_flags |= kattr->attr_set;
+
+			/*
+			 * The MNT_IDMAPPED flag should be seen _after_ the
+			 * user_ns pointer in struct vfsmount is valid.
+			 */
+#ifdef CONFIG_IDMAP_MOUNTS
+			if (kattr->attr_set & MNT_IDMAPPED) {
+				struct user_namespace *user_ns = READ_ONCE(m->mnt.mnt_user_ns);
+				WRITE_ONCE(m->mnt.mnt_user_ns, get_user_ns(kattr->userns));
+				if (user_ns != &init_user_ns)
+					put_user_ns(user_ns);
+			}
+			smp_wmb();
+#endif
 			WRITE_ONCE(m->mnt.mnt_flags, new_flags);
 		}
 
@@ -3893,12 +3985,20 @@ static int do_mount_setattr(struct path *path, struct mount_kattr *kattr)
 			cleanup_group_ids(mnt, NULL);
 	}
 
+#ifdef CONFIG_IDMAP_MOUNTS
+	if (kattr->attr_set & MNT_IDMAPPED) {
+		put_user_ns(kattr->userns);
+		kattr->userns = NULL;
+	}
+#endif
+
 	return err;
 }
 
 static int build_mount_kattr(const struct mount_attr *attr,
 			     struct mount_kattr *kattr, unsigned int flags)
 {
+	int err = 0;
 	unsigned int lookup_flags = LOOKUP_AUTOMOUNT | LOOKUP_FOLLOW;
 
 	if (flags & AT_NO_AUTOMOUNT)
@@ -3975,7 +4075,58 @@ static int build_mount_kattr(const struct mount_attr *attr,
 		}
 	}
 
-	return 0;
+#ifndef CONFIG_IDMAP_MOUNTS
+	if ((attr->attr_set | attr->attr_clr) & MOUNT_ATTR_IDMAP)
+		return -EINVAL;
+#else
+	if ((attr->attr_set & MOUNT_ATTR_IDMAP) && (attr->userns > INT_MAX))
+		return -EINVAL;
+
+	/* TODO: Implement MNT_IDMAPPED clearing. */
+	if (attr->attr_clr & MNT_IDMAPPED)
+		return -EINVAL;
+
+	if (attr->attr_set & MOUNT_ATTR_IDMAP) {
+		struct ns_common *ns;
+		struct user_namespace *user_ns;
+		struct file *file;
+
+		file = fget(attr->userns);
+		if (!file)
+			return -EBADF;
+
+		if (!proc_ns_file(file)) {
+			err = -EINVAL;
+			goto out_fput;
+		}
+
+		ns = get_proc_ns(file_inode(file));
+		if (ns->ops->type != CLONE_NEWUSER) {
+			err = -EINVAL;
+			goto out_fput;
+		}
+		user_ns = container_of(ns, struct user_namespace, ns);
+
+		/*
+		 * The init_user_ns is used to indicate that a vfsmount is not
+		 * idmapped. This is simpler than just having to treat NULL as
+		 * unmapped. Users wanting to idmap a mount to init_user_ns can
+		 * just use a namespace with an identity mapping.
+		 */
+		if (user_ns == &init_user_ns) {
+			err = -EPERM;
+			goto out_fput;
+		}
+
+		kattr->userns = get_user_ns(user_ns);
+		err = 0;
+	out_fput:
+		fput(file);
+	}
+
+#endif /* CONFIG_IDMAP_MOUNTS */
+
+	return err;
 }
 
 SYSCALL_DEFINE5(mount_setattr, int, dfd, const char __user *, path, unsigned int, flags,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 0bd126418bb6..8314cd351673 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2217,6 +2217,7 @@ struct file_system_type {
 #define FS_HAS_SUBTYPE		4
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
 #define FS_DISALLOW_NOTIFY_PERM	16	/* Disable fanotify permission events */
+#define FS_ALLOW_IDMAP		32	/* FS has been updated to handle vfs idmappings. */
 #define FS_THP_SUPPORT		8192	/* Remove once all fs converted */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
 	int (*init_fs_context)(struct fs_context *);
diff --git a/include/linux/mount.h b/include/linux/mount.h
index aaf343b38671..d4ae170b2c03 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -31,6 +31,7 @@ struct fs_context;
 #define MNT_RELATIME	0x20
 #define MNT_READONLY	0x40	/* does the user want this to be r/o? */
 #define MNT_NOSYMFOLLOW	0x80
+#define MNT_IDMAPPED	0x400
 
 #define MNT_SHRINKABLE	0x100
 #define MNT_WRITE_HOLD	0x200
@@ -47,7 +48,7 @@ struct fs_context;
 #define MNT_SHARED_MASK	(MNT_UNBINDABLE)
 #define MNT_USER_SETTABLE_MASK  (MNT_NOSUID | MNT_NODEV | MNT_NOEXEC \
 				 | MNT_NOATIME | MNT_NODIRATIME | MNT_RELATIME \
-				 | MNT_READONLY | MNT_NOSYMFOLLOW)
+				 | MNT_READONLY | MNT_NOSYMFOLLOW | MNT_IDMAPPED)
 #define MNT_ATIME_MASK (MNT_NOATIME | MNT_NODIRATIME | MNT_RELATIME )
 
 #define MNT_INTERNAL_FLAGS (MNT_SHARED | MNT_WRITE_HOLD | MNT_INTERNAL | \
@@ -72,8 +73,25 @@ struct vfsmount {
 	struct dentry *mnt_root;	/* root of the mounted tree */
 	struct super_block *mnt_sb;	/* pointer to superblock */
 	int mnt_flags;
+#ifdef CONFIG_IDMAP_MOUNTS
+	struct user_namespace *mnt_user_ns;
+#endif
 } __randomize_layout;
 
+static inline bool mnt_idmapped(const struct vfsmount *mnt)
+{
+	return READ_ONCE(mnt->mnt_flags) & MNT_IDMAPPED;
+}
+
+static inline struct user_namespace *mnt_user_ns(const struct vfsmount *mnt)
+{
+#ifdef CONFIG_IDMAP_MOUNTS
+	return READ_ONCE(mnt->mnt_user_ns);
+#else
+	return &init_user_ns;
+#endif
+}
+
 struct file; /* forward dec */
 struct path;
 
diff --git a/include/uapi/linux/mount.h b/include/uapi/linux/mount.h
index fb3ad26fdebf..672c58c619ed 100644
--- a/include/uapi/linux/mount.h
+++ b/include/uapi/linux/mount.h
@@ -117,6 +117,7 @@ enum fsconfig_command {
 #define MOUNT_ATTR_NOATIME	0x00000010 /* - Do not update access times. */
 #define MOUNT_ATTR_STRICTATIME	0x00000020 /* - Always perform atime updates */
 #define MOUNT_ATTR_NODIRATIME	0x00000080 /* Do not update directory access times */
+#define MOUNT_ATTR_IDMAP	0x00100000 /* Idmap this mount to @userns in mount_attr. */
 
 /*
  * mount_setattr()
@@ -125,6 +126,8 @@ struct mount_attr {
 	__u64 attr_set;
 	__u64 attr_clr;
 	__u64 propagation;
+	__u32 userns;
+	__u32 reserved[0];
 };
 
 /* Change propagation through mount_setattr(). */
@@ -138,6 +141,7 @@ enum propagation_type {
 
 /* List of all mount_attr versions. */
 #define MOUNT_ATTR_SIZE_VER0	24 /* sizeof first published struct */
-#define MOUNT_ATTR_SIZE_LATEST	MOUNT_ATTR_SIZE_VER0
+#define MOUNT_ATTR_SIZE_VER1	32 /* sizeof second published struct */
+#define MOUNT_ATTR_SIZE_LATEST	MOUNT_ATTR_SIZE_VER1
 
 #endif /* _UAPI_LINUX_MOUNT_H */
-- 
2.29.0

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
