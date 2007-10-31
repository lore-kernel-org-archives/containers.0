From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] pidns: Limit kill -1 and cap_set_all
Date: Wed, 31 Oct 2007 16:43:33 -0500
Message-ID: <20071031214333.GA29663@vino.hallyn.com>
References: <m1y7dp22d4.fsf@ebiederm.dsl.xmission.com>
	<alpine.LFD.0.999.0710261105440.30120@woody.linux-foundation.org>
	<m1r6jhzmov.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5p9zk6b.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1k5p9zk6b.fsf_-_-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Rishikesh K Rajak <risrajak-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> 
> This patch implements task_in_pid_ns and uses it to limit cap_set_all
> and sys_kill(-1,) to only those tasks in the current pid namespace.
> 
> Without this we have a setup for a very nasty surprise.
> 
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Thanks Eric.  Seems one of the LTP tests being written to test pidns
signaling did just catch that this week.  Hopefully the testcases will
be ready to push to ltp "soon".

So despite some complaints raised by others,

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

for looking correct and very much needed.

thanks,
-serge

> ---
>  include/linux/pid_namespace.h |    2 ++
>  kernel/capability.c           |    3 +++
>  kernel/pid.c                  |   11 +++++++++++
>  kernel/signal.c               |    5 ++++-
>  4 files changed, 20 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/pid_namespace.h b/include/linux/pid_namespace.h
> index 0227e68..b454678 100644
> --- a/include/linux/pid_namespace.h
> +++ b/include/linux/pid_namespace.h
> @@ -78,4 +78,6 @@ static inline struct task_struct *task_child_reaper(struct task_struct *tsk)
>  	return tsk->nsproxy->pid_ns->child_reaper;
>  }
>  
> +extern int task_in_pid_ns(struct task_struct *tsk, struct pid_namespace *ns);
> +
>  #endif /* _LINUX_PID_NS_H */
> diff --git a/kernel/capability.c b/kernel/capability.c
> index efbd9cd..a801016 100644
> --- a/kernel/capability.c
> +++ b/kernel/capability.c
> @@ -125,6 +125,7 @@ static inline int cap_set_all(kernel_cap_t *effective,
>  			       kernel_cap_t *inheritable,
>  			       kernel_cap_t *permitted)
>  {
> +     struct pid_namespace *pid_ns = current->nsproxy->pid_ns;
>       struct task_struct *g, *target;
>       int ret = -EPERM;
>       int found = 0;
> @@ -132,6 +133,8 @@ static inline int cap_set_all(kernel_cap_t *effective,
>       do_each_thread(g, target) {
>               if (target == current || is_container_init(target->group_leader))
>                       continue;
> +             if (!task_in_pid_ns(target, pid_ns))
> +		     continue;
>               found = 1;
>  	     if (security_capset_check(target, effective, inheritable,
>  						permitted))
> diff --git a/kernel/pid.c b/kernel/pid.c
> index f815455..1c332ca 100644
> --- a/kernel/pid.c
> +++ b/kernel/pid.c
> @@ -430,6 +430,17 @@ struct pid *find_get_pid(pid_t nr)
>  	return pid;
>  }
>  
> +static int pid_in_pid_ns(struct pid *pid, struct pid_namespace *ns)
> +{
> +	return pid && (ns->level <= pid->level) &&
> +		pid->numbers[ns->level].ns == ns;
> +}
> +
> +int task_in_pid_ns(struct task_struct *task, struct pid_namespace *ns)
> +{
> +	return pid_in_pid_ns(task_pid(task), ns);
> +}
> +
>  pid_t pid_nr_ns(struct pid *pid, struct pid_namespace *ns)
>  {
>  	struct upid *upid;
> diff --git a/kernel/signal.c b/kernel/signal.c
> index 1200630..8f5a31f 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -1147,10 +1147,13 @@ static int kill_something_info(int sig, struct siginfo *info, int pid)
>  	} else if (pid == -1) {
>  		int retval = 0, count = 0;
>  		struct task_struct * p;
> +		struct pid_namespace *ns = current->nsproxy->pid_ns;
>  
>  		read_lock(&tasklist_lock);
>  		for_each_process(p) {
> -			if (p->pid > 1 && !same_thread_group(p, current)) {
> +			if (!is_container_init(p) &&
> +			    !same_thread_group(p, current) &&
> +			    task_in_pid_ns(p, ns)) {
>  				int err = group_send_sig_info(sig, info, p);
>  				++count;
>  				if (err != -EPERM)
> -- 
> 1.5.3.rc6.17.g1911
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
