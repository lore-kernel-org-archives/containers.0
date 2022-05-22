Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B5987C
	for <containers@lists.linux.dev>; Sun, 22 May 2022 18:24:28 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
	id 66B1966D; Sun, 22 May 2022 13:24:26 -0500 (CDT)
Date: Sun, 22 May 2022 13:24:26 -0500
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
Subject: Re: [PATCH v12 13/26] userns: Add pointer to ima_namespace to
 user_namespace
Message-ID: <20220522182426.GA24765@mail.hallyn.com>
References: <20220420140633.753772-1-stefanb@linux.ibm.com>
 <20220420140633.753772-14-stefanb@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220420140633.753772-14-stefanb@linux.ibm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)

On Wed, Apr 20, 2022 at 10:06:20AM -0400, Stefan Berger wrote:
> Add a pointer to ima_namespace to the user_namespace and initialize
> the init_user_ns with a pointer to init_ima_ns. We need a pointer from
> the user namespace to its associated IMA namespace since IMA namespaces
> are piggybacking on user namespaces.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> Acked-by: Christian Brauner <brauner@kernel.org>
> Reviewed-by: Mimi Zohar <zohar@linux.ibm.com>
> 
> ---
> v11:
>  - Added lost A-b from Christian back
>  - Added sentence to patch description explaining why we need the pointer
> 
> v9:
>  - Deferred implementation of ima_ns_from_user_ns() to later patch
> ---
>  include/linux/ima.h            | 2 ++
>  include/linux/user_namespace.h | 4 ++++
>  kernel/user.c                  | 4 ++++
>  3 files changed, 10 insertions(+)
> 
> diff --git a/include/linux/ima.h b/include/linux/ima.h
> index 426b1744215e..fcb60a44e05f 100644
> --- a/include/linux/ima.h
> +++ b/include/linux/ima.h
> @@ -14,6 +14,8 @@
>  #include <crypto/hash_info.h>
>  struct linux_binprm;
>  
> +extern struct ima_namespace init_ima_ns;
> +
>  #ifdef CONFIG_IMA
>  extern enum hash_algo ima_get_current_hash_algo(void);
>  extern int ima_bprm_check(struct linux_binprm *bprm);
> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> index 33a4240e6a6f..019e8cf7b633 100644
> --- a/include/linux/user_namespace.h
> +++ b/include/linux/user_namespace.h
> @@ -36,6 +36,7 @@ struct uid_gid_map { /* 64 bytes -- 1 cache line */
>  #define USERNS_INIT_FLAGS USERNS_SETGROUPS_ALLOWED
>  
>  struct ucounts;
> +struct ima_namespace;
>  
>  enum ucount_type {
>  	UCOUNT_USER_NAMESPACES,
> @@ -99,6 +100,9 @@ struct user_namespace {
>  #endif
>  	struct ucounts		*ucounts;
>  	long ucount_max[UCOUNT_COUNTS];
> +#ifdef CONFIG_IMA_NS

It's probably worth putting a comment here saying that user_ns does not
pin ima_ns.

That the only time the ima_ns will be freed is when user_ns is freed,
and only time it will be changed is when user_ns is freed, or during
ima_fs_ns_init() (under smp_load_acquire) during a new mount.

> +	struct ima_namespace	*ima_ns;

So, if I create a new user_ns with a new ima_ns, and in there I
create a new user_ns again, it looks like ima_ns will be NULL in
the new user_ns?  Should it not be set to the parent->ima_ns?
(which would cause trouble for the way it's currently being
freed...)

> +#endif
>  } __randomize_layout;
>  
>  struct ucounts {
> diff --git a/kernel/user.c b/kernel/user.c
> index e2cf8c22b539..e5d1f4b9b8ba 100644
> --- a/kernel/user.c
> +++ b/kernel/user.c
> @@ -19,6 +19,7 @@
>  #include <linux/export.h>
>  #include <linux/user_namespace.h>
>  #include <linux/proc_ns.h>
> +#include <linux/ima.h>
>  
>  /*
>   * userns count is 1 for root user, 1 for init_uts_ns,
> @@ -67,6 +68,9 @@ struct user_namespace init_user_ns = {
>  	.keyring_name_list = LIST_HEAD_INIT(init_user_ns.keyring_name_list),
>  	.keyring_sem = __RWSEM_INITIALIZER(init_user_ns.keyring_sem),
>  #endif
> +#ifdef CONFIG_IMA_NS
> +	.ima_ns = &init_ima_ns,
> +#endif
>  };
>  EXPORT_SYMBOL_GPL(init_user_ns);
>  
> -- 
> 2.34.1
