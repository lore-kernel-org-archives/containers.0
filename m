From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 17/53] netns xfrm: per-netns xfrm_policy_byidx hashmask
Date: Tue, 25 Nov 2008 20:26:49 +0300
Message-ID: <1227634045-27534-17-git-send-email-adobriyan__13872.432037215$1227634550$gmane$org@gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227634045-27534-16-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

Per-netns hashes are independently resizeable.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/netns/xfrm.h |    1 +
 net/xfrm/xfrm_policy.c   |   15 +++++++--------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 5cd7d06..42dc318 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -28,6 +28,7 @@ struct netns_xfrm {
 
 	struct list_head	policy_all;
 	struct hlist_head	*policy_byidx;
+	unsigned int		policy_idx_hmask;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 700cdd7..9e37a44 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -329,12 +329,11 @@ struct xfrm_policy_hash {
 
 static struct hlist_head xfrm_policy_inexact[XFRM_POLICY_MAX*2];
 static struct xfrm_policy_hash xfrm_policy_bydst[XFRM_POLICY_MAX*2] __read_mostly;
-static unsigned int xfrm_idx_hmask __read_mostly;
 static unsigned int xfrm_policy_hashmax __read_mostly = 1 * 1024 * 1024;
 
 static inline unsigned int idx_hash(u32 index)
 {
-	return __idx_hash(index, xfrm_idx_hmask);
+	return __idx_hash(index, init_net.xfrm.policy_idx_hmask);
 }
 
 static struct hlist_head *policy_hash_bysel(struct xfrm_selector *sel, unsigned short family, int dir)
@@ -434,7 +433,7 @@ static void xfrm_bydst_resize(int dir)
 
 static void xfrm_byidx_resize(int total)
 {
-	unsigned int hmask = xfrm_idx_hmask;
+	unsigned int hmask = init_net.xfrm.policy_idx_hmask;
 	unsigned int nhashmask = xfrm_new_hash_mask(hmask);
 	unsigned int nsize = (nhashmask + 1) * sizeof(struct hlist_head);
 	struct hlist_head *oidx = init_net.xfrm.policy_byidx;
@@ -450,7 +449,7 @@ static void xfrm_byidx_resize(int total)
 		xfrm_idx_hash_transfer(oidx + i, nidx, nhashmask);
 
 	init_net.xfrm.policy_byidx = nidx;
-	xfrm_idx_hmask = nhashmask;
+	init_net.xfrm.policy_idx_hmask = nhashmask;
 
 	write_unlock_bh(&xfrm_policy_lock);
 
@@ -474,7 +473,7 @@ static inline int xfrm_bydst_should_resize(int dir, int *total)
 
 static inline int xfrm_byidx_should_resize(int total)
 {
-	unsigned int hmask = xfrm_idx_hmask;
+	unsigned int hmask = init_net.xfrm.policy_idx_hmask;
 
 	if ((hmask + 1) < xfrm_policy_hashmax &&
 	    total > hmask)
@@ -492,7 +491,7 @@ void xfrm_spd_getinfo(struct xfrmk_spdinfo *si)
 	si->inscnt = xfrm_policy_count[XFRM_POLICY_IN+XFRM_POLICY_MAX];
 	si->outscnt = xfrm_policy_count[XFRM_POLICY_OUT+XFRM_POLICY_MAX];
 	si->fwdscnt = xfrm_policy_count[XFRM_POLICY_FWD+XFRM_POLICY_MAX];
-	si->spdhcnt = xfrm_idx_hmask;
+	si->spdhcnt = init_net.xfrm.policy_idx_hmask;
 	si->spdhmcnt = xfrm_policy_hashmax;
 	read_unlock_bh(&xfrm_policy_lock);
 }
@@ -2410,7 +2409,7 @@ static int __net_init xfrm_policy_init(struct net *net)
 	net->xfrm.policy_byidx = xfrm_hash_alloc(sz);
 	if (!net->xfrm.policy_byidx)
 		goto out_byidx;
-	xfrm_idx_hmask = hmask;
+	net->xfrm.policy_idx_hmask = hmask;
 
 	for (dir = 0; dir < XFRM_POLICY_MAX * 2; dir++) {
 		struct xfrm_policy_hash *htab;
@@ -2439,7 +2438,7 @@ static void xfrm_policy_fini(struct net *net)
 
 	WARN_ON(!list_empty(&net->xfrm.policy_all));
 
-	sz = (xfrm_idx_hmask + 1) * sizeof(struct hlist_head);
+	sz = (net->xfrm.policy_idx_hmask + 1) * sizeof(struct hlist_head);
 	WARN_ON(!hlist_empty(net->xfrm.policy_byidx));
 	xfrm_hash_free(net->xfrm.policy_byidx, sz);
 }
-- 
1.5.6.5
