From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Add AF_INET c/r support
Date: Tue, 23 Jun 2009 09:53:13 -0500
Message-ID: <20090623145313.GA19332@us.ibm.com>
References: <1245697976-29159-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1245697976-29159-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> This patch adds AF_INET c/r support based on the framework established in
> my AF_UNIX patch.  I've tested it by checkpointing a single app with a
> pair of sockets connected over loopback.
> 
> I expect a pile of comments :)
> 
> A couple points about the operation:
> 
>  1. In order to properly hook up the established sockets with the matching
>     listening parent socket, I added a new list to the ckpt_ctx and run the
>     parent attachment in the deferqueue at the end of the restart process.
>  2. I don't do anything to redirect or freeze traffic flowing to or from the
>     remote system (to prevent a RST from breaking things).  I expect that
>     userspace will bring down a veth device or freeze traffic to the remote
>     system to handle this case.
> 
> Cc: Oren Laaden <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/sys.c                 |    2 +
>  include/linux/checkpoint_hdr.h   |    1 +
>  include/linux/checkpoint_types.h |    2 +
>  include/linux/socket.h           |   95 ++++++++++
>  net/checkpoint.c                 |  369 +++++++++++++++++++++++++++++++++-----
>  5 files changed, 428 insertions(+), 41 deletions(-)

...

> +static int sock_in_checkpoint(struct ckpt_ctx *ctx,
> +			      struct sock *sock,
> +			      struct ckpt_hdr_socket *h)
> +{
> +	int ret = -EINVAL;
> +	struct ckpt_hdr_socket_in *in;
> +
> +	in = ckpt_hdr_get_type(ctx, sizeof(*in), CKPT_HDR_SOCKET_IN);
> +	if (!in)
> +		goto out;
> +
> +	ret = sock_in_cptrst(ctx, sock, in, CKPT_CPT);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) in);
> + out:

ckpt_hdr_put(ctx, in) ?

> +	return ret;
> +}
> +
> +static int sock_un_checkpoint(struct ckpt_ctx *ctx,
> +			      struct sock *sock,
> +			      struct ckpt_hdr_socket *h)
> +{
> +	struct unix_sock *sk = unix_sk(sock);
> +	struct unix_sock *pr = unix_sk(sk->peer);
> +	struct ckpt_hdr_socket_un *un;
> +	int new;
> +	int ret = -ENOMEM;
> +
> +	if ((sock->sk_state == TCP_LISTEN) &&
> +	    !skb_queue_empty(&sock->sk_receive_queue)) {
> +		ckpt_debug("listening socket has unaccepted peers");
> +		return -EBUSY;
> +	}
> +
> +	un = ckpt_hdr_get_type(ctx, sizeof(*un), CKPT_HDR_SOCKET_UN);
> +	if (!un)
> +		goto out;
> +
> +	un->linked = sk->dentry && (sk->dentry->d_inode->i_nlink > 0);
> +
> +	un->this = ckpt_obj_lookup_add(ctx, sk, CKPT_OBJ_SOCK, &new);
> +	if (un->this < 0)
> +		goto out;
> +
> +	if (sk->peer)
> +		un->peer = ckpt_obj_lookup_add(ctx, pr, CKPT_OBJ_SOCK, &new);
> +	else
> +		un->peer = 0;
> +
> +	if (un->peer < 0) {
> +		ret = un->peer;
> +		goto out;
> +	}

So what if new == 1 for either un->this or un->peer?  You never actually
write them out to the checkpoint image?

> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
> +	if (ret < 0)
> +		goto out;
> +
> +	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) un);
> + out:

ckpt_hdr_put(ctx, un) ?

> +	return ret;
> +}
> +
>  int do_sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
>  {
>  	struct socket *socket = file->private_data;

...

> +static int sock_in_restart(struct ckpt_ctx *ctx,
> +			   struct ckpt_hdr_socket *h,
> +			   struct socket *socket)
> +{
> +	int ret;
> +	struct ckpt_hdr_socket_in *in;
> +	struct sockaddr_in *l = (struct sockaddr_in *)&h->laddr;
> +
> +	in = ckpt_read_obj_type(ctx, sizeof(*in), CKPT_HDR_SOCKET_IN);
> +	if (IS_ERR(in))
> +		return PTR_ERR(in);
> +
> +	if (h->sock.state == TCP_ESTABLISHED) {
> +		socket->state = h->socket.state;
> +		socket->sk->sk_state = h->sock.state;
> +
> +		sock_cptrst(ctx, socket->sk, h, CKPT_RST);
> +		ret = sock_in_cptrst(ctx, socket->sk, in, CKPT_RST);
> +
> +		/* Delay hashing this sock until the end so we can
> +		 * hook it up with its parent (if appropriate)
> +		 */
> +		sock_defer_hash(ctx, socket->sk);
> +
> +	} else if (h->sock.state == TCP_LISTEN) {
> +		socket->sk->sk_reuse = 2;
> +		inet_sk(socket->sk)->freebind = 1;
> +		ret = socket->ops->bind(socket,
> +					(struct sockaddr *)l,
> +					h->laddr_len);
> +		if (ret < 0)
> +			goto out;
> +		ret = socket->ops->listen(socket, h->sock.backlog);
> +		if (ret < 0)
> +			goto out;
> +
> +		sock_add_parent(ctx, socket->sk);
> +	}
> +
> +  out:

ckpt_hdr_socket_in(ctx, in)?

> +	return ret;
> + }
> +
>  struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
>  				    struct ckpt_hdr_socket *h)
>  {
> @@ -465,6 +749,9 @@ struct socket *do_sock_file_restore(struct ckpt_ctx *ctx,
>  	if (h->sock_common.family == AF_UNIX) {
>  		ret = sock_un_restart(ctx, h, socket);
>  		ckpt_debug("sock_un_restart: %i\n", ret);
> +	} else if (h->sock_common.family == AF_INET) {
> +		ret = sock_in_restart(ctx, h, socket);
> +		ckpt_debug("sock_in_restart: %i\n", ret);
>  	} else {
>  		ckpt_debug("unsupported family %i\n", h->sock_common.family);
>  		ret = -EINVAL;
> -- 
> 1.6.2.2
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
