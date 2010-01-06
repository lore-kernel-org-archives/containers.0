From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] RFC: taking a crack at targeted capabilities
Date: Wed, 6 Jan 2010 11:35:36 -0600
Message-ID: <20100106173536.GD15784@us.ibm.com>
References: <20100106062809.GA17064@us.ibm.com>
	<m17hrv18ad.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m17hrv18ad.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > So i was thinking about how to safely but incrementally introduce
> > targeted capabilities - which we decided was a prereq to making VFS
> > handle user namespaces - and the following seemed doable.  My main
> > motivations were (in order):
> >
> >         1. don't make any unconverted capable() checks unsafe
> >         2. minimize performance impact on non-container case
> >         3. minimize performance impact on containers
> 
> My motivation is a bit different.  I would like to get to the
> unprivileged creation of new namespaces.  It looks like this gets us
> 90% of the way there, with only potential uid confusion issues left.

Yup, that was actually what I was thinking about last night when I decided
to give it a shot :)  IMO, my patch + a dummy version of user_namespaces
for vfs (done in a clean way that can be an incremental step toward full
vfs userns support - which I haven't yet thought through) is enough to
give you safe fully unprivileged containers.  Now with the API I have,
you'd have a program with either setuid-root or cap_sys_admin,cap_setpcap=pe
which does the prctl and the unshares, but it would theoretically be safe
to hand that program to unprivileged users.

> I still need to handle getting all caps after creation but otherwise I
> think I have a good starter patch that achieves all of your goals.

Well in my patch we don't need to clear out the bounding set, or set
SETUID_NOROOT - so running a setuid root program or becoming root should
still give you capabilities!  They'll just be targeted at your container.

I really think this is what you need.

> Of course kill_permission needs the checks you have suggested as well.

Ok, I can't look at your patch in detail right now and don't quite get
where you're going with a quick glance, so will look in closer detail
later.   Will also think about a way to get "just-enough" vfs userns
support to completely give you what you need for privileged users in
unprivileged containers.

-serge

> >From db104af741b5f0a2f128688905498cae68fbbde2 Mon Sep 17 00:00:00 2001
> From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Date: Wed, 6 Jan 2010 08:26:21 -0800
> Subject: [PATCH] security:  Make capabilities relative to the user namespace.
> 
> - Introduce ns_capable to test for a capability in a non-default
>   user namespace.
> - Teach cap_capable to handle capabilities in a non-default
>   user namespace.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  include/linux/capability.h |    6 ++++--
>  include/linux/security.h   |   12 +++++++-----
>  kernel/capability.c        |   22 ++++++++++++++++++++--
>  security/commoncap.c       |   40 +++++++++++++++++++++++++++++++++-------
>  security/security.c        |   12 ++++++------
>  security/selinux/hooks.c   |   14 +++++++++-----
>  6 files changed, 79 insertions(+), 27 deletions(-)
> 
> diff --git a/include/linux/capability.h b/include/linux/capability.h
> index 39e5ff5..89572b2 100644
> --- a/include/linux/capability.h
> +++ b/include/linux/capability.h
> @@ -544,7 +544,7 @@ extern const kernel_cap_t __cap_init_eff_set;
>   *
>   * Note that this does not set PF_SUPERPRIV on the task.
>   */
> -#define has_capability(t, cap) (security_real_capable((t), (cap)) == 0)
> +#define has_capability(t, cap) (security_real_capable((t), &init_user_ns, (cap)) == 0)
> 
>  /**
>   * has_capability_noaudit - Determine if a task has a superior capability available (unaudited)
> @@ -558,9 +558,11 @@ extern const kernel_cap_t __cap_init_eff_set;
>   * Note that this does not set PF_SUPERPRIV on the task.
>   */
>  #define has_capability_noaudit(t, cap) \
> -	(security_real_capable_noaudit((t), (cap)) == 0)
> +	(security_real_capable_noaudit((t), &init_user_ns, (cap)) == 0)
> 
> +struct user_namespace;
>  extern int capable(int cap);
> +extern int ns_capable(struct user_namespace *ns, int cap);
> 
>  /* audit system wants to get cap info from files as well */
>  struct dentry;
> diff --git a/include/linux/security.h b/include/linux/security.h
> index 2c627d3..f44932f 100644
> --- a/include/linux/security.h
> +++ b/include/linux/security.h
> @@ -45,13 +45,14 @@
> 
>  struct ctl_table;
>  struct audit_krule;
> +struct user_namespace;
> 
>  /*
>   * These functions are in security/capability.c and are used
>   * as the default capabilities functions
>   */
>  extern int cap_capable(struct task_struct *tsk, const struct cred *cred,
> -		       int cap, int audit);
> +		       struct user_namespace *ns, int cap, int audit);
>  extern int cap_settime(struct timespec *ts, struct timezone *tz);
>  extern int cap_ptrace_access_check(struct task_struct *child, unsigned int mode);
>  extern int cap_ptrace_traceme(struct task_struct *parent);
> @@ -1327,6 +1328,7 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
>   *	credentials.
>   *	@tsk contains the task_struct for the process.
>   *	@cred contains the credentials to use.
> + *      @ns contains the user namespace we want the capability in
>   *	@cap contains the capability <include/linux/capability.h>.
>   *	@audit: Whether to write an audit message or not
>   *	Return 0 if the capability is granted for @tsk.
> @@ -1457,7 +1459,7 @@ struct security_operations {
>  		       const kernel_cap_t *inheritable,
>  		       const kernel_cap_t *permitted);
>  	int (*capable) (struct task_struct *tsk, const struct cred *cred,
> -			int cap, int audit);
> +			struct user_namespace *ns, int cap, int audit);
>  	int (*acct) (struct file *file);
>  	int (*sysctl) (struct ctl_table *table, int op);
>  	int (*quotactl) (int cmds, int type, int id, struct super_block *sb);
> @@ -1754,9 +1756,9 @@ int security_capset(struct cred *new, const struct cred *old,
>  		    const kernel_cap_t *effective,
>  		    const kernel_cap_t *inheritable,
>  		    const kernel_cap_t *permitted);
> -int security_capable(int cap);
> -int security_real_capable(struct task_struct *tsk, int cap);
> -int security_real_capable_noaudit(struct task_struct *tsk, int cap);
> +int security_capable(struct user_namespace *ns, int cap);
> +int security_real_capable(struct task_struct *tsk, struct user_namespace *ns, int cap);
> +int security_real_capable_noaudit(struct task_struct *tsk, struct user_namespace *ns, int cap);
>  int security_acct(struct file *file);
>  int security_sysctl(struct ctl_table *table, int op);
>  int security_quotactl(int cmds, int type, int id, struct super_block *sb);
> diff --git a/kernel/capability.c b/kernel/capability.c
> index 7f876e6..63dcf53 100644
> --- a/kernel/capability.c
> +++ b/kernel/capability.c
> @@ -14,6 +14,7 @@
>  #include <linux/security.h>
>  #include <linux/syscalls.h>
>  #include <linux/pid_namespace.h>
> +#include <linux/user_namespace.h>
>  #include <asm/uaccess.h>
>  #include "cred-internals.h"
> 
> @@ -302,15 +303,32 @@ error:
>   */
>  int capable(int cap)
>  {
> +	return ns_capable(&init_user_ns, cap);
> +}
> +EXPORT_SYMBOL(capable);
> +
> +/**
> + * ns_capable - Determine if the current task has a superior capability in effect
> + * @ns:  The usernamespace we want the capability in
> + * @cap: The capability to be tested for
> + *
> + * Return true if the current task has the given superior capability currently
> + * available for use, false if not.
> + *
> + * This sets PF_SUPERPRIV on the task if the capability is available on the
> + * assumption that it's about to be used.
> + */
> +int ns_capable(struct user_namespace *ns, int cap)
> +{
>  	if (unlikely(!cap_valid(cap))) {
>  		printk(KERN_CRIT "capable() called with invalid cap=%u\n", cap);
>  		BUG();
>  	}
> 
> -	if (security_capable(cap) == 0) {
> +	if (security_capable(ns, cap) == 0) {
>  		current->flags |= PF_SUPERPRIV;
>  		return 1;
>  	}
>  	return 0;
>  }
> -EXPORT_SYMBOL(capable);
> +EXPORT_SYMBOL(ns_capable);
> diff --git a/security/commoncap.c b/security/commoncap.c
> index 34500e3..ffde5be 100644
> --- a/security/commoncap.c
> +++ b/security/commoncap.c
> @@ -27,6 +27,7 @@
>  #include <linux/sched.h>
>  #include <linux/prctl.h>
>  #include <linux/securebits.h>
> +#include <linux/user_namespace.h>
> 
>  /*
>   * If a non-root user executes a setuid-root binary in
> @@ -68,6 +69,7 @@ EXPORT_SYMBOL(cap_netlink_recv);
>   * cap_capable - Determine whether a task has a particular effective capability
>   * @tsk: The task to query
>   * @cred: The credentials to use
> + * @ns:  The user namespace in which we need the capability
>   * @cap: The capability to check for
>   * @audit: Whether to write an audit message or not
>   *
> @@ -79,10 +81,32 @@ EXPORT_SYMBOL(cap_netlink_recv);
>   * cap_has_capability() returns 0 when a task has a capability, but the
>   * kernel's capable() and has_capability() returns 1 for this case.
>   */
> -int cap_capable(struct task_struct *tsk, const struct cred *cred, int cap,
> -		int audit)
> +int cap_capable(struct task_struct *tsk, const struct cred *cred,
> +		struct user_namespace *targ_ns, int cap, int audit)
>  {
> -	return cap_raised(cred->cap_effective, cap) ? 0 : -EPERM;
> +	for (;;) {
> +		/* Do we have the necessary capabilities? */
> +		if (targ_ns == cred->user->user_ns)
> +			return cap_raised(cred->cap_effective, cap) ? 0 : -EPERM;
> +	
> +		/* The creator of the user namespace has all caps. */
> +		if (targ_ns->creator == cred->user)
> +			return 0;
> +	
> +		/* Have we tried all of the parent namespaces? */
> +		if (targ_ns == &init_user_ns)
> +			return -EPERM;
> +	
> +		/* If you have the capability in a parent user ns you have it
> +		 * in the over all children user namespaces as well, so see
> +		 * if this process has the capability in the parent user
> +		 * namespace.
> +		 */
> +		targ_ns = targ_ns->creator->user_ns;
> +	}
> +	
> +	/* We never get here */
> +	return -EPERM;                
>  }
> 
>  /**
> @@ -177,7 +201,8 @@ static inline int cap_inh_is_capped(void)
>  	/* they are so limited unless the current task has the CAP_SETPCAP
>  	 * capability
>  	 */
> -	if (cap_capable(current, current_cred(), CAP_SETPCAP,
> +	if (cap_capable(current, current_cred(),
> +			current_cred()->user->user_ns, CAP_SETPCAP,
>  			SECURITY_CAP_AUDIT) == 0)
>  		return 0;
>  	return 1;
> @@ -832,7 +857,8 @@ int cap_task_prctl(int option, unsigned long arg2, unsigned long arg3,
>  		     & (new->securebits ^ arg2))			/*[1]*/
>  		    || ((new->securebits & SECURE_ALL_LOCKS & ~arg2))	/*[2]*/
>  		    || (arg2 & ~(SECURE_ALL_LOCKS | SECURE_ALL_BITS))	/*[3]*/
> -		    || (cap_capable(current, current_cred(), CAP_SETPCAP,
> +		    || (cap_capable(current, current_cred(),
> +				    current_cred()->user->user_ns, CAP_SETPCAP,
>  				    SECURITY_CAP_AUDIT) != 0)		/*[4]*/
>  			/*
>  			 * [1] no changing of bits that are locked
> @@ -910,7 +936,7 @@ int cap_vm_enough_memory(struct mm_struct *mm, long pages)
>  {
>  	int cap_sys_admin = 0;
> 
> -	if (cap_capable(current, current_cred(), CAP_SYS_ADMIN,
> +	if (cap_capable(current, current_cred(), &init_user_ns, CAP_SYS_ADMIN,
>  			SECURITY_CAP_NOAUDIT) == 0)
>  		cap_sys_admin = 1;
>  	return __vm_enough_memory(mm, pages, cap_sys_admin);
> @@ -937,7 +963,7 @@ int cap_file_mmap(struct file *file, unsigned long reqprot,
>  	int ret = 0;
> 
>  	if (addr < dac_mmap_min_addr) {
> -		ret = cap_capable(current, current_cred(), CAP_SYS_RAWIO,
> +		ret = cap_capable(current, current_cred(), &init_user_ns, CAP_SYS_RAWIO,
>  				  SECURITY_CAP_AUDIT);
>  		/* set PF_SUPERPRIV if it turns out we allow the low mmap */
>  		if (ret == 0)
> diff --git a/security/security.c b/security/security.c
> index 24e060b..ad75427 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -155,30 +155,30 @@ int security_capset(struct cred *new, const struct cred *old,
>  				    effective, inheritable, permitted);
>  }
> 
> -int security_capable(int cap)
> +int security_capable(struct user_namespace *ns, int cap)
>  {
> -	return security_ops->capable(current, current_cred(), cap,
> +	return security_ops->capable(current, current_cred(), ns, cap,
>  				     SECURITY_CAP_AUDIT);
>  }
> 
> -int security_real_capable(struct task_struct *tsk, int cap)
> +int security_real_capable(struct task_struct *tsk, struct user_namespace *ns, int cap)
>  {
>  	const struct cred *cred;
>  	int ret;
> 
>  	cred = get_task_cred(tsk);
> -	ret = security_ops->capable(tsk, cred, cap, SECURITY_CAP_AUDIT);
> +	ret = security_ops->capable(tsk, cred, ns, cap, SECURITY_CAP_AUDIT);
>  	put_cred(cred);
>  	return ret;
>  }
> 
> -int security_real_capable_noaudit(struct task_struct *tsk, int cap)
> +int security_real_capable_noaudit(struct task_struct *tsk, struct user_namespace *ns, int cap)
>  {
>  	const struct cred *cred;
>  	int ret;
> 
>  	cred = get_task_cred(tsk);
> -	ret = security_ops->capable(tsk, cred, cap, SECURITY_CAP_NOAUDIT);
> +	ret = security_ops->capable(tsk, cred, ns, cap, SECURITY_CAP_NOAUDIT);
>  	put_cred(cred);
>  	return ret;
>  }
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index bd77a2b..a69f97d 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -76,6 +76,7 @@
>  #include <linux/selinux.h>
>  #include <linux/mutex.h>
>  #include <linux/posix-timers.h>
> +#include <linux/user_namespace.h>
> 
>  #include "avc.h"
>  #include "objsec.h"
> @@ -1480,6 +1481,7 @@ static int current_has_perm(const struct task_struct *tsk,
>  /* Check whether a task is allowed to use a capability. */
>  static int task_has_capability(struct task_struct *tsk,
>  			       const struct cred *cred,
> +			       struct user_namespace *ns,
>  			       int cap, int audit)
>  {
>  	struct common_audit_data ad;
> @@ -1927,15 +1929,15 @@ static int selinux_capset(struct cred *new, const struct cred *old,
>   */
> 
>  static int selinux_capable(struct task_struct *tsk, const struct cred *cred,
> -			   int cap, int audit)
> +			   struct user_namespace *ns, int cap, int audit)
>  {
>  	int rc;
> 
> -	rc = cap_capable(tsk, cred, cap, audit);
> +	rc = cap_capable(tsk, cred, ns, cap, audit);
>  	if (rc)
>  		return rc;
> 
> -	return task_has_capability(tsk, cred, cap, audit);
> +	return task_has_capability(tsk, cred, ns, cap, audit);
>  }
> 
>  static int selinux_sysctl_get_sid(ctl_table *table, u16 tclass, u32 *sid)
> @@ -2091,7 +2093,8 @@ static int selinux_vm_enough_memory(struct mm_struct *mm, long pages)
>  {
>  	int rc, cap_sys_admin = 0;
> 
> -	rc = selinux_capable(current, current_cred(), CAP_SYS_ADMIN,
> +	rc = selinux_capable(current, current_cred(),
> +			     &init_user_ns, CAP_SYS_ADMIN,
>  			     SECURITY_CAP_NOAUDIT);
>  	if (rc == 0)
>  		cap_sys_admin = 1;
> @@ -2889,7 +2892,8 @@ static int selinux_inode_getsecurity(const struct inode *inode, const char *name
>  	 * and lack of permission just means that we fall back to the
>  	 * in-core context value, not a denial.
>  	 */
> -	error = selinux_capable(current, current_cred(), CAP_MAC_ADMIN,
> +	error = selinux_capable(current, current_cred(),
> +				&init_user_ns, CAP_MAC_ADMIN,
>  				SECURITY_CAP_NOAUDIT);
>  	if (!error)
>  		error = security_sid_to_context_force(isec->sid, &context,
> -- 
> 1.6.5.2.143.g8cc62
