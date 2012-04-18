From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 22/43] userns: Convert capabilities related permsion checks
Date: Wed, 18 Apr 2012 18:51:06 +0000
Message-ID: <20120418185106.GG4984__19641.8447689668$1334775061$gmane$org@mail.hallyn.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-22-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1333862139-31737-22-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Beiderman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> - Use uid_eq when comparing kuids
>   Use gid_eq when comparing kgids
> - Use __make_kuid(user_ns, 0) to talk about the user_namespace root uid
>   Use __make_kgid(user_ns, 0) to talk about the user_namespace root gid
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

though, nit,

> ---
>  fs/open.c            |    3 ++-
>  security/commoncap.c |   43 ++++++++++++++++++++++++++++---------------
>  2 files changed, 30 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/open.c b/fs/open.c
> index 5720854..92335f6 100644
> --- a/fs/open.c
> +++ b/fs/open.c
> @@ -316,7 +316,8 @@ SYSCALL_DEFINE3(faccessat, int, dfd, const char __user *, filename, int, mode)
>  
>  	if (!issecure(SECURE_NO_SETUID_FIXUP)) {
>  		/* Clear the capabilities if we switch to a non-root user */
> -		if (override_cred->uid)
> +		kuid_t root_uid = make_kuid(override_cred->user_ns, 0);
> +		if (!uid_eq(override_cred->uid, root_uid))
>  			cap_clear(override_cred->cap_effective);
>  		else
>  			override_cred->cap_effective =
> diff --git a/security/commoncap.c b/security/commoncap.c
> index dbd465a..9bf8df8 100644
> --- a/security/commoncap.c
> +++ b/security/commoncap.c
> @@ -472,19 +472,24 @@ int cap_bprm_set_creds(struct linux_binprm *bprm)
>  	struct cred *new = bprm->cred;
>  	bool effective, has_cap = false;
>  	int ret;
> +	kuid_t root_uid;
> +	kgid_t root_gid;

the root_gid is assigned but never used.

>  
>  	effective = false;
>  	ret = get_file_caps(bprm, &effective, &has_cap);
>  	if (ret < 0)
>  		return ret;
>  
> +	root_uid = make_kuid(new->user_ns, 0);
> +	root_gid = make_kgid(new->user_ns, 0);
> +
>  	if (!issecure(SECURE_NOROOT)) {
>  		/*
>  		 * If the legacy file capability is set, then don't set privs
>  		 * for a setuid root binary run by a non-root user.  Do set it
>  		 * for a root user just to cause least surprise to an admin.
>  		 */
> -		if (has_cap && new->uid != 0 && new->euid == 0) {
> +		if (has_cap && !uid_eq(new->uid, root_uid) && uid_eq(new->euid, root_uid)) {
>  			warn_setuid_and_fcaps_mixed(bprm->filename);
>  			goto skip;
>  		}
> @@ -495,12 +500,12 @@ int cap_bprm_set_creds(struct linux_binprm *bprm)
>  		 *
>  		 * If only the real uid is 0, we do not set the effective bit.
>  		 */
> -		if (new->euid == 0 || new->uid == 0) {
> +		if (uid_eq(new->euid, root_uid) || uid_eq(new->uid, root_uid)) {
>  			/* pP' = (cap_bset & ~0) | (pI & ~0) */
>  			new->cap_permitted = cap_combine(old->cap_bset,
>  							 old->cap_inheritable);
>  		}
> -		if (new->euid == 0)
> +		if (uid_eq(new->euid, root_uid))
>  			effective = true;
>  	}
>  skip:
> @@ -508,8 +513,8 @@ skip:
>  	/* Don't let someone trace a set[ug]id/setpcap binary with the revised
>  	 * credentials unless they have the appropriate permit
>  	 */
> -	if ((new->euid != old->uid ||
> -	     new->egid != old->gid ||
> +	if ((!uid_eq(new->euid, old->uid) ||
> +	     !gid_eq(new->egid, old->gid) ||
>  	     !cap_issubset(new->cap_permitted, old->cap_permitted)) &&
>  	    bprm->unsafe & ~LSM_UNSAFE_PTRACE_CAP) {
>  		/* downgrade; they get no more than they had, and maybe less */
> @@ -544,7 +549,7 @@ skip:
>  	 */
>  	if (!cap_isclear(new->cap_effective)) {
>  		if (!cap_issubset(CAP_FULL_SET, new->cap_effective) ||
> -		    new->euid != 0 || new->uid != 0 ||
> +		    !uid_eq(new->euid, root_uid) || !uid_eq(new->uid, root_uid) ||
>  		    issecure(SECURE_NOROOT)) {
>  			ret = audit_log_bprm_fcaps(bprm, new, old);
>  			if (ret < 0)
> @@ -569,16 +574,17 @@ skip:
>  int cap_bprm_secureexec(struct linux_binprm *bprm)
>  {
>  	const struct cred *cred = current_cred();
> +	kuid_t root_uid = make_kuid(cred->user_ns, 0);
>  
> -	if (cred->uid != 0) {
> +	if (!uid_eq(cred->uid, root_uid)) {
>  		if (bprm->cap_effective)
>  			return 1;
>  		if (!cap_isclear(cred->cap_permitted))
>  			return 1;
>  	}
>  
> -	return (cred->euid != cred->uid ||
> -		cred->egid != cred->gid);
> +	return (!uid_eq(cred->euid, cred->uid) ||
> +		!gid_eq(cred->egid, cred->gid));
>  }
>  
>  /**
> @@ -668,15 +674,21 @@ int cap_inode_removexattr(struct dentry *dentry, const char *name)
>   */
>  static inline void cap_emulate_setxuid(struct cred *new, const struct cred *old)
>  {
> -	if ((old->uid == 0 || old->euid == 0 || old->suid == 0) &&
> -	    (new->uid != 0 && new->euid != 0 && new->suid != 0) &&
> +	kuid_t root_uid = make_kuid(old->user_ns, 0);
> +
> +	if ((uid_eq(old->uid, root_uid) ||
> +	     uid_eq(old->euid, root_uid) ||
> +	     uid_eq(old->suid, root_uid)) &&
> +	    (!uid_eq(new->uid, root_uid) &&
> +	     !uid_eq(new->euid, root_uid) &&
> +	     !uid_eq(new->suid, root_uid)) &&
>  	    !issecure(SECURE_KEEP_CAPS)) {
>  		cap_clear(new->cap_permitted);
>  		cap_clear(new->cap_effective);
>  	}
> -	if (old->euid == 0 && new->euid != 0)
> +	if (uid_eq(old->euid, root_uid) && !uid_eq(new->euid, root_uid))
>  		cap_clear(new->cap_effective);
> -	if (old->euid != 0 && new->euid == 0)
> +	if (!uid_eq(old->euid, root_uid) && uid_eq(new->euid, root_uid))
>  		new->cap_effective = new->cap_permitted;
>  }
>  
> @@ -709,11 +721,12 @@ int cap_task_fix_setuid(struct cred *new, const struct cred *old, int flags)
>  		 *          if not, we might be a bit too harsh here.
>  		 */
>  		if (!issecure(SECURE_NO_SETUID_FIXUP)) {
> -			if (old->fsuid == 0 && new->fsuid != 0)
> +			kuid_t root_uid = make_kuid(old->user_ns, 0);
> +			if (uid_eq(old->fsuid, root_uid) && !uid_eq(new->fsuid, root_uid))
>  				new->cap_effective =
>  					cap_drop_fs_set(new->cap_effective);
>  
> -			if (old->fsuid != 0 && new->fsuid == 0)
> +			if (!uid_eq(old->fsuid, root_uid) && uid_eq(new->fsuid, root_uid))
>  				new->cap_effective =
>  					cap_raise_fs_set(new->cap_effective,
>  							 new->cap_permitted);
> -- 
> 1.7.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
