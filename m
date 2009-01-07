From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v12][PATCH 14/14] Restart multiple processes
Date: Tue, 06 Jan 2009 22:20:59 -0500
Message-ID: <49641F9B.9020803__15813.7178318158$1231298646$gmane$org@cs.columbia.edu>
References: <1230542187-10434-1-git-send-email-orenl@cs.columbia.edu>
	<1230542187-10434-15-git-send-email-orenl@cs.columbia.edu>
	<20090104201957.GA12725@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090104201957.GA12725-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org



Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> Restarting of multiple processes expects all restarting tasks to call
>> sys_restart(). Once inside the system call, each task will restart
>> itself at the same order that they were saved. The internals of the
>> syscall will take care of in-kernel synchronization bewteen tasks.

[...]

> Thanks, Oren.
> 
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> with a few comments below.

Thanks for the comments.

[...]

>> +/* FIXME: this should be per container */
>> +DECLARE_WAIT_QUEUE_HEAD(cr_restart_waitq);
>> +
>> +static int do_restart_task(struct cr_ctx *ctx, pid_t pid)
> 
> Passing ctx in here, when it is always NULL, is just a bit
> confusing, and, since you goto out and cr_ctx_put(ctx) without
> initializing ctx, you make verifying that that's ok a step
> harder.
> 
> Do you intend to ever pass in non-NULL in later patches?

Yes; for instance I expect Andrey's create-tasks-in-kernel patch
(when ready) to eventually have each thread call do_restart_task().
I also liked the symmetry with do_restart_root()...

You are correct that it's confusing now, so I'll take it out.

> 
>> +{
>> +	struct task_struct *root_task;
>> +	int ret;
>> +
>> +	rcu_read_lock();
>> +	root_task = find_task_by_pid_ns(pid, current->nsproxy->pid_ns);
>> +	if (root_task)
>> +		get_task_struct(root_task);
>> +	rcu_read_unlock();
>> +
>> +	if (!root_task)
>> +		return -EINVAL;
>> +
>> +	/*
>> +	 * wait for container init to initialize the restart context, then
>> +	 * grab a reference to that context, and if we're the last task to
>> +	 * do it, notify the container init.
>> +	 */
>> +	ret = wait_event_interruptible(cr_restart_waitq,
>> +				       root_task->checkpoint_ctx);
> 
> Would seem more sensible to do the above using the ctx which
> you grabbed under task_lock(root_task) next.  Your whole
> locking of root_task->checkpoint_ctx seems haphazard (see below).

At this point 'root_task->checkpoint_ctx' may still be NULL if the
container init did not yet initialize it. That's why we first wait
for it to become non-NULL.

The code solves a coordination problem between the container init and
the other tasks, given that:
a) the order in which they call sys_restart() is unknown
b) the container init creates a 'ctx' that is to be used by everyone

The container init simply (1) allocates a shared 'ctx' and makes it
visible via 'root_task->chcekpoint_ctx', then waits for all tasks to
grab it (thus, be ready to restart), then initiates the restart chain,
and finally waits for all tasks to finish.

The other tasks, because of (a) and (b), may enter the kernel before
the container init completes its step (1). So they must first wait
for that 'ctx' to be available

> 
>> +	if (ret < 0)
>> +		goto out;
>> +
>> +	task_lock(root_task);
>> +	ctx = root_task->checkpoint_ctx;
>> +	if (ctx)
>> +		cr_ctx_get(ctx);
>> +	task_unlock(root_task);

So the other tasks work in two steps:
1) wait for the container init ->checkpoint_ctx (we don't know when !)
2) grab a reference to that 'ctx'

Step (2) ensures that our reference to 'ctx' is valid even if the
container init exits (due to error, signal etc). The last user of
the 'ctx' will be the one to actually free it.

I use the lock to protect against time-of-check to time-of-use race
(e.g.the container init may exit due to an error or a signal); the
container init also grabs the lock before clearing its ->checkpoint_ctx.

>> +
>> +	if (!ctx) {
>> +		ret = -EAGAIN;
>> +		goto out;
>> +	}
>> +
>> +	if (atomic_dec_and_test(&ctx->tasks_count))
>> +		complete(&ctx->complete);
>> +
>> +	/* wait for our turn, do the restore, and tell next task in line */
>> +	ret = cr_wait_task(ctx);
>> +	if (ret < 0)
>> +		goto out;
>> +	ret = cr_read_task(ctx);
>> +	if (ret < 0)
>> +		goto out;
>> +	ret = cr_next_task(ctx);
>> +
>> + out:
>> +	cr_ctx_put(ctx);
>> +	put_task_struct(root_task);
>> +	return ret;
>> +}
>> +
>> +static int cr_wait_all_tasks_start(struct cr_ctx *ctx)
>> +{
>> +	int ret;
>> +
>> +	if (ctx->pids_nr == 1)
>> +		return 0;
>> +
>> +	init_completion(&ctx->complete);
>> +	current->checkpoint_ctx = ctx;
>> +
>> +	wake_up_all(&cr_restart_waitq);
>> +
>> +	ret = wait_for_completion_interruptible(&ctx->complete);
>> +	if (ret < 0)
>> +		return ret;
>> +
>> +	task_lock(current);
>> +	current->checkpoint_ctx = NULL;
>> +	task_unlock(current);
> 
> Who can you be racing with here?  All other tasks should have
> already dereferenced current->checkpoint_ctx.
> 
> If you want to always lock root_task around setting and
> reading of (root_task|current)->checkpoint_ctx, that's
> ok, but I think you can sufficiently argue that your
> completion is completely protecint readers from the sole
> writer.

Only lock around clearing and reading; setting is safe.

The completion is interruptible so that you can signal or kill
the container init if something goes wrong, e.g. bad checkpoint
image causes it to wait for non-existing processes forever.

At a second glance, the clearing of '->checkpoint_ctx' must
happen regardless of whether an error occurred, so the test for
'ret < 0' should follow (and not precede) it.

[...]

Thanks,

Oren.
