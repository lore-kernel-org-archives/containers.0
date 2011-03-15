From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 07/17] net, rcu: convert call_rcu(inet6_ifa_finish_destroy_rcu)
	to kfree_rcu()
Date: Tue, 15 Mar 2011 18:00:14 +0800
Message-ID: <4D7F38AE.7060708@cn.fujitsu.com>
References: <4D7F3610.6000809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4D7F3610.6000809-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org



The rcu callback inet6_ifa_finish_destroy_rcu() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(inet6_ifa_finish_destroy_rcu).

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/ipv6/addrconf.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f8c1a4c..14ab6e8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -529,12 +529,6 @@ static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int old)
 }
 #endif
 
-static void inet6_ifa_finish_destroy_rcu(struct rcu_head *head)
-{
-	struct inet6_ifaddr *ifp = container_of(head, struct inet6_ifaddr, rcu);
-	kfree(ifp);
-}
-
 /* Nobody refers to this ifaddr, destroy it */
 void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 {
@@ -555,7 +549,7 @@ void inet6_ifa_finish_destroy(struct inet6_ifaddr *ifp)
 	}
 	dst_release(&ifp->rt->dst);
 
-	call_rcu(&ifp->rcu, inet6_ifa_finish_destroy_rcu);
+	kfree_rcu(ifp, rcu);
 }
 
 static void
-- 
1.7.4
