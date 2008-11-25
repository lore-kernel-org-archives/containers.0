From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 01/53] xfrm: initialise xfrm_policy_gc_work statically
Date: Tue, 25 Nov 2008 20:26:33 +0300
Message-ID: <1227634045-27534-1-git-send-email-adobriyan__45270.5356329263$1227634157$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Cc: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/xfrm/xfrm_policy.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 1785488..ea3456d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -55,7 +55,6 @@ static struct xfrm_policy_afinfo *xfrm_policy_afinfo[NPROTO];
 
 static struct kmem_cache *xfrm_dst_cache __read_mostly;
 
-static struct work_struct xfrm_policy_gc_work;
 static HLIST_HEAD(xfrm_policy_gc_list);
 static DEFINE_SPINLOCK(xfrm_policy_gc_lock);
 
@@ -296,6 +295,7 @@ static void xfrm_policy_gc_task(struct work_struct *work)
 	hlist_for_each_entry_safe(policy, entry, tmp, &gc_list, bydst)
 		xfrm_policy_gc_kill(policy);
 }
+static DECLARE_WORK(xfrm_policy_gc_work, xfrm_policy_gc_task);
 
 /* Rule must be locked. Release descentant resources, announce
  * entry dead. The rule must be unlinked from lists to the moment.
@@ -2425,7 +2425,6 @@ static void __init xfrm_policy_init(void)
 	}
 
 	INIT_LIST_HEAD(&xfrm_policy_all);
-	INIT_WORK(&xfrm_policy_gc_work, xfrm_policy_gc_task);
 	register_netdevice_notifier(&xfrm_dev_notifier);
 }
 
-- 
1.5.6.5
