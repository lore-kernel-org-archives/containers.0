From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 04/14] userns: Convert selinux to use kuid and kgid where
	appropriate
Date: Wed, 26 Sep 2012 12:51:36 -0500
Message-ID: <20120926175136.GB30620__34289.7771428854$1348681921$gmane$org@sergelap>
References: <87k3vote43.fsf@xmission.com>
	<1348187330-6616-1-git-send-email-ebiederm@xmission.com>
	<1348187330-6616-4-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1348187330-6616-4-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> Cc: Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>
> Cc: James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>

Acked-by: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>

> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  security/selinux/selinuxfs.c   |    6 +++---
>  security/selinux/ss/services.c |    2 +-
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/security/selinux/selinuxfs.c b/security/selinux/selinuxfs.c
> index 298e695..55af8c5 100644
> --- a/security/selinux/selinuxfs.c
> +++ b/security/selinux/selinuxfs.c
> @@ -174,7 +174,7 @@ static ssize_t sel_write_enforce(struct file *file, const char __user *buf,
>  		audit_log(current->audit_context, GFP_KERNEL, AUDIT_MAC_STATUS,
>  			"enforcing=%d old_enforcing=%d auid=%u ses=%u",
>  			new_value, selinux_enforcing,
> -			audit_get_loginuid(current),
> +			from_kuid(&init_user_ns, audit_get_loginuid(current)),
>  			audit_get_sessionid(current));
>  		selinux_enforcing = new_value;
>  		if (selinux_enforcing)
> @@ -305,7 +305,7 @@ static ssize_t sel_write_disable(struct file *file, const char __user *buf,
>  			goto out;
>  		audit_log(current->audit_context, GFP_KERNEL, AUDIT_MAC_STATUS,
>  			"selinux=0 auid=%u ses=%u",
> -			audit_get_loginuid(current),
> +			from_kuid(&init_user_ns, audit_get_loginuid(current)),
>  			audit_get_sessionid(current));
>  	}
>  
> @@ -551,7 +551,7 @@ static ssize_t sel_write_load(struct file *file, const char __user *buf,
>  out1:
>  	audit_log(current->audit_context, GFP_KERNEL, AUDIT_MAC_POLICY_LOAD,
>  		"policy loaded auid=%u ses=%u",
> -		audit_get_loginuid(current),
> +		from_kuid(&init_user_ns, audit_get_loginuid(current)),
>  		audit_get_sessionid(current));
>  out:
>  	mutex_unlock(&sel_mutex);
> diff --git a/security/selinux/ss/services.c b/security/selinux/ss/services.c
> index 4321b8f..b4feecc 100644
> --- a/security/selinux/ss/services.c
> +++ b/security/selinux/ss/services.c
> @@ -2440,7 +2440,7 @@ int security_set_bools(int len, int *values)
>  				sym_name(&policydb, SYM_BOOLS, i),
>  				!!values[i],
>  				policydb.bool_val_to_struct[i]->state,
> -				audit_get_loginuid(current),
> +				from_kuid(&init_user_ns, audit_get_loginuid(current)),
>  				audit_get_sessionid(current));
>  		}
>  		if (values[i])
> -- 
> 1.7.5.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
