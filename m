From: Daniel Golle <dgolle-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH] xt_quota2: introduce support for netns
Date: Tue, 25 Feb 2014 18:00:34 +0100
Message-ID: <20140225170034.GA10440@earthship.local.cellrox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>, jpa-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Initialize a separate xt_quota2 instance for each network
namespace so data limit can be set and enforced per persona.

Change-Id: Iba2869d87cccab2567f5166d7a49e3fc6b956ae8

Signed-off-by: Daniel Golle <dgolle-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Acked-by: Oren Laadan <orenl-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
---
 net/netfilter/xt_quota2.c | 127 +++++++++++++++++++++++++++++++++++++---------
 1 file changed, 102 insertions(+), 25 deletions(-)

diff --git a/net/netfilter/xt_quota2.c b/net/netfilter/xt_quota2.c
index fb2ef46..bba78ec 100644
--- a/net/netfilter/xt_quota2.c
+++ b/net/netfilter/xt_quota2.c
@@ -11,6 +11,12 @@
  *	it under the terms of the GNU General Public License; either
  *	version 2 of the License, as published by the Free Software Foundation.
  */
+
+#include <linux/nsproxy.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <net/dst.h>
+
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/proc_fs.h>
@@ -43,13 +49,38 @@ module_param_named(event_num, qlog_nl_event, uint, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(event_num,
 		 "Event number for NETLINK_NFLOG message. 0 disables log."
 		 "111 is what ipt_ULOG uses.");
-static struct sock *nflognl;
 #endif
 
-static LIST_HEAD(counter_list);
+struct quota2_net {
+	struct list_head counter_list;
+	struct proc_dir_entry *proc_xt_quota;
+#ifdef CONFIG_NETFILTER_XT_MATCH_QUOTA2_LOG
+	struct sock *nflognl;
+#endif
+};
+
+static int quota2_net_id;
+static inline struct quota2_net *quota2_pernet(struct net *net)
+{
+	return net_generic(net, quota2_net_id);
+}
+
+/* from xt_TEE, should probably go into some common include */
+static struct net *pick_net(const struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_NS
+	const struct dst_entry *dst;
+	if (skb->dev != NULL)
+		return dev_net(skb->dev);
+	dst = skb_dst(skb);
+	if (dst != NULL && dst->dev != NULL)
+		return dev_net(dst->dev);
+#endif
+	return &init_net;
+}
+
 static DEFINE_SPINLOCK(counter_list_lock);
 
-static struct proc_dir_entry *proc_xt_quota;
 static unsigned int quota_list_perms = S_IRUGO | S_IWUSR;
 static unsigned int quota_list_uid   = 0;
 static unsigned int quota_list_gid   = 0;
@@ -57,9 +88,9 @@ module_param_named(perms, quota_list_perms, uint, S_IRUGO | S_IWUSR);
 module_param_named(uid, quota_list_uid, uint, S_IRUGO | S_IWUSR);
 module_param_named(gid, quota_list_gid, uint, S_IRUGO | S_IWUSR);
 
-
 #ifdef CONFIG_NETFILTER_XT_MATCH_QUOTA2_LOG
-static void quota2_log(unsigned int hooknum,
+static void quota2_log(struct net *net,
+		       unsigned int hooknum,
 		       const struct sk_buff *skb,
 		       const struct net_device *in,
 		       const struct net_device *out,
@@ -69,7 +100,7 @@ static void quota2_log(unsigned int hooknum,
 	struct sk_buff *log_skb;
 	size_t size;
 	struct nlmsghdr *nlh;
-
+	struct quota2_net *quota2_net = quota2_pernet(net);
 	if (!qlog_nl_event)
 		return;
 
@@ -105,13 +136,14 @@ static void quota2_log(unsigned int hooknum,
 
 	NETLINK_CB(log_skb).dst_group = 1;
 	pr_debug("throwing 1 packets to netlink group 1\n");
-	netlink_broadcast(nflognl, log_skb, 0, 1, GFP_ATOMIC);
+	netlink_broadcast(quota2_net->nflognl, log_skb, 0, 1, GFP_ATOMIC);
 
 nlmsg_failure:  /* Used within NLMSG_PUT() */
 	pr_debug("xt_quota2: error during NLMSG_PUT\n");
 }
 #else
-static void quota2_log(unsigned int hooknum,
+static void quota2_log(struct net *net,
+		       unsigned int hooknum,
 		       const struct sk_buff *skb,
 		       const struct net_device *in,
 		       const struct net_device *out,
@@ -177,11 +209,12 @@ q2_new_counter(const struct xt_quota_mtinfo2 *q, bool anon)
  * @name:	name of counter
  */
 static struct xt_quota_counter *
-q2_get_counter(const struct xt_quota_mtinfo2 *q)
+q2_get_counter(struct net *net, const struct xt_quota_mtinfo2 *q)
 {
 	struct proc_dir_entry *p;
 	struct xt_quota_counter *e = NULL;
 	struct xt_quota_counter *new_e;
+	struct quota2_net *quota2_net = quota2_pernet(net);
 
 	if (*q->name == '\0')
 		return q2_new_counter(q, true);
@@ -192,7 +225,7 @@ q2_get_counter(const struct xt_quota_mtinfo2 *q)
 		goto out;
 
 	spin_lock_bh(&counter_list_lock);
-	list_for_each_entry(e, &counter_list, list)
+	list_for_each_entry(e, &quota2_net->counter_list, list)
 		if (strcmp(e->name, q->name) == 0) {
 			atomic_inc(&e->ref);
 			spin_unlock_bh(&counter_list_lock);
@@ -202,7 +235,7 @@ q2_get_counter(const struct xt_quota_mtinfo2 *q)
 		}
 	e = new_e;
 	pr_debug("xt_quota2: new_counter name=%s", e->name);
-	list_add_tail(&e->list, &counter_list);
+	list_add_tail(&e->list, &quota2_net->counter_list);
 	/* The entry having a refcount of 1 is not directly destructible.
 	 * This func has not yet returned the new entry, thus iptables
 	 * has not references for destroying this entry.
@@ -214,7 +247,7 @@ q2_get_counter(const struct xt_quota_mtinfo2 *q)
 
 	/* create_proc_entry() is not spin_lock happy */
 	p = e->procfs_entry = create_proc_entry(e->name, quota_list_perms,
-	                      proc_xt_quota);
+	                      quota2_net->proc_xt_quota);
 
 	if (IS_ERR_OR_NULL(p)) {
 		spin_lock_bh(&counter_list_lock);
@@ -249,7 +282,7 @@ static int quota_mt2_check(const struct xt_mtchk_param *par)
 		return -EINVAL;
 	}
 
-	q->master = q2_get_counter(q);
+	q->master = q2_get_counter(par->net, q);
 	if (q->master == NULL) {
 		printk(KERN_ERR "xt_quota.3: memory alloc failure\n");
 		return -ENOMEM;
@@ -262,6 +295,7 @@ static void quota_mt2_destroy(const struct xt_mtdtor_param *par)
 {
 	struct xt_quota_mtinfo2 *q = par->matchinfo;
 	struct xt_quota_counter *e = q->master;
+	struct quota2_net *quota2_net = quota2_pernet(par->net);
 
 	if (*q->name == '\0') {
 		kfree(e);
@@ -275,7 +309,7 @@ static void quota_mt2_destroy(const struct xt_mtdtor_param *par)
 	}
 
 	list_del(&e->list);
-	remove_proc_entry(e->name, proc_xt_quota);
+	remove_proc_entry(e->name, quota2_net->proc_xt_quota);
 	spin_unlock_bh(&counter_list_lock);
 	kfree(e);
 }
@@ -305,7 +339,8 @@ quota_mt2(const struct sk_buff *skb, struct xt_action_param *par)
 		} else {
 			/* We are transitioning, log that fact. */
 			if (e->quota) {
-				quota2_log(par->hooknum,
+				quota2_log(pick_net(skb),
+					   par->hooknum,
 					   skb,
 					   par->in,
 					   par->out,
@@ -342,34 +377,76 @@ static struct xt_match quota_mt2_reg[] __read_mostly = {
 	},
 };
 
-static int __init quota_mt2_init(void)
+static int __net_init quota2_net_init(struct net *net)
 {
-	int ret;
-	pr_debug("xt_quota2: init()");
-
+	struct quota2_net *quota2_net = quota2_pernet(net);
+	INIT_LIST_HEAD(&quota2_net->counter_list);
 #ifdef CONFIG_NETFILTER_XT_MATCH_QUOTA2_LOG
-	nflognl = netlink_kernel_create(&init_net,
+	quota2_net->nflognl = netlink_kernel_create(net,
 					NETLINK_NFLOG, 1, NULL,
 					NULL, THIS_MODULE);
-	if (!nflognl)
+	if (quota2_net->nflognl == NULL)
 		return -ENOMEM;
 #endif
 
-	proc_xt_quota = proc_mkdir("xt_quota", init_net.proc_net);
-	if (proc_xt_quota == NULL)
+	quota2_net->proc_xt_quota = proc_mkdir("xt_quota", net->proc_net);
+	if (quota2_net->proc_xt_quota == NULL) {
+#ifdef CONFIG_NETFILTER_XT_MATCH_QUOTA2_LOG
+		netlink_kernel_release(quota2_net->nflognl);
+#endif
 		return -EACCES;
+	}
+	return 0;
+}
+
+static void __net_exit quota2_net_exit(struct net *net)
+{
+	struct quota2_net *quota2_net = quota2_pernet(net);
+	struct xt_quota_counter *e = NULL;
+	struct list_head *pos, *q;
+#ifdef CONFIG_NETFILTER_XT_MATCH_QUOTA2_LOG
+	netlink_kernel_release(quota2_net->nflognl);
+#endif
+	remove_proc_entry("xt_quota", net->proc_net);
+
+	/* destroy counter_list while freeing it's content */
+	spin_lock_bh(&counter_list_lock);
+	list_for_each_safe(pos, q, &quota2_net->counter_list) {
+		e = list_entry(pos, struct xt_quota_counter, list);
+		list_del(pos);
+		kfree(e);
+	}
+	spin_unlock_bh(&counter_list_lock);
+}
+
+static struct pernet_operations quota2_net_ops = {
+	.init   = quota2_net_init,
+	.exit   = quota2_net_exit,
+	.id     = &quota2_net_id,
+	.size   = sizeof(struct quota2_net),
+};
+
+static int __init quota_mt2_init(void)
+{
+	int ret;
+	pr_debug("xt_quota2: init()");
+
+	ret = register_pernet_subsys(&quota2_net_ops);
+	if (ret < 0)
+		return ret;
 
 	ret = xt_register_matches(quota_mt2_reg, ARRAY_SIZE(quota_mt2_reg));
 	if (ret < 0)
-		remove_proc_entry("xt_quota", init_net.proc_net);
+		unregister_pernet_subsys(&quota2_net_ops);
 	pr_debug("xt_quota2: init() %d", ret);
+
 	return ret;
 }
 
 static void __exit quota_mt2_exit(void)
 {
 	xt_unregister_matches(quota_mt2_reg, ARRAY_SIZE(quota_mt2_reg));
-	remove_proc_entry("xt_quota", init_net.proc_net);
+	unregister_pernet_subsys(&quota2_net_ops);
 }
 
 module_init(quota_mt2_init);
-- 
1.8.1.2
