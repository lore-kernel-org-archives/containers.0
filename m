From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 16/17] net,
	rcu: convert call_rcu(dn_dev_free_ifa_rcu) to kfree_rcu()
Date: Tue, 15 Mar 2011 18:10:12 +0800
Message-ID: <4D7F3B04.9080504@cn.fujitsu.com>
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


The rcu callback dn_dev_free_ifa_rcu() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(dn_dev_free_ifa_rcu).

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/decnet/dn_dev.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 0dcaa90..4c27615 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -332,14 +332,9 @@ static struct dn_ifaddr *dn_dev_alloc_ifa(void)
 	return ifa;
 }
 
-static void dn_dev_free_ifa_rcu(struct rcu_head *head)
-{
-	kfree(container_of(head, struct dn_ifaddr, rcu));
-}
-
 static void dn_dev_free_ifa(struct dn_ifaddr *ifa)
 {
-	call_rcu(&ifa->rcu, dn_dev_free_ifa_rcu);
+	kfree_rcu(ifa, rcu);
 }
 
 static void dn_dev_del_ifa(struct dn_dev *dn_db, struct dn_ifaddr __rcu **ifap, int destroy)
-- 
1.7.4
