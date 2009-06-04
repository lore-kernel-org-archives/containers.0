From: Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support
Date: Thu, 4 Jun 2009 22:14:45 +0200
Message-ID: <20090604201444.GA4302@localdomain>
References: <1244042305-7770-1-git-send-email-danms@us.ibm.com>
Reply-To: Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8068649647687426311=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1244042305-7770-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Mime-version: 1.0
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--===============8068649647687426311==
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-4458-1244146470-0001-2"
Content-Disposition: inline

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-4458-1244146470-0001-2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Jun 03, 2009 at 08:18:25AM -0700, Dan Smith wrote:
> This patch adds basic checkpoint/restart support for AF_UNIX sockets.  It
> has been tested with a single and multiple processes, and with data infli=
ght
> at the time of checkpoint.  It supports both socketpair()s and path-based
> sockets.
>=20
> I have an almost-working AF_INET follow-on to this which I can submit aft=
er
> this is reviewed and tweaked into acceptance.
>=20

[...]

> diff --git a/net/socket_cr.c b/net/socket_cr.c
> new file mode 100644
> index 0000000..76759fe
> --- /dev/null
> +++ b/net/socket_cr.c
> @@ -0,0 +1,378 @@
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
> +static int sock_copy_buffers(struct sk_buff_head *from, struct sk_buff_h=
ead *to)
> +{
> +	int count =3D 0;
> +	struct sk_buff *skb;
> +
> +	spin_lock(&from->lock);
> +
> +	skb_queue_walk(from, skb) {
> +		struct sk_buff *tmp;
> +
> +		tmp =3D skb_copy(skb, GFP_KERNEL);

GFP_KERNEL is not allowed here, since from->lock is locked. Not sure that
GFP_ATOMIC is acceptable though. Perhaps it would be better to temporarily =
move
the queue to a local head, copy it (no spinlock needed), and then push it a=
gain.
This would need to block concurrent senders/receivers during this operation,
unless it's guaranteed that they are all frozen.

Thanks,

Louis

> +		if (!tmp) {
> +			count =3D -ENOMEM;
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
> +
> +static int __sock_write_buffers(struct ckpt_ctx *ctx,
> +				struct sk_buff_head *queue)
> +{
> +	struct sk_buff *skb;
> +	int ret =3D 0;
> +
> +	skb_queue_walk(queue, skb) {
> +		ret =3D ckpt_write_obj_type(ctx, skb->data, skb->len,
> +					  CKPT_HDR_SOCKET_BUFFER);
> +		if (ret)
> +			return ret;
> +	}
> +
> +	return 0;
> +}
> +
> +static int sock_write_buffers(struct ckpt_ctx *ctx, struct sk_buff_head =
*queue)
> +{
> +	struct ckpt_hdr_socket_buffer *h;
> +	struct sk_buff_head tmpq;
> +	int ret =3D -ENOMEM;
> +
> +	h =3D ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFERS);
> +	if (!h)
> +		goto out;
> +
> +	skb_queue_head_init(&tmpq);
> +
> +	h->skb_count =3D sock_copy_buffers(queue, &tmpq);
> +	if (h->skb_count < 0) {
> +		ret =3D h->skb_count;
> +		goto out;
> +	}
> +
> +	ret =3D ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (!ret)
> +		ret =3D __sock_write_buffers(ctx, &tmpq);
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
> +	struct unix_sock *sk =3D unix_sk(sock);
> +	struct unix_sock *pr =3D unix_sk(sk->peer);
> +	int new;
> +	int ret;
> +
> +	h->un.this =3D ckpt_obj_lookup_add(ctx, sk, CKPT_OBJ_SOCK, &new);
> +	if (h->un.this < 0)
> +		goto out;
> +
> +	if (sk->peer)
> +		h->un.peer =3D ckpt_obj_lookup_add(ctx, pr, CKPT_OBJ_SOCK, &new);
> +	else
> +		h->un.peer =3D 0;
> +
> +	if (h->un.peer < 0) {
> +		ret =3D h->un.peer;
> +		goto out;
> +	}
> +
> +	ret =3D ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
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
> +	struct socket *socket =3D file->private_data;
> +	struct sock *sock =3D socket->sk;
> +	struct ckpt_hdr_socket *h;
> +	int ret =3D 0;
> +
> +	h =3D ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SOCKET);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	h->family =3D sock->sk_family;
> +	h->state =3D socket->state;
> +	h->sock_state =3D sock->sk_state;
> +	h->reuse =3D sock->sk_reuse;
> +	h->type =3D sock->sk_type;
> +	h->protocol =3D sock->sk_protocol;
> +
> +	h->laddr_len =3D sizeof(h->laddr);
> +	h->raddr_len =3D sizeof(h->raddr);
> +
> +	if (socket->ops->getname(socket, &h->laddr, &h->laddr_len, 0)) {
> +		ret =3D -EINVAL;
> +		goto out;
> +	}
> +
> +	if ((h->sock_state !=3D TCP_LISTEN) &&
> +	    (h->type !=3D SOCK_DGRAM) &&
> +	    (socket->ops->getname(socket, &h->raddr, &h->raddr_len, 1))) {
> +		ret =3D -EINVAL;
> +		goto out;
> +	}
> +
> +	sock_cptrst(ctx, sock, h, CKPT_CPT);
> +
> +	if (h->family =3D=3D AF_UNIX) {
> +		ret =3D sock_un_checkpoint(ctx, sock, h);
> +		if (ret)
> +			goto out;
> +	} else {
> +		ckpt_debug("unsupported socket type %i\n", h->family);
> +		ret =3D EINVAL;
> +		goto out;
> +	}
> +
> +	ret =3D sock_write_buffers(ctx, &sock->sk_receive_queue);
> +	if (ret)
> +		goto out;
> +
> +	ret =3D sock_write_buffers(ctx, &sock->sk_write_queue);
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
> +	int ret =3D 0;
> +	int len;
> +
> +	h =3D ckpt_read_buf_type(ctx, SKB_MAX_ALLOC, CKPT_HDR_SOCKET_BUFFER);
> +	if (IS_ERR(h))
> +		return PTR_ERR(h);
> +
> +	len =3D h->len - sizeof(*h);
> +
> +	*skb =3D sock_alloc_send_skb(sock, len, MSG_DONTWAIT, &ret);
> +	if (*skb =3D=3D NULL) {
> +		ret =3D ENOMEM;
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
> +	int ret =3D 0;
> +	int i;
> +
> +	h =3D ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SOCKET_BUFFERS);
> +	if (IS_ERR(h)) {
> +		ret =3D PTR_ERR(h);
> +		goto out;
> +	}
> +
> +	for (i =3D 0; i < h->skb_count; i++) {
> +		struct sk_buff *skb =3D NULL;
> +
> +		ret =3D sock_read_buffer(ctx, sock, &skb);
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
> +	int ret =3D 0;
> +
> +	if (h->sock_state =3D=3D TCP_ESTABLISHED) {
> +		peer =3D ckpt_obj_fetch(ctx, h->un.peer, CKPT_OBJ_SOCK);
> +		if (peer && !IS_ERR(peer)) {
> +			/* We're last, so join with peer */
> +			struct sock *this =3D socket->sk;
> +
> +			sock_hold(this);
> +			sock_hold(peer);
> +
> +			unix_sk(this)->peer =3D peer;
> +			unix_sk(peer)->peer =3D this;
> +
> +			this->sk_peercred.pid =3D task_tgid_vnr(current);
> +			current_euid_egid(&this->sk_peercred.uid,
> +					  &this->sk_peercred.gid);
> +
> +			peer->sk_peercred.pid =3D task_tgid_vnr(current);
> +			current_euid_egid(&peer->sk_peercred.uid,
> +					  &peer->sk_peercred.gid);
> +		} else {
> +			/* We're first, so add our socket and wait for peer */
> +			ckpt_obj_insert(ctx, socket->sk, h->un.this,
> +					CKPT_OBJ_SOCK);
> +		}
> +
> +	} else if (h->sock_state =3D=3D TCP_LISTEN) {
> +		ret =3D socket->ops->bind(socket,
> +					(struct sockaddr *)&h->laddr,
> +					h->laddr_len);
> +		if (ret < 0)
> +			goto out;
> +
> +		ret =3D socket->ops->listen(socket, h->backlog);
> +		if (ret < 0)
> +			goto out;
> +	} else
> +		ckpt_debug("unsupported UNIX socket state %i\n", h->state);
> +
> +	socket->state =3D h->state;
> +	socket->sk->sk_state =3D h->sock_state;
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
> +	ret =3D sock_create(h->family, h->type, 0, &socket);
> +	if (ret < 0)
> +		return ERR_PTR(ret);
> +
> +	if (h->family =3D=3D AF_UNIX) {
> +		ret =3D sock_un_restart(ctx, h, socket);
> +		ckpt_debug("sock_un_restart: %i\n", ret);
> +	} else {
> +		ckpt_debug("unsupported family %i\n", h->family);
> +		ret =3D -EINVAL;
> +	}
> +
> +	if (ret)
> +		goto out;
> +
> +	ret =3D sock_read_buffers(ctx, socket->sk, &socket->sk->sk_receive_queu=
e);
> +	if (ret)
> +		goto out;
> +
> +	ret =3D sock_read_buffers(ctx, socket->sk, &socket->sk->sk_write_queue);
> +	if (ret)
> +		goto out;
> + out:
> +	if (ret) {
> +		sock_release(socket);
> +		socket =3D ERR_PTR(ret);
> +	}
> +
> +	return socket;
> +}
> +
> +int sock_file_checkpoint(struct ckpt_ctx *ctx, void *ptr)
> +{
> +	struct ckpt_hdr_file_socket *h;
> +	int ret;
> +	struct file *file =3D ptr;
> +
> +	h =3D ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE);
> +	if (!h)
> +		return -ENOMEM;
> +
> +	h->common.f_type =3D CKPT_FILE_SOCKET;
> +
> +	ret =3D checkpoint_file_common(ctx, file, &h->common);
> +	if (ret < 0)
> +		goto out;
> +	ret =3D ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret =3D __sock_file_checkpoint(ctx, file);
> + out:
> +	ckpt_hdr_put(ctx, h);
> +	return ret;
> +}
> +
> +
> --=20
> 1.6.0.4
>=20
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--=_bohort-4458-1244146470-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkooKzQACgkQVKcRuvQ9Q1SIhgCfdDuUMDnzPdpSQMSfNf0JMklL
MNUAn3nuN2C/gicDv4mWaPnshdaoChaq
=g4q0
-----END PGP SIGNATURE-----

--=_bohort-4458-1244146470-0001-2--

--===============8068649647687426311==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--===============8068649647687426311==--
