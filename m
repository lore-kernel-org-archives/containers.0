From: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Subject: [patch 1/1] fix bad netif_carrier_off place
Date: Tue, 18 Sep 2007 18:56:46 +0200
Message-ID: <20070918170430.254614330@mai.toulouse-stg.fr.ibm.com>
References: <20070918165645.365056264@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=fix-veth-netcarrier-off.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

If the netif_carrier_off is called before register_netdev
that will use and generate an event for a non initialized network
device and that leads to a Oops.

I moved the netif_carrier_off from the setup function after each 
register_netdev call.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/veth.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: net-2.6.24/drivers/net/veth.c
===================================================================
--- net-2.6.24.orig/drivers/net/veth.c
+++ net-2.6.24/drivers/net/veth.c
@@ -286,7 +286,6 @@ static void veth_setup(struct net_device
 	dev->features |= NETIF_F_LLTX;
 	dev->init = veth_dev_init;
 	dev->destructor = veth_dev_free;
-	netif_carrier_off(dev);
 }
 
 /*
@@ -357,6 +356,8 @@ static int veth_newlink(struct net_devic
 	if (err < 0)
 		goto err_register_peer;
 
+	netif_carrier_off(peer);
+
 	/*
 	 * register dev last
 	 *
@@ -382,6 +383,8 @@ static int veth_newlink(struct net_devic
 	if (err < 0)
 		goto err_register_dev;
 
+	netif_carrier_off(dev);
+
 	/*
 	 * tie the deviced together
 	 */

-- 
