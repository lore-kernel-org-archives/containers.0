From: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [PATCH 03/38] netns nf: ip6table_mangle in netns for real
Date: Fri, 22 Aug 2008 01:57:39 +0400
Message-ID: <20080821215739.GC31136__3268.00874104283$1219356176$gmane$org@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 net/ipv6/netfilter/ip6table_mangle.c |   31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -67,17 +67,29 @@ static struct xt_table packet_mangler = {
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-ip6t_route_hook(unsigned int hook,
+ip6t_in_hook(unsigned int hook,
 	 struct sk_buff *skb,
 	 const struct net_device *in,
 	 const struct net_device *out,
 	 int (*okfn)(struct sk_buff *))
 {
-	return ip6t_do_table(skb, hook, in, out, init_net.ipv6.ip6table_mangle);
+	return ip6t_do_table(skb, hook, in, out,
+			     dev_net(in)->ipv6.ip6table_mangle);
 }
 
 static unsigned int
-ip6t_local_hook(unsigned int hook,
+ip6t_post_routing_hook(unsigned int hook,
+		struct sk_buff *skb,
+		const struct net_device *in,
+		const struct net_device *out,
+		int (*okfn)(struct sk_buff *))
+{
+	return ip6t_do_table(skb, hook, in, out,
+			     dev_net(out)->ipv6.ip6table_mangle);
+}
+
+static unsigned int
+ip6t_local_out_hook(unsigned int hook,
 		   struct sk_buff *skb,
 		   const struct net_device *in,
 		   const struct net_device *out,
@@ -108,7 +120,7 @@ ip6t_local_hook(unsigned int hook,
 	/* flowlabel and prio (includes version, which shouldn't change either */
 	flowlabel = *((u_int32_t *)ipv6_hdr(skb));
 
-	ret = ip6t_do_table(skb, hook, in, out, init_net.ipv6.ip6table_mangle);
+	ret = ip6t_do_table(skb, hook, in, out, dev_net(out)->ipv6.ip6table_mangle);
 
 	if (ret != NF_DROP && ret != NF_STOLEN
 		&& (memcmp(&ipv6_hdr(skb)->saddr, &saddr, sizeof(saddr))
@@ -122,35 +134,35 @@ ip6t_local_hook(unsigned int hook,
 
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	{
-		.hook		= ip6t_route_hook,
+		.hook		= ip6t_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
-		.hook		= ip6t_route_hook,
+		.hook		= ip6t_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
-		.hook		= ip6t_route_hook,
+		.hook		= ip6t_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
-		.hook		= ip6t_local_hook,
+		.hook		= ip6t_local_out_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
-		.hook		= ip6t_route_hook,
+		.hook		= ip6t_post_routing_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_INET6,
 		.hooknum	= NF_INET_POST_ROUTING,
-- 
1.5.6.3
