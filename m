From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Repeatable OOPS with containers and netfilter
Date: Fri, 9 Sep 2011 19:16:41 +0300
Message-ID: <CACVxJT8rK9941N0MYOC8RQFSEXpPHL5XoTLJC2JU8269jkEbMQ@mail.gmail.com>
References: <72F3F43BCA987119E04694FA@nimrod.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <72F3F43BCA987119E04694FA-PdXK6nMiYlGE+EvaaNYduQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

net->nfnl =3D NULL

On Fri, Sep 9, 2011 at 6:33 PM, Alex Bligh <alex-rWA27mgs/Jz10XsdtD+oqA@public.gmane.org> wrote:
> We are seeing a repeatable kernel oops (quite a deadly one) when destroyi=
ng
> containers which are or have been passing forwarded IPv4 traffic and have
> (or have had) a netfilter conntrack rule installed.
>
> To repeat, you need to have
> a) a container
> b) which is forwarding IPv4 traffic from one interface in the container to
> =A0another (2 veth interfaces in this case) - one ping packet per second
> =A0will do
> c) iptables with an IP conntrack rule.
> d) delete the container (it doesn't matter if you delete the iptables
> =A0rule first and sleep for a couple of seconds).
>
> An OOPS like the one below results.
>
> This one is from Ubuntu kernel
> 3.0.0-10-server #16-Ubuntu SMP Fri Sep 2 18:51:05 UTC 2011 x86_64 GNU/Lin=
ux

> RIP: 0010:[<ffffffff81511959>] =A0[<ffffffff81511959>] netlink_has_listen=
ers+0x9/0x50
> [<ffffffffa048f145>] nfnetlink_has_listeners+0x15/0x20 [nfnetlink]
> [<ffffffffa049943b>] ctnetlink_conntrack_event+0x5cb/0x890 [nf_conntrack_=
netlink]
> [<ffffffff814e34d0>] ? net_drop_ns+0x50/0x50
> [<ffffffffa04062d8>] death_by_timeout+0xc8/0x1c0 [nf_conntrack]
> [<ffffffffa0405270>] ? nf_conntrack_attach+0x50/0x50 [nf_conntrack]
> [<ffffffffa0406448>] nf_ct_iterate_cleanup+0x78/0x90 [nf_conntrack]
> [<ffffffffa0406491>] nf_conntrack_cleanup_net+0x31/0x100 [nf_conntrack]
> [<ffffffffa0407f97>] nf_conntrack_cleanup+0x27/0x60 [nf_conntrack]
> [<ffffffffa04081f0>] nf_conntrack_net_exit+0x60/0x80 [nf_conntrack]
> [<ffffffff814e2d28>] ops_exit_list.isra.1+0x38/0x60
> [<ffffffff814e35e2>] cleanup_net+0x112/0x1b0
