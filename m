From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH] netns: Coexist with the sysfs limitations
Date: Wed, 22 Oct 2008 13:32:36 -0700
Message-ID: <m17i80nzff.fsf__18607.2379620329$1224707805$gmane$org@frodo.ebiederm.org>
References: <20081022152144.351965414@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081022152144.351965414-4vkkeT0zb4ZEtYaxpPmRp1aPQRlvutdw@public.gmane.org> (Benjamin Thery's
	message of "Wed, 22 Oct 2008 17:21:44 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Denis Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Dave Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org


To make testing of the network namespace simpler allow
the network namespace code and the sysfs code to be
compiled and run at the same time.  To do this only
virtual devices are allowed in the additional network
namespaces and those virtual devices are not placed
in the kobject tree.

Since virtual devices don't actually do anything interesting
hardware wise that needs device management there should
be no loss in keeping them out of the kobject tree and
by implication sysfs.  The gain in ease of testing
and code coverage should be significant.

I.e. people running distributions that make it next to
impossible to boot without sysfs should at be able to
boot a test kernel now.

Plus no ABIs are harmed with this patch.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 net/Kconfig          |    2 +-
 net/core/dev.c       |   12 +++++++++++-
 net/core/net-sysfs.c |    7 +++++++
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index d789d79..8c3d97c 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -27,7 +27,7 @@ menu "Networking options"
 config NET_NS
 	bool "Network namespace support"
 	default n
-	depends on EXPERIMENTAL && !SYSFS && NAMESPACES
+	depends on EXPERIMENTAL && NAMESPACES
 	help
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
diff --git a/net/core/dev.c b/net/core/dev.c
index b8a4fd0..a7f0461 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4449,6 +4449,15 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	if (dev->features & NETIF_F_NETNS_LOCAL)
 		goto out;
 
+#ifdef CONFIG_SYSFS
+	/* Don't allow real devices to be moved when sysfs
+	 * is enabled.
+	 */
+	err = -EINVAL;
+	if (dev->dev.parent)
+		goto out;
+#endif
+
 	/* Ensure the device has been registrered */
 	err = -EINVAL;
 	if (dev->reg_state != NETREG_REGISTERED)
@@ -4506,6 +4515,8 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	 */
 	dev_addr_discard(dev);
 
+	netdev_unregister_kobject(dev);
+
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
 
@@ -4522,7 +4533,6 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	}
 
 	/* Fixup kobjects */
-	netdev_unregister_kobject(dev);
 	err = netdev_register_kobject(dev);
 	WARN_ON(err);
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 92d6b94..85cb8bd 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -476,6 +476,10 @@ void netdev_unregister_kobject(struct net_device * net)
 	struct device *dev = &(net->dev);
 
 	kobject_get(&dev->kobj);
+
+	if (dev_net(net) != &init_net)
+		return;
+
 	device_del(dev);
 }
 
@@ -501,6 +505,9 @@ int netdev_register_kobject(struct net_device *net)
 #endif
 #endif /* CONFIG_SYSFS */
 
+	if (dev_net(net) != &init_net)
+		return 0;
+
 	return device_add(dev);
 }
 
-- 
1.5.3.rc6.17.g1911
