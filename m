From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] eventfd: Add missing spin locks around eventfd checkpoint.
Date: Sat, 24 Apr 2010 19:58:07 -0400
Message-ID: <4BD3858F.3030501@cs.columbia.edu>
References: <b0c0f47c8211da3ecb0163afd17be1446a10919d.1271434051.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <b0c0f47c8211da3ecb0163afd17be1446a10919d.1271434051.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


Applied for ckpt-v21-rc3


Matt Helsley wrote:
> Ensure that we get a consistent set of count and flag values at checkpoint
> by locking the eventfd structures to prevent races with non-frozen tasks
> sharing the underlying struct file *.
> 
> The locking during restart is fine since it relies entirely on the eventd
> creation syscall.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  fs/eventfd.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/eventfd.c b/fs/eventfd.c
> index e412a02..65307e0 100644
> --- a/fs/eventfd.c
> +++ b/fs/eventfd.c
> @@ -303,8 +303,10 @@ static int eventfd_checkpoint(struct ckpt_ctx *ckpt_ctx, struct file *file)
>  	if (ret < 0)
>  		goto out;
>  	ctx = file->private_data;
> +	spin_lock_irq(&ctx->wqh.lock);
>  	h->count = ctx->count;
>  	h->flags = ctx->flags;
> +	spin_unlock_irq(&ctx->wqh.lock);
>  	ret = ckpt_write_obj(ckpt_ctx, &h->common.h);
>  out:
>  	ckpt_hdr_put(ckpt_ctx, h);
