From: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Subject: Re: [Devel] [RFC][PATCH] IP address restricting cgroup subsystem
Date: Sun, 11 Jan 2009 11:19:46 +0100
Message-ID: <20090111101946.GA14325@megiteam.pl>
References: <20090106230554.GB25228@eskarina.localdomain.pl>
	<6599ad830901091358m11effdbegeff6cbb7ee28e262@mail.gmail.com>
	<20090110112009.GA12336@megiteam.pl>
	<6599ad830901100821q2c943d38i314c00f7db51b4f0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830901100821q2c943d38i314c00f7db51b4f0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On sob, sty 10, 2009 at 08:21:53 -0800, Paul Menage wrote:
> But converting a socket definition into a packet header that would be
> sent/received on that socket is a fairly mechanical operation, and
> after that you have the entire flexibility of the iptables API
> available. So the connect()  operation would construct a fake packet
> header and send it through the iptable associated with the current
> cgroup; if the packet was accepted the operation was permitted, else
> the operation was denied.

So if I understand you right, your proposed solution would be something
akin to ipt_cgroup (matching packets originating from a cgroup, like
ipt_owner matches uid/gid) plus netfilter hooks for blocking/remapping
addresses passed to connect() and/or bind()? Or maybe a dedicated
netfilter table with per-cgroup chains?

I'd rather not invent some new userspace tools (to use the iptables API
without /sbin/iptables) to manage the cgroup networking so I guess
extending iptables (or iproute) would be the way to go in that case.

Using the iptables API with connect() sending a fake packet, how would
you represent "allow this connection, but bind() to 10.0.0.1 first"?
Rewrite the source address in an iptables target?

Am I right or completely off the mark?

Best regards,
 Grzegorz Nosek
