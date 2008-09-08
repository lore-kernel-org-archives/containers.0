From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 04/33] Fix {ip,6}_route_me_harder() in netns
Date: Mon,  8 Sep 2008 07:02:41 +0400
Message-ID: <1220842990-30500-4-git-send-email-adobriyan__48473.760582465$1220843498$gmane$org@gmail.com>
References: <48C01046.2070704@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C01046.2070704-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Take netns from skb->dst->dev. It should be safe because, they are called
from LOCAL_OUT hook where dst is valid (though, I'm not exactly sure about
IPVS and queueing packets to userspace).

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index f8edacd..9c54024 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -12,6 +12,7 @@
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
 int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 {
+	struct net *net = dev_net(skb->dst->dev);
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 	struct flowi fl = {};
@@ -19,7 +20,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 	unsigned int hh_len;
 	unsigned int type;
 
-	type = inet_addr_type(&init_net, iph->saddr);
+	type = inet_addr_type(net, iph->saddr);
 	if (addr_type == RTN_UNSPEC)
 		addr_type = type;
 
@@ -33,7 +34,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		fl.nl_u.ip4_u.tos = RT_TOS(iph->tos);
 		fl.oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
 		fl.mark = skb->mark;
-		if (ip_route_output_key(&init_net, &rt, &fl) != 0)
+		if (ip_route_output_key(net, &rt, &fl) != 0)
 			return -1;
 
 		/* Drop old route. */
@@ -43,7 +44,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		/* non-local src, find valid iif to satisfy
 		 * rp-filter when calling ip_route_input. */
 		fl.nl_u.ip4_u.daddr = iph->saddr;
-		if (ip_route_output_key(&init_net, &rt, &fl) != 0)
+		if (ip_route_output_key(net, &rt, &fl) != 0)
 			return -1;
 
 		odst = skb->dst;
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 8c6c5e7..4cb4844 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -23,7 +23,7 @@ int ip6_route_me_harder(struct sk_buff *skb)
 		    .saddr = iph->saddr, } },
 	};
 
-	dst = ip6_route_output(&init_net, skb->sk, &fl);
+	dst = ip6_route_output(dev_net(skb->dst->dev), skb->sk, &fl);
 
 #ifdef CONFIG_XFRM
 	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
