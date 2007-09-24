From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: [patch 1/3][netns] add a reference to the netns for timewait
Date: Mon, 24 Sep 2007 15:29:36 +0200
Message-ID: <20070924133312.176652115@mai.toulouse-stg.fr.ibm.com>
References: <20070924132935.398625515@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=net-fix-timewait-reference.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

When a socket changes to a timewait socket, the network namespace
is not copied from the original socket.

Here we hold a usage reference, not the ref count on the network
namespace, so the network namespace will be freed either the usage
reference is not 0. The network namespace cleanup function will 
fail if there is any usage of it. In this case, we should ensure
there is no usage of the network namespace.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 include/net/inet_timewait_sock.h |    2 ++
 net/ipv4/inet_timewait_sock.c    |    1 +
 2 files changed, 3 insertions(+)

Index: linux-2.6-netns/include/net/inet_timewait_sock.h
===================================================================
--- linux-2.6-netns.orig/include/net/inet_timewait_sock.h
+++ linux-2.6-netns/include/net/inet_timewait_sock.h
@@ -197,12 +197,14 @@ static inline void inet_twsk_put(struct 
 {
 	if (atomic_dec_and_test(&tw->tw_refcnt)) {
 		struct module *owner = tw->tw_prot->owner;
+		struct net *net = tw->tw_net;
 		twsk_destructor((struct sock *)tw);
 #ifdef SOCK_REFCNT_DEBUG
 		printk(KERN_DEBUG "%s timewait_sock %p released\n",
 		       tw->tw_prot->name, tw);
 #endif
 		kmem_cache_free(tw->tw_prot->twsk_prot->twsk_slab, tw);
+		release_net(net);
 		module_put(owner);
 	}
 }
Index: linux-2.6-netns/net/ipv4/inet_timewait_sock.c
===================================================================
--- linux-2.6-netns.orig/net/ipv4/inet_timewait_sock.c
+++ linux-2.6-netns/net/ipv4/inet_timewait_sock.c
@@ -108,6 +108,7 @@ struct inet_timewait_sock *inet_twsk_all
 		tw->tw_hash	    = sk->sk_hash;
 		tw->tw_ipv6only	    = 0;
 		tw->tw_prot	    = sk->sk_prot_creator;
+		tw->tw_net          = hold_net(sk->sk_net);
 		atomic_set(&tw->tw_refcnt, 1);
 		inet_twsk_dead_node_init(tw);
 		__module_get(tw->tw_prot->owner);

-- 
