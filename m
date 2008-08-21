From: adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [PATCH 06/37] netns ct: add netns boilerplate
Date: Fri, 22 Aug 2008 01:58:50 +0400
Message-ID: <20080821215850.GF31136__34451.1577547111$1219356265$gmane$org@x200.localdomain>
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
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

One comment: #ifdefs around #include is necessary to overcome amazing compile
breakages in NOTRACK-in-netns patch (see below).

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/net/net_namespace.h               |    6 ++++++
 include/net/netfilter/nf_conntrack_core.h |    4 ++--
 include/net/netns/conntrack.h             |    6 ++++++
 net/netfilter/nf_conntrack_core.c         |    4 ++--
 net/netfilter/nf_conntrack_expect.c       |    4 ++--
 net/netfilter/nf_conntrack_standalone.c   |   22 ++++++++++++++++++----
 6 files changed, 36 insertions(+), 10 deletions(-)

--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -16,6 +16,9 @@
 #include <net/netns/ipv6.h>
 #include <net/netns/dccp.h>
 #include <net/netns/x_tables.h>
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#include <net/netns/conntrack.h>
+#endif
 
 struct proc_dir_entry;
 struct net_device;
@@ -67,6 +70,9 @@ struct net {
 #endif
 #ifdef CONFIG_NETFILTER
 	struct netns_xt		xt;
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+	struct netns_ct		ct;
+#endif
 #endif
 	struct net_generic	*gen;
 };
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -24,8 +24,8 @@ extern unsigned int nf_conntrack_in(int pf,
 				    unsigned int hooknum,
 				    struct sk_buff *skb);
 
-extern int nf_conntrack_init(void);
-extern void nf_conntrack_cleanup(void);
+extern int nf_conntrack_init(struct net *net);
+extern void nf_conntrack_cleanup(struct net *net);
 
 extern int nf_conntrack_proto_init(void);
 extern void nf_conntrack_proto_fini(void);
new file mode 100644
--- /dev/null
+++ b/include/net/netns/conntrack.h
@@ -0,0 +1,6 @@
+#ifndef __NETNS_CONNTRACK_H
+#define __NETNS_CONNTRACK_H
+
+struct netns_ct {
+};
+#endif
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1006,7 +1006,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_flush);
 
 /* Mishearing the voices in his head, our hero wonders how he's
    supposed to kill the mall. */
-void nf_conntrack_cleanup(void)
+void nf_conntrack_cleanup(struct net *net)
 {
 	rcu_assign_pointer(ip_ct_attach, NULL);
 
@@ -1120,7 +1120,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_set_hashsize);
 module_param_call(hashsize, nf_conntrack_set_hashsize, param_get_uint,
 		  &nf_conntrack_htable_size, 0600);
 
-int __init nf_conntrack_init(void)
+int nf_conntrack_init(struct net *net)
 {
 	int max_factor = 8;
 	int ret;
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -537,7 +537,7 @@ static const struct file_operations exp_file_ops = {
 };
 #endif /* CONFIG_PROC_FS */
 
-static int __init exp_proc_init(void)
+static int exp_proc_init(void)
 {
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *proc;
@@ -558,7 +558,7 @@ static void exp_proc_remove(void)
 
 module_param_named(expect_hashsize, nf_ct_expect_hsize, uint, 0600);
 
-int __init nf_conntrack_expect_init(void)
+int nf_conntrack_expect_init(void)
 {
 	int err = -ENOMEM;
 
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -440,11 +440,26 @@ static void nf_conntrack_standalone_fini_sysctl(void)
 }
 #endif /* CONFIG_SYSCTL */
 
+static int nf_conntrack_net_init(struct net *net)
+{
+	return nf_conntrack_init(net);
+}
+
+static void nf_conntrack_net_exit(struct net *net)
+{
+	nf_conntrack_cleanup(net);
+}
+
+static struct pernet_operations nf_conntrack_net_ops = {
+	.init = nf_conntrack_net_init,
+	.exit = nf_conntrack_net_exit,
+};
+
 static int __init nf_conntrack_standalone_init(void)
 {
 	int ret;
 
-	ret = nf_conntrack_init();
+	ret = register_pernet_subsys(&nf_conntrack_net_ops);
 	if (ret < 0)
 		goto out;
 	ret = nf_conntrack_standalone_init_proc();
@@ -458,7 +473,7 @@ static int __init nf_conntrack_standalone_init(void)
 out_sysctl:
 	nf_conntrack_standalone_fini_proc();
 out_proc:
-	nf_conntrack_cleanup();
+	unregister_pernet_subsys(&nf_conntrack_net_ops);
 out:
 	return ret;
 }
@@ -467,7 +482,7 @@ static void __exit nf_conntrack_standalone_fini(void)
 {
 	nf_conntrack_standalone_fini_sysctl();
 	nf_conntrack_standalone_fini_proc();
-	nf_conntrack_cleanup();
+	unregister_pernet_subsys(&nf_conntrack_net_ops);
 }
 
 module_init(nf_conntrack_standalone_init);
-- 
1.5.6.3
