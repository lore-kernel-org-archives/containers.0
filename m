From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 04/38][IPV6] inet6_addr - check ipv6 address per namespace
Date: Mon, 03 Dec 2007 17:16:40 +0100
Message-ID: <20071203162438.964724827@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=inet6-addr-ipv6-chk-addr.patch
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

When a new address is added, we must check if the new address does 
not already exists.
This patch makes this check to be aware of a network namespace,
so the check will look if the address already exists for the specified
network namespace. While the addresses are browsed, the addresses
which do not belong to the namespace are discarded.

The modifications are trivial here and they do not touch the 
callers of the function ipv6_chk_addr.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 include/net/addrconf.h |   11 ++++++++++-
 net/ipv6/addrconf.c    |    7 +++++--
 2 files changed, 15 insertions(+), 3 deletions(-)

Index: linux-2.6-netns/include/net/addrconf.h
===================================================================
--- linux-2.6-netns.orig/include/net/addrconf.h
+++ linux-2.6-netns/include/net/addrconf.h
@@ -58,9 +58,18 @@ extern int			addrconf_add_ifaddr(void __
 extern int			addrconf_del_ifaddr(void __user *arg);
 extern int			addrconf_set_dstaddr(void __user *arg);
 
-extern int			ipv6_chk_addr(struct in6_addr *addr,
+extern int			__ipv6_chk_addr(struct net *net,
+					      struct in6_addr *addr,
 					      struct net_device *dev,
 					      int strict);
+
+static inline int ipv6_chk_addr(struct in6_addr *addr,
+				struct net_device *dev,
+				int strict)
+{
+	return __ipv6_chk_addr(&init_net, addr, dev, strict);
+}
+
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 extern int			ipv6_chk_home_addr(struct in6_addr *addr);
 #endif
Index: linux-2.6-netns/net/ipv6/addrconf.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/addrconf.c
+++ linux-2.6-netns/net/ipv6/addrconf.c
@@ -1181,13 +1181,16 @@ static int ipv6_count_addresses(struct i
 	return cnt;
 }
 
-int ipv6_chk_addr(struct in6_addr *addr, struct net_device *dev, int strict)
+int __ipv6_chk_addr(struct net *net, struct in6_addr *addr,
+		  struct net_device *dev, int strict)
 {
 	struct inet6_ifaddr * ifp;
 	u8 hash = ipv6_addr_hash(addr);
 
 	read_lock_bh(&addrconf_hash_lock);
 	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
+		if (ifp->idev->dev->nd_net != net)
+			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr) &&
 		    !(ifp->flags&IFA_F_TENTATIVE)) {
 			if (dev == NULL || ifp->idev->dev == dev ||
@@ -1199,7 +1202,7 @@ int ipv6_chk_addr(struct in6_addr *addr,
 	return ifp != NULL;
 }
 
-EXPORT_SYMBOL(ipv6_chk_addr);
+EXPORT_SYMBOL(__ipv6_chk_addr);
 
 static
 int ipv6_chk_same_addr(const struct in6_addr *addr, struct net_device *dev)

-- 
