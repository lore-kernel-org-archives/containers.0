From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 11/17][cr][v4]: Add ->fl_type_prev field.
Date: Thu, 16 Sep 2010 20:06:46 -0400
Message-ID: <4C92B116.7060601__39759.446893777$1284682154$gmane$org@cs.columbia.edu>
References: <1281987801-1293-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1281987801-1293-12-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1281987801-1293-12-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Jamie Lokier <jamie-yetKDKU6eevNLxjTenLetw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Steven Whitehouse <swhiteho-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



On 08/16/2010 03:43 PM, Sukadev Bhattiprolu wrote:
> In preparation for checkpoint/restart of file leases, add ->fl_type_prev
> field to 'struct file_lock'. This field is needed to correctly restore
> file leases in case of recursive checkpoint/restart of an in-progress
> lease.

Nit: since it isn't obvious why fl_type_prev field exists,
maybe add this comment also inside fs.h  (so that future
readers won't need to look it up in the git history) ?

Oren.

> 
> This ->fl_type_prev is only initialized in this patch. It will actually
> be used when restoring file leases after a checkpoint.
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
>  fs/locks.c         |   10 ++++++++++
>  include/linux/fs.h |    1 +
>  2 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index 0bd5af7..9a00876 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -184,6 +184,7 @@ void locks_init_lock(struct file_lock *fl)
>  	fl->fl_file = NULL;
>  	fl->fl_flags = 0;
>  	fl->fl_type = 0;
> +	fl->fl_type_prev = 0;
>  	fl->fl_start = fl->fl_end = 0;
>  	fl->fl_break_time = 0UL;
>  	fl->fl_ops = NULL;
> @@ -227,6 +228,7 @@ void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
>  	new->fl_file = NULL;
>  	new->fl_flags = fl->fl_flags;
>  	new->fl_type = fl->fl_type;
> +	new->fl_type_prev = fl->fl_type_prev;
>  	new->fl_start = fl->fl_start;
>  	new->fl_end = fl->fl_end;
>  	new->fl_break_time = 0UL;
> @@ -293,6 +295,13 @@ static int assign_type(struct file_lock *fl, int type)
>  	case F_WRLCK:
>  	case F_UNLCK:
>  		fl->fl_type = type;
> +		/*
> +		 * Clear ->fl_type_prev since this is a new lease type.
> +		 * break_lease() will use this cleared state to know
> +		 * if it must save the lease-type in case of checkpoint/
> +		 * restart.
> +		 */
> +		fl->fl_type_prev = 0;
>  		break;
>  	default:
>  		return -EINVAL;
> @@ -1222,6 +1231,7 @@ int __break_lease(struct inode *inode, unsigned int mode)
>  
>  	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
>  		if (fl->fl_type != future) {
> +			fl->fl_type_prev = fl->fl_type;
>  			fl->fl_type = future;
>  			fl->fl_break_time = break_time;
>  			/* lease must have lmops break callback */
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 49d4eeb..299cc09 100644
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
