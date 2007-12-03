From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 29/38][IPV6] route6 - Pass the network namespace parameter
	to rt6_purge_dflt_routers
Date: Mon, 03 Dec 2007 17:17:05 +0100
Message-ID: <20071203162521.225432949@mai.toulouse-stg.fr.ibm.com>
References: <20071203161636.308694257@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline;
	filename=route6-pass-network-namespace-to-rt6_purge_dflt_routers.patch
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

Add a network namespace parameter to rt6_purge_dflt_routers.
This is needed to call fib6_get_table with the appropriate 
network namespace.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
---
 include/net/ip6_route.h |    2 +-
 net/ipv6/addrconf.c     |    4 ++--
 net/ipv6/route.c        |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

Index: linux-2.6-netns/include/net/ip6_route.h
===================================================================
--- linux-2.6-netns.orig/include/net/ip6_route.h
+++ linux-2.6-netns/include/net/ip6_route.h
@@ -99,7 +99,7 @@ extern struct rt6_info *	rt6_add_dflt_ro
 						    struct net_device *dev,
 						    unsigned int pref);
 
-extern void			rt6_purge_dflt_routers(void);
+extern void			rt6_purge_dflt_routers(struct net *net);
 
 extern int			rt6_route_rcv(struct net_device *dev,
 					      u8 *opt, int len,
Index: linux-2.6-netns/net/ipv6/addrconf.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/addrconf.c
+++ linux-2.6-netns/net/ipv6/addrconf.c
@@ -3797,7 +3797,7 @@ int addrconf_sysctl_forward(ctl_table *c
 			addrconf_forward_change();
 		}
 		if (*valp)
-			rt6_purge_dflt_routers();
+			rt6_purge_dflt_routers(&init_net);
 	}
 
 	return ret;
@@ -3850,7 +3850,7 @@ static int addrconf_sysctl_forward_strat
 		}
 
 		if (*valp)
-			rt6_purge_dflt_routers();
+			rt6_purge_dflt_routers(&init_net);
 	} else
 		*valp = new;
 
Index: linux-2.6-netns/net/ipv6/route.c
===================================================================
--- linux-2.6-netns.orig/net/ipv6/route.c
+++ linux-2.6-netns/net/ipv6/route.c
@@ -1699,13 +1699,13 @@ struct rt6_info *rt6_add_dflt_router(str
 	return rt6_get_dflt_router(gwaddr, dev);
 }
 
-void rt6_purge_dflt_routers(void)
+void rt6_purge_dflt_routers(struct net *net)
 {
 	struct rt6_info *rt;
 	struct fib6_table *table;
 
 	/* NOTE: Keep consistent with rt6_get_dflt_router */
-	table = fib6_get_table(&init_net, RT6_TABLE_DFLT);
+	table = fib6_get_table(net, RT6_TABLE_DFLT);
 	if (table == NULL)
 		return;
 

-- 
