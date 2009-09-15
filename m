From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Add a cleanup routine for objhash socket objects
Date: Tue, 15 Sep 2009 13:21:18 -0700
Message-ID: <20090915202118.GC10922@count0.beaverton.ibm.com>
References: <1253033531-6764-1-git-send-email-danms@us.ibm.com>
	<1253033531-6764-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1253033531-6764-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Tue, Sep 15, 2009 at 09:52:11AM -0700, Dan Smith wrote:
> This cleanup routine checks for unattached sockets that we instantiated
> and calls sock_release() on them to avoid leaking the struct socket when
> their buffers are consumed and the struct sock is free'd.

Does it make sense to add a generic (cleanup) operation when only one object
type will make use of it? If we add generic mechanisms for things
without having multiple uses then are we just obfuscating the special
cases of the code? (Another example of this dilemma was my file table
deferqueue before you introduced a second use of it...) Or do you
anticipate other particular uses of "cleanup"?

As an alternative, would it work if we  kept a list of unattached sockets in
the ckpt context, removed them whenever they become attached, and then use the
generic "end of restart" deferqueue to cleanup unattached sockets?

Cheers,
	-Matt Helsley

> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/objhash.c |   13 +++++++++++++
>  1 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index 9750483..5626707 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -247,6 +247,18 @@ static void obj_sock_drop(void *ptr)
>  	sock_put((struct sock *) ptr);
>  }
> 
> +static void cleanup_sock(void *ptr)
> +{
> +	struct sock *sk = (struct sock *) ptr;
> +
> +	if (sk->sk_socket && !sk->sk_socket->file) {

Would it make sense to add a little helper to explain this?

	if (!is_sk_attached(sk)) {
...

examples where this _might_ be nicely re-used:

net/core/sock.c (sk_send_sigurg())
ipv4/netfilter/ipt_LOG.c (dump_packet())
ipv6/netfilter/ip6t_LOG.c (dump_packet())
net/netfilter/nfnetlink_log.c (__build_packet_message())
net/sctp/socket.c (__sctp_connect() -- though this adds a redundant
					sk_socket NULL check...)

> +		struct socket *sock = sk->sk_socket;
> +		sock_orphan(sk);
> +		sock->sk = NULL;
> +		sock_release(sock);
> +	}
> +}
> +
>  static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  	/* ignored object */
>  	{
> @@ -384,6 +396,7 @@ static struct ckpt_obj_ops ckpt_obj_ops[] = {
>  		.ref_grab = obj_sock_grab,
>  		.checkpoint = checkpoint_sock,
>  		.restore = restore_sock,
> +		.cleanup = cleanup_sock,
>  	},
>  };
