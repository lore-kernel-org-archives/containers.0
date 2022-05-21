Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5822E15AB
	for <containers@lists.linux.dev>; Sat, 21 May 2022 03:24:29 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
	id 6BBDD3F4; Fri, 20 May 2022 22:24:27 -0500 (CDT)
Date: Fri, 20 May 2022 22:24:27 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Stefan Berger <stefanb@linux.ibm.com>
Cc: linux-integrity@vger.kernel.org, zohar@linux.ibm.com, serge@hallyn.com,
	christian.brauner@ubuntu.com, containers@lists.linux.dev,
	dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
	krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
	mpeters@redhat.com, lhinds@redhat.com, lsturman@redhat.com,
	puiterwi@redhat.com, jejb@linux.ibm.com, jamjoom@us.ibm.com,
	linux-kernel@vger.kernel.org, paul@paul-moore.com, rgb@redhat.com,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	jpenumak@redhat.com, Christian Brauner <brauner@kernel.org>
Subject: Re: [PATCH v12 08/26] ima: Move IMA securityfs files into
 ima_namespace or onto stack
Message-ID: <20220521032427.GG9107@mail.hallyn.com>
References: <20220420140633.753772-1-stefanb@linux.ibm.com>
 <20220420140633.753772-9-stefanb@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220420140633.753772-9-stefanb@linux.ibm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)

On Wed, Apr 20, 2022 at 10:06:15AM -0400, Stefan Berger wrote:
> Earlier we simplified how dentry creation and deletion is manged in
> securityfs. This allows us to move IMA securityfs files from global
> variables directly into ima_fs_ns_init() itself. We can now rely on
> those dentries to be cleaned up when the securityfs instance is cleaned
> when the last reference to it is dropped.
> 
> Things are slightly different for the initial IMA namespace. In contrast
> to non-initial IMA namespaces it has pinning logic binding the lifetime
> of the securityfs superblock to created dentries. We need to keep this
> behavior to not regress userspace. Since IMA never removes most of the
> securityfs files the initial securityfs instance stays pinned. This also
> means even for the initial IMA namespace we don't need to keep
> references to these dentries anywhere.
> 
> The ima_policy file is the exception since IMA can end up removing it
> on systems that don't allow reading or extending the IMA custom policy.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> Acked-by: Christian Brauner <brauner@kernel.org>
> Reviewed-by: Mimi Zohar <zohar@linux.ibm.com>

Acked-by: Serge Hallyn <serge@hallyn.com>

> 
> ---
> 
> v9:
>  - Revert renaming of ima_policy to policy_dentry
> ---
>  security/integrity/ima/ima.h    |  2 ++
>  security/integrity/ima/ima_fs.c | 37 ++++++++++++++++++---------------
>  2 files changed, 22 insertions(+), 17 deletions(-)
> 
> diff --git a/security/integrity/ima/ima.h b/security/integrity/ima/ima.h
> index a144edfdb9a1..b35c8504ef87 100644
> --- a/security/integrity/ima/ima.h
> +++ b/security/integrity/ima/ima.h
> @@ -142,6 +142,8 @@ struct ima_namespace {
>  	struct mutex ima_write_mutex;
>  	unsigned long ima_fs_flags;
>  	int valid_policy;
> +
> +	struct dentry *ima_policy;
>  } __randomize_layout;
>  extern struct ima_namespace init_ima_ns;
>  
> diff --git a/security/integrity/ima/ima_fs.c b/security/integrity/ima/ima_fs.c
> index 4cf786f0bba8..89d3113ceda1 100644
> --- a/security/integrity/ima/ima_fs.c
> +++ b/security/integrity/ima/ima_fs.c
> @@ -359,14 +359,6 @@ static ssize_t ima_write_policy(struct file *file, const char __user *buf,
>  	return result;
>  }
>  
> -static struct dentry *ima_dir;
> -static struct dentry *ima_symlink;
> -static struct dentry *binary_runtime_measurements;
> -static struct dentry *ascii_runtime_measurements;
> -static struct dentry *runtime_measurements_count;
> -static struct dentry *violations;
> -static struct dentry *ima_policy;
> -
>  enum ima_fs_flags {
>  	IMA_FS_BUSY,
>  };
> @@ -436,8 +428,8 @@ static int ima_release_policy(struct inode *inode, struct file *file)
>  
>  	ima_update_policy(ns);
>  #if !defined(CONFIG_IMA_WRITE_POLICY) && !defined(CONFIG_IMA_READ_POLICY)
> -	securityfs_remove(ima_policy);
> -	ima_policy = NULL;
> +	securityfs_remove(ns->ima_policy);
> +	ns->ima_policy = NULL;
>  #elif defined(CONFIG_IMA_WRITE_POLICY)
>  	clear_bit(IMA_FS_BUSY, &ns->ima_fs_flags);
>  #elif defined(CONFIG_IMA_READ_POLICY)
> @@ -454,8 +446,14 @@ static const struct file_operations ima_measure_policy_ops = {
>  	.llseek = generic_file_llseek,
>  };
>  
> -int __init ima_fs_init(void)
> +static int __init ima_fs_ns_init(struct ima_namespace *ns)
>  {
> +	struct dentry *ima_dir;
> +	struct dentry *ima_symlink = NULL;
> +	struct dentry *binary_runtime_measurements = NULL;
> +	struct dentry *ascii_runtime_measurements = NULL;
> +	struct dentry *runtime_measurements_count = NULL;
> +	struct dentry *violations = NULL;
>  	int ret;
>  
>  	ima_dir = securityfs_create_dir("ima", integrity_dir);
> @@ -504,17 +502,17 @@ int __init ima_fs_init(void)
>  		goto out;
>  	}
>  
> -	ima_policy = securityfs_create_file("policy", POLICY_FILE_FLAGS,
> -					    ima_dir, NULL,
> -					    &ima_measure_policy_ops);
> -	if (IS_ERR(ima_policy)) {
> -		ret = PTR_ERR(ima_policy);
> +	ns->ima_policy = securityfs_create_file("policy", POLICY_FILE_FLAGS,
> +						ima_dir, NULL,
> +						&ima_measure_policy_ops);
> +	if (IS_ERR(ns->ima_policy)) {
> +		ret = PTR_ERR(ns->ima_policy);
>  		goto out;
>  	}
>  
>  	return 0;
>  out:
> -	securityfs_remove(ima_policy);
> +	securityfs_remove(ns->ima_policy);
>  	securityfs_remove(violations);
>  	securityfs_remove(runtime_measurements_count);
>  	securityfs_remove(ascii_runtime_measurements);
> @@ -524,3 +522,8 @@ int __init ima_fs_init(void)
>  
>  	return ret;
>  }
> +
> +int __init ima_fs_init(void)
> +{
> +	return ima_fs_ns_init(&init_ima_ns);
> +}
> -- 
> 2.34.1
