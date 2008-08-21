From: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [PATCH 11/38] netns ct: per-netns unconfirmed hash
Date: Fri, 22 Aug 2008 02:40:30 +0400
Message-ID: <20080821224030.GB31601__34934.4703405679$1219358463$gmane$org@x200.localdomain>
References: <20080821220059.GK31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080821220059.GK31136-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

What is unconfirmed connection in one netns can very well be confirmed
in another.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/net/netfilter/nf_conntrack_core.h |    1 -
 include/net/netns/conntrack.h             |    2 ++
 net/netfilter/nf_conntrack_core.c         |    6 +++---
 net/netfilter/nf_conntrack_helper.c       |    3 +--
 4 files changed, 6 insertions(+), 6 deletions(-)

--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -72,6 +72,5 @@ print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
             const struct nf_conntrack_l4proto *proto);
 
 extern spinlock_t nf_conntrack_lock ;
-extern struct hlist_head unconfirmed;
 
 #endif /* _NF_CONNTRACK_CORE_H */
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -1,6 +1,7 @@
 #ifndef __NETNS_CONNTRACK_H
 #define __NETNS_CONNTRACK_H
 
+#include <linux/list.h>
 #include <asm/atomic.h>
 
 struct netns_ct {
@@ -10,5 +11,6 @@ struct netns_ct {
 	unsigned int		expect_count;
 	struct hlist_head	*expect_hash;
 	int			expect_vmalloc;
+	struct hlist_head	unconfirmed;
 };
 #endif
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -54,7 +54,6 @@ struct nf_conn nf_conntrack_untracked __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_untracked);
 
 unsigned int nf_ct_log_invalid __read_mostly;
-HLIST_HEAD(unconfirmed);
 static struct kmem_cache *nf_conntrack_cachep __read_mostly;
 
 DEFINE_PER_CPU(struct ip_conntrack_stat, nf_conntrack_stat);
@@ -596,7 +595,7 @@ init_conntrack(struct net *net,
 	}
 
 	/* Overload tuple linked list to put us in unconfirmed list. */
-	hlist_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode, &unconfirmed);
+	hlist_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnode, &net->ct.unconfirmed);
 
 	spin_unlock_bh(&nf_conntrack_lock);
 
@@ -956,7 +955,7 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 				goto found;
 		}
 	}
-	hlist_for_each_entry(h, n, &unconfirmed, hnode) {
+	hlist_for_each_entry(h, n, &net->ct.unconfirmed, hnode) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (iter(ct, data))
 			set_bit(IPS_DYING_BIT, &ct->status);
@@ -1152,6 +1151,7 @@ int nf_conntrack_init(struct net *net)
 		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
 		goto err_out;
 	}
+	INIT_HLIST_HEAD(&net->ct.unconfirmed);
 
 	nf_conntrack_max = max_factor * nf_conntrack_htable_size;
 
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -156,7 +156,7 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	}
 
 	/* Get rid of expecteds, set helpers to NULL. */
-	hlist_for_each_entry(h, n, &unconfirmed, hnode)
+	hlist_for_each_entry(h, n, &init_net.ct.unconfirmed, hnode)
 		unhelp(h, me);
 	for (i = 0; i < nf_conntrack_htable_size; i++) {
 		hlist_for_each_entry(h, n, &init_net.ct.hash[i], hnode)
-- 
1.5.6.3
