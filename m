From: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Subject: Network separation q
Date: Fri, 02 Jul 2010 10:16:38 +0400
Message-ID: <4C2D8446.4080102@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello.

I'm - again - evaluating possibilities to use
current container mechanisms (with a help from
lxc) to improve security in our environment.

One of the places where - to my view - containers
fits well - is to work around wrong programming
practices in certain daemons.  For example, we --
historically -- use vtun tunnels and pptp, and
since they both run as root all the time, I've
no confidence in security of the host where they're
running.  So, -- and I think it's quite natural --
I thought about putting these into containers, to
at least add _some_ additional barriers.

But I immediately come to an.. issue, even 2, both
of which are related to our historical infrastructure,
but I don't actually know better ways.

First of all, we've a single machine which does all
the routing and firewalling, and is running tunnels
of all sorts.  It is our main and only gateway
machine.

So naturally it has a set of firewall rules.  Which,
among others, are based off the network interface
name, -- various tunnels are named, and are allowed
to contact only a listed networks.  So first question
that popped up when I tried to naively move some
services into container - is there a way to use the
"original" interface names in firewall rules on the
main host, or how to un-hide that original iface when
it's hidden by the container's veth or macvlan?

For this very issue, I think the best way is to split
the rules into 2 parts, one per-vpn-interface which
goes into container, and another to list all networks
which are allowed to come from any of tunnels, to
attach to the new container's interface.  So this
seems to be doable.


And another question is about routing, and for this
one I've no alternative currently.

Some our VPNs are used as "backup routes".  I.e.,
normally whole certain network gets routed to a
"usual" place, but it is possible for some nodes
to come to us, establishing a direct tunnel, in
which case routing to this very node goes over
the said tunnel.  This works well, because /32
route to a tunnel is obviously more specific
than generic /24  (or wider range) route to the
whole network.

Now, if I move that vpn/tunnel server into a
container, my main host wont know when the
specific nodes comes up and down, so I have
to install/configure some additional software/
ways to notify host from a container about
tunnels (and don't forget about stale info
in case vpn daemon crashed - normally kernel
cleans it all up in this case).

Granted, I'm just trying to think about all
this, and I don't pretend I understand how
it all works.  My observations are based
solely on my understanding (or lack thereof).
That to say: I'm not sure I know what I need. ;)

But it appears that what I want is a semi-
transparent network separation.  So that the
container can only see its own "subnetwork"
(and can only mess with it, not with anything
else), but host sees whole thing, for firewall
rules and routing.  Or maybe there are better
ways to do it all....

Thanks!

/mjt
