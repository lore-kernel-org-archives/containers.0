From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Fix ckpt_write_err() check for empty string
Date: Fri, 2 Oct 2009 20:24:51 -0700
Message-ID: <20091003032451.GB18101@count0.beaverton.ibm.com>
References: <1254531987-13008-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1254531987-13008-1-git-send-email-matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Oct 02, 2009 at 06:06:27PM -0700, Matt Helsley wrote:
> The test for empty error strings does not work because we always add 2
> to len before testing if it's 0. Fix by checking before adding 2.

It occurs to me that this should be an [RFC] patch because there are
two alternative solutions:

1. Compare to 2 after addition

2. Drop the check altogether -- the result will be an empty string in the
	checkpoint image. This means that ckpt_write_err() would always
	output a CKPT_HDR_ERROR with at least an empty string. I wonder
	if this wouldn't be preferrable to no CKPT_HDR_ERROR at all.

Cheers,
	-Matt Helsley

> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/checkpoint.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index 1eeb557..bcd5d86 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -258,11 +258,11 @@ int ckpt_write_err(struct ckpt_ctx *ctx, char *pre, char *fmt, ...)
>  	}
> 
>  	str = ctx->err_string;
> -	len = strlen(str + 1) + 2;	/* leading and trailing '\0' */
> -
> +	len = strlen(str + 1);
>  	if (len == 0)	/* empty error string */
>  		return 0;
> 
> +	len += 2; 	/* leading and trailing '\0' */
>  	ret = ckpt_write_obj_type(ctx, NULL, 0, CKPT_HDR_ERROR);
>  	if (!ret)
>  		ret = ckpt_write_string(ctx, str, len);
> -- 
> 1.5.6.3
> 
