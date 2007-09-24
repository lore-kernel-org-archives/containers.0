From: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Subject: [patch 2/3][netns] net: Activate arp for non init netns
Date: Mon, 24 Sep 2007 14:21:14 +0200
Message-ID: <20070924122835.845520047@mai.toulouse-stg.fr.ibm.com>
References: <20070924122112.065703991@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=net-activate-arp.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

Arp is disabled for network namespace different from the init_net.
This patch enables it again.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 net/ipv4/arp.c |    6 ------
 1 file changed, 6 deletions(-)

Index: linux-2.6-netns/net/ipv4/arp.c
===================================================================
--- linux-2.6-netns.orig/net/ipv4/arp.c
+++ linux-2.6-netns/net/ipv4/arp.c
@@ -939,9 +939,6 @@ static int arp_rcv(struct sk_buff *skb, 
 {
 	struct arphdr *arp;
 
-	if (dev->nd_net != &init_net)
-		goto freeskb;
-
 	/* ARP header, plus 2 device addresses, plus 2 IP addresses.  */
 	if (!pskb_may_pull(skb, (sizeof(struct arphdr) +
 				 (2 * dev->addr_len) +
@@ -1216,9 +1213,6 @@ static int arp_netdev_event(struct notif
 {
 	struct net_device *dev = ptr;
 
-	if (dev->nd_net != &init_net)
-		return NOTIFY_DONE;
-
 	switch (event) {
 	case NETDEV_CHANGEADDR:
 		neigh_changeaddr(&arp_tbl, dev);

-- 
