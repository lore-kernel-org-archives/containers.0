From: Whit Blauvelt <whit-M6G8SDWvnhfby3iVrkZq2A@public.gmane.org>
Subject: Re: How do containers tie to multiple IP's on a NIC?
Date: Sun, 4 Jul 2010 19:08:27 -0400
Message-ID: <20100704230827.GA1066@transpect.com>
References: <20100704034023.GA29753@transpect.com> <4C30BC16.9090802@free.fr>
	<20100704191841.GA31425@transpect.com> <4C30E5CB.1080902@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4C30E5CB.1080902-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Jul 04, 2010 at 09:49:31PM +0200, Daniel Lezcano wrote:

> Well  ... please don't consider what I will suggest as "preaching
> for its parish" ;)

In English, "Preaching to the choir."

> I would recommend to use the lxc tools, preferably the 0.7.1
> version. 

Will do.

> These tools allow to do what you are expecting that is assign several Ip
> addresses to the same virtual nic.

Ah, then what I need to understand is the relationship of the virtual NIC to
the real NIC. That is, some of what I set up is multi-purpose boxes, where
the single machine functions as an iptables firewall, perhaps multi-homed to
two ISPs, with 3 real NICs, one for the IP block assigned by each ISP, and
one for the LAN - which might also have more than on IP on it. But these
aren't just firewalls. They tend to serve a website or two, perhaps ftp,
smtp, dns - spread over serveral of the IPs. They're also doing SNAT and
DNAT for systems behind them.

It would make all sorts of sense to be adding containers to these systems,
in terms of security, isolation, and the flexibility to easily migrate
services to other servers. But unlike the more usual virtualization
instance, where someone has a dozen different boxes and wants to consolidate
them, I'm already fully consolidated. What I need to do is split things
apart more, so they can go into containers, but still consolidated on boxes
which continue to be multi-purpose, and where each single NIC may have over
a dozen IPs assigned to it, but as a rule from within a single block per
NIC.

I've seen discussions elsewhere (using Google to try to find hints for this)
where people have given a machine two IPs on the same LAN by actually using
two physical NICs (and then need to play STP tricks). My attitude is "Why
use two pieces of hardware where one can do the job?"

Time for some trial-and-error with lxc tools.

Regards,
Whit
