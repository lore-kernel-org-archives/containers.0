From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 10/17] audit_tree,
	rcu: convert call_rcu(__put_tree) to kfree_rcu()
Date: Tue, 15 Mar 2011 18:03:53 +0800
Message-ID: <4D7F3989.80207@cn.fujitsu.com>
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



The rcu callback __put_tree() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(__put_tree).

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/audit_tree.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/kernel/audit_tree.c b/kernel/audit_tree.c
index 37b2bea..ae216a3 100644
--- a/kernel/audit_tree.c
+++ b/kernel/audit_tree.c
@@ -93,16 +93,10 @@ static inline void get_tree(struct audit_tree *tree)
 	atomic_inc(&tree->count);
 }
 
-static void __put_tree(struct rcu_head *rcu)
-{
-	struct audit_tree *tree = container_of(rcu, struct audit_tree, head);
-	kfree(tree);
-}
-
 static inline void put_tree(struct audit_tree *tree)
 {
 	if (atomic_dec_and_test(&tree->count))
-		call_rcu(&tree->head, __put_tree);
+		kfree_rcu(tree, head);
 }
 
 /* to avoid bringing the entire thing in audit.h */
-- 
1.7.4
