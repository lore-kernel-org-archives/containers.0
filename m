From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH 05/38] Fix ip{,6}_route_me_harder() in netns
Date: Thu, 04 Sep 2008 18:10:36 +0200
Message-ID: <48C0087C.2080708__38911.6992745132$1220544926$gmane$org@trash.net>
References: <20080821215825.GE31136@x200.localdomain>
	<20080821223958.GA31601@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080821223958.GA31601-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
> ip_route_me_harder() is called on output codepaths:
> 1) IPVS: honestly, not sure, looks like it can be called during forwarding
> 2) IPv4 REJECT: refreshing comment re skb->dst is valid and assigment of
>    skb->dst right before call :^)
> 3) NAT: called in LOCAL_OUT hook
> 4) iptable_mangle: LOCAL_OUT hook
> 5) nf_ip_reroute(): LOCAL_OUT hook (no clue about queueing packets to luserspace)
> 
> ip6_route_me_harder() is also called in output codepaths:
> 1) ip6table_mangle: LOCAL_OUT hook
> 2) nf_ip6_reroute: LOCAL_OUT hook (ditto)

This changelog doesn't give much clue what the patch is doing
or even what the problem is. It also doesn't seem that you're
very convinced of its correctness.

Please resend with a proper changelog. If you have any questions
about the contexts in which this function is called, just ask.
