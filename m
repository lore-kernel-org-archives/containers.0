From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 6/9][cr][v2]: Checkpoint file-locks
Date: Tue, 15 Jun 2010 00:13:27 -0400
Message-ID: <4C16FDE7.7050709__14902.5807193995$1276575243$gmane$org@cs.columbia.edu>
References: <1274238452-15382-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274238452-15382-7-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274238452-15382-7-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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



On 05/18/2010 11:07 PM, Sukadev Bhattiprolu wrote:
> While checkpointing each file-descriptor, find all the locks on the
> file and save information about the lock in the checkpoint-image.
> A follow-on patch will use this informaiton to restore the file-locks.
> 
> Changelog[v2]:
> 	[Matt Helsley]: Use fixed sizes (__s64) instead of 'loff_t' in
> 		'struct ckpt_hdr_file_lock'.
> 	[Matt Helsley, Serge Hallyn]: Highlight new use of BKL (using
> 		lock_flocks() macros as suggested by Serge).
> 	[Matt Helsley]: Reorg code a bit to simplify error handling.
> 	[Matt Helsley]: Reorg code to initialize marker-lock (Pass a
> 		NULL lock to checkpoint_one_lock() to indicate marker).
> 
> Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

[...]

>  
> +static int checkpoint_one_file_lock(struct ckpt_ctx *ctx, struct file *file,
> +		struct file_lock *lock)
> +{
> +	int rc;
> +	struct ckpt_hdr_file_lock *h;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_LOCK);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	if (lock) {
> +		h->fl_start = lock->fl_start;
> +		h->fl_end = lock->fl_end;
> +		h->fl_type = lock->fl_type;
> +		h->fl_flags = lock->fl_flags;
> +	} else {
> +		/* Checkpoint a dummy lock as a marker */
> +		h->fl_start = -1;

Maybe designate some constant for this ?  e.g. CKPT_FLOCK_NONE ?
In any case, you need a (loff_t) -1  (like in the restore code).

[...]

Oren.
