From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][cr][PATCH  2/6] Checkpoint file-locks
Date: Tue, 4 May 2010 20:12:56 -0700
Message-ID: <20100505031256.GJ31830@count0.beaverton.ibm.com>
References: <1273023883-19264-1-git-send-email-Sukadev>
	<1273023883-19264-2-git-send-email-Sukadev>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1273023883-19264-2-git-send-email-Sukadev>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, May 04, 2010 at 06:44:39PM -0700, sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org wrote:
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> While checkpointing each file-descriptor, find all the locks on the
> file and save information about the lock in the checkpoint-image.
> A follow-on patch will use this informaiton to restore the file-locks.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  fs/checkpoint.c                |   98 ++++++++++++++++++++++++++++++++++-----
>  include/linux/checkpoint_hdr.h |   10 ++++
>  2 files changed, 95 insertions(+), 13 deletions(-)
> 
> diff --git a/fs/checkpoint.c b/fs/checkpoint.c
> index e036a7a..180302e 100644
> --- a/fs/checkpoint.c
> +++ b/fs/checkpoint.c
> @@ -26,6 +26,7 @@
>  #include <linux/checkpoint.h>
>  #include <linux/eventpoll.h>
>  #include <linux/eventfd.h>
> +#include <linux/smp_lock.h>
>  #include <net/sock.h>
> 
>  /**************************************************************************
> @@ -249,8 +250,86 @@ static int checkpoint_file(struct ckpt_ctx *ctx, void *ptr)
>  	return ret;
>  }
> 
> +static int checkpoint_one_file_lock(struct ckpt_ctx *ctx, struct file *file,
> +		int fd, struct file_lock *lock)

fd is only used for debugging info. Probably ought to remove it.

> +{
> +	int rc;
> +	struct ckpt_hdr_file_lock *h;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_LOCK);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	h->fl_start = lock->fl_start;
> +	h->fl_end = lock->fl_end;
> +	h->fl_type = lock->fl_type;
> +	h->fl_flags = lock->fl_flags;
> +
> +	rc = ckpt_write_obj(ctx, &h->h);
> +
> +	ckpt_hdr_put(ctx, h);
> +
> +	ckpt_debug("Lock [%lld, %lld, %d, 0x%x] fd %d, rc %d\n", lock->fl_start,
> +			lock->fl_end, lock->fl_type, lock->fl_flags, fd, rc);
> +
> +	return rc;
> +}
> +
> +int
> +checkpoint_file_locks(struct ckpt_ctx *ctx, struct files_struct *files,
> +		struct file *file, int fd)
> +{
> +	int rc;
> +	struct inode *inode;
> +	struct file_lock **lockpp;
> +	struct file_lock *lockp;
> +	struct file_lock last_lock;
> +
> +	lock_kernel();

Eep. What are the current standards as far as adding "new" uses of the BKL?
Arnd/anti-BKL-ninjas might be good folks to Cc on the next round if this
is still here.

Regardless, I'd think some good comments about the kernel-locking are in
order so that when this BKL use is being removed those involved can easily
know what it's meant to protect.

> +	inode = file->f_path.dentry->d_inode;
> +	for_each_lock(inode, lockpp) {
> +		lockp = *lockpp;
> +		ckpt_debug("Found lock [%lld, %lld, %d, 0x%x]\n",
> +				lockp->fl_start, lockp->fl_end, 
> +				lockp->fl_type, lockp->fl_flags);
> +
> +		if (lockp->fl_owner != files)
> +			continue;
> +

Maybe a stupid idea:
		rc = -EBADF;
> +		if (IS_POSIX(lockp)) {
> +			rc = checkpoint_one_file_lock(ctx, file, fd, lockp);

Remove the other contents of this block.

> +			if (rc < 0) {
> +				ckpt_err(ctx,  rc, "%(T)fd %d, checkpoint "
> +						"lock failed\n", fd);
> +				goto out;
> +			}
> +		} else {

		if (rc < 0) {

> +			ckpt_err(ctx, rc, "%(T)fd %d has unsupported file "
> +					"lock type, flags 0x%x\n", fd,
> +					lockp->fl_flags);
> +			goto out;
> +		}
> +	}

I say maybe stupid because it may not follow accepted patterns and coalesces
two ckpt_err() reports into something more complex or ambiguous.

> +
> +	/*
> +	 * Checkpoint a dummy file-lock to mark the end of file-locks
> +	 * for this fd.
> +	 */
> +	memset(&last_lock, 0, sizeof(struct file_lock));
> +	last_lock.fl_start = -1;
> +	last_lock.fl_flags = FL_POSIX;
> +	rc = checkpoint_one_file_lock(ctx, file, fd, &last_lock);

Seems like you could just pull allocation of h out of checkpoint_one_file_lock,
pass it as a parameter to that function, then outside the loop
fill out the "dummy" here, and call:

	rc = ckpt_write_obj(ctx, &h->h);

directly instead of inventing a last_lock struct.

> +	if (rc < 0)
> +		ckpt_err(ctx,  rc, "%(T)fd %d, checkpoint last-lock failed\n",
> +				fd);
> +out:
> +	unlock_kernel();
> +	return rc;
> +}
> +
>  /**
> - * ckpt_write_file_desc - dump the state of a given file descriptor
> + * checkpoint_file_desc - dump the state of a given file descriptor
>   * @ctx: checkpoint context
>   * @files: files_struct pointer
>   * @fd: file descriptor
> @@ -282,18 +361,6 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
>  	}
>  	rcu_read_unlock();
> 
> -	ret = find_locks_with_owner(file, files);
> -	/*
> -	 * find_locks_with_owner() returns an error when there
> -	 * are no locks found, so we *want* it to return an error
> -	 * code.  Its success means we have to fail the checkpoint.
> -	 */
> -	if (!ret) {
> -		ret = -EBADF;
> -		ckpt_err(ctx, ret, "%(T)fd %d has file lock or lease\n", fd);
> -		goto out;
> -	}
> -
>  	/* sanity check (although this shouldn't happen) */
>  	ret = -EBADF;
>  	if (!file) {
> @@ -328,6 +395,11 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
>  	h->fd_close_on_exec = coe;
> 
>  	ret = ckpt_write_obj(ctx, &h->h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = checkpoint_file_locks(ctx, files, file, fd);
> +
>  out:
>  	ckpt_hdr_put(ctx, h);
>  	if (file)
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 790214f..d2a0fcd 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -144,6 +144,8 @@ enum {
>  #define CKPT_HDR_TTY_LDISC CKPT_HDR_TTY_LDISC
>  	CKPT_HDR_EPOLL_ITEMS,  /* must be after file-table */
>  #define CKPT_HDR_EPOLL_ITEMS CKPT_HDR_EPOLL_ITEMS
> +	CKPT_HDR_FILE_LOCK,
> +#define CKPT_HDR_FILE_LOCK CKPT_HDR_FILE_LOCK
> 
>  	CKPT_HDR_MM = 401,
>  #define CKPT_HDR_MM CKPT_HDR_MM
> @@ -576,6 +578,14 @@ struct ckpt_hdr_file_generic {
>  	struct ckpt_hdr_file common;
>  } __attribute__((aligned(8)));
> 
> +struct ckpt_hdr_file_lock {
> +       struct ckpt_hdr h;
> +       loff_t fl_start;
> +       loff_t fl_end;

fl_start and fl_end are file positions, aren't they?

loff_t is, unfortunately, a notoriously ambiguous type -- it doesn't
meet our standards for a biarch-safe checkpoint image. I think a u64,
like ckpt_hdr_file's f_pos field, is called for.

Cheers,
	-Matt Helsley
