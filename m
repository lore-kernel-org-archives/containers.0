From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] print the number of bytes processed in ckpt_error()
Date: Fri, 23 Oct 2009 10:42:08 -0700
Message-ID: <20091023174208.GC15092@count0.beaverton.ibm.com>
References: <20091023170529.GA23079@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091023170529.GA23079-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Oct 23, 2009 at 12:05:29PM -0500, Serge E. Hallyn wrote:
> This should be useful at restart to indicate how much we have
> processed before running into an error.
> 
> This only adds it to the user log for now, bc the syslog
> printing macro is expected to totally change anyway.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Should be quite useful for users trying to pinpoint the source of
restart problems in their checkpoint images.

Acked-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  checkpoint/sys.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/checkpoint/sys.c b/checkpoint/sys.c
> index 1840f90..a7fe1f8 100644
> --- a/checkpoint/sys.c
> +++ b/checkpoint/sys.c
> @@ -361,7 +361,7 @@ void ckpt_log_error(struct ckpt_ctx *ctx, char *fmt, ...)
>  		return;
>  	file = ctx->logfile;
> 
> -	count = snprintf(buf, 200, "%d:%d ", mypid, tpid);
> +	count = snprintf(buf, 200, "%d:%d@%d ", mypid, tpid, ctx->total);
>  	if (count > 200)
>  		return; /* not possible */
>  	fs = get_fs();
> -- 
> 1.6.1
