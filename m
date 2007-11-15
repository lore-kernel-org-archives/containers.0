From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 10/10][NETNS][IP6_FIB] make gc timer handle several network
	namespace
Date: Thu, 15 Nov 2007 15:01:53 +0100
Message-ID: <20071115140626.262024924@mai.toulouse-stg.fr.ibm.com>
References: <20071115140143.597214582@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=ip6-fib-gc-timer-per-namespace.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Move the timer initialization at the network namespace creation
and store the namespace in the timer argument.

That enables multiple timer per network namespace to do garbage
collecting.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/ipv6/ip6_fib.c |   33 +++++++++++++++++----------------
 1 file changed, 17 insertions(+), 16 deletions(-)

Index: linux-2.6-netns/net/ipv6/ip6_fib.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/ip6_fib.c
+++ linux-2.6-netns/net/ipv6/ip6_fib.c
@@ -1466,12 +1466,23 @@ static void fib6_gc_timer_cb(unsigned lo
 static int fib6_net_init(struct net *net)
 {
 	int ret;
+	struct timer_list *timer;
 
 	ret = -ENOMEM;
+ 	timer = kzalloc(sizeof(*timer), GFP_KERNEL);
+ 	if (!timer)
+		goto out;
+
+	timer->function = fib6_gc_timer_cb;
+	timer->expires = 0;
+	timer->data = (unsigned long)net;
+	timer->base = &boot_tvec_bases;
+ 	net->ip6_fib_timer = timer;
+
 	net->fib_table_hash = kzalloc(sizeof(*net->fib_table_hash)*FIB_TABLE_HASHSZ,
 				      GFP_KERNEL);
 	if (!net->fib_table_hash)
-		goto out;
+		goto out_timer;
 
 	net->fib6_main_tbl = kzalloc(sizeof(*net->fib6_main_tbl), GFP_KERNEL);
 	if (!net->fib6_main_tbl)
@@ -1498,12 +1509,17 @@ static int fib6_net_init(struct net *net
 
 out_fib6_main_tbl:
 	kfree(net->fib_table_hash);
+out_timer:
+	kfree(timer);
 out:
 	return ret;
  }
 
 static void fib6_net_exit(struct net *net)
 {
+	del_timer(net->ip6_fib_timer);
+	kfree(net->ip6_fib_timer);
+
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	kfree(net->fib6_local_tbl);
 #endif
@@ -1518,31 +1534,16 @@ static struct pernet_operations fib6_net
 
 void __init fib6_init(void)
 {
- 	struct timer_list *timer;
-
 	fib6_node_kmem = kmem_cache_create("fib6_nodes",
 					   sizeof(struct fib6_node),
 					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					   NULL);
-
-	timer = kzalloc(sizeof(*timer), GFP_KERNEL);
-	if (!timer)
-		panic("IPV6: failed to allocate the gc timer\n");
-
-	timer->function = fib6_gc_timer_cb;
-	timer->expires = 0;
-	timer->data = (unsigned long)&init_net;
-	timer->base = &boot_tvec_bases;
-	init_net.ip6_fib_timer = timer;
-
 	register_pernet_subsys(&fib6_net_ops);
         __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
 }
 
 void fib6_gc_cleanup(void)
 {
-	del_timer(timer);
-	kfree(timer);
 	unregister_pernet_subsys(&fib6_net_ops);
 	kmem_cache_destroy(fib6_node_kmem);
 }

-- 
