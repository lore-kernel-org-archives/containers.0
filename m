From: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Subject: [PATCH 3/4] net: cleanup some vars names to be more consistant with
	the network code
Date: Wed, 22 Oct 2008 17:22:14 +0200
Message-ID: <20081022152144.944690300__17916.6189198897$1224689182$gmane$org@theryb.frec.bull.fr>
References: <20081022152144.351965414@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

This small patch renames a couple of net_device variables from 
'net' to 'netdev' to avoid confusion with 'struct net' variables
that will be introduced in the next patch. 
'net' is commonly used to designate 'struct net' in the rest of 
the network code.

Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/core/net-sysfs.c |   17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

Index: net-next-2.6/net/core/net-sysfs.c
===================================================================
--- net-next-2.6.orig/net/core/net-sysfs.c
+++ net-next-2.6/net/core/net-sysfs.c
@@ -471,32 +471,33 @@ static struct class net_class = {
 /* Delete sysfs entries but hold kobject reference until after all
  * netdev references are gone.
  */
-void netdev_unregister_kobject(struct net_device * net)
+void netdev_unregister_kobject(struct net_device *netdev)
 {
-	struct device *dev = &(net->dev);
+	struct device *dev = &(netdev->dev);
 
 	kobject_get(&dev->kobj);
 	device_del(dev);
 }
 
 /* Create sysfs entries for network device. */
-int netdev_register_kobject(struct net_device *net)
+int netdev_register_kobject(struct net_device *netdev)
 {
-	struct device *dev = &(net->dev);
-	struct attribute_group **groups = net->sysfs_groups;
+	struct device *dev = &(netdev->dev);
+	struct attribute_group **groups = netdev->sysfs_groups;
 
 	dev->class = &net_class;
-	dev->platform_data = net;
+	dev->platform_data = netdev;
 	dev->groups = groups;
 
 	BUILD_BUG_ON(BUS_ID_SIZE < IFNAMSIZ);
-	strlcpy(dev->bus_id, net->name, BUS_ID_SIZE);
+	strlcpy(dev->bus_id, netdev->name, BUS_ID_SIZE);
 
 #ifdef CONFIG_SYSFS
 	*groups++ = &netstat_group;
 
 #ifdef CONFIG_WIRELESS_EXT_SYSFS
-	if (net->wireless_handlers && net->wireless_handlers->get_wireless_stats)
+	if (netdev->wireless_handlers &&
+	    netdev->wireless_handlers->get_wireless_stats)
 		*groups++ = &wireless_group;
 #endif
 #endif /* CONFIG_SYSFS */

-- 
