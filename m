Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D0B329CA
	for <containers@lists.linux.dev>; Sat, 11 Dec 2021 10:50:35 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9E0B5C004DD;
	Sat, 11 Dec 2021 10:50:29 +0000 (UTC)
Date: Sat, 11 Dec 2021 11:50:26 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Stefan Berger <stefanb@linux.ibm.com>
Cc: linux-integrity@vger.kernel.org, zohar@linux.ibm.com, serge@hallyn.com,
	containers@lists.linux.dev, dmitry.kasatkin@gmail.com,
	ebiederm@xmission.com, krzysztof.struczynski@huawei.com,
	roberto.sassu@huawei.com, mpeters@redhat.com, lhinds@redhat.com,
	lsturman@redhat.com, puiterwi@redhat.com, jejb@linux.ibm.com,
	jamjoom@us.ibm.com, linux-kernel@vger.kernel.org,
	paul@paul-moore.com, rgb@redhat.com,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [PATCH v6 12/17] securityfs: Extend securityfs with namespacing
 support
Message-ID: <20211211105026.pq5stw23gh5na3eq@wittgenstein>
References: <20211210194736.1538863-1-stefanb@linux.ibm.com>
 <20211210194736.1538863-13-stefanb@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20211210194736.1538863-13-stefanb@linux.ibm.com>

On Fri, Dec 10, 2021 at 02:47:31PM -0500, Stefan Berger wrote:
> Extend 'securityfs' for support of IMA namespacing so that each
> IMA (user) namespace can have its own front-end for showing the currently
> active policy, the measurement list, number of violations and so on.
> 
> Drop the addition dentry reference and simplify cleanup to work without
> the additional reference. This enables simple cleanup of dentries upon
> umount.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> Signed-off-by: James Bottomley <James.Bottomley@HansenPartnership.com>
> ---
>  security/inode.c | 14 ++++----------
>  1 file changed, 4 insertions(+), 10 deletions(-)
> 
> diff --git a/security/inode.c b/security/inode.c
> index fee01ff4d831..c77ae8ecc464 100644
> --- a/security/inode.c
> +++ b/security/inode.c
> @@ -54,7 +54,7 @@ static int securityfs_fill_super(struct super_block *sb, struct fs_context *fc)
>  
>  static int securityfs_get_tree(struct fs_context *fc)
>  {
> -	return get_tree_single(fc, securityfs_fill_super);
> +	return get_tree_keyed(fc, securityfs_fill_super, fc->user_ns);
>  }
>  
>  static const struct fs_context_operations securityfs_context_ops = {
> @@ -72,6 +72,7 @@ static struct file_system_type fs_type = {
>  	.name =		"securityfs",
>  	.init_fs_context = securityfs_init_fs_context,
>  	.kill_sb =	kill_litter_super,
> +	.fs_flags =	FS_USERNS_MOUNT,
>  };
>  
>  /**
> @@ -168,7 +169,6 @@ static struct dentry *securityfs_create_dentry(const char *name, umode_t mode,
>  		inode->i_fop = fops;
>  	}
>  	d_instantiate(dentry, inode);
> -	dget(dentry);
>  	inode_unlock(dir);
>  	return dentry;
>  
> @@ -306,23 +306,17 @@ EXPORT_SYMBOL_GPL(securityfs_create_symlink);
>  void securityfs_remove(struct dentry *dentry)
>  {
>  	struct user_namespace *ns;
> -	struct inode *dir;
>  
>  	if (!dentry || IS_ERR(dentry))
>  		return;
>  
>  	ns = dentry->d_sb->s_user_ns;
>  
> -	dir = d_inode(dentry->d_parent);
> -	inode_lock(dir);
>  	if (simple_positive(dentry)) {
> -		if (d_is_dir(dentry))
> -			simple_rmdir(dir, dentry);
> -		else
> -			simple_unlink(dir, dentry);
> +		d_delete(dentry);
>  		dput(dentry);

In
https://lore.kernel.org/lkml/20211210114934.tacjnwryihrsx6ln@wittgenstein
I explained why d_delete()+d_put() only is wrong and how to fix it.
