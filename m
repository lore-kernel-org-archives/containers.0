From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/3][cr][v2]: Checkpoint/restart file leases
Date: Tue, 15 Jun 2010 00:40:16 -0400
Message-ID: <4C170430.2030708__21308.6812677377$1276576863$gmane$org@cs.columbia.edu>
References: <1274836063-13271-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274836063-13271-3-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274836063-13271-3-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, matthew-Ztpu424NOJ8@public.gmane.org
List-Id: containers.vger.kernel.org



On 05/25/2010 09:07 PM, Sukadev Bhattiprolu wrote:
> Build upon the C/R of file-locks to C/R file-leases. C/R of a lease that is
> not being broken is almost identical to C/R of file-locks.  i.e save the type
> of lease for the file in the checkpoint image and when restarting, restore
> the lease by calling do_setlease().
> 
> C/R of file-lease gets complicated (I think), if a process is checkpointed
> when its lease was being revoked. i.e if P1 has a F_WRLCK lease on file F1
> and P2 opens F1 for write, P2's open is blocked for lease_break_time (45 secs).
> P1's lease is revoked (i.e set to F_UNLCK) and P1 is notified via a SIGIO to
> flush any dirty data.
> 
> This brings up two issues:
> 
> First, if P1 is checkpointed during this lease_break_time, we need to remember
> to that P1 originally had a F_WRLCK lease which is now revoked to F_UNLCK.
> Checkpointing the "current lease type" would wrongly save the lease-type as
> F_UNLCK.
> 
> Secondly, if P1 was checkpointed 40 seconds into the lease_break_time,(i.e.
> it had 5 seconds remaining in the lease), we want to ensure that after restart,
> P1 gets at least 5 more seconds in the lease (no ?). (i.e P1 could be in the
> its SIGIO handler when it was checkpointed and may be about to start a new
> write(). If P1 does not gets its 5 seconds and P2's open and a read()
> completes, we would have a data corruption).
> 
> This patch addresses the first issue above by adding file_lock->fl_type_prev
> field. When a lease is downgraded/revoked, the original lease type is saved
> in ->fl_type_prev and is also checkpointed. When the process P1 is restarted,
> the kernel temporarily restores the original (F_WRLCK) lease.  When process
> P2 is restarted, the open() would fail with -ERESTARTSYS and the open() would
> be repeated. This open() would initiate the lease-break protocol again on P1.
> 
> To address the second issue above, this patch saves the remaining-lease in
> the checkpoint image, but does not (yet) use this value. The plan is to use
> this remaining-lease period when P1/P2 are restarted so that P2 is blocked
> only for the remaining-lease rather than entire lease_break_time. I want to
> check if there are better ways to address this.

[...]

> @@ -280,8 +280,14 @@ static int checkpoint_one_file_lock(struct ckpt_ctx *ctx, struct file *file,
>  	if (lock) {
>  		h->fl_start = lock->fl_start;
>  		h->fl_end = lock->fl_end;
> +		/* checkpoint F_INPROGRESS if set for now */

Did I miss anything -- what is F_INPROGRESS ?

>  		h->fl_type = lock->fl_type;
> +		h->fl_type_prev = lock->fl_type_prev;
>  		h->fl_flags = lock->fl_flags;
> +		if (h->fl_type & F_INPROGRESS && 
> +					(lock->fl_break_time > jiffies))
> +			h->fl_rem_lease = (lock->fl_break_time - jiffies) / HZ;

Hmmm -- we have a ctx->ktime_begin marking the start of the checkpoint.
It is used for relative-time calculations, for example, the expiry of
restart-blocks and timeouts.  I suggest that we use it here too to be
consistent.

> +
>  	} else {
>  		/* Checkpoint a dummy lock as a marker */
>  		h->fl_start = -1;
> @@ -315,7 +321,7 @@ checkpoint_file_locks(struct ckpt_ctx *ctx, struct files_struct *files,
>  			continue;
>  
>  		rc = -EBADF;
> -		if (IS_POSIX(lockp))
> +		if (IS_POSIX(lockp) || IS_LEASE(lockp))
>  			rc = checkpoint_one_file_lock(ctx, file, lockp);
>  
>  		if (rc < 0) {
> @@ -1055,8 +1061,10 @@ static int restore_file_locks(struct ckpt_ctx *ctx, struct file *file, int fd)
>  		if (IS_ERR(h))
>  			return PTR_ERR(h);
>  
> -		ckpt_debug("Lock [%lld, %lld, %d, 0x%x]\n", h->fl_start,
> -				h->fl_end, (int)h->fl_type, h->fl_flags);
> +		ckpt_debug("Lock [%lld, %lld, %d, 0x%x], rem-lease %lus, "
> +				"fl-type-prev %d\n", h->fl_start, h->fl_end,
> +				(int)h->fl_type, h->fl_flags, h->fl_rem_lease,
> +				h->fl_type_prev);
>  
>  		/*
>  		 * If it is a dummy-lock, we are done with this fd.
> @@ -1070,6 +1078,17 @@ static int restore_file_locks(struct ckpt_ctx *ctx, struct file *file, int fd)
>  		if (h->fl_flags & FL_POSIX)
>  			ret = restore_one_file_lock(ctx, file, fd, h); 
>  
> +		else if (h->fl_flags & FL_LEASE) {
> +			int type;
> +
> +			type = h->fl_type;
> +			if (h->fl_type & F_INPROGRESS)
> +				type = h->fl_type_prev;
> +			ret = do_setlease(fd, file, type, h->fl_rem_lease);

Do we need to sanitize the "type" argument ?
or the h->fl_rem_lease ?
or h->fl_type_prev ?  (which is taken blindly here)

> +			if (ret)
> +				ckpt_err(ctx, ret, "do_setlease(): %d\n", type);
> +		}
> +
>  		if (ret < 0)
>  			ckpt_err(ctx, ret, "%(T) fl_flags 0x%x\n", h->fl_flags);
>  	}
> diff --git a/fs/locks.c b/fs/locks.c
> index 4107295..7a80278 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -184,6 +184,8 @@ void locks_init_lock(struct file_lock *fl)
>  	fl->fl_file = NULL;
>  	fl->fl_flags = 0;
>  	fl->fl_type = 0;
> +	fl->fl_type_prev = 0;
> +	fl->fl_break_time = 0UL;
>  	fl->fl_start = fl->fl_end = 0;
>  	fl->fl_ops = NULL;
>  	fl->fl_lmops = NULL;
> @@ -291,6 +293,13 @@ static int assign_type(struct file_lock *fl, int type)
>  	case F_WRLCK:
>  	case F_UNLCK:
>  		fl->fl_type = type;
> +		/*
> +		 * Clear fl_type_prev since we now have a new lease-type.
> +		 * That way, break_lease() will know to save the new lease-type
> +		 * in case of a checkpoint. (non-lease file-locks don't use
> +		 * ->fl_type_prev).  
> +		 */
> +		fl->fl_type_prev = 0;
>  		break;
>  	default:
>  		return -EINVAL;
> @@ -1211,6 +1220,16 @@ int __break_lease(struct inode *inode, unsigned int mode)
>  		goto out;
>  	}
>  
> +	/*
> +	 * TODO: Checkpoint/restart. Suppose lease_break_time was 45 seonds and
> +	 * 	 we were checkpointed when we had 35 seconds remaining in our
> +	 * 	 lease. When we are restarted, should we get only 35 seconds
> +	 * 	 of the lease and not the full lease_break_time ?
> +	 *
> +	 * 	 We checkpoint ->fl_break_time in the hope that we can use it
> +	 * 	 to calculate the remaining lease, but for now, give the
> +	 * 	 restarted process the full 'lease_break_time'.
> +	 */
>  	break_time = 0;
>  	if (lease_break_time > 0) {
>  		break_time = jiffies + lease_break_time * HZ;

Here, too, use ctx->ktime_begin

> @@ -1220,8 +1239,29 @@ int __break_lease(struct inode *inode, unsigned int mode)
>  
>  	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
>  		if (fl->fl_type != future) {
> +			/*
> +			 * CHECK:
> +			 *
> +			 * If fl_type_prev is already set, we could be in a
> +			 * recursive checkpoint-restart i.e we were checkpointed
> +			 * once when our lease was being broken. We were then
> +			 * restarted from the checkpoint and checkpointed
> +			 * again before the restored lease expired. In this
> +			 * case, we want to restore the lease to the original
> +			 * type. So don't overwrite fl_type_prev if its already
> +			 * set.
> +			 */
> +			if (!fl->fl_type_prev)
> +				fl->fl_type_prev = fl->fl_type;
>  			fl->fl_type = future;
>  			fl->fl_break_time = break_time;
> +
> +			/*
> +			 * TODO: ->fl_break() sends the SIGIO to lease-holder.
> +			 *       If lease-holder was checkpointed/restarted and
> +			 *       this is a restarted lease, we should not
> +			 *       re-send the SIGIO ?
> +			 */
>  			/* lease must have lmops break callback */
>  			fl->fl_lmops->fl_break(fl);
>  		}
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 4509016..ddad73f 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -588,7 +588,9 @@ struct ckpt_hdr_file_lock {
>         __s64 fl_start;
>         __s64 fl_end;
>         __u8 fl_type;
> +       __u8 fl_type_prev;
>         __u8 fl_flags;
> +       unsigned long fl_rem_lease;

Mis-alignment :(

>  };
>  
>  struct ckpt_hdr_file_pipe {
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 700317a..54b2a7b 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1066,6 +1066,7 @@ struct file_lock {
>  	fl_owner_t fl_owner;
>  	unsigned char fl_flags;
>  	unsigned char fl_type;
> +	unsigned char fl_type_prev;
>  	unsigned int fl_pid;
>  	struct pid *fl_nspid;
>  	wait_queue_head_t fl_wait;

Oren.
