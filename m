From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] [RFC][PATCH] IP address restricting cgroup subsystem
Date: Sat, 10 Jan 2009 08:21:53 -0800
Message-ID: <6599ad830901100821q2c943d38i314c00f7db51b4f0@mail.gmail.com>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
	<6599ad830901091358m11effdbegeff6cbb7ee28e262@mail.gmail.com>
	<20090110112009.GA12336@megiteam.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090110112009.GA12336-yp6mvK3Bdd2rDJvtcaxF/A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Jan 10, 2009 at 3:20 AM, Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org> wrote:
>
> IP address [/netmask] [port [- port]]
>
> right? Would that cover a reasonable set of use cases?

Oh, and don't forget being able to control remote addresses/ports too.
E.g. you might not care what local port/address something binds to (or
there may only be one local address anyway) but you might want to
restrict a cgroup from e.g. connecting outside your data center, etc.
(Something that I'm interested in).

> If there are
> going to be multiple addresses, we'd probably want some mechanism to
> determine which one should be used for remapping INADDR_ANY. BTW, do you
> want to restrict connect() source ports too?

Potentially, yes.

>
> The iptables interface is nice but only works with network packets and
> not sockets

But converting a socket definition into a packet header that would be
sent/received on that socket is a fairly mechanical operation, and
after that you have the entire flexibility of the iptables API
available. So the connect()  operation would construct a fake packet
header and send it through the iptable associated with the current
cgroup; if the packet was accepted the operation was permitted, else
the operation was denied.

> So, are you opposed to the current implementation (single IP address) or
> to the interface (a file in cgroupfs)?

Primarily the interface - changing the code later is simple.

Paul
