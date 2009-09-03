From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 3/3] [RFC] Track socket buffer owners
Date: Wed, 02 Sep 2009 21:52:24 -0400
Message-ID: <4A9F2158.4010405@librato.com>
References: <1251915760-20118-1-git-send-email-danms@us.ibm.com>
	<1251915760-20118-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251915760-20118-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> This patch is a superset of the previous attempt to store socket buffers
> with their owners.  It defers the writing and reading of the socket buffers
> until after the end of the file phase to avoid a recursive nose-dive of
> checkpointing socket owners.
> 
> This also moves the join logic to the deferqueue as well, since that too
> can lead us down a deep hole.  The buffer restore logic may perform a join
> if it decides that the join is inevitable (but not yet performed) and
> necessary.
> 
> Note that I've been staring at this for too long, so I'm sending it as an
> RFC with hopes that it's not too much of a mess.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Nice, so this solves the chicken-and-egg of socket/peer and the recursion
of dgram socket "chains".

IIUC, sockets discovered while writing the receive buffers (being the
source of an skb) are checkpointed on the fly. In particular, they are
then added to the defer queue.

IOW, they are added to a list that is being traversed (executing the
deferred tasks). I think it's OK: deferqueue_add() uses list_add_tail()
and deferqueue_run user() uses list_for_each_entry_safe().

This probably deserves a comment ?

[...]

>  
> +struct ckpt_hdr_socket_buffer {
> +	struct ckpt_hdr h;
> +	__s32 src_objref;
> +	__s32 dst_objref;
> +};

Super nit: perhaps use 'sk_objref' for socket, and 'peer_objref' for
peer. The latter won't be used in inet sockets. Also, while effectively
a no-op, dst_objref is "source" for send buffers :p

[...]

 > +int sock_deferred_write_buffers(void *data)
> +{
> +	struct dq_buffers *dq = (struct dq_buffers *)data;
> +	struct ckpt_ctx *ctx = dq->ctx;
> +	int ret;
> +	int dst_objref;
> +
> +	dst_objref = ckpt_obj_lookup(ctx, dq->sk, CKPT_OBJ_SOCK);
> +	if (dst_objref < 0) {
> +		ckpt_write_err(ctx,
> +			       "Unable to get objref of owner socket: %i\n",
> +			       dst_objref);
> +		return dst_objref;
> +	}
> +
> +	ret = sock_write_buffers(ctx, &dq->sk->sk_receive_queue, dst_objref);
> +	ckpt_debug("write recv buffers: %i\n", ret);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = sock_write_buffers(ctx, &dq->sk->sk_write_queue, dst_objref);
								^^^^^^^ :p

> +	ckpt_debug("write send buffers: %i\n", ret);
> +
> +	return ret;
> +}
> +
> +int sock_defer_write_buffers(struct ckpt_ctx *ctx, struct sock *sk)
> +{
> +	struct dq_buffers dq;
> +
> +	dq.ctx = ctx;
> +	dq.sk = sk;
> +
> +	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
> +			      sock_deferred_write_buffers,
> +			      sock_deferred_write_buffers);

The dtor should be NULL ?

[...]

 >  static int sock_restore_flags(struct socket *sock,
> -                             struct ckpt_socket *h)
> +                             struct ckpt_hdr_socket *h)
>  {
>         int ret;
>         int i;
> @@ -309,6 +376,9 @@ static int sock_restore_flags(struct socket *sock,
>                 return -ENOSYS;
>         }
>  
> +       if (test_and_clear_bit(SOCK_DEAD, &sk_flags))
> +	       sock_flag(sock->sk, SOCK_DEAD);
> +

I think this snippet belongs to the 1st patch.

[...]

> +struct dq_join {
> +	struct ckpt_ctx *ctx;
> +	int src_ref;
> +	int dst_ref;
> +};
> +
> +struct dq_buffers {
> +	struct ckpt_ctx *ctx;
> +	int sk_ref; /* objref of the socket these buffers belong to */
> +};

Another nit:  s/ref/objref/  (consistency...)

[...]

> +static int unix_defer_join(struct ckpt_ctx *ctx,
> +			   int src_ref,
> +			   int dst_ref)
> +{
> +	struct dq_join dq;
> +
> +	dq.ctx = ctx;
> +	dq.src_ref = src_ref;
> +	dq.dst_ref = dst_ref;
> +
> +	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
> +			      unix_deferred_join, unix_deferred_join);

Here, too, dtor should be NULL ?

[...]

> +
> +	/* If we don't have a destination or a peer and we know the
> +	 * destination of this skb, then we must need to join with our
> +	 * peer
> +	 */
> +	if (!addrlen && !unix_sk(sk)->peer && (h->dst_objref != 0)) {

IIUC, h->dst_objref should always be > 0, no ?

[...]

> +static int unix_deferred_restore_buffers(void *data)
> +{
> +	struct dq_buffers *dq = (struct dq_buffers *)data;
> +	struct ckpt_ctx *ctx = dq->ctx;
> +	struct sock *sk;
> +	struct sockaddr *addr = NULL;
> +	unsigned int addrlen = 0;
> +	int ret;
> +
> +	sk = ckpt_obj_fetch(ctx, dq->sk_ref, CKPT_OBJ_SOCK);
> +	if (!sk) {
> +		ckpt_debug("Missing sock ref %i\n", dq->sk_ref);
> +		return -EINVAL;
> +	}
> +
> +	if ((sk->sk_type == SOCK_DGRAM) && (unix_sk(sk)->addr != NULL)) {
> +		addr = (struct sockaddr *)&unix_sk(sk)->addr->name;
> +		addrlen = unix_sk(sk)->addr->len;
> +	}
> +
> +	ret = unix_read_buffers(ctx, addr, addrlen);
> +	ckpt_debug("read recv buffers: %i\n", ret);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = unix_read_buffers(ctx, addr, addrlen);
> +	ckpt_debug("read send buffers: %i\n", ret);
> +	if (ret != 0)
> +		ret = -EINVAL; /* No send buffers for UNIX sockets */

Change to "if (ret > 0)", otherwise you may mask out a real error.

> +
> +	return ret;
> +}
> +
> +static int unix_defer_restore_buffers(struct ckpt_ctx *ctx, int sk_ref)
> +{
> +	struct dq_buffers dq;
> +
> +	dq.ctx = ctx;
> +	dq.sk_ref = sk_ref;
> +
> +	return deferqueue_add(ctx->files_deferq, &dq, sizeof(dq),
> +			      unix_deferred_restore_buffers,
> +			      unix_deferred_restore_buffers);

... dtor should be NULL.

[...]

Oren.
