From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/5] Add _ckpt_read_hdr_type() helper
Date: Wed, 22 Jul 2009 23:59:35 -0400
Message-ID: <4A67E027.1050602@cs.columbia.edu>
References: <1248295301-30930-1-git-send-email-danms@us.ibm.com>
	<1248295301-30930-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1248295301-30930-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> This helper function gives us a way to read a header object and the
> subsequent payload from the checkpoint stream directly into our own
> buffer.  This is used by the net/checkpoint.c code to read skb's
> without a memcpy().
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/restart.c       |   36 ++++++++++++++++++++++++++++++++++--
>  include/linux/checkpoint.h |    4 ++++
>  2 files changed, 38 insertions(+), 2 deletions(-)
> 
> diff --git a/checkpoint/restart.c b/checkpoint/restart.c
> index 677f030..5cbe491 100644
> --- a/checkpoint/restart.c
> +++ b/checkpoint/restart.c
> @@ -178,6 +178,38 @@ int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len)
>  }
>  
>  /**
> + * _ckpt_read_hdr_type - read a header record and check the type
> + * @ctx: checkpoint context
> + * @h: provided header buffer (returned)
> + * @type: optional type, 0 to ignore
> + *
> + * Returns the size of the payload to follow or negative on error
> + */
> +int _ckpt_read_hdr_type(struct ckpt_ctx *ctx, struct ckpt_hdr *h, int type)
> +{
> +	int ret;
> +
> +	ret = ckpt_kread(ctx, h, sizeof(*h));
> +	if (ret < 0)
> +		return ret;
> +	else if (type && h->type != type)
> +		return -EINVAL;
> +	else
> +		return h->len - sizeof(*h);
> +}

See commit 9efd630c26be10aee66a7d124f57b6227257a47e in ckpt-v17-dev -
it modifies _ckpt_read_obj_type() to do what you want. It is used in
the following commit f8b21d1fb5a162ae4ae8460dbde1981cf5df36a0 in
restore_pipe().

> +
> +/**
> + * _ckpt_read_payload - read the payload associated with a recent header read
> + * @ctx: checkpoint_context
> + * @h: header returned from _ckpt_read_hdr_type()
> + * @buffer: pre-allocated buffer to store payload
> + */
> +int _ckpt_read_payload(struct ckpt_ctx *ctx, struct ckpt_hdr *h, void *buffer)
> +{
> +	return ckpt_kread(ctx, buffer, h->len - sizeof(*h));
> +}

Since _ckpt_read_obj_type() now returns the actual payload length,
you change the prototype to accept @len instead of @h.

Nit: rename to _ckpt_read_obj_payload() or _ckpt_read_obj_data() to
maintain existing naming convention ?

(Or use ckpt_kread() directly ...)

Oren.
