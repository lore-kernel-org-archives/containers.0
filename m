From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [v10][PATCH 8/9] Define clone_with_pids() syscall
Date: Mon, 02 Nov 2009 13:09:59 -0500
Message-ID: <4AEF2077.5080107@librato.com>
References: <20091101204132.GA22116@us.ibm.com>
	<20091101204548.GG23168@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091101204548.GG23168-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org



Sukadev Bhattiprolu wrote:
> From: Sukadev Bhattiprolu <suka@suka.(none)>
> Date: Tue, 20 Oct 2009 22:04:57 -0700
> Subject: [v10][PATCH 8/9] Define clone_with_pids() syscall

[...]

> diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
> index 4cf7956..41081eb 100644
> --- a/arch/x86/kernel/process_32.c
> +++ b/arch/x86/kernel/process_32.c
> @@ -445,6 +445,69 @@ int sys_clone(struct pt_regs *regs)
>  	return do_fork(clone_flags, newsp, regs, 0, parent_tidptr, child_tidptr);
>  }
>  
> +int sys_clone_with_pids(struct pt_regs *regs)
> +{
> +	int rc;
> +	struct clone_args kcs;
> +	unsigned long flags;
> +	int __user *parent_tid_ptr;
> +	int __user *child_tid_ptr;
> +	unsigned long __user child_stack;
> +	unsigned long stack_size;
> +	unsigned int flags_low;
> +	struct clone_args __user *ucs;
> +	pid_t __user *pids;
> +
> +	flags_low = regs->bx;
> +	ucs = (int __user *)regs->cx;
> +	pids = (int __user *)regs->dx;
> +
> +	rc = copy_from_user(&kcs, ucs, sizeof(kcs));
> +	if (rc)
> +		return -EFAULT;
> +
> +	/*
> +	 * TODO: If size of clone_args is not what the kernel expects, it
> +	 * 	 could be that kernel is newer and has an extended structure.
> +	 * 	 When that happens, this check needs to be smarter (and we
> +	 * 	 need an additional copy_from_user()). For now, assume exact
> +	 * 	 match.
> +	 */
> +	if (kcs.clone_args_size != sizeof(kcs))
> +		return -EINVAL;

I wonder if this is a reason to move the clone_args_size outside the
structure and pass it as a regular argument ?  This will rid the
(futuristic) additional copy-from-user (in case it causes a concern
for clone performance ?)

Oren.
