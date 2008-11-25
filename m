From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add support for in-kernel process creation during
	restart
Date: Tue, 25 Nov 2008 15:17:56 -0500
Message-ID: <492C5D74.7040302__9003.75106507472$1227644502$gmane$org@cs.columbia.edu>
References: <1227541175-30301-1-git-send-email-major@openvz.org>
	<1227541175-30301-2-git-send-email-major@openvz.org>
	<1227541175-30301-3-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227541175-30301-3-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

Andrey Mirkin wrote:
> All work (process tree creation and process state restore) now can be
> done in kernel.
> 
> Task structure in image file is extended with 2 fields to make in-kernel
> process creation more easy.
> 
> Signed-off-by: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> ---
>  checkpoint/checkpoint.c        |   17 ++++
>  checkpoint/restart.c           |    4 +-
>  checkpoint/rstr_process.c      |  201 +++++++++++++++++++++++++++++++++++++++-
>  include/linux/checkpoint.h     |    2 +
>  include/linux/checkpoint_hdr.h |    2 +
>  5 files changed, 223 insertions(+), 3 deletions(-)
> 
> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index 04b0c4a..ae3326e 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -173,6 +173,21 @@ static int cr_write_tail(struct cr_ctx *ctx)
>  	return ret;
>  }
>  
> +static int cr_count_children(struct cr_ctx *ctx, struct task_struct *tsk)
> +{
> +	int num = 0;
> +	struct task_struct *child;
> +
> +	read_lock(&tasklist_lock);
> +	list_for_each_entry(child, &tsk->children, sibling) {
> +		if (child->parent != tsk)
> +			continue;
> +		num++;
> +	}
> +	read_unlock(&tasklist_lock);
> +	return num;
> +}
> +

This information (and the pids of children) is already available in
the ctx->pids_arr.

>  /* dump the task_struct of a given task */
>  static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
>  {
> @@ -189,6 +204,8 @@ static int cr_write_task_struct(struct cr_ctx *ctx, struct task_struct *t)
>  	hh->exit_code = t->exit_code;
>  	hh->exit_signal = t->exit_signal;
>  
> +	hh->vpid = task_pid_nr_ns(t, ctx->root_nsproxy->pid_ns);
> +	hh->children_nr = cr_count_children(ctx, t);
>  	hh->task_comm_len = TASK_COMM_LEN;

Same here (hmm... well, if it weren't skipped below, actually...)

>  
>  	/* FIXME: save remaining relevant task_struct fields */
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c

[...]

> +static int restart_thread(void *arg)
> +{
> +	struct thr_context *thr_ctx = arg;
> +	struct cr_ctx *ctx;
> +	struct cr_hdr_task *ht;
> +	int ret;
> +	int i;
> +
> +	current->state = TASK_UNINTERRUPTIBLE;

Why do you not want it to be interruptible ?

> +
> +	ctx = thr_ctx->ctx;
> +	ht = thr_ctx->ht;
> +
> +	if (ht->vpid == 1) {
> +		ctx->root_task = current;
> +		ctx->root_nsproxy = current->nsproxy;
> +
> +		get_task_struct(ctx->root_task);
> +		get_nsproxy(ctx->root_nsproxy);
> +	}
> +
> +	ret = cr_rstr_task_struct(ctx, ht);
> +	cr_debug("rstr_task_struct: ret %d\n", ret);
> +	if (ret < 0)
> +		goto out;
> +	ret = cr_read_mm(ctx);
> +	cr_debug("memory: ret %d\n", ret);
> +	if (ret < 0)
> +		goto out;
> +	ret = cr_read_files(ctx);
> +	cr_debug("files: ret %d\n", ret);
> +	if (ret < 0)
> +		goto out;
> +	ret = cr_read_thread(ctx);
> +	cr_debug("thread: ret %d\n", ret);
> +	if (ret < 0)
> +		goto out;
> +	ret = cr_read_cpu(ctx);
> +	cr_debug("cpu: ret %d\n", ret);
> +
> +	for (i = 0; i < ht->children_nr; i++) {
> +		ret = cr_restart_process(ctx);
> +		if (ret < 0)
> +			break;
> +	}

Here, eventually we'll need the pids of those processes; instead of
keeping 'ht->children_nr', you could loop through the pids array in
the ctx and create those who have their parent set to us.

> +
> +out:
> +	thr_ctx->error = ret;
> +	complete(&thr_ctx->complete);
> +
> +	if (!ret && (ht->state & (EXIT_ZOMBIE|EXIT_DEAD))) {
> +		do_exit(ht->exit_code);
> +	} else {
> +		__set_current_state(TASK_UNINTERRUPTIBLE);
> +	}
> +	schedule();

Using TASK_UNINTERRUPTIBLE, may keep a task unkill-able for potentially
long time. Any reason not to use TASK_INTERRUPTIBLE ?

> +
> +	cr_debug("leaked %d/%d %p\n", task_pid_nr(current), task_pid_vnr(current), current->mm);
> +
> +	complete_and_exit(NULL, 0);
> +	return ret;
> +}
> +
> +static int cr_restart_process(struct cr_ctx *ctx)
> +{
> +	struct thr_context thr_ctx;
> +	struct task_struct *tsk;
> +	struct cr_hdr_task *ht = cr_hbuf_get(ctx, sizeof(*ht));
> +	int pid, parent, ret = -EINVAL;
> +
> +	thr_ctx.ctx = ctx;
> +	thr_ctx.error = 0;
> +	init_completion(&thr_ctx.complete);
> +
> +	parent = cr_read_obj_type(ctx, ht, sizeof(*ht), CR_HDR_TASK);
> +	if (parent < 0) {
> +		ret = parent;
> +		goto out;
> +	} else if (parent != 0)
> +		goto out;
> +
> +	thr_ctx.ht = ht;
> +
> +	if (ht->vpid == 1) {
> +		/* We should also create container here */
> +		pid = cr_kernel_thread(restart_thread, &thr_ctx,
> +				CLONE_NEWNS | CLONE_NEWUTS | CLONE_NEWIPC |
> +				CLONE_NEWUSER | CLONE_NEWPID | CLONE_NEWNET, 0);

why do you want to start the container in the kernel ?

instead, we can create a new containers in user space, and have the init task
call the restart syscall from inside there.


> +	} else {
> +		/* We should fork here a child with saved pid and
> +		   correct flags */
> +		pid = cr_kernel_thread(restart_thread, &thr_ctx, 0, ht->vpid);
> +	}
> +	if (pid < 0) {
> +		ret = pid;
> +		goto out;
> +	}
> +	read_lock(&tasklist_lock);
> +	tsk = find_task_by_vpid(pid);
> +	if (tsk)
> +		get_task_struct(tsk);
> +	read_unlock(&tasklist_lock);
> +	if (tsk == NULL) {
> +		ret = -ESRCH;
> +		goto out;
> +	}
> +
> +	wait_for_completion(&thr_ctx.complete);
> +	wait_task_inactive(tsk, 0);
> +	ret = thr_ctx.error;
> +	put_task_struct(tsk);
> +
> +out:
> +	cr_hbuf_put(ctx, sizeof(*ht));
> +	return ret;
> +}
> +
>  
>  int do_restart_in_kernel(struct cr_ctx *ctx)
>  {
> -	return -ENOSYS;
> +	int ret, size, parent;
> +	struct cr_hdr_tree *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +
> +	ret = cr_read_head(ctx);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = -EINVAL;
> +	parent = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_TREE);
> +	if (parent < 0) {
> +		ret = parent;
> +		goto out;
> +	} else if (parent != 0)
> +		goto out;
> +
> +	size = sizeof(*ctx->pids_arr) * hh->tasks_nr;
> +	if (size < 0)
> +		goto out;
> +	ctx->file->f_pos += size;

You can't do that - the file may be non-seekable (e.g. a socket); must read
the data in.
Besides, if instead of skipping this data you read it in, then you could use
it as noted above.

> +
> +	ret = cr_restart_process(ctx);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = cr_read_tail(ctx);

[...]

Thanks,

Oren.
