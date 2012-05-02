From: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Subject: Re: [PATCH 05/11] block: drop custom queue draining used by
	scsi_transport_{iscsi|fc}
Date: Tue, 01 May 2012 23:55:49 -0500
Message-ID: <4FA0BE55.2000305__10660.9363494956$1335935242$gmane$org@cs.wisc.edu>
References: <1335477561-11131-1-git-send-email-tj@kernel.org>
	<1335477561-11131-6-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1335477561-11131-6-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, James Smart <james.smart-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 04/26/2012 04:59 PM, Tejun Heo wrote:
> iscsi_remove_host() uses bsg_remove_queue() which implements custom
> queue draining.  fc_bsg_remove() open-codes mostly identical logic.
> 
> The draining logic isn't correct in that blk_stop_queue() doesn't
> prevent new requests from being queued - it just stops processing, so
> nothing prevents new requests to be queued after the logic determines
> that the queue is drained.
> 
> blk_cleanup_queue() now implements proper queue draining and these
> custom draining logics aren't necessary.  Drop them and use
> bsg_unregister_queue() + blk_cleanup_queue() instead.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>
> Cc: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
> Cc: James Smart <james.smart-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org>
> ---
>  block/bsg-lib.c                     |   53 -----------------------------------
>  drivers/scsi/scsi_transport_fc.c    |   38 -------------------------
>  drivers/scsi/scsi_transport_iscsi.c |    2 +-

iSCSI changes worked ok for me. I replicated the problem that the old
code was supposed to fix and verified the new code worked ok. I also
tested the FC code briefly (I do not have a proper setup to really
stress it), and it worked ok.

Thanks for killing that code for us.

Reviewed-by: Mike Christie <michaelc@.cs.wisc.edu>
