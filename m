From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Add support for the per-task sem_undo list
Date: Fri, 30 Jul 2010 14:42:15 -0400
Message-ID: <4C531D07.9070506@cs.columbia.edu>
References: <1280502495-31542-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1280502495-31542-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Dan Smith wrote:
> The semaphore undo list is a set of adjustments to be made to semaphores
> held by a task on exit.  Right now, we do not checkpoint or restore this
> list which could cause undesirable behavior by a restarted process on exit.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

See comments inline:

> ---
>  include/linux/checkpoint.h     |    5 +
>  include/linux/checkpoint_hdr.h |   18 +++
>  ipc/sem.c                      |  332 +++++++++++++++++++++++++++++++++++++++-
>  kernel/checkpoint/process.c    |   16 ++
>  4 files changed, 365 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 0437de2..285689a 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -275,6 +275,11 @@ extern int ckpt_collect_fs(struct ckpt_ctx *ctx, struct task_struct *t);
>  extern int checkpoint_obj_fs(struct ckpt_ctx *ctx, struct task_struct *t);
>  extern int restore_obj_fs(struct ckpt_ctx *ctx, int fs_objref);
>  
> +/* per-task semaphore undo */
> +int checkpoint_obj_sem_undo(struct ckpt_ctx *ctx, struct task_struct *t);
> +int restore_obj_sem_undo(struct ckpt_ctx *ctx, int sem_undo_objref);
> +int ckpt_collect_sem_undo(struct ckpt_ctx *ctx, struct task_struct *t);

I supsect we don't need to collect these, since sem-undo-lists
are already covered by ipc-ns.

[...]

> diff --git a/ipc/sem.c b/ipc/sem.c
> index 37da85e..fdad527 100644
> --- a/ipc/sem.c
> +++ b/ipc/sem.c
> @@ -132,12 +132,49 @@ void sem_exit_ns(struct ipc_namespace *ns)
>  }
>  #endif
>  
> +static int obj_sem_undo_grab(void *ptr)
> +{
> +	struct sem_undo_list *ulp = ptr;
> +
> +	atomic_inc(&ulp->refcnt);
> +	return 0;
> +}
> +
> +static void obj_sem_undo_drop(void *ptr, int lastref)
> +{
> +	struct sem_undo_list *ulp = ptr;
> +
> +	atomic_dec(&ulp->refcnt);

What happens when the count drops to zero ?

> +}
> +
> +static int obj_sem_undo_users(void *ptr)
> +{
> +	struct sem_undo_list *ulp = ptr;
> +
> +	return atomic_read(&ulp->refcnt);
> +}
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
> +	.checkpoint = checkpoint_sem_undo,
> +	.restore = restore_sem_undo,
> +};
> +
>  void __init sem_init (void)
>  {
>  	sem_init_ns(&init_ipc_ns);
>  	ipc_init_proc_interface("sysvipc/sem",
>  				"       key      semid perms      nsems   uid   gid  cuid  cgid      otime      ctime\n",
>  				IPC_SEM_IDS, sysvipc_sem_proc_show);
> +	register_checkpoint_obj(&ckpt_obj_sem_undo_ops);
> +
>  }
>  
>  /*
> @@ -983,6 +1020,20 @@ asmlinkage long SyS_semctl(int semid, int semnum, int cmd, union semun arg)
>  SYSCALL_ALIAS(sys_semctl, SyS_semctl);
>  #endif
>  
> +static struct sem_undo_list *alloc_undo_list(void)
> +{
> +	struct sem_undo_list *undo_list;
> +
> +	undo_list = kzalloc(sizeof(*undo_list), GFP_KERNEL);
> +	if (undo_list == NULL)
> +		return NULL;
> +	spin_lock_init(&undo_list->lock);
> +	atomic_set(&undo_list->refcnt, 1);
> +	INIT_LIST_HEAD(&undo_list->list_proc);
> +
> +	return undo_list;
> +}
> +
>  /* If the task doesn't already have a undo_list, then allocate one
>   * here.  We guarantee there is only one thread using this undo list,
>   * and current is THE ONE
> @@ -1000,13 +1051,9 @@ static inline int get_undo_list(struct sem_undo_list **undo_listp)
>  
>  	undo_list = current->sysvsem.undo_list;
>  	if (!undo_list) {
> -		undo_list = kzalloc(sizeof(*undo_list), GFP_KERNEL);
> -		if (undo_list == NULL)
> +		undo_list = alloc_undo_list();
> +		if (!undo_list)
>  			return -ENOMEM;
> -		spin_lock_init(&undo_list->lock);
> -		atomic_set(&undo_list->refcnt, 1);
> -		INIT_LIST_HEAD(&undo_list->list_proc);
> -
>  		current->sysvsem.undo_list = undo_list;
>  	}
>  	*undo_listp = undo_list;
> @@ -1458,3 +1505,276 @@ static int sysvipc_sem_proc_show(struct seq_file *s, void *it)
>  			  sma->sem_ctime);
>  }
>  #endif
> +
> +static int __get_task_semids(struct sem_undo_list *ulp, int *semids, int max)
> +{
> +	int count = 0;
> +	struct sem_undo *un;
> +
> +	if (!ulp)
> +		return 0;
> +
> +	spin_lock(&ulp->lock);
> +	list_for_each_entry_rcu(un, &ulp->list_proc, list_proc) {
> +		if (count >= max) {
> +			count = -E2BIG;
> +			break;
> +		}
> +		semids[count++] = un->semid;
> +	}
> +	spin_unlock(&ulp->lock);
> +
> +	return count;
> +}
> +
> +static int get_task_semids(struct sem_undo_list *ulp, int **semid_listp)
> +{
> +	int ret;
> +	int max = 32;
> +	int *semid_list = NULL;
> + retry:
> +	*semid_listp = krealloc(semid_list, max * sizeof(int), GFP_KERNEL);
> +	if (!*semid_listp) {
> +		kfree(semid_list);
> +		return -ENOMEM;
> +	}
> +	semid_list = *semid_listp;
> +
> +	ret = __get_task_semids(ulp, semid_list, max);
> +	if (ret == -E2BIG) {
> +		max *= 2;
> +		goto retry;

What about @max overflowing and becoming negative ?  I guess
that's covered by the test of the krealloc() retval.

> +	} else if (ret < 0) {
> +		kfree(semid_list);
> +		*semid_listp = NULL;
> +	}
> +
> +	return ret;
> +}
> +
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

This will oops because ckpt_hdr_put() is not NULL-friendly...

> +
> +	semadj = kzalloc(nsems * sizeof(short), GFP_KERNEL);
> +	if (!semadj)
> +		goto putref_abort;
> +
> +	sem_lock_and_putref(sma);
> +
> +	h->semid = un->semid;
> +	h->semadj_count = nsems;
> +	memcpy(semadj, un->semadj, h->semadj_count * sizeof(short));

sizeof(short) --> sizeof(__s16)

And for safety, maybe a compile assertion:
   sizeof(__s16) == sizeof(*un->semadj)

> +
> +	sem_unlock(sma);
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *)h);
> +	if (ret == 0)
> +		ret = ckpt_write_buffer(ctx, semadj, nsems * sizeof(short));
> +
> +	kfree(semadj);

ckpt_hdr_put()...

> +
> +	return ret;
> +
> + putref_abort:
> +	sem_putref(sma);
> +	ckpt_hdr_put(ctx, h);
> +
> +	return -ENOMEM;
> +}
> +
> +int write_sem_undo_list(struct ckpt_ctx *ctx, struct sem_undo_list *ulp,
> +			int count, int *semids)
> +{
> +	int i;
> +	int ret;
> +
> +	for (i = 0; i < count; i++) {
> +		struct sem_undo *un;
> +
> +		spin_lock(&ulp->lock);
> +		un = lookup_undo(ulp, semids[i]);
> +		spin_unlock(&ulp->lock);
> +
> +		if (!un) {
> +			ckpt_debug("unable to lookup semid %i\n", semids[i]);
> +			return -EINVAL;
> +		}
> +
> +		ret = checkpoint_sem_undo_adj(ctx, un);
> +		ckpt_debug("checkpoint_sem_undo: %i\n", ret);
> +		if (ret < 0)
> +			return ret;
> +	}
> +
> +	return 0;
> +}
> +
> +static int checkpoint_sem_undo(struct ckpt_ctx *ctx, void *ptr)
> +{
> +	int ret;
> +	int *semids = NULL;
> +	struct sem_undo_list *ulp = ptr;
> +	struct ckpt_hdr_task_sem_undo_list *h;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_SEM_UNDO_LIST);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	ret = get_task_semids(ulp, &semids);
> +	if (ret < 0)
> +		goto out;
> +	h->count = ret;
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *)h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = write_sem_undo_list(ctx, ulp, h->count, semids);
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	kfree(semids);
> +
> +	return ret;
> +}
> +
> +int checkpoint_obj_sem_undo(struct ckpt_ctx *ctx, struct task_struct *t)
> +{
> +	struct sem_undo_list *ulp;
> +	int sem_undo_objref = 0;
> +
> +	ulp = t->sysvsem.undo_list;
> +	if (ulp)
> +		sem_undo_objref = checkpoint_obj(ctx, ulp, CKPT_OBJ_SEM_UNDO);
> +
> +	return sem_undo_objref;

:)

> +}
> +
> +/* Count the number of sems for the given sem_undo->semid */
> +static int sem_undo_nsems(struct sem_undo *un, struct ipc_namespace *ns)
> +{
> +	struct sem_array *sma;
> +	int nsems;
> +
> +	sma = sem_lock(ns, un->semid);
> +	if (IS_ERR(sma))
> +		return PTR_ERR(sma);
> +
> +	nsems = sma->sem_nsems;
> +	sem_unlock(sma);
> +
> +	return nsems;
> +}
> +
> +static int restore_task_sem_undo_adj(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_task_sem_undo *h;
> +	int len;
> +	int ret = -ENOMEM;
> +	struct sem_undo *un;
> +	int nsems;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_SEM_UNDO);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	un = find_alloc_undo(current->nsproxy->ipc_ns, h->semid);
> +	if (IS_ERR(un)) {
> +		ret = PTR_ERR(un);
> +		ckpt_debug("unable to find semid %i\n", h->semid);
> +		goto out_nolock;
> +	}
> +
> +	nsems = sem_undo_nsems(un, current->nsproxy->ipc_ns);
> +	if (nsems != h->semadj_count) {
> +		ckpt_err(ctx, -EINVAL,
> +			 "semid %i has nmsems=%i but %i undo adjustments\n",
> +			 h->semid, nsems, h->semadj_count);
> +		goto out;
> +	}
> +
> +	len = sizeof(short) * h->semadj_count;

here, too:  sizeof(short) --> sizeof(__s16)

And for safety, maybe a compile assertion:
   sizeof(__s16) == sizeof(*un->semadj)

Do the values in the buffer require sanity check ?

> +	ret = _ckpt_read_buffer(ctx, un->semadj, len);

The rcu_read lock is taken here --> use a temporary buffer
like in checkpoint, or don't keep the lock at all, just a
reference.

> +	if (ret < 0)
> +		goto out;
> +
> +	ckpt_debug("semid %i restored with %i adjustments\n",
> +		   h->semid, h->semadj_count);

And this debug should also be outside the rcu_read_unlock().

> + out:
> +	rcu_read_unlock(); /* was taken by find_alloc_undo() */
> + out_nolock:
> +	ckpt_hdr_put(ctx, h);
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
> +	ulp = alloc_undo_list();
> +	if (!ulp) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	for (i = 0; i < h->count; i++) {
> +		ret = restore_task_sem_undo_adj(ctx);
> +		if (ret < 0)
> +			goto out;
> +	}
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	if (ret < 0)
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

If the fetch succeeds and we are not the original task in which
context the undo-list was restored, then we need to explicitly
attach the list to ourselves.

> +
> +	return 0;
> +}
> +
> +int ckpt_collect_sem_undo(struct ckpt_ctx *ctx, struct task_struct *t)
> +{
> +	struct sem_undo_list *ulp = t->sysvsem.undo_list;
> +
> +	if (ulp)
> +		return ckpt_obj_collect(ctx, ulp, CKPT_OBJ_SEM_UNDO);
> +	else
> +		return 0;
> +}

I'd assume that we don't need to explicitly collect the undo-list
since it requires that they also share ipc-ns, and that is already
collected.

> diff --git a/kernel/checkpoint/process.c b/kernel/checkpoint/process.c
> index 936675a..2d50ac9 100644
> --- a/kernel/checkpoint/process.c
> +++ b/kernel/checkpoint/process.c
> @@ -236,6 +236,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
>  	int files_objref;
>  	int mm_objref;
>  	int fs_objref;
> +	int sem_undo_objref;
>  	int sighand_objref;
>  	int signal_objref;
>  	int first, ret;
> @@ -283,6 +284,12 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
>  		return fs_objref;
>  	}
>  
> +	sem_undo_objref = checkpoint_obj_sem_undo(ctx, t);
> +	if (sem_undo_objref < 0) {
> +		ckpt_err(ctx, sem_undo_objref, "%(T)process sem_undo\n");
> +		return sem_undo_objref;
> +	}
> +
>  	sighand_objref = checkpoint_obj_sighand(ctx, t);
>  	ckpt_debug("sighand: objref %d\n", sighand_objref);
>  	if (sighand_objref < 0) {
> @@ -311,6 +318,7 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
>  	h->files_objref = files_objref;
>  	h->mm_objref = mm_objref;
>  	h->fs_objref = fs_objref;
> +	h->sem_undo_objref = sem_undo_objref;
>  	h->sighand_objref = sighand_objref;
>  	h->signal_objref = signal_objref;
>  	ret = ckpt_write_obj(ctx, &h->h);
> @@ -492,6 +500,9 @@ int ckpt_collect_task(struct ckpt_ctx *ctx, struct task_struct *t)
>  	ret = ckpt_collect_fs(ctx, t);
>  	if (ret < 0)
>  		return ret;
> +	ret = ckpt_collect_sem_undo(ctx, t);
> +	if (ret < 0)
> +		return ret;
>  	ret = ckpt_collect_sighand(ctx, t);
>  
>  	return ret;
> @@ -679,6 +690,11 @@ static int restore_task_objs(struct ckpt_ctx *ctx)
>  	if (ret < 0)
>  		return ret;
>  
> +	ret = restore_obj_sem_undo(ctx, h->sem_undo_objref);
> +	ckpt_debug("sem_undo: ret %d\n", ret);
> +	if (ret < 0)
> +		return ret;
> +
>  	ret = restore_obj_sighand(ctx, h->sighand_objref);
>  	ckpt_debug("sighand: ret %d (%p)\n", ret, current->sighand);
>  	if (ret < 0)

Oren.
