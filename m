From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 35/38][IPV6] addrconf - Add a network namespace parameter to
	addrconf_forward_change
Date: Mon, 03 Dec 2007 17:17:11 +0100
Message-ID: <20071203162529.921559103@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=addrconf-forward-per-namespace.patch
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

Add a network namespace parameter to addrconf_forward_change to 
remove reference to init_net and make it more generic.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/ipv6/addrconf.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6-netns/net/ipv6/addrconf.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/addrconf.c
+++ linux-2.6-netns/net/ipv6/addrconf.c
@@ -451,13 +451,13 @@ static void dev_forward_change(struct in
 }
 
 
-static void addrconf_forward_change(void)
+static void addrconf_forward_change(struct net *net)
 {
 	struct net_device *dev;
 	struct inet6_dev *idev;
 
 	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(net, dev) {
 		rcu_read_lock();
 		idev = __in6_dev_get(dev);
 		if (idev) {
@@ -3808,7 +3808,7 @@ int addrconf_sysctl_forward(ctl_table *c
 			}
 		} else {
 			ipv6_devconf_dflt.forwarding = ipv6_devconf.forwarding;
-			addrconf_forward_change();
+			addrconf_forward_change(&init_net);
 		}
 		if (*valp)
 			rt6_purge_dflt_routers(&init_net);
@@ -3860,7 +3860,7 @@ static int addrconf_sysctl_forward_strat
 				dev_forward_change(idev);
 		} else {
 			*valp = new;
-			addrconf_forward_change();
+			addrconf_forward_change(&init_net);
 		}
 
 		if (*valp)

-- 
