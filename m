From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/8 net-2.6.26] [NETNS]: Add netns refcnt debug for timewait buckets.
Date: Tue, 15 Apr 2008 16:37:50 +0400
Message-ID: <1208263075-28016-3-git-send-email-den@openvz.org>
References: <1208262959.21529.32.camel@iris.sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1208262959.21529.32.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, dlezcano@fr.ibm.com, "Denis V. Lunev" <den@openvz.org>
List-Id: containers.vger.kernel.org

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/inet_timewait_sock.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index a741378..ce16e9a 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -57,6 +57,7 @@ void inet_twsk_put(struct inet_timewait_sock *tw)
 		printk(KERN_DEBUG "%s timewait_sock %p released\n",
 		       tw->tw_prot->name, tw);
 #endif
+		release_net(twsk_net(tw));
 		kmem_cache_free(tw->tw_prot->twsk_prot->twsk_slab, tw);
 		module_put(owner);
 	}
@@ -124,7 +125,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_hash	    = sk->sk_hash;
 		tw->tw_ipv6only	    = 0;
 		tw->tw_prot	    = sk->sk_prot_creator;
-		twsk_net_set(tw, sock_net(sk));
+		twsk_net_set(tw, hold_net(sock_net(sk)));
 		atomic_set(&tw->tw_refcnt, 1);
 		inet_twsk_dead_node_init(tw);
 		__module_get(tw->tw_prot->owner);
-- 
1.5.3.rc5

