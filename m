From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 07/38][IPV6] inet6_addr - ipv6_get_ifaddr namespace aware
Date: Mon, 03 Dec 2007 17:16:43 +0100
Message-ID: <20071203162445.610125209@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=inet6-addr-ipv6-get-ifaddr.patch
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

The inet6_addr_lst is browsed taking into account the network 
namespace specified as parameter. If an address does not belong
to the specified namespace, it is ignored.

In order to reduce the scope of the patch, a wrapper has been
created to not impact all the callers.

The next patch will remove this wrapper and change all the wrappers
to take into account this new parameter.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 include/net/addrconf.h |   15 ++++++++++++---
 net/ipv6/addrconf.c    |    5 ++++-
 2 files changed, 16 insertions(+), 4 deletions(-)

Index: linux-2.6-netns/include/net/addrconf.h
===================================================================
--- linux-2.6-netns.orig/include/net/addrconf.h
+++ linux-2.6-netns/include/net/addrconf.h
@@ -66,9 +66,18 @@ extern int			ipv6_chk_addr(struct net *n
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 extern int			ipv6_chk_home_addr(struct in6_addr *addr);
 #endif
-extern struct inet6_ifaddr *	ipv6_get_ifaddr(struct in6_addr *addr,
-						struct net_device *dev,
-						int strict);
+extern struct inet6_ifaddr      *__ipv6_get_ifaddr(struct net *net,
+						   struct in6_addr *addr,
+						   struct net_device *dev,
+						   int strict);
+
+static inline struct inet6_ifaddr *ipv6_get_ifaddr(struct in6_addr *addr,
+						   struct net_device *dev,
+						   int strict)
+{
+	return __ipv6_get_ifaddr(&init_net, addr, dev, strict);
+}
+
 extern int			ipv6_get_saddr(struct dst_entry *dst, 
 					       struct in6_addr *daddr,
 					       struct in6_addr *saddr);
Index: linux-2.6-netns/net/ipv6/addrconf.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/addrconf.c
+++ linux-2.6-netns/net/ipv6/addrconf.c
@@ -1223,13 +1223,16 @@ int ipv6_chk_same_addr(struct net *net, 
 	return ifp != NULL;
 }
 
-struct inet6_ifaddr * ipv6_get_ifaddr(struct in6_addr *addr, struct net_device *dev, int strict)
+struct inet6_ifaddr * __ipv6_get_ifaddr(struct net *net, struct in6_addr *addr,
+					struct net_device *dev, int strict)
 {
 	struct inet6_ifaddr * ifp;
 	u8 hash = ipv6_addr_hash(addr);
 
 	read_lock_bh(&addrconf_hash_lock);
 	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
+		if (ifp->idev->dev->nd_net != net)
+			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
 			if (dev == NULL || ifp->idev->dev == dev ||
 			    !(ifp->scope&(IFA_LINK|IFA_HOST) || strict)) {

-- 
