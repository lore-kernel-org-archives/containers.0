From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] Fail checkpoint if IPv4 multicast addresses are configured
Date: Tue,  6 Apr 2010 07:13:03 -0700
Message-ID: <1270563183-9351-4-git-send-email-danms@us.ibm.com>
References: <1270563183-9351-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1270563183-9351-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

This causes checkpoint to fail if an interface actually has a
multicast membership.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/checkpoint_dev.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
index 776931b..11c6544 100644
--- a/net/checkpoint_dev.c
+++ b/net/checkpoint_dev.c
@@ -17,6 +17,7 @@
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/deferqueue.h>
+#include <linux/igmp.h>
 
 #include <net/if_inet6.h>
 #include <net/ipv6.h>
@@ -177,6 +178,7 @@ static int ckpt_netdev_inet4_addrs(struct in_device *indev,
 				   struct ckpt_netdev_addr *abuf)
 {
 	struct in_ifaddr *addr = indev->ifa_list;
+	struct ip_mc_list *mcaddr;
 
 	while (addr) {
 		abuf[index].type = CKPT_NETDEV_ADDR_IPV4;
@@ -190,6 +192,19 @@ static int ckpt_netdev_inet4_addrs(struct in_device *indev,
 			return -E2BIG;
 	}
 
+	for (mcaddr = indev->mc_list; mcaddr; mcaddr = mcaddr->next) {
+		if ((mcaddr->multiaddr & IGMP_LOCAL_GROUP_MASK) == IGMP_LOCAL_GROUP)
+			continue;
+
+		/* TODO */
+
+		/* Multicast addresses are not supported, so do not
+		 * allow checkpoint to continue if one is assigned
+		 */
+		ckpt_debug("ipv4 multicast addresses are not supported\n");
+		return -EINVAL;
+	}
+
 	return index;
 }
 
-- 
1.6.2.5
