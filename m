From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 09/38][IPV6] inet6_addr - make ipv6_chk_home_addr namespace
	aware
Date: Mon, 03 Dec 2007 17:16:45 +0100
Message-ID: <20071203162448.331430757@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=inet6-addr-ipv6-chk-home-addr.patch
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

Looks if the address is belonging to the network namespace, otherwise
discard the address for the check.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 include/net/addrconf.h |    3 ++-
 net/ipv6/addrconf.c    |    4 +++-
 net/ipv6/exthdrs.c     |    2 +-
 3 files changed, 6 insertions(+), 3 deletions(-)

Index: linux-2.6-netns/include/net/addrconf.h
===================================================================
--- linux-2.6-netns.orig/include/net/addrconf.h
+++ linux-2.6-netns/include/net/addrconf.h
@@ -64,7 +64,8 @@ extern int			ipv6_chk_addr(struct net *n
 					      int strict);
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
-extern int			ipv6_chk_home_addr(struct in6_addr *addr);
+extern int			ipv6_chk_home_addr(struct net *net,
+						   struct in6_addr *addr);
 #endif
 extern struct inet6_ifaddr      *ipv6_get_ifaddr(struct net *net,
 						 struct in6_addr *addr,
Index: linux-2.6-netns/net/ipv6/addrconf.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/addrconf.c
+++ linux-2.6-netns/net/ipv6/addrconf.c
@@ -2848,13 +2848,15 @@ void if6_proc_exit(void)
 
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 /* Check if address is a home address configured on any interface. */
-int ipv6_chk_home_addr(struct in6_addr *addr)
+int ipv6_chk_home_addr(struct net *net, struct in6_addr *addr)
 {
 	int ret = 0;
 	struct inet6_ifaddr * ifp;
 	u8 hash = ipv6_addr_hash(addr);
 	read_lock_bh(&addrconf_hash_lock);
 	for (ifp = inet6_addr_lst[hash]; ifp; ifp = ifp->lst_next) {
+		if (ifp->idev->dev->nd_net != net)
+			continue;
 		if (ipv6_addr_cmp(&ifp->addr, addr) == 0 &&
 		    (ifp->flags & IFA_F_HOMEADDRESS)) {
 			ret = 1;
Index: linux-2.6-netns/net/ipv6/exthdrs.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/exthdrs.c
+++ linux-2.6-netns/net/ipv6/exthdrs.c
@@ -467,7 +467,7 @@ looped_back:
 			kfree_skb(skb);
 			return -1;
 		}
-		if (!ipv6_chk_home_addr(addr)) {
+		if (!ipv6_chk_home_addr(&init_net, addr)) {
 			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
 					 IPSTATS_MIB_INADDRERRORS);
 			kfree_skb(skb);

-- 
