From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 29/53] netns xfrm: propagate netns into policy byidx hash
Date: Tue, 25 Nov 2008 20:27:01 +0300
Message-ID: <1227634045-27534-29-git-send-email-adobriyan__9320.53940273381$1227635151$gmane$org@gmail.com>
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
	<1227634045-27534-16-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-17-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-18-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-19-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-20-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-21-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-22-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-23-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-24-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-25-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-26-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-27-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-28-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227634045-27534-28-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
 net/xfrm/xfrm_policy.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 3d931f5..aefbb56 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -321,9 +321,9 @@ static void xfrm_policy_kill(struct xfrm_policy *policy)
 
 static unsigned int xfrm_policy_hashmax __read_mostly = 1 * 1024 * 1024;
 
-static inline unsigned int idx_hash(u32 index)
+static inline unsigned int idx_hash(struct net *net, u32 index)
 {
-	return __idx_hash(index, init_net.xfrm.policy_idx_hmask);
+	return __idx_hash(index, net->xfrm.policy_idx_hmask);
 }
 
 static struct hlist_head *policy_hash_bysel(struct xfrm_selector *sel, unsigned short family, int dir)
@@ -523,7 +523,7 @@ static u32 xfrm_gen_index(int dir)
 		idx_generator += 8;
 		if (idx == 0)
 			idx = 8;
-		list = init_net.xfrm.policy_byidx + idx_hash(idx);
+		list = init_net.xfrm.policy_byidx + idx_hash(&init_net, idx);
 		found = 0;
 		hlist_for_each_entry(p, entry, list, byidx) {
 			if (p->index == idx) {
@@ -596,7 +596,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 		init_net.xfrm.policy_count[dir]--;
 	}
 	policy->index = delpol ? delpol->index : xfrm_gen_index(dir);
-	hlist_add_head(&policy->byidx, init_net.xfrm.policy_byidx+idx_hash(policy->index));
+	hlist_add_head(&policy->byidx, init_net.xfrm.policy_byidx+idx_hash(&init_net, policy->index));
 	policy->curlft.add_time = get_seconds();
 	policy->curlft.use_time = 0;
 	if (!mod_timer(&policy->timer, jiffies + HZ))
@@ -698,7 +698,7 @@ struct xfrm_policy *xfrm_policy_byid(u8 type, int dir, u32 id, int delete,
 
 	*err = 0;
 	write_lock_bh(&xfrm_policy_lock);
-	chain = init_net.xfrm.policy_byidx + idx_hash(id);
+	chain = init_net.xfrm.policy_byidx + idx_hash(&init_net, id);
 	ret = NULL;
 	hlist_for_each_entry(pol, entry, chain, byidx) {
 		if (pol->type == type && pol->index == id) {
@@ -1075,7 +1075,7 @@ static void __xfrm_policy_link(struct xfrm_policy *pol, int dir)
 
 	list_add(&pol->walk.all, &net->xfrm.policy_all);
 	hlist_add_head(&pol->bydst, chain);
-	hlist_add_head(&pol->byidx, net->xfrm.policy_byidx+idx_hash(pol->index));
+	hlist_add_head(&pol->byidx, net->xfrm.policy_byidx+idx_hash(net, pol->index));
 	net->xfrm.policy_count[dir]++;
 	xfrm_pol_hold(pol);
 
-- 
1.5.6.5
