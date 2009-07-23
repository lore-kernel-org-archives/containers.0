From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 3/5] Add a ckpt_read_string() function to allow reading
	of a	variable-length (but length-capped) string from the checkpoint
	stream.
Date: Thu, 23 Jul 2009 00:19:56 -0400
Message-ID: <4A67E4EC.3070509@librato.com>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>
	<1248295301-30930-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248295301-30930-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Dan Smith wrote:
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/restart.c       |   35 +++++++++++++++++++++++++++++++++++
>  include/linux/checkpoint.h |    1 +
>  2 files changed, 36 insertions(+), 0 deletions(-)
> 
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index 5cbe491..06fe47e 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -339,6 +339,41 @@ int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type)
>  	return ret;
>  }
>  
> +/**
> + * ckpt_read_string - read a string (variable length)
> + * @ctx: checkpoint context
> + * @max: maximum acceptable length
> + * @str: pointer to buffer to store allocated string (caller must kfree())
> + *
> + * This can be used to read a variable-length string from the checkpoint
> + * stream. @max limits the size of the resulting buffer.  Returns zero on
> + * success, negative on failure.
> + */
> +int ckpt_read_string(struct ckpt_ctx *ctx, char **str, int max)
> +{
> +	struct ckpt_hdr *h;
> +	char *buf;
> +	int len;
> +	int ret = 0;
> +
> +	h = ckpt_read_buf_type(ctx, max, CKPT_HDR_STRING);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	buf = (char *)(h + 1);
> +	len = h->len - sizeof(*h);
> +
> +	*str = kzalloc(len + 1, GFP_KERNEL);
> +	if (!*str)
> +		ret = -ENOMEM;
> +	else
> +		memcpy(*str, buf, len);
> +

You can avoid the memcpy() if you first read only the header, allocate
the string, and then read data into it.

Given that you already want _ckpt_read_obj_data() (or _payload) that
reads certain @len into a given buffer, why not add ckpt_read_obj_data()
that will return an allocate payload buffer.

Something like ...

int _ckpt_read_obj_data(ctx, ptr, len)
{
	return ckpt_kread(ctx, ptr, len);
}

void *ckpt_read_obj_data(ctx, len, type)
{
	void *buf = NULL;

	ret = _ckpt_read_obj_type(ctx, NULL, len, type);
	if (ret < 0)
		return ERR_PTR(ret);
	if (len && ret != len)
		return ERR_PTR(-EINVAL);
	if (ret) {
		buf = kzalloc(len, GFP_KERNEL);
		if (!buf)
			return ERR_PTR(-ENOMEM);
		ret = _ckpt_read_obj_data(ctx, buf, ret);
		if (ret < 0) {
			kfree(buf);
			buf = ERR_PTR(ret);
		}
	}
	return buf;
}

On top of this you can have ckpt_read_string() that will verify that
the buffer is of non-zero length and null terminated ?

Oren.
