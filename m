From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 9/8] restore_sigpending: fix reversed list_add_tail
	arguments
Date: Tue, 13 Jul 2010 16:36:12 -0700
Message-ID: <20100713233612.GI17990@count0.beaverton.ibm.com>
References: <1279035864-10533-1-git-send-email-ntl@pobox.com>
	<1279059777.3002.1282.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1279059777.3002.1282.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jul 13, 2010 at 05:22:57PM -0500, Nathan Lynch wrote:
> A testcase that posts several realtime signals via sigqueue before C/R
> uncovered this.  Without this change only the first queued signal is
> delivered after restart.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Nice catch!

Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
> 
> [only noticed this after posting the series, oops]
> 
>  kernel/signal.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/signal.c b/kernel/signal.c
> index cc7aee9..ba8a623 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -3277,7 +3277,7 @@ static int restore_sigpending(struct ckpt_ctx *ctx, struct sigpending *pending)
>  		}
> 
>  		q->flags &= ~SIGQUEUE_PREALLOC;
> -		list_add_tail(&pending->list, &q->list);
> +		list_add_tail(&q->list, &pending->list);
>  	}
> 
>  	if (ret < 0)
> -- 
> 1.7.1.1
> 
> 
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
