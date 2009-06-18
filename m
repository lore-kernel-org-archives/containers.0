From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] checkpoint/restart of robust futex lists
Date: Thu, 18 Jun 2009 13:12:18 -0400
Message-ID: <4A3A7572.9030907@cs.columbia.edu>
References: <20090603041919.GO9285@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090603041919.GO9285-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Matt Helsley wrote:
>     Save and restore the [compat_]robust_list member of the task struct.
>     
>     These lists record which futexes the task holds. To keep the overhead of
>     robust futexes low the list is kept in userspace. When the task exits the
>     kernel carefully walks these lists to recover held futexes that
>     other tasks may be attempting to acquire with FUTEX_WAIT.
>     
>     Because they point to userspace memory that is saved/restored by
>     checkpoint/restart saving the list pointers works.
>     
>     While saving the pointers works during checkpoint, restart is tricky
>     because the robust futex ABI contains provisions for changes based on
>     checking the size of the list head. So we need to save the length of
>     the list head too in order to make sure that the kernel used during
>     restart is capable of handling that ABI. Since there is only one ABI
>     supported at the moment taking the list head's size is simple. Should
>     the ABI change we will need to use the same size as specified during
>     sys_set_robust_list() and hence some new means of determining the length
>     of this userspace structure in sys_checkpoint would be required.
>     
>     Rather than rewrite the logic that checks and handles the ABI we reuse
>     sys_set_robust_list() by factoring out the body of the function and
>     calling it during restart.
>     
>     Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

What happens if we checkpoint on a system with CONFIG_FUTEX and
restart on a a system with !CONFIG_FUTEX ?

Clearly, if processes used futex, restart should fail.

If they didn't - then all we know is that at the time of the
checkpoint they didn't. It could be that they didn't and will
never try, so restarting on a futex-less kernel is correct.

But it could be that they perhaps did and perhaps will attempt
again later on. In this case, restarting on a futex-less kernel
is incorrect, because it isn't compatible with the (intention)
of the original execution.

I suppose it's time to come up with some scheme to encode the
capabilities of a kernel in the checkpoint image. At restart
we can test compatibility of current kernel with original one,
and decide what to do.

The decision itself, or part of it - like the question above -
can be done in userspace.

The opposite case (checkpoint with !CONFIG_FUTEX and restart on
CONFIG_FUTEX) is always ok, because it will overwrite with null
values on the restarting tasks.

Oren.


> 
> diff --git a/checkpoint/process.c b/checkpoint/process.c
> index b604a85..084a2e4 100644
> --- a/checkpoint/process.c
> +++ b/checkpoint/process.c
> @@ -42,6 +42,17 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
>  
>  	h->task_comm_len = TASK_COMM_LEN;
>  
> +#ifdef CONFIG_FUTEX
> +	/* These are __user pointers and can be saved without the objhash. */
> +	h->robust_futex_list = t->robust_list;
> +	h->robust_futex_head_len = sizeof(t->robust_list);
> +#ifdef CONFIG_COMPAT
> +	h->compat_robust_futex_list = t->compat_robust_list;
> +	h->compat_robust_futex_head_len = sizeof(t->compat_robust_list);
> +#endif
> +	/* FIXME save pi futex state?? */
> +#endif
> +
>  	/* FIXME: save remaining relevant task_struct fields */
>  
>  	ret = ckpt_write_obj(ctx, &h->h);
> @@ -366,6 +377,20 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
>  	memset(t->comm, 0, TASK_COMM_LEN);
>  	ret = _ckpt_read_string(ctx, t->comm, h->task_comm_len);
>  
> +#ifdef CONFIG_FUTEX
> +	/* Since we restore the memory map the address remains the same and
> +	 * this is safe. This is the same as [compat_]sys_set_robust_list() */
> +	if (h->robust_futex_list) {
> +		struct robust_list_head __user *rfl = h->robust_futex_list;
> +		do_set_robust_list(rfl, h->robust_futex_head_len);
> +	}
> +#ifdef CONFIG_COMPAT
> +	if (h->compat_robust_futex_list) {
> +		struct compat_robust_list_head __user *crfl = h->compat_robust_futex_list;
> +		do_compat_set_robust_list(crfl, h->compat_robust_futex_head_len);
> +	}
> +#endif
> +#endif
>  	/* FIXME: restore remaining relevant task_struct fields */
>   out:
>  	ckpt_hdr_put(ctx, h);
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index cd427d8..f226f8f 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -163,6 +163,12 @@ struct ckpt_hdr_task {
>  	__u32 exit_signal;
>  
>  	__u32 task_comm_len;
> +
> +	__u32 robust_futex_head_len;
> +	__u32 compat_robust_futex_head_len;
> +	__u64 robust_futex_list; /* a __user * */
> +	__u64 compat_robust_futex_list; /* a __user * */
> +	/* FIXME need futex prio inheritance state? */
>  } __attribute__((aligned(8)));
>  
>  /* namespaces */
> diff --git a/include/linux/compat.h b/include/linux/compat.h
> index f2ded21..f311e36 100644
> --- a/include/linux/compat.h
> +++ b/include/linux/compat.h
> @@ -165,7 +165,8 @@ struct compat_robust_list_head {
>  };
>  
>  extern void compat_exit_robust_list(struct task_struct *curr);
> -
> +extern long do_compat_set_robust_list(struct compat_robust_list_head __user *head,
> +				      compat_size_t len);
>  asmlinkage long
>  compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
>  			   compat_size_t len);
> diff --git a/include/linux/futex.h b/include/linux/futex.h
> index dd0e06b..8685d1c 100644
> --- a/include/linux/futex.h
> +++ b/include/linux/futex.h
> @@ -178,6 +178,7 @@ union futex_key {
>  #define FUTEX_KEY_INIT (union futex_key) { .both = { .ptr = NULL } }
>  
>  #ifdef CONFIG_FUTEX
> +extern long do_set_robust_list(struct robust_list_head __user *head, size_t len);
>  extern void exit_robust_list(struct task_struct *curr);
>  extern void exit_pi_state_list(struct task_struct *curr);
>  extern int futex_cmpxchg_enabled;
> diff --git a/kernel/futex.c b/kernel/futex.c
> index f405c73..cf80e7c 100644
> --- a/kernel/futex.c
> +++ b/kernel/futex.c
> @@ -1680,13 +1680,7 @@ pi_faulted:
>   * the list. There can only be one such pending lock.
>   */
>  
> -/**
> - * sys_set_robust_list - set the robust-futex list head of a task
> - * @head: pointer to the list-head
> - * @len: length of the list-head, as userspace expects
> - */
> -SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
> -		size_t, len)
> +long do_set_robust_list(struct robust_list_head __user *head, size_t len)
>  {
>  	if (!futex_cmpxchg_enabled)
>  		return -ENOSYS;
> @@ -1702,6 +1696,17 @@ SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
>  }
>  
>  /**
> + * sys_set_robust_list - set the robust-futex list head of a task
> + * @head: pointer to the list-head
> + * @len: length of the list-head, as userspace expects
> + */
> +SYSCALL_DEFINE2(set_robust_list, struct robust_list_head __user *, head,
> +		size_t, len)
> +{
> +	return do_set_robust_list(head, len);
> +}
> +
> +/**
>   * sys_get_robust_list - get the robust-futex list head of a task
>   * @pid: pid of the process [zero for current task]
>   * @head_ptr: pointer to a list-head pointer, the kernel fills it in
> diff --git a/kernel/futex_compat.c b/kernel/futex_compat.c
> index d607a5b..eac734c 100644
> --- a/kernel/futex_compat.c
> +++ b/kernel/futex_compat.c
> @@ -114,9 +114,9 @@ void compat_exit_robust_list(struct task_struct *curr)
>  	}
>  }
>  
> -asmlinkage long
> -compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
> -			   compat_size_t len)
> +long
> +do_compat_set_robust_list(struct compat_robust_list_head __user *head,
> +			  compat_size_t len)
>  {
>  	if (!futex_cmpxchg_enabled)
>  		return -ENOSYS;
> @@ -130,6 +130,13 @@ compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
>  }
>  
>  asmlinkage long
> +compat_sys_set_robust_list(struct compat_robust_list_head __user *head,
> +			   compat_size_t len)
> +{
> +	return do_compat_set_robust_list(head, len);
> +}
> +
> +asmlinkage long
>  compat_sys_get_robust_list(int pid, compat_uptr_t __user *head_ptr,
>  			   compat_size_t __user *len_ptr)
>  {
> 
