From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 01/17] cgroup,
	rcu: convert call_rcu(free_css_set_rcu) to kfree_rcu()
Date: Tue, 15 Mar 2011 17:53:46 +0800
Message-ID: <4D7F372A.6050407@cn.fujitsu.com>
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


The rcu callback free_css_set_rcu() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(free_css_set_rcu).

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 95362d1..ad485d4 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -326,12 +326,6 @@ static struct hlist_head *css_set_hash(struct cgroup_subsys_state *css[])
 	return &css_set_table[index];
 }
 
-static void free_css_set_rcu(struct rcu_head *obj)
-{
-	struct css_set *cg = container_of(obj, struct css_set, rcu_head);
-	kfree(cg);
-}
-
 /* We don't maintain the lists running through each css_set to its
  * task until after the first call to cgroup_iter_start(). This
  * reduces the fork()/exit() overhead for people who have cgroups
@@ -375,7 +369,7 @@ static void __put_css_set(struct css_set *cg, int taskexit)
 	}
 
 	write_unlock(&css_set_lock);
-	call_rcu(&cg->rcu_head, free_css_set_rcu);
+	kfree_rcu(cg, rcu_head);
 }
 
 /*
-- 
1.7.4
