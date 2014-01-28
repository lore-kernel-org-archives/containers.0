From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/6] cgroup: make CONFIG_CGROUP_NET_PRIO bool and drop
	unnecessary init_netclassid_cgroup()
Date: Tue, 28 Jan 2014 18:43:56 -0500
Message-ID: <1390952641-15950-2-git-send-email-tj@kernel.org>
References: <1390952641-15950-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1390952641-15950-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
List-Id: containers.vger.kernel.org

net_prio is the only cgroup which is allowed to be built as a module.
The savings from allowing one controller to be built as a module are
tiny especially given that cgroup module support itself adds quite a
bit of complexity.

Given that none of other controllers has much chance of being made a
module and that we're unlikely to add new modular controllers, the
added complexity is simply not justifiable.

As a first step to drop cgroup module support, this patch changes the
config option to bool from tristate and drops module related code from
it.

Also, while an earlier commit fe1217c4f3f7 ("net: net_cls: move
cgroupfs classid handling into core") dropped module support from
net_cls cgroup, it retained a call to cgroup_load_subsys(), which is
noop for built-in controllers.  Drop it along with
init_netclassid_cgroup().

v2: Removed modular version of task_netprioidx() in
    include/net/netprio_cgroup.h as suggested by Li Zefan.

v3: Rebased on top of fe1217c4f3f7 ("net: net_cls: move cgroupfs
    classid handling into core").  net_cls cgroup part is mostly
    dropped except for removal of init_netclassid_cgroup().

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Acked-by: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/net/netprio_cgroup.h | 15 ---------------
 net/Kconfig                  |  2 +-
 net/core/netclassid_cgroup.c |  6 ------
 net/core/netprio_cgroup.c    | 32 ++------------------------------
 4 files changed, 3 insertions(+), 52 deletions(-)

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index dafc09f..b7ff5bd 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -27,7 +27,6 @@ struct netprio_map {
 
 void sock_update_netprioidx(struct sock *sk);
 
-#if IS_BUILTIN(CONFIG_CGROUP_NET_PRIO)
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	struct cgroup_subsys_state *css;
@@ -39,20 +38,6 @@ static inline u32 task_netprioidx(struct task_struct *p)
 	rcu_read_unlock();
 	return idx;
 }
-#elif IS_MODULE(CONFIG_CGROUP_NET_PRIO)
-static inline u32 task_netprioidx(struct task_struct *p)
-{
-	struct cgroup_subsys_state *css;
-	u32 idx = 0;
-
-	rcu_read_lock();
-	css = task_css(p, net_prio_subsys_id);
-	if (css)
-		idx = css->cgroup->id;
-	rcu_read_unlock();
-	return idx;
-}
-#endif
 #else /* !CONFIG_CGROUP_NET_PRIO */
 static inline u32 task_netprioidx(struct task_struct *p)
 {
diff --git a/net/Kconfig b/net/Kconfig
index e411046..a83bc4c 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -239,7 +239,7 @@ config XPS
 	default y
 
 config CGROUP_NET_PRIO
-	tristate "Network priority cgroup"
+	bool "Network priority cgroup"
 	depends on CGROUPS
 	---help---
 	  Cgroup subsystem for use in assigning processes to network priorities on
diff --git a/net/core/netclassid_cgroup.c b/net/core/netclassid_cgroup.c
index 719efd5..9fc7f90 100644
--- a/net/core/netclassid_cgroup.c
+++ b/net/core/netclassid_cgroup.c
@@ -112,9 +112,3 @@ struct cgroup_subsys net_cls_subsys = {
 	.base_cftypes		= ss_files,
 	.module			= THIS_MODULE,
 };
-
-static int __init init_netclassid_cgroup(void)
-{
-	return cgroup_load_subsys(&net_cls_subsys);
-}
-__initcall(init_netclassid_cgroup);
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 9043cae..cc3a31e 100644
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
-- 
1.8.5.3
