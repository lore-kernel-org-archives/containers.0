From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 22/38][IPV6] rt6_stats - dynamically allocate the rt6_stats
Date: Mon, 03 Dec 2007 17:16:58 +0100
Message-ID: <20071203162509.922662885@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=rt6-stats-dynamic-allocation.patch
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

This patch allocates the rt6_stats struct dynamically when
the fib6 is initialized. That provides the ability to create
several instances of this structure for the network namespaces.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/ipv6/ip6_fib.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

Index: linux-2.6-netns/net/ipv6/ip6_fib.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/ip6_fib.c
+++ linux-2.6-netns/net/ipv6/ip6_fib.c
@@ -48,8 +48,7 @@
 #define RT6_TRACE(x...) do { ; } while (0)
 #endif
 
-static struct rt6_statistics __rt6_stats;
-struct rt6_statistics *rt6_stats = &__rt6_stats;
+struct rt6_statistics *rt6_stats;
 
 static struct kmem_cache * fib6_node_kmem __read_mostly;
 
@@ -1544,6 +1543,10 @@ void __init fib6_init(void)
 					   sizeof(struct fib6_node),
 					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					   NULL);
+
+  	rt6_stats = kzalloc(sizeof(*rt6_stats), GFP_KERNEL);
+  	if (!rt6_stats)
+  		panic("IPV6: failed to allocate rt6_stats.\n");
 
 	register_pernet_subsys(&fib6_net_ops);
         __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
@@ -1552,5 +1555,6 @@ void __init fib6_init(void)
 void fib6_gc_cleanup(void)
 {
 	unregister_pernet_subsys(&fib6_net_ops);
+	kfree(rt6_stats);
 	kmem_cache_destroy(fib6_node_kmem);
 }

-- 
