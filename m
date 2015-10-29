From: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Subject: Re: [PATCH v4 09/11] smack: namespace groundwork
Date: Thu, 29 Oct 2015 15:51:55 -0700
Message-ID: <5632A30B.9030703__5892.95379254526$1446159141$gmane$org@schaufler-ca.com>
References: <1444826525-9758-1-git-send-email-l.pawelczyk@samsung.com>
	<1444826525-9758-10-git-send-email-l.pawelczyk@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1444826525-9758-10-git-send-email-l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
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

On 10/14/2015 5:42 AM, Lukasz Pawelczyk wrote:
> This commit introduces several changes to Smack to prepare it for
> namespace implementation. All the changes are related to namespaces.
>
> Overview of the changes:
> - Adds required data structures for mapped labels and functions to
>   operate on them.
> - Implements the proc interface /proc/$PID/attr/label_map that can be
>   used for remapping of labels for a specific namespace. Also for
>   checking the map.
> - Modifies handling of special built-in labels. Detects them on import
>   and assigns the same char* pointer regardless whether it's used in a
>   normal or a mapped label. This way we can always compare them by ==
>   instead of strcmp().
> - Adds User namespace hooks implementation
>
> This patch introduces both internal and user-space visible APIs to
> handle namespaced labels and Smack namespaces but the behaviour of Smack
> should not be changed. The APIs are there, but they have no impact yet.
>
> Signed-off-by: Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> Reviewed-by: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>

Acked-by: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>


> ---
>  security/smack/Kconfig        |  10 ++
>  security/smack/Makefile       |   1 +
>  security/smack/smack.h        |  45 ++++-
>  security/smack/smack_access.c |  47 ++++-
>  security/smack/smack_lsm.c    | 134 +++++++++++++-
>  security/smack/smack_ns.c     | 404 ++++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 626 insertions(+), 15 deletions(-)
>  create mode 100644 security/smack/smack_ns.c
>
> diff --git a/security/smack/Kconfig b/security/smack/Kconfig
> index 271adae..b19a7fb 100644
> --- a/security/smack/Kconfig
> +++ b/security/smack/Kconfig
> @@ -40,3 +40,13 @@ config SECURITY_SMACK_NETFILTER
>  	  This enables security marking of network packets using
>  	  Smack labels.
>  	  If you are unsure how to answer this question, answer N.
> +
> +config SECURITY_SMACK_NS
> +	bool "Smack namespace"
> +	depends on SECURITY_SMACK
> +	depends on USER_NS
> +	help
> +	  This enables Smack namespace that makes it possible to map
> +	  specific labels within user namespace (analogously to mapping
> +	  UIDs) and to gain MAC capabilities over them.
> +	  If you are unsure how to answer this question, answer N.
> diff --git a/security/smack/Makefile b/security/smack/Makefile
> index ee2ebd5..5faebd7 100644
> --- a/security/smack/Makefile
> +++ b/security/smack/Makefile
> @@ -6,3 +6,4 @@ obj-$(CONFIG_SECURITY_SMACK) := smack.o
>  
>  smack-y := smack_lsm.o smack_access.o smackfs.o
>  smack-$(CONFIG_SECURITY_SMACK_NETFILTER) += smack_netfilter.o
> +smack-$(CONFIG_SECURITY_SMACK_NS) += smack_ns.o
> diff --git a/security/smack/smack.h b/security/smack/smack.h
> index 98bb676..4b7489f 100644
> --- a/security/smack/smack.h
> +++ b/security/smack/smack.h
> @@ -24,6 +24,7 @@
>  #include <linux/list.h>
>  #include <linux/rculist.h>
>  #include <linux/lsm_audit.h>
> +#include <linux/user_namespace.h>
>  
>  /*
>   * Use IPv6 port labeling if IPv6 is enabled and secmarks
> @@ -74,8 +75,36 @@ struct smack_known {
>  	struct netlbl_lsm_secattr	smk_netlabel;	/* on wire labels */
>  	struct list_head		smk_rules;	/* access rules */
>  	struct mutex			smk_rules_lock;	/* lock for rules */
> +#ifdef CONFIG_SECURITY_SMACK_NS
> +	struct list_head		smk_mapped;	/* namespaced labels */
> +	struct mutex			smk_mapped_lock;
> +#endif /* CONFIG_SECURITY_SMACK_NS */
>  };
>  
> +#ifdef CONFIG_SECURITY_SMACK_NS
> +
> +/*
> + * User namespace security pointer content.
> + */
> +struct smack_ns {
> +	struct list_head		smk_mapped;	/* namespaced labels */
> +	struct mutex			smk_mapped_lock;
> +};
> +
> +/*
> + * A single entry for a namespaced/mapped label.
> + */
> +struct smack_known_ns {
> +	struct list_head	smk_list_known;
> +	struct list_head	smk_list_ns;
> +	struct user_namespace	*smk_ns;
> +	char			*smk_mapped;
> +	struct smack_known	*smk_unmapped;
> +	bool			smk_allocated;
> +};
> +
> +#endif /* CONFIG_SECURITY_SMACK_NS */
> +
>  /*
>   * Maximum number of bytes for the levels in a CIPSO IP option.
>   * Why 23? CIPSO is constrained to 30, so a 32 byte buffer is
> @@ -295,7 +324,7 @@ int smk_tskacc(struct task_struct *, struct smack_known *,
>  	       u32, struct smk_audit_info *);
>  int smk_curacc(struct smack_known *, u32, struct smk_audit_info *);
>  struct smack_known *smack_from_secid(const u32);
> -char *smk_parse_smack(const char *string, int len);
> +char *smk_parse_smack(const char *string, int len, bool *allocated);
>  int smk_netlbl_mls(int, char *, struct netlbl_lsm_secattr *, int);
>  struct smack_known *smk_import_entry(const char *, int);
>  void smk_insert_entry(struct smack_known *skp);
> @@ -310,6 +339,20 @@ char *smk_find_label_name(struct smack_known *skp);
>  struct smack_known *smk_get_label(const char *string, int len, bool import);
>  
>  /*
> + * These functions are in smack_ns.c
> + */
> +#ifdef CONFIG_SECURITY_SMACK_NS
> +struct user_namespace *smk_find_mapped_ns(struct user_namespace *ns);
> +struct smack_known_ns *smk_find_mapped(struct smack_known *skp,
> +				       struct user_namespace *ns);
> +struct smack_known *smk_find_unmapped(const char *string, int len,
> +				      struct user_namespace *ns);
> +extern const struct seq_operations proc_label_map_seq_operations;
> +ssize_t proc_label_map_write(struct task_struct *p, const struct cred *f_cred,
> +			     void *value, size_t size);
> +#endif /* CONFIG_SECURITY_SMACK_NS */
> +
> +/*
>   * Shared data.
>   */
>  extern int smack_enabled;
> diff --git a/security/smack/smack_access.c b/security/smack/smack_access.c
> index 750aa9c..17b7e2c 100644
> --- a/security/smack/smack_access.c
> +++ b/security/smack/smack_access.c
> @@ -452,13 +452,16 @@ struct smack_known *smk_find_entry(const char *string)
>  /**
>   * smk_parse_smack - parse smack label from a text string
>   * @string: a text string that might contain a Smack label
> - * @len: the maximum size, or zero if it is NULL terminated.
> + * @len: the maximum size, or zero if it is NULL terminated
> + * @allocated: (out) indicates whether the return string has been
> + *             allocated and has to be freed with kfree() later
> + *             (built-in labels returned are not allocated)
>   *
>   * Returns a pointer to the clean label or an error code.
>   */
> -char *smk_parse_smack(const char *string, int len)
> +char *smk_parse_smack(const char *string, int len, bool *allocated)
>  {
> -	char *smack;
> +	char *smack = NULL;
>  	int i;
>  
>  	if (len <= 0)
> @@ -480,11 +483,33 @@ char *smk_parse_smack(const char *string, int len)
>  	if (i == 0 || i >= SMK_LONGLABEL)
>  		return ERR_PTR(-EINVAL);
>  
> +	/*
> +	 * Look for special labels. This way we guarantee that we can compare
> +	 * special labels in mapped entries by ==, without strcmp().
> +	 */
> +	if (len == 1 && !strcmp(string, smack_known_huh.smk_known))
> +		smack = smack_known_huh.smk_known;
> +	else if (len == 1 && !strcmp(string, smack_known_hat.smk_known))
> +		smack = smack_known_hat.smk_known;
> +	else if (len == 1 && !strcmp(string, smack_known_star.smk_known))
> +		smack = smack_known_star.smk_known;
> +	else if (len == 1 && !strcmp(string, smack_known_floor.smk_known))
> +		smack = smack_known_floor.smk_known;
> +	else if (len == 1 && !strcmp(string, smack_known_web.smk_known))
> +		smack = smack_known_web.smk_known;
> +
> +	if (smack) {
> +		*allocated = false;
> +
> +		return smack;
> +	}
> +
>  	smack = kzalloc(i + 1, GFP_KERNEL);
>  	if (smack == NULL)
>  		return ERR_PTR(-ENOMEM);
>  
>  	strncpy(smack, string, i);
> +	*allocated = true;
>  
>  	return smack;
>  }
> @@ -540,8 +565,9 @@ struct smack_known *smk_import_entry(const char *string, int len)
>  	char *smack;
>  	int slen;
>  	int rc;
> +	bool allocated;
>  
> -	smack = smk_parse_smack(string, len);
> +	smack = smk_parse_smack(string, len, &allocated);
>  	if (IS_ERR(smack))
>  		return ERR_CAST(smack);
>  
> @@ -577,6 +603,10 @@ struct smack_known *smk_import_entry(const char *string, int len)
>  	if (rc >= 0) {
>  		INIT_LIST_HEAD(&skp->smk_rules);
>  		mutex_init(&skp->smk_rules_lock);
> +#ifdef CONFIG_SECURITY_SMACK_NS
> +		INIT_LIST_HEAD(&skp->smk_mapped);
> +		mutex_init(&skp->smk_mapped_lock);
> +#endif /* CONFIG_SECURITY_SMACK_NS */
>  		/*
>  		 * Make sure that the entry is actually
>  		 * filled before putting it on the list.
> @@ -590,7 +620,8 @@ struct smack_known *smk_import_entry(const char *string, int len)
>  	kfree(skp);
>  	skp = ERR_PTR(rc);
>  freeout:
> -	kfree(smack);
> +	if (allocated)
> +		kfree(smack);
>  unlockout:
>  	mutex_unlock(&smack_known_lock);
>  
> @@ -748,17 +779,19 @@ char *smk_find_label_name(struct smack_known *skp)
>  struct smack_known *smk_get_label(const char *string, int len, bool import)
>  {
>  	struct smack_known *skp;
> +	bool allocated;
>  	char *cp;
>  
>  	if (import) {
>  		skp = smk_import_entry(string, len);
>  	} else {
> -		cp = smk_parse_smack(string, len);
> +		cp = smk_parse_smack(string, len, &allocated);
>  		if (IS_ERR(cp))
>  			return ERR_CAST(cp);
>  
>  		skp = smk_find_entry(cp);
> -		kfree(cp);
> +		if (allocated)
> +			kfree(cp);
>  	}
>  
>  	return skp;
> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index 5a59836..206e0ce 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -42,6 +42,7 @@
>  #include <linux/shm.h>
>  #include <linux/binfmts.h>
>  #include <linux/parser.h>
> +#include <linux/user_namespace.h>
>  #include "smack.h"
>  
>  #define TRANS_TRUE	"TRUE"
> @@ -3496,6 +3497,27 @@ unlockandout:
>  }
>  
>  /**
> + * smack_getprocattr_seq - Smack process attribute access through seq
> + * @p: the object task
> + * @name: the name of the attribute in /proc/.../attr/
> + * @ops: out, seq_operations to handle @name
> + *
> + * Returns 0 if @name is to be handled by seq, error otherwise.
> + */
> +int smack_getprocattr_seq(struct task_struct *p, const char *name,
> +			  const struct seq_operations **ops)
> +{
> +#ifdef CONFIG_SECURITY_SMACK_NS
> +	if (strcmp(name, "label_map") == 0) {
> +		*ops = &proc_label_map_seq_operations;
> +		return 0;
> +	}
> +#endif
> +
> +	return -EOPNOTSUPP;
> +}
> +
> +/**
>   * smack_getprocattr - Smack process attribute access
>   * @p: the object task
>   * @name: the name of the attribute in /proc/.../attr
> @@ -3527,9 +3549,8 @@ static int smack_getprocattr(struct task_struct *p, char *name, char **value)
>  }
>  
>  /**
> - * smack_setprocattr - Smack process attribute setting
> + * proc_current_write - Smack "current" process attribute setting
>   * @p: the object task
> - * @name: the name of the attribute in /proc/.../attr
>   * @value: the value to set
>   * @size: the size of the value
>   *
> @@ -3538,8 +3559,7 @@ static int smack_getprocattr(struct task_struct *p, char *name, char **value)
>   *
>   * Returns the length of the smack label or an error code
>   */
> -static int smack_setprocattr(struct task_struct *p, const struct cred *f_cred,
> -			     char *name, void *value, size_t size)
> +static int proc_current_write(struct task_struct *p, void *value, size_t size)
>  {
>  	struct task_smack *tsp;
>  	struct cred *new;
> @@ -3558,9 +3578,6 @@ static int smack_setprocattr(struct task_struct *p, const struct cred *f_cred,
>  	if (value == NULL || size == 0 || size >= SMK_LONGLABEL)
>  		return -EINVAL;
>  
> -	if (strcmp(name, "current") != 0)
> -		return -EINVAL;
> -
>  	skp = smk_get_label(value, size, true);
>  	if (IS_ERR(skp))
>  		return PTR_ERR(skp);
> @@ -3583,6 +3600,33 @@ static int smack_setprocattr(struct task_struct *p, const struct cred *f_cred,
>  }
>  
>  /**
> + * smack_setprocattr - Smack process attribute setting
> + * @p: the object task
> + * @cred: the credentials of the file's opener
> + * @name: the name of the attribute in /proc/.../attr
> + * @value: the value to set
> + * @size: the size of the value
> + *
> + * Sets the proc attribute
> + *
> + * Returns the length of the written data or an error code
> + */
> +static int smack_setprocattr(struct task_struct *p, const struct cred *f_cred,
> +			     char *name, void *value, size_t size)
> +{
> +#ifdef CONFIG_SECURITY_SMACK_NS
> +	if (strcmp(name, "label_map") == 0)
> +		return proc_label_map_write(p, f_cred, value, size);
> +#endif
> +
> +	if (strcmp(name, "current") == 0)
> +		return proc_current_write(p, value, size);
> +
> +	return -EINVAL;
> +
> +}
> +
> +/**
>   * smack_unix_stream_connect - Smack access on UDS
>   * @sock: one sock
>   * @other: the other sock
> @@ -4434,6 +4478,53 @@ static void smack_audit_rule_free(void *vrule)
>  
>  #endif /* CONFIG_AUDIT */
>  
> +#ifdef CONFIG_SECURITY_SMACK_NS
> +
> +static inline int smack_userns_create(struct user_namespace *ns)
> +{
> +	struct smack_ns *snsp;
> +
> +	snsp = kzalloc(sizeof(*snsp), GFP_KERNEL);
> +	if (snsp == NULL)
> +		return -ENOMEM;
> +
> +	INIT_LIST_HEAD(&snsp->smk_mapped);
> +	mutex_init(&snsp->smk_mapped_lock);
> +
> +	ns->security = snsp;
> +	return 0;
> +}
> +
> +static inline void smack_userns_free(struct user_namespace *ns)
> +{
> +	struct smack_ns *snsp = ns->security;
> +	struct smack_known *skp;
> +	struct smack_known_ns *sknp, *n;
> +
> +	list_for_each_entry_safe(sknp, n, &snsp->smk_mapped, smk_list_ns) {
> +		skp = sknp->smk_unmapped;
> +
> +		mutex_lock(&skp->smk_mapped_lock);
> +		list_del_rcu(&sknp->smk_list_known);
> +		if (sknp->smk_allocated)
> +			kfree(sknp->smk_mapped);
> +		kfree(sknp);
> +		mutex_unlock(&skp->smk_mapped_lock);
> +
> +		list_del(&sknp->smk_list_ns);
> +	}
> +
> +	kfree(snsp);
> +}
> +
> +static inline int smack_userns_setns(struct nsproxy *nsproxy,
> +				     struct user_namespace *ns)
> +{
> +	return 0;
> +}
> +
> +#endif /* CONFIG_SECURITY_SMACK_NS */
> +
>  /**
>   * smack_ismaclabel - check if xattr @name references a smack MAC label
>   * @name: Full xattr name to check.
> @@ -4610,6 +4701,7 @@ static struct security_hook_list smack_hooks[] = {
>  
>  	LSM_HOOK_INIT(d_instantiate, smack_d_instantiate),
>  
> +	LSM_HOOK_INIT(getprocattr_seq, smack_getprocattr_seq),
>  	LSM_HOOK_INIT(getprocattr, smack_getprocattr),
>  	LSM_HOOK_INIT(setprocattr, smack_setprocattr),
>  
> @@ -4647,6 +4739,13 @@ static struct security_hook_list smack_hooks[] = {
>  	LSM_HOOK_INIT(audit_rule_free, smack_audit_rule_free),
>  #endif /* CONFIG_AUDIT */
>  
> + /* Namespace hooks */
> +#ifdef CONFIG_SECURITY_SMACK_NS
> +	LSM_HOOK_INIT(userns_create, smack_userns_create),
> +	LSM_HOOK_INIT(userns_free, smack_userns_free),
> +	LSM_HOOK_INIT(userns_setns, smack_userns_setns),
> +#endif /* CONFIG_SECURITY_SMACK_NS */
> +
>  	LSM_HOOK_INIT(ismaclabel, smack_ismaclabel),
>  	LSM_HOOK_INIT(secid_to_secctx, smack_secid_to_secctx),
>  	LSM_HOOK_INIT(secctx_to_secid, smack_secctx_to_secid),
> @@ -4659,6 +4758,27 @@ static struct security_hook_list smack_hooks[] = {
>  
>  static __init void init_smack_known_list(void)
>  {
> +#ifdef CONFIG_SECURITY_SMACK_NS
> +	/*
> +	 * Initialize mapped list locks
> +	 */
> +	mutex_init(&smack_known_huh.smk_mapped_lock);
> +	mutex_init(&smack_known_hat.smk_mapped_lock);
> +	mutex_init(&smack_known_floor.smk_mapped_lock);
> +	mutex_init(&smack_known_star.smk_mapped_lock);
> +	mutex_init(&smack_known_invalid.smk_mapped_lock);
> +	mutex_init(&smack_known_web.smk_mapped_lock);
> +	/*
> +	 * Initialize mapped lists
> +	 */
> +	INIT_LIST_HEAD(&smack_known_huh.smk_mapped);
> +	INIT_LIST_HEAD(&smack_known_hat.smk_mapped);
> +	INIT_LIST_HEAD(&smack_known_star.smk_mapped);
> +	INIT_LIST_HEAD(&smack_known_floor.smk_mapped);
> +	INIT_LIST_HEAD(&smack_known_invalid.smk_mapped);
> +	INIT_LIST_HEAD(&smack_known_web.smk_mapped);
> +#endif /* CONFIG_SECURITY_SMACK_NS */
> +
>  	/*
>  	 * Initialize rule list locks
>  	 */
> diff --git a/security/smack/smack_ns.c b/security/smack/smack_ns.c
> new file mode 100644
> index 0000000..49223c4
> --- /dev/null
> +++ b/security/smack/smack_ns.c
> @@ -0,0 +1,404 @@
> +/*
> + * Copyright (C) 2014 Samsung Electronics.
> + *
> + * Smack namespaces
> + *
> + * Author(s):
> + *    Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> + *
> + * This program is free software, you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +
> +#include <linux/file.h>
> +#include <linux/ctype.h>
> +#include <linux/rculist.h>
> +#include <linux/seq_file.h>
> +#include <linux/user_namespace.h>
> +#include "smack.h"
> +
> +/**
> + * smk_find_mapped_ns - Finds a first namespace from this one through
> + * its parrents that has a map. This map is the effective map in this
> + * namespace.
> + * @ns: a user namespace for which we search for a mapped ns
> + *
> + * Returns a namespace that has a non-NULL map, or NULL if there is
> + * no mapped namespace.
> + *
> + * Can be effectively used to answer a question: "is there a Smack
> + * map for this namespace?"
> + */
> +struct user_namespace *smk_find_mapped_ns(struct user_namespace *ns)
> +{
> +	struct user_namespace *user_ns = ns;
> +
> +	do {
> +		struct smack_ns *sns = user_ns->security;
> +
> +		if (sns && !list_empty(&sns->smk_mapped))
> +			break;
> +
> +		user_ns = user_ns->parent;
> +	} while (user_ns);
> +
> +	return user_ns;
> +}
> +
> +/**
> + * __smk_find_mapped - an internal version of smk_find_mapped
> + *                     that doesn't use smk_find_mapped_ns, but
> + *                     operates directly on the passed one.
> + */
> +static struct smack_known_ns *__smk_find_mapped(struct smack_known *skp,
> +						struct user_namespace *ns)
> +{
> +	struct smack_known_ns *sknp;
> +
> +	if (ns == NULL)
> +		return NULL;
> +
> +	list_for_each_entry_rcu(sknp, &skp->smk_mapped, smk_list_known)
> +		if (sknp->smk_ns == ns)
> +			return sknp;
> +
> +	return NULL;
> +}
> +
> +/**
> + * smk_find_mapped - Finds a mapped label on the smack_known's mapped list
> + * @skp: a label which mapped label we look for
> + * @ns: a user namespace the label we search for is assigned to
> + *
> + * Returns a pointer to the mapped label if one exists that is
> + * assigned to the specified user namespace or NULL if not found.
> + */
> +struct smack_known_ns *smk_find_mapped(struct smack_known *skp,
> +				       struct user_namespace *ns)
> +{
> +	struct user_namespace *user_ns = smk_find_mapped_ns(ns);
> +
> +	return __smk_find_mapped(skp, user_ns);
> +}
> +
> +/**
> + * __smk_find_unmapped - an internal version of smk_find_unmapped
> + *                       that doesn't use smk_find_mapped_ns, but
> + *                       operates directly on the passed one.
> + */
> +static struct smack_known *__smk_find_unmapped(const char *string, int len,
> +					       struct user_namespace *ns)
> +{
> +	struct smack_ns *snsp;
> +	struct smack_known *skp = NULL;
> +	struct smack_known_ns *sknp;
> +	char *smack;
> +	bool allocated = false;
> +
> +	if (ns == NULL)
> +		return NULL;
> +
> +	snsp = ns->security;
> +
> +	smack = smk_parse_smack(string, len, &allocated);
> +	if (IS_ERR(smack))
> +		return ERR_CAST(smack);
> +
> +	list_for_each_entry_rcu(sknp, &snsp->smk_mapped, smk_list_ns) {
> +		if (strcmp(smack, sknp->smk_mapped) == 0) {
> +			skp = sknp->smk_unmapped;
> +			break;
> +		}
> +	}
> +
> +	if (allocated)
> +		kfree(smack);
> +	return skp;
> +}
> +
> +/**
> + * smk_find_unmapped - Finds an original label by a mapped label string
> + *                     and the namespace it could be mapped in
> + * @string: a name of a mapped label we look for
> + * @len: the string size, or zero if it is NULL terminated.
> + * @ns: a namespace the looked for label should be mapped in
> + *
> + * Returns a smack_known label that is mapped as 'string' in 'ns',
> + * NULL if not found or an error code.
> + */
> +struct smack_known *smk_find_unmapped(const char *string, int len,
> +				      struct user_namespace *ns)
> +{
> +	struct user_namespace *user_ns = smk_find_mapped_ns(ns);
> +
> +	return __smk_find_unmapped(string, len, user_ns);
> +}
> +
> +/**
> + * smk_import_mapped - Imports a mapped label effectively creating a mapping.
> + * @skp: a label we map
> + * @ns: a user namespace this label will be mapped in
> + * @string: a text string of the mapped label
> + * @len: the maximum size, or zero if it is NULL terminanted
> + *
> + * Returns a pointer to the mapped label entry or an error code.
> + *
> + * The mapped label will be added to 2 lists:
> + *   - a list of mapped labels of skp
> + *   - a list of labels mapped in ns
> + */
> +static struct smack_known_ns *smk_import_mapped(struct smack_known *skp,
> +						struct user_namespace *ns,
> +						const char *string, int len)
> +{
> +	struct smack_ns *snsp = ns->security;
> +	struct smack_known_ns *sknp;
> +	char *mapped;
> +	bool allocated;
> +
> +	/* Mapping init_user_ns is against the design and pointless */
> +	if (ns == &init_user_ns)
> +		return ERR_PTR(-EBADR);
> +
> +	mapped = smk_parse_smack(string, len, &allocated);
> +	if (IS_ERR(mapped))
> +		return ERR_CAST(mapped);
> +
> +	mutex_lock(&skp->smk_mapped_lock);
> +
> +	/*
> +	 * Don't allow one<->many mappings in namespace, rename.
> +	 * This code won't get triggered for now as trying to assign
> +	 * a duplicate is forbidden in proc_label_map_write().
> +	 * Leaving this as this function might be also used elsewhere.
> +	 */
> +	sknp = smk_find_mapped(skp, ns);
> +	if (sknp != NULL) {
> +		if (sknp->smk_allocated)
> +			kfree(sknp->smk_mapped);
> +		sknp->smk_mapped = mapped;
> +		sknp->smk_allocated = allocated;
> +		goto unlockout;
> +	}
> +
> +	sknp = kzalloc(sizeof(*sknp), GFP_KERNEL);
> +	if (sknp == NULL) {
> +		sknp = ERR_PTR(-ENOMEM);
> +		if (allocated)
> +			kfree(mapped);
> +		goto unlockout;
> +	}
> +
> +	sknp->smk_ns = ns;
> +	sknp->smk_mapped = mapped;
> +	sknp->smk_allocated = allocated;
> +	sknp->smk_unmapped = skp;
> +	list_add_rcu(&sknp->smk_list_known, &skp->smk_mapped);
> +
> +	mutex_lock(&snsp->smk_mapped_lock);
> +	list_add_rcu(&sknp->smk_list_ns, &snsp->smk_mapped);
> +	mutex_unlock(&snsp->smk_mapped_lock);
> +
> +unlockout:
> +	mutex_unlock(&skp->smk_mapped_lock);
> +
> +	return sknp;
> +}
> +
> +static void *proc_label_map_seq_start(struct seq_file *seq, loff_t *pos)
> +{
> +	struct smack_known *skp;
> +	struct task_struct *task = seq->private;
> +	struct user_namespace *ns = ns_of_task_struct(task);
> +	loff_t counter = *pos;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(skp, &smack_known_list, list)
> +		if (smk_find_mapped(skp, ns) && counter-- == 0)
> +			return skp;
> +
> +	return NULL;
> +}
> +
> +static void proc_label_map_seq_stop(struct seq_file *seq, void *v)
> +{
> +	rcu_read_unlock();
> +}
> +
> +static void *proc_label_map_seq_next(struct seq_file *seq, void *v, loff_t *pos)
> +{
> +	struct smack_known *skp = v;
> +	struct task_struct *task = seq->private;
> +	struct user_namespace *ns = ns_of_task_struct(task);
> +
> +	list_for_each_entry_continue_rcu(skp, &smack_known_list, list) {
> +		if (smk_find_mapped(skp, ns)) {
> +			(*pos)++;
> +			return skp;
> +		}
> +	}
> +
> +	return NULL;
> +}
> +
> +static int proc_label_map_seq_show(struct seq_file *seq, void *v)
> +{
> +	struct smack_known *skp = v;
> +	struct task_struct *task = seq->private;
> +	struct user_namespace *ns = ns_of_task_struct(task);
> +	struct smack_known_ns *sknp;
> +
> +	sknp = smk_find_mapped(skp, ns);
> +	if (sknp)
> +		seq_printf(seq, "%s -> %s\n", skp->smk_known, sknp->smk_mapped);
> +
> +	return 0;
> +}
> +
> +const struct seq_operations proc_label_map_seq_operations = {
> +	.start = proc_label_map_seq_start,
> +	.stop = proc_label_map_seq_stop,
> +	.next = proc_label_map_seq_next,
> +	.show = proc_label_map_seq_show,
> +};
> +
> +static DEFINE_MUTEX(smk_map_mutex);
> +
> +static bool mapping_permitted(const struct cred *f_cred,
> +			      struct user_namespace *user_ns)
> +{
> +	/*
> +	 * Do not allow mapping own label. This is in contrast to user
> +	 * namespace where you can always map your own UID. In Smack having
> +	 * administrative privileges over your own label (which Smack
> +	 * namespace would effectively give you) is not equivalent to user
> +	 * namespace. E.g. things like setting exec/transmute labels that
> +	 * otherwise would be denied. Hence no own_label param here.
> +	 */
> +
> +	/*
> +	 * Adjusting namespace settings requires capabilities on the target.
> +	 */
> +	if (security_capable(f_cred, user_ns, CAP_MAC_ADMIN) != 0)
> +		return false;
> +
> +	/*
> +	 * And it requires capabilities in the parent.
> +	 *
> +	 * If the Smack namespace was properly hierarchical the user_ns to
> +	 * check against could be 'user_ns->parent'. Right now because of
> +	 * security concerns only privileged initial namespace is allowed
> +	 * to fill the map. For a hierarchical namespaces one would
> +	 * implement mapping (in the child namespaces) of only mapped labels
> +	 * (in parent namespace) and change '&init_user_ns' to
> +	 * 'user_ns->parent'. This will be added in the future.
> +	 */
> +	if (smack_ns_privileged(&init_user_ns, CAP_MAC_ADMIN) &&
> +	    security_capable(f_cred, &init_user_ns, CAP_MAC_ADMIN) == 0)
> +		return true;
> +
> +	return false;
> +}
> +
> +ssize_t proc_label_map_write(struct task_struct *p, const struct cred *f_cred,
> +			     void *value, size_t size)
> +{
> +	struct user_namespace *ns = ns_of_task_struct(p);
> +	struct user_namespace *cur_ns = ns_of_current();
> +	struct smack_known *skp;
> +	struct smack_known_ns *sknp;
> +	char *pos, *next_line, *tok[2];
> +	ssize_t ret;
> +	int i;
> +
> +	/* Mapping labels for the init ns makes no sense */
> +	if (ns == &init_user_ns)
> +		return -EBADR;
> +
> +	if (cur_ns != ns->parent)
> +		return -EPERM;
> +
> +	if (!mapping_permitted(f_cred, ns))
> +		return -EPERM;
> +
> +	if (value == NULL || size == 0 || size >= PAGE_SIZE)
> +		return -EINVAL;
> +
> +	mutex_lock(&smk_map_mutex);
> +
> +	/* Parse the user data */
> +	pos = value;
> +	pos[size] = '\0';
> +
> +	for (; pos; pos = next_line) {
> +		ret = -EINVAL;
> +
> +		/* Find the end of line and ensure I don't look past it */
> +		next_line = strchr(pos, '\n');
> +		if (next_line) {
> +			*next_line = '\0';
> +			next_line++;
> +			if (*next_line == '\0')
> +				next_line = NULL;
> +		}
> +
> +		/* Find tokens in line */
> +		for (i = 0; i < 2; ++i) {
> +			while (isspace(*pos))
> +				*(pos++) = '\0';
> +
> +			/* unexpected end of file */
> +			if (*pos == '\0')
> +				goto out;
> +
> +			tok[i] = pos;
> +
> +			/* find the end of the token */
> +			while (*pos != '\0' && !isspace(*pos))
> +				++pos;
> +		}
> +
> +		/* NUL terminate the last token if not EOL */
> +		while (isspace(*pos))
> +			*(pos++) = '\0';
> +
> +		/* there should not be any trailing data */
> +		if (*pos != '\0')
> +			goto out;
> +
> +		ret = -EEXIST;
> +
> +		/* do not allow to map 2 different labels to one name */
> +		skp = __smk_find_unmapped(tok[1], 0, ns);
> +		if (IS_ERR(skp)) {
> +			ret = PTR_ERR(skp);
> +			goto out;
> +		}
> +		if (skp != NULL)
> +			goto out;
> +
> +		skp = smk_import_entry(tok[0], 0);
> +		if (IS_ERR(skp)) {
> +			ret = PTR_ERR(skp);
> +			goto out;
> +		}
> +
> +		/* do not allow remapping */
> +		if (__smk_find_mapped(skp, ns))
> +			goto out;
> +
> +		sknp = smk_import_mapped(skp, ns, tok[1], 0);
> +		if (IS_ERR(sknp)) {
> +			ret = PTR_ERR(sknp);
> +			goto out;
> +		}
> +	}
> +
> +	ret = size;
> +
> +out:
> +	mutex_unlock(&smk_map_mutex);
> +
> +	return ret;
> +}
