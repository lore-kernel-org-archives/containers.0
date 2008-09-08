From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 31/33] netns ct: fixup DNAT in netns
Date: Mon,  8 Sep 2008 07:03:08 +0400
Message-ID: <1220842990-30500-31-git-send-email-adobriyan__28626.8182950609$1220844133$gmane$org@gmail.com>
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

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index 0a02a8c..f929352 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -91,13 +91,13 @@ static unsigned int ipt_snat_target(struct sk_buff *skb,
 }
 
 /* Before 2.6.11 we did implicit source NAT if required. Warn about change. */
-static void warn_if_extra_mangle(__be32 dstip, __be32 srcip)
+static void warn_if_extra_mangle(struct net *net, __be32 dstip, __be32 srcip)
 {
 	static int warned = 0;
 	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = dstip } } };
 	struct rtable *rt;
 
-	if (ip_route_output_key(&init_net, &rt, &fl) != 0)
+	if (ip_route_output_key(net, &rt, &fl) != 0)
 		return;
 
 	if (rt->rt_src != srcip && !warned) {
@@ -130,7 +130,7 @@ static unsigned int ipt_dnat_target(struct sk_buff *skb,
 
 	if (hooknum == NF_INET_LOCAL_OUT &&
 	    mr->range[0].flags & IP_NAT_RANGE_MAP_IPS)
-		warn_if_extra_mangle(ip_hdr(skb)->daddr,
+		warn_if_extra_mangle(dev_net(out), ip_hdr(skb)->daddr,
 				     mr->range[0].min_ip);
 
 	return nf_nat_setup_info(ct, &mr->range[0], IP_NAT_MANIP_DST);
