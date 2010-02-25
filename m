From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: fix "scheduling in atomic" while restoring ipc shm
Date: Wed, 24 Feb 2010 21:53:31 -0500
Message-ID: <4B85E62B.90804@cs.columbia.edu>
References: <201002241902.19623@zigzag.lvk.cs.msu.su>
	<1267054267-2819-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1267054267-2819-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Nikita V. Youshchenko" <yoush-/llMDZXAvAOHXe+LvDLADg@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Nikita,

Thanks for the report and the analysis. It actually helped to
pinpoint a couple of other minor issues in the code. This patch
should fix all of these.

Oren.


Oren Laadan wrote:
> """
>   While playing with checkpoint-restart code, version
>   several-commits-before-0.19, we have faced "scheduling in atomic" issue.
>   ...
>   So restore_ipc_shm() calls ipc_lock() and then restore_memory_contents().
>   Inside ipc_lock(), a spinlock is taken.
>   Inside restore_memory_contents(), checkpoint data is read, that results
>   in vfs_read() and a schedule somewhere below.
>   ...
>   Another related bug: if load_ipc_shm_hdr() fails in line 257, control
>   is transfered to mutex: label with negative ret value; ipc_unlock()
>   is not called on this path.
> """
> 
> Actually, the error could have occurred with other sleeping functions,
> for example, security_restore_obj().
> 
> The fix is to simply not take ipc_lock(). this relies on the fact that
> IPC is always restored to a brand new ipc namespace which is only
> accessible to the restarting process(es):
> 
> 1) The ipc object (id) could not have been deleted between its creation
>   and taking the rw_mutex.
> 
> 2) No unauthorized task will attempt to gain access to it, so it is
>   safe to do away with ipc_lock(). This is useful because we can call
>   functions that sleep.
> 
> 3) Likewise, we only restore the security bits further below, so it is
>   safe to ignore a security (theoretical only!) race.
> 
> If (and when) we allow to restore the ipc state within the parent's
> namespace, we will need to re-examine this.
> 
> While at it, there is also a cleanup to not restore perm->{id,key,seq}
> or the shm->shm_segsz, as they are all set upon creation properly.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> Reported-by: "Nikita V. Youshchenko" <yoush-/llMDZXAvAOHXe+LvDLADg@public.gmane.org>
> ---
>  ipc/checkpoint.c     |    9 ++----
>  ipc/checkpoint_msg.c |   35 +++++++++++++++++-------
>  ipc/checkpoint_sem.c |   33 ++++++++++++++++------
>  ipc/checkpoint_shm.c |   74 +++++++++++++++++++++++++++++++++-----------------
>  4 files changed, 101 insertions(+), 50 deletions(-)
> 
> diff --git a/ipc/checkpoint.c b/ipc/checkpoint.c
> index 4322dea..06027c2 100644
> --- a/ipc/checkpoint.c
> +++ b/ipc/checkpoint.c
> @@ -203,9 +203,6 @@ int restore_load_ipc_perms(struct ckpt_ctx *ctx,
>  
>  	/* FIX: verify the ->mode field makes sense */
>  
> -	perm->id = h->id;
> -	perm->key = h->key;
> -
>  	if (!validate_created_perms(h))
>  		return -EPERM;
>  	perm->uid = h->uid;
> @@ -213,10 +210,10 @@ int restore_load_ipc_perms(struct ckpt_ctx *ctx,
>  	perm->cuid = h->cuid;
>  	perm->cgid = h->cgid;
>  	perm->mode = h->mode;
> -	perm->seq = h->seq;
>  
> -	return security_restore_obj(ctx, (void *)perm, CKPT_SECURITY_IPC,
> -				   h->sec_ref);
> +	return security_restore_obj(ctx, (void *)perm,
> +				    CKPT_SECURITY_IPC,
> +				    h->sec_ref);
>  }
>  
>  static int restore_ipc_any(struct ckpt_ctx *ctx, struct ipc_namespace *ipc_ns,
> diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
> index 61b3d78..073a893 100644
> --- a/ipc/checkpoint_msg.c
> +++ b/ipc/checkpoint_msg.c
> @@ -306,7 +306,7 @@ static int restore_msg_contents(struct ckpt_ctx *ctx, struct list_head *queue,
>  int restore_ipc_msg(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
>  {
>  	struct ckpt_hdr_ipc_msg *h;
> -	struct kern_ipc_perm *perms;
> +	struct kern_ipc_perm *ipc;
>  	struct msg_queue *msq;
>  	struct ipc_ids *msg_ids = &ns->ids[IPC_MSG_IDS];
>  	struct list_head messages;
> @@ -344,12 +344,26 @@ int restore_ipc_msg(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
>  
>  	down_write(&msg_ids->rw_mutex);
>  
> -	/* we are the sole owners/users of this ipc_ns, it can't go away */
> -	perms = ipc_lock(msg_ids, h->perms.id);
> -	BUG_ON(IS_ERR(perms));	/* ipc_ns is private to us */
> +	/*
> +	 * We are the sole owners/users of this brand new ipc-ns, so:
> +	 *
> +	 * 1) The msgid could not have been deleted between its creation
> +	 *   and taking the rw_mutex above.
> +	 * 2) No unauthorized task will attempt to gain access to it,
> +	 *   so it is safe to do away with ipc_lock(). This is useful
> +	 *   because we can call functions that sleep.
> +	 * 3) Likewise, we only restore the security bits further below,
> +	 *   so it is safe to ignore this (theoretical only!) race.
> +	 *
> +	 * If/when we allow to restore the ipc state within the parent's
> +	 * ipc-ns, we will need to re-examine this.
> +	 */
> +
> +	ipc = idr_find(&msg_ids->ipcs_idr, h->perms.id);
> +	BUG_ON(!ipc);
>  
> -	msq = container_of(perms, struct msg_queue, q_perm);
> -	BUG_ON(!list_empty(&msq->q_messages));	/* ipc_ns is private to us */
> +	msq = container_of(ipc, struct msg_queue, q_perm);
> +	BUG_ON(!list_empty(&msq->q_messages));
>  
>  	/* attach queued messages we read before */
>  	list_splice_init(&messages, &msq->q_messages);
> @@ -362,13 +376,14 @@ int restore_ipc_msg(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
>  	msq->q_qnum = h->q_qnum;
>  
>  	ret = load_ipc_msg_hdr(ctx, h, msq);
> -
>  	if (ret < 0) {
>  		ckpt_debug("msq: need to remove (%d)\n", ret);
> -		freeque(ns, perms);
> -	} else
> -		ipc_unlock(perms);
> +		ipc_lock_by_ptr(&msq->q_perm);
> +		freeque(ns, ipc);
> +		ipc_unlock(ipc);
> +	}
>  	up_write(&msg_ids->rw_mutex);
> +
>   out:
>  	free_msg_list(&messages);  /* no-op if all ok, else cleanup msgs */
>  	ckpt_hdr_put(ctx, h);
> diff --git a/ipc/checkpoint_sem.c b/ipc/checkpoint_sem.c
> index 395c84d..78c1932 100644
> --- a/ipc/checkpoint_sem.c
> +++ b/ipc/checkpoint_sem.c
> @@ -166,7 +166,7 @@ static struct sem *restore_sem_array(struct ckpt_ctx *ctx, int nsems)
>  int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
>  {
>  	struct ckpt_hdr_ipc_sem *h;
> -	struct kern_ipc_perm *perms;
> +	struct kern_ipc_perm *ipc;
>  	struct sem_array *sem;
>  	struct sem *sma = NULL;
>  	struct ipc_ids *sem_ids = &ns->ids[IPC_SEM_IDS];
> @@ -201,19 +201,34 @@ int restore_ipc_sem(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
>  
>  	down_write(&sem_ids->rw_mutex);
>  
> -	/* we are the sole owners/users of this ipc_ns, it can't go away */
> -	perms = ipc_lock(sem_ids, h->perms.id);
> -	BUG_ON(IS_ERR(perms));  /* ipc_ns is private to us */
> -
> -	sem = container_of(perms, struct sem_array, sem_perm);
> +	/*
> +	 * We are the sole owners/users of this brand new ipc-ns, so:
> +	 *
> +	 * 1) The semid could not have been deleted between its creation
> +	 *   and taking the rw_mutex above.
> +	 * 2) No unauthorized task will attempt to gain access to it,
> +	 *   so it is safe to do away with ipc_lock(). This is useful
> +	 *   because we can call functions that sleep.
> +	 * 3) Likewise, we only restore the security bits further below,
> +	 *   so it is safe to ignore this (theoretical only!) race.
> +	 *
> +	 * If/when we allow to restore the ipc state within the parent's
> +	 * ipc-ns, we will need to re-examine this.
> +	 */
> +
> +	ipc = idr_find(&sem_ids->ipcs_idr, h->perms.id);
> +	BUG_ON(!ipc);
> +
> +	sem = container_of(ipc, struct sem_array, sem_perm);
>  	memcpy(sem->sem_base, sma, sem->sem_nsems * sizeof(*sma));
>  
>  	ret = load_ipc_sem_hdr(ctx, h, sem);
>  	if (ret < 0) {
> +		ipc_lock_by_ptr(&sem->sem_perm);
>  		ckpt_debug("sem: need to remove (%d)\n", ret);
> -		freeary(ns, perms);
> -	} else
> -		ipc_unlock(perms);
> +		freeary(ns, ipc);
> +		ipc_unlock(ipc);
> +	}
>  	up_write(&sem_ids->rw_mutex);
>   out:
>  	kfree(sma);
> diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
> index 01091d9..6329245 100644
> --- a/ipc/checkpoint_shm.c
> +++ b/ipc/checkpoint_shm.c
> @@ -144,18 +144,27 @@ struct dq_ipcshm_del {
>  	int id;
>  };
>  
> -static int ipc_shm_delete(void *data)
> +static int _ipc_shm_delete(struct ipc_namespace *ns, int id)
>  {
> -	struct dq_ipcshm_del *dq = (struct dq_ipcshm_del *) data;
>  	mm_segment_t old_fs;
>  	int ret;
>  
>  	old_fs = get_fs();
>  	set_fs(get_ds());
> -	ret = shmctl_down(dq->ipcns, dq->id, IPC_RMID, NULL, 0);
> +	ret = shmctl_down(ns, id, IPC_RMID, NULL, 0);
>  	set_fs(old_fs);
>  
> +	return ret;
> +}
> +
> +static int ipc_shm_delete(void *data)
> +{
> +	struct dq_ipcshm_del *dq = (struct dq_ipcshm_del *) data;
> +	int ret;
> +
> +	ret = _ipc_shm_delete(dq->ipcns, dq->id);
>  	put_ipc_ns(dq->ipcns);
> +
>  	return ret;
>  }
>  
> @@ -175,7 +184,6 @@ static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
>  	if (h->shm_cprid < 0 || h->shm_lprid < 0)
>  		return -EINVAL;
>  
> -	shp->shm_segsz = h->shm_segsz;
>  	shp->shm_atim = h->shm_atim;
>  	shp->shm_dtim = h->shm_dtim;
>  	shp->shm_ctim = h->shm_ctim;
> @@ -188,7 +196,7 @@ static int load_ipc_shm_hdr(struct ckpt_ctx *ctx,
>  int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
>  {
>  	struct ckpt_hdr_ipc_shm *h;
> -	struct kern_ipc_perm *perms;
> +	struct kern_ipc_perm *ipc;
>  	struct shmid_kernel *shp;
>  	struct ipc_ids *shm_ids = &ns->ids[IPC_SHM_IDS];
>  	struct file *file;
> @@ -213,6 +221,14 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
>  	if (h->flags & SHM_HUGETLB)	/* FIXME: support SHM_HUGETLB */
>  		goto out;
>  
> +	shmflag = h->flags | h->perms.mode | IPC_CREAT | IPC_EXCL;
> +	ckpt_debug("shm: do_shmget size %lld flag %#x id %d\n",
> +		 h->shm_segsz, shmflag, h->perms.id);
> +	ret = do_shmget(ns, h->perms.key, h->shm_segsz, shmflag, h->perms.id);
> +	ckpt_debug("shm: do_shmget ret %d\n", ret);
> +	if (ret < 0)
> +		goto out;
> +
>  	/*
>  	 * SHM_DEST means that the shm is to be deleted after creation.
>  	 * However, deleting before it's actually attached is quite silly.
> @@ -228,29 +244,36 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
>  		dq.ipcns = ns;
>  		get_ipc_ns(dq.ipcns);
>  
> -		/* XXX can safely use put_ipc_ns() as dtor, see above */
>  		ret = deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
>  				     (deferqueue_func_t) ipc_shm_delete,
> -				     (deferqueue_func_t) put_ipc_ns);
> -		if (ret < 0)
> +				     (deferqueue_func_t) ipc_shm_delete);
> +		if (ret < 0) {
> +			ipc_shm_delete((void *) &dq);
>  			goto out;
> +		}
>  	}
>  
> -	shmflag = h->flags | h->perms.mode | IPC_CREAT | IPC_EXCL;
> -	ckpt_debug("shm: do_shmget size %lld flag %#x id %d\n",
> -		 h->shm_segsz, shmflag, h->perms.id);
> -	ret = do_shmget(ns, h->perms.key, h->shm_segsz, shmflag, h->perms.id);
> -	ckpt_debug("shm: do_shmget ret %d\n", ret);
> -	if (ret < 0)
> -		goto out;
> -
>  	down_write(&shm_ids->rw_mutex);
>  
> -	/* we are the sole owners/users of this ipc_ns, it can't go away */
> -	perms = ipc_lock(shm_ids, h->perms.id);
> -	BUG_ON(IS_ERR(perms));  /* ipc_ns is private to us */
> +	/*
> +	 * We are the sole owners/users of this brand new ipc-ns, so:
> +	 *
> +	 * 1) The shmid could not have been deleted between its creation
> +	 *   and taking the rw_mutex above.
> +	 * 2) No unauthorized task will attempt to gain access to it,
> +	 *   so it is safe to do away with ipc_lock(). This is useful
> +	 *   because we can call functions that sleep.
> +	 * 3) Likewise, we only restore the security bits further below,
> +	 *   so it is safe to ignore this (theoretical only!) race.
> +	 *
> +	 * If/when we allow to restore the ipc state within the parent's
> +	 * ipc-ns, we will need to re-examine this.
> +	 */
> +
> +	ipc = idr_find(&shm_ids->ipcs_idr, h->perms.id);
> +	BUG_ON(!ipc);
>  
> -	shp = container_of(perms, struct shmid_kernel, shm_perm);
> +	shp = container_of(ipc, struct shmid_kernel, shm_perm);
>  	file = shp->shm_file;
>  	get_file(file);
>  
> @@ -265,12 +288,13 @@ int restore_ipc_shm(struct ckpt_ctx *ctx, struct ipc_namespace *ns)
>  	ret = restore_memory_contents(ctx, file->f_dentry->d_inode);
>   mutex:
>  	fput(file);
> -	if (ret < 0) {
> -		ckpt_debug("shm: need to remove (%d)\n", ret);
> -		do_shm_rmid(ns, perms);
> -	} else
> -		ipc_unlock(perms);
>  	up_write(&shm_ids->rw_mutex);
> +
> +	/* discard this shmid if error and deferqueue wasn't set */
> +	if (ret < 0 && !(h->perms.mode & SHM_DEST)) {
> +		ckpt_debug("shm: need to remove (%d)\n", ret);
> +		_ipc_shm_delete(ns, h->perms.id);
> +	}
>   out:
>  	ckpt_hdr_put(ctx, h);
>  	return ret;
