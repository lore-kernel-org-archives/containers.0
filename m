From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 05/17] net,
	rcu: convert call_rcu(tcf_police_free_rcu) to kfree_rcu()
Date: Tue, 15 Mar 2011 17:58:00 +0800
Message-ID: <4D7F3828.4040403@cn.fujitsu.com>
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

[PATCH 05/17] net,rcu: convert call_rcu(tcf_police_free_rcu) to kfree_rcu()

The rcu callback tcf_police_free_rcu() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(tcf_police_free_rcu).

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/sched/act_police.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/sched/act_police.c b/net/sched/act_police.c
index e2f08b1..083b091 100644
--- a/net/sched/act_police.c
+++ b/net/sched/act_police.c
@@ -97,11 +97,6 @@ nla_put_failure:
 	goto done;
 }
 
-static void tcf_police_free_rcu(struct rcu_head *head)
-{
-	kfree(container_of(head, struct tcf_police, tcf_rcu));
-}
-
 static void tcf_police_destroy(struct tcf_police *p)
 {
 	unsigned int h = tcf_hash(p->tcf_index, POL_TAB_MASK);
@@ -122,7 +117,7 @@ static void tcf_police_destroy(struct tcf_police *p)
 			 * gen_estimator est_timer() might access p->tcf_lock
 			 * or bstats, wait a RCU grace period before freeing p
 			 */
-			call_rcu(&p->tcf_rcu, tcf_police_free_rcu);
+			kfree_rcu(p, tcf_rcu);
 			return;
 		}
 	}
-- 
1.7.4
