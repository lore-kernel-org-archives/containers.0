From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 16/53] netns xfrm: per-netns xfrm_policy_byidx hash
Date: Tue, 25 Nov 2008 20:26:48 +0300
Message-ID: <1227634045-27534-16-git-send-email-adobriyan__25517.2755140395$1227634552$gmane$org@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-2-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-3-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-4-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-5-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-6-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-7-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-8-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-9-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-10-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-11-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-12-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-13-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-14-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-15-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227634045-27534-15-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
 include/net/netns/xfrm.h |    1 +
 net/xfrm/xfrm_policy.c   |   28 ++++++++++++++++++----------
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 6648924..5cd7d06 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -27,6 +27,7 @@ struct netns_xfrm {
 	wait_queue_head_t	km_waitq;
 
 	struct list_head	policy_all;
+	struct hlist_head	*policy_byidx;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index aabc7f2..700cdd7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -329,7 +329,6 @@ struct xfrm_policy_hash {
 
 static struct hlist_head xfrm_policy_inexact[XFRM_POLICY_MAX*2];
 static struct xfrm_policy_hash xfrm_policy_bydst[XFRM_POLICY_MAX*2] __read_mostly;
-static struct hlist_head *xfrm_policy_byidx __read_mostly;
 static unsigned int xfrm_idx_hmask __read_mostly;
 static unsigned int xfrm_policy_hashmax __read_mostly = 1 * 1024 * 1024;
 
@@ -438,7 +437,7 @@ static void xfrm_byidx_resize(int total)
 	unsigned int hmask = xfrm_idx_hmask;
 	unsigned int nhashmask = xfrm_new_hash_mask(hmask);
 	unsigned int nsize = (nhashmask + 1) * sizeof(struct hlist_head);
-	struct hlist_head *oidx = xfrm_policy_byidx;
+	struct hlist_head *oidx = init_net.xfrm.policy_byidx;
 	struct hlist_head *nidx = xfrm_hash_alloc(nsize);
 	int i;
 
@@ -450,7 +449,7 @@ static void xfrm_byidx_resize(int total)
 	for (i = hmask; i >= 0; i--)
 		xfrm_idx_hash_transfer(oidx + i, nidx, nhashmask);
 
-	xfrm_policy_byidx = nidx;
+	init_net.xfrm.policy_byidx = nidx;
 	xfrm_idx_hmask = nhashmask;
 
 	write_unlock_bh(&xfrm_policy_lock);
@@ -536,7 +535,7 @@ static u32 xfrm_gen_index(int dir)
 		idx_generator += 8;
 		if (idx == 0)
 			idx = 8;
-		list = xfrm_policy_byidx + idx_hash(idx);
+		list = init_net.xfrm.policy_byidx + idx_hash(idx);
 		found = 0;
 		hlist_for_each_entry(p, entry, list, byidx) {
 			if (p->index == idx) {
@@ -609,7 +608,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 		xfrm_policy_count[dir]--;
 	}
 	policy->index = delpol ? delpol->index : xfrm_gen_index(dir);
-	hlist_add_head(&policy->byidx, xfrm_policy_byidx+idx_hash(policy->index));
+	hlist_add_head(&policy->byidx, init_net.xfrm.policy_byidx+idx_hash(policy->index));
 	policy->curlft.add_time = get_seconds();
 	policy->curlft.use_time = 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))
@@ -711,7 +710,7 @@ struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete,
 
 	*err = 0;
 	write_lock_bh(&xfrm_policy_lock);
-	chain = xfrm_policy_byidx + idx_hash(id);
+	chain = init_net.xfrm.policy_byidx + idx_hash(id);
 	ret = NULL;
 	hlist_for_each_entry(pol, entry, chain, byidx) {
 		if (pol->type == type && pol->index == id) {
@@ -1087,7 +1086,7 @@ static void __xfrm_policy_link(struct xfrm_policy *pol, int dir)
 
 	list_add(&pol->walk.all, &init_net.xfrm.policy_all);
 	hlist_add_head(&pol->bydst, chain);
-	hlist_add_head(&pol->byidx, xfrm_policy_byidx+idx_hash(pol->index));
+	hlist_add_head(&pol->byidx, init_net.xfrm.policy_byidx+idx_hash(pol->index));
 	xfrm_policy_count[dir]++;
 	xfrm_pol_hold(pol);
 
@@ -2408,10 +2407,10 @@ static int __net_init xfrm_policy_init(struct net *net)
 	hmask = 8 - 1;
 	sz = (hmask+1) * sizeof(struct hlist_head);
 
-	xfrm_policy_byidx = xfrm_hash_alloc(sz);
+	net->xfrm.policy_byidx = xfrm_hash_alloc(sz);
+	if (!net->xfrm.policy_byidx)
+		goto out_byidx;
 	xfrm_idx_hmask = hmask;
-	if (!xfrm_policy_byidx)
-		panic("XFRM: failed to allocate byidx hash\n");
 
 	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
 		struct xfrm_policy_hash *htab;
@@ -2429,11 +2428,20 @@ static int __net_init xfrm_policy_init(struct net *net)
 	if (net_eq(net, &init_net))
 		register_netdevice_notifier(&xfrm_dev_notifier);
 	return 0;
+
+out_byidx:
+	return -ENOMEM;
 }
 
 static void xfrm_policy_fini(struct net *net)
 {
+	unsigned int sz;
+
 	WARN_ON(!list_empty(&net->xfrm.policy_all));
+
+	sz = (xfrm_idx_hmask + 1) * sizeof(struct hlist_head);
+	WARN_ON(!hlist_empty(net->xfrm.policy_byidx));
+	xfrm_hash_free(net->xfrm.policy_byidx, sz);
 }
 
 static int __net_init xfrm_net_init(struct net *net)
-- 
1.5.6.5
