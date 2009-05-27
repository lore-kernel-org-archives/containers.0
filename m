From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/7] [PATCH] Define do_fork_with_pids()
Date: Wed, 27 May 2009 13:05:43 -0500
Message-ID: <20090527180543.GC780@us.ibm.com>
References: <20090527154212.GA3107@us.ibm.com>
	<20090527154443.GF3107@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090527154443.GF3107-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Date: Mon, 4 May 2009 01:17:44 -0700
> Subject: [PATCH 6/7] [PATCH] Define do_fork_with_pids()
> 
> do_fork_with_pids() is same as do_fork(), except that it takes an
> additional, target_pids, parameter. This parameter, currently unused,
> specifies the target_pids of the process in each of its pid namespaces.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  include/linux/sched.h |    1 +
>  kernel/fork.c         |   17 ++++++++++++++---
>  2 files changed, 15 insertions(+), 3 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index b4c38bc..2173df1 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1995,6 +1995,7 @@ extern int disallow_signal(int);
> 
>  extern int do_execve(char *, char __user * __user *, char __user * __user *, struct pt_regs *);
>  extern long do_fork(unsigned long, unsigned long, struct pt_regs *, unsigned long, int __user *, int __user *);
> +extern long do_fork_with_pids(unsigned long, unsigned long, struct pt_regs *, unsigned long, int __user *, int __user *, pid_t *target_pids);
>  struct task_struct *fork_idle(int);
> 
>  extern void set_task_comm(struct task_struct *tsk, char *from);
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 373411e..912d008 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1340,17 +1340,17 @@ struct task_struct * __cpuinit fork_idle(int cpu)
>   * It copies the process, and if successful kick-starts
>   * it and waits for it to finish using the VM if required.
>   */
> -long do_fork(unsigned long clone_flags,
> +long do_fork_with_pids(unsigned long clone_flags,
>  	      unsigned long stack_start,
>  	      struct pt_regs *regs,
>  	      unsigned long stack_size,
>  	      int __user *parent_tidptr,
> -	      int __user *child_tidptr)
> +	      int __user *child_tidptr,
> +	      pid_t *target_pids)
>  {
>  	struct task_struct *p;
>  	int trace = 0;
>  	long nr;
> -	pid_t *target_pids = NULL;
> 
>  	/*
>  	 * Do some preliminary argument and permissions checking before we
> @@ -1448,6 +1448,17 @@ long do_fork(unsigned long clone_flags,
>  	return nr;
>  }
> 
> +long do_fork(unsigned long clone_flags,
> +	      unsigned long stack_start,
> +	      struct pt_regs *regs,
> +	      unsigned long stack_size,
> +	      int __user *parent_tidptr,
> +	      int __user *child_tidptr)
> +{
> +	return do_fork_with_pids(clone_flags, stack_start, regs, stack_size,
> +			parent_tidptr, child_tidptr, NULL);
> +}
> +
>  #ifndef ARCH_MIN_MMSTRUCT_ALIGN
>  #define ARCH_MIN_MMSTRUCT_ALIGN 0
>  #endif
> -- 
> 1.5.2.5
