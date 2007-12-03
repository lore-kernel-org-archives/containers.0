From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 26/38][IPV6] route6 - Pass the network namespace parameter
	to rt6_lookup
Date: Mon, 03 Dec 2007 17:17:02 +0100
Message-ID: <20071203162516.122045161@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=route6-pass-network-namespace-to-rt6_lookup.patch
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

Add a network namespace parameter to rt6_lookup().

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 include/net/ip6_route.h |    3 ++-
 net/ipv6/addrconf.c     |    4 ++--
 net/ipv6/anycast.c      |    2 +-
 net/ipv6/ip6_tunnel.c   |    4 ++--
 net/ipv6/mcast.c        |    4 ++--
 net/ipv6/route.c        |    9 +++++----
 net/ipv6/sit.c          |    4 ++--
 7 files changed, 16 insertions(+), 14 deletions(-)

Index: linux-2.6-netns/include/net/ip6_route.h
===================================================================
--- linux-2.6-netns.orig/include/net/ip6_route.h
+++ linux-2.6-netns/include/net/ip6_route.h
@@ -73,7 +73,8 @@ extern void			rt6_sndmsg(int type, struc
 					   int dstlen, int srclen,
 					   int metric, __u32 flags);
 
-extern struct rt6_info		*rt6_lookup(struct in6_addr *daddr,
+extern struct rt6_info		*rt6_lookup(struct net *net,
+					    struct in6_addr *daddr,
 					    struct in6_addr *saddr,
 					    int oif, int flags);
 
Index: linux-2.6-netns/net/ipv6/addrconf.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/addrconf.c
+++ linux-2.6-netns/net/ipv6/addrconf.c
@@ -728,7 +728,7 @@ static void ipv6_del_addr(struct inet6_i
 		struct rt6_info *rt;
 
 		ipv6_addr_prefix(&prefix, &ifp->addr, ifp->prefix_len);
-		rt = rt6_lookup(&prefix, NULL, ifp->idev->dev->ifindex, 1);
+		rt = rt6_lookup(&init_net, &prefix, NULL, ifp->idev->dev->ifindex, 1);
 
 		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
 			if (onlink == 0) {
@@ -1672,7 +1672,7 @@ void addrconf_prefix_rcv(struct net_devi
 
 	if (pinfo->onlink) {
 		struct rt6_info *rt;
-		rt = rt6_lookup(&pinfo->prefix, NULL, dev->ifindex, 1);
+		rt = rt6_lookup(&init_net, &pinfo->prefix, NULL, dev->ifindex, 1);
 
 		if (rt && ((rt->rt6i_flags & (RTF_GATEWAY | RTF_DEFAULT)) == 0)) {
 			if (rt->rt6i_flags&RTF_EXPIRES) {
Index: linux-2.6-netns/net/ipv6/anycast.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/anycast.c
+++ linux-2.6-netns/net/ipv6/anycast.c
@@ -101,7 +101,7 @@ int ipv6_sock_ac_join(struct sock *sk, i
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 
-		rt = rt6_lookup(addr, NULL, 0, 0);
+		rt = rt6_lookup(&init_net, addr, NULL, 0, 0);
 		if (rt) {
 			dev = rt->rt6i_dev;
 			dev_hold(dev);
Index: linux-2.6-netns/net/ipv6/ip6_tunnel.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/ip6_tunnel.c
+++ linux-2.6-netns/net/ipv6/ip6_tunnel.c
@@ -602,7 +602,7 @@ ip6ip6_err(struct sk_buff *skb, struct i
 		skb_reset_network_header(skb2);
 
 		/* Try to guess incoming interface */
-		rt = rt6_lookup(&ipv6_hdr(skb2)->saddr, NULL, 0, 0);
+		rt = rt6_lookup(&init_net, &ipv6_hdr(skb2)->saddr, NULL, 0, 0);
 
 		if (rt && rt->rt6i_dev)
 			skb2->dev = rt->rt6i_dev;
@@ -1112,7 +1112,7 @@ static void ip6_tnl_link_config(struct i
 		int strict = (ipv6_addr_type(&p->raddr) &
 			      (IPV6_ADDR_MULTICAST|IPV6_ADDR_LINKLOCAL));
 
-		struct rt6_info *rt = rt6_lookup(&p->raddr, &p->laddr,
+		struct rt6_info *rt = rt6_lookup(&init_net, &p->raddr, &p->laddr,
 						 p->link, strict);
 
 		if (rt == NULL)
Index: linux-2.6-netns/net/ipv6/mcast.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/mcast.c
+++ linux-2.6-netns/net/ipv6/mcast.c
@@ -208,7 +208,7 @@ int ipv6_sock_mc_join(struct sock *sk, i
 
 	if (ifindex == 0) {
 		struct rt6_info *rt;
-		rt = rt6_lookup(addr, NULL, 0, 0);
+		rt = rt6_lookup(&init_net, addr, NULL, 0, 0);
 		if (rt) {
 			dev = rt->rt6i_dev;
 			dev_hold(dev);
@@ -294,7 +294,7 @@ static struct inet6_dev *ip6_mc_find_dev
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 
-		rt = rt6_lookup(group, NULL, 0, 0);
+		rt = rt6_lookup(&init_net, group, NULL, 0, 0);
 		if (rt) {
 			dev = rt->rt6i_dev;
 			dev_hold(dev);
Index: linux-2.6-netns/net/ipv6/route.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/route.c
+++ linux-2.6-netns/net/ipv6/route.c
@@ -553,11 +553,12 @@ out:
 
 }
 
-struct rt6_info *rt6_lookup(struct in6_addr *daddr, struct in6_addr *saddr,
+struct rt6_info *rt6_lookup(struct net *net,
+			    struct in6_addr *daddr, struct in6_addr *saddr,
 			    int oif, int strict)
 {
 	struct flowi fl = {
-		.fl_net = &init_net,
+		.fl_net = net,
 		.oif = oif,
 		.nl_u = {
 			.ip6_u = {
@@ -1164,7 +1165,7 @@ int ip6_route_add(struct fib6_config *cf
 			if (!(gwa_type&IPV6_ADDR_UNICAST))
 				goto out;
 
-			grt = rt6_lookup(gw_addr, NULL, cfg->fc_ifindex, 1);
+			grt = rt6_lookup(&init_net, gw_addr, NULL, cfg->fc_ifindex, 1);
 
 			err = -EHOSTUNREACH;
 			if (grt == NULL)
@@ -1486,7 +1487,7 @@ void rt6_pmtu_discovery(struct in6_addr 
 	struct rt6_info *rt, *nrt;
 	int allfrag = 0;
 
-	rt = rt6_lookup(daddr, saddr, dev->ifindex, 0);
+	rt = rt6_lookup(dev->nd_net, daddr, saddr, dev->ifindex, 0);
 	if (rt == NULL)
 		return;
 
Index: linux-2.6-netns/net/ipv6/sit.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/sit.c
+++ linux-2.6-netns/net/ipv6/sit.c
@@ -341,11 +341,11 @@ out:
 	skb_reset_network_header(skb2);
 
 	/* Try to guess incoming interface */
-	rt6i = rt6_lookup(&iph6->saddr, NULL, NULL, 0);
+	rt6i = rt6_lookup(&init_net, &iph6->saddr, NULL, NULL, 0);
 	if (rt6i && rt6i->rt6i_dev) {
 		skb2->dev = rt6i->rt6i_dev;
 
-		rt6i = rt6_lookup(&iph6->daddr, &iph6->saddr, NULL, 0);
+		rt6i = rt6_lookup(&init_net, &iph6->daddr, &iph6->saddr, NULL, 0);
 
 		if (rt6i && rt6i->rt6i_dev && rt6i->rt6i_dev->type == ARPHRD_SIT) {
 			struct ip_tunnel *t = netdev_priv(rt6i->rt6i_dev);

-- 
