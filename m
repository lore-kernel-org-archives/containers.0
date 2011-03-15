From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 12/17] block,
	rcu: convert call_rcu(cfq_cfqd_free) to kfree_rcu()
Date: Tue, 15 Mar 2011 18:06:07 +0800
Message-ID: <4D7F3A0F.1050403@cn.fujitsu.com>
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



The rcu callback cfq_cfqd_free() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(cfq_cfqd_free).

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 block/cfq-iosched.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index ea83a4f..32fe43e 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -3812,11 +3812,6 @@ static void cfq_put_async_queues(struct cfq_data *cfqd)
 		cfq_put_queue(cfqd->async_idle_cfqq);
 }
 
-static void cfq_cfqd_free(struct rcu_head *head)
-{
-	kfree(container_of(head, struct cfq_data, rcu));
-}
-
 static void cfq_exit_queue(struct elevator_queue *e)
 {
 	struct cfq_data *cfqd = e->elevator_data;
@@ -3850,7 +3845,7 @@ static void cfq_exit_queue(struct elevator_queue *e)
 	spin_unlock(&cic_index_lock);
 
 	/* Wait for cfqg->blkg->key accessors to exit their grace periods. */
-	call_rcu(&cfqd->rcu, cfq_cfqd_free);
+	kfree_rcu(cfqd, rcu);
 }
 
 static int cfq_alloc_cic_index(void)
-- 
1.7.4
