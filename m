From: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>
Subject: Re: [PATCH v4 08/11] smack: misc cleanups in preparation for a
	namespace patch
Date: Thu, 29 Oct 2015 15:51:30 -0700
Message-ID: <5632A2F2.1090000@schaufler-ca.com>
References: <1444826525-9758-1-git-send-email-l.pawelczyk@samsung.com>
	<1444826525-9758-9-git-send-email-l.pawelczyk@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1444826525-9758-9-git-send-email-l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
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
> This patch does some small miscellaneous cleanups and additions that
> should not change the code behaviour in any way. Its only purpose is to
> shape the code in a way that the smack namespace patches would be
> smaller and easier to understand.
>
> Changes:
> - four small helper functions added
> - minor code reformatting in several places for readability
> - unnecessarily increasing string size has been fixed
>
> This patch should not change the behaviour of the Smack in any way.
>
> Signed-off-by: Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> Reviewed-by: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>

Acked-by: Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>


> ---
>  security/smack/smack.h        | 47 ++++++++++++++++++++++++++++++++++-
>  security/smack/smack_access.c | 18 +++++++++-----
>  security/smack/smack_lsm.c    | 58 ++++++++++++++++---------------------------
>  security/smack/smackfs.c      |  4 +--
>  4 files changed, 81 insertions(+), 46 deletions(-)
>
> diff --git a/security/smack/smack.h b/security/smack/smack.h
> index 091efc2..98bb676 100644
> --- a/security/smack/smack.h
> +++ b/security/smack/smack.h
> @@ -291,7 +291,7 @@ struct smk_audit_info {
>  int smk_access_entry(char *, char *, struct list_head *);
>  int smk_access(struct smack_known *, struct smack_known *,
>  	       int, struct smk_audit_info *);
> -int smk_tskacc(struct task_smack *, struct smack_known *,
> +int smk_tskacc(struct task_struct *, struct smack_known *,
>  	       u32, struct smk_audit_info *);
>  int smk_curacc(struct smack_known *, u32, struct smk_audit_info *);
>  struct smack_known *smack_from_secid(const u32);
> @@ -348,6 +348,7 @@ extern struct hlist_head smack_known_hash[SMACK_HASH_SLOTS];
>  static inline int smk_inode_transmutable(const struct inode *isp)
>  {
>  	struct inode_smack *sip = isp->i_security;
> +
>  	return (sip->smk_flags & SMK_INODE_TRANSMUTE) != 0;
>  }
>  
> @@ -357,10 +358,31 @@ static inline int smk_inode_transmutable(const struct inode *isp)
>  static inline struct smack_known *smk_of_inode(const struct inode *isp)
>  {
>  	struct inode_smack *sip = isp->i_security;
> +
>  	return sip->smk_inode;
>  }
>  
>  /*
> + * Present a pointer to the smack label entry in an inode blob for an exec.
> + */
> +static inline struct smack_known *smk_of_exec(const struct inode *isp)
> +{
> +	struct inode_smack *sip = isp->i_security;
> +
> +	return sip->smk_task;
> +}
> +
> +/*
> + * Present a pointer to the smack label entry in an inode blob for an mmap.
> + */
> +static inline struct smack_known *smk_of_mmap(const struct inode *isp)
> +{
> +	struct inode_smack *sip = isp->i_security;
> +
> +	return sip->smk_mmap;
> +}
> +
> +/*
>   * Present a pointer to the smack label entry in an task blob.
>   */
>  static inline struct smack_known *smk_of_task(const struct task_smack *tsp)
> @@ -395,6 +417,29 @@ static inline struct smack_known *smk_of_current(void)
>  }
>  
>  /*
> + * Present a pointer to the user namespace entry in an task blob.
> + */
> +static inline
> +struct user_namespace *ns_of_task_struct(const struct task_struct *t)
> +{
> +	struct user_namespace *ns;
> +
> +	rcu_read_lock();
> +	ns = __task_cred(t)->user_ns;
> +	rcu_read_unlock();
> +
> +	return ns;
> +}
> +
> +/*
> + * Present a pointer to the user namespace entry in the current task blob.
> + */
> +static inline struct user_namespace *ns_of_current(void)
> +{
> +	return current_user_ns();
> +}
> +
> +/*
>   * logging functions
>   */
>  #define SMACK_AUDIT_DENIED 0x1
> diff --git a/security/smack/smack_access.c b/security/smack/smack_access.c
> index 131c742..750aa9c 100644
> --- a/security/smack/smack_access.c
> +++ b/security/smack/smack_access.c
> @@ -167,6 +167,7 @@ int smk_access(struct smack_known *subject, struct smack_known *object,
>  		if (subject == &smack_known_hat)
>  			goto out_audit;
>  	}
> +
>  	/*
>  	 * Beyond here an explicit relationship is required.
>  	 * If the requested access is contained in the available
> @@ -183,6 +184,7 @@ int smk_access(struct smack_known *subject, struct smack_known *object,
>  		rc = -EACCES;
>  		goto out_audit;
>  	}
> +
>  #ifdef CONFIG_SECURITY_SMACK_BRINGUP
>  	/*
>  	 * Return a positive value if using bringup mode.
> @@ -225,10 +227,10 @@ out_audit:
>   * non zero otherwise. It allows that the task may have the capability
>   * to override the rules.
>   */
> -int smk_tskacc(struct task_smack *tsp, struct smack_known *obj_known,
> +int smk_tskacc(struct task_struct *task, struct smack_known *obj_known,
>  	       u32 mode, struct smk_audit_info *a)
>  {
> -	struct smack_known *sbj_known = smk_of_task(tsp);
> +	struct smack_known *sbj_known = smk_of_task_struct(task);
>  	int may;
>  	int rc;
>  
> @@ -237,13 +239,19 @@ int smk_tskacc(struct task_smack *tsp, struct smack_known *obj_known,
>  	 */
>  	rc = smk_access(sbj_known, obj_known, mode, NULL);
>  	if (rc >= 0) {
> +		struct task_smack *tsp;
> +
>  		/*
>  		 * If there is an entry in the task's rule list
>  		 * it can further restrict access.
>  		 */
> +		rcu_read_lock();
> +		tsp = __task_cred(task)->security;
>  		may = smk_access_entry(sbj_known->smk_known,
>  				       obj_known->smk_known,
>  				       &tsp->smk_rules);
> +		rcu_read_unlock();
> +
>  		if (may < 0)
>  			goto out_audit;
>  		if ((mode & may) == mode)
> @@ -280,9 +288,7 @@ out_audit:
>  int smk_curacc(struct smack_known *obj_known,
>  	       u32 mode, struct smk_audit_info *a)
>  {
> -	struct task_smack *tsp = current_security();
> -
> -	return smk_tskacc(tsp, obj_known, mode, a);
> +	return smk_tskacc(current, obj_known, mode, a);
>  }
>  
>  #ifdef CONFIG_AUDIT
> @@ -456,7 +462,7 @@ char *smk_parse_smack(const char *string, int len)
>  	int i;
>  
>  	if (len <= 0)
> -		len = strlen(string) + 1;
> +		len = strlen(string);
>  
>  	/*
>  	 * Reserve a leading '-' as an indicator that
> diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
> index 7303c37..5a59836 100644
> --- a/security/smack/smack_lsm.c
> +++ b/security/smack/smack_lsm.c
> @@ -393,8 +393,6 @@ static int smk_ptrace_rule_check(struct task_struct *tracer,
>  {
>  	int rc;
>  	struct smk_audit_info ad, *saip = NULL;
> -	struct task_smack *tsp;
> -	struct smack_known *tracer_known;
>  
>  	if ((mode & PTRACE_MODE_NOAUDIT) == 0) {
>  		smk_ad_init(&ad, func, LSM_AUDIT_DATA_TASK);
> @@ -402,13 +400,12 @@ static int smk_ptrace_rule_check(struct task_struct *tracer,
>  		saip = &ad;
>  	}
>  
> -	rcu_read_lock();
> -	tsp = __task_cred(tracer)->security;
> -	tracer_known = smk_of_task(tsp);
>  
>  	if ((mode & PTRACE_MODE_ATTACH) &&
>  	    (smack_ptrace_rule == SMACK_PTRACE_EXACT ||
>  	     smack_ptrace_rule == SMACK_PTRACE_DRACONIAN)) {
> +		struct smack_known *tracer_known = smk_of_task_struct(tracer);
> +
>  		if (tracer_known->smk_known == tracee_known->smk_known)
>  			rc = 0;
>  		else if (smack_ptrace_rule == SMACK_PTRACE_DRACONIAN)
> @@ -416,22 +413,18 @@ static int smk_ptrace_rule_check(struct task_struct *tracer,
>  		else if (smack_has_privilege(tracer, CAP_SYS_PTRACE))
>  			rc = 0;
>  		else
> -			rc = -EACCES;
> +			rc = -EPERM;
>  
>  		if (saip)
>  			smack_log(tracer_known->smk_known,
>  				  tracee_known->smk_known,
>  				  0, rc, saip);
>  
> -		rcu_read_unlock();
>  		return rc;
>  	}
>  
>  	/* In case of rule==SMACK_PTRACE_DEFAULT or mode==PTRACE_MODE_READ */
> -	rc = smk_tskacc(tsp, tracee_known, smk_ptrace_mode(mode), saip);
> -
> -	rcu_read_unlock();
> -	return rc;
> +	return smk_tskacc(tracer, tracee_known, smk_ptrace_mode(mode), saip);
>  }
>  
>  /*
> @@ -450,9 +443,7 @@ static int smk_ptrace_rule_check(struct task_struct *tracer,
>   */
>  static int smack_ptrace_access_check(struct task_struct *ctp, unsigned int mode)
>  {
> -	struct smack_known *skp;
> -
> -	skp = smk_of_task_struct(ctp);
> +	struct smack_known *skp = smk_of_task_struct(ctp);
>  
>  	return smk_ptrace_rule_check(current, skp, mode, __func__);
>  }
> @@ -467,13 +458,9 @@ static int smack_ptrace_access_check(struct task_struct *ctp, unsigned int mode)
>   */
>  static int smack_ptrace_traceme(struct task_struct *ptp)
>  {
> -	int rc;
> -	struct smack_known *skp;
> -
> -	skp = smk_of_task(current_security());
> +	struct smack_known *skp = smk_of_current();
>  
> -	rc = smk_ptrace_rule_check(ptp, skp, PTRACE_MODE_ATTACH, __func__);
> -	return rc;
> +	return smk_ptrace_rule_check(ptp, skp, PTRACE_MODE_ATTACH, __func__);
>  }
>  
>  /**
> @@ -1692,13 +1679,14 @@ static int smack_mmap_file(struct file *file,
>  	if (file == NULL)
>  		return 0;
>  
> +	tsp = current_security();
> +	skp = smk_of_task(tsp);
>  	isp = file_inode(file)->i_security;
> -	if (isp->smk_mmap == NULL)
> -		return 0;
>  	mkp = isp->smk_mmap;
>  
> -	tsp = current_security();
> -	skp = smk_of_current();
> +	if (mkp == NULL)
> +		return 0;
> +
>  	rc = 0;
>  
>  	rcu_read_lock();
> @@ -3606,11 +3594,13 @@ static int smack_setprocattr(struct task_struct *p, const struct cred *f_cred,
>  static int smack_unix_stream_connect(struct sock *sock,
>  				     struct sock *other, struct sock *newsk)
>  {
> -	struct smack_known *skp;
> -	struct smack_known *okp;
>  	struct socket_smack *ssp = sock->sk_security;
>  	struct socket_smack *osp = other->sk_security;
>  	struct socket_smack *nsp = newsk->sk_security;
> +	struct smack_known *skp_out = ssp->smk_out;
> +	struct smack_known *okp_out = osp->smk_out;
> +	struct smack_known *skp_in = ssp->smk_in;
> +	struct smack_known *okp_in = osp->smk_in;
>  	struct smk_audit_info ad;
>  	int rc = 0;
>  #ifdef CONFIG_AUDIT
> @@ -3618,19 +3608,15 @@ static int smack_unix_stream_connect(struct sock *sock,
>  #endif
>  
>  	if (!smack_privileged(CAP_MAC_OVERRIDE)) {
> -		skp = ssp->smk_out;
> -		okp = osp->smk_in;
>  #ifdef CONFIG_AUDIT
>  		smk_ad_init_net(&ad, __func__, LSM_AUDIT_DATA_NET, &net);
>  		smk_ad_setfield_u_net_sk(&ad, other);
>  #endif
> -		rc = smk_access(skp, okp, MAY_WRITE, &ad);
> -		rc = smk_bu_note("UDS connect", skp, okp, MAY_WRITE, rc);
> +		rc = smk_access(skp_out, okp_in, MAY_WRITE, &ad);
> +		rc = smk_bu_note("UDS connect", skp_out, okp_in, MAY_WRITE, rc);
>  		if (rc == 0) {
> -			okp = osp->smk_out;
> -			skp = ssp->smk_in;
> -			rc = smk_access(okp, skp, MAY_WRITE, &ad);
> -			rc = smk_bu_note("UDS connect", okp, skp,
> +			rc = smk_access(okp_out, skp_in, MAY_WRITE, &ad);
> +			rc = smk_bu_note("UDS connect", okp_out, skp_in,
>  						MAY_WRITE, rc);
>  		}
>  	}
> @@ -3639,8 +3625,8 @@ static int smack_unix_stream_connect(struct sock *sock,
>  	 * Cross reference the peer labels for SO_PEERSEC.
>  	 */
>  	if (rc == 0) {
> -		nsp->smk_packet = ssp->smk_out;
> -		ssp->smk_packet = osp->smk_out;
> +		nsp->smk_packet = skp_out;
> +		ssp->smk_packet = okp_out;
>  	}
>  
>  	return rc;
> diff --git a/security/smack/smackfs.c b/security/smack/smackfs.c
> index e5fb555..3149ec0 100644
> --- a/security/smack/smackfs.c
> +++ b/security/smack/smackfs.c
> @@ -1827,7 +1827,7 @@ static const struct file_operations smk_mapped_ops = {
>  static ssize_t smk_read_ambient(struct file *filp, char __user *buf,
>  				size_t cn, loff_t *ppos)
>  {
> -	ssize_t rc;
> +	ssize_t rc = -EINVAL;
>  	char *cp;
>  	int asize;
>  
> @@ -1847,8 +1847,6 @@ static ssize_t smk_read_ambient(struct file *filp, char __user *buf,
>  
>  	if (cn >= asize)
>  		rc = simple_read_from_buffer(buf, cn, ppos, cp, asize);
> -	else
> -		rc = -EINVAL;
>  
>  	mutex_unlock(&smack_ambient_lock);
>  
