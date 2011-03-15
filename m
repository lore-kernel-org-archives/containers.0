From: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [PATCH 11/17] net,rcu: convert call_rcu(sctp_local_addr_free) to
	kfree_rcu()
Date: Tue, 15 Mar 2011 18:05:02 +0800
Message-ID: <4D7F39CE.80403@cn.fujitsu.com>
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



The rcu callback sctp_local_addr_free() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(sctp_local_addr_free).

Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 include/net/sctp/sctp.h |    1 -
 net/sctp/bind_addr.c    |    2 +-
 net/sctp/ipv6.c         |    2 +-
 net/sctp/protocol.c     |    9 +--------
 4 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 505845d..01e094c 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -115,7 +115,6 @@
  * sctp/protocol.c
  */
 extern struct sock *sctp_get_ctl_sock(void);
-extern void sctp_local_addr_free(struct rcu_head *head);
 extern int sctp_copy_local_addr_list(struct sctp_bind_addr *,
 				     sctp_scope_t, gfp_t gfp,
 				     int flags);
diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
index faf71d1..3c06c87 100644
--- a/net/sctp/bind_addr.c
+++ b/net/sctp/bind_addr.c
@@ -219,7 +219,7 @@ int sctp_del_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *del_addr)
 	}
 
 	if (found) {
-		call_rcu(&addr->rcu, sctp_local_addr_free);
+		kfree_rcu(addr, rcu);
 		SCTP_DBG_OBJCNT_DEC(addr);
 		return 0;
 	}
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 95e0c8e..1960234 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -123,7 +123,7 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
 		}
 		spin_unlock_bh(&sctp_local_addr_lock);
 		if (found)
-			call_rcu(&addr->rcu, sctp_local_addr_free);
+			kfree_rcu(addr, rcu);
 		break;
 	}
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index e58f947..26c7697 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -230,13 +230,6 @@ static void sctp_free_local_addr_list(void)
 	}
 }
 
-void sctp_local_addr_free(struct rcu_head *head)
-{
-	struct sctp_sockaddr_entry *e = container_of(head,
-				struct sctp_sockaddr_entry, rcu);
-	kfree(e);
-}
-
 /* Copy the local addresses which are valid for 'scope' into 'bp'.  */
 int sctp_copy_local_addr_list(struct sctp_bind_addr *bp, sctp_scope_t scope,
 			      gfp_t gfp, int copy_flags)
@@ -680,7 +673,7 @@ static int sctp_inetaddr_event(struct notifier_block *this, unsigned long ev,
 		}
 		spin_unlock_bh(&sctp_local_addr_lock);
 		if (found)
-			call_rcu(&addr->rcu, sctp_local_addr_free);
+			kfree_rcu(addr, rcu);
 		break;
 	}
 
-- 
1.7.4
