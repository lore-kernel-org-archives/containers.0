From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/5] Add a ckpt_read_string() function (v3)
Date: Wed, 12 Aug 2009 02:17:36 -0400
Message-ID: <4A825E80.70807@librato.com>
References: <1249918379-29414-1-git-send-email-danms@us.ibm.com>
	<1249918379-29414-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1249918379-29414-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


I ended up adding:

	int ckpt_read_payload(ctx, void **ptr, int max, int type)

It returns the length of the payload actually read and allocated; caller
should free the buffer.

and:

	char *ckpt_read_string(ctx, max)

It reads the payload of size up to @max (including terminating null!)
into allocated buffer that the caller should free. It returns this
buffer.

To play it safe, it forces a '\0' at the end of the buffer, in case
a malicious user didn't provide it. This way, the caller can safely
assume that it is indeed a null terminated string.

This is slightly different than your prototype, so you need to
update the fifth patch.

Oren.


Dan Smith wrote:
> Add a ckpt_read_string() function to allow reading of a variable-length
> (but length-capped) string from the checkpoint stream.
> 
> Changes in v3:
>  - Return immediately on allocation failure instead of falling through to the
>    inevitable crash
> 
> Changes in v2:
>  - Avoid memcpy() by reading into the allocated buffer directly
> 
> Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/restart.c       |   36 ++++++++++++++++++++++++++++++++++++
>  include/linux/checkpoint.h |    1 +
>  2 files changed, 37 insertions(+), 0 deletions(-)
> 
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index 65cafd9..b1ffc54 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -285,6 +285,42 @@ int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type)
>  	return ret;
>  }
>  
> +/**
> + * ckpt_read_string - read a string (variable length)
> + * @ctx: checkpoint context
> + * @str: pointer to buffer to store allocated string (caller must kfree())
> + * @max: maximum acceptable length
> + *
> + * This can be used to read a variable-length string from the checkpoint
> + * stream. @max limits the size of the resulting buffer.  Returns zero on
> + * success, negative on failure.
> + */
> +int ckpt_read_string(struct ckpt_ctx *ctx, char **str, int max)
> +{
> +	int len;
> +	int ret = 0;
> +
> +	*str = NULL;
> +
> +	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_STRING);
> +	if (len < 0)
> +		return len;
> +	else if (len > max)
> +		return -EINVAL;
> +
> +	*str = kzalloc(len + 1, GFP_KERNEL);
> +	if (!*str)
> +		return -ENOMEM;
> +
> +	ret = ckpt_kread(ctx, *str, len);
> +	if (ret < 0) {
> +		kfree(*str);
> +		*str = NULL;
> +	}
> +
> +	return ret;
> +}
> +
>  /***********************************************************************
>   * Restart
>   */
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 87b683b..a6935b3 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -68,6 +68,7 @@ extern int _ckpt_read_obj_type(struct ckpt_ctx *ctx,
>  extern int _ckpt_read_nbuffer(struct ckpt_ctx *ctx, void *ptr, int len);
>  extern int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len);
>  extern int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len);
> +extern int ckpt_read_string(struct ckpt_ctx *ctx, char **str, int max);
>  extern void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type);
>  extern void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int len, int type);
>  extern int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type);
