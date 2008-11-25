From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 02/53] netns xfrm: add netns boilerplate
Date: Tue, 25 Nov 2008 20:26:34 +0300
Message-ID: <1227634045-27534-2-git-send-email-adobriyan__42290.6631640673$1227634211$gmane$org@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1227634045-27534-1-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
 include/net/net_namespace.h |    4 +++
 include/net/netns/xfrm.h    |    7 ++++++
 include/net/xfrm.h          |    3 +-
 net/xfrm/xfrm_policy.c      |   45 ++++++++++++++++++++++++++++++++++++++----
 net/xfrm/xfrm_state.c       |    7 +++++-
 5 files changed, 59 insertions(+), 7 deletions(-)
 create mode 100644 include/net/netns/xfrm.h

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 3195577..6fc13d9 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -19,6 +19,7 @@
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netns/conntrack.h>
 #endif
+#include <net/netns/xfrm.h>
 
 struct proc_dir_entry;
 struct net_device;
@@ -74,6 +75,9 @@ struct net {
 	struct netns_ct		ct;
 #endif
 #endif
+#ifdef CONFIG_XFRM
+	struct netns_xfrm	xfrm;
+#endif
 	struct net_generic	*gen;
 };
 
diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
new file mode 100644
index 0000000..1cb0024
--- /dev/null
+++ b/include/net/netns/xfrm.h
@@ -0,0 +1,7 @@
+#ifndef __NETNS_XFRM_H
+#define __NETNS_XFRM_H
+
+struct netns_xfrm {
+};
+
+#endif
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 45e11b3..9107d6f 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1269,7 +1269,8 @@ struct xfrm6_tunnel {
 
 extern void xfrm_init(void);
 extern void xfrm4_init(void);
-extern void xfrm_state_init(void);
+extern int xfrm_state_init(struct net *net);
+extern void xfrm_state_fini(struct net *net);
 extern void xfrm4_state_init(void);
 #ifdef CONFIG_XFRM
 extern int xfrm6_init(void);
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ea3456d..8e7671b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2394,12 +2394,13 @@ static int __init xfrm_statistics_init(void)
 }
 #endif
 
-static void __init xfrm_policy_init(void)
+static int __net_init xfrm_policy_init(struct net *net)
 {
 	unsigned int hmask, sz;
 	int dir;
 
-	xfrm_dst_cache = kmem_cache_create("xfrm_dst_cache",
+	if (net_eq(net, &init_net))
+		xfrm_dst_cache = kmem_cache_create("xfrm_dst_cache",
 					   sizeof(struct xfrm_dst),
 					   0, SLAB_HWCACHE_ALIGN|SLAB_PANIC,
 					   NULL);
@@ -2425,16 +2426,50 @@ static void __init xfrm_policy_init(void)
 	}
 
 	INIT_LIST_HEAD(&xfrm_policy_all);
-	register_netdevice_notifier(&xfrm_dev_notifier);
+	if (net_eq(net, &init_net))
+		register_netdevice_notifier(&xfrm_dev_notifier);
+	return 0;
+}
+
+static void xfrm_policy_fini(struct net *net)
+{
 }
 
+static int __net_init xfrm_net_init(struct net *net)
+{
+	int rv;
+
+	rv = xfrm_state_init(net);
+	if (rv < 0)
+		goto out_state;
+	rv = xfrm_policy_init(net);
+	if (rv < 0)
+		goto out_policy;
+	return 0;
+
+out_policy:
+	xfrm_state_fini(net);
+out_state:
+	return rv;
+}
+
+static void __net_exit xfrm_net_exit(struct net *net)
+{
+	xfrm_policy_fini(net);
+	xfrm_state_fini(net);
+}
+
+static struct pernet_operations __net_initdata xfrm_net_ops = {
+	.init = xfrm_net_init,
+	.exit = xfrm_net_exit,
+};
+
 void __init xfrm_init(void)
 {
+	register_pernet_subsys(&xfrm_net_ops);
 #ifdef CONFIG_XFRM_STATISTICS
 	xfrm_statistics_init();
 #endif
-	xfrm_state_init();
-	xfrm_policy_init();
 	xfrm_input_init();
 #ifdef CONFIG_XFRM_STATISTICS
 	xfrm_proc_init();
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index cd9d917..268fe3f 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2080,7 +2080,7 @@ error:
 
 EXPORT_SYMBOL(xfrm_init_state);
 
-void __init xfrm_state_init(void)
+int __net_init xfrm_state_init(struct net *net)
 {
 	unsigned int sz;
 
@@ -2094,6 +2094,11 @@ void __init xfrm_state_init(void)
 	xfrm_state_hmask = ((sz / sizeof(struct hlist_head)) - 1);
 
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task);
+	return 0;
+}
+
+void xfrm_state_fini(struct net *net)
+{
 }
 
 #ifdef CONFIG_AUDITSYSCALL
-- 
1.5.6.5
