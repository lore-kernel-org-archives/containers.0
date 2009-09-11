From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] Track socket buffer owners (v2)
Date: Thu, 10 Sep 2009 21:02:06 -0500
Message-ID: <20090911020206.GA15845@us.ibm.com>
References: <1252508756-4278-1-git-send-email-danms@us.ibm.com>
	<1252508756-4278-4-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1252508756-4278-4-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Changes in v2:
>  - Add comment about using deferqueue_add() in a function that could have
>    been called during deferqueue_run()
>  - Change 'ref' to 'objref' in several variable names
>  - Move SOCK_DEAD flag detection to initial patch
>  - Catch errors from unix_read_buffers(), even on the should-be-missing
>    send buffers
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Looks fine to my unqualified eyes, except for:

> @@ -139,54 +241,125 @@ static int sock_read_buffer_sendmsg(struct ckpt_ctx *ctx, struct sock *sk)
>  	if (ret < 0)
>  		goto out;
> 
> +	msg.msg_name = addr;
> +	msg.msg_namelen = addrlen;
> +
> +	/* If peer is shutdown, unshutdown it for this process */
> +	sock_shutdown = sk->sk_shutdown;
> +	sk->sk_shutdown &= ~SHUTDOWN_MASK;
> +
> +	/* Unshutdown peer too, if necessary */
> +	if (unix_sk(sk)->peer) {
> +		peer_shutdown = unix_sk(sk)->peer->sk_shutdown;
> +		unix_sk(sk)->peer->sk_shutdown &= ~SHUTDOWN_MASK;
> +	}
> +
> +	/* Make sure there's room in the send buffer */
> +	sndbuf = sk->sk_sndbuf;
> +	if (capable(CAP_NET_ADMIN) &&
> +	    ((sk->sk_sndbuf - atomic_read(&sk->sk_wmem_alloc)) < len))

'capable' actually has an adverse effect of setting the PF_SUPERPRIV
flag on current.  So if I don't misread this, you'll want to do the
length check first, then the capable check, in order to make sure
that PF_SUPERPRIV doesn't get set unless the privilege was actually
needed.

> +		sk->sk_sndbuf += len;
> +	else
> +		sk->sk_sndbuf = sysctl_wmem_max;

-serge
