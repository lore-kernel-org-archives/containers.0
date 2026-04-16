Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E03563BE623;
	Thu, 16 Apr 2026 13:30:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776346248; cv=none; b=QKvemG7Cnlopwt/E1+hvxC3dpJBVPSWD7x6wR9oT36eRxDR27Z/4k06k3OYn0he+kcXCXvlyYXmP5oQIu2cvkZi/QlJj67uF1Wfw2eXe9bQL71crhkb98QIc7r9VhsfFR5Z7pLhAhsSHSWCYmJVuQGkLTVFsT4G60QQGsUWKtrw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776346248; c=relaxed/simple;
	bh=EQ55YlF7GcAaCD2Yxr60QfxLvN+R0e7ao8Abz/pkFuI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=A5MLQfdQRyauWrQTsCYuyUmhgP4qcYYX4QprES8phGuYPERhh+oRoHXLWfGGBj3w95fTd1IJmYRoh8Q6HUGFn1ZnpmgxDyWCzE+uizVj4zP7fGmz2aHyfVNHPmr16KbdMo9uXxGN+NLW4VjbDF12I/emAF6FC9XTOeaEQ2S8bJU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=qzGvKXmI; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="qzGvKXmI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1738BC2BCAF;
	Thu, 16 Apr 2026 13:30:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776346247;
	bh=EQ55YlF7GcAaCD2Yxr60QfxLvN+R0e7ao8Abz/pkFuI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=qzGvKXmIeWgQ8NYBe2YlbJFEBXrM4et7OKJ0t0Hb4oeFtfqi6fQI6sC8ieg/E0Y0i
	 HBKCx2yCcDaw6Icw/Y3aELMmXYfEKwai8lcKrayQUYkp5tc5bKsz4uerhRqXrROK7Y
	 YlYMgYyG55UkWaqZApxsGSqg1bor24laaEpLFqquJ6zL7+7EQSjmbZYvFYgNHlJo+O
	 YODyIe/1AZmv5xJOKQjoycVSfL6S3KzCXJUwvL4EBaiC4Ic4GmzehMyPY5k0xEg1V+
	 iwdKrTih3j1gkYgBE4uo+55CuQ93WtQa+iAwUPhIsEIHgKGYWS551qvsVFlPmK5qYc
	 nrAg1Ouc6euQg==
Date: Thu, 16 Apr 2026 15:30:42 +0200
From: Christian Brauner <brauner@kernel.org>
To: Aleksa Sarai <cyphar@cyphar.com>
Cc: Alexey Gladkov <legion@kernel.org>, 
	Dan Klishch <danilklishch@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Kees Cook <keescook@chromium.org>, containers@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 4/5] proc: Skip the visibility check if subset=pid is
 used
Message-ID: <20260416-gewusel-dreck-63a7fc32a586@brauner>
References: <cover.1770979341.git.legion@kernel.org>
 <cover.1776079055.git.legion@kernel.org>
 <38572c1fb7cf55b4c27dd792adafa52f1216e3a3.1776079055.git.legion@kernel.org>
 <2026-04-16-serious-inky-roach-visitors-SZzNqk@cyphar.com>
 <2026-04-16-popular-long-bicep-bistros-8teEl3@cyphar.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="nfsjwfyis4t5hlj3"
Content-Disposition: inline
In-Reply-To: <2026-04-16-popular-long-bicep-bistros-8teEl3@cyphar.com>


--nfsjwfyis4t5hlj3
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Thu, Apr 16, 2026 at 10:46:50PM +1000, Aleksa Sarai wrote:
> On 2026-04-16, Aleksa Sarai <cyphar@cyphar.com> wrote:
> > On 2026-04-13, Alexey Gladkov <legion@kernel.org> wrote:
> > > When procfs is mounted with the subset=pid option, all system files and
> > > directories from the root of the filesystem are not accessible in
> > > userspace. Only dynamic information about processes is available, which
> > > cannot be hidden with overmount.
> > > 
> > > For this reason, checking for full visibility is not relevant if mounting
> > > is performed with the subset=pid option.
> > > 
> > > Signed-off-by: Alexey Gladkov <legion@kernel.org>
> > > ---
> > 
> > > -static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags)
> > > +static bool mount_too_revealing(struct fs_context *fc, int *new_mnt_flags)
> > >  {
> > >  	const unsigned long required_iflags = SB_I_NOEXEC | SB_I_NODEV;
> > >  	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
> > > +	const struct super_block *sb = fc->root->d_sb;
> > >  	unsigned long s_iflags;
> > >  
> > >  	if (ns->user_ns == &init_user_ns)
> > > @@ -6388,7 +6387,7 @@ static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags
> > >  		return true;
> > >  	}
> > >  
> > > -	return !mnt_already_visible(ns, sb, new_mnt_flags);
> > > +	return (!fc->skip_visibility && !mnt_already_visible(ns, sb, new_mnt_flags));
> > >  }
> > 
> > Unless I'm missing something (I haven't tested this locally yet, sorry),
> > this will allow you to bypass mount_too_revealing() even for
> > non-subset=pid mounts because once you create a subset=pid mount then a
> > regular procfs mount will see the subset=pid mount and permit it.
> > 
> > I think the solution is quite simple -- you can also skip super-blocks
> > that have fc->skip_visibility set in mnt_already_visible().
> 
> I now see that check was present in v8 but I guess its importance wasn't
> obvious. I guess this means we will need to reintroduce
> SB_I_USERNS_ALLOW_REVEALING. :/

I've been playing with something else. So first we should move
SB_I_USERNS_REVEALING to an fs_type flag. It's not an optional thing and
always set and never removed. That also means we can simplify
sysfs_get_tree() to just kernfs_get_tree().

And then we raise SB_I_USERNS_RESTRICTED on all procfs mounts with
pid_only and disallow using them for calculating mount permissions for
unrestricted procfs mounts.

Aleksa?

--nfsjwfyis4t5hlj3
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment;
	filename="0001-FOLD-Don-t-allow-to-abuse-restricted-procfs-mounts-t.patch"

From 1041e9c62d74ffd03c7bfc748cc952714ab51f01 Mon Sep 17 00:00:00 2001
From: Christian Brauner <brauner@kernel.org>
Date: Thu, 16 Apr 2026 15:22:15 +0200
Subject: [PATCH] [FOLD]: Don't allow to abuse restricted procfs mounts to
 mount unrestricted ones

Signed-off-by: Christian Brauner <brauner@kernel.org>
---
 fs/namespace.c                 | 11 ++++++++++-
 fs/proc/root.c                 |  5 ++++-
 include/linux/fs/super_types.h |  1 +
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 7b171a67dd50..099ce44e46b5 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -6351,10 +6351,19 @@ static bool mnt_already_visible(struct mnt_namespace *ns,
 
 	guard(namespace_shared)();
 	hlist_for_each_entry(mnt, &ns->mnt_visible_mounts, mnt_ns_visible) {
+		const struct super_block *sb_visible = mnt->mnt.mnt_sb;
 		struct mount *child;
 		int mnt_flags;
 
-		if (mnt->mnt.mnt_sb->s_type != sb->s_type)
+		if (sb_visible->s_type != sb->s_type)
+			continue;
+
+		/*
+		 * If the new superblock is not going to be restricted then any
+		 * mount that is restricted cannot be used to allow it.
+		 */
+		if (!(sb->s_iflags & SB_I_USERNS_RESTRICTED) &&
+		    (sb_visible->s_iflags & SB_I_USERNS_RESTRICTED))
 			continue;
 
 		/* A local view of the mount flags */
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 350fc4f888ab..a035467b465b 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -267,8 +267,11 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 	 * The dynamic part of procfs cannot be hidden using overmount.
 	 * Therefore, the check for "not fully visible" can be skipped.
 	 */
-	if (fs_info->pidonly)
+	if (fs_info->pidonly) {
 		fc->skip_visibility = true;
+		/* Indicate that this procfs instance hides a bunch of files. */
+		s->s_iflags |= SB_I_USERNS_RESTRICTED;
+	}
 
 	/* User space would break if executables or devices appear on proc */
 	s->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
diff --git a/include/linux/fs/super_types.h b/include/linux/fs/super_types.h
index 182efbeb9520..4ae7d0c3d55b 100644
--- a/include/linux/fs/super_types.h
+++ b/include/linux/fs/super_types.h
@@ -326,6 +326,7 @@ struct super_block {
 #define SB_I_STABLE_WRITES 0x00000008	/* don't modify blks until WB is done */
 
 /* sb->s_iflags to limit user namespace mounts */
+#define SB_I_USERNS_RESTRICTED		0x00000010
 #define SB_I_IMA_UNVERIFIABLE_SIGNATURE	0x00000020
 #define SB_I_UNTRUSTED_MOUNTER		0x00000040
 #define SB_I_EVM_HMAC_UNSUPPORTED	0x00000080
-- 
2.47.3


--nfsjwfyis4t5hlj3
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment;
	filename="0001-fs-move-SB_I_USERNS_VISIBLE-to-FS_USERNS_MOUNT_RESTR.patch"

From bcb9e887619cbf5f2cd0a6a80b299e3a5fc2692a Mon Sep 17 00:00:00 2001
From: Christian Brauner <brauner@kernel.org>
Date: Thu, 16 Apr 2026 15:04:31 +0200
Subject: [PATCH 1/2] fs: move SB_I_USERNS_VISIBLE to
 FS_USERNS_MOUNT_RESTRICTED

Whether a filesystem's mounts need to undergo a visibility check in user
namespaces is a static property of the filesystem type, not a runtime
property of each superblock instance. Both proc and sysfs always set
SB_I_USERNS_VISIBLE on their superblocks unconditionally (sysfs does so
on first creation, and subsequent mounts reuse the same superblock).

Move this flag from sb->s_iflags (SB_I_USERNS_VISIBLE) to
file_system_type->fs_flags (FS_USERNS_MOUNT_RESTRICTED) so the intent
is expressed at the filesystem type level where it belongs.

All check sites are updated to test sb->s_type->fs_flags instead of
sb->s_iflags. The SB_I_NOEXEC and SB_I_NODEV flags remain on the
superblock as they are runtime properties set during fill_super.

Signed-off-by: Christian Brauner <brauner@kernel.org>
---
 fs/namespace.c                 | 4 ++--
 fs/proc/root.c                 | 4 ++--
 fs/sysfs/mount.c               | 4 +---
 include/linux/fs.h             | 1 +
 include/linux/fs/super_types.h | 1 -
 kernel/acct.c                  | 2 +-
 6 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index fe919abd2f01..a60ddfe71c7a 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -6405,10 +6405,10 @@ static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags
 		return false;
 
 	/* Can this filesystem be too revealing? */
-	s_iflags = sb->s_iflags;
-	if (!(s_iflags & SB_I_USERNS_VISIBLE))
+	if (!(sb->s_type->fs_flags & FS_USERNS_MOUNT_RESTRICTED))
 		return false;
 
+	s_iflags = sb->s_iflags;
 	if ((s_iflags & required_iflags) != required_iflags) {
 		WARN_ONCE(1, "Expected s_iflags to contain 0x%lx\n",
 			  required_iflags);
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 0f9100559471..b65053f9f046 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -257,7 +257,7 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
 	proc_apply_options(fs_info, fc, current_user_ns());
 
 	/* User space would break if executables or devices appear on proc */
-	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;
+	s->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
 	s->s_flags |= SB_NODIRATIME | SB_NOSUID | SB_NOEXEC;
 	s->s_blocksize = 1024;
 	s->s_blocksize_bits = 10;
@@ -359,7 +359,7 @@ static struct file_system_type proc_fs_type = {
 	.init_fs_context	= proc_init_fs_context,
 	.parameters		= proc_fs_parameters,
 	.kill_sb		= proc_kill_sb,
-	.fs_flags		= FS_USERNS_MOUNT | FS_DISALLOW_NOTIFY_PERM,
+	.fs_flags		= FS_USERNS_MOUNT | FS_USERNS_MOUNT_RESTRICTED | FS_DISALLOW_NOTIFY_PERM,
 };
 
 void __init proc_root_init(void)
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index b199e8ff79b1..b45ea5d511e7 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -32,8 +32,6 @@ static int sysfs_get_tree(struct fs_context *fc)
 	if (ret)
 		return ret;
 
-	if (kfc->new_sb_created)
-		fc->root->d_sb->s_iflags |= SB_I_USERNS_VISIBLE;
 	return 0;
 }
 
@@ -93,7 +91,7 @@ static struct file_system_type sysfs_fs_type = {
 	.name			= "sysfs",
 	.init_fs_context	= sysfs_init_fs_context,
 	.kill_sb		= sysfs_kill_sb,
-	.fs_flags		= FS_USERNS_MOUNT,
+	.fs_flags		= FS_USERNS_MOUNT | FS_USERNS_MOUNT_RESTRICTED,
 };
 
 int __init sysfs_init(void)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b5b01bb22d12..17a6baefb7d3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2280,6 +2280,7 @@ struct file_system_type {
 #define FS_MGTIME		64	/* FS uses multigrain timestamps */
 #define FS_LBS			128	/* FS supports LBS */
 #define FS_POWER_FREEZE		256	/* Always freeze on suspend/hibernate */
+#define FS_USERNS_MOUNT_RESTRICTED 512	/* Restrict mount in userns if not already visible */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
 	int (*init_fs_context)(struct fs_context *);
 	const struct fs_parameter_spec *parameters;
diff --git a/include/linux/fs/super_types.h b/include/linux/fs/super_types.h
index 383050e7fdf5..182efbeb9520 100644
--- a/include/linux/fs/super_types.h
+++ b/include/linux/fs/super_types.h
@@ -326,7 +326,6 @@ struct super_block {
 #define SB_I_STABLE_WRITES 0x00000008	/* don't modify blks until WB is done */
 
 /* sb->s_iflags to limit user namespace mounts */
-#define SB_I_USERNS_VISIBLE		0x00000010 /* fstype already mounted */
 #define SB_I_IMA_UNVERIFIABLE_SIGNATURE	0x00000020
 #define SB_I_UNTRUSTED_MOUNTER		0x00000040
 #define SB_I_EVM_HMAC_UNSUPPORTED	0x00000080
diff --git a/kernel/acct.c b/kernel/acct.c
index cbbf79d718cf..c440d43479ca 100644
--- a/kernel/acct.c
+++ b/kernel/acct.c
@@ -249,7 +249,7 @@ static int acct_on(const char __user *name)
 		return -EINVAL;
 
 	/* Exclude procfs and sysfs. */
-	if (file_inode(file)->i_sb->s_iflags & SB_I_USERNS_VISIBLE)
+	if (file_inode(file)->i_sb->s_type->fs_flags & FS_USERNS_MOUNT_RESTRICTED)
 		return -EINVAL;
 
 	if (!(file->f_mode & FMODE_CAN_WRITE))
-- 
2.47.3


--nfsjwfyis4t5hlj3
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment;
	filename="0002-sysfs-remove-trivial-sysfs_get_tree-wrapper.patch"

From b43adcafc42753065739a22a053417d43694d9ac Mon Sep 17 00:00:00 2001
From: Christian Brauner <brauner@kernel.org>
Date: Thu, 16 Apr 2026 15:04:47 +0200
Subject: [PATCH 2/2] sysfs: remove trivial sysfs_get_tree() wrapper

Now that FS_USERNS_MOUNT_RESTRICTED is a file_system_type flag,
sysfs_get_tree() is a trivial wrapper around kernfs_get_tree() with no
additional logic. Point sysfs_fs_context_ops.get_tree directly at
kernfs_get_tree() and remove the wrapper.

Signed-off-by: Christian Brauner <brauner@kernel.org>
---
 fs/sysfs/mount.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index b45ea5d511e7..88c10823fcaf 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -23,18 +23,6 @@
 static struct kernfs_root *sysfs_root;
 struct kernfs_node *sysfs_root_kn;
 
-static int sysfs_get_tree(struct fs_context *fc)
-{
-	struct kernfs_fs_context *kfc = fc->fs_private;
-	int ret;
-
-	ret = kernfs_get_tree(fc);
-	if (ret)
-		return ret;
-
-	return 0;
-}
-
 static void sysfs_fs_context_free(struct fs_context *fc)
 {
 	struct kernfs_fs_context *kfc = fc->fs_private;
@@ -47,7 +35,7 @@ static void sysfs_fs_context_free(struct fs_context *fc)
 
 static const struct fs_context_operations sysfs_fs_context_ops = {
 	.free		= sysfs_fs_context_free,
-	.get_tree	= sysfs_get_tree,
+	.get_tree	= kernfs_get_tree,
 };
 
 static int sysfs_init_fs_context(struct fs_context *fc)
-- 
2.47.3


--nfsjwfyis4t5hlj3--
