From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/6] C/R: Netdev and NetNS fixes
Date: Mon, 22 Mar 2010 12:33:30 -0700
Message-ID: <1269286415-24851-2-git-send-email-danms@us.ibm.com>
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

These are fixes to the netdev/netns code to address things that Oren
pointed out after the initial review of that code.  Included are:

 - Netdev restore function dispatching from a table
 - Added a comment about the controverial determination of "initial netns"
 - Simplify the E2BIG error handling
 - Remove a redundant check for checkpoint support per-device

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 include/linux/checkpoint_hdr.h |    1 +
 net/checkpoint_dev.c           |  102 +++++++++++++++++++---------------------
 2 files changed, 49 insertions(+), 54 deletions(-)

diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 061d1d5..01553b4 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -779,6 +779,7 @@ enum ckpt_netdev_types {
 	CKPT_NETDEV_VETH,
 	CKPT_NETDEV_SIT,
 	CKPT_NETDEV_MACVLAN,
+	CKPT_NETDEV_MAX,
 };
 
 struct ckpt_hdr_netdev {
diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
index 9117a55..24186c5 100644
--- a/net/checkpoint_dev.c
+++ b/net/checkpoint_dev.c
@@ -92,6 +92,8 @@ static struct nlmsghdr *rtnl_get_response(struct socket *rtnl,
 	long timeo = MAX_SCHEDULE_TIMEOUT;
 	struct nlmsghdr *nlh;
 
+	*skb = NULL;
+
 	ret = sk_wait_data(rtnl->sk, &timeo);
 	if (!ret)
 		return ERR_PTR(-EPIPE);
@@ -121,6 +123,13 @@ static struct nlmsghdr *rtnl_get_response(struct socket *rtnl,
 
 int ckpt_netdev_in_init_netns(struct ckpt_ctx *ctx, struct net_device *dev)
 {
+	/*
+	 * Currently, we treat the "initial network namespace" as that
+	 * of the process doing the checkpoint.  This gives us a
+	 * consistent view of the container and its layout from the
+	 * perspective of the "agent" doing the checkpoint and
+	 * restore.
+	 */
 	return dev->nd_net == current->nsproxy->net_ns;
 }
 
@@ -132,9 +141,9 @@ int ckpt_netdev_hwaddr(struct net_device *dev, struct ckpt_hdr_netdev *h)
 
 	memcpy(req.ifr_name, dev->name, IFNAMSIZ);
 	ret = __kern_dev_ioctl(net, SIOCGIFFLAGS, &req);
-	h->flags = req.ifr_flags;
 	if (ret < 0)
 		return ret;
+	h->flags = req.ifr_flags;
 
 	ret = __kern_dev_ioctl(net, SIOCGIFHWADDR, &req);
 	if (ret < 0)
@@ -150,17 +159,11 @@ int ckpt_netdev_inet_addrs(struct in_device *indev,
 {
 	struct ckpt_netdev_addr *abuf = NULL;
 	struct in_ifaddr *addr = indev->ifa_list;
-	int pages = 0;
 	int addrs = 0;
-	int max;
+	int max = 32;
 
  retry:
-	if (++pages > 4) {
-		addrs = -E2BIG;
-		goto out;
-	}
-
-	*_abuf = krealloc(abuf, PAGE_SIZE * pages, GFP_KERNEL);
+	*_abuf = krealloc(abuf, max * sizeof(*abuf), GFP_KERNEL);
 	if (*_abuf == NULL) {
 		addrs = -ENOMEM;
 		goto out;
@@ -169,7 +172,6 @@ int ckpt_netdev_inet_addrs(struct in_device *indev,
 
 	read_lock(&dev_base_lock);
 
-	max = (pages * PAGE_SIZE) / sizeof(*abuf);
 	while (addr) {
 		abuf[addrs].type = CKPT_NETDEV_ADDR_IPV4; /* Only IPv4 now */
 		abuf[addrs].inet4_local = htonl(addr->ifa_local);
@@ -180,6 +182,7 @@ int ckpt_netdev_inet_addrs(struct in_device *indev,
 		addr = addr->ifa_next;
 		if (++addrs >= max) {
 			read_unlock(&dev_base_lock);
+			max *= 2;
 			goto retry;
 		}
 	}
@@ -211,13 +214,8 @@ struct ckpt_hdr_netdev *ckpt_netdev_base(struct ckpt_ctx *ctx,
 
 	*addrs = NULL;
 	ret = h->inet_addrs = ckpt_netdev_inet_addrs(dev->ip_ptr, addrs);
-	if (ret < 0) {
-		if (ret == -E2BIG)
-			ckpt_err(ctx, ret,
-				 "Too many inet addresses on interface %s\n",
-				 dev->name);
+	if (ret < 0)
 		goto out;
-	}
 
 	if (ckpt_netdev_in_init_netns(ctx, dev))
 		ret = h->netns_ref = 0;
@@ -238,6 +236,7 @@ struct ckpt_hdr_netdev *ckpt_netdev_base(struct ckpt_ctx *ctx,
 int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr)
 {
 	struct net_device *dev = (struct net_device *)ptr;
+	int ret;
 
 	if (!dev->netdev_ops->ndo_checkpoint) {
 		ckpt_err(ctx, -ENOSYS,
@@ -247,7 +246,12 @@ int checkpoint_netdev(struct ckpt_ctx *ctx, void *ptr)
 
 	ckpt_debug("checkpointing netdev %s\n", dev->name);
 
-	return dev->netdev_ops->ndo_checkpoint(ctx, dev);
+	ret = dev->netdev_ops->ndo_checkpoint(ctx, dev);
+	if (ret < 0)
+		ckpt_err(ctx, ret, "Failed to checkpoint netdev %s: %i\n",
+			 dev->name, ret);
+
+	return ret;
 }
 
 int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr)
@@ -262,21 +266,13 @@ int checkpoint_netns(struct ckpt_ctx *ctx, void *ptr)
 		return -ENOMEM;
 
 	h->this_ref = ckpt_obj_lookup(ctx, net, CKPT_OBJ_NET_NS);
-	BUG_ON(h->this_ref == 0);
+	BUG_ON(h->this_ref <= 0);
 
 	ret = ckpt_write_obj(ctx, (struct ckpt_hdr *) h);
 	if (ret < 0)
 		goto out;
 
 	for_each_netdev(net, dev) {
-		if (!dev->netdev_ops->ndo_checkpoint) {
-			ret = -ENOSYS;
-			ckpt_err(ctx, ret,
-				 "Device %s does not support checkpoint\n",
-				 dev->name);
-			break;
-		}
-
 		ret = checkpoint_obj(ctx, dev, CKPT_OBJ_NETDEV);
 		if (ret < 0)
 			break;
@@ -297,11 +293,7 @@ static int restore_in_addrs(struct ckpt_ctx *ctx,
 	int len = naddrs * sizeof(struct ckpt_netdev_addr);
 	struct ckpt_netdev_addr *addrs = NULL;
 
-	addrs = kmalloc(len, GFP_KERNEL);
-	if (!addrs)
-		return -ENOMEM;
-
-	ret = _ckpt_read_buffer(ctx, addrs, len);
+	ret = ckpt_read_payload(ctx, (void **)&addrs, len, CKPT_HDR_BUFFER);
 	if (ret < 0)
 		goto out;
 
@@ -414,7 +406,7 @@ static int mvl_new_link_msg(struct sk_buff *skb, void *data)
 	linkinfo = nla_nest_start(skb, IFLA_LINKINFO);
 	if (!linkinfo) {
 		ret = -ENOMEM;
-		goto out;
+		goto out_put;
 	}
 
 	ret = nla_put_string(skb, IFLA_INFO_KIND, "macvlan");
@@ -484,10 +476,9 @@ static struct net_device *rtnl_newlink(new_link_fn fn, void *data, char *name)
 
 	skb = new_link_msg(fn, data, name);
 	if (IS_ERR(skb)) {
-		ret = PTR_ERR(skb);
-		ckpt_debug("failed to create new link message: %i\n", ret);
-		skb = NULL;
-		goto out;
+		ckpt_debug("failed to create new link message: %li\n",
+			   PTR_ERR(skb));
+		return ERR_PTR(PTR_ERR(skb));
 	}
 
 	memset(&msg, 0, sizeof(msg));
@@ -556,7 +547,6 @@ static struct net_device *restore_veth(struct ckpt_ctx *ctx,
 	char peer_name[IFNAMSIZ];
 	struct net_device *dev;
 	struct net_device *peer;
-	int didreg = 0;
 	struct ifreq req;
 	struct dq_netdev dq;
 
@@ -578,9 +568,6 @@ static struct net_device *restore_veth(struct ckpt_ctx *ctx,
 			.peer = peer_name,
 		};
 
-		/* We're first: allocate the veth pair */
-		didreg = 1;
-
 		dev = rtnl_newlink(veth_new_link_msg, &veth, this_name);
 		if (IS_ERR(dev))
 			return dev;
@@ -725,6 +712,17 @@ static struct net_device *restore_macvlan(struct ckpt_ctx *ctx,
 	return dev;
 }
 
+typedef struct net_device *(*restore_netdev_fn)(struct ckpt_ctx *,
+						struct ckpt_hdr_netdev *,
+						struct net *);
+
+restore_netdev_fn restore_netdev_functions[] = {
+	restore_lo,     	/* CKPT_NETDEV_LO */
+	restore_veth,   	/* CKPT_NETDEV_VETH */
+	restore_sit,    	/* CKPT_NETDEV_SIT */
+	restore_macvlan,	/* CKPT_NETDEV_MACVLAN */
+};
+
 void *restore_netdev(struct ckpt_ctx *ctx)
 {
 	struct ckpt_hdr_netdev *h;
@@ -732,35 +730,31 @@ void *restore_netdev(struct ckpt_ctx *ctx)
 	struct ifreq req;
 	struct net *net;
 	int ret;
+	restore_netdev_fn restore_fn = NULL;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_NETDEV);
-	if (IS_ERR(h)) {
-		ckpt_err(ctx, PTR_ERR(h), "failed to read netdev\n");
+	if (IS_ERR(h))
 		return h;
-	}
 
 	if (h->netns_ref != 0) {
 		net = ckpt_obj_try_fetch(ctx, h->netns_ref, CKPT_OBJ_NET_NS);
 		if (IS_ERR(net)) {
 			ckpt_debug("failed to get net for %i\n", h->netns_ref);
 			ret = PTR_ERR(net);
-			net = current->nsproxy->net_ns;
 			goto out;
 		}
 	} else
 		net = current->nsproxy->net_ns;
 
-	if (h->type == CKPT_NETDEV_VETH)
-		dev = restore_veth(ctx, h, net);
-	else if (h->type == CKPT_NETDEV_LO)
-		dev = restore_lo(ctx, h, net);
-	else if (h->type == CKPT_NETDEV_SIT)
-		dev = restore_sit(ctx, h, net);
-	else if (h->type == CKPT_NETDEV_MACVLAN)
-		dev = restore_macvlan(ctx, h, net);
-	else
-		dev = ERR_PTR(-EINVAL);
+	if (h->type >= CKPT_NETDEV_MAX) {
+		ret = -EINVAL;
+		ckpt_err(ctx, ret, "Invalid netdev type %i\n", h->type);
+		goto out;
+	}
+
+	restore_fn = restore_netdev_functions[h->type];
 
+	dev = restore_fn(ctx, h, net);
 	if (IS_ERR(dev)) {
 		ret = PTR_ERR(dev);
 		ckpt_err(ctx, ret, "Netdev type %i not supported\n", h->type);
-- 
1.6.2.5
