From: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: PATCH 19/38] netns ct: cleanup after L3 and L4 proto in every netns
Date: Fri, 22 Aug 2008 02:04:14 +0400
Message-ID: <20080821220414.GS31136__16071.917260024$1219356881$gmane$org@x200.localdomain>
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
To: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Start massacre in every netns when proto in unregistered (read: rmmod).

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 net/netfilter/nf_conntrack_proto.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -207,6 +207,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_register);
 
 void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 {
+	struct net *net;
+
 	BUG_ON(proto->l3proto >= AF_MAX);
 
 	mutex_lock(&nf_ct_proto_mutex);
@@ -219,7 +221,8 @@ void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 	synchronize_rcu();
 
 	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(&init_net, kill_l3proto, proto);
+	for_each_net(net)
+		nf_ct_iterate_cleanup(net, kill_l3proto, proto);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
 
@@ -316,6 +319,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
 
 void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
 {
+	struct net *net;
+
 	BUG_ON(l4proto->l3proto >= PF_MAX);
 
 	mutex_lock(&nf_ct_proto_mutex);
@@ -328,7 +333,8 @@ void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
 	synchronize_rcu();
 
 	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(&init_net, kill_l4proto, l4proto);
+	for_each_net(net)
+		nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
 
-- 
1.5.6.3
