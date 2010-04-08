From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/4] Modularize the handling of netdev address c/r
Date: Thu,  8 Apr 2010 10:48:49 -0700
Message-ID: <1270748932-26745-2-git-send-email-danms@us.ibm.com>
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

This moves the INET4 address checkpoint and restart routines into
net/ipv4/devinet.c and introduces a registration method to present
the checkpoint code with the handler functions.

This makes it easier to add additional address types, and also
makes the cases where inet4 is absent, inet6 is a module, etc much
easier.  It also elminates the need for a couple of helper functions.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint.h     |   18 +++++-
 include/linux/checkpoint_hdr.h |    1 +
 net/checkpoint_dev.c           |  152 ++++++++++++++++++++++++----------------
 net/ipv4/devinet.c             |   75 ++++++++++++++++++++
 4 files changed, 184 insertions(+), 62 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 96693e2..5fdbd01 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -132,7 +132,8 @@ extern void *restore_netdev(struct ckpt_ctx *ctx);
 
 extern int ckpt_netdev_in_init_netns(struct ckpt_ctx *ctx,
 				     struct net_device *dev);
-extern int ckpt_netdev_inet_addrs(struct in_device *indev,
+extern int ckpt_netdev_inet_addrs(struct ckpt_ctx *ctx,
+				  struct net_device *dev,
 				  struct ckpt_netdev_addr *list[]);
 extern int ckpt_netdev_hwaddr(struct net_device *dev,
 			      struct ckpt_hdr_netdev *h);
@@ -513,6 +514,21 @@ extern void _ckpt_msg_complete(struct ckpt_ctx *ctx);
 	_do_ckpt_msg(ctx, err, "[E @ %s:%d]" fmt, __func__, __LINE__, ##args); \
 } while (0)
 
+struct ckpt_netdev_addr_handler {
+	int type;
+	struct module *owner;
+	int (*checkpoint_addr)(struct ckpt_ctx *ctx,
+			       struct net_device *dev,
+			       int index, int max,
+			       struct ckpt_netdev_addr *addrs);
+	int (*restore_addr)(struct ckpt_ctx *ctx,
+			    struct net_device *dev,
+			    struct net *net,
+			    struct ckpt_netdev_addr *addr);
+};
+extern int ckpt_netdev_addr_register(struct ckpt_netdev_addr_handler *);
+extern int ckpt_netdev_addr_unregister(struct ckpt_netdev_addr_handler *);
+
 #endif /* CONFIG_CHECKPOINT */
 #endif /* __KERNEL__ */
 
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 36386ad..13bf62c 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -804,6 +804,7 @@ struct ckpt_hdr_netdev {
 
 enum ckpt_netdev_addr_types {
 	CKPT_NETDEV_ADDR_IPV4,
+	CKPT_NETDEV_ADDR_MAX
 };
 
 struct ckpt_netdev_addr {
diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
index 5a4a95b..4ef06e3 100644
--- a/net/checkpoint_dev.c
+++ b/net/checkpoint_dev.c
@@ -12,11 +12,11 @@
 #include <linux/sched.h>
 #include <linux/if.h>
 #include <linux/if_arp.h>
-#include <linux/inetdevice.h>
 #include <linux/veth.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 #include <linux/deferqueue.h>
+#include <linux/module.h>
 
 #include <net/net_namespace.h>
 #include <net/sch_generic.h>
@@ -34,17 +34,64 @@ struct mvl_newlink {
 
 typedef int (*new_link_fn)(struct sk_buff *, void *);
 
-static int __kern_devinet_ioctl(struct net *net, unsigned int cmd, void *arg)
+static struct ckpt_netdev_addr_handler *addr_handlers[CKPT_NETDEV_ADDR_MAX];
+
+static char *addr_modules[] = {
+	"ipv4",		/* CKPT_NETDEV_ADDR_IPV4 */
+	"ipv6",		/* CKPT_NETDEV_ADDR_IPV6 */
+};
+
+int ckpt_netdev_addr_register(struct ckpt_netdev_addr_handler *h)
 {
-	mm_segment_t fs;
-	int ret;
+	if (h->type >= CKPT_NETDEV_ADDR_MAX)
+		return -EINVAL;
 
-	fs = get_fs();
-	set_fs(KERNEL_DS);
-	ret = devinet_ioctl(net, cmd, arg);
-	set_fs(fs);
+	if (addr_handlers[h->type] != NULL)
+		return -EEXIST;
 
-	return ret;
+	ckpt_debug("Registered addr type %s\n", addr_modules[h->type]);
+	addr_handlers[h->type] = h;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ckpt_netdev_addr_register);
+
+int ckpt_netdev_addr_unregister(struct ckpt_netdev_addr_handler *h)
+{
+	if (h->type >= CKPT_NETDEV_ADDR_MAX)
+		return -EINVAL;
+
+	if (addr_handlers[h->type] == NULL)
+		return -ESRCH;
+
+	ckpt_debug("Unregistered addr type %s\n", addr_modules[h->type]);
+	addr_handlers[h->type] = NULL;
+
+	return 0;
+}
+EXPORT_SYMBOL(ckpt_netdev_addr_unregister);
+
+static struct ckpt_netdev_addr_handler *get_addr_handler(int type)
+{
+	struct ckpt_netdev_addr_handler *h;
+
+	if (type >= CKPT_NETDEV_ADDR_MAX)
+		return ERR_PTR(-EINVAL);
+
+	h = addr_handlers[type];
+
+	if (h == NULL)
+		return NULL;
+
+	if (try_module_get(h->owner))
+		return h;
+	else
+		return ERR_PTR(-EBUSY);
+}
+
+static void put_addr_handler(struct ckpt_netdev_addr_handler *h)
+{
+	module_put(h->owner);
 }
 
 static int __kern_dev_ioctl(struct net *net, unsigned int cmd, void *arg)
@@ -151,13 +198,14 @@ int ckpt_netdev_hwaddr(struct net_device *dev, struct ckpt_hdr_netdev *h)
 	return 0;
 }
 
-int ckpt_netdev_inet_addrs(struct in_device *indev,
+int ckpt_netdev_inet_addrs(struct ckpt_ctx *ctx,
+			   struct net_device *dev,
 			   struct ckpt_netdev_addr *_abuf[])
 {
 	struct ckpt_netdev_addr *abuf = NULL;
-	struct in_ifaddr *addr = indev->ifa_list;
 	int addrs = 0;
 	int max = 32;
+	int i;
 
  retry:
 	*_abuf = krealloc(abuf, max * sizeof(*abuf), GFP_KERNEL);
@@ -169,19 +217,29 @@ int ckpt_netdev_inet_addrs(struct in_device *indev,
 
 	read_lock(&dev_base_lock);
 
-	while (addr) {
-		abuf[addrs].type = CKPT_NETDEV_ADDR_IPV4; /* Only IPv4 now */
-		abuf[addrs].inet4_local = htonl(addr->ifa_local);
-		abuf[addrs].inet4_address = htonl(addr->ifa_address);
-		abuf[addrs].inet4_mask = htonl(addr->ifa_mask);
-		abuf[addrs].inet4_broadcast = htonl(addr->ifa_broadcast);
+	addrs = 0;
 
-		addr = addr->ifa_next;
-		if (++addrs >= max) {
+	for (i = 0; i < CKPT_NETDEV_ADDR_MAX; i++) {
+		struct ckpt_netdev_addr_handler *h;
+
+		h = get_addr_handler(i);
+		if (!h)
+			continue;
+		else if (IS_ERR(h)) {
+			addrs = PTR_ERR(h);
+			ckpt_err(ctx, addrs,
+				 "Unable to handle netdev addr type %s\n",
+				 addr_modules[i]);
+			break;
+		}
+
+		addrs = h->checkpoint_addr(ctx, dev, addrs, max, abuf);
+		put_addr_handler(h);
+		if (addrs == -E2BIG) {
 			read_unlock(&dev_base_lock);
-			max *= 2;
 			goto retry;
-		}
+		} else if (addrs < 0)
+			break;
 	}
 
 	read_unlock(&dev_base_lock);
@@ -210,7 +268,7 @@ struct ckpt_hdr_netdev *ckpt_netdev_base(struct ckpt_ctx *ctx,
 		goto out;
 
 	*addrs = NULL;
-	ret = h->inet_addrs = ckpt_netdev_inet_addrs(dev->ip_ptr, addrs);
+	ret = h->inet_addrs = ckpt_netdev_inet_addrs(ctx, dev, addrs);
 	if (ret < 0)
 		goto out;
 
@@ -307,49 +365,21 @@ static int restore_in_addrs(struct ckpt_ctx *ctx,
 
 	for (i = 0; i < naddrs; i++) {
 		struct ckpt_netdev_addr *addr = &addrs[i];
-		struct ifreq req;
-		struct sockaddr_in *inaddr;
-
-		if (addr->type != CKPT_NETDEV_ADDR_IPV4) {
-			ret = -EINVAL;
-			ckpt_err(ctx, ret, "Unsupported netdev addr type %i\n",
-				 addr->type);
-			break;
-		}
-
-		ckpt_debug("restoring %s: %x/%x/%x\n", dev->name,
-			   addr->inet4_address,
-			   addr->inet4_mask,
-			   addr->inet4_broadcast);
-
-		memcpy(req.ifr_name, dev->name, IFNAMSIZ);
-
-		inaddr = (struct sockaddr_in *)&req.ifr_addr;
-		inaddr->sin_addr.s_addr = ntohl(addr->inet4_address);
-		inaddr->sin_family = AF_INET;
-		ret = __kern_devinet_ioctl(net, SIOCSIFADDR, &req);
-		if (ret < 0) {
-			ckpt_err(ctx, ret, "Failed to set address\n");
-			break;
-		}
-
-		inaddr = (struct sockaddr_in *)&req.ifr_addr;
-		inaddr->sin_addr.s_addr = ntohl(addr->inet4_mask);
-		inaddr->sin_family = AF_INET;
-		ret = __kern_devinet_ioctl(net, SIOCSIFNETMASK, &req);
-		if (ret < 0) {
-			ckpt_err(ctx, ret, "Failed to set netmask\n");
+		struct ckpt_netdev_addr_handler *h;
+
+		h = get_addr_handler(addr->type);
+		if (!h || IS_ERR(h)) {
+			ret = h ? PTR_ERR(h) : -EINVAL;
+			ckpt_err(ctx, ret,
+				 "Netdev addr type %s not supported\n",
+				 addr_modules[addr->type]);
 			break;
 		}
 
-		inaddr = (struct sockaddr_in *)&req.ifr_addr;
-		inaddr->sin_addr.s_addr = ntohl(addr->inet4_broadcast);
-		inaddr->sin_family = AF_INET;
-		ret = __kern_devinet_ioctl(net, SIOCSIFBRDADDR, &req);
-		if (ret < 0) {
-			ckpt_err(ctx, ret, "Failed to set broadcast\n");
+		ret = h->restore_addr(ctx, dev, net, addr);
+		put_addr_handler(h);
+		if (ret < 0)
 			break;
-		}
 	}
 
  out:
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 26dec2b..fa7799c 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -54,6 +54,7 @@
 #include <linux/sysctl.h>
 #endif
 #include <linux/kmod.h>
+#include <linux/checkpoint.h>
 
 #include <net/arp.h>
 #include <net/ip.h>
@@ -1616,6 +1617,76 @@ static __net_initdata struct pernet_operations devinet_ops = {
 	.exit = devinet_exit_net,
 };
 
+#ifdef CONFIG_NETNS_CHECKPOINT
+static int devinet_checkpoint(struct ckpt_ctx *ctx, struct net_device *dev,
+			      int index, int max,
+			      struct ckpt_netdev_addr *addrs)
+{
+	struct in_device *indev = dev->ip_ptr;
+	struct in_ifaddr *addr = indev->ifa_list;
+
+	for (addr = indev->ifa_list; addr ; addr = addr->ifa_next) {
+		addrs[index].type = CKPT_NETDEV_ADDR_IPV4;
+		addrs[index].inet4_local = htonl(addr->ifa_local);
+		addrs[index].inet4_address = htonl(addr->ifa_address);
+		addrs[index].inet4_mask = htonl(addr->ifa_mask);
+		addrs[index].inet4_broadcast = htonl(addr->ifa_broadcast);
+
+		if (++index >= max)
+			return -E2BIG;
+	}
+
+	return index;
+}
+
+static int devinet_restore(struct ckpt_ctx *ctx, struct net_device *dev,
+			   struct net *net, struct ckpt_netdev_addr *addr)
+{
+	struct ifreq req;
+	struct sockaddr_in *inaddr;
+	int ret;
+	mm_segment_t fs = get_fs();
+
+	set_fs(KERNEL_DS);
+
+	inaddr = (struct sockaddr_in *)&req.ifr_addr;
+	inaddr->sin_family = AF_INET;
+	memcpy(req.ifr_name, dev->name, IFNAMSIZ);
+
+	inaddr->sin_addr.s_addr = ntohl(addr->inet4_address);
+	ret = devinet_ioctl(net, SIOCSIFADDR, &req);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "Failed to set address\n");
+		goto out;
+	}
+
+	inaddr->sin_addr.s_addr = ntohl(addr->inet4_mask);
+	ret = devinet_ioctl(net, SIOCSIFNETMASK, &req);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "Failed to set netmask\n");
+		goto out;
+	}
+
+	inaddr->sin_addr.s_addr = ntohl(addr->inet4_broadcast);
+	ret = devinet_ioctl(net, SIOCSIFBRDADDR, &req);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "Failed to set broadcast\n");
+		goto out;
+	}
+ out:
+	set_fs(fs);
+
+	return ret;
+}
+
+static struct ckpt_netdev_addr_handler devinet_ckpt = {
+	.type			= CKPT_NETDEV_ADDR_IPV4,
+	.owner			= THIS_MODULE,
+	.checkpoint_addr	= devinet_checkpoint,
+	.restore_addr		= devinet_restore,
+};
+#endif /* CONFIG_NETNS_CHECKPOINT */
+
 void __init devinet_init(void)
 {
 	register_pernet_subsys(&devinet_ops);
@@ -1626,5 +1697,9 @@ void __init devinet_init(void)
 	rtnl_register(PF_INET, RTM_NEWADDR, inet_rtm_newaddr, NULL);
 	rtnl_register(PF_INET, RTM_DELADDR, inet_rtm_deladdr, NULL);
 	rtnl_register(PF_INET, RTM_GETADDR, NULL, inet_dump_ifaddr);
+
+#ifdef CONFIG_NETNS_CHECKPOINT
+	ckpt_netdev_addr_register(&devinet_ckpt);
+#endif
 }
 
-- 
1.6.2.5
