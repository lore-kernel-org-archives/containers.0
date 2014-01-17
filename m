From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/6] cgroup: make CONFIG_NET_CLS_CGROUP and
	CONFIG_NETPRIO_CGROUP bool instead of tristate
Date: Fri, 17 Jan 2014 13:11:52 -0500
Message-ID: <1389982317-22225-2-git-send-email-tj@kernel.org>
References: <1389982317-22225-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1389982317-22225-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

net_cls and net_prio are the only cgroups which are allowed to be
built as modules.  The savings from allowing the two controllers to be
built as modules are tiny especially given that cgroup module support
itself adds quite a bit of complexity.

The following are the sizes of vmlinux with both built as module and
both built as part of the kernel image with cgroup module support
removed.

	text		data		bss		dec
	20292207	2411496		10784768	33488471
	20293421	2412568		10784768	33490757

The total difference is 2286 bytes.  Given that none of other
controllers has much chance of being made a module and that we're
unlikely to add new modular controllers, the added complexity is
simply not justifiable.

As a first step to drop cgroup module support, this patch changes the
two config options to bool from tristate and drops module related code
from the two controllers.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/Kconfig               |  2 +-
 net/core/netprio_cgroup.c | 32 ++------------------------------
 net/sched/Kconfig         |  2 +-
 net/sched/cls_cgroup.c    | 23 ++---------------------
 4 files changed, 6 insertions(+), 53 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index d334678..fea7b88 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -239,7 +239,7 @@ config XPS
 	default y
 
 config NETPRIO_CGROUP
-	tristate "Network priority cgroup"
+	bool "Network priority cgroup"
 	depends on CGROUPS
 	---help---
 	  Cgroup subsystem for use in assigning processes to network priorities on
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 56cbb69..8912da7 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -283,37 +283,9 @@ static struct notifier_block netprio_device_notifier = {
 
 static int __init init_cgroup_netprio(void)
 {
-	int ret;
-
-	ret = cgroup_load_subsys(&net_prio_subsys);
-	if (ret)
-		goto out;
-
 	register_netdevice_notifier(&netprio_device_notifier);
-
-out:
-	return ret;
-}
-
-static void __exit exit_cgroup_netprio(void)
-{
-	struct netprio_map *old;
-	struct net_device *dev;
-
-	unregister_netdevice_notifier(&netprio_device_notifier);
-
-	cgroup_unload_subsys(&net_prio_subsys);
-
-	rtnl_lock();
-	for_each_netdev(&init_net, dev) {
-		old = rtnl_dereference(dev->priomap);
-		RCU_INIT_POINTER(dev->priomap, NULL);
-		if (old)
-			kfree_rcu(old, rcu);
-	}
-	rtnl_unlock();
+	return 0;
 }
 
-module_init(init_cgroup_netprio);
-module_exit(exit_cgroup_netprio);
+subsys_initcall(init_cgroup_netprio);
 MODULE_LICENSE("GPL v2");
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index ad1f1d8..0a9e4d1 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -433,7 +433,7 @@ config NET_CLS_FLOW
 	  module will be called cls_flow.
 
 config NET_CLS_CGROUP
-	tristate "Control Group Classifier"
+	bool "Control Group Classifier"
 	select NET_CLS
 	depends on CGROUPS
 	---help---
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 16006c9..2f6a9b4 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -309,27 +309,8 @@ static struct tcf_proto_ops cls_cgroup_ops __read_mostly = {
 
 static int __init init_cgroup_cls(void)
 {
-	int ret;
-
-	ret = cgroup_load_subsys(&net_cls_subsys);
-	if (ret)
-		goto out;
-
-	ret = register_tcf_proto_ops(&cls_cgroup_ops);
-	if (ret)
-		cgroup_unload_subsys(&net_cls_subsys);
-
-out:
-	return ret;
-}
-
-static void __exit exit_cgroup_cls(void)
-{
-	unregister_tcf_proto_ops(&cls_cgroup_ops);
-
-	cgroup_unload_subsys(&net_cls_subsys);
+	return register_tcf_proto_ops(&cls_cgroup_ops);
 }
 
-module_init(init_cgroup_cls);
-module_exit(exit_cgroup_cls);
+subsys_initcall(init_cgroup_cls);
 MODULE_LICENSE("GPL");
-- 
1.8.4.2
