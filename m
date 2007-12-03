From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 08/38][IPV6] inet6_addr - remove ipv6_get_ifaddr wrapper
Date: Mon, 03 Dec 2007 17:16:44 +0100
Message-ID: <20071203162446.984433366@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=inet6-addr-ipv6-get-ifaddr-2.patch
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

The previous patch introduced a new parameter to the ipv6_get_ifaddr 
function and made a wrapper around it in order to reduce the impact
of the patch and to facilitate code review.

This patch removes the wrapper and propagate the function change to
all callers.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 include/net/addrconf.h |   15 ++++-----------
 net/ipv6/addrconf.c    |   10 +++++-----
 net/ipv6/ip6_output.c  |    3 ++-
 net/ipv6/ndisc.c       |    9 +++++----
 4 files changed, 16 insertions(+), 21 deletions(-)

Index: linux-2.6-netns/include/net/addrconf.h
===================================================================
--- linux-2.6-netns.orig/include/net/addrconf.h
+++ linux-2.6-netns/include/net/addrconf.h
@@ -66,17 +66,10 @@ extern int			ipv6_chk_addr(struct net *n
 #if defined(CONFIG_IPV6_MIP6) || defined(CONFIG_IPV6_MIP6_MODULE)
 extern int			ipv6_chk_home_addr(struct in6_addr *addr);
 #endif
-extern struct inet6_ifaddr      *__ipv6_get_ifaddr(struct net *net,
-						   struct in6_addr *addr,
-						   struct net_device *dev,
-						   int strict);
-
-static inline struct inet6_ifaddr *ipv6_get_ifaddr(struct in6_addr *addr,
-						   struct net_device *dev,
-						   int strict)
-{
-	return __ipv6_get_ifaddr(&init_net, addr, dev, strict);
-}
+extern struct inet6_ifaddr      *ipv6_get_ifaddr(struct net *net,
+						 struct in6_addr *addr,
+						 struct net_device *dev,
+						 int strict);
 
 extern int			ipv6_get_saddr(struct dst_entry *dst, 
 					       struct in6_addr *daddr,
Index: linux-2.6-netns/net/ipv6/addrconf.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/addrconf.c
+++ linux-2.6-netns/net/ipv6/addrconf.c
@@ -1223,8 +1223,8 @@ int ipv6_chk_same_addr(struct net *net, 
 	return ifp != NULL;
 }
 
-struct inet6_ifaddr * __ipv6_get_ifaddr(struct net *net, struct in6_addr *addr,
-					struct net_device *dev, int strict)
+struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, struct in6_addr *addr,
+				     struct net_device *dev, int strict)
 {
 	struct inet6_ifaddr * ifp;
 	u8 hash = ipv6_addr_hash(addr);
@@ -1715,7 +1715,7 @@ void addrconf_prefix_rcv(struct net_devi
 
 ok:
 
-		ifp = ipv6_get_ifaddr(&addr, dev, 1);
+		ifp = ipv6_get_ifaddr(dev->nd_net, &addr, dev, 1);
 
 		if (ifp == NULL && valid_lft) {
 			int max_addresses = in6_dev->cnf.max_addresses;
@@ -3103,7 +3103,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, s
 	/* We ignore other flags so far. */
 	ifa_flags = ifm->ifa_flags & (IFA_F_NODAD | IFA_F_HOMEADDRESS);
 
-	ifa = ipv6_get_ifaddr(pfx, dev, 1);
+	ifa = ipv6_get_ifaddr(net, pfx, dev, 1);
 	if (ifa == NULL) {
 		/*
 		 * It would be best to check for !NLM_F_CREATE here but
@@ -3410,7 +3410,7 @@ static int inet6_rtm_getaddr(struct sk_b
 	if (ifm->ifa_index)
 		dev = __dev_get_by_index(&init_net, ifm->ifa_index);
 
-	if ((ifa = ipv6_get_ifaddr(addr, dev, 1)) == NULL) {
+	if ((ifa = ipv6_get_ifaddr(net, addr, dev, 1)) == NULL) {
 		err = -EADDRNOTAVAIL;
 		goto errout;
 	}
Index: linux-2.6-netns/net/ipv6/ip6_output.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/ip6_output.c
+++ linux-2.6-netns/net/ipv6/ip6_output.c
@@ -936,7 +936,8 @@ static int ip6_dst_lookup_tail(struct so
 			struct flowi fl_gw;
 			int redirect;
 
-			ifp = ipv6_get_ifaddr(&fl->fl6_src, (*dst)->dev, 1);
+			ifp = ipv6_get_ifaddr(&init_net, &fl->fl6_src,
+					      (*dst)->dev, 1);
 
 			redirect = (ifp && ifp->flags & IFA_F_OPTIMISTIC);
 			if (ifp)
Index: linux-2.6-netns/net/ipv6/ndisc.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/ndisc.c
+++ linux-2.6-netns/net/ipv6/ndisc.c
@@ -557,7 +557,7 @@ static void ndisc_send_na(struct net_dev
 	};
 
 	/* for anycast or proxy, solicited_addr != src_addr */
-	ifp = ipv6_get_ifaddr(solicited_addr, dev, 1);
+	ifp = ipv6_get_ifaddr(&init_net, solicited_addr, dev, 1);
 	if (ifp) {
 		src_addr = solicited_addr;
 		if (ifp->flags & IFA_F_OPTIMISTIC)
@@ -617,7 +617,8 @@ void ndisc_send_rs(struct net_device *de
 	 * supress the inclusion of the sllao.
 	 */
 	if (send_sllao) {
-		struct inet6_ifaddr *ifp = ipv6_get_ifaddr(saddr, dev, 1);
+		struct inet6_ifaddr *ifp = ipv6_get_ifaddr(&init_net, saddr,
+							   dev, 1);
 		if (ifp) {
 			if (ifp->flags & IFA_F_OPTIMISTIC)  {
 				send_sllao = 0;
@@ -742,7 +743,7 @@ static void ndisc_recv_ns(struct sk_buff
 
 	inc = ipv6_addr_is_multicast(daddr);
 
-	if ((ifp = ipv6_get_ifaddr(&msg->target, dev, 1)) != NULL) {
+	if ((ifp = ipv6_get_ifaddr(&init_net, &msg->target, dev, 1)) != NULL) {
 
 		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
 			if (dad) {
@@ -900,7 +901,7 @@ static void ndisc_recv_na(struct sk_buff
 			return;
 		}
 	}
-	if ((ifp = ipv6_get_ifaddr(&msg->target, dev, 1))) {
+	if ((ifp = ipv6_get_ifaddr(&init_net, &msg->target, dev, 1))) {
 		if (ifp->flags & IFA_F_TENTATIVE) {
 			addrconf_dad_failure(ifp);
 			return;

-- 
