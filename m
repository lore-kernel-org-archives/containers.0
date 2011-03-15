From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 15/17] net,rcu: convert call_rcu(ha_rcu_free) to kfree_rcu()
Date: Tue, 15 Mar 2011 18:08:58 +0800
Message-ID: <4D7F3ABA.7020709@cn.fujitsu.com>
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



The rcu callback ha_rcu_free() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(ha_rcu_free).

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/core/dev_addr_lists.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 133fd22..4062355 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -68,14 +68,6 @@ static int __hw_addr_add(struct netdev_hw_addr_list *list, unsigned char *addr,
 	return __hw_addr_add_ex(list, addr, addr_len, addr_type, false);
 }
 
-static void ha_rcu_free(struct rcu_head *head)
-{
-	struct netdev_hw_addr *ha;
-
-	ha = container_of(head, struct netdev_hw_addr, rcu_head);
-	kfree(ha);
-}
-
 static int __hw_addr_del_ex(struct netdev_hw_addr_list *list,
 			    unsigned char *addr, int addr_len,
 			    unsigned char addr_type, bool global)
@@ -94,7 +86,7 @@ static int __hw_addr_del_ex(struct netdev_hw_addr_list *list,
 			if (--ha->refcount)
 				return 0;
 			list_del_rcu(&ha->list);
-			call_rcu(&ha->rcu_head, ha_rcu_free);
+			kfree_rcu(ha, rcu_head);
 			list->count--;
 			return 0;
 		}
@@ -197,7 +189,7 @@ void __hw_addr_flush(struct netdev_hw_addr_list *list)
 
 	list_for_each_entry_safe(ha, tmp, &list->list, list) {
 		list_del_rcu(&ha->list);
-		call_rcu(&ha->rcu_head, ha_rcu_free);
+		kfree_rcu(ha, rcu_head);
 	}
 	list->count = 0;
 }
-- 
1.7.4
