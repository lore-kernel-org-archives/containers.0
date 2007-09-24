From: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Subject: [patch 1/3][netns] net: Activate inetdev event for IPV4
Date: Mon, 24 Sep 2007 14:21:13 +0200
Message-ID: <20070924122833.706560181@mai.toulouse-stg.fr.ibm.com>
References: <20070924122112.065703991@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=net-activate-inetdev-event-for-ipv4.patch
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

The event notification is disabled when the current
network namespace is not the init one. The route are
not created when setting up a new IP address.

I activate the notification to fix these problems.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 net/core/fib_rules.c    |    3 ---
 net/core/rtnetlink.c    |    3 ---
 net/ipv4/fib_frontend.c |    3 ---
 3 files changed, 9 deletions(-)

Index: linux-2.6-netns/net/core/fib_rules.c
===================================================================
--- linux-2.6-netns.orig/net/core/fib_rules.c
+++ linux-2.6-netns/net/core/fib_rules.c
@@ -605,9 +605,6 @@ static int fib_rules_event(struct notifi
 	struct net *net = dev->nd_net;
 	struct fib_rules_ops *ops;
 
-	if (dev->nd_net != &init_net)
-		return NOTIFY_DONE;
-
 	ASSERT_RTNL();
 	rcu_read_lock();
 
Index: linux-2.6-netns/net/core/rtnetlink.c
===================================================================
--- linux-2.6-netns.orig/net/core/rtnetlink.c
+++ linux-2.6-netns/net/core/rtnetlink.c
@@ -1348,9 +1348,6 @@ static int rtnetlink_event(struct notifi
 {
 	struct net_device *dev = ptr;
 
-	if (dev->nd_net != &init_net)
-		return NOTIFY_DONE;
-
 	switch (event) {
 	case NETDEV_UNREGISTER:
 		rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
Index: linux-2.6-netns/net/ipv4/fib_frontend.c
===================================================================
--- linux-2.6-netns.orig/net/ipv4/fib_frontend.c
+++ linux-2.6-netns/net/ipv4/fib_frontend.c
@@ -902,9 +902,6 @@ static int fib_netdev_event(struct notif
 	struct net_device *dev = ptr;
 	struct in_device *in_dev = __in_dev_get_rtnl(dev);
 
-	if (dev->nd_net != &init_net)
-		return NOTIFY_DONE;
-
 	if (event == NETDEV_UNREGISTER) {
 		fib_disable_ip(dev, 2);
 		return NOTIFY_DONE;

-- 
