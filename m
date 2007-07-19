From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 5/5] [V2] Move alloc_pid() to copy_process()
Date: Thu, 19 Jul 2007 11:44:47 +0400
Message-ID: <469F166F.9000501@openvz.org>
References: <20070719071206.GE10195@us.ibm.com>
	<20070719072240.GE28216@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070719072240.GE28216-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Andrew Morton <akpm-3NddpPZAyC0@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> 
> Subject: [PATCH 5/5] Move alloc_pid call to copy_process
> 
> From: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Move alloc_pid() into copy_process(). This will keep all pid and pid
> namespace code together and simplify error handling when we support
> multiple pid namespaces.

I would add smth like this to the comment:

When a task creates a new pid namespace, its init (i.e. this task's
child) will have pids with extra info inside - the new numerical id,
that represent this new task in this new namespace. Thus, we have 
to allocate this new pid only after the namespace creation to find 
out which namespace this pid will live in.

Hope, I expressed my idea cleanly.

Acked-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Cc: Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Cc: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> Cc: Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Herbert Poetzel <herbert-dBHVzrDq9nF4Lj/PQRBjDg@public.gmane.org>
> ---
>  kernel/fork.c |   19 +++++++++++++------
>  1 file changed, 13 insertions(+), 6 deletions(-)
> 
> Index: lx26-22-rc6-mm1a/kernel/fork.c
> ===================================================================
> --- lx26-22-rc6-mm1a.orig/kernel/fork.c	2007-07-16 12:55:13.000000000 -0700
> +++ lx26-22-rc6-mm1a/kernel/fork.c	2007-07-17 10:08:12.000000000 -0700
> @@ -1029,6 +1029,12 @@ static struct task_struct *copy_process(
>  	if (p->binfmt && !try_module_get(p->binfmt->module))
>  		goto bad_fork_cleanup_put_domain;
>  
> +	if (pid != &init_struct_pid) {
> +		pid = alloc_pid();
> +		if (!pid)
> +			goto bad_fork_put_binfmt_module;
> +	}
> +
>  	p->did_exec = 0;
>  	delayacct_tsk_init(p);	/* Must remain after dup_task_struct() */
>  	copy_flags(clone_flags, p);
> @@ -1316,6 +1322,9 @@ bad_fork_cleanup_container:
>  #endif
>  	container_exit(p, container_callbacks_done);
>  	delayacct_tsk_free(p);
> +	if (pid != &init_struct_pid)
> +		free_pid(pid);
> +bad_fork_put_binfmt_module:
>  	if (p->binfmt)
>  		module_put(p->binfmt->module);
>  bad_fork_cleanup_put_domain:
> @@ -1380,19 +1389,16 @@ long do_fork(unsigned long clone_flags,
>  {
>  	struct task_struct *p;
>  	int trace = 0;
> -	struct pid *pid = alloc_pid();
>  	long nr;
>  
> -	if (!pid)
> -		return -EAGAIN;
> -	nr = pid->nr;
>  	if (unlikely(current->ptrace)) {
>  		trace = fork_traceflag (clone_flags);
>  		if (trace)
>  			clone_flags |= CLONE_PTRACE;
>  	}
>  
> -	p = copy_process(clone_flags, stack_start, regs, stack_size, parent_tidptr, child_tidptr, pid);
> +	p = copy_process(clone_flags, stack_start, regs, stack_size,
> +			parent_tidptr, child_tidptr, NULL);
>  	/*
>  	 * Do this prior waking up the new thread - the thread pointer
>  	 * might get invalid after that point, if the thread exits quickly.
> @@ -1400,6 +1406,8 @@ long do_fork(unsigned long clone_flags,
>  	if (!IS_ERR(p)) {
>  		struct completion vfork;
>  
> +		nr = pid_nr(task_pid(p));
> +
>  		if (clone_flags & CLONE_VFORK) {
>  			p->vfork_done = &vfork;
>  			init_completion(&vfork);
> @@ -1433,7 +1441,6 @@ long do_fork(unsigned long clone_flags,
>  			}
>  		}
>  	} else {
> -		free_pid(pid);
>  		nr = PTR_ERR(p);
>  	}
>  	return nr;
> 
