From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/9] netns ebtables: per-netns table list
Date: Fri, 1 Aug 2008 05:28:35 +0400
Message-ID: <20080801012835.GD26761@martell.zuzino.mipt.ru>
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
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 include/net/net_namespace.h     |    4 ++++
 include/net/netns/bridge.h      |    9 +++++++++
 net/bridge/netfilter/ebtables.c |    8 ++++----
 3 files changed, 17 insertions(+), 4 deletions(-)

--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -19,6 +19,7 @@
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netns/conntrack.h>
 #endif
+#include <net/netns/bridge.h>
 
 struct proc_dir_entry;
 struct net_device;
@@ -73,6 +74,9 @@ struct net {
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 	struct netns_ct		ct;
 #endif
+#ifdef CONFIG_BRIDGE_NETFILTER
+	struct netns_br		br;
+#endif
 #endif
 	struct net_generic	*gen;
 };
new file mode 100644
--- /dev/null
+++ b/include/net/netns/bridge.h
@@ -0,0 +1,9 @@
+#ifndef __NETNS_BRIDGE_H
+#define __NETNS_BRIDGE_H
+
+#include <linux/list.h>
+
+struct netns_br {
+	struct list_head	ebt_tables;
+};
+#endif
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -54,7 +54,6 @@
 
 
 static DEFINE_MUTEX(ebt_mutex);
-static LIST_HEAD(ebt_tables);
 static LIST_HEAD(ebt_targets);
 static LIST_HEAD(ebt_matches);
 static LIST_HEAD(ebt_watchers);
@@ -309,7 +308,7 @@ find_inlist_lock(struct list_head *head, const char *name, const char *prefix,
 static inline struct ebt_table *
 find_table_lock(const char *name, int *error, struct mutex *mutex)
 {
-	return find_inlist_lock(&ebt_tables, name, "ebtable_", error, mutex);
+	return find_inlist_lock(&init_net.br.ebt_tables, name, "ebtable_", error, mutex);
 }
 
 static inline struct ebt_match *
@@ -1209,7 +1208,7 @@ int ebt_register_table(struct ebt_table *table)
 	if (ret != 0)
 		goto free_chainstack;
 
-	list_for_each_entry(t, &ebt_tables, list) {
+	list_for_each_entry(t, &init_net.br.ebt_tables, list) {
 		if (strcmp(t->name, table->name) == 0) {
 			ret = -EEXIST;
 			BUGPRINT("Table name already exists\n");
@@ -1222,7 +1221,7 @@ int ebt_register_table(struct ebt_table *table)
 		ret = -ENOENT;
 		goto free_unlock;
 	}
-	list_add(&table->list, &ebt_tables);
+	list_add(&table->list, &init_net.br.ebt_tables);
 	mutex_unlock(&ebt_mutex);
 	return 0;
 free_unlock:
@@ -1523,6 +1522,7 @@ static int __init ebtables_init(void)
 	mutex_unlock(&ebt_mutex);
 	if ((ret = nf_register_sockopt(&ebt_sockopts)) < 0)
 		return ret;
+	INIT_LIST_HEAD(&init_net.br.ebt_tables);
 
 	printk(KERN_INFO "Ebtables v2.0 registered\n");
 	return 0;
-- 
1.5.4.5
