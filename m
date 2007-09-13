From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net: Fix the prototype of call_netdevice_notifiers
Date: Thu, 13 Sep 2007 09:59:05 -0600
Message-ID: <m1y7fa5zg6.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org


This replaces the void * parameter with a struct net_device * which
is what is actually required.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/netdevice.h |    2 +-
 net/core/dev.c            |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0106fa6..90aecc3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -779,7 +779,7 @@ extern void		free_netdev(struct net_device *dev);
 extern void		synchronize_net(void);
 extern int 		register_netdevice_notifier(struct notifier_block *nb);
 extern int		unregister_netdevice_notifier(struct notifier_block *nb);
-extern int		call_netdevice_notifiers(unsigned long val, void *v);
+extern int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 extern struct net_device	*dev_get_by_index(struct net *net, int ifindex);
 extern struct net_device	*__dev_get_by_index(struct net *net, int ifindex);
 extern int		dev_restart(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index f119dc0..cc343dd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1206,9 +1206,9 @@ int unregister_netdevice_notifier(struct notifier_block *nb)
  *	are as for raw_notifier_call_chain().
  */
 
-int call_netdevice_notifiers(unsigned long val, void *v)
+int call_netdevice_notifiers(unsigned long val, struct net_device *dev)
 {
-	return raw_notifier_call_chain(&netdev_chain, val, v);
+	return raw_notifier_call_chain(&netdev_chain, val, dev);
 }
 
 /* When > 0 there are consumers of rx skb time stamps */
-- 
1.5.3.rc6.17.g1911

