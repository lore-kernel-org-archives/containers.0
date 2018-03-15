From: Matthew Wilcox <willy-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [RFC][PATCH] ipc: Remove IPCMNI
Date: Thu, 15 Mar 2018 12:45:27 -0700
Message-ID: <20180315194527.GB17574__21846.4286685505$1521143031$gmane$org@bombadil.infradead.org>
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
Content-Disposition: inline
In-Reply-To: <87woyego2u.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Luis R. Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Waiman Long <longman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Mar 14, 2018 at 07:49:29PM -0500, Eric W. Biederman wrote:
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

We have a helper for this:

	idr_for_each_entry(&ids->ipcs_idr, perm, next_id) {
		rcu_read_lock();
		ipc_lock_object(perm);
		free(ns, perm);
	}

(using idr_get_next() is tricky because you have to remember to increment
next_id yourself, and you didn't).

> +static int ipc_idr_alloc(struct ipc_ids *ids, struct kern_ipc_perm *new)
>  {
> +#ifdef CONFIG_CHECKPOINT_RESTORE
> +	if (ids->next_id >= 0) {
> +		idr_set_cursor(&ids->ipcs_idr, ids->next_id);
>  		ids->next_id = -1;
>  	}
> +#endif
> +	return idr_alloc_cyclic(&ids->ipcs_idr, (new), 0, 0, GFP_NOWAIT);
>  }
>  
> -#endif /* CONFIG_CHECKPOINT_RESTORE */

That seems a little convoluted; is there a reason to not call idr_set_cursor()
instead of assigning to ids->next_id?

> @@ -757,30 +725,20 @@ static struct kern_ipc_perm *sysvipc_find_ipc(struct ipc_ids *ids, loff_t pos,
>  					      loff_t *new_pos)
>  {
>  	struct kern_ipc_perm *ipc;
> +	int id;
>  
> +	/* Out of range - return NULL to terminate iteration */
> +	if (pos > INT_MAX)
>  		return NULL;
>  
> +	ipc = idr_get_next(&ids->ipcs_idr, &id);
> +	if (!ipc)
> +		return NULL;
>  
> +	*new_pos = id + 1;
> +	rcu_read_lock();
> +	ipc_lock_object(ipc);
> +	return ipc;
>  }

I'm no expert on the IPC locking, but I would have thought you'd want to
call rcu_read_lock() before calling idr_get_next() to avoid a simultaneous
delete from freeing 'ipc'.

Oh, I see.  proc_start takes the rwsem for read and proc_stop releases it.
The locking here seems quite shabby and in need of renovation.
