From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] Set socket flags on restore using
 sock_setsockopt() where possible (v2)
Date: Mon, 24 Aug 2009 10:48:10 -0700
Message-ID: <1251136090.22398.7523.camel@nimitz>
References: <1251134884-24491-1-git-send-email-danms@us.ibm.com>
	 <1251134884-24491-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1251134884-24491-2-git-send-email-danms@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

On Mon, 2009-08-24 at 10:28 -0700, Dan Smith wrote:
> 
> +static int sock_restore_flags(struct socket *sock,
> +                             struct ckpt_hdr_socket *h)
> +{
> +       int ret;
> +       int v = 1;
> +       unsigned long sk_flags = h->sock.flags;
> +       unsigned long sock_flags = h->socket.flags;
> +
> +       if (test_and_clear_bit(SOCK_URGINLINE, &sk_flags)) {
> +               ret = sock_setsockopt(sock, SOL_SOCKET, SO_OOBINLINE,
> +                                     (char *)&v, sizeof(v));
> +               if (ret)
> +                       return ret;
> +       }
> +
> +       if (test_and_clear_bit(SOCK_KEEPOPEN, &sk_flags)) {
> +               ret = sock_setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE,
> +                                     (char *)&v, sizeof(v));
> +               if (ret)
> +                       return ret;
> +       }

Would it make more sense to do this programatically?

cr_sock_restore_flag(struct socket *sock, unsigned long sck_flag,
		     struct ckpt_hdr_socket *h, unsigned long sock_flag)
{
	unsigned long sk_flags = h->sock.flags;
	unsigned long sock_flags = h->socket.flags;

	
	if (!test_and_clear_bit(sk, &sk_flags))
		return 0;

	return sock_setsockopt(sock, sock_flag, SO_OOBINLINE,
 			       (char *)&v, sizeof(v));
}

Then, each call becomes:

	ret = cr_sock_restore_flag(sock, cr_sock, SOCK_URGINLINE, SO_OOBINLINE);
	if (ret)
		return ret;

	ret = cr_sock_restore_flag(sock, cr_sock, SOCK_KEEPOPEN, SO_KEEPALIVE);
	if (ret)
		return ret;

Or, you could spell the flags out in a (better named) structure:

struct sock_flagpair
{
	unsigned long sock_flag;
	unsigned long sk_flag;
}	

struct sock_flagpair sock_flagpairs[] = {
	{ SOCK_URGINLINE, SO_OOBINLINE },
	{ SOCK_KEEPOPEN, SO_KEEPALIVE},
	...
};

And just walk through the array to do the restore:

static int sock_restore_flags(struct socket *sock,
                             struct ckpt_hdr_socket *h)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(sock_flagpairs); i++) {
		int ret;
		unsigned long sock_flag = sock_flagpairs[i].sock_flag;
		unsigned long sk_flag = sock_flagpairs[i].sk_flag;
		ret = cr_sock_restore_flag(sock, cr_sock, sock_flag, sk_flag);
		if (ret)
			break;
	}
	...
}

-- Dave

