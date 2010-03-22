From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 6/6] Clean up the error path in restore_veth()
Date: Mon, 22 Mar 2010 12:33:35 -0700
Message-ID: <1269286415-24851-7-git-send-email-danms@us.ibm.com>
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

This uses the previously-added rtnl_dellink() helper to tear down the
pair all at once by specifying one of the halves by name (which is how
userspace does it and how RTNL expects it to be done).  It also uses
the ckpt_obj_del() function to pull the devices out of the hash and drop
the references before it makes the call to destroy.  The result is a
unified and much cleaner error path for the entire function.

All the "goto err" paths have been checked by injecting errors.  They
all cleanup the interfaces properly and cleanly.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 net/checkpoint_dev.c |   87 +++++++++++++++++--------------------------------
 1 files changed, 30 insertions(+), 57 deletions(-)

diff --git a/net/checkpoint_dev.c b/net/checkpoint_dev.c
index 0091eb9..2bb3d4d 100644
--- a/net/checkpoint_dev.c
+++ b/net/checkpoint_dev.c
@@ -21,11 +21,6 @@
 #include <net/net_namespace.h>
 #include <net/sch_generic.h>
 
-struct dq_netdev {
-	struct net_device *dev;
-	struct ckpt_ctx *ctx;
-};
-
 struct veth_newlink {
 	char *peer;
 };
@@ -577,25 +572,6 @@ static int rtnl_dellink(char *name)
 	return ret;
 }
 
-static int netdev_noop(void *data)
-{
-	return 0;
-}
-
-static int netdev_cleanup(void *data)
-{
-	struct dq_netdev *dq = data;
-
-	dev_put(dq->dev);
-
-	if (dq->ctx->errno) {
-		ckpt_debug("Unregistering netdev %s\n", dq->dev->name);
-		unregister_netdev(dq->dev);
-	}
-
-	return 0;
-}
-
 static struct net_device *restore_veth(struct ckpt_ctx *ctx,
 				       struct ckpt_hdr_netdev *h,
 				       struct net *net)
@@ -606,9 +582,6 @@ static struct net_device *restore_veth(struct ckpt_ctx *ctx,
 	struct net_device *dev;
 	struct net_device *peer;
 	struct ifreq req;
-	struct dq_netdev dq;
-
-	dq.ctx = ctx;
 
 	ret = _ckpt_read_buffer(ctx, this_name, IFNAMSIZ);
 	if (ret < 0)
@@ -630,37 +603,31 @@ static struct net_device *restore_veth(struct ckpt_ctx *ctx,
 		if (IS_ERR(dev))
 			return dev;
 
+		ret = ckpt_obj_insert(ctx, dev, h->veth.this_ref,
+				      CKPT_OBJ_NETDEV);
+		dev_put(dev);
+		if (ret < 0)
+			goto err;
+
 		peer = dev_get_by_name(current->nsproxy->net_ns, peer_name);
 		if (!peer) {
 			ret = -EINVAL;
-			goto err_dev;
+			goto err;
 		}
 
-		dq.dev = peer;
-		ret = deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
-				     netdev_noop, netdev_cleanup);
-		if (ret)
-			goto err_peer;
-
 		ret = ckpt_obj_insert(ctx, peer, h->veth.peer_ref,
 				      CKPT_OBJ_NETDEV);
-		if (ret < 0)
-			/* Can't recall peer dq, so let it cleanup peer */
-			goto err_dev;
 		dev_put(peer);
-
-		dq.dev = dev;
-		ret = deferqueue_add(ctx->deferqueue, &dq, sizeof(dq),
-				     netdev_noop, netdev_cleanup);
-		if (ret)
-			/* Can't recall peer dq, so let it cleanup peer */
-			goto err_dev;
+		if (ret < 0)
+			goto err;
 
 	} else {
 		/* We're second: get our dev from the hash */
 		dev = ckpt_obj_fetch(ctx, h->veth.this_ref, CKPT_OBJ_NETDEV);
-		if (IS_ERR(dev))
-			return dev;
+		if (IS_ERR(dev)) {
+			ret = PTR_ERR(dev);
+			goto err;
+		}
 	}
 
 	/* Move to our new netns */
@@ -668,25 +635,31 @@ static struct net_device *restore_veth(struct ckpt_ctx *ctx,
 	ret = dev_change_net_namespace(dev, net, dev->name);
 	rtnl_unlock();
 	if (ret < 0)
-		goto out;
+		goto err;
 
 	/* Restore MAC address */
 	memcpy(req.ifr_name, dev->name, IFNAMSIZ);
 	memcpy(req.ifr_hwaddr.sa_data, h->hwaddr, sizeof(h->hwaddr));
 	req.ifr_hwaddr.sa_family = ARPHRD_ETHER;
 	ret = __kern_dev_ioctl(net, SIOCSIFHWADDR, &req);
- out:
-	if (ret)
-		dev = ERR_PTR(ret);
+	if (ret < 0)
+		goto err;
 
 	return dev;
-
- err_peer:
-	dev_put(peer);
-	unregister_netdev(peer);
- err_dev:
-	dev_put(dev);
-	unregister_netdev(dev);
+ err:
+	/* Delete from hash to drop reference */
+	ckpt_obj_del(ctx, h->veth.this_ref, CKPT_OBJ_NETDEV);
+	ckpt_obj_del(ctx, h->veth.peer_ref, CKPT_OBJ_NETDEV);
+
+	/* This will fail to delete the interface if we get here
+	 * because of a failed attempt at setting the hardware
+	 * address, since the device has been moved to another netns.
+	 * This is not a problem, however, because the death of that
+	 * netns will take the device (and its peer) down with it
+	 * cleanly.
+	 */
+	if (rtnl_dellink(this_name) < 0)
+		ckpt_debug("failed to delete interfaces on error\n");
 
 	return ERR_PTR(ret);
 }
-- 
1.6.2.5
