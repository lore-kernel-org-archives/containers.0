From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] Add ipc_namespace to struct sem_undo_list
Date: Tue, 10 Aug 2010 20:00:00 -0700
Message-ID: <20100811025959.GG2927@count0.beaverton.ibm.com>
References: <1281457254-18890-1-git-send-email-danms@us.ibm.com>
	<1281457254-18890-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1281457254-18890-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Tue, Aug 10, 2010 at 09:20:53AM -0700, Dan Smith wrote:
> Checkpoint/Restart needs to have a pointer to the ipc_namespace that the
> sem_undo_list applies to in order to properly bring up and tear down
> the object hash.  This patch adds a pointer to the namespace to the list
> structure, as well as breaks out the allocation of the undo list to a
> separate function (which is needed in a later C/R patch anyway).
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---

Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

>  include/linux/sem.h |    2 ++
>  ipc/sem.c           |   30 +++++++++++++++++++++---------
>  2 files changed, 23 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/sem.h b/include/linux/sem.h
> index 8a4adbe..8cf9636 100644
> --- a/include/linux/sem.h
> +++ b/include/linux/sem.h
> @@ -127,12 +127,14 @@ struct sem_undo {
>  	short *			semadj;		/* array of adjustments, one per semaphore */
>  };
> 
> +struct ipc_namespace;
>  /* sem_undo_list controls shared access to the list of sem_undo structures
>   * that may be shared among all a CLONE_SYSVSEM task group.
>   */ 
>  struct sem_undo_list {
>  	atomic_t		refcnt;
>  	spinlock_t		lock;
> +	struct ipc_namespace	*ipc_ns;
>  	struct list_head	list_proc;
>  };
> 
> diff --git a/ipc/sem.c b/ipc/sem.c
> index 37da85e..e439b73 100644
> --- a/ipc/sem.c
> +++ b/ipc/sem.c
> @@ -983,6 +983,21 @@ asmlinkage long SyS_semctl(int semid, int semnum, int cmd, union semun arg)
>  SYSCALL_ALIAS(sys_semctl, SyS_semctl);
>  #endif
> 
> +static struct sem_undo_list *alloc_undo_list(struct ipc_namespace *ipc_ns)
> +{
> +	struct sem_undo_list *undo_list;
> +
> +	undo_list = kzalloc(sizeof(*undo_list), GFP_KERNEL);
> +	if (undo_list == NULL)
> +		return NULL;
> +	spin_lock_init(&undo_list->lock);
> +	atomic_set(&undo_list->refcnt, 1);
> +	INIT_LIST_HEAD(&undo_list->list_proc);
> +	undo_list->ipc_ns = ipc_ns;
> +
> +	return undo_list;
> +}
> +
>  /* If the task doesn't already have a undo_list, then allocate one
>   * here.  We guarantee there is only one thread using this undo list,
>   * and current is THE ONE
> @@ -994,19 +1009,16 @@ SYSCALL_ALIAS(sys_semctl, SyS_semctl);
>   *
>   * This can block, so callers must hold no locks.
>   */
> -static inline int get_undo_list(struct sem_undo_list **undo_listp)
> +static inline int get_undo_list(struct sem_undo_list **undo_listp,
> +				struct ipc_namespace *ipc_ns)
>  {
>  	struct sem_undo_list *undo_list;
> 
>  	undo_list = current->sysvsem.undo_list;
>  	if (!undo_list) {
> -		undo_list = kzalloc(sizeof(*undo_list), GFP_KERNEL);
> -		if (undo_list == NULL)
> +		undo_list = alloc_undo_list(ipc_ns);
> +		if (!undo_list)
>  			return -ENOMEM;
> -		spin_lock_init(&undo_list->lock);
> -		atomic_set(&undo_list->refcnt, 1);
> -		INIT_LIST_HEAD(&undo_list->list_proc);
> -
>  		current->sysvsem.undo_list = undo_list;
>  	}
>  	*undo_listp = undo_list;
> @@ -1057,7 +1069,7 @@ static struct sem_undo *find_alloc_undo(struct ipc_namespace *ns, int semid)
>  	int nsems;
>  	int error;
> 
> -	error = get_undo_list(&ulp);
> +	error = get_undo_list(&ulp, ns);
>  	if (error)
>  		return ERR_PTR(error);
> 
> @@ -1328,7 +1340,7 @@ int copy_semundo(unsigned long clone_flags, struct task_struct *tsk)
>  	int error;
> 
>  	if (clone_flags & CLONE_SYSVSEM) {
> -		error = get_undo_list(&undo_list);
> +		error = get_undo_list(&undo_list, tsk->nsproxy->ipc_ns);
>  		if (error)
>  			return error;
>  		atomic_inc(&undo_list->refcnt);
> -- 
> 1.7.1.1
> 
