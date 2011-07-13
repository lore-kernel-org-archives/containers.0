From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 08/14] af_netlink.c: make netlink_capable userns-aware
Date: Wed, 13 Jul 2011 02:02:23 +0000
Message-ID: <20110713020223.GA14187__33018.4911647395$1310522586$gmane$org@hallyn.com>
References: <1310513452-13397-1-git-send-email-serge@hallyn.com>
	<1310513452-13397-9-git-send-email-serge@hallyn.com>
	<1310520819.2634.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1310520819.2634.6.camel@edumazet-laptop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Eric Dumazet (eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Le mardi 12 juillet 2011 =E0 23:30 +0000, Serge Hallyn a =E9crit :
> > From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> > =

> > netlink_capable should check for permissions against the user
> > namespace owning the socket in question.
> > =

> > Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> > Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> > ---
> >  net/netlink/af_netlink.c |   11 +++++++++--
> >  1 files changed, 9 insertions(+), 2 deletions(-)
> > =

> > diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> > index 6ef64ad..81c1099 100644
> > --- a/net/netlink/af_netlink.c
> > +++ b/net/netlink/af_netlink.c
> > @@ -580,8 +580,15 @@ retry:
> >  =

> >  static inline int netlink_capable(struct socket *sock, unsigned int fl=
ag)
> >  {
> > -	return (nl_table[sock->sk->sk_protocol].nl_nonroot & flag) ||
> > -	       capable(CAP_NET_ADMIN);
> > +	struct net *net;
> > +	if (nl_table[sock->sk->sk_protocol].nl_nonroot & flag)
> > +		return 1;
> > +#ifdef CONFIG_NET_NS
> > +	net =3D sock->sk->sk_net;
> > +#else
> > +	net =3D &init_net;
> > +#endif
> =

> This is really ugly, please use :
> =

> 	net =3D sock_net(sk);
> =

> And no more #ifdef

thanks, will do!
