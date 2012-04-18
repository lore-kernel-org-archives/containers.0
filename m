From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 19/43] userns: Store uid and gid values in struct cred
	with kuid_t and kgid_t types
Date: Wed, 18 Apr 2012 18:49:43 +0000
Message-ID: <20120418184943.GD4984__42224.9930714772$1334775002$gmane$org@mail.hallyn.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-19-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1333862139-31737-19-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
> cred.h and a few trivial users of struct cred are changed.  The rest of the users
> of struct cred are left for other patches as there are too many changes to make
> in one go and leave the change reviewable.  If the user namespace is disabled and
> CONFIG_UIDGID_STRICT_TYPE_CHECKS are disabled the code will contiue to compile
> and behave correctly.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> ---
>  arch/x86/mm/fault.c            |    2 +-
>  fs/ioprio.c                    |    8 ++------
>  include/linux/cred.h           |   16 ++++++++--------
>  include/linux/user_namespace.h |    8 ++++----
>  kernel/cred.c                  |   36 ++++++++++++++++++++++--------------
>  kernel/signal.c                |   14 ++++++++------
>  kernel/sys.c                   |   26 +++++++++-----------------
>  kernel/user_namespace.c        |    4 ++--
>  mm/oom_kill.c                  |    4 ++--
>  security/commoncap.c           |    3 +--
>  10 files changed, 59 insertions(+), 62 deletions(-)
> 
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 3ecfd1a..76dcd9d 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -582,7 +582,7 @@ show_fault_oops(struct pt_regs *regs, unsigned long error_code,
>  		pte_t *pte = lookup_address(address, &level);
>  
>  		if (pte && pte_present(*pte) && !pte_exec(*pte))
> -			printk(nx_warning, current_uid());
> +			printk(nx_warning, from_kuid(&init_user_ns, current_uid()));
>  	}
>  
>  	printk(KERN_ALERT "BUG: unable to handle kernel ");
> diff --git a/fs/ioprio.c b/fs/ioprio.c
> index 8e35e96..2072e41 100644
> --- a/fs/ioprio.c
> +++ b/fs/ioprio.c
> @@ -123,9 +123,7 @@ SYSCALL_DEFINE3(ioprio_set, int, which, int, who, int, ioprio)
>  				break;
>  
>  			do_each_thread(g, p) {
> -				const struct cred *tcred = __task_cred(p);
> -				kuid_t tcred_uid = make_kuid(tcred->user_ns, tcred->uid);
> -				if (!uid_eq(tcred_uid, uid))
> +				if (!uid_eq(task_uid(p), uid))
>  					continue;
>  				ret = set_task_ioprio(p, ioprio);
>  				if (ret)
> @@ -220,9 +218,7 @@ SYSCALL_DEFINE2(ioprio_get, int, which, int, who)
>  				break;
>  
>  			do_each_thread(g, p) {
> -				const struct cred *tcred = __task_cred(p);
> -				kuid_t tcred_uid = make_kuid(tcred->user_ns, tcred->uid);
> -				if (!uid_eq(tcred_uid, user->uid))
> +				if (!uid_eq(task_uid(p), user->uid))
>  					continue;
>  				tmpio = get_task_ioprio(p);
>  				if (tmpio < 0)
> diff --git a/include/linux/cred.h b/include/linux/cred.h
> index 0ab3cda..fac0579 100644
> --- a/include/linux/cred.h
> +++ b/include/linux/cred.h
> @@ -123,14 +123,14 @@ struct cred {
>  #define CRED_MAGIC	0x43736564
>  #define CRED_MAGIC_DEAD	0x44656144
>  #endif
> -	uid_t		uid;		/* real UID of the task */
> -	gid_t		gid;		/* real GID of the task */
> -	uid_t		suid;		/* saved UID of the task */
> -	gid_t		sgid;		/* saved GID of the task */
> -	uid_t		euid;		/* effective UID of the task */
> -	gid_t		egid;		/* effective GID of the task */
> -	uid_t		fsuid;		/* UID for VFS ops */
> -	gid_t		fsgid;		/* GID for VFS ops */
> +	kuid_t		uid;		/* real UID of the task */
> +	kgid_t		gid;		/* real GID of the task */
> +	kuid_t		suid;		/* saved UID of the task */
> +	kgid_t		sgid;		/* saved GID of the task */
> +	kuid_t		euid;		/* effective UID of the task */
> +	kgid_t		egid;		/* effective GID of the task */
> +	kuid_t		fsuid;		/* UID for VFS ops */
> +	kgid_t		fsgid;		/* GID for VFS ops */
>  	unsigned	securebits;	/* SUID-less security management */
>  	kernel_cap_t	cap_inheritable; /* caps our children can inherit */
>  	kernel_cap_t	cap_permitted;	/* caps we're permitted */
> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> index 4c9846d..a2c6145 100644
> --- a/include/linux/user_namespace.h
> +++ b/include/linux/user_namespace.h
> @@ -70,15 +70,15 @@ static inline void put_user_ns(struct user_namespace *ns)
>  #endif
>  
>  static inline uid_t user_ns_map_uid(struct user_namespace *to,
> -	const struct cred *cred, uid_t uid)
> +	const struct cred *cred, kuid_t uid)
>  {
> -	return from_kuid_munged(to, make_kuid(cred->user_ns, uid));
> +	return from_kuid_munged(to, uid);
>  }
>  
>  static inline gid_t user_ns_map_gid(struct user_namespace *to,
> -	const struct cred *cred, gid_t gid)
> +	const struct cred *cred, kgid_t gid)
>  {
> -	return from_kgid_munged(to, make_kgid(cred->user_ns, gid));
> +	return from_kgid_munged(to, gid);
>  }
>  
>  #endif /* _LINUX_USER_H */
> diff --git a/kernel/cred.c b/kernel/cred.c
> index 7a0d806..eddc5e2 100644
> --- a/kernel/cred.c
> +++ b/kernel/cred.c
> @@ -49,6 +49,14 @@ struct cred init_cred = {
>  	.subscribers		= ATOMIC_INIT(2),
>  	.magic			= CRED_MAGIC,
>  #endif
> +	.uid			= GLOBAL_ROOT_UID,
> +	.gid			= GLOBAL_ROOT_GID,
> +	.suid			= GLOBAL_ROOT_UID,
> +	.sgid			= GLOBAL_ROOT_GID,
> +	.euid			= GLOBAL_ROOT_UID,
> +	.egid			= GLOBAL_ROOT_GID,
> +	.fsuid			= GLOBAL_ROOT_UID,
> +	.fsgid			= GLOBAL_ROOT_GID,
>  	.securebits		= SECUREBITS_DEFAULT,
>  	.cap_inheritable	= CAP_EMPTY_SET,
>  	.cap_permitted		= CAP_FULL_SET,
> @@ -488,10 +496,10 @@ int commit_creds(struct cred *new)
>  	get_cred(new); /* we will require a ref for the subj creds too */
>  
>  	/* dumpability changes */
> -	if (old->euid != new->euid ||
> -	    old->egid != new->egid ||
> -	    old->fsuid != new->fsuid ||
> -	    old->fsgid != new->fsgid ||
> +	if (!uid_eq(old->euid, new->euid) ||
> +	    !gid_eq(old->egid, new->egid) ||
> +	    !uid_eq(old->fsuid, new->fsuid) ||
> +	    !gid_eq(old->fsgid, new->fsgid) ||
>  	    !cap_issubset(new->cap_permitted, old->cap_permitted)) {
>  		if (task->mm)
>  			set_dumpable(task->mm, suid_dumpable);
> @@ -500,9 +508,9 @@ int commit_creds(struct cred *new)
>  	}
>  
>  	/* alter the thread keyring */
> -	if (new->fsuid != old->fsuid)
> +	if (!uid_eq(new->fsuid, old->fsuid))
>  		key_fsuid_changed(task);
> -	if (new->fsgid != old->fsgid)
> +	if (!gid_eq(new->fsgid, old->fsgid))
>  		key_fsgid_changed(task);
>  
>  	/* do it
> @@ -519,16 +527,16 @@ int commit_creds(struct cred *new)
>  	alter_cred_subscribers(old, -2);
>  
>  	/* send notifications */
> -	if (new->uid   != old->uid  ||
> -	    new->euid  != old->euid ||
> -	    new->suid  != old->suid ||
> -	    new->fsuid != old->fsuid)
> +	if (!uid_eq(new->uid,   old->uid)  ||
> +	    !uid_eq(new->euid,  old->euid) ||
> +	    !uid_eq(new->suid,  old->suid) ||
> +	    !uid_eq(new->fsuid, old->fsuid))
>  		proc_id_connector(task, PROC_EVENT_UID);
>  
> -	if (new->gid   != old->gid  ||
> -	    new->egid  != old->egid ||
> -	    new->sgid  != old->sgid ||
> -	    new->fsgid != old->fsgid)
> +	if (!gid_eq(new->gid,   old->gid)  ||
> +	    !gid_eq(new->egid,  old->egid) ||
> +	    !gid_eq(new->sgid,  old->sgid) ||
> +	    !gid_eq(new->fsgid, old->fsgid))
>  		proc_id_connector(task, PROC_EVENT_GID);
>  
>  	/* release the old obj and subj refs both */
> diff --git a/kernel/signal.c b/kernel/signal.c
> index e2c5d84..2734dc9 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -1038,8 +1038,10 @@ static inline void userns_fixup_signal_uid(struct siginfo *info, struct task_str
>  	if (SI_FROMKERNEL(info))
>  		return;
>  
> -	info->si_uid = user_ns_map_uid(task_cred_xxx(t, user_ns),
> -					current_cred(), info->si_uid);
> +	rcu_read_lock();
> +	info->si_uid = from_kuid_munged(task_cred_xxx(t, user_ns),
> +					make_kuid(current_user_ns(), info->si_uid));
> +	rcu_read_unlock();
>  }
>  #else
>  static inline void userns_fixup_signal_uid(struct siginfo *info, struct task_struct *t)
> @@ -1106,7 +1108,7 @@ static int __send_signal(int sig, struct siginfo *info, struct task_struct *t,
>  			q->info.si_code = SI_USER;
>  			q->info.si_pid = task_tgid_nr_ns(current,
>  							task_active_pid_ns(t));
> -			q->info.si_uid = current_uid();
> +			q->info.si_uid = from_kuid_munged(current_user_ns(), current_uid());
>  			break;
>  		case (unsigned long) SEND_SIG_PRIV:
>  			q->info.si_signo = sig;
> @@ -1973,7 +1975,7 @@ static void ptrace_do_notify(int signr, int exit_code, int why)
>  	info.si_signo = signr;
>  	info.si_code = exit_code;
>  	info.si_pid = task_pid_vnr(current);
> -	info.si_uid = current_uid();
> +	info.si_uid = from_kuid_munged(current_user_ns(), current_uid());
>  
>  	/* Let the debugger run.  */
>  	ptrace_stop(exit_code, why, 1, &info);
> @@ -2828,7 +2830,7 @@ SYSCALL_DEFINE2(kill, pid_t, pid, int, sig)
>  	info.si_errno = 0;
>  	info.si_code = SI_USER;
>  	info.si_pid = task_tgid_vnr(current);
> -	info.si_uid = current_uid();
> +	info.si_uid = from_kuid_munged(current_user_ns(), current_uid());
>  
>  	return kill_something_info(sig, &info, pid);
>  }
> @@ -2871,7 +2873,7 @@ static int do_tkill(pid_t tgid, pid_t pid, int sig)
>  	info.si_errno = 0;
>  	info.si_code = SI_TKILL;
>  	info.si_pid = task_tgid_vnr(current);
> -	info.si_uid = current_uid();
> +	info.si_uid = from_kuid_munged(current_user_ns(), current_uid());
>  
>  	return do_send_specific(tgid, pid, sig, &info);
>  }
> diff --git a/kernel/sys.c b/kernel/sys.c
> index f0c43b4..3996281 100644
> --- a/kernel/sys.c
> +++ b/kernel/sys.c
> @@ -175,7 +175,6 @@ SYSCALL_DEFINE3(setpriority, int, which, int, who, int, niceval)
>  	const struct cred *cred = current_cred();
>  	int error = -EINVAL;
>  	struct pid *pgrp;
> -	kuid_t cred_uid;
>  	kuid_t uid;
>  
>  	if (which > PRIO_USER || which < PRIO_PROCESS)
> @@ -209,22 +208,19 @@ SYSCALL_DEFINE3(setpriority, int, which, int, who, int, niceval)
>  			} while_each_pid_thread(pgrp, PIDTYPE_PGID, p);
>  			break;
>  		case PRIO_USER:
> -			cred_uid = make_kuid(cred->user_ns, cred->uid);
>  			uid = make_kuid(cred->user_ns, who);
>  			user = cred->user;
>  			if (!who)
> -				uid = cred_uid;
> -			else if (!uid_eq(uid, cred_uid) &&
> +				uid = cred->uid;
> +			else if (!uid_eq(uid, cred->uid) &&
>  				 !(user = find_user(uid)))
>  				goto out_unlock;	/* No processes for this user */
>  
>  			do_each_thread(g, p) {
> -				const struct cred *tcred = __task_cred(p);
> -				kuid_t tcred_uid = make_kuid(tcred->user_ns, tcred->uid);
> -				if (uid_eq(tcred_uid, uid))
> +				if (uid_eq(task_uid(p), uid))
>  					error = set_one_prio(p, niceval, error);
>  			} while_each_thread(g, p);
> -			if (!uid_eq(uid, cred_uid))
> +			if (!uid_eq(uid, cred->uid))
>  				free_uid(user);		/* For find_user() */
>  			break;
>  	}
> @@ -248,7 +244,6 @@ SYSCALL_DEFINE2(getpriority, int, which, int, who)
>  	const struct cred *cred = current_cred();
>  	long niceval, retval = -ESRCH;
>  	struct pid *pgrp;
> -	kuid_t cred_uid;
>  	kuid_t uid;
>  
>  	if (which > PRIO_USER || which < PRIO_PROCESS)
> @@ -280,25 +275,22 @@ SYSCALL_DEFINE2(getpriority, int, which, int, who)
>  			} while_each_pid_thread(pgrp, PIDTYPE_PGID, p);
>  			break;
>  		case PRIO_USER:
> -			cred_uid = make_kuid(cred->user_ns, cred->uid);
>  			uid = make_kuid(cred->user_ns, who);
>  			user = cred->user;
>  			if (!who)
> -				uid = cred_uid;
> -			else if (!uid_eq(uid, cred_uid) &&
> +				uid = cred->uid;
> +			else if (!uid_eq(uid, cred->uid) &&
>  				 !(user = find_user(uid)))
>  				goto out_unlock;	/* No processes for this user */
>  
>  			do_each_thread(g, p) {
> -				const struct cred *tcred = __task_cred(p);
> -				kuid_t tcred_uid = make_kuid(tcred->user_ns, tcred->uid);
> -				if (uid_eq(tcred_uid, uid)) {
> +				if (uid_eq(task_uid(p), uid)) {
>  					niceval = 20 - task_nice(p);
>  					if (niceval > retval)
>  						retval = niceval;
>  				}
>  			} while_each_thread(g, p);
> -			if (!uid_eq(uid, cred_uid))
> +			if (!uid_eq(uid, cred->uid))
>  				free_uid(user);		/* for find_user() */
>  			break;
>  	}
> @@ -641,7 +633,7 @@ static int set_user(struct cred *new)
>  {
>  	struct user_struct *new_user;
>  
> -	new_user = alloc_uid(make_kuid(new->user_ns, new->uid));
> +	new_user = alloc_uid(new->uid);
>  	if (!new_user)
>  		return -EAGAIN;
>  
> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> index 9991bac..0683dbf 100644
> --- a/kernel/user_namespace.c
> +++ b/kernel/user_namespace.c
> @@ -36,8 +36,8 @@ static bool new_idmap_permitted(struct user_namespace *ns, int cap_setid,
>  int create_user_ns(struct cred *new)
>  {
>  	struct user_namespace *ns, *parent_ns = new->user_ns;
> -	kuid_t owner = make_kuid(new->user_ns, new->euid);
> -	kgid_t group = make_kgid(new->user_ns, new->egid);
> +	kuid_t owner = new->euid;
> +	kgid_t group = new->egid;
>  
>  	/* The creator needs a mapping in the parent user namespace
>  	 * or else we won't be able to reasonably tell userspace who
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 46bf2ed5..9f09a1f 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -410,8 +410,8 @@ static void dump_tasks(const struct mem_cgroup *memcg, const nodemask_t *nodemas
>  		}
>  
>  		pr_info("[%5d] %5d %5d %8lu %8lu %3u     %3d         %5d %s\n",
> -			task->pid, task_uid(task), task->tgid,
> -			task->mm->total_vm, get_mm_rss(task->mm),
> +			task->pid, from_kuid(&init_user_ns, task_uid(task)),
> +			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
>  			task_cpu(task), task->signal->oom_adj,
>  			task->signal->oom_score_adj, task->comm);
>  		task_unlock(task);
> diff --git a/security/commoncap.c b/security/commoncap.c
> index f2399d8..dbd465a 100644
> --- a/security/commoncap.c
> +++ b/security/commoncap.c
> @@ -77,8 +77,7 @@ int cap_capable(const struct cred *cred, struct user_namespace *targ_ns,
>  {
>  	for (;;) {
>  		/* The owner of the user namespace has all caps. */
> -		if (targ_ns != &init_user_ns && uid_eq(targ_ns->owner,
> -						       make_kuid(cred->user_ns, cred->euid)))
> +		if (targ_ns != &init_user_ns && uid_eq(targ_ns->owner, cred->euid))
>  			return 0;
>  
>  		/* Do we have the necessary capabilities? */
> -- 
> 1.7.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
