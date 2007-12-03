From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 16/38][IPV6] ip6_fib - make ip6 fib gc timer mindless changes
Date: Mon, 03 Dec 2007 17:16:52 +0100
Message-ID: <20071203162500.038553774@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=ip6-fib-make-gc-timer-mindless-changes.patch
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

The patch prepares to dynamically allocate the ip6_fib_timer timer.
It changes all reference to the global static variable to a
globally defined pointer to the global static variable.

That makes all the code use a pointer instead of a static variable.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 net/ipv6/ip6_fib.c |   21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

Index: linux-2.6-netns/net/ipv6/ip6_fib.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/ip6_fib.c
+++ linux-2.6-netns/net/ipv6/ip6_fib.c
@@ -95,7 +95,8 @@ static __u32 rt_sernum;
 
 static void fib6_gc_timer_cb(unsigned long arg);
 
-static DEFINE_TIMER(ip6_fib_timer, fib6_gc_timer_cb, 0, (unsigned long)&init_net);
+static DEFINE_TIMER(__ip6_fib_timer, fib6_gc_timer_cb, 0, (unsigned long)&init_net);
+static struct timer_list *ip6_fib_timer = &__ip6_fib_timer;
 
 static struct fib6_walker_t fib6_walker_list = {
 	.prev	= &fib6_walker_list,
@@ -666,15 +667,15 @@ static int fib6_add_rt2node(struct fib6_
 
 static __inline__ void fib6_start_gc(struct rt6_info *rt)
 {
-	if (ip6_fib_timer.expires == 0 &&
+	if (ip6_fib_timer->expires == 0 &&
 	    (rt->rt6i_flags & (RTF_EXPIRES|RTF_CACHE)))
-		mod_timer(&ip6_fib_timer, jiffies + ip6_rt_gc_interval);
+		mod_timer(ip6_fib_timer, jiffies + ip6_rt_gc_interval);
 }
 
 void fib6_force_start_gc(void)
 {
-	if (ip6_fib_timer.expires == 0)
-		mod_timer(&ip6_fib_timer, jiffies + ip6_rt_gc_interval);
+	if (ip6_fib_timer->expires == 0)
+		mod_timer(ip6_fib_timer, jiffies + ip6_rt_gc_interval);
 }
 
 /*
@@ -1446,7 +1447,7 @@ void fib6_run_gc(unsigned long expires, 
 	} else {
 		local_bh_disable();
 		if (!spin_trylock(&fib6_gc_lock)) {
-			mod_timer(&ip6_fib_timer, jiffies + HZ);
+			mod_timer(ip6_fib_timer, jiffies + HZ);
 			local_bh_enable();
 			return;
 		}
@@ -1459,10 +1460,10 @@ void fib6_run_gc(unsigned long expires, 
 	fib6_clean_all(net, fib6_age, 0, NULL);
 
 	if (gc_args.more)
-		mod_timer(&ip6_fib_timer, jiffies + ip6_rt_gc_interval);
+		mod_timer(ip6_fib_timer, jiffies + ip6_rt_gc_interval);
 	else {
-		del_timer(&ip6_fib_timer);
-		ip6_fib_timer.expires = 0;
+		del_timer(ip6_fib_timer);
+		ip6_fib_timer->expires = 0;
 	}
 	spin_unlock_bh(&fib6_gc_lock);
 }
@@ -1538,7 +1539,7 @@ void __init fib6_init(void)
 
 void fib6_gc_cleanup(void)
 {
-	del_timer(&ip6_fib_timer);
+	del_timer(ip6_fib_timer);
 	unregister_pernet_subsys(&fib6_net_ops);
 	kmem_cache_destroy(fib6_node_kmem);
 }

-- 
