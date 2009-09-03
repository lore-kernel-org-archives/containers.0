From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Make sockets proper objhash objects and use
	checkpoint_obj() on them (v2)
Date: Thu, 3 Sep 2009 00:40:58 -0500
Message-ID: <20090903054058.GA7189@us.ibm.com>
References: <1251915760-20118-1-git-send-email-danms@us.ibm.com>
	<1251915760-20118-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> +static int do_sock_checkpoint(struct ckpt_ctx *ctx, struct sock *sk)
> +{
> +	struct socket *sock;
> +	int ret;
> +
> +	if (sk->sk_socket)
> +		return __do_sock_checkpoint(ctx, sk);
> +
> +	/* Temporarily adopt this orphan socket */
> +	ret = sock_create(sk->sk_family, sk->sk_type, 0, &sock);
> +	if (ret < 0)
> +		return ret;
> +	sock_graft(sk, sock);
> +
> +	ret = __do_sock_checkpoint(ctx, sk);

I'm sure I sound like an idiot, but... at restore, a socket will
be created for sk now.  Is that a problem?  I don't see where
sk_free() will cause that sock to be freed, and you are not
attaching it do a file whose close would cause it to be released...

-serge
