From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add support for the per-task sem_undo list (v2)
Date: Wed, 04 Aug 2010 14:49:09 -0400
Message-ID: <4C59B625.7000007@cs.columbia.edu>
References: <1280941345-27566-1-git-send-email-danms@us.ibm.com>
	<1280941345-27566-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280941345-27566-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org



On 08/04/2010 01:02 PM, Dan Smith wrote:
> The semaphore undo list is a set of adjustments to be made to semaphores
> held by a task on exit.  Right now, we do not checkpoint or restore this
> list which could cause undesirable behavior by a restarted process on exit.
>
> Changes in v2:
>   - Remove collect operation
>   - Add a BUILD_BUG_ON() to ensure sizeof(short) == sizeof(__u16)
>   - Use sizeof(__u16) when copying to/from checkpoint header
>   - Fix a couple of leaked hdr objects
>   - Avoid reading the semadj buffer with rcu_read_lock() held
>   - Set the sem_undo pointer on tasks other than the first to restore a list
>   - Fix refcounting on restart
>   - Pull out the guts of exit_sem() into put_undo_list() and call that
>     from our drop() function in case we're the last one.
>
> Signed-off-by: Dan Smith<danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Looks better. Still some more comments...

> ---
>   include/linux/checkpoint.h     |    4 +
>   include/linux/checkpoint_hdr.h |   18 ++
>   ipc/sem.c                      |  342 +++++++++++++++++++++++++++++++++++++++-
>   kernel/checkpoint/process.c    |   13 ++
>   4 files changed, 369 insertions(+), 8 deletions(-)
>
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 4e25042..34e81f4 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -271,6 +271,10 @@ extern int ckpt_collect_fs(struct ckpt_ctx *ctx, struct task_struct *t);
>   extern int checkpoint_obj_fs(struct ckpt_ctx *ctx, struct task_struct *t);
>   extern int restore_obj_fs(struct ckpt_ctx *ctx, int fs_objref);
>
> +/* per-task semaphore undo */
> +int checkpoint_obj_sem_undo(struct ckpt_ctx *ctx, struct task_struct *t);
> +int restore_obj_sem_undo(struct ckpt_ctx *ctx, int sem_undo_objref);

Please add "extern" here (been burned before)

[...]

> +static int obj_sem_undo_grab(void *ptr)
> +{
> +	struct sem_undo_list *ulp = ptr;
> +
> +	atomic_inc(&ulp->refcnt);
> +	return 0;
> +}
> +
> +static void put_undo_list(struct sem_undo_list *ulp);

nit: to me it makes more sense to move grab/drop/checkpoint/restart
code, as well sem_init(), to the end of the file (and avoid those
statics...).

> +static void obj_sem_undo_drop(void *ptr, int lastref)
> +{
> +	struct sem_undo_list *ulp = ptr;
> +
> +	put_undo_list(ulp);
> +}
> +
> +static int obj_sem_undo_users(void *ptr)
> +{
> +	struct sem_undo_list *ulp = ptr;
> +
> +	return atomic_read(&ulp->refcnt);
> +}

Can get rid of ..._users() since we don't collect them.

> +
> +static void *restore_sem_undo(struct ckpt_ctx *ctx);
> +static int checkpoint_sem_undo(struct ckpt_ctx *ctx, void *ptr);
> +
> +static const struct ckpt_obj_ops ckpt_obj_sem_undo_ops = {
> +	.obj_name = "IPC_SEM_UNDO",
> +	.obj_type = CKPT_OBJ_SEM_UNDO,
> +	.ref_drop = obj_sem_undo_drop,
> +	.ref_grab = obj_sem_undo_grab,
> +	.ref_users = obj_sem_undo_users,

(here too)

> +	.checkpoint = checkpoint_sem_undo,
> +	.restore = restore_sem_undo,
> +};
> +
>   void __init sem_init (void)
>   {
>   	sem_init_ns(&init_ipc_ns);
>   	ipc_init_proc_interface("sysvipc/sem",
>   				"       key      semid perms      nsems   uid   gid  cuid  cgid      otime      ctime\n",
>   				IPC_SEM_IDS, sysvipc_sem_proc_show);
> +
> +	/* sem_undo_list          uses a short
> +	*  ckpt_hdr_task_sem_undo uses a __u16
> +	*/
> +	BUILD_BUG_ON(sizeof(short) != sizeof(__u16));

semadj is short, so:
s/__u16/__s16/

> +
> +	register_checkpoint_obj(&ckpt_obj_sem_undo_ops);
>   }
>
>   /*
> @@ -1363,14 +1407,8 @@ int copy_semundo(unsigned long clone_flags, struct task_struct *tsk)
>    * The current implementation does not do so. The POSIX standard
>    * and SVID should be consulted to determine what behavior is mandated.
>    */
> -void exit_sem(struct task_struct *tsk)
> +static void put_undo_list(struct sem_undo_list *ulp)
>   {
> -	struct sem_undo_list *ulp;
> -
> -	ulp = tsk->sysvsem.undo_list;
> -	if (!ulp)
> -		return;
> -	tsk->sysvsem.undo_list = NULL;
>
>   	if (!atomic_dec_and_test(&ulp->refcnt))
>   		return;
> @@ -1393,7 +1431,7 @@ void exit_sem(struct task_struct *tsk)
>   		if (semid == -1)
>   			break;
>
> -		sma = sem_lock_check(tsk->nsproxy->ipc_ns, un->semid);
> +		sma = sem_lock_check(ulp->ipc_ns, un->semid);

This hunk belongs to previous patch, no ?

[...]

> +int checkpoint_sem_undo_adj(struct ckpt_ctx *ctx, struct sem_undo *un)
> +{
> +	int nsems;
> +	int ret;
> +	short *semadj = NULL;
> +	struct sem_array *sma;
> +	struct ckpt_hdr_task_sem_undo *h = NULL;
> +
> +	sma = sem_lock(ctx->root_nsproxy->ipc_ns, un->semid);
> +	if (IS_ERR(sma)) {
> +		ckpt_debug("unable to lock semid %i (wrong ns?)\n", un->semid);
> +		return PTR_ERR(sma);
> +	}
> +
> +	nsems = sma->sem_nsems;
> +	sem_getref_and_unlock(sma);
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_SEM_UNDO);
> +	if (!h)
> +		goto putref_abort;
> +
> +	semadj = kzalloc(nsems * sizeof(short), GFP_KERNEL);
> +	if (!semadj)
> +		goto putref_abort;
> +
> +	sem_lock_and_putref(sma);
> +
> +	h->semid = un->semid;
> +	h->semadj_count = nsems;
> +	memcpy(semadj, un->semadj, h->semadj_count * sizeof(__u16));

s/u__u16/__s16/

> +
> +	sem_unlock(sma);
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *)h);
> +	if (ret == 0)
> +		ret = ckpt_write_buffer(ctx, semadj, nsems * sizeof(short));

.... s/short/__s16/

[...]

> +static int restore_task_sem_undo_adj(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_task_sem_undo *h;
> +	int len;
> +	int ret = -ENOMEM;
> +	struct sem_undo *un;
> +	int nsems;
> +	short *semadj = NULL;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_SEM_UNDO);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	len = sizeof(__u16) * h->semadj_count;

s/__u16/__s16/

> +	semadj = kzalloc(len, GFP_KERNEL);
> +	if (!semadj)
> +		goto out;
> +
> +	ret = _ckpt_read_buffer(ctx, semadj, len);
> +	if (ret<  0)
> +		goto out;

Use ckpt_read_payload() - it already allocates the payload buffer.

> +
> +	un = find_alloc_undo(current->nsproxy->ipc_ns, h->semid);
> +	if (IS_ERR(un)) {
> +		ret = PTR_ERR(un);
> +		ckpt_debug("unable to find semid %i\n", h->semid);
> +		goto out;
> +	}
> +
> +	nsems = sem_undo_nsems(un, current->nsproxy->ipc_ns);
> +	len = sizeof(short) * nsems;

s/short/__s16/

If nsems > h->semadj_count, we may be accessing bad memory in
the semadj buffer from above, therefore ...

> +	memcpy(un->semadj, semadj, len);
> +	rcu_read_unlock();
> +
> +	if (nsems != h->semadj_count)

... this test should occur before the memcpy() above.

> +		ckpt_err(ctx, -EINVAL,
> +			 "semid %i has nmsems=%i but %i undo adjustments\n",
> +			 h->semid, nsems, h->semadj_count);
> +	else
> +		ckpt_debug("semid %i restored with %i adjustments\n",
> +			   h->semid, h->semadj_count);
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	kfree(semadj);
> +
> +	return ret;
> +}
> +
> +static void *restore_sem_undo(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_task_sem_undo_list *h;
> +	struct sem_undo_list *ulp = NULL;
> +	int i;
> +	int ret = 0;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_SEM_UNDO_LIST);
> +	if (IS_ERR(h))
> +		return ERR_PTR(PTR_ERR(h));
> +
> +	ulp = alloc_undo_list(current->nsproxy->ipc_ns);
> +	if (!ulp) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	for (i = 0; i<  h->count; i++) {
> +		ret = restore_task_sem_undo_adj(ctx);
> +		if (ret<  0)
> +			goto out;
> +	}
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	if (ret<  0)
> +		return ERR_PTR(ret);
> +	else
> +		return ulp;
> +}
> +
> +int restore_obj_sem_undo(struct ckpt_ctx *ctx, int sem_undo_objref)
> +{
> +	struct sem_undo_list *ulp;
> +
> +	if (!sem_undo_objref)
> +		return 0; /* Task had no undo list */
> +
> +	ulp = ckpt_obj_try_fetch(ctx, sem_undo_objref, CKPT_OBJ_SEM_UNDO);
> +	if (IS_ERR(ulp))
> +		return PTR_ERR(ulp);
> +
> +	/* The first task to restore a shared list should already have this,
> +	 * but subsequent ones won't, so attach to current in that case
> +	 */
> +	if (!current->sysvsem.undo_list)
> +		current->sysvsem.undo_list = ulp;
> +
> +	atomic_inc(&ulp->refcnt);

I suspect there is a leak here: atomic_inc is needed only for
tasks other than the first task; The first task already gets the
refcount deep inside find_alloc_undo(), and the hash-table gets
its ref via the obj->grab method.

[...]

Oren.
