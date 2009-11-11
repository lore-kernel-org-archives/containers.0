From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/4] Unify skb read/write functions and fix for
	fragmented buffers
Date: Wed, 11 Nov 2009 14:02:57 -0600
Message-ID: <20091111200257.GB8761@us.ibm.com>
References: <1257878856-25520-1-git-send-email-danms@us.ibm.com>
	<1257878856-25520-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1257878856-25520-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> The INET code often creates socket buffers by attaching fragments instead
> of writing to the linear region.  This extends the skb write functions
> to write out the linear and fragment regions of an skb, and adds a
> function to be used by others wishing to restore an skb in the same way.
> This also includes the header-mark-setting bits from a previous patch.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  include/linux/checkpoint.h     |    1 +
>  include/linux/checkpoint_hdr.h |   11 ++
>  net/checkpoint.c               |  253 ++++++++++++++++++++++++++++++++++++----
>  3 files changed, 242 insertions(+), 23 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index dfcb59b..3e73e68 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -100,6 +100,7 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
>  			      struct socket *socket,
>  			      struct sockaddr *loc, unsigned *loc_len,
>  			      struct sockaddr *rem, unsigned *rem_len);
> +struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx);
> 
>  /* ckpt kflags */
>  #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 5d9c088..ace4139 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -561,8 +561,19 @@ struct ckpt_hdr_socket_queue {
> 
>  struct ckpt_hdr_socket_buffer {
>  	struct ckpt_hdr h;
> +	__u64 transport_header;
> +	__u64 network_header;
> +	__u64 mac_header;
> +	__u64 lin_len; /* Length of linear data */
> +	__u64 frg_len; /* Length of fragment data */
> +	__u64 skb_len; /* Length of skb (adjusted) */
> +	__u64 hdr_len; /* Length of skipped header */
> +	__u64 mac_len;
>  	__s32 sk_objref;
>  	__s32 pr_objref;
> +	__u16 protocol;
> +	__u16 nr_frags;
> +	__u8 cb[48];
>  };
> 
>  #define CKPT_UNIX_LINKED 1
> diff --git a/net/checkpoint.c b/net/checkpoint.c
> index dd23efd..00365b2 100644
> --- a/net/checkpoint.c
> +++ b/net/checkpoint.c
> @@ -17,9 +17,11 @@
>  #include <linux/syscalls.h>
>  #include <linux/sched.h>
>  #include <linux/fs_struct.h>
> +#include <linux/highmem.h>
> 
>  #include <net/af_unix.h>
>  #include <net/tcp_states.h>
> +#include <net/tcp.h>
> 
>  #include <linux/deferqueue.h>
>  #include <linux/checkpoint.h>
> @@ -88,6 +90,233 @@ static int sock_copy_buffers(struct sk_buff_head *from,
>  	return -EAGAIN;
>  }
> 
> +static void sock_record_header_info(struct sk_buff *skb,
> +				    struct ckpt_hdr_socket_buffer *h)
> +{
> +
> +	h->mac_len = skb->mac_len;
> +	h->skb_len = skb->len;
> +	h->hdr_len = skb->data - skb->head;
> +	h->lin_len = (__u64)(skb->tail - skb->head);
> +	h->frg_len = skb->data_len;
> +
> +#ifdef NET_SKBUFF_DATA_USES_OFFSET
> +	h->transport_header = skb->transport_hdr;
> +	h->network_header = skb->network_header;
> +	h->mac_header = skb->mac_header;
> +#else
> +	h->transport_header = skb->transport_header - skb->head;
> +	h->network_header = skb->network_header - skb->head;
> +	h->mac_header = skb->mac_header - skb->head;
> +#endif
> +
> +	memcpy(h->cb, skb->cb, sizeof(skb->cb));
> +	h->nr_frags = skb_shinfo(skb)->nr_frags;
> +}
> +
> +int sock_restore_header_info(struct sk_buff *skb,
> +			     struct ckpt_hdr_socket_buffer *h)
> +{
> +	if (h->mac_header + h->mac_len != h->network_header) {
> +		ckpt_debug("skb mac_header %llu+%llu != network header %llu\n",
> +			   h->mac_header, h->mac_len, h->network_header);
> +		return -EINVAL;
> +	}
> +
> +	if (h->network_header > h->lin_len) {
> +		ckpt_debug("skb network header %llu > linear length %llu\n",
> +			   h->network_header, h->lin_len);
> +		return -EINVAL;
> +	}
> +
> +	if (h->transport_header > h->lin_len) {
> +		ckpt_debug("skb transport header %llu > linear length %llu\n",
> +			   h->transport_header, h->lin_len);
> +		return -EINVAL;
> +	}
> +
> +	if (h->skb_len > SKB_MAX_ALLOC) {
> +		ckpt_debug("skb total length %llu larger than max of %lu\n",
> +			   h->skb_len, SKB_MAX_ALLOC);
> +		return -EINVAL;
> +	}
> +
> +	skb_set_transport_header(skb, h->transport_header);
> +	skb_set_network_header(skb, h->network_header);
> +	skb_set_mac_header(skb, h->mac_header);
> +	skb->mac_len = h->mac_len;
> +
> +	/* FIXME: This should probably be sanitized per-protocol to
> +	 * make sure nothing bad happens if it is hijacked.  For the
> +	 * current set of protocols that we restore this way, the data
> +	 * contained within is not very risky (flags and sequence
> +	 * numbers) but could still be evalutated from a
> +	 * could-the-user- have-set-these-flags point of view.
> +	 */
> +	memcpy(skb->cb, h->cb, sizeof(skb->cb));
> +
> +	skb->data = skb->head + skb->hdr_len;
> +	skb->len = h->skb_len;
> +
> +	return 0;
> +}
> +
> +static int sock_restore_skb_frag(struct ckpt_ctx *ctx,
> +				 struct sk_buff *skb,
> +				 int frag_idx)
> +{
> +	int ret = 0;
> +	int fraglen;
> +	struct page *page;
> +	void *buf;
> +
> +	fraglen = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_BUFFER);
> +	if (fraglen < 0)
> +		return fraglen;
> +
> +	if (fraglen > PAGE_SIZE) {
> +		ckpt_debug("skb frag size %i > PAGE_SIZE\n", fraglen);
> +		return -EINVAL;
> +	}
> +
> +	page = alloc_page(GFP_KERNEL);
> +	if (!page)
> +		return -ENOMEM;
> +
> +	buf = kmap(page);
> +	ret = ckpt_kread(ctx, buf, fraglen);
> +	kunmap(page);
> +
> +	if (ret) {
> +		ckpt_debug("failed to read fragment: %i\n", ret);
> +		ret = -EINVAL;
> +		__free_page(page);
> +	} else {
> +		ckpt_debug("read %i for fragment %i\n", fraglen, frag_idx);
> +		skb_add_rx_frag(skb, frag_idx, page, 0, fraglen);
> +	}
> +
> +	return ret < 0 ? ret : fraglen;
> +}
> +
> +struct sk_buff *sock_restore_skb(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_socket_buffer *h;
> +	struct sk_buff *skb = NULL;
> +	int i;
> +	int ret = 0;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFER);
> +	if (IS_ERR(h))
> +		return (struct sk_buff *)h;
> +
> +	if (h->lin_len > SKB_MAX_ALLOC) {
> +		ckpt_debug("socket linear buffer too big (%llu > %lu)\n",
> +			   h->lin_len, SKB_MAX_ALLOC);
> +		ret = -ENOSPC;
> +		goto out;
> +	} else if (h->frg_len > SKB_MAX_ALLOC) {
> +		ckpt_debug("socket frag size too big (%llu > %lu\n",
> +			   h->frg_len, SKB_MAX_ALLOC);
> +		ret = -ENOSPC;
> +		goto out;
> +	}
> +
> +	skb = alloc_skb(h->lin_len, GFP_KERNEL);
> +	if (!skb) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	ret = _ckpt_read_obj_type(ctx, skb_put(skb, h->lin_len),
> +				  h->lin_len, CKPT_HDR_BUFFER);
> +	ckpt_debug("read linear skb length %llu: %i\n", h->lin_len, ret);
> +	if (ret < 0) {
> +		goto out;
> +	}
> +
> +	for (i = 0; i < h->nr_frags; i++) {
> +		ret = sock_restore_skb_frag(ctx, skb, i);
> +		ckpt_debug("read skb frag %i/%i: %i\n",
> +			   i + 1, h->nr_frags, ret);
> +		if (ret < 0)
> +			goto out;
> +		h->frg_len -= ret;
> +	}
> +
> +	if (h->frg_len != 0) {
> +		ckpt_debug("length %llu remaining after reading frags\n",
> +			   h->frg_len);
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
> +	sock_restore_header_info(skb, h);
> +
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	if (ret < 0) {
> +		kfree_skb(skb);
> +		skb = ERR_PTR(ret);
> +	}
> +
> +	return skb;
> +}
> +
> +static int __sock_write_skb(struct ckpt_ctx *ctx,
> +			    struct sk_buff *skb,
> +			    int dst_objref)
> +{
> +	struct ckpt_hdr_socket_buffer *h;
> +	int ret = 0;
> +	int i;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFER);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	if (dst_objref > 0) {
> +		BUG_ON(!skb->sk);
> +		ret = checkpoint_obj(ctx, skb->sk, CKPT_OBJ_SOCK);
> +		if (ret < 0)
> +			goto out;
> +		h->sk_objref = ret;
> +		h->pr_objref = dst_objref;
> +	}
> +
> +	sock_record_header_info(skb, h);
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = ckpt_write_obj_type(ctx, skb->head, h->lin_len, CKPT_HDR_BUFFER);
> +	ckpt_debug("writing skb linear region %llu: %i\n", h->lin_len, ret);
> +	if (ret < 0)
> +		goto out;
> +
> +	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
> +		u8 *vaddr = kmap(frag->page);
> +
> +		ckpt_debug("writing buffer fragment %i/%i (%i)\n",
> +			   i + 1, h->nr_frags, frag->size);
> +		ret = ckpt_write_obj_type(ctx, vaddr + frag->page_offset,
> +					  frag->size, CKPT_HDR_BUFFER);
> +		kunmap(frag->page);
> +		h->frg_len -= frag->size;
> +		if (ret < 0)
> +			goto out;
> +	}
> +
> +	WARN_ON(h->frg_len != 0);
> +
> + out:
> +	ckpt_hdr_put(ctx, h);
> +
> +	return ret;
> +}
> +
>  static int __sock_write_buffers(struct ckpt_ctx *ctx,
>  				struct sk_buff_head *queue,
>  				int dst_objref)
> @@ -95,13 +324,8 @@ static int __sock_write_buffers(struct ckpt_ctx *ctx,
>  	struct sk_buff *skb;
> 
>  	skb_queue_walk(queue, skb) {
> -		struct ckpt_hdr_socket_buffer *h;
>  		int ret = 0;
> 
> -		/* FIXME: This could be a false positive for non-unix
> -		 *        buffers, so add a type check here in the
> -		 *        future
> -		 */
>  		if (UNIXCB(skb).fp) {
>  			ckpt_write_err(ctx, "TE", "af_unix: pass fd", -EBUSY);
>  			return -EBUSY;
> @@ -113,25 +337,8 @@ static int __sock_write_buffers(struct ckpt_ctx *ctx,
>  		 * because we don't save out (or restore) the control
>  		 * information contained in the skb.
>  		 */
> -		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFER);
> -		if (!h)
> -			return -ENOMEM;
> -
> -		BUG_ON(!skb->sk);
> -		ret = checkpoint_obj(ctx, skb->sk, CKPT_OBJ_SOCK);
> -		if (ret < 0)
> -			goto end;
> -		h->sk_objref = ret;
> -		h->pr_objref = dst_objref;
> -
> -		ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> -		if (ret < 0)
> -			goto end;
> 
> -		ret = ckpt_write_obj_type(ctx, skb->data, skb->len,
> -					  CKPT_HDR_BUFFER);
> -	end:
> -		ckpt_hdr_put(ctx, h);
> +		ret = __sock_write_skb(ctx, skb, dst_objref);
>  		if (ret < 0)
>  			return ret;
>  	}
> -- 
> 1.6.3.3
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
