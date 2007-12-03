From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 25/38][IPV6] route6 - create route6 proc files for the
	namespace
Date: Mon, 03 Dec 2007 17:17:01 +0100
Message-ID: <20071203162514.241112882@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=route6-procfs.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: den-3ImXcnM4P+0@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Make /proc/net/ipv6_route and /proc/net/rt6_stats to be per namespace.
These proc files are now created when the network namespace is initialized.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/ipv6/route.c |   27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

Index: linux-2.6-netns/net/ipv6/route.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/route.c
+++ linux-2.6-netns/net/ipv6/route.c
@@ -2486,6 +2486,24 @@ ctl_table ipv6_route_table[] = {
 
 #endif
 
+static int ip6_route_net_init(struct net *net)
+{
+	proc_net_fops_create(net, "ipv6_route", 0, &ipv6_route_proc_fops);
+	proc_net_fops_create(net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
+	return 0;
+}
+
+static void ip6_route_net_exit(struct net *net)
+{
+	proc_net_remove(net, "ipv6_route");
+	proc_net_remove(net, "rt6_stats");
+}
+
+static struct pernet_operations ip6_route_net_ops = {
+	.init = ip6_route_net_init,
+	.exit = ip6_route_net_exit,
+};
+
 void __init ip6_route_init(void)
 {
 	ip6_dst_ops.kmem_cachep =
@@ -2493,9 +2511,8 @@ void __init ip6_route_init(void)
 				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
 	ip6_dst_blackhole_ops.kmem_cachep = ip6_dst_ops.kmem_cachep;
 
+	register_pernet_subsys(&ip6_route_net_ops);
 	fib6_init();
-	proc_net_fops_create(&init_net, "ipv6_route", 0, &ipv6_route_proc_fops);
-	proc_net_fops_create(&init_net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
 #ifdef CONFIG_XFRM
 	xfrm6_init();
 #endif
@@ -2510,13 +2527,11 @@ void __init ip6_route_init(void)
 
 void ip6_route_cleanup(void)
 {
+	unregister_pernet_subsys(&ip6_route_net_ops);
+
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	fib6_rules_cleanup();
 #endif
-#ifdef CONFIG_PROC_FS
-	proc_net_remove(&init_net, "ipv6_route");
-	proc_net_remove(&init_net, "rt6_stats");
-#endif
 #ifdef CONFIG_XFRM
 	xfrm6_fini();
 #endif

-- 
