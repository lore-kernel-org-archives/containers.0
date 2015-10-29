From: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Subject: Re: [PATCH v4 05/11] smack: extend capability functions and fix 2
	checks
Date: Thu, 29 Oct 2015 15:50:38 -0700
Message-ID: <5632A2BE.6070905__6110.63074688918$1446159064$gmane$org@schaufler-ca.com>
References: <1444826525-9758-1-git-send-email-l.pawelczyk@samsung.com>
	<1444826525-9758-6-git-send-email-l.pawelczyk@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1444826525-9758-6-git-send-email-l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
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
> This patch extends smack capability functions to a full list to those
> equivalent in the kernel
>
> has_ns_capability -> smack_has_ns_privilege
> has_capability    -> smack_has_privilege
> ns_capable        -> smack_ns_privileged
> capable           -> smack_privileged
>
> It also puts the smack related part to a common function:
> smack_capability_allowed()
>
> Those functions will be needed for capability checks in the upcoming
> Smack namespace patches.
>
> Additionally there were 2 smack capability checks that used generic
> capability functions instead of specific Smack ones effectively ignoring
> the onlycap rule. This has been fixed now with the introduction of those
> new functions.
>
> This has implications on the Smack namespace as well as the additional
> Smack checks in smack_capability_allowed() will be extended beyond the
> onlycap rule. Not using Smack specific checks in those 2 places could
> mean breaking the Smack label namespace separation.
>
> Signed-off-by: Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> Reviewed-by: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Acked-by: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>


> ---
>  security/smack/smack.h        |  5 ++++
>  security/smack/smack_access.c | 64 +++++++++++++++++++++++++++++++++++++++----
>  security/smack/smack_lsm.c    |  4 +--
>  3 files changed, 65 insertions(+), 8 deletions(-)
>
> diff --git a/security/smack/smack.h b/security/smack/smack.h
> index fff0c61..ca8fb7c 100644
> --- a/security/smack/smack.h
> +++ b/security/smack/smack.h
> @@ -300,6 +300,11 @@ int smk_netlbl_mls(int, char *, struct netlbl_lsm_secattr *, int);
>  struct smack_known *smk_import_entry(const char *, int);
>  void smk_insert_entry(struct smack_known *skp);
>  struct smack_known *smk_find_entry(const char *);
> +int smack_has_ns_privilege(struct task_struct *task,
> +			   struct user_namespace *user_ns,
> +			   int cap);
> +int smack_has_privilege(struct task_struct *task, int cap);
> +int smack_ns_privileged(struct user_namespace *user_ns, int cap);
>  int smack_privileged(int cap);
>  
>  /*
> diff --git a/security/smack/smack_access.c b/security/smack/smack_access.c
> index bc1053f..72f848e 100644
> --- a/security/smack/smack_access.c
> +++ b/security/smack/smack_access.c
> @@ -629,14 +629,16 @@ LIST_HEAD(smack_onlycap_list);
>  DEFINE_MUTEX(smack_onlycap_lock);
>  
>  /*
> - * Is the task privileged and allowed to be privileged
> - * by the onlycap rule.
> + * Internal smack capability check complimentary to the
> + * set of kernel capable() and has_capability() functions
>   *
> - * Returns 1 if the task is allowed to be privileged, 0 if it's not.
> + * For a capability in smack related checks to be effective it needs to:
> + * - be allowed to be privileged by the onlycap rule.
> + * - be in the initial user ns
>   */
> -int smack_privileged(int cap)
> +static int smack_capability_allowed(struct smack_known *skp,
> +				    struct user_namespace *user_ns)
>  {
> -	struct smack_known *skp = smk_of_current();
>  	struct smack_onlycap *sop;
>  
>  	/*
> @@ -645,7 +647,7 @@ int smack_privileged(int cap)
>  	if (unlikely(current->flags & PF_KTHREAD))
>  		return 1;
>  
> -	if (!capable(cap))
> +	if (user_ns != &init_user_ns)
>  		return 0;
>  
>  	rcu_read_lock();
> @@ -664,3 +666,53 @@ int smack_privileged(int cap)
>  
>  	return 0;
>  }
> +
> +/*
> + * Is the task privileged in a namespace and allowed to be privileged
> + * by additional smack rules.
> + */
> +int smack_has_ns_privilege(struct task_struct *task,
> +			   struct user_namespace *user_ns,
> +			   int cap)
> +{
> +	struct smack_known *skp = smk_of_task_struct(task);
> +
> +	if (!has_ns_capability(task, user_ns, cap))
> +		return 0;
> +	if (smack_capability_allowed(skp, user_ns))
> +		return 1;
> +	return 0;
> +}
> +
> +/*
> + * Is the task privileged and allowed to be privileged
> + * by additional smack rules.
> + */
> +int smack_has_privilege(struct task_struct *task, int cap)
> +{
> +	return smack_has_ns_privilege(task, &init_user_ns, cap);
> +}
> +
> +/*
> + * Is the current task privileged in a namespace and allowed to be privileged
> + * by additional smack rules.
> + */
> +int smack_ns_privileged(struct user_namespace *user_ns, int cap)
> +{
> +	struct smack_known *skp = smk_of_current();
> +
> +	if (!ns_capable(user_ns, cap))
> +		return 0;
> +	if (smack_capability_allowed(skp, user_ns))
> +		return 1;
> +	return 0;
> +}
> +
> +/*
> + * Is the current task privileged and allowed to be privileged
> + * by additional smack rules.
> + */
> +int smack_privileged(int cap)
> +{
> +	return smack_ns_privileged(&init_user_ns, cap);
> +}
> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index c439370..198d3d6 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -413,7 +413,7 @@ static int smk_ptrace_rule_check(struct task_struct *tracer,
>  			rc = 0;
>  		else if (smack_ptrace_rule == SMACK_PTRACE_DRACONIAN)
>  			rc = -EACCES;
> -		else if (capable(CAP_SYS_PTRACE))
> +		else if (smack_has_privilege(tracer, CAP_SYS_PTRACE))
>  			rc = 0;
>  		else
>  			rc = -EACCES;
> @@ -1809,7 +1809,7 @@ static int smack_file_send_sigiotask(struct task_struct *tsk,
>  	skp = file->f_security;
>  	rc = smk_access(skp, tkp, MAY_WRITE, NULL);
>  	rc = smk_bu_note("sigiotask", skp, tkp, MAY_WRITE, rc);
> -	if (rc != 0 && has_capability(tsk, CAP_MAC_OVERRIDE))
> +	if (rc != 0 && smack_has_privilege(tsk, CAP_MAC_OVERRIDE))
>  		rc = 0;
>  
>  	smk_ad_init(&ad, __func__, LSM_AUDIT_DATA_TASK);
