From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 09/17] net,rcu: convert call_rcu(kfree_tid_tx) to kfree_rcu()
Date: Tue, 15 Mar 2011 18:02:42 +0800
Message-ID: <4D7F3942.3080703@cn.fujitsu.com>
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



The rcu callback kfree_tid_tx() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(kfree_tid_tx).

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/mac80211/agg-tx.c |   14 +++-----------
 1 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index 9cc472c..7f25f20 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -136,14 +136,6 @@ void ieee80211_send_bar(struct ieee80211_sub_if_data *sdata, u8 *ra, u16 tid, u1
 	ieee80211_tx_skb(sdata, skb);
 }
 
-static void kfree_tid_tx(struct rcu_head *rcu_head)
-{
-	struct tid_ampdu_tx *tid_tx =
-	    container_of(rcu_head, struct tid_ampdu_tx, rcu_head);
-
-	kfree(tid_tx);
-}
-
 int ___ieee80211_stop_tx_ba_session(struct sta_info *sta, u16 tid,
 				    enum ieee80211_back_parties initiator,
 				    bool tx)
@@ -163,7 +155,7 @@ int ___ieee80211_stop_tx_ba_session(struct sta_info *sta, u16 tid,
 		/* not even started yet! */
 		rcu_assign_pointer(sta->ampdu_mlme.tid_tx[tid], NULL);
 		spin_unlock_bh(&sta->lock);
-		call_rcu(&tid_tx->rcu_head, kfree_tid_tx);
+		kfree_rcu(tid_tx, rcu_head);
 		return 0;
 	}
 
@@ -322,7 +314,7 @@ void ieee80211_tx_ba_session_handle_start(struct sta_info *sta, int tid)
 		spin_unlock_bh(&sta->lock);
 
 		ieee80211_wake_queue_agg(local, tid);
-		call_rcu(&tid_tx->rcu_head, kfree_tid_tx);
+		kfree_rcu(tid_tx, rcu_head);
 		return;
 	}
 
@@ -699,7 +691,7 @@ void ieee80211_stop_tx_ba_cb(struct ieee80211_vif *vif, u8 *ra, u8 tid)
 
 	ieee80211_agg_splice_finish(local, tid);
 
-	call_rcu(&tid_tx->rcu_head, kfree_tid_tx);
+	kfree_rcu(tid_tx, rcu_head);
 
  unlock_sta:
 	spin_unlock_bh(&sta->lock);
-- 
1.7.4
