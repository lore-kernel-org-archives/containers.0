From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 32/43] userns: signal remove unnecessary map_cred_ns
Date: Wed, 18 Apr 2012 19:07:11 +0000
Message-ID: <20120418190711.GJ5186__25663.3554156453$1334775988$gmane$org@mail.hallyn.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-32-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1333862139-31737-32-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
> map_cred_ns is a light wrapper around from_kuid with the order of the arguments
> reversed.  Replace map_cred_ns with from_kuid and remove map_cred_ns.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> ---
>  kernel/signal.c |   20 +++++---------------
>  1 files changed, 5 insertions(+), 15 deletions(-)
> 
> diff --git a/kernel/signal.c b/kernel/signal.c
> index 9797939..6aca310 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -1019,15 +1019,6 @@ static inline int legacy_queue(struct sigpending *signals, int sig)
>  	return (sig < SIGRTMIN) && sigismember(&signals->signal, sig);
>  }
>  
> -/*
> - * map the uid in struct cred into user namespace *ns
> - */
> -static inline uid_t map_cred_ns(const struct cred *cred,
> -				struct user_namespace *ns)
> -{
> -	return from_kuid_munged(ns, cred->uid);
> -}
> -
>  #ifdef CONFIG_USER_NS
>  static inline void userns_fixup_signal_uid(struct siginfo *info, struct task_struct *t)
>  {
> @@ -1677,8 +1668,8 @@ bool do_notify_parent(struct task_struct *tsk, int sig)
>  	 */
>  	rcu_read_lock();
>  	info.si_pid = task_pid_nr_ns(tsk, tsk->parent->nsproxy->pid_ns);
> -	info.si_uid = map_cred_ns(__task_cred(tsk),
> -			task_cred_xxx(tsk->parent, user_ns));
> +	info.si_uid = from_kuid_munged(task_cred_xxx(tsk->parent, user_ns),
> +				       task_uid(tsk));
>  	rcu_read_unlock();
>  
>  	info.si_utime = cputime_to_clock_t(tsk->utime + tsk->signal->utime);
> @@ -1761,8 +1752,7 @@ static void do_notify_parent_cldstop(struct task_struct *tsk,
>  	 */
>  	rcu_read_lock();
>  	info.si_pid = task_pid_nr_ns(tsk, parent->nsproxy->pid_ns);
> -	info.si_uid = map_cred_ns(__task_cred(tsk),
> -			task_cred_xxx(parent, user_ns));
> +	info.si_uid = from_kuid_munged(task_cred_xxx(parent, user_ns), task_uid(tsk));
>  	rcu_read_unlock();
>  
>  	info.si_utime = cputime_to_clock_t(tsk->utime);
> @@ -2180,8 +2170,8 @@ static int ptrace_signal(int signr, siginfo_t *info,
>  		info->si_code = SI_USER;
>  		rcu_read_lock();
>  		info->si_pid = task_pid_vnr(current->parent);
> -		info->si_uid = map_cred_ns(__task_cred(current->parent),
> -				current_user_ns());
> +		info->si_uid = from_kuid_munged(current_user_ns(),
> +						task_uid(current->parent));
>  		rcu_read_unlock();
>  	}
>  
> -- 
> 1.7.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
