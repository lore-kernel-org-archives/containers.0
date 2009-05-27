From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/7] [PATCH] Add target_pids parameter to copy_process()
Date: Wed, 27 May 2009 13:05:31 -0500
Message-ID: <20090527180531.GB780@us.ibm.com>
References: <20090527154212.GA3107@us.ibm.com>
	<20090527154422.GE3107@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090527154422.GE3107-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> 
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Mon, 4 May 2009 01:17:43 -0700
> Subject: [PATCH 5/7] [PATCH] Add target_pids parameter to copy_process()
> 
> The new parameter will be used in a follow-on patch when clone_with_pids()
> is implemented.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  kernel/fork.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index d2d69d3..373411e 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -949,12 +949,12 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  					unsigned long stack_size,
>  					int __user *child_tidptr,
>  					struct pid *pid,
> +					pid_t *target_pids,
>  					int trace)
>  {
>  	int retval;
>  	struct task_struct *p;
>  	int cgroup_callbacks_done = 0;
> -	pid_t *target_pids = NULL;
> 
>  	if ((clone_flags & (CLONE_NEWNS|CLONE_FS)) == (CLONE_NEWNS|CLONE_FS))
>  		return ERR_PTR(-EINVAL);
> @@ -1327,7 +1327,7 @@ struct task_struct * __cpuinit fork_idle(int cpu)
>  	struct pt_regs regs;
> 
>  	task = copy_process(CLONE_VM, 0, idle_regs(&regs), 0, NULL,
> -			    &init_struct_pid, 0);
> +			    &init_struct_pid, NULL, 0);
>  	if (!IS_ERR(task))
>  		init_idle(task, cpu);
> 
> @@ -1350,6 +1350,7 @@ long do_fork(unsigned long clone_flags,
>  	struct task_struct *p;
>  	int trace = 0;
>  	long nr;
> +	pid_t *target_pids = NULL;
> 
>  	/*
>  	 * Do some preliminary argument and permissions checking before we
> @@ -1390,7 +1391,7 @@ long do_fork(unsigned long clone_flags,
>  		trace = tracehook_prepare_clone(clone_flags);
> 
>  	p = copy_process(clone_flags, stack_start, regs, stack_size,
> -			 child_tidptr, NULL, trace);
> +			 child_tidptr, NULL, target_pids, trace);
>  	/*
>  	 * Do this prior waking up the new thread - the thread pointer
>  	 * might get invalid after that point, if the thread exits quickly.
> -- 
> 1.5.2.5
