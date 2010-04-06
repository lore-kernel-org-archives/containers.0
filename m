From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] C/R: Support for IPv6 addresses on network devices (v2)
Date: Tue,  6 Apr 2010 07:13:01 -0700
Message-ID: <1270563183-9351-2-git-send-email-danms@us.ibm.com>
References: <1270563183-9351-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1270563183-9351-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Changes in v2:
 - Store an in6_addr structure in the checkpoint stream
 - Fix network byte order conversion
 - Don't checkpoint and restore non-global scope addresses
 - Fail checkpoint if we find global scope multicast or anycast
   addresses

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint.h     |    2 +-
 include/linux/checkpoint_hdr.h |    8 ++
 net/checkpoint_dev.c           |  272 ++++++++++++++++++++++++++++++++--------
 3 files changed, 228 insertions(+), 54 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 96693e2..2caa38c 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -132,7 +132,7 @@ extern void *restore_netdev(struct ckpt_ctx *ctx);
 
 extern int ckpt_netdev_in_init_netns(struct ckpt_ctx *ctx,
 				     struct net_device *dev);
-extern int ckpt_netdev_inet_addrs(struct in_device *indev,
+extern int ckpt_netdev_inet_addrs(struct net_device *dev,
 				  struct ckpt_netdev_addr *list[]);
 extern int ckpt_netdev_hwaddr(struct net_device *dev,
 			      struct ckpt_hdr_netdev *h);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 36386ad..90e4934 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -804,6 +804,7 @@ struct ckpt_hdr_netdev {
 
 enum ckpt_netdev_addr_types {
 	CKPT_NETDEV_ADDR_IPV4,
+	CKPT_NETDEV_ADDR_IPV6,
 };
 
 struct ckpt_netdev_addr {
@@ -815,6 +816,13 @@ struct ckpt_netdev_addr {
 			__be32 inet4_mask;
 			__be32 inet4_broadcast;
 		};
+		struct {
+			struct in6_addr inet6_addr;
+			__u32  inet6_prefix_len;
+			__u32  inet6_valid_lft;
+			__u32  inet6_prefered_lft;
+			__u16  inet6_scope;
+		};
 	} __attribute__((aligned(8)));
 } __attribute__((aligned(8)));
 
diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
index 5a4a95b..776931b 100644
--- a/net/checkpoint_dev.c
+++ b/net/checkpoint_dev.c
@@ -18,8 +18,11 @@
 #include <linux/checkpoint_hdr.h>
 #include <linux/deferqueue.h>
 
+#include <net/if_inet6.h>
+#include <net/ipv6.h>
 #include <net/net_namespace.h>
 #include <net/sch_generic.h>
+#include <net/addrconf.h>
 
 struct veth_newlink {
 	char *peer;
@@ -47,6 +50,24 @@ static int __kern_devinet_ioctl(struct net *net, unsigned int cmd, void *arg)
 	return ret;
 }
 
+#ifdef CONFIG_IPV6
+static int __kern_addrconf(struct net *net, unsigned int cmd, void *arg)
+{
+	mm_segment_t fs;
+	int ret;
+
+	fs = get_fs();
+	set_fs(KERNEL_DS);
+	if (cmd == SIOCSIFADDR)
+		ret = addrconf_add_ifaddr(net, arg);
+	else
+		ret = -EINVAL;
+	set_fs(fs);
+
+	return ret;
+}
+#endif
+
 static int __kern_dev_ioctl(struct net *net, unsigned int cmd, void *arg)
 {
 	mm_segment_t fs;
@@ -151,11 +172,109 @@ int ckpt_netdev_hwaddr(struct net_device *dev, struct ckpt_hdr_netdev *h)
 	return 0;
 }
 
-int ckpt_netdev_inet_addrs(struct in_device *indev,
+static int ckpt_netdev_inet4_addrs(struct in_device *indev,
+				   int index, int max,
+				   struct ckpt_netdev_addr *abuf)
+{
+	struct in_ifaddr *addr = indev->ifa_list;
+
+	while (addr) {
+		abuf[index].type = CKPT_NETDEV_ADDR_IPV4;
+		abuf[index].inet4_local = htonl(addr->ifa_local);
+		abuf[index].inet4_address = htonl(addr->ifa_address);
+		abuf[index].inet4_mask = htonl(addr->ifa_mask);
+		abuf[index].inet4_broadcast = htonl(addr->ifa_broadcast);
+
+		addr = addr->ifa_next;
+		if (++index >= max)
+			return -E2BIG;
+	}
+
+	return index;
+}
+
+#ifdef CONFIG_IPV6
+
+#define __BYTE_ORDER_COPY(op, dst, src)					\
+	do {								\
+		int i;							\
+		for (i = 0; i < 16; i++) {				\
+			(dst)->in6_u.u6_addr8[i] =			\
+				(src)->in6_u.u6_addr8[16-i];		\
+		}							\
+	} while (0);
+
+#define HTON_IPV6(dst, src) __BYTE_ORDER_COPY(htonl, dst, src)
+#define NTOH_IPV6(dst, src) __BYTE_ORDER_COPY(ntohl, dst, src)
+
+static int ckpt_netdev_inet6_addrs(struct inet6_dev *indev,
+				   int index, int max,
+				   struct ckpt_netdev_addr *abuf)
+{
+	struct inet6_ifaddr *addr;
+	struct ifmcaddr6 *mcaddr;
+	struct ifacaddr6 *acaddr;
+
+	for (addr = indev->addr_list; addr; addr = addr->if_next) {
+		if (ipv6_addr_scope(&addr->addr))
+			continue; /* Ignore non-global scope addresses */
+
+		abuf[index].type = CKPT_NETDEV_ADDR_IPV6;
+
+		HTON_IPV6(&abuf[index].inet6_addr, &addr->addr);
+
+		ckpt_debug("Checkpointed inet6: %pI6\n", &addr->addr);
+
+		abuf[index].inet6_prefix_len = addr->prefix_len;
+		abuf[index].inet6_valid_lft = addr->valid_lft;
+		abuf[index].inet6_prefered_lft = addr->prefered_lft;
+		abuf[index].inet6_scope = addr->scope;
+
+		if (++index >= max)
+			return -E2BIG;
+	}
+
+	for (mcaddr = indev->mc_list; mcaddr; mcaddr = mcaddr->next) {
+		if (ipv6_addr_scope(&mcaddr->mca_addr))
+			continue; /* Ignore non-global scope addresses */
+
+		/* TODO */
+
+		/* Multicast addresses are not supported, so do not
+		 * allow checkpoint to continue if one is assigned
+		 */
+		ckpt_debug("ipv6 multicast addresses are not supported\n");
+		return -EINVAL;
+	}
+
+	for (acaddr = indev->ac_list; acaddr; acaddr = acaddr->aca_next) {
+		if (ipv6_addr_scope(&acaddr->aca_addr))
+			continue; /* Ignore non-global scope addresses */
+
+		/* TODO */
+
+		/* Anycast addresses are not supported, so do not
+		 * allow checkpoint to continue if one is assigned
+		 */
+		ckpt_debug("ipv6 anycast addresses are not supported\n");
+		return -EINVAL;
+	}
+
+	return index;
+}
+#else
+static int ckpt_netdev_inet6_addrs(struct inet6_dev *indev,
+				   int index, int max,
+				   struct ckpt_netdev_addr *abuf)
+{
+	return -ENOSYS;
+}
+#endif
+
+int ckpt_netdev_inet_addrs(struct net_device *dev,
 			   struct ckpt_netdev_addr *_abuf[])
 {
 	struct ckpt_netdev_addr *abuf = NULL;
-	struct in_ifaddr *addr = indev->ifa_list;
 	int addrs = 0;
 	int max = 32;
 
@@ -169,21 +288,21 @@ int ckpt_netdev_inet_addrs(struct in_device *indev,
 
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
-			read_unlock(&dev_base_lock);
-			max *= 2;
-			goto retry;
-		}
-	}
+	addrs = ckpt_netdev_inet4_addrs(dev->ip_ptr, addrs, max, abuf);
+	if (addrs == -E2BIG) {
+		read_unlock(&dev_base_lock);
+		goto retry;
+	} else if (addrs < 0)
+		goto unlock;
 
+	addrs = ckpt_netdev_inet6_addrs(dev->ip6_ptr, addrs, max, abuf);
+	if (addrs == -E2BIG) {
+		read_unlock(&dev_base_lock);
+		goto retry;
+	}
+ unlock:
 	read_unlock(&dev_base_lock);
  out:
 	if (addrs < 0) {
@@ -210,7 +329,7 @@ struct ckpt_hdr_netdev *ckpt_netdev_base(struct ckpt_ctx *ctx,
 		goto out;
 
 	*addrs = NULL;
-	ret = h->inet_addrs = ckpt_netdev_inet_addrs(dev->ip_ptr, addrs);
+	ret = h->inet_addrs = ckpt_netdev_inet_addrs(dev, addrs);
 	if (ret < 0)
 		goto out;
 
@@ -291,6 +410,85 @@ int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr)
 	return ret;
 }
 
+static int restore_inet4_addr(struct ckpt_ctx *ctx,
+			      struct net_device *dev,
+			      struct net *net,
+			      struct ckpt_netdev_addr *addr)
+{
+	struct ifreq req;
+	struct sockaddr_in *inaddr;
+	int ret;
+
+	ckpt_debug("restoring %s: %x/%x/%x\n",
+		   dev->name,
+		   addr->inet4_address,
+		   addr->inet4_mask,
+		   addr->inet4_broadcast);
+
+	memcpy(req.ifr_name, dev->name, IFNAMSIZ);
+
+	inaddr = (struct sockaddr_in *)&req.ifr_addr;
+	inaddr->sin_addr.s_addr = ntohl(addr->inet4_address);
+	inaddr->sin_family = AF_INET;
+	ret = __kern_devinet_ioctl(net, SIOCSIFADDR, &req);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "Failed to set address\n");
+		return ret;
+	}
+
+	inaddr = (struct sockaddr_in *)&req.ifr_addr;
+	inaddr->sin_addr.s_addr = ntohl(addr->inet4_mask);
+	inaddr->sin_family = AF_INET;
+	ret = __kern_devinet_ioctl(net, SIOCSIFNETMASK, &req);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "Failed to set netmask\n");
+		return ret;
+	}
+
+	inaddr = (struct sockaddr_in *)&req.ifr_addr;
+	inaddr->sin_addr.s_addr = ntohl(addr->inet4_broadcast);
+	inaddr->sin_family = AF_INET;
+	ret = __kern_devinet_ioctl(net, SIOCSIFBRDADDR, &req);
+	if (ret < 0) {
+		ckpt_err(ctx, ret, "Failed to set broadcast\n");
+		return ret;
+	}
+
+	return 0;
+}
+
+#ifdef CONFIG_IPV6
+static int restore_inet6_addr(struct ckpt_ctx *ctx,
+			      struct net_device *dev,
+			      struct net *net,
+			      struct ckpt_netdev_addr *addr)
+{
+	struct in6_ifreq req;
+	int ret;
+
+	req.ifr6_ifindex = dev->ifindex;
+	NTOH_IPV6(&req.ifr6_addr, &addr->inet6_addr);
+	req.ifr6_prefixlen = addr->inet6_prefix_len;
+
+	ckpt_debug("Restored %s: %pI6\n", dev->name, &req.ifr6_addr);
+
+	ret = __kern_addrconf(net, SIOCSIFADDR, &req);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "Failed to set address");
+
+	return ret;
+}
+#else
+static int restore_inet6_addr(struct ckpt_ctx *ctx,
+			      struct net_device *dev,
+			      struct net *net,
+			      struct ckpt_netdev_addr *addr)
+{
+	ckpt_err(ctx, -ENOSYS, "IPv6 not supported");
+	return -ENOSYS;
+}
+#endif
+
 static int restore_in_addrs(struct ckpt_ctx *ctx,
 			    __u32 naddrs,
 			    struct net *net,
@@ -307,49 +505,17 @@ static int restore_in_addrs(struct ckpt_ctx *ctx,
 
 	for (i = 0; i < naddrs; i++) {
 		struct ckpt_netdev_addr *addr = &addrs[i];
-		struct ifreq req;
-		struct sockaddr_in *inaddr;
 
-		if (addr->type != CKPT_NETDEV_ADDR_IPV4) {
+		if (addr->type == CKPT_NETDEV_ADDR_IPV4)
+			ret = restore_inet4_addr(ctx, dev, net, addr);
+		else if (addr->type == CKPT_NETDEV_ADDR_IPV6)
+			ret = restore_inet6_addr(ctx, dev, net, addr);
+		else {
 			ret = -EINVAL;
 			ckpt_err(ctx, ret, "Unsupported netdev addr type %i\n",
 				 addr->type);
 			break;
 		}
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
-			break;
-		}
-
-		inaddr = (struct sockaddr_in *)&req.ifr_addr;
-		inaddr->sin_addr.s_addr = ntohl(addr->inet4_broadcast);
-		inaddr->sin_family = AF_INET;
-		ret = __kern_devinet_ioctl(net, SIOCSIFBRDADDR, &req);
-		if (ret < 0) {
-			ckpt_err(ctx, ret, "Failed to set broadcast\n");
-			break;
-		}
 	}
 
  out:
-- 
1.6.2.5
