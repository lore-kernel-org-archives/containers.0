From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 38/53] netns xfrm: dst garbage-collecting in netns
Date: Tue, 25 Nov 2008 20:27:10 +0300
Message-ID: <1227634045-27534-38-git-send-email-adobriyan__31706.4183684581$1227635355$gmane$org@gmail.com>
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
	<1227634045-27534-29-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-30-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-31-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-32-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-33-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-34-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-35-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-36-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-37-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227634045-27534-37-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

Pass netns pointer to struct xfrm_policy_afinfo::garbage_collect()

	[This needs more thoughts on what to do with dst_ops]
	[Currently stub to init_net]

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/xfrm.h      |    2 +-
 net/ipv4/xfrm4_policy.c |    2 +-
 net/ipv6/xfrm6_policy.c |    2 +-
 net/xfrm/xfrm_policy.c  |    4 ++--
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 36c8cff..bd25150 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -265,7 +265,7 @@ struct xfrm_dst;
 struct xfrm_policy_afinfo {
 	unsigned short		family;
 	struct dst_ops		*dst_ops;
-	void			(*garbage_collect)(void);
+	void			(*garbage_collect)(struct net *net);
 	struct dst_entry	*(*dst_lookup)(int tos, xfrm_address_t *saddr,
 					       xfrm_address_t *daddr);
 	int			(*get_saddr)(xfrm_address_t *saddr, xfrm_address_t *daddr);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 84dbb5a..a881ca3 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -187,7 +187,7 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 static inline int xfrm4_garbage_collect(struct dst_ops *ops)
 {
-	xfrm4_policy_afinfo.garbage_collect();
+	xfrm4_policy_afinfo.garbage_collect(&init_net);
 	return (atomic_read(&xfrm4_dst_ops.entries) > xfrm4_dst_ops.gc_thresh*2);
 }
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 3b67ce7..2df8a78 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -220,7 +220,7 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 
 static inline int xfrm6_garbage_collect(struct dst_ops *ops)
 {
-	xfrm6_policy_afinfo.garbage_collect();
+	xfrm6_policy_afinfo.garbage_collect(&init_net);
 	return (atomic_read(&xfrm6_dst_ops.entries) > xfrm6_dst_ops.gc_thresh*2);
 }
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 49e0898..7ebbdd6 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2173,9 +2173,9 @@ static int unused_bundle(struct dst_entry *dst)
 	return !atomic_read(&dst->__refcnt);
 }
 
-static void __xfrm_garbage_collect(void)
+static void __xfrm_garbage_collect(struct net *net)
 {
-	xfrm_prune_bundles(&init_net, unused_bundle);
+	xfrm_prune_bundles(net, unused_bundle);
 }
 
 static int xfrm_flush_bundles(struct net *net)
-- 
1.5.6.5
