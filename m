From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 6/7][v2] Define do_fork_with_pids()
Date: Thu, 28 May 2009 07:54:24 -0500
Message-ID: <20090528125424.GC14253@us.ibm.com>
References: <20090528043748.GA16522@us.ibm.com>
	<20090528043929.GF16522@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090528043929.GF16522-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Subject: [RFC][PATCH 6/7][v2] Define do_fork_with_pids()
> 
> do_fork_with_pids() is same as do_fork(), except that it takes an
> additional, 'pid_set', parameter. This parameter, currently unused,
> specifies the set of target pids of the process in each of its pid
> namespaces.
> 
> Changelog[v2]:
> 	- [v1] of this patch had some architecture-indpendent code in
> 	  arch/x86/kernel/process_32.c.  To facilitate moving this code
> 	  to kernel/fork.c, in the next patch, [v2] of the patch passes
> 	  'struct target_pid_set __user *' to do_fork_with_pids() instead
> 	  of 'pid_t *'.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  include/linux/sched.h |    1 +
>  include/linux/types.h |    5 +++++
>  kernel/fork.c         |   16 ++++++++++++++--
>  3 files changed, 20 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index b4c38bc..8468e54 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1995,6 +1995,7 @@ extern int disallow_signal(int);
> 
>  extern int do_execve(char *, char __user * __user *, char __user * __user *, struct pt_regs *);
>  extern long do_fork(unsigned long, unsigned long, struct pt_regs *, unsigned long, int __user *, int __user *);
> +extern long do_fork_with_pids(unsigned long, unsigned long, struct pt_regs *, unsigned long, int __user *, int __user *, struct target_pid_set __user *pid_set);
>  struct task_struct *fork_idle(int);
> 
>  extern void set_task_comm(struct task_struct *tsk, char *from);
> diff --git a/include/linux/types.h b/include/linux/types.h
> index 5abe354..17ec186 100644
> --- a/include/linux/types.h
> +++ b/include/linux/types.h
> @@ -204,6 +204,11 @@ struct ustat {
>  	char			f_fpack[6];
>  };
> 
> +struct target_pid_set {
> +	int num_pids;
> +	pid_t *target_pids;
> +};
> +
>  #endif	/* __KERNEL__ */
>  #endif /*  __ASSEMBLY__ */
>  #endif /* _LINUX_TYPES_H */
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 373411e..a16ef7b 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1340,12 +1340,13 @@ struct task_struct * __cpuinit fork_idle(int cpu)
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
> +	      struct target_pid_set __user *pid_setp)
>  {
>  	struct task_struct *p;
>  	int trace = 0;
> @@ -1448,6 +1449,17 @@ long do_fork(unsigned long clone_flags,
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
