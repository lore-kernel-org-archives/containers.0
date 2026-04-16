Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 135C434EEF3;
	Thu, 16 Apr 2026 12:52:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776343972; cv=none; b=a148Jh+jTPEMBGHONUia7Sz/AgotIbdTtrJjSNAd2sPp8/W0yhwXJ5uO67fYLQ9lnsguecqD5GcR316iGpkSy7q4jScRb3TLev5iL01mlhHINxr7HCukbupD+0mVUKym4NUiNi0cvv0tSUF0YS4nNk4AFM2EQJxew/iWNIpf7S4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776343972; c=relaxed/simple;
	bh=anFAn8EFkT/wM9TCCD3yXQb97tBtIGdYsMxxuy+vDeA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=BI6rAYCS2DNff5oNn3Sy/DP6LUZi2jEWg5Jcleuo5EjnOcasXHmIN3dj1w0vmqZHs7IqmhlebdnS3heF7gZ8uH58iz3V0xqilkZvAibim7rmRukPzyy/2t5ZJR0Zv3cpJDytnkwgGMB6liJhye7EOzoU42ybWJVlnXBqVgDwMSc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EF33WJGC; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EF33WJGC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 69B33C2BCAF;
	Thu, 16 Apr 2026 12:52:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776343971;
	bh=anFAn8EFkT/wM9TCCD3yXQb97tBtIGdYsMxxuy+vDeA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=EF33WJGCkxPPBQzYrimo292TvLakm6gug+mZVc+cDvCT0YEbI0FxEtq4oMgaGEQzg
	 jN4IFWr2p0PpH3Z5Wq6zKhoPOSJlgRQK7epMn9Ct69KkMXv2677rMg8fl0oaqBiWTH
	 +YqNk7pzjooj4Hs0ixBSn3T8GjdVUmYh9XnceA8GJpgh7tpuO7r2h1TlkyZ21SgUq1
	 fg4z+vkmIYmnalFaXdyt8FPJ3NFznwQ+GFBjIWuFe3Germ4vqax5CwzVR9BdT2pbuO
	 e1XI5pMZfYRBcF0rVhpHd/SWDFMY6Z6ciJ6svXHDluhYTpcO0h5DJyr/+zXpS4TtBE
	 rLecUA8TAbq8g==
Date: Thu, 16 Apr 2026 14:52:46 +0200
From: Christian Brauner <brauner@kernel.org>
To: Alexey Gladkov <legion@kernel.org>
Cc: Dan Klishch <danilklishch@gmail.com>, 
	Al Viro <viro@zeniv.linux.org.uk>, "Eric W . Biederman" <ebiederm@xmission.com>, 
	Kees Cook <keescook@chromium.org>, containers@lists.linux.dev, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v9 4/5] proc: Skip the visibility check if subset=pid is
 used
Message-ID: <20260416-nullnummer-ruhebereich-64e9495ae98f@brauner>
References: <cover.1770979341.git.legion@kernel.org>
 <cover.1776079055.git.legion@kernel.org>
 <38572c1fb7cf55b4c27dd792adafa52f1216e3a3.1776079055.git.legion@kernel.org>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <38572c1fb7cf55b4c27dd792adafa52f1216e3a3.1776079055.git.legion@kernel.org>

On Mon, Apr 13, 2026 at 01:19:43PM +0200, Alexey Gladkov wrote:
> When procfs is mounted with the subset=pid option, all system files and
> directories from the root of the filesystem are not accessible in
> userspace. Only dynamic information about processes is available, which
> cannot be hidden with overmount.
> 
> For this reason, checking for full visibility is not relevant if mounting
> is performed with the subset=pid option.
> 
> Signed-off-by: Alexey Gladkov <legion@kernel.org>
> ---
>  fs/fs_context.c            |  1 +
>  fs/namespace.c             | 15 +++++++--------
>  fs/proc/root.c             |  7 +++++++
>  include/linux/fs_context.h |  1 +
>  4 files changed, 16 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/fs_context.c b/fs/fs_context.c
> index a37b0a093505..2fd3d6422a38 100644
> --- a/fs/fs_context.c
> +++ b/fs/fs_context.c
> @@ -545,6 +545,7 @@ void vfs_clean_context(struct fs_context *fc)
>  	kfree(fc->source);
>  	fc->source = NULL;
>  	fc->exclusive = false;
> +	fc->skip_visibility = false;
>  
>  	fc->purpose = FS_CONTEXT_FOR_RECONFIGURE;
>  	fc->phase = FS_CONTEXT_AWAITING_RECONF;
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 539b74403072..32aaedb020c1 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -3755,7 +3755,7 @@ static int do_add_mount(struct mount *newmnt, const struct pinned_mountpoint *mp
>  	return graft_tree(newmnt, mp);
>  }
>  
> -static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags);
> +static bool mount_too_revealing(struct fs_context *fc, int *new_mnt_flags);
>  
>  /*
>   * Create a new mount using a superblock configuration and request it
> @@ -3764,19 +3764,17 @@ static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags
>  static int do_new_mount_fc(struct fs_context *fc, const struct path *mountpoint,
>  			   unsigned int mnt_flags)
>  {
> -	struct super_block *sb;
>  	struct vfsmount *mnt __free(mntput) = fc_mount(fc);
>  	int error;
>  
>  	if (IS_ERR(mnt))
>  		return PTR_ERR(mnt);
>  
> -	sb = fc->root->d_sb;
> -	error = security_sb_kern_mount(sb);
> +	error = security_sb_kern_mount(fc->root->d_sb);
>  	if (unlikely(error))
>  		return error;
>  
> -	if (unlikely(mount_too_revealing(sb, &mnt_flags))) {
> +	if (unlikely(mount_too_revealing(fc, &mnt_flags))) {
>  		errorfcp(fc, "VFS", "Mount too revealing");
>  		return -EPERM;
>  	}
> @@ -4463,7 +4461,7 @@ SYSCALL_DEFINE3(fsmount, int, fs_fd, unsigned int, flags,
>  		return ret;
>  
>  	ret = -EPERM;
> -	if (mount_too_revealing(fc->root->d_sb, &mnt_flags)) {
> +	if (mount_too_revealing(fc, &mnt_flags)) {
>  		errorfcp(fc, "VFS", "Mount too revealing");
>  		return ret;
>  	}
> @@ -6368,10 +6366,11 @@ static bool mnt_already_visible(struct mnt_namespace *ns,
>  	return false;
>  }
>  
> -static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags)
> +static bool mount_too_revealing(struct fs_context *fc, int *new_mnt_flags)
>  {
>  	const unsigned long required_iflags = SB_I_NOEXEC | SB_I_NODEV;
>  	struct mnt_namespace *ns = current->nsproxy->mnt_ns;
> +	const struct super_block *sb = fc->root->d_sb;
>  	unsigned long s_iflags;
>  
>  	if (ns->user_ns == &init_user_ns)
> @@ -6388,7 +6387,7 @@ static bool mount_too_revealing(const struct super_block *sb, int *new_mnt_flags
>  		return true;
>  	}
>  
> -	return !mnt_already_visible(ns, sb, new_mnt_flags);
> +	return (!fc->skip_visibility && !mnt_already_visible(ns, sb, new_mnt_flags));
>  }
>  
>  bool mnt_may_suid(struct vfsmount *mnt)
> diff --git a/fs/proc/root.c b/fs/proc/root.c
> index 05558654df31..6dc870b3061b 100644
> --- a/fs/proc/root.c
> +++ b/fs/proc/root.c
> @@ -263,6 +263,13 @@ static int proc_fill_super(struct super_block *s, struct fs_context *fc)
>  	if (ret)
>  		return ret;
>  
> +	/*
> +	 * The dynamic part of procfs cannot be hidden using overmount.
> +	 * Therefore, the check for "not fully visible" can be skipped.
> +	 */
> +	if (fs_info->pidonly)
> +		fc->skip_visibility = true;
> +
>  	/* User space would break if executables or devices appear on proc */
>  	s->s_iflags |= SB_I_USERNS_VISIBLE | SB_I_NOEXEC | SB_I_NODEV;

I think we should move the SB_I_USERNS_VISIBLE check to the fs_type. It
really is something that applies to the filesystem type and isn't a
per-superblock thing. Then we can raise SB_I_USERNS_VISIBLE only on
superblocks that are restricted via pid_only and discount those when
deciding to allow procfs mount without pid_only. Something that Aleksa
had pointed out on an earlier review. Let ms see if I can write that up.
