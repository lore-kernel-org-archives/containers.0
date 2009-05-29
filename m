From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7][v2] Define clone_with_pids syscall
Date: Fri, 29 May 2009 01:29:05 -0400
Message-ID: <4A1F72A1.4070103@cs.columbia.edu>
References: <20090528043748.GA16522@us.ibm.com>
	<20090528043945.GG16522@us.ibm.com>
	<4A1EA73F.1080802@cs.columbia.edu>
	<20090528173019.GB26183@us.ibm.com>
	<4A1F228C.2020201@cs.columbia.edu>
	<20090529030558.GA2548@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090529030558.GA2548-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Here is an updated patch with hopefully some useful comments on why
> we copy to the end of target_pids[] (comments were harder to write
> than the code :-)
> 
> ---
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Mon, 4 May 2009 01:17:45 -0700
> Subject: [PATCH 7/7] Define clone_with_pids syscall
> 
> Container restart requires that a task have the same pid it had when it was
> checkpointed. When containers are nested the tasks within the containers
> exist in multiple pid namespaces and hence have multiple pids to specify
> during restart.
> 
> clone_with_pids(), intended for use during restart, is the same as clone(),
> except that it takes a 'target_pid_set' paramter. This parameter lets caller
> choose specific pid numbers for the child process, in the process's active
> and descendant pid namespaces. Since the application does/can not know of any
> ancestor pid namespaces, it cannot choose a pid in those namespaces.

I think the term "descendant pid namespaces" is confusing, because it
can be interpreted as the collection of all descendant namespaces (e.g.
by all children of a task), which is a tree. And I'm unsure what does
"ancestor pid namespaces" mean.

I'd say that both "descendant" and "ancestor" here are defined with
respect to the nesting level of root task of a restart. Or otherwise
say explicitly that it's relative to the nesting level at which the
restart operation occurs.

In my mind, clone_with_pid() is performed from "within" the deepest
level - in which the child will "live" - and the pids array then
works "bottom-up" in the sense that it indicates the desired pids
as you go up the ancestry chain (going up is always well defined).

Right now the restart with a flat pid-ns works by first devising a
schedule and then following that schedule with forks/clones to
generate a process tree.

To also restore pids, we need only use clone_with_pid() with an array
of size 1, and we're good.

To restart nested pid-ns from userspace, we need to devise a schedule
that will command a sequence of fork/clones. The schedule will tell
when to use the CLONE_NEWPID to create a sub-pid-ns. When that happens,
we'll increment the size of the pids array - for that clone and all
subsequent clones by that task and its descendents.

So the clone_with_pids occurs in the context of the deepest pid-ns, so
to speak, and the arrays of pids works its way "upwards"

(That's probably what you meant, anyway).

> 
> Unlike clone(), clone_with_pids() needs CAP_SYS_ADMIN, at least for now, to
> prevent unprivileged processes from misusing this interface.
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
> 	- May need additional sanity checks in do_fork_with_pids().
> 	- Allow CLONE_NEWPID() with clone_with_pids() (ensure target-pid in
> 	  the namespace is either 1 or 0).
> 
> Changelog[v2]:
> 	- (Oren Laadan) Specified target pids should apply to youngest
> 	  pid-namespaces only (see comments in copy_target_pids())
> 	- Remove unnecessary printk and add a note to callers of
> 	  copy_target_pids() to free target_pids.
> 	- (Matt Helsley) Update patch description.
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
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---

[...]


> diff --git a/kernel/fork.c b/kernel/fork.c
> index a16ef7b..06b1583 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1335,6 +1335,84 @@ struct task_struct * __cpuinit fork_idle(int cpu)
>  }
>  
>  /*
> + * If user specified any 'target-pids' in @upid_setp, copy them from
> + * user and return a pointer to a local copy of the list of pids. The
> + * caller must free the list, when they are done using it.
> + *
> + * If user did not specify any target pids, return NULL (caller should
> + * treat this like normal clone).
> + *
> + * On any errors, return the error code
> + */
> +static pid_t *copy_target_pids(void __user *upid_setp)
> +{
> +	int j;
> +	int rc;
> +	int size;
> +	int num_pids;
> +	int nesting;
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
> +	nesting = task_pid(current)->level + 1;

I should have mentioned earlier, but there is also the case of
CLONE_NEWPID. If CLONE_NEWPID is given, then @nesting should be
plus one, _and_ the corresponding pid must be 1 or 0.

And this consideration deserves fat comment :)

> +
> +	if (!num_pids)
> +		return NULL;
> +
> +	if (num_pids < 0 || num_pids > nesting)
> +		return ERR_PTR(-EINVAL);
> +
> +	target_pids = kzalloc((nesting * sizeof(pid_t)), GFP_KERNEL);
> +	if (!target_pids)
> +		return ERR_PTR(-ENOMEM);
> +
> +	/*
> +	 * A process running in a level-1 pid namespace has two pid
> +	 * namespaces and hence two pid numbers. If this process is
> +	 * checkpointed, information about these two namespaces are
> +	 * saved. We refer to these namespaces as 'known namespaces'.
> +	 *
> +	 * If this checkpointed process is however restarted in a 
> +	 * level-2 pid namespace, the restarted process has an extra
> +	 * ancestor pid namespace (i.e 'unknown namespace').
> +	 *
> +	 * During restart, the process requests specific pids for its
> +	 * 'known namespaces' and lets kernel assign pids to its 'unknown
> +	 * namespaces'. 
> +	 *
> +	 * Since the requested-pids correspond to 'known namespaces' and
> +	 * since 'known-namespaces' are younger than (i.e descendants of)
> +	 * 'unknown-namespaces', copy requested pids to end of target_pids[]
> +	 * and copy zeroes to the beginning (so kernel can assign a pid for
> +	 * the unknown namespaces).
> +	 *
> +	 * NOTE: The order of pids in target_pids[] is oldest pid namespace
> +	 * 	 to youngest (i.e target_pids[0] corresponds to init_pid_ns). 
> +	 */

Reads good!

[...]

Oren.
