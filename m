From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support
Date: Thu, 4 Jun 2009 10:19:23 -0500
Message-ID: <20090604151923.GA29519@us.ibm.com>
References: <1244042305-7770-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1244042305-7770-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
> has been tested with a single and multiple processes, and with data inflight
> at the time of checkpoint.  It supports both socketpair()s and path-based
> sockets.
> 
> I have an almost-working AF_INET follow-on to this which I can submit after
> this is reviewed and tweaked into acceptance.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Looks very nice, but a few comments.  I do think that the following
should be moved into network headers:

> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
...
> @@ -248,6 +262,11 @@ struct ckpt_hdr_file_pipe {
>  	__s32 pipe_objref;
>  } __attribute__((aligned(8)));
> 
> +struct ckpt_hdr_file_socket {
> +	struct ckpt_hdr_file common;
> +	__u16 family;
> +} __attribute__((aligned(8)));
> +
>  struct ckpt_hdr_file_pipe_state {
>  	struct ckpt_hdr h;
>  	__s32 pipe_len;
> @@ -394,4 +413,56 @@ struct ckpt_hdr_ipc_sem {
>  #define CKPT_TST_OVERFLOW_64(a, b) \
>  	((sizeof(a) > sizeof(b)) && ((a) > LONG_MAX))
> 
> +struct ckpt_hdr_socket {
> +	struct ckpt_hdr h;
> +
> +	/* sock_common */
> +	__u16 family;
> +	__u8 state;
> +	__u8 reuse;
> +	__u32 bound_dev_if;
> +
> +	/* sock */
> +	__u8 protocol;
> +	__u16 type;
> +	__u8 sock_state;
> +	__u8 shutdown;
> +	__u8 userlocks;
> +	__u8 no_check;
> +	__u32 err;
> +	__u32 err_soft;
> +	__u32 priority;
> +	__u64 rcvlowat;
> +	__u64 rcvtimeo;
> +	__u64 sndtimeo;
> +	__u16 backlog;
> +	__s32 rcvbuf;
> +	__s32 sndbuf;
> +	__u64 flags;
> +	__u64 lingertime;
> +
> +	/* socket */
> +	__u64 socket_flags;
> +	__u8 socket_state;
> +
> +	/* common to all supported families */
> +	struct sockaddr laddr;
> +	struct sockaddr raddr;
> +	__u32 laddr_len;
> +	__u32 raddr_len;
> +
> +	union {
> +		struct {
> +			__u32 this;
> +			__u32 peer;
> +		} un;
> +	};
> +
> +} __attribute__ ((aligned(8)));
> +
> +struct ckpt_hdr_socket_buffer {
> +	struct ckpt_hdr h;
> +	__u32 skb_count;
> +} __attribute__ ((aligned(8)));
> +
>  #endif /* _CHECKPOINT_CKPT_HDR_H_ */

...

> +void *sock_file_restore(struct ckpt_ctx *ctx)
> +{
> +	struct ckpt_hdr_socket *h = NULL;
> +	struct socket *socket = NULL;
> +	struct file *file = NULL;
> +	int err;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
> +	if (IS_ERR(h))
> +		return h;
> +
> +	socket = __sock_file_restore(ctx, h);
> +	if (IS_ERR(socket)) {
> +		err = PTR_ERR(socket);
> +		goto err_put;
> +	}
> +
> +	file = sock_alloc_attach_fd(socket);
> +	if (IS_ERR(file)) {
> +		err = PTR_ERR(file);
> +		goto err_release;
> +	}
> +
> +	ckpt_hdr_put(ctx, h);
> +
> +	return file;

EXTREME nit: a blank line between the return and the error label.

> + err_release:
> +	sock_release(socket);
> + err_put:
> +	ckpt_hdr_put(ctx, h);
> +
> +	return ERR_PTR(err);
> +}

...

> +static int sock_un_checkpoint(struct ckpt_ctx *ctx,
> +			      struct sock *sock,
> +			      struct ckpt_hdr_socket *h)
> +{
> +	struct unix_sock *sk = unix_sk(sock);
> +	struct unix_sock *pr = unix_sk(sk->peer);
> +	int new;
> +	int ret;
> +
> +	h->un.this = ckpt_obj_lookup_add(ctx, sk, CKPT_OBJ_SOCK, &new);
> +	if (h->un.this < 0)
> +		goto out;
> +
> +	if (sk->peer)
> +		h->un.peer = ckpt_obj_lookup_add(ctx, pr, CKPT_OBJ_SOCK, &new);
> +	else
> +		h->un.peer = 0;
> +
> +	if (h->un.peer < 0) {
> +		ret = h->un.peer;
> +		goto out;
> +	}
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> + out:
> +	return ret;
> +}

in the CHECKPOINT_SUBTREE case do we want to try to ensure that sk->peer
is owned by another checkpointed task?

...

> +int __sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
> +{
> +	struct socket *socket = file->private_data;
> +	struct sock *sock = socket->sk;
> +	struct ckpt_hdr_socket *h;
> +	int ret = 0;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	h->family = sock->sk_family;
> +	h->state = socket->state;
> +	h->sock_state = sock->sk_state;
> +	h->reuse = sock->sk_reuse;
> +	h->type = sock->sk_type;
> +	h->protocol = sock->sk_protocol;
> +
> +	h->laddr_len = sizeof(h->laddr);
> +	h->raddr_len = sizeof(h->raddr);
> +
> +	if (socket->ops->getname(socket, &h->laddr, &h->laddr_len, 0)) {
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
> +	if ((h->sock_state != TCP_LISTEN) &&
> +	    (h->type != SOCK_DGRAM) &&
> +	    (socket->ops->getname(socket, &h->raddr, &h->raddr_len, 1))) {
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
> +	sock_cptrst(ctx, sock, h, CKPT_CPT);
> +
> +	if (h->family == AF_UNIX) {
> +		ret = sock_un_checkpoint(ctx, sock, h);
> +		if (ret)
> +			goto out;
> +	} else {
> +		ckpt_debug("unsupported socket type %i\n", h->family);
> +		ret = EINVAL;
> +		goto out;
> +	}
> +
> +	ret = sock_write_buffers(ctx, &sock->sk_receive_queue);
> +	if (ret)
> +		goto out;
> +
> +	ret = sock_write_buffers(ctx, &sock->sk_write_queue);
> +	if (ret)
> +		goto out;
> +
> +	/* FIXME: write out-of-order queue for TCP */
> + out:
> +	ckpt_hdr_put(ctx, h);
> +
> +	return ret;
> +}
> +
> +static int sock_read_buffer(struct ckpt_ctx *ctx,
> +			    struct sock *sock,
> +			    struct sk_buff **skb)
> +{
> +	struct ckpt_hdr *h;
> +	int ret = 0;
> +	int len;
> +
> +	h = ckpt_read_buf_type(ctx, SKB_MAX_ALLOC, CKPT_HDR_SOCKET_BUFFER);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	len = h->len - sizeof(*h);
> +
> +	*skb = sock_alloc_send_skb(sock, len, MSG_DONTWAIT, &ret);
> +	if (*skb == NULL) {
> +		ret = ENOMEM;
> +		goto out;
> +	}
> +
> +	memcpy(skb_put(*skb, len), (char *)(h + 1), len);
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	return ret;
> +}
> +
> +static int sock_read_buffers(struct ckpt_ctx *ctx,
> +			     struct sock *sock,
> +			     struct sk_buff_head *queue)
> +{
> +	struct ckpt_hdr_socket_buffer *h;
> +	int ret = 0;
> +	int i;
> +
> +	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFERS);
> +	if (IS_ERR(h)) {
> +		ret = PTR_ERR(h);
> +		goto out;
> +	}
> +
> +	for (i = 0; i < h->skb_count; i++) {
> +		struct sk_buff *skb = NULL;
> +
> +		ret = sock_read_buffer(ctx, sock, &skb);
> +		if (ret)
> +			break;
> +
> +		skb_queue_tail(queue, skb);
> +	}
> + out:
> +	ckpt_hdr_put(ctx, h);
> +
> +	return ret;
> +}
> +
> +static int sock_un_restart(struct ckpt_ctx *ctx,
> +			   struct ckpt_hdr_socket *h,
> +			   struct socket *socket)
> +{
> +	struct sock *peer;
> +	int ret = 0;
> +
> +	if (h->sock_state == TCP_ESTABLISHED) {
> +		peer = ckpt_obj_fetch(ctx, h->un.peer, CKPT_OBJ_SOCK);
> +		if (peer && !IS_ERR(peer)) {
> +			/* We're last, so join with peer */
> +			struct sock *this = socket->sk;
> +
> +			sock_hold(this);
> +			sock_hold(peer);
> +
> +			unix_sk(this)->peer = peer;
> +			unix_sk(peer)->peer = this;
> +
> +			this->sk_peercred.pid = task_tgid_vnr(current);
> +			current_euid_egid(&this->sk_peercred.uid,
> +					  &this->sk_peercred.gid);

No, really, you can't just trust the uid and gid in the ckpt file :)

> +
> +			peer->sk_peercred.pid = task_tgid_vnr(current);

Will the peer's sk_peercred.pid always be current's pid?

> +			current_euid_egid(&peer->sk_peercred.uid,
> +					  &peer->sk_peercred.gid);
> +		} else {
> +			/* We're first, so add our socket and wait for peer */
> +			ckpt_obj_insert(ctx, socket->sk, h->un.this,
> +					CKPT_OBJ_SOCK);
> +		}
> +
> +	} else if (h->sock_state == TCP_LISTEN) {
> +		ret = socket->ops->bind(socket,
> +					(struct sockaddr *)&h->laddr,
> +					h->laddr_len);
> +		if (ret < 0)
> +			goto out;
> +
> +		ret = socket->ops->listen(socket, h->backlog);
> +		if (ret < 0)
> +			goto out;
> +	} else
> +		ckpt_debug("unsupported UNIX socket state %i\n", h->state);
> +
> +	socket->state = h->state;
> +	socket->sk->sk_state = h->sock_state;
> + out:
> +	return ret;
> +}
> +
> +struct socket *__sock_file_restore(struct ckpt_ctx *ctx,
> +				   struct ckpt_hdr_socket *h)
> +{
> +	struct socket *socket;
> +	int ret;
> +
> +	ret = sock_create(h->family, h->type, 0, &socket);
> +	if (ret < 0)
> +		return ERR_PTR(ret);
> +
> +	if (h->family == AF_UNIX) {
> +		ret = sock_un_restart(ctx, h, socket);
> +		ckpt_debug("sock_un_restart: %i\n", ret);
> +	} else {
> +		ckpt_debug("unsupported family %i\n", h->family);
> +		ret = -EINVAL;
> +	}
> +
> +	if (ret)
> +		goto out;
> +
> +	ret = sock_read_buffers(ctx, socket->sk, &socket->sk->sk_receive_queue);
> +	if (ret)
> +		goto out;
> +
> +	ret = sock_read_buffers(ctx, socket->sk, &socket->sk->sk_write_queue);
> +	if (ret)
> +		goto out;
> + out:
> +	if (ret) {
> +		sock_release(socket);
> +		socket = ERR_PTR(ret);
> +	}
> +
> +	return socket;
> +}
> +
> +int sock_file_checkpoint(struct ckpt_ctx *ctx, void *ptr)
> +{
> +	struct ckpt_hdr_file_socket *h;
> +	int ret;
> +	struct file *file = ptr;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	h->common.f_type = CKPT_FILE_SOCKET;
> +
> +	ret = checkpoint_file_common(ctx, file, &h->common);
> +	if (ret < 0)
> +		goto out;
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = __sock_file_checkpoint(ctx, file);
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	return ret;
> +}

thanks,
-serge
