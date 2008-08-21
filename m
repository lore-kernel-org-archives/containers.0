From: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [PATCH 2/2] netns bridge: cleanup bridges during netns stop
Date: Fri, 22 Aug 2008 02:18:30 +0400
Message-ID: <20080821221830.GN31136__3701.40158706835$1219357381$gmane$org@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 net/bridge/br.c         |   22 ++++++++++++++++------
 net/bridge/br_if.c      |    4 ++--
 net/bridge/br_private.h |    2 +-
 3 files changed, 19 insertions(+), 9 deletions(-)

--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -28,6 +28,10 @@ static const struct stp_proto br_stp_proto = {
 	.rcv	= br_stp_rcv,
 };
 
+static struct pernet_operations br_net_ops = {
+	.exit	= br_net_exit,
+};
+
 static int __init br_init(void)
 {
 	int err;
@@ -42,18 +46,22 @@ static int __init br_init(void)
 	if (err)
 		goto err_out;
 
-	err = br_netfilter_init();
+	err = register_pernet_subsys(&br_net_ops);
 	if (err)
 		goto err_out1;
 
-	err = register_netdevice_notifier(&br_device_notifier);
+	err = br_netfilter_init();
 	if (err)
 		goto err_out2;
 
-	err = br_netlink_init();
+	err = register_netdevice_notifier(&br_device_notifier);
 	if (err)
 		goto err_out3;
 
+	err = br_netlink_init();
+	if (err)
+		goto err_out4;
+
 	brioctl_set(br_ioctl_deviceless_stub);
 	br_handle_frame_hook = br_handle_frame;
 
@@ -61,10 +69,12 @@ static int __init br_init(void)
 	br_fdb_put_hook = br_fdb_put;
 
 	return 0;
-err_out3:
+err_out4:
 	unregister_netdevice_notifier(&br_device_notifier);
-err_out2:
+err_out3:
 	br_netfilter_fini();
+err_out2:
+	unregister_pernet_subsys(&br_net_ops);
 err_out1:
 	br_fdb_fini();
 err_out:
@@ -80,7 +90,7 @@ static void __exit br_deinit(void)
 	unregister_netdevice_notifier(&br_device_notifier);
 	brioctl_set(NULL);
 
-	br_cleanup_bridges();
+	unregister_pernet_subsys(&br_net_ops);
 
 	synchronize_net();
 
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -446,13 +446,13 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	return 0;
 }
 
-void __exit br_cleanup_bridges(void)
+void br_net_exit(struct net *net)
 {
 	struct net_device *dev;
 
 	rtnl_lock();
 restart:
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev(net, dev) {
 		if (dev->priv_flags & IFF_EBRIDGE) {
 			del_br(dev->priv);
 			goto restart;
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -180,7 +180,7 @@ extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb);
 extern void br_port_carrier_check(struct net_bridge_port *p);
 extern int br_add_bridge(struct net *net, const char *name);
 extern int br_del_bridge(struct net *net, const char *name);
-extern void br_cleanup_bridges(void);
+extern void br_net_exit(struct net *net);
 extern int br_add_if(struct net_bridge *br,
 	      struct net_device *dev);
 extern int br_del_if(struct net_bridge *br,
