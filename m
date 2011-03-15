From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 14/17] security,rcu: convert call_rcu(whitelist_item_free)
	to kfree_rcu()
Date: Tue, 15 Mar 2011 18:07:57 +0800
Message-ID: <4D7F3A7D.2080503@cn.fujitsu.com>
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



The rcu callback whitelist_item_free() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(whitelist_item_free).

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 security/device_cgroup.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 8d9c48f..e886ab5 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -126,14 +126,6 @@ static int dev_whitelist_add(struct dev_cgroup *dev_cgroup,
 	return 0;
 }
 
-static void whitelist_item_free(struct rcu_head *rcu)
-{
-	struct dev_whitelist_item *item;
-
-	item = container_of(rcu, struct dev_whitelist_item, rcu);
-	kfree(item);
-}
-
 /*
  * called under devcgroup_mutex
  */
@@ -156,7 +148,7 @@ remove:
 		walk->access &= ~wh->access;
 		if (!walk->access) {
 			list_del_rcu(&walk->list);
-			call_rcu(&walk->rcu, whitelist_item_free);
+			kfree_rcu(walk, rcu);
 		}
 	}
 }
-- 
1.7.4
