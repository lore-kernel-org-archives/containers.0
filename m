From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 3/3] Store socket owner with buffers
Date: Tue, 25 Aug 2009 01:33:44 -0400
Message-ID: <4A9377B8.1010400@librato.com>
References: <1251133918-8117-1-git-send-email-danms@us.ibm.com>
	<1251133918-8117-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251133918-8117-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> When we write out the buffers for a socket, store the objref of the owner
> socket as well (which in the case of AF_UNIX is the sender).  On restore,
> we can fetch the socket from the objhash (reading if necessary) and use
> it to re-send the buffers with sendmsg(), thus retaining the identity of
> the sender for use with recvmsg().
> 

I suspect this won't pass a test in which the sender of a dgram
has been closed already (and therefore is "dangling") ?

> Note: This removes the code recently in place to set the buffer limits
> to the current system maximum to handle the case where the application
> set the limit below the size of their current incoming queue.  This is
> a valid scenario, but we'll fail on that now because there won't be
> enough space for the buffers after we set their limit.  Should we always
> set the maximum and then use the deferqueue to replace the user's limit
> after restart?

I'm not sure why you removed that code completely.

It can be executed, for example, by the caller of unix_read_buffers(),
before and after that call ?

> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/checkpoint.h     |    3 -
>  include/linux/checkpoint_hdr.h |    6 ++
>  net/checkpoint.c               |   76 ++++++++++++-------------
>  net/unix/checkpoint.c          |  121 +++++++++++++++++++++++++---------------
>  4 files changed, 118 insertions(+), 88 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 761cad5..88861a1 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -84,9 +84,6 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
>  			      struct socket *socket,
>  			      struct sockaddr *loc, unsigned *loc_len,
>  			      struct sockaddr *rem, unsigned *rem_len);
> -extern struct ckpt_hdr_socket_queue *
> -ckpt_sock_read_buffer_hdr(struct ckpt_ctx *ctx,
> -			  uint32_t *bufsize);
>  
>  /* ckpt kflags */
>  #define ckpt_set_ctx_kflag(__ctx, __kflag)  \
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 39b3cb4..5473a4f 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -411,6 +411,12 @@ struct ckpt_hdr_socket_queue {
>  	__u32 total_bytes;
>  } __attribute__ ((aligned(8)));
>  
> +struct ckpt_hdr_socket_buffer {
> +	struct ckpt_hdr h;
> +	__s32 src_objref;
> +	__u8 data[0];
> +};
> +
>  #define CKPT_UNIX_LINKED 1
>  struct ckpt_hdr_socket_unix {
>  	struct ckpt_hdr h;
> diff --git a/net/checkpoint.c b/net/checkpoint.c
> index c84511e..a7e7db0 100644
> --- a/net/checkpoint.c
> +++ b/net/checkpoint.c
> @@ -58,6 +58,7 @@ static int sock_copy_buffers(struct sk_buff_head *from,
>  			break; /* The queue changed as we read it */
>  
>  		skb_morph(skbs[i], skb);
> +		skbs[i]->sk = skb->sk;
>  		skb_queue_tail(to, skbs[i]);
>  
>  		*total_bytes += skb->len;
> @@ -85,9 +86,11 @@ static int __sock_write_buffers(struct ckpt_ctx *ctx,
>  				struct sk_buff_head *queue)
>  {
>  	struct sk_buff *skb;
> -	int ret = 0;
>  
>  	skb_queue_walk(queue, skb) {
> +		struct ckpt_hdr_socket_buffer *h;
> +		int ret = 0;
> +
>  		/* FIXME: This could be a false positive for non-unix
>  		 *        buffers, so add a type check here in the
>  		 *        future
> @@ -104,9 +107,34 @@ static int __sock_write_buffers(struct ckpt_ctx *ctx,
>  		 * information contained in the skb.
>  		 */
>  
> -		ret = ckpt_write_obj_type(ctx, skb->data, skb->len,
> +		h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFER);
> +		if (!h)
> +			return -ENOMEM;
> +
> +		BUG_ON(!skb->sk);
> +		ret = checkpoint_obj(ctx, skb->sk, CKPT_OBJ_SOCK);
> +		if (ret < 0)
> +			goto end;
> +		h->src_objref = ret;
> +
> +		/* To avoid a memory copy to compose the header and
> +		 * the socket buffer data, write only the header for
> +		 * the object plus the data length, followed by the
> +		 * actual object and then the data itself.
> +		 */
> +		ret = ckpt_write_obj_type(ctx, NULL, sizeof(*h) + skb->len,
>  					  CKPT_HDR_SOCKET_BUFFER);
> -		if (ret)
> +		if (ret < 0)
> +			goto end;
> +
> +		ret = ckpt_kwrite(ctx, h, sizeof(*h));

The 'struct ckpt_hdr' part of @h was already written in the call
to ckpt_write_obj_type() above.

> +		if (ret < 0)
> +			goto end;
> +
> +		ret = ckpt_kwrite(ctx, skb->data, skb->len);
> +	end:
> +		ckpt_hdr_put(ctx, h);
> +		if (ret < 0)
>  			return ret;
>  	}
>  
> @@ -488,42 +516,6 @@ int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
>  	return ret;
>  }
>  
> -struct ckpt_hdr_socket_queue *ckpt_sock_read_buffer_hdr(struct ckpt_ctx *ctx,
> -							uint32_t *bufsize)
> -{
> -	struct ckpt_hdr_socket_queue *h;
> -	int err = 0;
> -
> -	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_QUEUE);
> -	if (IS_ERR(h))
> -		return h;
> -
> -	if (!bufsize) {
> -		if (h->total_bytes != 0) {
> -			ckpt_debug("Expected empty buffer, got %u\n",
> -				   h->total_bytes);
> -			err = -EINVAL;
> -		}
> -	} else if (h->total_bytes > *bufsize) {
> -		/* NB: We let CAP_NET_ADMIN override the system buffer limit
> -		 *     as setsockopt() does
> -		 */
> -		if (capable(CAP_NET_ADMIN))
> -			*bufsize = h->total_bytes;
> -		else {
> -			ckpt_debug("Buffer total %u exceeds limit %u\n",
> -			   h->total_bytes, *bufsize);
> -			err = -EINVAL;
> -		}
> -	}
> -
> -	if (err) {
> -		ckpt_hdr_put(ctx, h);
> -		return ERR_PTR(err);
> -	} else
> -		return h;
> -}
> -
>  static struct file *sock_alloc_attach_fd(struct socket *sock)
>  {
>  	struct file *file;
> @@ -614,6 +606,12 @@ struct file *sock_file_restore(struct ckpt_ctx *ctx, struct ckpt_hdr_file *ptr)
>  		return ERR_PTR(ret);
>  	}
>  
> +	/* Since objhash assumes the initial reference for a socket,
> +	 * we bump it here for this descriptor, unlike other places in the
> +	 * socket code which assume the descriptor is the owner.
> +	 */
> +	sock_hold(sk);
> +
>  	return file;
>  }

This piece belongs to the previous patch ...

>  
> diff --git a/net/unix/checkpoint.c b/net/unix/checkpoint.c
> index cda8434..4a94165 100644
> --- a/net/unix/checkpoint.c
> +++ b/net/unix/checkpoint.c
> @@ -109,17 +109,24 @@ int unix_checkpoint(struct ckpt_ctx *ctx, struct socket *sock)
>  	return ret;
>  }
>  
> -static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sk)
> +static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx,
> +				    struct sockaddr *addr,
> +				    unsigned int addrlen)
>  {
>  	struct msghdr msg;
>  	struct kvec kvec;
> +	struct ckpt_hdr_socket_buffer h;
> +	struct sock *sk;
> +	uint8_t sock_shutdown;
>  	void *buf;
>  	int ret = 0;
> +	int totlen;
>  	int len;
>  
>  	memset(&msg, 0, sizeof(msg));
>  
> -	len = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_SOCKET_BUFFER);
> +	totlen = _ckpt_read_obj_type(ctx, NULL, 0, CKPT_HDR_SOCKET_BUFFER);
> +	len = totlen - sizeof(h);

Catch read errors:
	if (totlen < 0)
		return totlen;

>  	if (len < 0)
>  		return len;
		      ^^^^^^
		      -EINVAL;

[...]

> @@ -243,8 +266,19 @@ static int unix_restore_connected(struct ckpt_ctx *ctx,
>  	struct sock *this = ckpt_obj_fetch(ctx, un->this, CKPT_OBJ_SOCK);
>  	struct sock *peer = ckpt_obj_fetch(ctx, un->peer, CKPT_OBJ_SOCK);
>  	struct socket *tmp = NULL;
> +	struct sockaddr *addr = NULL;
> +	unsigned int addrlen = 0;
>  	int ret;
>  
> +	if (un->peer == 0) {
> +		/* These get propagated to the msghdr, so only set them
> +		 * if we're not connected to a peer, else we'll get an error
> +		 * when we sendmsg()
> +		 */
> +		addr = (struct sockaddr *)&un->laddr;
> +		addrlen = un->laddr_len;
> +	}
> +

I wonder if we need to consider this:
With unix domain sockets, when a connected, or unconnected dgram
socket is (re)connected or disconnected, IIRC, all the existing
data in the receive buffers is removed.

I suppose this will automagically be enforced, because when you
connect the socket, old buffers will be discarded already, and if
it is already connected, then sending from other sockets (not peer)
will fail.

So I think we're protected from such malicious data. Perhaps this
is worth a comment ?


>  	if (!IS_ERR(this) && !IS_ERR(peer)) {
>  		/* We're last */
>  		struct socket *old = this->sk_socket;
> @@ -258,26 +292,29 @@ static int unix_restore_connected(struct ckpt_ctx *ctx,
>  		int family = sock->sk->sk_family;
>  		int type = sock->sk->sk_type;
>  
> -		ret = sock_create(family, type, 0, &tmp);
> -		ckpt_debug("sock_create: %i\n", ret);
> -		if (ret)
> -			goto out;
> -
>  		this = sock->sk;
> -		peer = tmp->sk;
>  
>  		ret = ckpt_obj_insert(ctx, this, un->this, CKPT_OBJ_SOCK);
>  		if (ret < 0)
>  			goto out;
>  
> -		ret = ckpt_obj_insert(ctx, peer, un->peer, CKPT_OBJ_SOCK);
> -		if (ret < 0)
> -			goto out;
> -
> -		ret = unix_join(ctx, this, peer, un);
> -		ckpt_debug("unix_join: %i\n", ret);
> -		if (ret)
> -			goto out;
> +		if (un->peer > 0) {
> +			ret = sock_create(family, type, 0, &tmp);
> +			ckpt_debug("sock_create: %i\n", ret);
> +			if (ret)
> +				goto out;
> +
> +			peer = tmp->sk;
> +			ret = ckpt_obj_insert(ctx, peer, un->peer,
> +					      CKPT_OBJ_SOCK);

Hmmm... I suspect this is plain wrong. Objects that are treated
via checkpoint_obj() and restore_obj() should only be added to
the objhash via these two functions.

Because at checkpoint you used un->peer = checkpoint_obj(...), a
ckpt_obj_fetch() on @un->peer _must_ return the matching object,
or the image file data is invalid.

So sock_create() above should be ckpt_obj_fetch(), and the
ckpt_obj_insert() should go away.

Unfortunately, neither restore_obj() nor ckpt_obj_insert() will
complain about adding the same objref twice...

> +			if (ret < 0)
> +				goto out;
> +
> +			ret = unix_join(ctx, this, peer, un);
> +			ckpt_debug("unix_join: %i\n", ret);
> +			if (ret)
> +				goto out;
> +		}

[...]

Oren.
