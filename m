From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 8/9] netns ebtables: deal with fake netdevices et al
Date: Fri, 1 Aug 2008 05:39:38 +0400
Message-ID: <20080801013938.GI26761@martell.zuzino.mipt.ru>
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
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Bridge netfilter code uses fake netdevice and fake rtable. Fake means
"static struct net_device". So these should be logically created in
bridge's portion of struct netns.

But!

Adding "struct net_device __fake_net_device" creates header circular dependency,
which is PITA to resolve. I couldn't, so fake netdevice and fake rtable
are created dynamically. :-(

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/net/netns/bridge.h |   11 ++++-
 net/bridge/br_netfilter.c  |   88 ++++++++++++++++++++++++++++++++-------------
 2 files changed, 71 insertions(+), 28 deletions(-)

--- a/include/net/netns/bridge.h
+++ b/include/net/netns/bridge.h
@@ -3,10 +3,15 @@
 
 #include <linux/list.h>
 
+struct net_device;
+struct rtable;
+
 struct netns_br {
 	struct list_head	ebt_tables;
-	struct ebt_table *broute_table;
-	struct ebt_table *frame_filter;
-	struct ebt_table *frame_nat;
+	struct ebt_table	*broute_table;
+	struct ebt_table	*frame_filter;
+	struct ebt_table	*frame_nat;
+	struct net_device	*__fake_net_device;
+	struct rtable		*__fake_rtable;
 };
 #endif
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -109,24 +109,47 @@ static inline __be16 pppoe_proto(const struct sk_buff *skb)
  * refragmentation needs it, and the rt_flags entry because
  * ipt_REJECT needs it.  Future netfilter modules might
  * require us to fill additional fields. */
-static struct net_device __fake_net_device = {
-	.hard_header_len	= ETH_HLEN,
+static int br_netfilter_net_init(struct net *net)
+{
+	net->br.__fake_net_device = kmalloc(sizeof(struct net_device), GFP_KERNEL);
+	if (!net->br.__fake_net_device)
+		return -ENOMEM;
+	net->br.__fake_rtable = kmalloc(sizeof(struct rtable), GFP_KERNEL);
+	if (!net->br.__fake_rtable) {
+		kfree(net->br.__fake_net_device);
+		return -ENOMEM;
+	}
+
+	*net->br.__fake_net_device = (struct net_device) {
+		.hard_header_len	= ETH_HLEN,
 #ifdef CONFIG_NET_NS
-	.nd_net			= &init_net,
+		.nd_net			= net,
 #endif
-};
+	};
+	*net->br.__fake_rtable = (struct rtable) {
+		.u = {
+			.dst = {
+				.__refcnt	= ATOMIC_INIT(1),
+				.dev		= net->br.__fake_net_device,
+				.path		= &net->br.__fake_rtable->u.dst,
+				.metrics	= {[RTAX_MTU - 1] = 1500},
+				.flags		= DST_NOXFRM,
+			}
+		},
+		.rt_flags	= 0,
+	};
+	return 0;
+}
 
-static struct rtable __fake_rtable = {
-	.u = {
-		.dst = {
-			.__refcnt		= ATOMIC_INIT(1),
-			.dev			= &__fake_net_device,
-			.path			= &__fake_rtable.u.dst,
-			.metrics		= {[RTAX_MTU - 1] = 1500},
-			.flags			= DST_NOXFRM,
-		}
-	},
-	.rt_flags	= 0,
+static void br_netfilter_net_exit(struct net *net)
+{
+	kfree(net->br.__fake_rtable);
+	kfree(net->br.__fake_net_device);
+}
+
+static struct pernet_operations br_netfilter_net_ops = {
+	.init = br_netfilter_net_init,
+	.exit = br_netfilter_net_exit,
 };
 
 static inline struct net_device *bridge_parent(const struct net_device *dev)
@@ -218,6 +241,7 @@ int nf_bridge_copy_header(struct sk_buff *skb)
  * bridge PRE_ROUTING hook. */
 static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 {
+	struct net *net = dev_net(skb->dev);
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 
 	if (nf_bridge->mask & BRNF_PKT_TYPE) {
@@ -226,8 +250,8 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 	}
 	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 
-	skb->rtable = &__fake_rtable;
-	dst_hold(&__fake_rtable.u.dst);
+	skb->rtable = net->br.__fake_rtable;
+	dst_hold(&net->br.__fake_rtable->u.dst);
 
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_push_encap_header(skb);
@@ -323,6 +347,7 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 static int br_nf_pre_routing_finish(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
+	struct net *net = dev_net(dev);
 	struct iphdr *iph = ip_hdr(skb);
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	int err;
@@ -356,7 +381,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 			if (err != -EHOSTUNREACH || !in_dev || IN_DEV_FORWARD(in_dev))
 				goto free_skb;
 
-			if (!ip_route_output_key(&init_net, &rt, &fl)) {
+			if (!ip_route_output_key(net, &rt, &fl)) {
 				/* - Bridged-and-DNAT'ed traffic doesn't
 				 *   require ip_forwarding. */
 				if (((struct dst_entry *)rt)->dev == dev) {
@@ -391,8 +416,8 @@ bridged_dnat:
 			skb->pkt_type = PACKET_HOST;
 		}
 	} else {
-		skb->rtable = &__fake_rtable;
-		dst_hold(&__fake_rtable.u.dst);
+		skb->rtable = net->br.__fake_rtable;
+		dst_hold(&net->br.__fake_rtable->u.dst);
 	}
 
 	skb->dev = nf_bridge->physindev;
@@ -611,8 +636,10 @@ static unsigned int br_nf_local_in(unsigned int hook, struct sk_buff *skb,
 				   const struct net_device *out,
 				   int (*okfn)(struct sk_buff *))
 {
-	if (skb->rtable == &__fake_rtable) {
-		dst_release(&__fake_rtable.u.dst);
+	struct net *net = dev_net(in);
+
+	if (skb->rtable == net->br.__fake_rtable) {
+		dst_release(&net->br.__fake_rtable->u.dst);
 		skb->rtable = NULL;
 	}
 
@@ -979,18 +1006,28 @@ int __init br_netfilter_init(void)
 
 	ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
 	if (ret < 0)
-		return ret;
+		goto out;
+	ret = register_pernet_subsys(&br_netfilter_net_ops);
+	if (ret < 0)
+		goto out_net_ops;
 #ifdef CONFIG_SYSCTL
 	brnf_sysctl_header = register_sysctl_paths(brnf_path, brnf_table);
 	if (brnf_sysctl_header == NULL) {
 		printk(KERN_WARNING
 		       "br_netfilter: can't register to sysctl.\n");
-		nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
-		return -ENOMEM;
+		ret = -ENOMEM;
+		goto out_sysctl;
 	}
 #endif
 	printk(KERN_NOTICE "Bridge firewalling registered\n");
 	return 0;
+
+out_sysctl:
+	unregister_pernet_subsys(&br_netfilter_net_ops);
+out_net_ops:
+	nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+out:
+	return ret;
 }
 
 void br_netfilter_fini(void)
@@ -999,4 +1036,5 @@ void br_netfilter_fini(void)
 #ifdef CONFIG_SYSCTL
 	unregister_sysctl_table(brnf_sysctl_header);
 #endif
+	unregister_pernet_subsys(&br_netfilter_net_ops);
 }
-- 
1.5.4.5
