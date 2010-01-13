From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/2] ctnetlink: add netns support
Date: Wed, 13 Jan 2010 14:26:37 +0200
Message-ID: <20100113122637.GB5790__24733.9496425868$1263385681$gmane$org@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Allow conntrack program to operate correctly in netns.
Note: passing events is not done in this patch.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 net/netfilter/nf_conntrack_netlink.c |   48 +++++++++++++++++++++--------------
 1 file changed, 29 insertions(+), 19 deletions(-)

--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -30,6 +30,7 @@
 
 #include <linux/netfilter.h>
 #include <net/netlink.h>
+#include <net/sock.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_expect.h>
@@ -587,6 +588,7 @@ static int ctnetlink_done(struct netlink_callback *cb)
 static int
 ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct net *net = sock_net(skb->sk);
 	struct nf_conn *ct, *last;
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
@@ -597,7 +599,7 @@ ctnetlink_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 	last = (struct nf_conn *)cb->args[1];
 	for (; cb->args[0] < nf_conntrack_htable_size; cb->args[0]++) {
 restart:
-		hlist_nulls_for_each_entry_rcu(h, n, &init_net.ct.hash[cb->args[0]],
+		hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[cb->args[0]],
 					 hnnode) {
 			if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
 				continue;
@@ -769,6 +771,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			const struct nlmsghdr *nlh,
 			const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conn *ct;
@@ -782,7 +785,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		err = ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_REPLY, u3);
 	else {
 		/* Flush the whole table */
-		nf_conntrack_flush_report(&init_net,
+		nf_conntrack_flush_report(net,
 					 NETLINK_CB(skb).pid,
 					 nlmsg_report(nlh));
 		return 0;
@@ -791,7 +794,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	h = nf_conntrack_find_get(&init_net, &tuple);
+	h = nf_conntrack_find_get(net, &tuple);
 	if (!h)
 		return -ENOENT;
 
@@ -829,6 +832,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			const struct nlmsghdr *nlh,
 			const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conn *ct;
@@ -851,7 +855,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	h = nf_conntrack_find_get(&init_net, &tuple);
+	h = nf_conntrack_find_get(net, &tuple);
 	if (!h)
 		return -ENOENT;
 
@@ -1176,7 +1180,8 @@ ctnetlink_change_conntrack(struct nf_conn *ct,
 }
 
 static struct nf_conn *
-ctnetlink_create_conntrack(const struct nlattr * const cda[],
+ctnetlink_create_conntrack(struct net *net,
+			   const struct nlattr * const cda[],
 			   struct nf_conntrack_tuple *otuple,
 			   struct nf_conntrack_tuple *rtuple,
 			   u8 u3)
@@ -1185,7 +1190,7 @@ ctnetlink_create_conntrack(const struct nlattr * const cda[],
 	int err = -EINVAL;
 	struct nf_conntrack_helper *helper;
 
-	ct = nf_conntrack_alloc(&init_net, otuple, rtuple, GFP_ATOMIC);
+	ct = nf_conntrack_alloc(net, otuple, rtuple, GFP_ATOMIC);
 	if (IS_ERR(ct))
 		return ERR_PTR(-ENOMEM);
 
@@ -1286,7 +1291,7 @@ ctnetlink_create_conntrack(const struct nlattr * const cda[],
 		if (err < 0)
 			goto err2;
 
-		master_h = nf_conntrack_find_get(&init_net, &master);
+		master_h = nf_conntrack_find_get(net, &master);
 		if (master_h == NULL) {
 			err = -ENOENT;
 			goto err2;
@@ -1314,6 +1319,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			const struct nlmsghdr *nlh,
 			const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple otuple, rtuple;
 	struct nf_conntrack_tuple_hash *h = NULL;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
@@ -1334,9 +1340,9 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 
 	spin_lock_bh(&nf_conntrack_lock);
 	if (cda[CTA_TUPLE_ORIG])
-		h = __nf_conntrack_find(&init_net, &otuple);
+		h = __nf_conntrack_find(net, &otuple);
 	else if (cda[CTA_TUPLE_REPLY])
-		h = __nf_conntrack_find(&init_net, &rtuple);
+		h = __nf_conntrack_find(net, &rtuple);
 
 	if (h == NULL) {
 		err = -ENOENT;
@@ -1344,7 +1350,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			struct nf_conn *ct;
 			enum ip_conntrack_events events;
 
-			ct = ctnetlink_create_conntrack(cda, &otuple,
+			ct = ctnetlink_create_conntrack(net, cda, &otuple,
 							&rtuple, u3);
 			if (IS_ERR(ct)) {
 				err = PTR_ERR(ct);
@@ -1587,7 +1593,7 @@ static int ctnetlink_exp_done(struct netlink_callback *cb)
 static int
 ctnetlink_exp_dump_table(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct net *net = &init_net;
+	struct net *net = sock_net(skb->sk);
 	struct nf_conntrack_expect *exp, *last;
 	struct nfgenmsg *nfmsg = nlmsg_data(cb->nlh);
 	struct hlist_node *n;
@@ -1640,6 +1646,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 		     const struct nlmsghdr *nlh,
 		     const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
 	struct sk_buff *skb2;
@@ -1661,7 +1668,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	exp = nf_ct_expect_find_get(&init_net, &tuple);
+	exp = nf_ct_expect_find_get(net, &tuple);
 	if (!exp)
 		return -ENOENT;
 
@@ -1701,6 +1708,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		     const struct nlmsghdr *nlh,
 		     const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_expect *exp;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_helper *h;
@@ -1717,7 +1725,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 			return err;
 
 		/* bump usage count to 2 */
-		exp = nf_ct_expect_find_get(&init_net, &tuple);
+		exp = nf_ct_expect_find_get(net, &tuple);
 		if (!exp)
 			return -ENOENT;
 
@@ -1747,7 +1755,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		}
 		for (i = 0; i < nf_ct_expect_hsize; i++) {
 			hlist_for_each_entry_safe(exp, n, next,
-						  &init_net.ct.expect_hash[i],
+						  &net->ct.expect_hash[i],
 						  hnode) {
 				m_help = nfct_help(exp->master);
 				if (m_help->helper == h
@@ -1763,7 +1771,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 		spin_lock_bh(&nf_conntrack_lock);
 		for (i = 0; i < nf_ct_expect_hsize; i++) {
 			hlist_for_each_entry_safe(exp, n, next,
-						  &init_net.ct.expect_hash[i],
+						  &net->ct.expect_hash[i],
 						  hnode) {
 				if (del_timer(&exp->timeout)) {
 					nf_ct_unlink_expect(exp);
@@ -1784,7 +1792,8 @@ ctnetlink_change_expect(struct nf_conntrack_expect *x,
 }
 
 static int
-ctnetlink_create_expect(const struct nlattr * const cda[], u_int8_t u3,
+ctnetlink_create_expect(struct net *net, const struct nlattr * const cda[],
+			u_int8_t u3,
 			u32 pid, int report)
 {
 	struct nf_conntrack_tuple tuple, mask, master_tuple;
@@ -1806,7 +1815,7 @@ ctnetlink_create_expect(const struct nlattr * const cda[], u_int8_t u3,
 		return err;
 
 	/* Look for master conntrack of this expectation */
-	h = nf_conntrack_find_get(&init_net, &master_tuple);
+	h = nf_conntrack_find_get(net, &master_tuple);
 	if (!h)
 		return -ENOENT;
 	ct = nf_ct_tuplehash_to_ctrack(h);
@@ -1846,6 +1855,7 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 		     const struct nlmsghdr *nlh,
 		     const struct nlattr * const cda[])
 {
+	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_expect *exp;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
@@ -1862,13 +1872,13 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 		return err;
 
 	spin_lock_bh(&nf_conntrack_lock);
-	exp = __nf_ct_expect_find(&init_net, &tuple);
+	exp = __nf_ct_expect_find(net, &tuple);
 
 	if (!exp) {
 		spin_unlock_bh(&nf_conntrack_lock);
 		err = -ENOENT;
 		if (nlh->nlmsg_flags & NLM_F_CREATE) {
-			err = ctnetlink_create_expect(cda,
+			err = ctnetlink_create_expect(net, cda,
 						      u3,
 						      NETLINK_CB(skb).pid,
 						      nlmsg_report(nlh));
