From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 28/38][IPV6] route6 - Pass network namespace to
	rt6_add_route_info and rt6_get_route_info
Date: Mon, 03 Dec 2007 17:17:04 +0100
Message-ID: <20071203162519.658375173@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=route6-pass-network-namespace-to-rt6_x_route_info.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: den-3ImXcnM4P+0@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Add a network namespace parameter to rt6_add_route_info() and 
rt6_get_route_info to enable them to handle multiple network namespaces.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/ipv6/route.c |   25 +++++++++++++++++--------
 1 file changed, 17 insertions(+), 8 deletions(-)

Index: linux-2.6-netns/net/ipv6/route.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/route.c
+++ linux-2.6-netns/net/ipv6/route.c
@@ -95,10 +95,12 @@ static void		ip6_link_failure(struct sk_
 static void		ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
-static struct rt6_info *rt6_add_route_info(struct in6_addr *prefix, int prefixlen,
+static struct rt6_info *rt6_add_route_info(struct net *net,
+					   struct in6_addr *prefix, int prefixlen,
 					   struct in6_addr *gwaddr, int ifindex,
 					   unsigned pref);
-static struct rt6_info *rt6_get_route_info(struct in6_addr *prefix, int prefixlen,
+static struct rt6_info *rt6_get_route_info(struct net *net,
+					   struct in6_addr *prefix, int prefixlen,
 					   struct in6_addr *gwaddr, int ifindex);
 #endif
 
@@ -442,6 +444,7 @@ static struct rt6_info *rt6_select(struc
 int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
 		  struct in6_addr *gwaddr)
 {
+	struct net *net = dev->nd_net;
 	struct route_info *rinfo = (struct route_info *) opt;
 	struct in6_addr prefix_buf, *prefix;
 	unsigned int pref;
@@ -489,7 +492,8 @@ int rt6_route_rcv(struct net_device *dev
 		prefix = &prefix_buf;
 	}
 
-	rt = rt6_get_route_info(prefix, rinfo->prefix_len, gwaddr, dev->ifindex);
+	rt = rt6_get_route_info(net, prefix, rinfo->prefix_len, gwaddr,
+				dev->ifindex);
 
 	if (rt && !lifetime) {
 		ip6_del_rt(rt);
@@ -497,7 +501,7 @@ int rt6_route_rcv(struct net_device *dev
 	}
 
 	if (!rt && lifetime)
-		rt = rt6_add_route_info(prefix, rinfo->prefix_len, gwaddr, dev->ifindex,
+		rt = rt6_add_route_info(net, prefix, rinfo->prefix_len, gwaddr, dev->ifindex,
 					pref);
 	else if (rt)
 		rt->rt6i_flags = RTF_ROUTEINFO |
@@ -1592,14 +1596,15 @@ static struct rt6_info * ip6_rt_copy(str
 }
 
 #ifdef CONFIG_IPV6_ROUTE_INFO
-static struct rt6_info *rt6_get_route_info(struct in6_addr *prefix, int prefixlen,
+static struct rt6_info *rt6_get_route_info(struct net *net,
+					   struct in6_addr *prefix, int prefixlen,
 					   struct in6_addr *gwaddr, int ifindex)
 {
 	struct fib6_node *fn;
 	struct rt6_info *rt = NULL;
 	struct fib6_table *table;
 
-	table = fib6_get_table(&init_net, RT6_TABLE_INFO);
+	table = fib6_get_table(net, RT6_TABLE_INFO);
 	if (table == NULL)
 		return NULL;
 
@@ -1623,7 +1628,8 @@ out:
 	return rt;
 }
 
-static struct rt6_info *rt6_add_route_info(struct in6_addr *prefix, int prefixlen,
+static struct rt6_info *rt6_add_route_info(struct net *net,
+					   struct in6_addr *prefix, int prefixlen,
 					   struct in6_addr *gwaddr, int ifindex,
 					   unsigned pref)
 {
@@ -1634,6 +1640,9 @@ static struct rt6_info *rt6_add_route_in
 		.fc_dst_len	= prefixlen,
 		.fc_flags	= RTF_GATEWAY | RTF_ADDRCONF | RTF_ROUTEINFO |
 				  RTF_UP | RTF_PREF(pref),
+		.fc_nlinfo.pid = 0,
+		.fc_nlinfo.nlh = NULL,
+		.fc_nlinfo.net = net,
 	};
 
 	ipv6_addr_copy(&cfg.fc_dst, prefix);
@@ -1645,7 +1654,7 @@ static struct rt6_info *rt6_add_route_in
 
 	ip6_route_add(&cfg);
 
-	return rt6_get_route_info(prefix, prefixlen, gwaddr, ifindex);
+	return rt6_get_route_info(net, prefix, prefixlen, gwaddr, ifindex);
 }
 #endif
 

-- 
