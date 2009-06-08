From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support (v2)
Date: Mon, 08 Jun 2009 02:02:37 -0400
Message-ID: <4A2CA97D.1060002@cs.columbia.edu>
References: <1244226434-8167-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1244226434-8167-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Hi,

Dan Smith wrote:
> This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
> has been tested with a single and multiple processes, and with data inflight
> at the time of checkpoint.  It supports both socketpair()s and path-based
> sockets.
> 
> I have an almost-working AF_INET follow-on to this which I can submit after
> this is reviewed and tweaked into acceptance.
> 
> Changes in v2:
>   - Change GFP_KERNEL to GFP_ATOMIC in sock_copy_buffers() (this seems
>     to be rather common in other uses of skb_copy())
>   - Move the ckpt_hdr_socket structure definition to linux/socket.h
>   - Fix whitespace issue
>   - Move sock_file_checkpoint() to net/socket.c for symmetry
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

[...]

> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 421afb4..6525ddc 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -23,6 +23,7 @@ struct __kernel_sockaddr_storage {
>  #include <linux/uio.h>			/* iovec support		*/
>  #include <linux/types.h>		/* pid_t			*/
>  #include <linux/compiler.h>		/* __user			*/
> +#include <linux/checkpoint_hdr.h>	/* ckpt_hdr			*/
>  
>  #ifdef __KERNEL__
>  # ifdef CONFIG_PROC_FS
> @@ -323,5 +324,60 @@ extern int move_addr_to_kernel(void __user *uaddr, int ulen, struct sockaddr *ka
>  extern int put_cmsg(struct msghdr*, int level, int type, int len, void *data);
>  
>  #endif
> +
> +struct ckpt_hdr_socket_un {
> +	__u32 this;
> +	__u32 peer;
> +};

Nit:  add __attribute__ ((aligned(8)));

> +
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

Data needs to be aligned (at least for some archs)

> +	__u8 sock_state;
> +	__u8 shutdown;
> +	__u8 userlocks;
> +	__u8 no_check;
> +	__u32 err;

Here too ...

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

Here too ...

> +
> +	/* common to all supported families */
> +	struct sockaddr laddr;
> +	struct sockaddr raddr;
> +	__u32 laddr_len;
> +	__u32 raddr_len;
> +
> +	union {
> +		struct ckpt_hdr_socket_un un;
> +	};


Perhaps use a separate header/object for each socket type,
instead of a union ?  Unix domain sockets take 64 bytes,
I expect inet sockets to require much more.

> +
> +} __attribute__ ((aligned(8)));
> +
> +struct ckpt_hdr_socket_buffer {
> +	struct ckpt_hdr h;
> +	__u32 skb_count;
> +} __attribute__ ((aligned(8)));
> +

Do we need the skb_count ?  How about using the total data
length instead ?

>  #endif /* not kernel and not glibc */
>  #endif /* _LINUX_SOCKET_H */
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 4bb1ff9..d00598c 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1482,4 +1482,13 @@ extern int sysctl_optmem_max;
>  extern __u32 sysctl_wmem_default;
>  extern __u32 sysctl_rmem_default;
>  
> +/* Checkpoint/Restart Functions */
> +struct ckpt_ctx;
> +struct ckpt_hdr_socket;
> +extern int sock_file_checkpoint(struct ckpt_ctx *, void *);
> +extern void *sock_file_restore(struct ckpt_ctx *);
> +extern struct socket *__sock_file_restore(struct ckpt_ctx *,
> +					  struct ckpt_hdr_socket *);
> +extern int __sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file);
> +
>  #endif	/* _SOCK_H */
> diff --git a/net/Makefile b/net/Makefile
> index 9e00a55..1c68a4e 100644
> --- a/net/Makefile
> +++ b/net/Makefile
> @@ -65,3 +65,5 @@ ifeq ($(CONFIG_NET),y)
>  obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
>  endif
>  obj-$(CONFIG_WIMAX)		+= wimax/
> +
> +obj-$(CONFIG_CHECKPOINT)	+= socket_cr.o
> diff --git a/net/socket.c b/net/socket.c
> index 791d71a..5c36753 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -96,6 +96,9 @@
>  #include <net/sock.h>
>  #include <linux/netfilter.h>
>  
> +#include <linux/checkpoint.h>
> +#include <linux/checkpoint_hdr.h>
> +
>  static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
>  static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
>  			 unsigned long nr_segs, loff_t pos);
> @@ -140,6 +143,9 @@ static const struct file_operations socket_file_ops = {
>  	.sendpage =	sock_sendpage,
>  	.splice_write = generic_splice_sendpage,
>  	.splice_read =	sock_splice_read,
> +#ifdef CONFIG_CHECKPOINT
> +	.checkpoint =   sock_file_checkpoint,
> +#endif
>  };
>  
>  /*
> @@ -415,6 +421,84 @@ int sock_map_fd(struct socket *sock, int flags)
>  	return fd;
>  }
>  
> +static struct file *sock_alloc_attach_fd(struct socket *socket)
> +{
> +	struct file *file;
> +	int err;
> +
> +	file = get_empty_filp();
> +	if (!file)
> +		return ERR_PTR(ENOMEM);
> +
> +	err = sock_attach_fd(socket, file, 0);
> +	if (err < 0) {
> +		put_filp(file);
> +		file = ERR_PTR(err);
> +	}
> +
> +	return file;
> +}
> +
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

Nit: like elsewhere, how about "do_sock_file_restore" ?

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
> +
> + err_release:
> +	sock_release(socket);
> + err_put:
> +	ckpt_hdr_put(ctx, h);
> +
> +	return ERR_PTR(err);
> +}
> +
> +int sock_file_checkpoint(struct ckpt_ctx *ctx, void *ptr)

Heh.. I feel more comfortable with checkpoint code appearing
before restart: it helps to already have seen how checkpoint
works when going through the restore.

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

Nit: here too, perhaps "do_sock_file_checkpoint" ?

> + out:
> +	ckpt_hdr_put(ctx, h);
> +	return ret;
> +}
> +
>  static struct socket *sock_from_file(struct file *file, int *err)
>  {
>  	if (file->f_op == &socket_file_ops)
> diff --git a/net/socket_cr.c b/net/socket_cr.c
> new file mode 100644
> index 0000000..448b95f
> --- /dev/null
> +++ b/net/socket_cr.c

People objected to "cr" prefix/ending in file- and function-
names. I suggest "net/checkpoint.c".

Also, is there a reason to split checkpoint_... and restore_...
code between two files ?  I'd put everything in net/checkpoint.c

> @@ -0,0 +1,352 @@
> +/*
> + *  Copyright 2009 IBM Corporation
> + *
> + *  Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> + *
> + *  This program is free software; you can redistribute it and/or
> + *  modify it under the terms of the GNU General Public License as
> + *  published by the Free Software Foundation, version 2 of the
> + *  License.
> + */
> +
> +#include <linux/socket.h>
> +#include <linux/mount.h>
> +#include <linux/file.h>
> +
> +#include <net/af_unix.h>
> +#include <net/tcp_states.h>
> +
> +#include <linux/checkpoint.h>
> +#include <linux/checkpoint_hdr.h>
> +
> +static int sock_copy_buffers(struct sk_buff_head *from, struct sk_buff_head *to)
> +{
> +	int count = 0;
> +	struct sk_buff *skb;
> +
> +	spin_lock(&from->lock);
> +
> +	skb_queue_walk(from, skb) {
> +		struct sk_buff *tmp;
> +
> +		tmp = skb_copy(skb, GFP_ATOMIC);

I believe you can use skb_clone() here, and avoid the actual
memory allocation and data copy.

I think the GFP_ATOMIC in this case isn't that bad. But you
could get mitigate (at least some of) it by pre-allocating
skb's before grabbing the lock and then use skb_morph().

> +		if (!tmp) {
> +			count = -ENOMEM;
> +			goto out;
> +		}
> +		skb_queue_tail(to, tmp);
> +		count++;
> +	}
> + out:
> +	spin_unlock(&from->lock);
> +
> +	return count;
> +}

What about passed file-descriptors ?  Either handle them or
fail with an error (e.g. -EBUSY) when found.

> +
> +static int __sock_write_buffers(struct ckpt_ctx *ctx,
> +				struct sk_buff_head *queue)
> +{
> +	struct sk_buff *skb;
> +	int ret = 0;
> +
> +	skb_queue_walk(queue, skb) {
> +		ret = ckpt_write_obj_type(ctx, skb->data, skb->len,
> +					  CKPT_HDR_SOCKET_BUFFER);

Seems like you intend for the code to be generic and useful for
not only for unix domain sockets. Skb's may point to fragmented
data as well. If not supported, then the code should test for it
and report an error in that case.

> +		if (ret)
> +			return ret;
> +	}
> +
> +	return 0;
> +}

What's the advantage of writing skb's instead of one long
stream of data ?

In fact, perhaps you can use splice() for that data transfer
(similar to pipe implementation) - will also take care of the
fragmentation eventually ...

> +static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head *queue)
> +{
> +	struct ckpt_hdr_socket_buffer *h;
> +	struct sk_buff_head tmpq;
> +	int ret = -ENOMEM;
> +
> +	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFERS);
> +	if (!h)
> +		goto out;
> +
> +	skb_queue_head_init(&tmpq);
> +
> +	h->skb_count = sock_copy_buffers(queue, &tmpq);
> +	if (h->skb_count < 0) {
> +		ret = h->skb_count;
> +		goto out;
> +	}
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (!ret)
> +		ret = __sock_write_buffers(ctx, &tmpq);
> +
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	__skb_queue_purge(&tmpq);
> +
> +	return ret;
> +}
> +
> +static int sock_un_checkpoint(struct ckpt_ctx *ctx,
> +			      struct sock *sock,
> +			      struct ckpt_hdr_socket *h)
> +{

Later we'll have sock_inet_... and then others, and this file
will grow indefinitely. Perhaps place family specific logic
(sock_un_checkpoint, sock_un_restore) in the corresponding
subdir (unix/checkpoint.c) ?

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

For TCP_LISTEN sockets, there may be sockets connected to
it, that have not been accepted yet.

In the case of af_unix, they are embedded in skb's ...

> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> + out:
> +	return ret;
> +}
> +
> +static int sock_cptrst(struct ckpt_ctx *ctx,
> +		       struct sock *sock,
> +		       struct ckpt_hdr_socket *h,
> +		       int op)
> +{
> +	if (sock->sk_socket) {
> +		CKPT_COPY(op, h->socket_flags, sock->sk_socket->flags);
> +		CKPT_COPY(op, h->socket_state, sock->sk_socket->state);
> +	}
> +
> +	CKPT_COPY(op, h->reuse, sock->sk_reuse);
> +	CKPT_COPY(op, h->shutdown, sock->sk_shutdown);
> +	CKPT_COPY(op, h->userlocks, sock->sk_userlocks);
> +	CKPT_COPY(op, h->no_check, sock->sk_no_check);
> +	CKPT_COPY(op, h->protocol, sock->sk_protocol);
> +	CKPT_COPY(op, h->err, sock->sk_err);
> +	CKPT_COPY(op, h->err_soft, sock->sk_err_soft);
> +	CKPT_COPY(op, h->priority, sock->sk_priority);
> +	CKPT_COPY(op, h->rcvlowat, sock->sk_rcvlowat);
> +	CKPT_COPY(op, h->backlog, sock->sk_max_ack_backlog);
> +	CKPT_COPY(op, h->rcvtimeo, sock->sk_rcvtimeo);
> +	CKPT_COPY(op, h->sndtimeo, sock->sk_sndtimeo);
> +	CKPT_COPY(op, h->rcvbuf, sock->sk_rcvbuf);
> +	CKPT_COPY(op, h->sndbuf, sock->sk_sndbuf);
> +	CKPT_COPY(op, h->bound_dev_if, sock->sk_bound_dev_if);
> +	CKPT_COPY(op, h->flags, sock->sk_flags);
> +	CKPT_COPY(op, h->lingertime, sock->sk_lingertime);
> +
> +	return 0;
> +}
> +
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

This deserves a comment about SOCK_STREAM and SOCK_SEQPACKET
being connection based. (For unix domain sockets you don't
really need the remote address).

SOCK_DGRAM may also be "connected" in a way that requires
saving the remote address.

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

	if (h->un.peer <= 0)
		return -EINVAL;

> +
> +	if (h->sock_state == TCP_ESTABLISHED) {
> +		peer = ckpt_obj_fetch(ctx, h->un.peer, CKPT_OBJ_SOCK);

> +		if (peer && !IS_ERR(peer)) {

ckpt_obj_fetch() returns either a valid pointer or an error:

		if (!IS_ERR(peer))
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
> +
> +			peer->sk_peercred.pid = task_tgid_vnr(current);
> +			current_euid_egid(&peer->sk_peercred.uid,
> +					  &peer->sk_peercred.gid);
> +		} else {
		else if (PTR_ERR(peer) == -EINVAL) {
> +			/* We're first, so add our socket and wait for peer */
> +			ckpt_obj_insert(ctx, socket->sk, h->un.this,
> +					CKPT_OBJ_SOCK);
> +		} else {
			ret = PTE_ERR(peer);
			goto out;
		}
> +
> +	} else if (h->sock_state == TCP_LISTEN) {
> +		ret = socket->ops->bind(socket,
> +					(struct sockaddr *)&h->laddr,
> +					h->laddr_len);

bind() may also be required for TCP_ESTABLISHED or TCP_CLOSED
(and of course, to SOCK_DRGRAM).

Also, usually when you checkpoint a listening socket with a
standard (non-abstract) address, the socket inode will exist
in the file system. So it will be there on restart (assuming
the file system view was restored too, e.g. from snapshot).
So bind() will fail with -EADDRINUSE.

Therefore you need to first unlink() the desired pathname.

And if it wasn't there, you need to unlink() after the bind()...

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

h->state may hold arbitrary value, and in particular not
necessarily in agreement with h->sock_state :(

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

Missing call to sock_cptrst() ?   And in that case, will need
to sanitize the data.

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


The local addresses of sockets are not restored. This means that
getpeername() will not give the expected result.

I also wonder how this scheme will end up working when we add
support to INET sockets - at first, locally connected. I like
the simplicity of your approach that creates two separate
sockets and manually connect them. Unfortunately, this "manually"
is going to be very complicated with INET sockets.

Here's an alternative approach for SOCK_STEAM sockets (SOCK_DGRAM
later):

A socket may be either listening, connect or accept (dgram: only
connect). If a socket is not connected, then c/r is relatively
easy.

-- Checkpoint:

If it is connected, then locate the correspondig other sockets:
listening (L), connect (C) and accept (A). Checkpoint them in
this order (regardless of which socket you hit first).

If you first find the (L), then checkpoint it alone If it has
not-yet-accepted sockets pending, say (a1, a2), then locate
their corresponding (C1), (C2), and checkpoint (C1), (a1) and
then (C2), (a2) etc.

If for a pair (C)-(A), the (L) was already checkpointed, then
save the objref only.

If for a pair (C)-(A), the (L) does not exist anymore then save
objref=0 (objrefs are otherwise always > 0).

-- Restart:

When seeing an (L), create a listening socket. (If need to
later unlink the pathname, defer this to end of checkpoint).

When seeing a (C), read it in, connect to the corresponding
(L). If there was no (L), create a temporary one. If the
peer was accepted, then accept to create (A), else leave as
is to create (a). Add both (C) and (A)/(a) to the objhash.

When seeing an (A) or (a), ckpt_obj_fetch() must succeed and
there is little work to do.

--- For SOCK_DGRAM

Here, each socket may be "connected" (in the DGRAM sense) to
another, or even to itself. To checkpoint, first save the
socket, then the peer, then connect - similar to what you
do now, but with a real "connect()" call, to get the full
behind-the-scenes effect.  For INET sockets, it's even
simpler.

---

The advantages of this approach are:

- You care not about the internals of socket connection, or
  not-yet-accepted sockets.

- The local- and peer-addresses are all set automagically.

- It should work for INET sockets (locally connected, e.g.
  to localhost), without caring about e.g. TCP seq-numbers).

Comments ?

Oren.
