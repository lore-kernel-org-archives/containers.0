From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 7/7] [PATCH] Define clone_with_pids syscall
Date: Wed, 27 May 2009 15:53:43 -0400
Message-ID: <4A1D9A47.6030201@cs.columbia.edu>
References: <20090527154212.GA3107@us.ibm.com>
	<20090527154507.GG3107@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090527154507.GG3107-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Sukadev Bhattiprolu wrote:
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Mon, 4 May 2009 01:17:45 -0700
> Subject: [PATCH 7/7] [PATCH] Define clone_with_pids syscall
> 
> clone_with_pids() is same as clone(), except that it takes a 'target_pid_set'
> paramter which lets caller choose a specific pid number for the child process
> in each of the child process's pid namespace. This system call would be needed
> to implement Checkpoint/Restart (i.e after a checkpoint, restart a process with
> its original pids).
> 
> Call clone_with_pids as follows:
> 
> 	pid_t pids[] = { 0, 77, 99 };
> 	struct target_pid_set pid_set;
> 
> 	pid_set.num_pids = sizeof(pids) / sizeof(int);
> 	pid_set.target_pids = &pids;
> 
> 	syscall(__NR_clone_with_pids, flags, stack, NULL, NULL, NULL, &pid_set);
> 
> If a target-pid is 0, the kernel continues to assign a pid for the process in
> that namespace. In the above example, pids[0] is 0, meaning the kernel will
> assign next available pid to the process in init_pid_ns. But kernel will assign
> pid 77 in the child pid namespace 1 and pid 99 in pid namespace 2. If either
> 77 or 99 are taken, the system call fails with -EBUSY.
> 
> If 'pid_set.num_pids' exceeds the current nesting level of pid namespaces,
> the system call fails with -EINVAL.
> 
> Its mostly an exploratory patch seeking feedback on the interface.
> 
> NOTE:
> 	Compared to clone(), clone_with_pids() needs to pass in two more
> 	pieces of information:
> 
> 		- number of pids in the set
> 		- user buffer containing the list of pids.
> 
> 	But since clone() already takes 5 parameters, use a 'struct
> 	target_pid_set'.
> 
> TODO:
> 	- Gently tested.
> 	- May need additional sanity checks in check_target_pids()
> 	- Allow CLONE_NEWPID() with clone_with_pids() (ensure target-pid in
> 	  the namespace is either 1 or 0).
> 
> Changelog[v1]:
> 	- Fixed some compile errors (had fixed these errors earlier in my
> 	  git tree but had not refreshed patches before emailing them)
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---

Reviewed-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

but ...

[...]

> +static pid_t *copy_target_pids(unsigned long clone_flags, void __user *upid_setp)
> +{
> +	int rc;
> +	int size;
> +	pid_t __user *utarget_pids;
> +	pid_t *target_pids;
> +	struct target_pid_set pid_set;
> +
> +	if (copy_from_user(&pid_set, upid_setp, sizeof(pid_set)))
> +		return ERR_PTR(-EFAULT);
> +
> +	size = pid_set.num_pids * sizeof(pid_t);

...either test "pid_set.num_pids > 0" (and give -EINVAL),
or...

[...]

>  
> +struct target_pid_set {
> +	int num_pids;

... make this 'size_t' ?


> +	pid_t *target_pids;
> +};
> +
>  #endif	/* __KERNEL__ */
>  #endif /*  __ASSEMBLY__ */
>  #endif /* _LINUX_TYPES_H */
