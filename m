From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] nsproxy: extract create_nsproxy()
Date: Mon, 4 May 2009 03:29:22 +0400
Message-ID: <20090503232922.GH16631__15654.2190038182$1241393381$gmane$org@x200.localdomain>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

clone_nsproxy() does useless copying of old nsproxy -- every pointer will be
rewritten to new ns or to old ns. Remove copying, rename clone_nsproxy(),
create_nsproxy() will be used by C/R code to create fresh nsproxy on restart.

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 kernel/nsproxy.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 63598dc..09b4ff9 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -26,19 +26,14 @@ static struct kmem_cache *nsproxy_cachep;
 
 struct nsproxy init_nsproxy = INIT_NSPROXY(init_nsproxy);
 
-/*
- * creates a copy of "orig" with refcount 1.
- */
-static inline struct nsproxy *clone_nsproxy(struct nsproxy *orig)
+static inline struct nsproxy *create_nsproxy(void)
 {
-	struct nsproxy *ns;
+	struct nsproxy *nsproxy;
 
-	ns = kmem_cache_alloc(nsproxy_cachep, GFP_KERNEL);
-	if (ns) {
-		memcpy(ns, orig, sizeof(struct nsproxy));
-		atomic_set(&ns->count, 1);
-	}
-	return ns;
+	nsproxy = kmem_cache_alloc(nsproxy_cachep, GFP_KERNEL);
+	if (nsproxy)
+		atomic_set(&nsproxy->count, 1);
+	return nsproxy;
 }
 
 /*
@@ -52,7 +47,7 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 	struct nsproxy *new_nsp;
 	int err;
 
-	new_nsp = clone_nsproxy(tsk->nsproxy);
+	new_nsp = create_nsproxy();
 	if (!new_nsp)
 		return ERR_PTR(-ENOMEM);
