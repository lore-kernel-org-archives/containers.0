From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add support for the per-task sem_undo list (v3.01)
Date: Thu, 05 Aug 2010 18:40:57 -0400
Message-ID: <4C5B3DF9.4000907@cs.columbia.edu>
References: <1281031026-2357-1-git-send-email-danms@us.ibm.com>	<1281031026-2357-3-git-send-email-danms@us.ibm.com>
	<20100805214842.GP2927@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100805214842.GP2927-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



On 08/05/2010 05:48 PM, Matt Helsley wrote:
> On Thu, Aug 05, 2010 at 10:57:06AM -0700, Dan Smith wrote:
>> The semaphore undo list is a set of adjustments to be made to semaphores
>> held by a task on exit.  Right now, we do not checkpoint or restore this
>> list which could cause undesirable behavior by a restarted process on exit.

[...]

>> +{
>> +	int i;
>> +	int ret;
>> +
>> +	for (i = 0; i<  count; i++) {
>> +		struct sem_undo *un;
>> +
>> +		spin_lock(&ulp->lock);
>> +		un = lookup_undo(ulp, semids[i]);
>> +		spin_unlock(&ulp->lock);
>> +
>> +		if (!un) {
>> +			ckpt_debug("unable to lookup semid %i\n", semids[i]);
>
> Or should this be a ckpt_err() ?

This is not supposed to happen: the semdis[] array was
extracted just before, and it should not be possible for
them to disappear (at least in the container-checkpoint
case, where tasks are frozen and ipcns does not leak).

>
>> +			return -EINVAL;
>> +		}
>> +
>> +		ret = checkpoint_sem_undo_adj(ctx, un);
>> +		ckpt_debug("checkpoint_sem_undo: %i\n", ret);
>> +		if (ret<  0)
>> +			return ret;
>> +	}
>> +
>> +	return 0;
>> +}
>
> <snip>
>
>> +static int restore_task_sem_undo_adj(struct ckpt_ctx *ctx)

Now that Matt said it ... I suggest to rename this too to
something like "restore_sem_undo_adj()" :)

(Interestingly, the checkpoint counterpart is named so !)

>> +{
>> +	struct ckpt_hdr_task_sem_undo *h;
>> +	int len;
>> +	int ret = -ENOMEM;
>> +	struct sem_undo *un;
>> +	int nsems;
>> +	__s16 *semadj = NULL;
>> +
>> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_SEM_UNDO);
>> +	if (IS_ERR(h))
>> +		return PTR_ERR(h);
>> +
>> +	len = sizeof(__s16) * h->semadj_count;
>> +	ret = ckpt_read_payload(ctx, (void **)&semadj, len, CKPT_HDR_BUFFER);
>> +	if (ret<  0)
>> +		goto out;
>> +
>
> As best I can tell exit_sem() does not do permission checking -- it
> relies on semop and semtimedop to check permissions on the operation
> that created the undo in the first place. Thus I think we need to check
> permissions here with ipc_check_perms() or ipcperms(). Otherwise it may
> be possible to manipulate semaphores we do not have permission to
> manipulate.

Good catch !

>
>> +	un = find_alloc_undo(current->nsproxy->ipc_ns, h->semid);
>> +	if (IS_ERR(un)) {
>> +		ret = PTR_ERR(un);
>> +		ckpt_debug("unable to find semid %i\n", h->semid);
>> +		goto out;
>> +	}
>> +
>> +	nsems = sem_undo_nsems(un, current->nsproxy->ipc_ns);
>> +	len = sizeof(__s16) * nsems;
>> +	if (h->semadj_count == nsems)
>> +		memcpy(un->semadj, semadj, len);
>> +	rcu_read_unlock();
>> +
>> +	if (nsems != h->semadj_count)
>> +		ckpt_err(ctx, -EINVAL,
>> +			 "semid %i has nmsems=%i but %i undo adjustments\n",
>> +			 h->semid, nsems, h->semadj_count);
>> +	else
>> +		ckpt_debug("semid %i restored with %i adjustments\n",
>> +			   h->semid, h->semadj_count);
>> + out:
>> +	ckpt_hdr_put(ctx, h);
>> +	kfree(semadj);
>> +
>> +	return ret;
>> +}
>> +
>> +static void *restore_sem_undo(struct ckpt_ctx *ctx)
>> +{
>> +	struct ckpt_hdr_task_sem_undo_list *h;
>> +	struct sem_undo_list *ulp = NULL;
>> +	int i;
>> +	int ret = 0;
>> +
>> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_TASK_SEM_UNDO_LIST);
>> +	if (IS_ERR(h))
>> +		return ERR_PTR(PTR_ERR(h));
>> +

Maybe add this:
	/*
	 * On success, alloc_undo_list() attaches the new @ulp
	 * to current task - so no need for explicit cleanup
	 */
>> +	ulp = alloc_undo_list(current->nsproxy->ipc_ns);
>> +	if (!ulp) {
>> +		ret = -ENOMEM;
>> +		goto out;
>> +	}
>> +
>> +	for (i = 0; i<  h->count; i++) {
>> +		ret = restore_task_sem_undo_adj(ctx);
>> +		if (ret<  0)
>> +			goto out;
>> +	}
>> +

Maybe add this:

	/* success: account for reference in the objhash*/
>> +	atomic_inc(&ulp->refcnt);
>> + out:
>> +	ckpt_hdr_put(ctx, h);
>> +	if (ret<  0)
>
> Don't we need to check ulp and clean up the alloc'd undo list here?

No: the ulp is attached to current ask (a side effect of
alloc_undo_list) so will be freed when the task exits.
The addition atomic_inc() is only performed on success,
to account for it being added to the hash once we return.

Dan: I suggest to add the comment above to make it clear.

Oren.
