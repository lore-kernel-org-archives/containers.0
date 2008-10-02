From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH v2 4/6] netns ct:
	per-netns	net.netfilter.nf_conntrack_checksum sysctl
Date: Thu, 02 Oct 2008 10:02:25 +0200
Message-ID: <48E48011.90709__27023.8262870864$1222934761$gmane$org@trash.net>
References: <48C01046.2070704@trash.net>
	<1220842990-30500-17-git-send-email-adobriyan@gmail.com>
	<48C623CA.9060803@trash.net>
	<20080909073245.GA7307@x200.localdomain>
	<48C62B1C.7070104@trash.net>
	<20080913105239.GE7440@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080913105239.GE7440-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Alexey Dobriyan wrote:
> Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>
>  include/net/netfilter/nf_conntrack.h           |    1 -
>  include/net/netns/conntrack.h                  |    1 +
>  net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
>  net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    2 +-
>  net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
>  net/netfilter/nf_conntrack_proto_dccp.c        |    2 +-
>  net/netfilter/nf_conntrack_proto_tcp.c         |    2 +-
>  net/netfilter/nf_conntrack_proto_udp.c         |    2 +-
>  net/netfilter/nf_conntrack_proto_udplite.c     |    2 +-
>  net/netfilter/nf_conntrack_standalone.c        |    7 +++----

Applied.
