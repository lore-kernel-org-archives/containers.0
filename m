From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/3] Make sockets proper objhash objects and use
	checkpoint_obj() on them
Date: Tue, 25 Aug 2009 01:01:37 -0400
Message-ID: <4A937031.10300@librato.com>
References: <1251133918-8117-1-git-send-email-danms@us.ibm.com>
	<1251133918-8117-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251133918-8117-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Hi Dan,

Dan Smith wrote:
> This changes the checkpoint/restart procedure for sockets a bit.  The
> socket file header is now checkpointed separately from the socket itself,
> which allows us to checkpoint a socket without arriving at it from a
> file descriptor.  Thus, most sockets will be checkpointed as a result
> of processing the file table, calling sock_file_checkpoint(fd), which
> in turn calls checkpoint_obj(socket).

It's perhaps more accurate to s/most sockets/some sockets/. It may
be more likely for a socket to be checkpointed as a peer of another
process, or as the sender of an skb.

The patch looks fine - see a few comment below.

Now that you made 'struct sock' a 1st class object, they deserve to
enjoy 1st class treatment :p  That also means proper collect() method
- probably starting with the f_op ...

I may be mistaken, but I suspect that the suggested implementation
cannot limit the depth of recursive calls to checkpoint_obj(). For
instance, consider a dgram socket that received data from another
dgram socket, that received data from another dgram, ad infinitum.

> 
> However, we may arrive at some sockets while checkpointing other objects,
> such as the other end of an AF_UNIX socket with buffers in flight.  This
> patch just opens that door, which is utilized by the next patch.
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/objhash.c           |    2 +
>  include/linux/checkpoint_hdr.h |    4 +-
>  include/net/sock.h             |    2 +
>  net/checkpoint.c               |  116 ++++++++++++++++++++++++++++-----------
>  net/unix/checkpoint.c          |    3 +-
>  5 files changed, 91 insertions(+), 36 deletions(-)
> 
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index 019077b..4f26e86 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -381,6 +381,8 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  		.obj_type = CKPT_OBJ_SOCK,
>  		.ref_drop = obj_sock_drop,
>  		.ref_grab = obj_sock_grab,
> +		.checkpoint = checkpoint_sock,
> +		.restore = restore_sock,
>  	},
>  };
>  
> diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
> index 78f1f27..39b3cb4 100644
> --- a/include/linux/checkpoint_hdr.h
> +++ b/include/linux/checkpoint_hdr.h
> @@ -68,6 +68,7 @@ enum {
>  	CKPT_HDR_USER,
>  	CKPT_HDR_GROUPINFO,
>  	CKPT_HDR_TASK_CREDS,
> +	CKPT_HDR_SOCKET,
>  
>  	/* 201-299: reserved for arch-dependent */
>  
> @@ -367,6 +368,7 @@ struct ckpt_hdr_file_pipe {
>  
>  /* socket */
>  struct ckpt_hdr_socket {
> +	struct ckpt_hdr h;
>  	struct { /* struct socket */
>  		__u64 flags;
>  		__u8 state;
> @@ -425,7 +427,7 @@ struct ckpt_hdr_socket_unix {
>  
>  struct ckpt_hdr_file_socket {
>  	struct ckpt_hdr_file common;
> -	struct ckpt_hdr_socket socket;
> +	__s32 sock_objref;
>  } __attribute__((aligned(8)));

I'm thinking about the two other use cases that I mentioned:
"dangling" (not-referenced by a file) and "pending" (not yet
accepted) sockets.

In both cases (well, at least with "pending"), the 'struct sock'
exist but the 'struct socket' does not exit until after the
socket is attached to a file descriptor. IIRC, the lifespan of
'struct socket' is coupled to that of the referencing file.

In that case, I guess it make more sense to leave the 'struct
socket' related data within ckpt_hdr_file_socket.

[...]

> +	sk = ckpt_obj_fetch(ctx, h->sock_objref, CKPT_OBJ_SOCK);
> +	if (IS_ERR(sk))
> +		return ERR_PTR(PTR_ERR(sk));

Nit: I vaguely recall some disapproval of such construct...
How about '(struct file *) sk' ?

> +
> +	file = sock_alloc_attach_fd(sk->sk_socket);
> +	if (IS_ERR(file))
> +		return file;

[...]

Oren.
