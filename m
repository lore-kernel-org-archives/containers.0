From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 45/53] netns xfrm: ->get_saddr in netns
Date: Tue, 25 Nov 2008 20:27:17 +0300
Message-ID: <1227634045-27534-45-git-send-email-adobriyan__3652.33688285134$1227635875$gmane$org@gmail.com>
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
	<1227634045-27534-38-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-39-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-40-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-41-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-42-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-43-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-44-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227634045-27534-44-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
 include/net/xfrm.h      |    2 +-
 net/ipv4/xfrm4_policy.c |    5 +++--
 net/ipv6/xfrm6_policy.c |    5 +++--
 net/xfrm/xfrm_policy.c  |    7 ++++---
 4 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index b16d4c0..d076f3d 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -269,7 +269,7 @@ struct xfrm_policy_afinfo {
 	struct dst_entry	*(*dst_lookup)(struct net *net, int tos,
 					       xfrm_address_t *saddr,
 					       xfrm_address_t *daddr);
-	int			(*get_saddr)(xfrm_address_t *saddr, xfrm_address_t *daddr);
+	int			(*get_saddr)(struct net *net, xfrm_address_t *saddr, xfrm_address_t *daddr);
 	struct dst_entry	*(*find_bundle)(struct flowi *fl, struct xfrm_policy *policy);
 	void			(*decode_session)(struct sk_buff *skb,
 						  struct flowi *fl,
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index e1cf9ed..2ad24ba 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -44,12 +44,13 @@ static struct dst_entry *xfrm4_dst_lookup(struct net *net, int tos,
 	return dst;
 }
 
-static int xfrm4_get_saddr(xfrm_address_t *saddr, xfrm_address_t *daddr)
+static int xfrm4_get_saddr(struct net *net,
+			   xfrm_address_t *saddr, xfrm_address_t *daddr)
 {
 	struct dst_entry *dst;
 	struct rtable *rt;
 
-	dst = xfrm4_dst_lookup(&init_net, 0, NULL, daddr);
+	dst = xfrm4_dst_lookup(net, 0, NULL, daddr);
 	if (IS_ERR(dst))
 		return -EHOSTUNREACH;
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index d7a5b8b..97ab068 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -50,12 +50,13 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos,
 	return dst;
 }
 
-static int xfrm6_get_saddr(xfrm_address_t *saddr, xfrm_address_t *daddr)
+static int xfrm6_get_saddr(struct net *net,
+			   xfrm_address_t *saddr, xfrm_address_t *daddr)
 {
 	struct dst_entry *dst;
 	struct net_device *dev;
 
-	dst = xfrm6_dst_lookup(&init_net, 0, NULL, daddr);
+	dst = xfrm6_dst_lookup(net, 0, NULL, daddr);
 	if (IS_ERR(dst))
 		return -EHOSTUNREACH;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 2b0a80b..7c7bb54 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1187,7 +1187,7 @@ int __xfrm_sk_clone_policy(struct sock *sk)
 }
 
 static int
-xfrm_get_saddr(xfrm_address_t *local, xfrm_address_t *remote,
+xfrm_get_saddr(struct net *net, xfrm_address_t *local, xfrm_address_t *remote,
 	       unsigned short family)
 {
 	int err;
@@ -1195,7 +1195,7 @@ xfrm_get_saddr(xfrm_address_t *local, xfrm_address_t *remote,
 
 	if (unlikely(afinfo == NULL))
 		return -EINVAL;
-	err = afinfo->get_saddr(local, remote);
+	err = afinfo->get_saddr(net, local, remote);
 	xfrm_policy_put_afinfo(afinfo);
 	return err;
 }
@@ -1207,6 +1207,7 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, struct flowi *fl,
 		      struct xfrm_state **xfrm,
 		      unsigned short family)
 {
+	struct net *net = xp_net(policy);
 	int nx;
 	int i, error;
 	xfrm_address_t *daddr = xfrm_flowi_daddr(fl, family);
@@ -1225,7 +1226,7 @@ xfrm_tmpl_resolve_one(struct xfrm_policy *policy, struct flowi *fl,
 			local = &tmpl->saddr;
 			family = tmpl->encap_family;
 			if (xfrm_addr_any(local, family)) {
-				error = xfrm_get_saddr(&tmp, remote, family);
+				error = xfrm_get_saddr(net, &tmp, remote, family);
 				if (error)
 					goto fail;
 				local = &tmp;
-- 
1.5.6.5
