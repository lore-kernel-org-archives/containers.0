From: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [PATCH 4/6] netns brnetfilter: per-netns filter table
Date: Fri, 22 Aug 2008 02:22:05 +0400
Message-ID: <20080821222205.GR31136__6103.15283197469$1219357600$gmane$org@x200.localdomain>
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
To: shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/net/netns/bridge.h            |    1 
 net/bridge/netfilter/ebtable_filter.c |   51 ++++++++++++++++++++++++----------
 2 files changed, 38 insertions(+), 14 deletions(-)

--- a/include/net/netns/bridge.h
+++ b/include/net/netns/bridge.h
@@ -6,5 +6,6 @@
 struct netns_br {
 	struct list_head	ebt_tables;
 	struct ebt_table	*broute_table;
+	struct ebt_table	*frame_filter;
 };
 #endif
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -50,41 +50,47 @@ static int check(const struct ebt_table_info *info, unsigned int valid_hooks)
 	return 0;
 }
 
-static struct ebt_table __frame_filter =
+static struct ebt_table frame_filter =
 {
 	.name		= "filter",
 	.table		= &initial_table,
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(__frame_filter.lock),
+	.lock		= __RW_LOCK_UNLOCKED(frame_filter.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
-static struct ebt_table *frame_filter;
 
 static unsigned int
-ebt_hook(unsigned int hook, struct sk_buff *skb, const struct net_device *in,
+ebt_in_hook(unsigned int hook, struct sk_buff *skb, const struct net_device *in,
    const struct net_device *out, int (*okfn)(struct sk_buff *))
 {
-	return ebt_do_table(hook, skb, in, out, frame_filter);
+	return ebt_do_table(hook, skb, in, out, dev_net(in)->br.frame_filter);
+}
+
+static unsigned int
+ebt_out_hook(unsigned int hook, struct sk_buff *skb, const struct net_device *in,
+   const struct net_device *out, int (*okfn)(struct sk_buff *))
+{
+	return ebt_do_table(hook, skb, in, out, dev_net(out)->br.frame_filter);
 }
 
 static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
 	{
-		.hook		= ebt_hook,
+		.hook		= ebt_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_BRIDGE,
 		.hooknum	= NF_BR_LOCAL_IN,
 		.priority	= NF_BR_PRI_FILTER_BRIDGED,
 	},
 	{
-		.hook		= ebt_hook,
+		.hook		= ebt_in_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_BRIDGE,
 		.hooknum	= NF_BR_FORWARD,
 		.priority	= NF_BR_PRI_FILTER_BRIDGED,
 	},
 	{
-		.hook		= ebt_hook,
+		.hook		= ebt_out_hook,
 		.owner		= THIS_MODULE,
 		.pf		= PF_BRIDGE,
 		.hooknum	= NF_BR_LOCAL_OUT,
@@ -92,23 +98,41 @@ static struct nf_hook_ops ebt_ops_filter[] __read_mostly = {
 	},
 };
 
+static int frame_filter_net_init(struct net *net)
+{
+	net->br.frame_filter = ebt_register_table(net, &frame_filter);
+	if (IS_ERR(net->br.frame_filter))
+		return PTR_ERR(net->br.frame_filter);
+	return 0;
+}
+
+static void frame_filter_net_exit(struct net *net)
+{
+	ebt_unregister_table(net->br.frame_filter);
+}
+
+static struct pernet_operations frame_filter_net_ops = {
+	.init = frame_filter_net_init,
+	.exit = frame_filter_net_exit,
+};
+
 static int __init ebtable_filter_init(void)
 {
 	int ret;
 
-	frame_filter = ebt_register_table(&init_net, &__frame_filter);
-	if (IS_ERR(frame_filter))
-		return PTR_ERR(frame_filter);
+	ret = register_pernet_subsys(&frame_filter_net_ops);
+	if (ret < 0)
+		return ret;
 	ret = nf_register_hooks(ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
 	if (ret < 0)
-		ebt_unregister_table(frame_filter);
+		unregister_pernet_subsys(&frame_filter_net_ops);
 	return ret;
 }
 
 static void __exit ebtable_filter_fini(void)
 {
 	nf_unregister_hooks(ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
-	ebt_unregister_table(frame_filter);
+	unregister_pernet_subsys(&frame_filter_net_ops);
 }
 
 module_init(ebtable_filter_init);
-- 
1.5.6.3
