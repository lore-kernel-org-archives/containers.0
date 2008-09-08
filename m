From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 07/33] netns ct: pass netns pointer to nf_conntrack_in()
Date: Mon,  8 Sep 2008 07:02:44 +0400
Message-ID: <1220842990-30500-7-git-send-email-adobriyan__16130.3731998943$1220843510$gmane$org@gmail.com>
References: <48C01046.2070704@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C01046.2070704-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
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
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

It's deducible from skb->dev or skb->dst->dev, but we know netns at
the moment of call, so pass it down and use for finding and creating
conntracks.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index b4b45c5..e78afe7 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -20,7 +20,8 @@
 /* This header is used to share core functionality between the
    standalone connection tracking module, and the compatibility layer's use
    of connection tracking. */
-extern unsigned int nf_conntrack_in(u_int8_t pf,
+extern unsigned int nf_conntrack_in(struct net *net,
+				    u_int8_t pf,
 				    unsigned int hooknum,
 				    struct sk_buff *skb);
 
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 03dd108..2e4dd3f 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -172,7 +172,7 @@ static unsigned int ipv4_conntrack_in(unsigned int hooknum,
 				      const struct net_device *out,
 				      int (*okfn)(struct sk_buff *))
 {
-	return nf_conntrack_in(PF_INET, hooknum, skb);
+	return nf_conntrack_in(dev_net(in), PF_INET, hooknum, skb);
 }
 
 static unsigned int ipv4_conntrack_local(unsigned int hooknum,
@@ -188,7 +188,7 @@ static unsigned int ipv4_conntrack_local(unsigned int hooknum,
 			printk("ipt_hook: happy cracking.\n");
 		return NF_ACCEPT;
 	}
-	return nf_conntrack_in(PF_INET, hooknum, skb);
+	return nf_conntrack_in(dev_net(out), PF_INET, hooknum, skb);
 }
 
 /* Connection tracking may drop packets, but never alters them, so
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 85050c0..e91db16 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -211,11 +211,10 @@ static unsigned int ipv6_defrag(unsigned int hooknum,
 	return NF_STOLEN;
 }
 
-static unsigned int ipv6_conntrack_in(unsigned int hooknum,
-				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+static unsigned int __ipv6_conntrack_in(struct net *net,
+					unsigned int hooknum,
+					struct sk_buff *skb,
+					int (*okfn)(struct sk_buff *))
 {
 	struct sk_buff *reasm = skb->nfct_reasm;
 
@@ -225,7 +224,7 @@ static unsigned int ipv6_conntrack_in(unsigned int hooknum,
 		if (!reasm->nfct) {
 			unsigned int ret;
 
-			ret = nf_conntrack_in(PF_INET6, hooknum, reasm);
+			ret = nf_conntrack_in(net, PF_INET6, hooknum, reasm);
 			if (ret != NF_ACCEPT)
 				return ret;
 		}
@@ -235,7 +234,16 @@ static unsigned int ipv6_conntrack_in(unsigned int hooknum,
 		return NF_ACCEPT;
 	}
 
-	return nf_conntrack_in(PF_INET6, hooknum, skb);
+	return nf_conntrack_in(net, PF_INET6, hooknum, skb);
+}
+
+static unsigned int ipv6_conntrack_in(unsigned int hooknum,
+				      struct sk_buff *skb,
+				      const struct net_device *in,
+				      const struct net_device *out,
+				      int (*okfn)(struct sk_buff *))
+{
+	return __ipv6_conntrack_in(dev_net(in), hooknum, skb, okfn);
 }
 
 static unsigned int ipv6_conntrack_local(unsigned int hooknum,
@@ -250,7 +258,7 @@ static unsigned int ipv6_conntrack_local(unsigned int hooknum,
 			printk("ipv6_conntrack_local: packet too short\n");
 		return NF_ACCEPT;
 	}
-	return ipv6_conntrack_in(hooknum, skb, in, out, okfn);
+	return __ipv6_conntrack_in(dev_net(out), hooknum, skb, okfn);
 }
 
 static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 2a105db..5c96d97 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -611,7 +611,8 @@ init_conntrack(struct net *net,
 
 /* On success, returns conntrack ptr, sets skb->nfct and ctinfo */
 static inline struct nf_conn *
-resolve_normal_ct(struct sk_buff *skb,
+resolve_normal_ct(struct net *net,
+		  struct sk_buff *skb,
 		  unsigned int dataoff,
 		  u_int16_t l3num,
 		  u_int8_t protonum,
@@ -632,10 +633,9 @@ resolve_normal_ct(struct sk_buff *skb,
 	}
 
 	/* look for tuple match */
-	h = nf_conntrack_find_get(&init_net, &tuple);
+	h = nf_conntrack_find_get(net, &tuple);
 	if (!h) {
-		h = init_conntrack(&init_net, &tuple, l3proto, l4proto, skb,
-				   dataoff);
+		h = init_conntrack(net, &tuple, l3proto, l4proto, skb, dataoff);
 		if (!h)
 			return NULL;
 		if (IS_ERR(h))
@@ -669,7 +669,8 @@ resolve_normal_ct(struct sk_buff *skb,
 }
 
 unsigned int
-nf_conntrack_in(u_int8_t pf, unsigned int hooknum, struct sk_buff *skb)
+nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
+		struct sk_buff *skb)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -709,8 +710,8 @@ nf_conntrack_in(u_int8_t pf, unsigned int hooknum, struct sk_buff *skb)
 		return -ret;
 	}
 
-	ct = resolve_normal_ct(skb, dataoff, pf, protonum, l3proto, l4proto,
-			       &set_reply, &ctinfo);
+	ct = resolve_normal_ct(net, skb, dataoff, pf, protonum,
+			       l3proto, l4proto, &set_reply, &ctinfo);
 	if (!ct) {
 		/* Not valid part of a connection */
 		NF_CT_STAT_INC_ATOMIC(invalid);
