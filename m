From: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Subject: Re: [PATCH v4 01/11] user_ns: 3 new LSM hooks for user namespace
	operations
Date: Thu, 29 Oct 2015 15:49:09 -0700
Message-ID: <5632A265.7020402__29575.1582285904$1446158973$gmane$org@schaufler-ca.com>
References: <1444826525-9758-1-git-send-email-l.pawelczyk@samsung.com>
	<1444826525-9758-2-git-send-email-l.pawelczyk@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1444826525-9758-2-git-send-email-l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Calvin Owens <calvinowens-b10kYP2dOMg@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, John Johansen <john.johansen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Mauro Carvalho Chehab <mchehab-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>Serge
Cc: Lukasz Pawelczyk <havner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 10/14/2015 5:41 AM, Lukasz Pawelczyk wrote:
> This commit implements 3 new LSM hooks that provide the means for LSMs
> to embed their own security context within user namespace, effectively
> creating some sort of a user_ns related security namespace.
>
> The first one to take advantage of this mechanism is Smack.
>
> The hooks has been documented in the in the security.h below.
>
> Signed-off-by: Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> Reviewed-by: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
> Acked-by: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>

Acked-by: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>

> ---
>  include/linux/lsm_hooks.h      | 28 ++++++++++++++++++++++++++++
>  include/linux/security.h       | 23 +++++++++++++++++++++++
>  include/linux/user_namespace.h |  4 ++++
>  kernel/user.c                  |  3 +++
>  kernel/user_namespace.c        | 18 ++++++++++++++++++
>  security/security.c            | 28 ++++++++++++++++++++++++++++
>  6 files changed, 104 insertions(+)
>
> diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
> index ec3a6ba..18c9160 100644
> --- a/include/linux/lsm_hooks.h
> +++ b/include/linux/lsm_hooks.h
> @@ -1261,6 +1261,23 @@
>   *	audit_rule_init.
>   *	@rule contains the allocated rule
>   *
> + * @userns_create:
> + *	Allocates and fills the security part of a new user namespace.
> + *	@ns points to a newly created user namespace.
> + *	Returns 0 or an error code.
> + *
> + * @userns_free:
> + *	Deallocates the security part of a user namespace.
> + *	@ns points to a user namespace about to be destroyed.
> + *
> + * @userns_setns:
> + *	Run during a setns syscall to add a process to an already existing
> + *	user namespace. Returning failure here will block the operation
> + *	requested from userspace (setns() with CLONE_NEWUSER).
> + *	@nsproxy contains nsproxy to which the user namespace will be assigned.
> + *	@ns contains user namespace that is to be incorporated to the nsproxy.
> + *	Returns 0 or an error code.
> + *
>   * @inode_notifysecctx:
>   *	Notify the security module of what the security context of an inode
>   *	should be.  Initializes the incore security context managed by the
> @@ -1613,6 +1630,12 @@ union security_list_options {
>  				struct audit_context *actx);
>  	void (*audit_rule_free)(void *lsmrule);
>  #endif /* CONFIG_AUDIT */
> +
> +#ifdef CONFIG_USER_NS
> +	int (*userns_create)(struct user_namespace *ns);
> +	void (*userns_free)(struct user_namespace *ns);
> +	int (*userns_setns)(struct nsproxy *nsproxy, struct user_namespace *ns);
> +#endif /* CONFIG_USER_NS */
>  };
>  
>  struct security_hook_heads {
> @@ -1824,6 +1847,11 @@ struct security_hook_heads {
>  	struct list_head audit_rule_match;
>  	struct list_head audit_rule_free;
>  #endif /* CONFIG_AUDIT */
> +#ifdef CONFIG_USER_NS
> +	struct list_head userns_create;
> +	struct list_head userns_free;
> +	struct list_head userns_setns;
> +#endif /* CONFIG_USER_NS */
>  };
>  
>  /*
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 2f4c1f7..91ffba2 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -1584,6 +1584,29 @@ static inline void security_audit_rule_free(void *lsmrule)
>  #endif /* CONFIG_SECURITY */
>  #endif /* CONFIG_AUDIT */
>  
> +#ifdef CONFIG_USER_NS
> +int security_userns_create(struct user_namespace *ns);
> +void security_userns_free(struct user_namespace *ns);
> +int security_userns_setns(struct nsproxy *nsproxy, struct user_namespace *ns);
> +
> +#else
> +
> +static inline int security_userns_create(struct user_namespace *ns)
> +{
> +	return 0;
> +}
> +
> +static inline void security_userns_free(struct user_namespace *ns)
> +{ }
> +
> +static inline int security_userns_setns(struct nsproxy *nsproxy,
> +					struct user_namespace *ns)
> +{
> +	return 0;
> +}
> +
> +#endif /* CONFIG_USER_NS */
> +
>  #ifdef CONFIG_SECURITYFS
>  
>  extern struct dentry *securityfs_create_file(const char *name, umode_t mode,
> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> index 8297e5b..a9400cc 100644
> --- a/include/linux/user_namespace.h
> +++ b/include/linux/user_namespace.h
> @@ -39,6 +39,10 @@ struct user_namespace {
>  	struct key		*persistent_keyring_register;
>  	struct rw_semaphore	persistent_keyring_register_sem;
>  #endif
> +
> +#ifdef CONFIG_SECURITY
> +	void *security;
> +#endif
>  };
>  
>  extern struct user_namespace init_user_ns;
> diff --git a/kernel/user.c b/kernel/user.c
> index b069ccb..ce5419e 100644
> --- a/kernel/user.c
> +++ b/kernel/user.c
> @@ -59,6 +59,9 @@ struct user_namespace init_user_ns = {
>  	.persistent_keyring_register_sem =
>  	__RWSEM_INITIALIZER(init_user_ns.persistent_keyring_register_sem),
>  #endif
> +#ifdef CONFIG_SECURITY
> +	.security = NULL,
> +#endif
>  };
>  EXPORT_SYMBOL_GPL(init_user_ns);
>  
> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> index 88fefa6..daef188 100644
> --- a/kernel/user_namespace.c
> +++ b/kernel/user_namespace.c
> @@ -22,6 +22,7 @@
>  #include <linux/ctype.h>
>  #include <linux/projid.h>
>  #include <linux/fs_struct.h>
> +#include <linux/security.h>
>  
>  static struct kmem_cache *user_ns_cachep __read_mostly;
>  static DEFINE_MUTEX(userns_state_mutex);
> @@ -109,6 +110,15 @@ int create_user_ns(struct cred *new)
>  
>  	set_cred_user_ns(new, ns);
>  
> +#ifdef CONFIG_SECURITY
> +	ret = security_userns_create(ns);
> +	if (ret) {
> +		ns_free_inum(&ns->ns);
> +		kmem_cache_free(user_ns_cachep, ns);
> +		return ret;
> +	}
> +#endif
> +
>  #ifdef CONFIG_PERSISTENT_KEYRINGS
>  	init_rwsem(&ns->persistent_keyring_register_sem);
>  #endif
> @@ -144,6 +154,9 @@ void free_user_ns(struct user_namespace *ns)
>  #ifdef CONFIG_PERSISTENT_KEYRINGS
>  		key_put(ns->persistent_keyring_register);
>  #endif
> +#ifdef CONFIG_SECURITY
> +		security_userns_free(ns);
> +#endif
>  		ns_free_inum(&ns->ns);
>  		kmem_cache_free(user_ns_cachep, ns);
>  		ns = parent;
> @@ -970,6 +983,7 @@ static int userns_install(struct nsproxy *nsproxy, struct ns_common *ns)
>  {
>  	struct user_namespace *user_ns = to_user_ns(ns);
>  	struct cred *cred;
> +	int err;
>  
>  	/* Don't allow gaining capabilities by reentering
>  	 * the same user namespace.
> @@ -987,6 +1001,10 @@ static int userns_install(struct nsproxy *nsproxy, struct ns_common *ns)
>  	if (!ns_capable(user_ns, CAP_SYS_ADMIN))
>  		return -EPERM;
>  
> +	err = security_userns_setns(nsproxy, user_ns);
> +	if (err)
> +		return err;
> +
>  	cred = prepare_creds();
>  	if (!cred)
>  		return -ENOMEM;
> diff --git a/security/security.c b/security/security.c
> index 46f405c..e571127 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -25,6 +25,7 @@
>  #include <linux/mount.h>
>  #include <linux/personality.h>
>  #include <linux/backing-dev.h>
> +#include <linux/user_namespace.h>
>  #include <net/flow.h>
>  
>  #define MAX_LSM_EVM_XATTR	2
> @@ -1538,6 +1539,25 @@ int security_audit_rule_match(u32 secid, u32 field, u32 op, void *lsmrule,
>  }
>  #endif /* CONFIG_AUDIT */
>  
> +#ifdef CONFIG_USER_NS
> +
> +int security_userns_create(struct user_namespace *ns)
> +{
> +	return call_int_hook(userns_create, 0, ns);
> +}
> +
> +void security_userns_free(struct user_namespace *ns)
> +{
> +	call_void_hook(userns_free, ns);
> +}
> +
> +int security_userns_setns(struct nsproxy *nsproxy, struct user_namespace *ns)
> +{
> +	return call_int_hook(userns_setns, 0, nsproxy, ns);
> +}
> +
> +#endif /* CONFIG_USER_NS */
> +
>  struct security_hook_heads security_hook_heads = {
>  	.binder_set_context_mgr =
>  		LIST_HEAD_INIT(security_hook_heads.binder_set_context_mgr),
> @@ -1882,4 +1902,12 @@ struct security_hook_heads security_hook_heads = {
>  	.audit_rule_free =
>  		LIST_HEAD_INIT(security_hook_heads.audit_rule_free),
>  #endif /* CONFIG_AUDIT */
> +#ifdef CONFIG_USER_NS
> +	.userns_create =
> +		LIST_HEAD_INIT(security_hook_heads.userns_create),
> +	.userns_free =
> +		LIST_HEAD_INIT(security_hook_heads.userns_free),
> +	.userns_setns =
> +		LIST_HEAD_INIT(security_hook_heads.userns_setns),
> +#endif /* CONFIG_USER_NS */
>  };
