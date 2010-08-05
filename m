From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add support for the per-task sem_undo list (v3.01)
Date: Thu, 5 Aug 2010 14:48:42 -0700
Message-ID: <20100805214842.GP2927@count0.beaverton.ibm.com>
References: <1281031026-2357-1-git-send-email-danms@us.ibm.com>
	<1281031026-2357-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1281031026-2357-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Thu, Aug 05, 2010 at 10:57:06AM -0700, Dan Smith wrote:
> The semaphore undo list is a set of adjustments to be made to semaphores
> held by a task on exit.  Right now, we do not checkpoint or restore this
> list which could cause undesirable behavior by a restarted process on exit.

<snip>

> diff --git a/ipc/sem.c b/ipc/sem.c
> index e439b73..ee5b386 100644
> --- a/ipc/sem.c
> +++ b/ipc/sem.c

<snip>

> @@ -1470,3 +1466,319 @@ static int sysvipc_sem_proc_show(struct seq_file *s, void *it)
>  			  sma->sem_ctime);
>  }
>  #endif
> +
> +static int __get_task_semids(struct sem_undo_list *ulp, int *semids, int max)

Why "task"? I'd name it __get_undo_list_semids or something like that
instead.

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

<snip>

> +int checkpoint_sem_undo_adj(struct ckpt_ctx *ctx, struct sem_undo *un)

Should be static.

<snip>

> +
> +int write_sem_undo_list(struct ckpt_ctx *ctx, struct sem_undo_list *ulp,
> +			int count, int *semids)

Should be static.

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

Or should this be a ckpt_err() ?

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

<snip>

> +static int restore_task_sem_undo_adj(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_task_sem_undo *h;
> +	int len;
> +	int ret = -ENOMEM;
> +	struct sem_undo *un;
> +	int nsems;
> +	__s16 *semadj = NULL;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_SEM_UNDO);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	len = sizeof(__s16) * h->semadj_count;
> +	ret = ckpt_read_payload(ctx, (void **)&semadj, len, CKPT_HDR_BUFFER);
> +	if (ret < 0)
> +		goto out;
> +

As best I can tell exit_sem() does not do permission checking -- it
relies on semop and semtimedop to check permissions on the operation
that created the undo in the first place. Thus I think we need to check
permissions here with ipc_check_perms() or ipcperms(). Otherwise it may
be possible to manipulate semaphores we do not have permission to
manipulate.

> +	un = find_alloc_undo(current->nsproxy->ipc_ns, h->semid);
> +	if (IS_ERR(un)) {
> +		ret = PTR_ERR(un);
> +		ckpt_debug("unable to find semid %i\n", h->semid);
> +		goto out;
> +	}
> +
> +	nsems = sem_undo_nsems(un, current->nsproxy->ipc_ns);
> +	len = sizeof(__s16) * nsems;
> +	if (h->semadj_count == nsems)
> +		memcpy(un->semadj, semadj, len);
> +	rcu_read_unlock();
> +
> +	if (nsems != h->semadj_count)
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
> +	for (i = 0; i < h->count; i++) {
> +		ret = restore_task_sem_undo_adj(ctx);
> +		if (ret < 0)
> +			goto out;
> +	}
> +
> +	atomic_inc(&ulp->refcnt);
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	if (ret < 0)

Don't we need to check ulp and clean up the alloc'd undo list here?

> +		return ERR_PTR(ret);
> +	else
> +		return ulp;
> +}

Cheers,
	-Matt Helsley
