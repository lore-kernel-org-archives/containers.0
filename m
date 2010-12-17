From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC 5/5] user namespaces: Allow ptrace from non-init user
	namespaces
Date: Fri, 17 Dec 2010 11:45:49 -0800
Message-ID: <m1hbecqj2q.fsf__43021.4938744486$1292615195$gmane$org@fess.ebiederm.org>
References: <20101217152246.GA8221@mail.hallyn.com>
	<20101217152458.GA11162@mail.hallyn.com>
	<20101217152547.GB11162@mail.hallyn.com>
	<20101217152625.GC11162@mail.hallyn.com>
	<20101217152659.GD11162@mail.hallyn.com>
	<20101217152737.GE11162@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101217152737.GE11162-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Fri, 17 Dec 2010 15:27:37 +0000")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michael Kerrisk <michael.kerrisk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> ptrace is allowed to tasks in the same user namespace according to
> the usual rules (i.e. the same rules as for two tasks in the init
> user namespace).  ptrace is also allowed to a user namespace to
> which the current task the has CAP_SYS_PTRACE capability.

The uid equality check below is broken.

Eric


> Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  include/linux/capability.h |    2 ++
>  kernel/ptrace.c            |   40 ++++++++++++++++++++++++++++------------
>  security/commoncap.c       |   26 +++++++++++++++++++++-----
>  3 files changed, 51 insertions(+), 17 deletions(-)
>
> diff --git a/include/linux/capability.h b/include/linux/capability.h
> index cc3e976..777a166 100644
> --- a/include/linux/capability.h
> +++ b/include/linux/capability.h
> @@ -543,6 +543,8 @@ extern const kernel_cap_t __cap_init_eff_set;
>   */
>  #define has_capability(t, cap) (security_real_capable((t), &init_user_ns, (cap)) == 0)
>  
> +#define has_ns_capability(t, ns, cap) (security_real_capable((t), (ns), (cap)) == 0)
> +
>  /**
>   * has_capability_noaudit - Determine if a task has a superior capability available (unaudited)
>   * @t: The task in question
> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
> index 99bbaa3..aed24eb 100644
> --- a/kernel/ptrace.c
> +++ b/kernel/ptrace.c
> @@ -116,6 +116,19 @@ int ptrace_check_attach(struct task_struct *child, int kill)
>  	return ret;
>  }
>  
> +static inline int may_ptrace_ns(struct task_struct *t)

Can we name this ptrace_capable?  Since you are only
wrapping the capability check?  With a name like may_ptrace_ns
I imagine very different semantics.

> +{
> +	struct user_namespace *ns;
> +	int ret;
> +
> +	rcu_read_lock();
> +	ns = task_cred_xxx(t, user)->user_ns;
> +	ret = ns_capable(ns, CAP_SYS_PTRACE);
> +	rcu_read_unlock();
> +
> +	return ret;
> +}
> +
>  int __ptrace_may_access(struct task_struct *task, unsigned int mode)
>  {
>  	const struct cred *cred = current_cred(), *tcred;
> @@ -134,21 +147,24 @@ int __ptrace_may_access(struct task_struct *task, unsigned int mode)
>  		return 0;
>  	rcu_read_lock();
>  	tcred = __task_cred(task);
> -	if ((cred->uid != tcred->euid ||
> -	     cred->uid != tcred->suid ||
> -	     cred->uid != tcred->uid  ||
> -	     cred->gid != tcred->egid ||
> -	     cred->gid != tcred->sgid ||
> -	     cred->gid != tcred->gid) &&
> -	    !capable(CAP_SYS_PTRACE)) {
> -		rcu_read_unlock();
> -		return -EPERM;
> -	}
> +	if (cred->user->user_ns == tcred->user->user_ns &&
> +	    (cred->uid == tcred->euid ||
> +	     cred->uid == tcred->suid ||
> +	     cred->uid == tcred->uid  ||
> +	     cred->gid == tcred->egid ||
> +	     cred->gid == tcred->sgid ||
> +	     cred->gid == tcred->gid))
> +		goto ok;

This needs to be:
> +	if (cred->user->user_ns == tcred->user->user_ns &&
> +	    (cred->uid == tcred->euid &&
> +	     cred->uid == tcred->suid &&
> +	     cred->uid == tcred->uid  &&
> +	     cred->gid == tcred->egid &&
> +	     cred->gid == tcred->sgid &&
> +	     cred->gid == tcred->gid))
> +		goto ok;



> +	if (ns_capable(tcred->user->user_ns, CAP_SYS_PTRACE))
> +		goto ok;
> +	rcu_read_unlock();
> +	return -EPERM;
> +ok:
>  	rcu_read_unlock();
>  	smp_rmb();
>  	if (task->mm)
>  		dumpable = get_dumpable(task->mm);
> -	if (!dumpable && !capable(CAP_SYS_PTRACE))
> +	if (!dumpable && !may_ptrace_ns(task))
>  		return -EPERM;
>  
>  	return security_ptrace_access_check(task, mode);
> @@ -198,7 +214,7 @@ int ptrace_attach(struct task_struct *task)
>  		goto unlock_tasklist;
>  
>  	task->ptrace = PT_PTRACED;
> -	if (capable(CAP_SYS_PTRACE))
> +	if (may_ptrace_ns(task))
>  		task->ptrace |= PT_PTRACE_CAP;
>  
>  	__ptrace_link(task, current);
> diff --git a/security/commoncap.c b/security/commoncap.c
> index 9d910e6..bd0bcc6 100644
> --- a/security/commoncap.c
> +++ b/security/commoncap.c
> @@ -136,12 +136,20 @@ int cap_settime(struct timespec *ts, struct timezone *tz)
>  int cap_ptrace_access_check(struct task_struct *child, unsigned int mode)
>  {
>  	int ret = 0;
> +	struct cred *cred, *tcred;
>  
>  	rcu_read_lock();
> -	if (!cap_issubset(__task_cred(child)->cap_permitted,
> -			  current_cred()->cap_permitted) &&
> +	cred = current_cred();
> +	tcred = __task_cred(child);
> +	if (cred->user->user_ns != tcred->user->user_ns) {

This probably deserves a comment about why cap_issubset isn't
needed here.  Aka we implicitly have all caps in child user namespaces
so if we have CAP_SYS_PTRACE we know we have them all.

> +		if (!ns_capable(tcred->user->user_ns, CAP_SYS_PTRACE))
> +			ret = -EPERM;
> +		goto out;
> +	}
> +	if (!cap_issubset(tcred->cap_permitted, cred->cap_permitted) &&
>  	    !capable(CAP_SYS_PTRACE))
>  		ret = -EPERM;
> +out:
>  	rcu_read_unlock();
>  	return ret;
>  }
> @@ -156,12 +164,20 @@ int cap_ptrace_access_check(struct task_struct *child, unsigned int mode)
>  int cap_ptrace_traceme(struct task_struct *parent)
>  {
>  	int ret = 0;
> +	struct cred *cred, *tcred;
>  
>  	rcu_read_lock();
> -	if (!cap_issubset(current_cred()->cap_permitted,
> -			  __task_cred(parent)->cap_permitted) &&
> -	    !has_capability(parent, CAP_SYS_PTRACE))
> +	cred = __task_cred(parent);
> +	tcred = current_cred();
> +	if (cred->user->user_ns != tcred->user->user_ns) {
> +		if (!has_ns_capability(parent, tcred->user->user_ns, CAP_SYS_PTRACE))
> +			ret = -EPERM;
> +		goto out;
> +	}
> +	if (!cap_issubset(tcred->cap_permitted, cred->cap_permitted) &&
> +	    !has_ns_capability(parent, tcred->user->user_ns, CAP_SYS_PTRACE))
>  		ret = -EPERM;
> +out:
>  	rcu_read_unlock();
>  	return ret;
>  }
