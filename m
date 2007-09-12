From: dlezcano@fr.ibm.com
Subject: [net-2.6.24][NETNS][patch 2/3] fix loopback network namespace initialization
Date: Wed, 12 Sep 2007 14:38:13 +0200
Message-ID: <20070912124419.150545693@mai.toulouse-stg.fr.ibm.com>
References: <20070912123811.075269132@mai.toulouse-stg.fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=net-fix-kernel-bug-dev-nd-net-null.patch
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: ebiederm@xmission.com, containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>

The core patchset of the network namespace sent by 
Eric Biederman does not do dynamic loopback creation.
So there is no call to alloc_netdev_mq which fills the
network namespace field of the netdevice.

This patch assign the loopback to the init network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 drivers/net/loopback.c |    1 +
 1 file changed, 1 insertion(+)

Index: net-2.6.24/drivers/net/loopback.c
===================================================================
--- net-2.6.24.orig/drivers/net/loopback.c
+++ net-2.6.24/drivers/net/loopback.c
@@ -225,6 +225,7 @@
 				  | NETIF_F_LLTX
 				  | NETIF_F_NETNS_LOCAL,
 	.ethtool_ops		= &loopback_ethtool_ops,
+	.nd_net                 = &init_net,
 };
 
 /* Setup and register the loopback device. */

-- 
