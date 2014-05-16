From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: question about default values for per-namespace settings
Date: Fri, 16 May 2014 04:16:18 -0700
Message-ID: <CAHo-OoyTowOPEqPoqXV53w7+PgbJpBprT-qwHapR7R-pqSdMcg@mail.gmail.com>
References: <20140512140706.GA22082@macbook.localnet>
	<cover.1399909529.git.vvs@openvz.org>
	<5370F781.7010909@parallels.com> <53711B21.1060309@pandora.be>
	<53712B0A.7060007@parallels.com> <53727246.4050306@pandora.be>
	<53748280.60906@parallels.com>
	<20140515174850.GB20738@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140515174850.GB20738-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vasily Averin <vvs-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Isn't pulling current settings from init_net an isolation violation if
init_net isn't the namespace you are in at the time you are creating
the new namespace?

The way I see it there are 2 possibilities:
(a) you use some kernel (probably compile time) defaults (ie. what
init_net gets when you boot machine)
(b) you inherit from current namespace
I'm not sure what the right choice is.

For something like 'iptables configuration' it seems (a) is correct
(come up with no firewall).
For something like 'tcp socket memory limits' or 'bindv6only' or
'v6.default_use_tempaddr) it does seem like (b) is possibly more
appropriate.

That said I think there are cases where (a) is clearly correct and (b)
is clearly not desirable (iptables conf being a prime example).
After all a new namespace doesn't inherit interfaces from the
namespace we're in when we create it.

I can't think of any cases where (b) is clearly correct and (a) is
clearly not desirable.
[I guess this is less than clear for settings which auto scale at boot
with available ram and/or number of cpus in the machine]

Based on that doing (a) for everything may be the right choice
(consistency trump...).
This would imply network namespace you are in should have no effect on
the new network namespace you are creating.

OTOH, if I want to change some tcp mem tuning sysctl (or something
like net.ipv6.conf.default.use_tempaddr = 2)
it would be annoying if /etc/sysctl.conf didn't apply to non-init
namespace.  But perhaps this is better solved in userspace
by loading some /etc/sysctls-for-new-network-namespaces.conf settings
in some network namespace creating libraries.

- Maciej
