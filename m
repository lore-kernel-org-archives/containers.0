From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/3] Record and restore skb header marks (v2)
Date: Thu, 29 Oct 2009 16:10:34 -0400
Message-ID: <4AE9F6BA.8050601@librato.com>
References: <1256666008-8231-1-git-send-email-danms@us.ibm.com>
	<1256666008-8231-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256666008-8231-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Save this information when we checkpoint an skb and provide a mechanism
> to restore that information on restart.  This will be used in the
> subsequent INET patch.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> Changes in v2:
>  - Add range checks to ensure that the header marks we restore
>    are within the data length of the skb

[...]

> +int sock_restore_header_info(struct sk_buff *skb,
> +			     struct ckpt_hdr_socket_buffer *h)
> +{
> +	if ((h->transport_header >= skb->len) ||
> +	    (h->network_header >= skb->len) ||
> +	    (h->mac_header >= skb->len) ||
> +	    (h->mac_len >= skb->len) ||
> +	    (h->hdr_len >= skb->len)) {

I wonder if the sanity test for mac_len and hdr_len are sufficient,
or whether a more constrained test is required.

For example, a quick grep shows that there are several places where:
	skb->mac_len = skb->network_header - skb->mac_header;

I think there is some code that relies on it without validating
that the value makes sense.

> +		ckpt_debug("skb header positions not within data length\n");
> +		return -EINVAL;
> +	}
> +
> +	skb->mac_len = h->mac_len;
> +	skb->hdr_len = h->hdr_len;
> +
> +	skb_set_transport_header(skb, h->transport_header);
> +	skb_set_network_header(skb, h->network_header);
> +	skb_set_mac_header(skb, h->mac_header);
> +
> +	memcpy(skb->cb, h->cb, sizeof(skb->cb));

The skb->cb holds can be used by any layer to put private variables.

Can the user mangle the data in there to create a disaster of some
sort ?

If the answer is "it's possible", and because this is per protocol
data, I suggest to add a per-protocol callback to sanitize the data
in this control buffer.

To not block this patchset infinitely, I guess you can put the
details of the sanity check in a separate patch(set). But I prefer
that the current set will at least mention and provision for such
a mechanism.

> +
> +	return 0;
> +}
> +
>  static int __sock_write_buffers(struct ckpt_ctx *ctx,
>  				struct sk_buff_head *queue,
>  				int dst_objref)
> @@ -123,6 +167,7 @@ static int __sock_write_buffers(struct ckpt_ctx *ctx,
>  			goto end;
>  		h->sk_objref = ret;
>  		h->pr_objref = dst_objref;
> +		sock_record_header_info(skb, h);
>  
>  		ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
>  		if (ret < 0)

Oren.
