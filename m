From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 21/38][IPV6] rt6_stats - make mindless changes for rt6_stats
Date: Mon, 03 Dec 2007 17:16:57 +0100
Message-ID: <20071203162508.595238186@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=rt6-stats-dynamic-make-mindless-changes.patch
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

Change the global reference to the rt6_stats variable to 
a pointer. These are the mindless changes to bring dynamic
allocation to the rt6_stats structure.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 include/net/ipv6.h |    2 +-
 net/ipv6/ip6_fib.c |   13 +++++++------
 net/ipv6/route.c   |    8 ++++----
 3 files changed, 12 insertions(+), 11 deletions(-)

Index: linux-2.6-netns/include/net/ipv6.h
===================================================================
--- linux-2.6-netns.orig/include/net/ipv6.h
+++ linux-2.6-netns/include/net/ipv6.h
@@ -620,7 +620,7 @@ extern void ipv6_misc_proc_exit(void);
 extern int snmp6_register_dev(struct inet6_dev *idev);
 extern int snmp6_unregister_dev(struct inet6_dev *idev);
 
-extern struct rt6_statistics rt6_stats;
+extern struct rt6_statistics *rt6_stats;
 #else
 static inline int snmp6_register_dev(struct inet6_dev *idev)
 {
Index: linux-2.6-netns/net/ipv6/ip6_fib.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/ip6_fib.c
+++ linux-2.6-netns/net/ipv6/ip6_fib.c
@@ -48,7 +48,8 @@
 #define RT6_TRACE(x...) do { ; } while (0)
 #endif
 
-struct rt6_statistics	rt6_stats;
+static struct rt6_statistics __rt6_stats;
+struct rt6_statistics *rt6_stats = &__rt6_stats;
 
 static struct kmem_cache * fib6_node_kmem __read_mostly;
 
@@ -650,10 +651,10 @@ static int fib6_add_rt2node(struct fib6_
 	rt->rt6i_node = fn;
 	atomic_inc(&rt->rt6i_ref);
 	inet6_rt_notify(RTM_NEWROUTE, rt, info);
-	rt6_stats.fib_rt_entries++;
+	rt6_stats->fib_rt_entries++;
 
 	if ((fn->fn_flags & RTN_RTINFO) == 0) {
-		rt6_stats.fib_route_nodes++;
+		rt6_stats->fib_route_nodes++;
 		fn->fn_flags |= RTN_RTINFO;
 	}
 
@@ -1088,8 +1089,8 @@ static void fib6_del_route(struct fib6_n
 	/* Unlink it */
 	*rtp = rt->u.dst.rt6_next;
 	rt->rt6i_node = NULL;
-	rt6_stats.fib_rt_entries--;
-	rt6_stats.fib_discarded_routes++;
+	rt6_stats->fib_rt_entries--;
+	rt6_stats->fib_discarded_routes++;
 
 	/* Reset round-robin state, if necessary */
 	if (fn->rr_ptr == rt)
@@ -1115,7 +1116,7 @@ static void fib6_del_route(struct fib6_n
 	/* If it was last route, expunge its radix tree node */
 	if (fn->leaf == NULL) {
 		fn->fn_flags &= ~RTN_RTINFO;
-		rt6_stats.fib_route_nodes--;
+		rt6_stats->fib_route_nodes--;
 		fn = fib6_repair_tree(fn);
 	}
 
Index: linux-2.6-netns/net/ipv6/route.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/route.c
+++ linux-2.6-netns/net/ipv6/route.c
@@ -2350,11 +2350,11 @@ static const struct file_operations ipv6
 static int rt6_stats_seq_show(struct seq_file *seq, void *v)
 {
 	seq_printf(seq, "%04x %04x %04x %04x %04x %04x %04x\n",
-		      rt6_stats.fib_nodes, rt6_stats.fib_route_nodes,
-		      rt6_stats.fib_rt_alloc, rt6_stats.fib_rt_entries,
-		      rt6_stats.fib_rt_cache,
+		      rt6_stats->fib_nodes, rt6_stats->fib_route_nodes,
+		      rt6_stats->fib_rt_alloc, rt6_stats->fib_rt_entries,
+		      rt6_stats->fib_rt_cache,
 		      atomic_read(&ip6_dst_ops.entries),
-		      rt6_stats.fib_discarded_routes);
+		      rt6_stats->fib_discarded_routes);
 
 	return 0;
 }

-- 
