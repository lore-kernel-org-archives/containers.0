From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 03/17] cgroup,
	rcu: convert call_rcu(__free_css_id_cb) to kfree_rcu()
Date: Tue, 15 Mar 2011 17:56:10 +0800
Message-ID: <4D7F37BA.5000308@cn.fujitsu.com>
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



The rcu callback __free_css_id_cb() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(__free_css_id_cb).

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5c83c91..b7d3f6d 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4612,14 +4612,6 @@ bool css_is_ancestor(struct cgroup_subsys_state *child,
 	return ret;
 }
 
-static void __free_css_id_cb(struct rcu_head *head)
-{
-	struct css_id *id;
-
-	id = container_of(head, struct css_id, rcu_head);
-	kfree(id);
-}
-
 void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css)
 {
 	struct css_id *id = css->id;
@@ -4634,7 +4626,7 @@ void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css)
 	spin_lock(&ss->id_lock);
 	idr_remove(&ss->idr, id->id);
 	spin_unlock(&ss->id_lock);
-	call_rcu(&id->rcu_head, __free_css_id_cb);
+	kfree_rcu(id, rcu_head);
 }
 EXPORT_SYMBOL_GPL(free_css_id);
 
-- 
1.7.4
