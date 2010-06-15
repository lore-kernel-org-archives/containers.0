From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC][PATCH 3/3][cr][v2]: fileleases: C/R of an in-progress lease.
Date: Tue, 15 Jun 2010 00:43:18 -0400
Message-ID: <4C1704E6.90300__43055.3217222497$1276577029$gmane$org@cs.columbia.edu>
References: <1274836063-13271-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274836063-13271-4-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274836063-13271-4-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
> If process P1 has a F_WRLCK lease on file F1 and process P2 opens the
> file, P2's open() blocks for lease_break_time (45 seconds) and P1 gets
> a SIGIO to cleanup it lease in preparation for P2's open.  If the two
> processes are checkpointed/restarted in this window, we should address
> following two issues:
> 
> 	- P1 should get a SIGIO only once for the lease (i.e if P1 got the
> 	  SIGIO before checkpoint, it should not get the SIGIO after restart).
> 
> 	- If R seconds remain in the lease, P2's open should be blocked for
> 	  at least the R seconds, so P1 has the time to clean up its lease.
> 	  The previous patch gives P1 the entire lease_break_time but that
> 	  can leave P2 stalled for 2*lease_break_time.
> 
> To address first, we add a field ->fl_break_notified to "remember" if we
> notified the lease-holder already. We save this field in the checkpoint
> image and when restarting, we notify the lease-holder only if this field
> is not set.
> 
> To address the second issue, we also checkpoint the ->fl_break_time for
> an in-progress lease. When restarting the process, we ensure that the
> lease-holder sleeps only for the remaining-lease rather than the entire
> lease.
> 
> These two fixes sound like an approximation (see comments in do_setlease()
> and __break_lease() below) and are also a bit kludgy (hence a separate patch
> for now).
> 
> Appreciate comments on how we can do this better. Specifically:
> 
> 	- do we even need to try and address the second issue above or
> 	  just let P1 have the entire lease_break_time again ?
> 
> 	- theoretically, the R seconds should start counting after *all*
> 	  processes in the application-process tree have been restarted,
> 	  since P1 waits inside the kernel for a portion of the remaining
> 	  lease - should we then add a delta to R ?

[...]

> @@ -1084,7 +1088,8 @@ static int restore_file_locks(struct ckpt_ctx *ctx, struct file *file, int fd)
>  			type = h->fl_type;
>  			if (h->fl_type & F_INPROGRESS)
>  				type = h->fl_type_prev;
> -			ret = do_setlease(fd, file, type, h->fl_rem_lease);
> +			ret = do_setlease(fd, file, type, h->fl_rem_lease,
> +					h->fl_break_notified);

Is h->fl_break_notified sanitized ?

Oren.
