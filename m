Return-Path: <SRS0=ByLK=H7=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,INCLUDES_CR_TRAILER,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DF05C4151A
	for <containers@archiver.kernel.org>; Mon,  1 Mar 2021 20:05:29 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 09B3564E76
	for <containers@archiver.kernel.org>; Mon,  1 Mar 2021 20:05:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09B3564E76
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by smtp2.osuosl.org (Postfix) with ESMTP id C358D430FD;
	Mon,  1 Mar 2021 20:05:28 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
	by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id lz3d5tHNY5S5; Mon,  1 Mar 2021 20:05:27 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by smtp2.osuosl.org (Postfix) with ESMTP id CC26E430BD;
	Mon,  1 Mar 2021 20:05:26 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id A7287C000A;
	Mon,  1 Mar 2021 20:05:26 +0000 (UTC)
Received: from smtp2.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 54093C0001
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 20:05:25 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by smtp2.osuosl.org (Postfix) with ESMTP id 2D60D430BD
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 20:05:25 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from smtp2.osuosl.org ([127.0.0.1])
 by localhost (smtp2.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id GpzpsVS8nmeQ
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 20:05:23 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.8.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
 by smtp2.osuosl.org (Postfix) with ESMTPS id 0A22643110
 for <containers@lists.linux-foundation.org>;
 Mon,  1 Mar 2021 20:05:21 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 4A83664E59;
 Mon,  1 Mar 2021 20:05:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
 s=k20201202; t=1614629121;
 bh=hyAhv1/q6cvQCTlV6LYpy1xT3/YK4Jj5FMw0D/k0sEg=;
 h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
 b=YCfprNeYAGQFm//11dcqGFIpsCdoGMupTNydtxQa1WN9clJ1rA+3dp0VuqTSX58PL
 nBGK7FXl3eQsqG34JyfsDJrssFDfLoguVhVNuHwzm8vf1l+tbiLVaPzvT2OtDTo3Md
 zpkzsCkyKGmaOkG9bLY6KnWE6D2UWU3s5JAU+/Z8QouVx8ndlhyZgpsJQc/Bno7Qg0
 SXZmn86k1ujjNKg4BXLCA1l8h2hZlErA4bzmtb0b5lgKXgiqZBHzqgziBKathvbrJD
 BZ0NL51ktZ6PKWx7v00GbV0GQ+FObkCcDkeNyrzji77DpNXJNDAE/WxTydpBfSMKqy
 dfNT2JCJKUg+w==
Date: Mon, 1 Mar 2021 12:05:20 -0800
From: "Darrick J. Wong" <djwong@kernel.org>
To: Christian Brauner <christian.brauner@ubuntu.com>
Subject: Re: [PATCH v6 39/40] xfs: support idmapped mounts
Message-ID: <20210301200520.GK7272@magnolia>
References: <20210121131959.646623-1-christian.brauner@ubuntu.com>
 <20210121131959.646623-40-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <20210121131959.646623-40-christian.brauner@ubuntu.com>
Cc: Lennart Poettering <lennart@poettering.net>,
 Mimi Zohar <zohar@linux.ibm.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andreas Dilger <adilger.kernel@dilger.ca>,
 containers@lists.linux-foundation.org, Christoph Hellwig <hch@lst.de>,
 Tycho Andersen <tycho@tycho.ws>, Paul Moore <paul@paul-moore.com>,
 Jonathan Corbet <corbet@lwn.net>, smbarber@chromium.org,
 Alban Crequy <alban@kinvolk.io>, linux-ext4@vger.kernel.org,
 Mrunal Patel <mpatel@redhat.com>, Kees Cook <keescook@chromium.org>,
 Arnd Bergmann <arnd@arndb.de>, selinux@vger.kernel.org,
 Josh Triplett <josh@joshtriplett.org>,
 Seth Forshee <seth.forshee@canonical.com>, Aleksa Sarai <cyphar@cyphar.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>,
 OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
 Geoffrey Thomas <geofft@ldpreload.com>, David Howells <dhowells@redhat.com>,
 John Johansen <john.johansen@canonical.com>, Theodore Tso <tytso@mit.edu>,
 Dmitry Kasatkin <dmitry.kasatkin@gmail.com>,
 Stephen Smalley <stephen.smalley.work@gmail.com>, linux-xfs@vger.kernel.org,
 linux-security-module@vger.kernel.org,
 "Eric W. Biederman" <ebiederm@xmission.com>, linux-api@vger.kernel.org,
 Casey Schaufler <casey@schaufler-ca.com>, linux-fsdevel@vger.kernel.org,
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

On Thu, Jan 21, 2021 at 02:19:58PM +0100, Christian Brauner wrote:
> From: Christoph Hellwig <hch@lst.de>
> 
> Enable idmapped mounts for xfs. This basically just means passing down
> the user_namespace argument from the VFS methods down to where it is
> passed to the relevant helpers.
> 
> Note that full-filesystem bulkstat is not supported from inside idmapped
> mounts as it is an administrative operation that acts on the whole file
> system. The limitation is not applied to the bulkstat single operation
> that just operates on a single inode.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
> ---
> /* v2 */
> 
> /* v3 */
> 
> /* v4 */
> 
> /* v5 */
> base-commit: 7c53f6b671f4aba70ff15e1b05148b10d58c2837
> 
> /* v6 */
> unchanged
> base-commit: 19c329f6808995b142b3966301f217c831e7cf31
> ---
>  fs/xfs/xfs_acl.c     |  3 +--
>  fs/xfs/xfs_file.c    |  4 +++-
>  fs/xfs/xfs_inode.c   | 26 +++++++++++++++--------
>  fs/xfs/xfs_inode.h   | 16 +++++++++------
>  fs/xfs/xfs_ioctl.c   | 35 ++++++++++++++++++-------------
>  fs/xfs/xfs_ioctl32.c |  6 ++++--
>  fs/xfs/xfs_iops.c    | 49 +++++++++++++++++++++++++-------------------
>  fs/xfs/xfs_iops.h    |  3 ++-
>  fs/xfs/xfs_itable.c  | 17 +++++++++++----
>  fs/xfs/xfs_itable.h  |  1 +
>  fs/xfs/xfs_qm.c      |  3 ++-
>  fs/xfs/xfs_super.c   |  2 +-
>  fs/xfs/xfs_symlink.c |  5 +++--
>  fs/xfs/xfs_symlink.h |  5 +++--
>  14 files changed, 110 insertions(+), 65 deletions(-)

<snip> Sorry for not noticing until after this went upstream, but...

> diff --git a/fs/xfs/xfs_itable.c b/fs/xfs/xfs_itable.c
> index 16ca97a7ff00..ca310a125d1e 100644
> --- a/fs/xfs/xfs_itable.c
> +++ b/fs/xfs/xfs_itable.c
> @@ -54,10 +54,12 @@ struct xfs_bstat_chunk {
>  STATIC int
>  xfs_bulkstat_one_int(
>  	struct xfs_mount	*mp,
> +	struct user_namespace	*mnt_userns,
>  	struct xfs_trans	*tp,
>  	xfs_ino_t		ino,
>  	struct xfs_bstat_chunk	*bc)
>  {
> +	struct user_namespace	*sb_userns = mp->m_super->s_user_ns;
>  	struct xfs_icdinode	*dic;		/* dinode core info pointer */
>  	struct xfs_inode	*ip;		/* incore inode pointer */
>  	struct inode		*inode;
> @@ -86,8 +88,8 @@ xfs_bulkstat_one_int(
>  	 */
>  	buf->bs_projectid = ip->i_d.di_projid;
>  	buf->bs_ino = ino;
> -	buf->bs_uid = i_uid_read(inode);
> -	buf->bs_gid = i_gid_read(inode);
> +	buf->bs_uid = from_kuid(sb_userns, i_uid_into_mnt(mnt_userns, inode));
> +	buf->bs_gid = from_kgid(sb_userns, i_gid_into_mnt(mnt_userns, inode));
>  	buf->bs_size = dic->di_size;
>  
>  	buf->bs_nlink = inode->i_nlink;
> @@ -173,7 +175,8 @@ xfs_bulkstat_one(
>  	if (!bc.buf)
>  		return -ENOMEM;
>  
> -	error = xfs_bulkstat_one_int(breq->mp, NULL, breq->startino, &bc);
> +	error = xfs_bulkstat_one_int(breq->mp, breq->mnt_userns, NULL,
> +				     breq->startino, &bc);
>  
>  	kmem_free(bc.buf);
>  
> @@ -194,9 +197,10 @@ xfs_bulkstat_iwalk(
>  	xfs_ino_t		ino,
>  	void			*data)
>  {
> +	struct xfs_bstat_chunk	*bc = data;
>  	int			error;
>  
> -	error = xfs_bulkstat_one_int(mp, tp, ino, data);
> +	error = xfs_bulkstat_one_int(mp, bc->breq->mnt_userns, tp, ino, data);
>  	/* bulkstat just skips over missing inodes */
>  	if (error == -ENOENT || error == -EINVAL)
>  		return 0;
> @@ -239,6 +243,11 @@ xfs_bulkstat(
>  	};
>  	int			error;
>  
> +	if (breq->mnt_userns != &init_user_ns) {
> +		xfs_warn_ratelimited(breq->mp,
> +			"bulkstat not supported inside of idmapped mounts.");
> +		return -EINVAL;

Shouldn't this be -EPERM?

Or -EOPNOTSUPP?

Also, I'm not sure why bulkstat won't work in an idmapped mount but
bulkstat_single does?  You can use the singleton version to stat inodes
that aren't inside the submount.

--D

> +	}
>  	if (xfs_bulkstat_already_done(breq->mp, breq->startino))
>  		return 0;
>  
> diff --git a/fs/xfs/xfs_itable.h b/fs/xfs/xfs_itable.h
> index 96a1e2a9be3f..7078d10c9b12 100644
> --- a/fs/xfs/xfs_itable.h
> +++ b/fs/xfs/xfs_itable.h
> @@ -8,6 +8,7 @@
>  /* In-memory representation of a userspace request for batch inode data. */
>  struct xfs_ibulk {
>  	struct xfs_mount	*mp;
> +	struct user_namespace   *mnt_userns;
>  	void __user		*ubuffer; /* user output buffer */
>  	xfs_ino_t		startino; /* start with this inode */
>  	unsigned int		icount;   /* number of elements in ubuffer */
> diff --git a/fs/xfs/xfs_qm.c b/fs/xfs/xfs_qm.c
> index c134eb4aeaa8..1b7b1393cab2 100644
> --- a/fs/xfs/xfs_qm.c
> +++ b/fs/xfs/xfs_qm.c
> @@ -787,7 +787,8 @@ xfs_qm_qino_alloc(
>  		return error;
>  
>  	if (need_alloc) {
> -		error = xfs_dir_ialloc(&tp, NULL, S_IFREG, 1, 0, 0, ipp);
> +		error = xfs_dir_ialloc(&init_user_ns, &tp, NULL, S_IFREG, 1, 0,
> +				       0, ipp);
>  		if (error) {
>  			xfs_trans_cancel(tp);
>  			return error;
> diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
> index 813be879a5e5..e95c1eff95e0 100644
> --- a/fs/xfs/xfs_super.c
> +++ b/fs/xfs/xfs_super.c
> @@ -1912,7 +1912,7 @@ static struct file_system_type xfs_fs_type = {
>  	.init_fs_context	= xfs_init_fs_context,
>  	.parameters		= xfs_fs_parameters,
>  	.kill_sb		= kill_block_super,
> -	.fs_flags		= FS_REQUIRES_DEV,
> +	.fs_flags		= FS_REQUIRES_DEV | FS_ALLOW_IDMAP,
>  };
>  MODULE_ALIAS_FS("xfs");
>  
> diff --git a/fs/xfs/xfs_symlink.c b/fs/xfs/xfs_symlink.c
> index 1f43fd7f3209..77c8ea3229f1 100644
> --- a/fs/xfs/xfs_symlink.c
> +++ b/fs/xfs/xfs_symlink.c
> @@ -134,6 +134,7 @@ xfs_readlink(
>  
>  int
>  xfs_symlink(
> +	struct user_namespace	*mnt_userns,
>  	struct xfs_inode	*dp,
>  	struct xfs_name		*link_name,
>  	const char		*target_path,
> @@ -223,8 +224,8 @@ xfs_symlink(
>  	/*
>  	 * Allocate an inode for the symlink.
>  	 */
> -	error = xfs_dir_ialloc(&tp, dp, S_IFLNK | (mode & ~S_IFMT), 1, 0,
> -			       prid, &ip);
> +	error = xfs_dir_ialloc(mnt_userns, &tp, dp, S_IFLNK | (mode & ~S_IFMT),
> +			       1, 0, prid, &ip);
>  	if (error)
>  		goto out_trans_cancel;
>  
> diff --git a/fs/xfs/xfs_symlink.h b/fs/xfs/xfs_symlink.h
> index b1fa091427e6..2586b7e393f3 100644
> --- a/fs/xfs/xfs_symlink.h
> +++ b/fs/xfs/xfs_symlink.h
> @@ -7,8 +7,9 @@
>  
>  /* Kernel only symlink definitions */
>  
> -int xfs_symlink(struct xfs_inode *dp, struct xfs_name *link_name,
> -		const char *target_path, umode_t mode, struct xfs_inode **ipp);
> +int xfs_symlink(struct user_namespace *mnt_userns, struct xfs_inode *dp,
> +		struct xfs_name *link_name, const char *target_path,
> +		umode_t mode, struct xfs_inode **ipp);
>  int xfs_readlink_bmap_ilocked(struct xfs_inode *ip, char *link);
>  int xfs_readlink(struct xfs_inode *ip, char *link);
>  int xfs_inactive_symlink(struct xfs_inode *ip);
> -- 
> 2.30.0
> 
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
