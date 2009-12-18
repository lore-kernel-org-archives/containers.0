From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] ckpt-files: error out on file locks and leases
Date: Fri, 18 Dec 2009 09:47:17 -0600
Message-ID: <20091218154717.GA21943@us.ibm.com>
References: <1261071313-14162-1-git-send-email-dave@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1261071313-14162-1-git-send-email-dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs98uUxBSJOaYoYkZiVZrdSR2LY78lusg7I@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> We do not currently handle the holding of any file locks.
> If a process being checkpointed is holding one, error out
> of the checkpoint process.
> 
> Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Thanks, Dave.  Applied to branch cr-next at
git://git.kernel.org/pub/scm/linux/kernel/git/sergeh/linux-cr.git
(as soon as it mirrors)

So, I think that as of the unimplemented features listed on
http://ckpt.wiki.kernel.org/index.php/Checklist, my cr-next
branch properly refuses to checkpoint all of them except for
sysvipc semaphore undos (which are supposed to be trivial
to implement?) and hardware devices - for which we can claim
that any controls through an fs interface will cause checkpoint
refusal.

So are we happy at this point?

thanks,
-serge

> ---
>  checkpoint/files.c |   12 ++++++++++++
>  fs/locks.c         |   35 +++++++++++++++++++++++++++++++++++
>  include/linux/fs.h |    6 ++++++
>  3 files changed, 53 insertions(+), 0 deletions(-)
> 
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> index b622588..46a103d 100644
> --- a/checkpoint/files.c
> +++ b/checkpoint/files.c
> @@ -272,6 +272,18 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
>  	}
>  	rcu_read_unlock();
> 
> +	ret = find_locks_with_owner(file, files);
> +	/*
> +	 * find_locks_with_owner() returns an error when there
> +	 * are no locks found, so we *want* it to return an error
> +	 * code.  Its success means we have to fail the checkpoint.
> +	 */
> +	if (!ret) {
> +		ret = -EBADF;
> +		ckpt_err(ctx, ret, "%(T)fd %d has file lock or lease\n", fd);
> +		goto out;
> +	}
> +
>  	/* sanity check (although this shouldn't happen) */
>  	ret = -EBADF;
>  	if (!file) {
> diff --git a/fs/locks.c b/fs/locks.c
> index a8794f2..721481a 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1994,6 +1994,41 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
> 
>  EXPORT_SYMBOL(locks_remove_posix);
> 
> +int find_locks_with_owner(struct file *filp, fl_owner_t owner)
> +{
> +	struct inode *inode = filp->f_path.dentry->d_inode;
> +	struct file_lock **inode_fl;
> +	int ret = -EEXIST;
> +
> +	lock_kernel();
> +	for_each_lock(inode, inode_fl) {
> +		struct file_lock *fl = *inode_fl;
> +		/*
> +		 * We could use posix_same_owner() along with a 'fake'
> +		 * file_lock.  But, the fake file will never have the
> +		 * same fl_lmops as the fl that we are looking for and
> +		 * posix_same_owner() would just fall back to this
> +		 * check anyway.
> +		 */
> +		if (IS_POSIX(fl)) {
> +			if (fl->fl_owner == owner) {
> +				ret = 0;
> +				break;
> +			}
> +		} else if (IS_FLOCK(fl) || IS_LEASE(fl)) {
> +			if (fl->fl_file == filp) {
> +				ret = 0;
> +				break;
> +			}
> +		} else {
> +			WARN(1, "unknown file lock type, fl_flags: %x",
> +				fl->fl_flags);
> +		}
> +	}
> +	unlock_kernel();
> +	return ret;
> +}
> +
>  /*
>   * This function is called on the last close of an open file.
>   */
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 5ae34fc..089549b 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1122,6 +1122,7 @@ extern void locks_remove_posix(struct file *, fl_owner_t);
>  extern void locks_remove_flock(struct file *);
>  extern void locks_release_private(struct file_lock *);
>  extern void posix_test_lock(struct file *, struct file_lock *);
> +extern int find_locks_with_owner(struct file *filp, fl_owner_t owner);
>  extern int posix_lock_file(struct file *, struct file_lock *, struct file_lock *);
>  extern int posix_lock_file_wait(struct file *, struct file_lock *);
>  extern int posix_unblock_lock(struct file *, struct file_lock *);
> @@ -1190,6 +1191,11 @@ static inline void locks_remove_posix(struct file *filp, fl_owner_t owner)
>  	return;
>  }
> 
> +static inline int find_locks_with_owner(struct file *filp, fl_owner_t owner)
> +{
> +	return -ENOENT;
> +}
> +
>  static inline void locks_remove_flock(struct file *filp)
>  {
>  	return;
> -- 
> 1.6.6.rc3
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
