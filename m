From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 13/17] nfs, rcu: convert call_rcu(nfs_free_delegation_callback)
	to kfree_rcu()
Date: Tue, 15 Mar 2011 18:07:01 +0800
Message-ID: <4D7F3A45.8060601@cn.fujitsu.com>
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



The rcu callback nfs_free_delegation_callback() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(nfs_free_delegation_callback).

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 fs/nfs/delegation.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index bbbc6bf..dd25c2a 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -21,25 +21,13 @@
 #include "delegation.h"
 #include "internal.h"
 
-static void nfs_do_free_delegation(struct nfs_delegation *delegation)
-{
-	kfree(delegation);
-}
-
-static void nfs_free_delegation_callback(struct rcu_head *head)
-{
-	struct nfs_delegation *delegation = container_of(head, struct nfs_delegation, rcu);
-
-	nfs_do_free_delegation(delegation);
-}
-
 static void nfs_free_delegation(struct nfs_delegation *delegation)
 {
 	if (delegation->cred) {
 		put_rpccred(delegation->cred);
 		delegation->cred = NULL;
 	}
-	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
+	kfree_rcu(delegation, rcu);
 }
 
 /**
-- 
1.7.4
