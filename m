From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 3/6] netns ct: per-netns
	net.netfilter.nf_conntrack_count sysctl
Date: Sat, 13 Sep 2008 14:51:05 +0400
Message-ID: <20080913105105.GD7440__346.298822160129$1221303087$gmane$org@x200.localdomain>
References: <48C01046.2070704@trash.net>
	<1220842990-30500-17-git-send-email-adobriyan@gmail.com>
	<48C623CA.9060803@trash.net>
	<20080909073245.GA7307@x200.localdomain>
	<48C62B1C.7070104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <48C62B1C.7070104-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Note, sysctl table is always duplicated, this is simpler and less
special-cased.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/net/netns/conntrack.h           |    4 +
 net/netfilter/nf_conntrack_standalone.c |   73 +++++++++++++++++---------------
 2 files changed, 45 insertions(+), 32 deletions(-)

--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -4,6 +4,7 @@
 #include <linux/list.h>
 #include <asm/atomic.h>
 
+struct ctl_table_header;
 struct nf_conntrack_ecache;
 
 struct netns_ct {
@@ -16,6 +17,9 @@ struct netns_ct {
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
 	struct nf_conntrack_ecache *ecache;
 #endif
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_header	*sysctl_header;
+#endif
 	int			hash_vmalloc;
 	int			expect_vmalloc;
 };
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -330,7 +330,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_checksum);
 static int log_invalid_proto_min = 0;
 static int log_invalid_proto_max = 255;
 
-static struct ctl_table_header *nf_ct_sysctl_header;
 static struct ctl_table_header *nf_ct_netfilter_header;
 
 static ctl_table nf_ct_sysctl_table[] = {
@@ -409,40 +408,58 @@ static struct ctl_path nf_ct_path[] = {
 
 EXPORT_SYMBOL_GPL(nf_ct_log_invalid);
 
-static int nf_conntrack_standalone_init_sysctl(void)
+static int nf_conntrack_standalone_init_sysctl(struct net *net)
 {
-	nf_ct_netfilter_header =
-		register_sysctl_paths(nf_ct_path, nf_ct_netfilter_table);
-	if (!nf_ct_netfilter_header)
-		goto out;
-
-	nf_ct_sysctl_header =
-		 register_sysctl_paths(nf_net_netfilter_sysctl_path,
-					nf_ct_sysctl_table);
-	if (!nf_ct_sysctl_header)
+	struct ctl_table *table;
+
+	if (net_eq(net, &init_net)) {
+		nf_ct_netfilter_header =
+		       register_sysctl_paths(nf_ct_path, nf_ct_netfilter_table);
+		if (!nf_ct_netfilter_header)
+			goto out;
+	}
+
+	table = kmemdup(nf_ct_sysctl_table, sizeof(nf_ct_sysctl_table),
+			GFP_KERNEL);
+	if (!table)
+		goto out_kmemdup;
+
+	table[1].data = &net->ct.count;
+
+	net->ct.sysctl_header = register_net_sysctl_table(net,
+					nf_net_netfilter_sysctl_path, table);
+	if (!net->ct.sysctl_header)
 		goto out_unregister_netfilter;
 
 	return 0;
 
 out_unregister_netfilter:
-	unregister_sysctl_table(nf_ct_netfilter_header);
+	kfree(table);
+out_kmemdup:
+	if (net_eq(net, &init_net))
+		unregister_sysctl_table(nf_ct_netfilter_header);
 out:
 	printk("nf_conntrack: can't register to sysctl.\n");
 	return -ENOMEM;
 }
 
-static void nf_conntrack_standalone_fini_sysctl(void)
+static void nf_conntrack_standalone_fini_sysctl(struct net *net)
 {
-	unregister_sysctl_table(nf_ct_netfilter_header);
-	unregister_sysctl_table(nf_ct_sysctl_header);
+	struct ctl_table *table;
+
+	if (net_eq(net, &init_net))
+		unregister_sysctl_table(nf_ct_netfilter_header);
+	table = net->ct.sysctl_header->ctl_table_arg;
+	unregister_net_sysctl_table(net->ct.sysctl_header);
+	kfree(table);
 }
 #else
-static int nf_conntrack_standalone_init_sysctl(void)
+static int nf_conntrack_standalone_init_sysctl(struct net *net)
 {
 	return 0;
 }
 
-static void nf_conntrack_standalone_fini_sysctl(void)
+static void nf_conntrack_standalone_fini_sysctl(struct net *net)
 {
 }
 #endif /* CONFIG_SYSCTL */
@@ -457,8 +474,13 @@ static int nf_conntrack_net_init(struct net *net)
 	ret = nf_conntrack_standalone_init_proc(net);
 	if (ret < 0)
 		goto out_proc;
+	ret = nf_conntrack_standalone_init_sysctl(net);
+	if (ret < 0)
+		goto out_sysctl;
 	return 0;
 
+out_sysctl:
+	nf_conntrack_standalone_fini_proc(net);
 out_proc:
 	nf_conntrack_cleanup(net);
 out_init:
@@ -467,6 +489,7 @@ out_init:
 
 static void nf_conntrack_net_exit(struct net *net)
 {
+	nf_conntrack_standalone_fini_sysctl(net);
 	nf_conntrack_standalone_fini_proc(net);
 	nf_conntrack_cleanup(net);
 }
@@ -478,25 +501,11 @@ static struct pernet_operations nf_conntrack_net_ops = {
 
 static int __init nf_conntrack_standalone_init(void)
 {
-	int ret;
-
-	ret = register_pernet_subsys(&nf_conntrack_net_ops);
-	if (ret < 0)
-		goto out;
-	ret = nf_conntrack_standalone_init_sysctl();
-	if (ret < 0)
-		goto out_sysctl;
-	return 0;
-
-out_sysctl:
-	unregister_pernet_subsys(&nf_conntrack_net_ops);
-out:
-	return ret;
+	return register_pernet_subsys(&nf_conntrack_net_ops);
 }
 
 static void __exit nf_conntrack_standalone_fini(void)
 {
-	nf_conntrack_standalone_fini_sysctl();
 	unregister_pernet_subsys(&nf_conntrack_net_ops);
 }
