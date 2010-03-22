From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/6] Unbreak compiling with CONFIG_CHECKPOINT=n or
	CONFIG_NET_NS=n
Date: Mon, 22 Mar 2010 12:33:31 -0700
Message-ID: <1269286415-24851-3-git-send-email-danms@us.ibm.com>
References: <1269286415-24851-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1269286415-24851-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

This just changes the code to use CONFIG_CHECKPOINT_NETNS instead of
CONFIG_CHECKPOINT, as it shoud have been in the first place.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/loopback.c |    4 ++--
 drivers/net/macvlan.c  |    4 ++++
 drivers/net/veth.c     |    4 ++--
 net/ipv6/sit.c         |    4 ++++
 4 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 77023a7..68120b3 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -155,7 +155,7 @@ static void loopback_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
 
-#ifdef CONFIG_CHECKPOINT
+#ifdef CONFIG_CHECKPOINT_NETNS
 static int loopback_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev)
 {
 	struct ckpt_hdr_netdev *h;
@@ -192,7 +192,7 @@ static const struct net_device_ops loopback_ops = {
 	.ndo_init       = loopback_dev_init,
 	.ndo_start_xmit = loopback_xmit,
 	.ndo_get_stats  = loopback_get_stats,
-#ifdef CONFIG_CHECKPOINT
+#ifdef CONFIG_CHECKPOINT_NETNS
 	.ndo_checkpoint = loopback_checkpoint,
 #endif
 };
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 4d99501..2600514 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -495,6 +495,7 @@ static struct net_device_stats *macvlan_dev_get_stats(struct net_device *dev)
 	return stats;
 }
 
+#ifdef CONFIG_CHECKPOINT_NETNS
 static int macvlan_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
@@ -535,6 +536,7 @@ static int macvlan_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev)
 
 	return ret;
 }
+#endif
 
 static void macvlan_ethtool_get_drvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *drvinfo)
@@ -582,7 +584,9 @@ static const struct net_device_ops macvlan_netdev_ops = {
 	.ndo_set_multicast_list	= macvlan_set_multicast_list,
 	.ndo_get_stats		= macvlan_dev_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_CHECKPOINT_NETNS
 	.ndo_checkpoint		= macvlan_checkpoint,
+#endif
 };
 
 static void macvlan_setup(struct net_device *dev)
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index db92de8..da55546 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -287,7 +287,7 @@ static void veth_dev_free(struct net_device *dev)
 	free_netdev(dev);
 }
 
-#ifdef CONFIG_CHECKPOINT
+#ifdef CONFIG_CHECKPOINT_NETNS
 static int veth_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev)
 {
 	struct ckpt_hdr_netdev *h;
@@ -365,7 +365,7 @@ static const struct net_device_ops veth_netdev_ops = {
 	.ndo_change_mtu      = veth_change_mtu,
 	.ndo_get_stats       = veth_get_stats,
 	.ndo_set_mac_address = eth_mac_addr,
-#ifdef CONFIG_CHECKPOINT
+#ifdef CONFIG_CHECKPOINT_NETNS
 	.ndo_checkpoint      = veth_checkpoint,
 #endif
 };
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index a9fc331..fe2dd49 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1087,6 +1087,7 @@ static int ipip6_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+#ifdef CONFIG_CHECKPOINT_NETNS
 static int ipip6_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev)
 {
 	struct ckpt_hdr_netdev *h;
@@ -1113,13 +1114,16 @@ static int ipip6_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev)
 
 	return ret;
 }
+#endif
 
 static const struct net_device_ops ipip6_netdev_ops = {
 	.ndo_uninit	= ipip6_tunnel_uninit,
 	.ndo_start_xmit	= ipip6_tunnel_xmit,
 	.ndo_do_ioctl	= ipip6_tunnel_ioctl,
 	.ndo_change_mtu	= ipip6_tunnel_change_mtu,
+#ifdef CONFIG_CHECKPOINT_NETNS
 	.ndo_checkpoint	= ipip6_checkpoint,
+#endif
 };
 
 static void ipip6_tunnel_setup(struct net_device *dev)
-- 
1.6.2.5
