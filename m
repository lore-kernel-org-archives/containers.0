From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/4] Fail checkpoint if IPv4 multicast addresses are configured
Date: Thu,  8 Apr 2010 10:48:50 -0700
Message-ID: <1270748932-26745-3-git-send-email-danms@us.ibm.com>
References: <1270748932-26745-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1270748932-26745-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
 net/ipv4/devinet.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index fa7799c..83411fc 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1624,6 +1624,7 @@ static int devinet_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev,
 {
 	struct in_device *indev = dev->ip_ptr;
 	struct in_ifaddr *addr = indev->ifa_list;
+	struct ip_mc_list *mcaddr;
 
 	for (addr = indev->ifa_list; addr ; addr = addr->ifa_next) {
 		addrs[index].type = CKPT_NETDEV_ADDR_IPV4;
@@ -1636,6 +1637,20 @@ static int devinet_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev,
 			return -E2BIG;
 	}
 
+	for (mcaddr = indev->mc_list; mcaddr; mcaddr = mcaddr->next) {
+		if ((mcaddr->multiaddr & IGMP_LOCAL_GROUP_MASK) ==
+		    IGMP_LOCAL_GROUP)
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
