From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 17/38][IPV6] ip6_fib - dynamically allocate the ip6 fib gc
	timer
Date: Mon, 03 Dec 2007 17:16:53 +0100
Message-ID: <20071203162501.421105019@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=ip6-fib-dynamically-allocate-gc-timer.patch
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

The ip6_fib_timer gc timer is dynamically allocated and initialized in
the ip6 fib init function. There are no more references to a
static global variable.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/ipv6/ip6_fib.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

Index: linux-2.6-netns/net/ipv6/ip6_fib.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/ip6_fib.c
+++ linux-2.6-netns/net/ipv6/ip6_fib.c
@@ -93,10 +93,7 @@ static int fib6_walk_continue(struct fib
 
 static __u32 rt_sernum;
 
-static void fib6_gc_timer_cb(unsigned long arg);
-
-static DEFINE_TIMER(__ip6_fib_timer, fib6_gc_timer_cb, 0, (unsigned long)&init_net);
-static struct timer_list *ip6_fib_timer = &__ip6_fib_timer;
+static struct timer_list *ip6_fib_timer;
 
 static struct fib6_walker_t fib6_walker_list = {
 	.prev	= &fib6_walker_list,
@@ -1533,6 +1530,15 @@ void __init fib6_init(void)
 					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					   NULL);
 
+	ip6_fib_timer = kzalloc(sizeof(*ip6_fib_timer), GFP_KERNEL);
+	if (!ip6_fib_timer)
+		panic("IPV6: failed to allocate the gc timer\n");
+
+	ip6_fib_timer->function = fib6_gc_timer_cb;
+	ip6_fib_timer->expires = 0;
+	ip6_fib_timer->data = (unsigned long)&init_net;
+	ip6_fib_timer->base = &boot_tvec_bases;
+
 	register_pernet_subsys(&fib6_net_ops);
         __rtnl_register(PF_INET6, RTM_GETROUTE, NULL, inet6_dump_fib);
 }
@@ -1540,6 +1546,7 @@ void __init fib6_init(void)
 void fib6_gc_cleanup(void)
 {
 	del_timer(ip6_fib_timer);
+	kfree(ip6_fib_timer);
 	unregister_pernet_subsys(&fib6_net_ops);
 	kmem_cache_destroy(fib6_node_kmem);
 }

-- 
