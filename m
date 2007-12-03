From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 06/38][IPV6] inet6_addr - ipv6_chk_same_addr namespace aware
Date: Mon, 03 Dec 2007 17:16:42 +0100
Message-ID: <20071203162443.741454632@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=inet6-addr-ipv6-chk-same-addr.patch
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

This patch makes ipv6_chk_same_addr function to be aware of the network
namespace. The addresses not belonging to the network namespace are 
discarded.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/ipv6/addrconf.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

Index: linux-2.6-netns/net/ipv6/addrconf.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/addrconf.c
+++ linux-2.6-netns/net/ipv6/addrconf.c
@@ -141,7 +141,8 @@ static void ipv6_ifa_notify(int event, s
 
 static void inet6_prefix_notify(int event, struct inet6_dev *idev,
 				struct prefix_info *pinfo);
-static int ipv6_chk_same_addr(const struct in6_addr *addr, struct net_device *dev);
+static int ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
+			      struct net_device *dev);
 
 static ATOMIC_NOTIFIER_HEAD(inet6addr_chain);
 
@@ -535,7 +536,7 @@ ipv6_add_addr(struct inet6_dev *idev, co
 	write_lock(&addrconf_hash_lock);
 
 	/* Ignore adding duplicate addresses on an interface */
-	if (ipv6_chk_same_addr(addr, idev->dev)) {
+	if (ipv6_chk_same_addr(idev->dev->nd_net, addr, idev->dev)) {
 		ADBG(("ipv6_add_addr: already assigned\n"));
 		err = -EEXIST;
 		goto out;
@@ -1205,12 +1206,15 @@ int ipv6_chk_addr(struct net *net, struc
 EXPORT_SYMBOL(ipv6_chk_addr);
 
 static
-int ipv6_chk_same_addr(const struct in6_addr *addr, struct net_device *dev)
+int ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
+		       struct net_device *dev)
 {
 	struct inet6_ifaddr * ifp;
 	u8 hash = ipv6_addr_hash(addr);
 
 	for(ifp = inet6_addr_lst[hash]; ifp; ifp=ifp->lst_next) {
+		if (ifp->idev->dev->nd_net != net)
+			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
 			if (dev == NULL || ifp->idev->dev == dev)
 				break;

-- 
