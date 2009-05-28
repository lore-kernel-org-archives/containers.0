From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7][v2] Define clone_with_pids syscall
Date: Thu, 28 May 2009 11:01:19 -0400
Message-ID: <4A1EA73F.1080802@cs.columbia.edu>
References: <20090528043748.GA16522@us.ibm.com>
	<20090528043945.GG16522@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090528043945.GG16522-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Subject: [RFC][PATCH 7/7][v2] Define clone_with_pids syscall
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
> 	1. clone_with_pids(), at least for now, needs CAP_SYS_ADMIN to prevent
> 	   misuse of the interface.
> 	   
> 	2. Compared to clone(), clone_with_pids() needs to pass in two more
> 	   pieces of information:
> 
> 		- number of pids in the set
> 		- user buffer containing the list of pids.
> 
> 	   But since clone() already takes 5 parameters, use a 'struct
> 	   target_pid_set'.
> 
> TODO:
> 	- Gently tested.
> 	- May need additional sanity checks in do_fork_with_pids().
> 	- Allow CLONE_NEWPID() with clone_with_pids() (ensure target-pid in
> 	  the namespace is either 1 or 0).
> 
> Changelog[v2]:
> 	- (Serge Hallyn) Mention CAP_SYS_ADMIN restriction in patch description.
> 	- (Oren Laadan) Add checks for 'num_pids < 0' (return -EINVAL) and
> 	  'num_pids == 0' (fall back to normal clone()).
> 	- Move arch-independent code (sanity checks and copy-in of target-pids)
> 	  into kernel/fork.c and simplify sys_clone_with_pids()
> 
> Changelog[v1]:
> 	- Fixed some compile errors (had fixed these errors earlier in my
> 	  git tree but had not refreshed patches before emailing them)
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

[...]

> index a16ef7b..f265a18 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1335,6 +1335,58 @@ struct task_struct * __cpuinit fork_idle(int cpu)
>  }
>  
>  /*
> + * If user specified any 'target-pids' in @upid_setp, copy them from
> + * user and return a pointer to the list of target pids.
> + *
> + * If user did not specify any target pids, return NULL (caller should
> + * treat this like normal clone).
> + *
> + * On any errors, return the error code
> + */
> +static pid_t *copy_target_pids(void __user *upid_setp)
> +{
> +	int rc;
> +	int size;
> +	int num_pids;
> +	pid_t __user *utarget_pids;
> +	pid_t *target_pids;
> +	struct target_pid_set pid_set;
> +
> +	if(!upid_setp)
> +		return NULL;
> +
> +	if (copy_from_user(&pid_set, upid_setp, sizeof(pid_set)))
> +		return ERR_PTR(-EFAULT);
> +
> +	num_pids = pid_set.num_pids;
> +	utarget_pids = pid_set.target_pids;
> +	size = num_pids * sizeof(pid_t);
> +
> +	if (!num_pids)
> +		return NULL;
> +
> +	if (num_pids < 0 || num_pids > task_pid(current)->level + 1)
> +		return ERR_PTR(-EINVAL);

What happens if (num_pids < task_pid(current->level) + 1) ?
Unless I missed something elsewhere, I suspect it will oops,
because in patch #4, you had:

 	for (i = ns->level; i >= 0; i--) {
-		nr = alloc_pidmap(tmp, 0);
+		tpid = 0;
+		if (target_pids)
+			tpid = target_pids[i];
+
+		nr = alloc_pidmap(tmp, tpid);
 		if (nr < 0)
 			goto out_free;

In general, can a task figure out it's depth in the pid-ns hierarchy ?

I'm thinking of a case in which a checkpoint was taken of a (flat)
container which is in depth 2 of the global hierarchy, and then it
is restarted in depth 3, or in depth 1.

Perhaps the semantics of the syscall should be that target_pids will
indicate the desired pids _from the bottom up_. A value of "0" means
"don't care" and let the kernel assign. The remaining levels (upwards)
will be treated as zeros.

[...]

Oren.
