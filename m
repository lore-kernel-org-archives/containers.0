From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/3] Make sockets proper objhash objects and
	use	checkpoint_obj() on them (v2)
Date: Wed, 02 Sep 2009 20:32:22 -0400
Message-ID: <4A9F0E96.70106@librato.com>
References: <1251915760-20118-1-git-send-email-danms@us.ibm.com>
	<1251915760-20118-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251915760-20118-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> This changes the checkpoint/restart procedure for sockets a bit.  The
> socket file header is now checkpointed separately from the socket itself,
> which allows us to checkpoint a socket without arriving at it from a
> file descriptor.  Thus, most sockets will be checkpointed as a result
> of processing the file table, calling sock_file_checkpoint(fd), which
> in turn calls checkpoint_obj(socket).
> 
> However, we may arrive at some sockets while checkpointing other objects,
> such as the other end of an AF_UNIX socket with buffers in flight.  This
> patch just opens that door, which is utilized by the next patch.
> 
> Changes in v2:
>  - If we attempt to checkpoint an orphan socket, create a struct socket
>    to adopt it for the purposes of the checkpoint
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Nice. See comments inline.

> ---
>  checkpoint/objhash.c           |    2 +
>  include/linux/checkpoint_hdr.h |    6 +-
>  include/net/sock.h             |    2 +
>  net/checkpoint.c               |  140 +++++++++++++++++++++++++++++++--------
>  net/unix/checkpoint.c          |    3 +-
>  5 files changed, 120 insertions(+), 33 deletions(-)
> 

[...]

> -int sock_file_checkpoint(struct ckpt_ctx *ctx, struct file *file)
> +static int __do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
>  {

> +static int do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
> +{
> +	struct socket *sock;
> +	int ret;
> +
> +	if (sk->sk_socket)
> +		return __do_sock_checkpoint(ctx, sk);
> +

I wonder if temporarily grafting the @sk is better than explicitly
testing for sk->sk_socket everywhere else ?  (in some places, the test
already exists, so if we keep this approach, it should be removed).

As it is, it simplifies the code. However, how can we be certain that
grafting a dead socket doesn't break any assumptions elsewhere ?
For instance, unix_sock_destructor() will spit a warning if it finds
sk->sk_socket != NULL. There may be other places (per protocol ?).

The alternative is to always pass around an 'sk' instead of sometimes
a 'sock', and to skip parts of the checkpoint (and restart) entirely
for dead sockets.

[...]

Oren.
