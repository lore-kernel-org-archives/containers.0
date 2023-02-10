Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 659F8624
	for <containers@lists.linux.dev>; Fri, 10 Feb 2023 00:39:22 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 89A88C433D2;
	Fri, 10 Feb 2023 00:39:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1675989562;
	bh=hvCkR1t/J0Mibwje1+vHzGzwiD5E4DAShPqq+y0oXz4=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=t7IsNPRCpzmKYAxcxeb/bxM5uLLpWOCLDx00vj+qX1dBPE2+H//GKuyx6LJLvqm6n
	 tr7gKVb1Rlwx7tiO1WOuOTioD+Yc3gnsUlsrJpJO4GW96JDs6BzUBlnBwpNvBgaang
	 QIE73tuptViDmCJvmd/FUCnkGER8XmwMrdtdWKKm/KTWTW1dKwlkuHhvbZ12JHCRXE
	 C1bWcw3KMXCvQPcDXuVojttF5WWOOdI1jvSBsBNjXf0NRn4zR4SqULLbQnwWvG9OL7
	 LK3LBt3EUZgzywyQCF/T1BsYHd+PjIZviuBZDvvga0Fn1/W3he0R2GFnejmIjZWahs
	 0+xxxzf7A8VUQ==
Date: Fri, 10 Feb 2023 02:39:19 +0200
From: Jarkko Sakkinen <jarkko@kernel.org>
To: Stefan Berger <stefanb@linux.ibm.com>
Cc: linux-integrity@vger.kernel.org, zohar@linux.ibm.com, serge@hallyn.com,
	brauner@kernel.org, containers@lists.linux.dev,
	dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
	krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
	mpeters@redhat.com, lhinds@redhat.com, lsturman@redhat.com,
	puiterwi@redhat.com, jejb@linux.ibm.com, jamjoom@us.ibm.com,
	linux-kernel@vger.kernel.org, paul@paul-moore.com, rgb@redhat.com,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	jpenumak@redhat.com, John Johansen <john.johansen@canonical.com>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Micah Morton <mortonm@chromium.org>,
	Kentaro Takeda <takedakn@nttdata.co.jp>
Subject: Re: [PATCH v15 01/26] securityfs: rework dentry creation
Message-ID: <Y+WSDX/zxRpxzqLP@kernel.org>
References: <20230206140253.3755945-1-stefanb@linux.ibm.com>
 <20230206140253.3755945-2-stefanb@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20230206140253.3755945-2-stefanb@linux.ibm.com>

On Mon, Feb 06, 2023 at 09:02:28AM -0500, Stefan Berger wrote:
> From: Christian Brauner <brauner@kernel.org>
> 
> When securityfs creates a new file or directory via
> securityfs_create_dentry() it will take an additional reference on the
> newly created dentry after it has attached the new inode to the new
> dentry and added it to the hashqueues.
> If we contrast this with debugfs, which has the same underlying logic as

nit: "Constrating this with debugfs"

Passive form is better when there is no well-defined definition of "we".

> securityfs, it uses a similar pairing as securityfs. Where securityfs
> has the securityfs_create_dentry() and securityfs_remove() pairing,
> debugfs has the __debugfs_create_file() and debugfs_remove() pairing.
> 
> In contrast to securityfs, debugfs doesn't take an additional reference
> on the newly created dentry in __debugfs_create_file() which would need
> to be put in debugfs_remove().
> 
> The additional dget() isn't a problem per se. In the current
> implementation of securityfs each created dentry pins the filesystem via
> securityfs_create_dentry() until it is removed. Since it is virtually
> guaranteed that there is at least one user of securityfs that has created
> dentries the initial securityfs mount cannot go away until all dentries
> have been removed.
> 
> Since most of the users of the initial securityfs mount don't go away
> until the system is shutdown the initial securityfs won't go away when
> unmounted. Instead a mount will usually surface the same superblock as
> before. The additional dget() doesn't matter in this scenario since it
> is required that all dentries have been cleaned up by the respective
> users before the superblock can be destroyed, i.e. superblock shutdown
> is tied to the lifetime of the associated dentries.
> 
> However, in order to support ima namespaces we need to extend securityfs
> to support being mounted outside of the initial user namespace. For
> namespaced users the pinning logic doesn't make sense. Whereas in the
> initial namespace the securityfs instance and the associated data
> structures of its users can't go away for reason explained earlier users
> of non-initial securityfs instances do go away when the last users of
> the namespace are gone.

"for reason explained earlier" ?

> So for those users we neither want to duplicate the pinning logic nor
> make the global securityfs instance display different information based
> on the namespace. Both options would be really messy and hacky.
> 
> Instead we will simply give each namespace its own securityfs instance
> similar to how each ipc namespace has its own mqueue instance and all
> entries in there are cleaned up on umount or when the last user of the
> associated namespace is gone.
> 
> This means that the superblock's lifetime isn't tied to the dentries.
> Instead the last umount, without any fds kept open, will trigger a clean
> shutdown. But now the additional dget() gets in the way. Instead of
> being able to rely on the generic superblock shutdown logic we would
> need to drop the additional dentry reference during superblock shutdown
> for all associated users. That would force the use of a generic
> coordination mechanism for current and future users of securityfs which
> is unnecessary. Simply remove the additional dget() in
> securityfs_dentry_create().
> 
> In securityfs_remove() we will call dget() to take an additional
> reference on the dentry about to be removed. After simple_unlink() or
> simple_rmdir() have dropped the dentry refcount we can call d_delete()
> which will either turn the dentry into negative dentry if our earlier
> dget() is the only reference to the dentry, i.e. it has no other users,
> or remove it from the hashqueues in case there are additional users.
> 
> All of these changes should not have any effect on the userspace
> semantics of the initial securityfs mount.
> 
> Signed-off-by: Christian Brauner <brauner@kernel.org>
> Cc: John Johansen <john.johansen@canonical.com>
> Cc: Matthew Garrett <mjg59@srcf.ucam.org>
> Cc: Micah Morton <mortonm@chromium.org>
> Cc: Kentaro Takeda <takedakn@nttdata.co.jp>
> Cc: James Morris <jmorris@namei.org>
> Cc: Jarkko Sakkinen <jarkko@kernel.org>
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> Reviewed-by: Mimi Zohar <zohar@linux.ibm.com>
> Reviewed-by: Serge Hallyn <serge@hallyn.com>
> 
> ---
> v13:
>   - Slight improvements in 1st paragraph of commit message
> ---
>  security/inode.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/security/inode.c b/security/inode.c
> index 6c326939750d..13e6780c4444 100644
> --- a/security/inode.c
> +++ b/security/inode.c
> @@ -159,7 +159,6 @@ static struct dentry *securityfs_create_dentry(const char *name, umode_t mode,
>  		inode->i_fop = fops;
>  	}
>  	d_instantiate(dentry, inode);
> -	dget(dentry);
>  	inode_unlock(dir);
>  	return dentry;
>  
> @@ -302,10 +301,12 @@ void securityfs_remove(struct dentry *dentry)
>  	dir = d_inode(dentry->d_parent);
>  	inode_lock(dir);
>  	if (simple_positive(dentry)) {
> +		dget(dentry);
>  		if (d_is_dir(dentry))
>  			simple_rmdir(dir, dentry);
>  		else
>  			simple_unlink(dir, dentry);
> +		d_delete(dentry);
>  		dput(dentry);
>  	}
>  	inode_unlock(dir);
> -- 
> 2.37.3
> 

BR, Jarkko
