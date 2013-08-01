From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 03/23] netprio_cgroup: pass around @css instead of @cgroup and
	kill struct cgroup_netprio_state
Date: Thu,  1 Aug 2013 17:49:41 -0400
Message-ID: <1375393801-4817-4-git-send-email-tj@kernel.org>
References: <1375393801-4817-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1375393801-4817-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

cgroup controller API will be converted to primarily use struct
cgroup_subsys_state instead of struct cgroup.  In preparation, make
the internal functions of netprio_cgroup pass around @css instead of
@cgrp.

While at it, kill struct cgroup_netprio_state which only contained
struct cgroup_subsys_state without serving any purpose.  All functions
are converted to deal with @css directly.

This patch shouldn't cause any behavior differences.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 include/net/netprio_cgroup.h |  4 ----
 net/core/netprio_cgroup.c    | 56 ++++++++++++++++++++++----------------------
 2 files changed, 28 insertions(+), 32 deletions(-)

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index 8110fa7..a24f8bb 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -25,10 +25,6 @@ struct netprio_map {
 	u32 priomap[];
 };
 
-struct cgroup_netprio_state {
-	struct cgroup_subsys_state css;
-};
-
 extern void sock_update_netprioidx(struct sock *sk);
 
 #if IS_BUILTIN(CONFIG_NETPRIO_CGROUP)
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index ccf8523..5dfac88 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -29,12 +29,6 @@
 
 #define PRIOMAP_MIN_SZ		128
 
-static inline struct cgroup_netprio_state *cgrp_netprio_state(struct cgroup *cgrp)
-{
-	return container_of(cgroup_css(cgrp, net_prio_subsys_id),
-			    struct cgroup_netprio_state, css);
-}
-
 /*
  * Extend @dev->priomap so that it's large enough to accomodate
  * @target_idx.  @dev->priomap.priomap_len > @target_idx after successful
@@ -87,68 +81,72 @@ static int extend_netdev_table(struct net_device *dev, u32 target_idx)
 
 /**
  * netprio_prio - return the effective netprio of a cgroup-net_device pair
- * @cgrp: cgroup part of the target pair
+ * @css: css part of the target pair
  * @dev: net_device part of the target pair
  *
  * Should be called under RCU read or rtnl lock.
  */
-static u32 netprio_prio(struct cgroup *cgrp, struct net_device *dev)
+static u32 netprio_prio(struct cgroup_subsys_state *css, struct net_device *dev)
 {
 	struct netprio_map *map = rcu_dereference_rtnl(dev->priomap);
+	int id = css->cgroup->id;
 
-	if (map && cgrp->id < map->priomap_len)
-		return map->priomap[cgrp->id];
+	if (map && id < map->priomap_len)
+		return map->priomap[id];
 	return 0;
 }
 
 /**
  * netprio_set_prio - set netprio on a cgroup-net_device pair
- * @cgrp: cgroup part of the target pair
+ * @css: css part of the target pair
  * @dev: net_device part of the target pair
  * @prio: prio to set
  *
- * Set netprio to @prio on @cgrp-@dev pair.  Should be called under rtnl
+ * Set netprio to @prio on @css-@dev pair.  Should be called under rtnl
  * lock and may fail under memory pressure for non-zero @prio.
  */
-static int netprio_set_prio(struct cgroup *cgrp, struct net_device *dev,
-			    u32 prio)
+static int netprio_set_prio(struct cgroup_subsys_state *css,
+			    struct net_device *dev, u32 prio)
 {
 	struct netprio_map *map;
+	int id = css->cgroup->id;
 	int ret;
 
 	/* avoid extending priomap for zero writes */
 	map = rtnl_dereference(dev->priomap);
-	if (!prio && (!map || map->priomap_len <= cgrp->id))
+	if (!prio && (!map || map->priomap_len <= id))
 		return 0;
 
-	ret = extend_netdev_table(dev, cgrp->id);
+	ret = extend_netdev_table(dev, id);
 	if (ret)
 		return ret;
 
 	map = rtnl_dereference(dev->priomap);
-	map->priomap[cgrp->id] = prio;
+	map->priomap[id] = prio;
 	return 0;
 }
 
 static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
 {
-	struct cgroup_netprio_state *cs;
+	struct cgroup_subsys_state *css;
 
-	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
-	if (!cs)
+	css = kzalloc(sizeof(*css), GFP_KERNEL);
+	if (!css)
 		return ERR_PTR(-ENOMEM);
 
-	return &cs->css;
+	return css;
 }
 
 static int cgrp_css_online(struct cgroup *cgrp)
 {
-	struct cgroup *parent = cgrp->parent;
+	struct cgroup_subsys_state *css = cgroup_css(cgrp, net_prio_subsys_id);
+	struct cgroup_subsys_state *parent_css;
 	struct net_device *dev;
 	int ret = 0;
 
-	if (!parent)
+	if (!cgrp->parent)
 		return 0;
+	parent_css = cgroup_css(cgrp->parent, net_prio_subsys_id);
 
 	rtnl_lock();
 	/*
@@ -156,9 +154,9 @@ static int cgrp_css_online(struct cgroup *cgrp)
 	 * onlining, there is no need to clear them on offline.
 	 */
 	for_each_netdev(&init_net, dev) {
-		u32 prio = netprio_prio(parent, dev);
+		u32 prio = netprio_prio(parent_css, dev);
 
-		ret = netprio_set_prio(cgrp, dev, prio);
+		ret = netprio_set_prio(css, dev, prio);
 		if (ret)
 			break;
 	}
@@ -168,7 +166,7 @@ static int cgrp_css_online(struct cgroup *cgrp)
 
 static void cgrp_css_free(struct cgroup *cgrp)
 {
-	kfree(cgrp_netprio_state(cgrp));
+	kfree(cgroup_css(cgrp, net_prio_subsys_id));
 }
 
 static u64 read_prioidx(struct cgroup *cgrp, struct cftype *cft)
@@ -179,11 +177,12 @@ static u64 read_prioidx(struct cgroup *cgrp, struct cftype *cft)
 static int read_priomap(struct cgroup *cont, struct cftype *cft,
 			struct cgroup_map_cb *cb)
 {
+	struct cgroup_subsys_state *css = cgroup_css(cont, net_prio_subsys_id);
 	struct net_device *dev;
 
 	rcu_read_lock();
 	for_each_netdev_rcu(&init_net, dev)
-		cb->fill(cb, dev->name, netprio_prio(cont, dev));
+		cb->fill(cb, dev->name, netprio_prio(css, dev));
 	rcu_read_unlock();
 	return 0;
 }
@@ -191,6 +190,7 @@ static int read_priomap(struct cgroup *cont, struct cftype *cft,
 static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
 			 const char *buffer)
 {
+	struct cgroup_subsys_state *css = cgroup_css(cgrp, net_prio_subsys_id);
 	char devname[IFNAMSIZ + 1];
 	struct net_device *dev;
 	u32 prio;
@@ -205,7 +205,7 @@ static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
 
 	rtnl_lock();
 
-	ret = netprio_set_prio(cgrp, dev, prio);
+	ret = netprio_set_prio(css, dev, prio);
 
 	rtnl_unlock();
 	dev_put(dev);
-- 
1.8.3.1
