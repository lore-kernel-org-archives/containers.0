From: Daniel Golle <dgolle-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v2] xt_quota2: introduce support for network namespaces
Date: Wed, 5 Mar 2014 12:07:56 +0100
Message-ID: <20140305110756.GA16910@earthship.local.cellrox.com>
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
To: Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>, jpa-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Initialize a separate xt_quota2 instance for each network
namespace so data limit can be set and enforced per container.
---
 extensions/xt_quota2.c | 85 ++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 72 insertions(+), 13 deletions(-)

diff --git a/extensions/xt_quota2.c b/extensions/xt_quota2.c
index 52c88a1..a216168 100644
--- a/extensions/xt_quota2.c
+++ b/extensions/xt_quota2.c
@@ -3,6 +3,8 @@
  * as a minimal accounting match.
  * by Jan Engelhardt , 2008
  *
+ * network namespace support added by Daniel Golle <dgolle-3AfRa/s5aFdBDgjK7y7TUQ@public.gmane.org> , 2014
+ *
  * Originally based on xt_quota.c:
  * 	Xtables module to enforce network quotas
  * 	Sam Johnston <samj-efmq+XrEd/4@public.gmane.org>
@@ -11,6 +13,12 @@
  *	it under the terms of the GNU General Public License
  *	version 2, as published by the Free Software Foundation.
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
@@ -37,10 +45,19 @@ struct xt_quota_counter {
 	struct proc_dir_entry *procfs_entry;
 };
 
-static LIST_HEAD(counter_list);
+struct quota2_net {
+	struct list_head counter_list;
+	struct proc_dir_entry *proc_xt_quota;
+};
+
+static int quota2_net_id;
+static inline struct quota2_net *quota2_pernet(struct net *net)
+{
+	return net_generic(net, quota2_net_id);
+}
+
 static DEFINE_SPINLOCK(counter_list_lock);
 
-static struct proc_dir_entry *proc_xt_quota;
 static unsigned int quota_list_perms = S_IRUGO | S_IWUSR;
 static unsigned int quota_list_uid   = 0;
 static unsigned int quota_list_gid   = 0;
@@ -120,16 +137,17 @@ q2_new_counter(const struct xt_quota_mtinfo2 *q, bool anon)
  * @name:	name of counter
  */
 static struct xt_quota_counter *
-q2_get_counter(const struct xt_quota_mtinfo2 *q)
+q2_get_counter(struct net *net, const struct xt_quota_mtinfo2 *q)
 {
 	struct proc_dir_entry *p;
 	struct xt_quota_counter *e;
+	struct quota2_net *quota2_net = quota2_pernet(net);
 
 	if (*q->name == '\0')
 		return q2_new_counter(q, true);
 
 	spin_lock_bh(&counter_list_lock);
-	list_for_each_entry(e, &counter_list, list)
+	list_for_each_entry(e, &quota2_net->counter_list, list)
 		if (strcmp(e->name, q->name) == 0) {
 			atomic_inc(&e->ref);
 			spin_unlock_bh(&counter_list_lock);
@@ -140,7 +158,8 @@ q2_get_counter(const struct xt_quota_mtinfo2 *q)
 	if (e == NULL)
 		goto out;
 
-	p = proc_create_data(e->name, quota_list_perms, proc_xt_quota,
+	p = proc_create_data(e->name, quota_list_perms,
+	                     quota2_net->proc_xt_quota,
 	                     &quota_proc_fops, e);
 	if (p == NULL || IS_ERR(p))
 		goto out;
@@ -148,7 +167,7 @@ q2_get_counter(const struct xt_quota_mtinfo2 *q)
 	e->procfs_entry = p;
 	proc_set_user(p, make_kuid(&init_user_ns, quota_list_uid),
 	              make_kgid(&init_user_ns, quota_list_gid));
-	list_add_tail(&e->list, &counter_list);
+	list_add_tail(&e->list, &quota2_net->counter_list);
 	spin_unlock_bh(&counter_list_lock);
 	return e;
 
@@ -171,7 +190,7 @@ static int quota_mt2_check(const struct xt_mtchk_param *par)
 		return -EINVAL;
 	}
 
-	q->master = q2_get_counter(q);
+	q->master = q2_get_counter(par->net, q);
 	if (q->master == NULL) {
 		printk(KERN_ERR "xt_quota.3: memory alloc failure\n");
 		return -ENOMEM;
@@ -184,6 +203,7 @@ static void quota_mt2_destroy(const struct xt_mtdtor_param *par)
 {
 	struct xt_quota_mtinfo2 *q = par->matchinfo;
 	struct xt_quota_counter *e = q->master;
+	struct quota2_net *quota2_net = quota2_pernet(par->net);
 
 	if (*q->name == '\0') {
 		kfree(e);
@@ -197,7 +217,7 @@ static void quota_mt2_destroy(const struct xt_mtdtor_param *par)
 	}
 
 	list_del(&e->list);
-	remove_proc_entry(e->name, proc_xt_quota);
+	remove_proc_entry(e->name, quota2_net->proc_xt_quota);
 	spin_unlock_bh(&counter_list_lock);
 	kfree(e);
 }
@@ -259,24 +279,63 @@ static struct xt_match quota_mt2_reg[] __read_mostly = {
 	},
 };
 
+static int __net_init quota2_net_init(struct net *net)
+{
+	struct quota2_net *quota2_net = quota2_pernet(net);
+	INIT_LIST_HEAD(&quota2_net->counter_list);
+
+	quota2_net->proc_xt_quota = proc_mkdir("xt_quota", net->proc_net);
+	if (quota2_net->proc_xt_quota == NULL)
+		return -EACCES;
+
+	return 0;
+}
+
+static void __net_exit quota2_net_exit(struct net *net)
+{
+	struct quota2_net *quota2_net = quota2_pernet(net);
+	struct xt_quota_counter *e = NULL;
+	struct list_head *pos, *q;
+
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
 static int __init quota_mt2_init(void)
 {
 	int ret;
+	pr_debug("xt_quota2: init()");
 
-	proc_xt_quota = proc_mkdir("xt_quota", init_net.proc_net);
-	if (proc_xt_quota == NULL)
-		return -EACCES;
+	ret = register_pernet_subsys(&quota2_net_ops);
+	if (ret < 0)
+		return ret;
 
 	ret = xt_register_matches(quota_mt2_reg, ARRAY_SIZE(quota_mt2_reg));
 	if (ret < 0)
-		remove_proc_entry("xt_quota", init_net.proc_net);
+		unregister_pernet_subsys(&quota2_net_ops);
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
1.9.0
