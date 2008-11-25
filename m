From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 14/53] netns xfrm: add struct xfrm_policy::xp_net
Date: Tue, 25 Nov 2008 20:26:46 +0300
Message-ID: <1227634045-27534-14-git-send-email-adobriyan__15913.5988950313$1227637624$gmane$org@gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227634045-27534-13-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

Again, to avoid complications with passing netns when not necessary.
Again, ->xp_net is set-once field, once set it never changes.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/xfrm.h     |   10 +++++++++-
 net/key/af_key.c       |    4 ++--
 net/xfrm/xfrm_policy.c |    5 +++--
 net/xfrm/xfrm_user.c   |    4 ++--
 4 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 0d4353c..1ab1756 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -475,6 +475,9 @@ struct xfrm_policy_walk {
 
 struct xfrm_policy
 {
+#ifdef CONFIG_NET_NS
+	struct net		*xp_net;
+#endif
 	struct hlist_node	bydst;
 	struct hlist_node	byidx;
 
@@ -499,6 +502,11 @@ struct xfrm_policy
 	struct xfrm_tmpl       	xfrm_vec[XFRM_MAX_DEPTH];
 };
 
+static inline struct net *xp_net(struct xfrm_policy *xp)
+{
+	return read_pnet(&xp->xp_net);
+}
+
 struct xfrm_kmaddress {
 	xfrm_address_t          local;
 	xfrm_address_t          remote;
@@ -1425,7 +1433,7 @@ static inline int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb)
 }
 #endif
 
-struct xfrm_policy *xfrm_policy_alloc(gfp_t gfp);
+struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp);
 
 extern void xfrm_policy_walk_init(struct xfrm_policy_walk *walk, u8 type);
 extern int xfrm_policy_walk(struct xfrm_policy_walk *walk,
diff --git a/net/key/af_key.c b/net/key/af_key.c
index f202ba6..036315d 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2174,7 +2174,7 @@ static int pfkey_spdadd(struct sock *sk, struct sk_buff *skb, struct sadb_msg *h
 	if (!pol->sadb_x_policy_dir || pol->sadb_x_policy_dir >= IPSEC_DIR_MAX)
 		return -EINVAL;
 
-	xp = xfrm_policy_alloc(GFP_KERNEL);
+	xp = xfrm_policy_alloc(&init_net, GFP_KERNEL);
 	if (xp == NULL)
 		return -ENOBUFS;
 
@@ -3141,7 +3141,7 @@ static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
 	    (!pol->sadb_x_policy_dir || pol->sadb_x_policy_dir > IPSEC_DIR_OUTBOUND))
 		return NULL;
 
-	xp = xfrm_policy_alloc(GFP_ATOMIC);
+	xp = xfrm_policy_alloc(&init_net, GFP_ATOMIC);
 	if (xp == NULL) {
 		*dir = -ENOBUFS;
 		return NULL;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index cf2bf3a..3eccefa 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -228,13 +228,14 @@ expired:
  * SPD calls.
  */
 
-struct xfrm_policy *xfrm_policy_alloc(gfp_t gfp)
+struct xfrm_policy *xfrm_policy_alloc(struct net *net, gfp_t gfp)
 {
 	struct xfrm_policy *policy;
 
 	policy = kzalloc(sizeof(struct xfrm_policy), gfp);
 
 	if (policy) {
+		write_pnet(&policy->xp_net, net);
 		INIT_LIST_HEAD(&policy->walk.all);
 		INIT_HLIST_NODE(&policy->bydst);
 		INIT_HLIST_NODE(&policy->byidx);
@@ -1153,7 +1154,7 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 
 static struct xfrm_policy *clone_policy(struct xfrm_policy *old, int dir)
 {
-	struct xfrm_policy *newp = xfrm_policy_alloc(GFP_ATOMIC);
+	struct xfrm_policy *newp = xfrm_policy_alloc(xp_net(old), GFP_ATOMIC);
 
 	if (newp) {
 		newp->selector = old->selector;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 65cdaa5..765c01e 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -1080,7 +1080,7 @@ static void copy_to_user_policy(struct xfrm_policy *xp, struct xfrm_userpolicy_i
 
 static struct xfrm_policy *xfrm_policy_construct(struct xfrm_userpolicy_info *p, struct nlattr **attrs, int *errp)
 {
-	struct xfrm_policy *xp = xfrm_policy_alloc(GFP_KERNEL);
+	struct xfrm_policy *xp = xfrm_policy_alloc(&init_net, GFP_KERNEL);
 	int err;
 
 	if (!xp) {
@@ -2291,7 +2291,7 @@ static struct xfrm_policy *xfrm_compile_policy(struct sock *sk, int opt,
 	if (p->dir > XFRM_POLICY_OUT)
 		return NULL;
 
-	xp = xfrm_policy_alloc(GFP_KERNEL);
+	xp = xfrm_policy_alloc(&init_net, GFP_KERNEL);
 	if (xp == NULL) {
 		*dir = -ENOBUFS;
 		return NULL;
-- 
1.5.6.5
