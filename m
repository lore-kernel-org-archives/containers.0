From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Change net c/r to use exported page I/O functions
Date: Tue, 17 Nov 2009 22:17:07 -0600
Message-ID: <20091118041707.GA19841@us.ibm.com>
References: <1258489484-28227-1-git-send-email-danms@us.ibm.com>
	<1258489484-28227-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1258489484-28227-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> +static int __sock_write_skb_frag(struct ckpt_ctx *ctx,
> +				 skb_frag_t *frag)
> +{
> +	struct ckpt_hdr_socket_buffer_frag *h;
> +	int ret;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_FRAG);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	h->size = frag->size;
> +	h->offset = frag->page_offset;
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *)h);
> +	ckpt_hdr_put(ctx, h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = checkpoint_dump_page(ctx, frag->page);
> +	ckpt_debug("writing frag page: %i\n", ret);
> +	if (ret < 0)
> +		goto out;
> +
> + out:
> +	ckpt_hdr_put(ctx, h);

I assume you meant to get rid of this second ckpt_hdr_put()?

> +
> +	return ret;
> +}
> +
>  static int __sock_write_skb(struct ckpt_ctx *ctx,
>  			    struct sk_buff *skb,
>  			    int dst_objref)
> @@ -316,16 +348,12 @@ static int __sock_write_skb(struct ckpt_ctx *ctx,
> 
>  	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
>  		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
> -		u8 *vaddr = kmap(frag->page);
> -
> +		ret = __sock_write_skb_frag(ctx, frag);
>  		ckpt_debug("writing buffer fragment %i/%i (%i)\n",
> -			   i + 1, h->nr_frags, frag->size);
> -		ret = ckpt_write_obj_type(ctx, vaddr + frag->page_offset,
> -					  frag->size, CKPT_HDR_BUFFER);
> -		kunmap(frag->page);
> -		h->frg_len -= frag->size;
> +			   i + 1, h->nr_frags, ret);
>  		if (ret < 0)
>  			goto out;
> +		h->frg_len -= frag->size;
>  	}
> 
>  	WARN_ON(h->frg_len != 0);
> -- 
> 1.6.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
