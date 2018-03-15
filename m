From: Waiman Long <longman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] ipc: Remove IPCMNI
Date: Thu, 15 Mar 2018 13:02:12 -0400
Message-ID: <047c6ed6-6581-b543-ba3d-cadc543d3d25__5906.15591868318$1521133219$gmane$org@redhat.com>
References: <1520885744-1546-1-git-send-email-longman@redhat.com>
	<1520885744-1546-5-git-send-email-longman@redhat.com>
	<87woyfyh57.fsf@xmission.com>
	<5d4a858a-3136-5ef4-76fe-a61e7f2aed56@redhat.com>
	<87o9jru3bf.fsf@xmission.com>
	<935a7c50-50cc-2dc0-33bb-92c000d039bc@redhat.com>
	<87woyego2u.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87woyego2u.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Matthew Wilcox <willy-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On 03/14/2018 08:49 PM, Eric W. Biederman wrote:
> The define IPCMNI was originally the size of a statically sized array in
> the kernel and that has long since been removed.  Therefore there is no
> fundamental reason for IPCMNI.
>
> The only remaining use IPCMNI serves is as a convoluted way to format
> the ipc id to userspace.  It does not appear that anything except for
> the CHECKPOINT_RESTORE code even cares about this variety of assignment
> and the CHECKPOINT_RESTORE code only cares about this weirdness because
> it has to restore these peculiar ids.
>
> Therefore make the assignment of ipc ids match the description in
> Advanced Programming in the Unix Environment and assign the next id
> until INT_MAX is hit then loop around to the lower ids.
>
> This can be implemented trivially with the current code using idr_alloc_cyclic.
>
> To make it possible to keep checkpoint/restore working I have renamed
> the sysctls from xxx_next_id to xxx_nextid.  That is enough change that
> a smart CRIU implementation can see that what is exported has changed,
> and act accordingly.  New kernels will be able to restore the old id's.
>
> This code still needs some real world testing to verify my assumptions.
> And some work with the CRIU implementations to actually add the code
> that deals with the new for of id assignment.
>
> Updates: 03f595668017 ("ipc: add sysctl to specify desired next object id")
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>
> Waiman please take a look at this and run it through some tests etc,
> I am pretty certain something like this patch is all you need to do
> to sort out ipc assignment.  Not messing with sysctls needed.
>
>  include/linux/ipc.h           |  2 --
>  include/linux/ipc_namespace.h |  1 -
>  ipc/ipc_sysctl.c              |  6 ++--
>  ipc/namespace.c               | 11 ++----
>  ipc/util.c                    | 80 ++++++++++---------------------------------
>  ipc/util.h                    | 11 +-----
>  6 files changed, 25 insertions(+), 86 deletions(-)
>
> diff --git a/include/linux/ipc.h b/include/linux/ipc.h
> index 821b2f260992..6cc2df7f7ac9 100644
> --- a/include/linux/ipc.h
> +++ b/include/linux/ipc.h
> @@ -8,8 +8,6 @@
>  #include <uapi/linux/ipc.h>
>  #include <linux/refcount.h>
>  
> -#define IPCMNI 32768  /* <= MAX_INT limit for ipc arrays (including sysctl changes) */
> -
>  /* used by in-kernel data structures */
>  struct kern_ipc_perm {
>  	spinlock_t	lock;
> diff --git a/include/linux/ipc_namespace.h b/include/linux/ipc_namespace.h
> index b5630c8eb2f3..cab33b6a8236 100644
> --- a/include/linux/ipc_namespace.h
> +++ b/include/linux/ipc_namespace.h
> @@ -15,7 +15,6 @@ struct user_namespace;
>  
>  struct ipc_ids {
>  	int in_use;
> -	unsigned short seq;
>  	bool tables_initialized;
>  	struct rw_semaphore rwsem;
>  	struct idr ipcs_idr;
> diff --git a/ipc/ipc_sysctl.c b/ipc/ipc_sysctl.c
> index 8ad93c29f511..a599963d58bf 100644
> --- a/ipc/ipc_sysctl.c
> +++ b/ipc/ipc_sysctl.c
> @@ -176,7 +176,7 @@ static struct ctl_table ipc_kern_table[] = {
>  	},
>  #ifdef CONFIG_CHECKPOINT_RESTORE
>  	{
> -		.procname	= "sem_next_id",
> +		.procname	= "sem_nextid",
>  		.data		= &init_ipc_ns.ids[IPC_SEM_IDS].next_id,
>  		.maxlen		= sizeof(init_ipc_ns.ids[IPC_SEM_IDS].next_id),
>  		.mode		= 0644,
> @@ -185,7 +185,7 @@ static struct ctl_table ipc_kern_table[] = {
>  		.extra2		= &int_max,
>  	},
>  	{
> -		.procname	= "msg_next_id",
> +		.procname	= "msg_nextid",
>  		.data		= &init_ipc_ns.ids[IPC_MSG_IDS].next_id,
>  		.maxlen		= sizeof(init_ipc_ns.ids[IPC_MSG_IDS].next_id),
>  		.mode		= 0644,
> @@ -194,7 +194,7 @@ static struct ctl_table ipc_kern_table[] = {
>  		.extra2		= &int_max,
>  	},
>  	{
> -		.procname	= "shm_next_id",
> +		.procname	= "shm_nextid",
>  		.data		= &init_ipc_ns.ids[IPC_SHM_IDS].next_id,
>  		.maxlen		= sizeof(init_ipc_ns.ids[IPC_SHM_IDS].next_id),
>  		.mode		= 0644,

So you are changing the names of existing sysctl parameters. Will it be
better to add new sysctl to indicate that the rule has changed instead?

> diff --git a/ipc/namespace.c b/ipc/namespace.c
> index f59a89966f92..84eaeba9e96c 100644
> --- a/ipc/namespace.c
> +++ b/ipc/namespace.c
> @@ -109,20 +109,13 @@ void free_ipcs(struct ipc_namespace *ns, struct ipc_ids *ids,
>  {
>  	struct kern_ipc_perm *perm;
>  	int next_id;
> -	int total, in_use;
>  
>  	down_write(&ids->rwsem);
> -
> -	in_use = ids->in_use;
> -
> -	for (total = 0, next_id = 0; total < in_use; next_id++) {
> -		perm = idr_find(&ids->ipcs_idr, next_id);
> -		if (perm == NULL)
> -			continue;
> +	next_id = 0;
> +	while ((perm = idr_get_next(&ids->ipcs_idr, &next_id))) {
>  		rcu_read_lock();
>  		ipc_lock_object(perm);
>  		free(ns, perm);
> -		total++;
>  	}
>  	up_write(&ids->rwsem);
>  }
> diff --git a/ipc/util.c b/ipc/util.c
> index 4ed5a17dd06f..ce6bf18e54df 100644
> --- a/ipc/util.c
> +++ b/ipc/util.c
> @@ -118,7 +118,6 @@ int ipc_init_ids(struct ipc_ids *ids)
>  {
>  	int err;
>  	ids->in_use = 0;
> -	ids->seq = 0;
>  	init_rwsem(&ids->rwsem);
>  	err = rhashtable_init(&ids->key_ht, &ipc_kht_params);
>  	if (err)
> @@ -192,46 +191,18 @@ static struct kern_ipc_perm *ipc_findkey(struct ipc_ids *ids, key_t key)
>  	return NULL;
>  }
>  
> -#ifdef CONFIG_CHECKPOINT_RESTORE
> -/*
> - * Specify desired id for next allocated IPC object.
> - */
> -#define ipc_idr_alloc(ids, new)						\
> -	idr_alloc(&(ids)->ipcs_idr, (new),				\
> -		  (ids)->next_id < 0 ? 0 : ipcid_to_idx((ids)->next_id),\
> -		  0, GFP_NOWAIT)
>  
> -static inline int ipc_buildid(int id, struct ipc_ids *ids,
> -			      struct kern_ipc_perm *new)
> +static int ipc_idr_alloc(struct ipc_ids *ids, struct kern_ipc_perm *new)
>  {
> -	if (ids->next_id < 0) { /* default, behave as !CHECKPOINT_RESTORE */
> -		new->seq = ids->seq++;
> -		if (ids->seq > IPCID_SEQ_MAX)
> -			ids->seq = 0;
> -	} else {
> -		new->seq = ipcid_to_seqx(ids->next_id);
> +#ifdef CONFIG_CHECKPOINT_RESTORE
> +	if (ids->next_id >= 0) {
> +		idr_set_cursor(&ids->ipcs_idr, ids->next_id);
>  		ids->next_id = -1;
>  	}
> -
> -	return SEQ_MULTIPLIER * new->seq + id;
> -}
> -
> -#else
> -#define ipc_idr_alloc(ids, new)					\
> -	idr_alloc(&(ids)->ipcs_idr, (new), 0, 0, GFP_NOWAIT)
> -
> -static inline int ipc_buildid(int id, struct ipc_ids *ids,
> -			      struct kern_ipc_perm *new)
> -{
> -	new->seq = ids->seq++;
> -	if (ids->seq > IPCID_SEQ_MAX)
> -		ids->seq = 0;
> -
> -	return SEQ_MULTIPLIER * new->seq + id;
> +#endif
> +	return idr_alloc_cyclic(&ids->ipcs_idr, (new), 0, 0, GFP_NOWAIT);
>  }
>  
> -#endif /* CONFIG_CHECKPOINT_RESTORE */
> -
>  /**
>   * ipc_addid - add an ipc identifier
>   * @ids: ipc identifier set
> @@ -251,9 +222,6 @@ int ipc_addid(struct ipc_ids *ids, struct kern_ipc_perm *new, int limit)
>  	kgid_t egid;
>  	int id, err;
>  
> -	if (limit > IPCMNI)
> -		limit = IPCMNI;
> -
>  	if (!ids->tables_initialized || ids->in_use >= limit)
>  		return -ENOSPC;
>  
> @@ -290,7 +258,7 @@ int ipc_addid(struct ipc_ids *ids, struct kern_ipc_perm *new, int limit)
>  	if (id > ids->max_id)
>  		ids->max_id = id;
>  
> -	new->id = ipc_buildid(id, ids, new);
> +	new->id = id;
>  
>  	return id;
>  }
> @@ -430,7 +398,7 @@ static void ipc_kht_remove(struct ipc_ids *ids, struct kern_ipc_perm *ipcp)
>   */
>  void ipc_rmid(struct ipc_ids *ids, struct kern_ipc_perm *ipcp)
>  {
> -	int lid = ipcid_to_idx(ipcp->id);
> +	int lid = ipcp->id;
>  
>  	idr_remove(&ids->ipcs_idr, lid);
>  	ipc_kht_remove(ids, ipcp);
> @@ -563,7 +531,7 @@ void ipc64_perm_to_ipc_perm(struct ipc64_perm *in, struct ipc_perm *out)
>  struct kern_ipc_perm *ipc_obtain_object_idr(struct ipc_ids *ids, int id)
>  {
>  	struct kern_ipc_perm *out;
> -	int lid = ipcid_to_idx(id);
> +	int lid = id;
>  
>  	if (unlikely(!ids->tables_initialized))
>  		return ERR_PTR(-EINVAL);
> @@ -757,30 +725,20 @@ static struct kern_ipc_perm *sysvipc_find_ipc(struct ipc_ids *ids, loff_t pos,
>  					      loff_t *new_pos)
>  {
>  	struct kern_ipc_perm *ipc;
> -	int total, id;
> -
> -	total = 0;
> -	for (id = 0; id < pos && total < ids->in_use; id++) {
> -		ipc = idr_find(&ids->ipcs_idr, id);
> -		if (ipc != NULL)
> -			total++;
> -	}
> +	int id;

I think you need to initialize id to pos. Right?

>  
> -	if (total >= ids->in_use)
> +	/* Out of range - return NULL to terminate iteration */
> +	if (pos > INT_MAX)
>  		return NULL;
>  
> -	for (; pos < IPCMNI; pos++) {
> -		ipc = idr_find(&ids->ipcs_idr, pos);
> -		if (ipc != NULL) {
> -			*new_pos = pos + 1;
> -			rcu_read_lock();
> -			ipc_lock_object(ipc);
> -			return ipc;
> -		}
> -	}
> +	ipc = idr_get_next(&ids->ipcs_idr, &id);
> +	if (!ipc)
> +		return NULL;
>  
> -	/* Out of range - return NULL to terminate iteration */
> -	return NULL;
> +	*new_pos = id + 1;
> +	rcu_read_lock();
> +	ipc_lock_object(ipc);
> +	return ipc;
>  }
>  
>  static void *sysvipc_proc_next(struct seq_file *s, void *it, loff_t *pos)
> diff --git a/ipc/util.h b/ipc/util.h
> index 89b8ec176fc4..de8e27367f0c 100644
> --- a/ipc/util.h
> +++ b/ipc/util.h
> @@ -15,8 +15,6 @@
>  #include <linux/err.h>
>  #include <linux/ipc_namespace.h>
>  
> -#define SEQ_MULTIPLIER	(IPCMNI)
> -
>  int sem_init(void);
>  int msg_init(void);
>  void shm_init(void);
> @@ -93,10 +91,6 @@ void __init ipc_init_proc_interface(const char *path, const char *header,
>  #define IPC_MSG_IDS	1
>  #define IPC_SHM_IDS	2
>  
> -#define ipcid_to_idx(id) ((id) % SEQ_MULTIPLIER)
> -#define ipcid_to_seqx(id) ((id) / SEQ_MULTIPLIER)
> -#define IPCID_SEQ_MAX min_t(int, INT_MAX/SEQ_MULTIPLIER, USHRT_MAX)
> -
>  /* must be called with ids->rwsem acquired for writing */
>  int ipc_addid(struct ipc_ids *, struct kern_ipc_perm *, int);
>  
> @@ -120,9 +114,6 @@ static inline int ipc_get_maxid(struct ipc_ids *ids)
>  	if (ids->in_use == 0)
>  		return -1;
>  
> -	if (ids->in_use == IPCMNI)
> -		return IPCMNI - 1;
> -
>  	return ids->max_id;
>  }
>  
> @@ -163,7 +154,7 @@ extern int store_msg(void __user *dest, struct msg_msg *msg, size_t len);
>  
>  static inline int ipc_checkid(struct kern_ipc_perm *ipcp, int uid)
>  {
> -	return uid / SEQ_MULTIPLIER != ipcp->seq;
> +	return uid != ipcp->seq;
>  }
>  
>  static inline void ipc_lock_object(struct kern_ipc_perm *perm)

I don't know the history why the id management of SysV IPC was designed
in such a convoluted way, but the patch does make sense to me.

Cheers,
Longman
