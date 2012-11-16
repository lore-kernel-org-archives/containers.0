From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 7/8] netprio_cgroup: keep track of whether prio is set or not
Date: Fri, 16 Nov 2012 11:20:23 -0800
Message-ID: <1353093624-22608-8-git-send-email-tj__919.137933715497$1353093690$gmane$org@kernel.org>
References: <1353093624-22608-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353093624-22608-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, srivatsa.bhat-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

netprio_cgroup keeps prio config per cgroup-netdev pair and doesn't
distinguish between unconfigured and explicit 0 priority.  To
implement hierarchy support, it's necessary to know whether a given
pair has explicit configuration or not.

This patch adds netprio_map->aux[] which is indexed by cgroup->id and
currently only contains one bool - is_local.  netprio[_set]_prio() is
updated to handle @is_local.  is_local is set iff the pair has
explicit config.  write_priomap() now clears is_local if a negative
value is written and sets on positive.  With cgrp_css_free() also
updated to clear it, is_local is set for a cgroup-netdev pair iff the
pair is online and a positive prio has been configured via
"net_prio.ifpriomap".

is_local is visible to userland via cgroup file "net_prio.is_local".

This currently doesn't change any behavior.  It will be used to
implement hierarchy support.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/net/netprio_cgroup.h | 10 +++++
 net/core/netprio_cgroup.c    | 94 ++++++++++++++++++++++++++++++++++----------
 2 files changed, 83 insertions(+), 21 deletions(-)

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index 1d04b6f..bd3daf8 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -19,8 +19,18 @@
 
 
 #if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
+
+/*
+ * Auxliary per-cgroup-netdev configuration.  Kept separate from priomap[]
+ * so that priomap[] has better spatial locality.
+ */
+struct netprio_aux {
+	bool		is_local:1;	/* cgroup has priority configured */
+};
+
 struct netprio_map {
 	struct rcu_head rcu;
+	struct netprio_aux *aux;	/* auxiliary config array */
 	u32 priomap_len;
 	u32 priomap[];
 };
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index b2af0d0..e7a5b03 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -35,6 +35,14 @@ static inline struct cgroup_netprio_state *cgrp_netprio_state(struct cgroup *cgr
 			    struct cgroup_netprio_state, css);
 }
 
+static void free_netprio_map(struct netprio_map *map)
+{
+	if (map) {
+		kfree(map->aux);
+		kfree_rcu(map, rcu);
+	}
+}
+
 /*
  * Extend @dev->priomap so that it's large enough to accomodate
  * @target_idx.  @dev->priomap.priomap_len > @target_idx after successful
@@ -69,38 +77,55 @@ static int extend_netdev_table(struct net_device *dev, u32 target_idx)
 
 	/* allocate & copy */
 	new = kzalloc(new_sz, GFP_KERNEL);
-	if (!new) {
-		pr_warn("Unable to alloc new priomap!\n");
-		return -ENOMEM;
-	}
+	if (!new)
+		goto enomem;
+
+	new->aux = kzalloc(new_len * sizeof(new->aux[0]), GFP_KERNEL);
+	if (!new->aux)
+		goto enomem;
 
-	if (old)
+	if (old) {
 		memcpy(new->priomap, old->priomap,
 		       old->priomap_len * sizeof(old->priomap[0]));
+		memcpy(new->aux, old->aux,
+		       old->priomap_len * sizeof(old->aux[0]));
+	}
 
 	new->priomap_len = new_len;
 
 	/* install the new priomap */
 	rcu_assign_pointer(dev->priomap, new);
-	if (old)
-		kfree_rcu(old, rcu);
+	free_netprio_map(old);
 	return 0;
+
+enomem:
+	free_netprio_map(new);
+	pr_warn("Unable to alloc new priomap!\n");
+	return -ENOMEM;
 }
 
 /**
  * netprio_prio - return the effective netprio of a cgroup-net_device pair
  * @cgrp: cgroup part of the target pair
  * @dev: net_device part of the target pair
+ * @is_local_p: optional out param, %true if @cgrp-@dev has local config
  *
  * Should be called under RCU read or rtnl lock.
  */
-static u32 netprio_prio(struct cgroup *cgrp, struct net_device *dev)
+static u32 netprio_prio(struct cgroup *cgrp, struct net_device *dev,
+			bool *is_local_p)
 {
 	struct netprio_map *map = rcu_dereference_rtnl(dev->priomap);
+	bool is_local = false;
+	u32 prio = 0;
 
-	if (map && cgrp->id < map->priomap_len)
-		return map->priomap[cgrp->id];
-	return 0;
+	if (map && cgrp->id < map->priomap_len) {
+		is_local = map->aux[cgrp->id].is_local;
+		prio = map->priomap[cgrp->id];
+	}
+	if (is_local_p)
+		*is_local_p = is_local;
+	return prio;
 }
 
 /**
@@ -108,19 +133,20 @@ static u32 netprio_prio(struct cgroup *cgrp, struct net_device *dev)
  * @cgrp: cgroup part of the target pair
  * @dev: net_device part of the target pair
  * @prio: prio to set
+ * @is_local: indicates whether @prio is @cgrp's local prio configuration
  *
  * Set netprio to @prio on @cgrp-@dev pair.  Should be called under rtnl
- * lock and may fail under memory pressure for non-zero @prio.
+ * lock and may fail under memory pressure if (@prio || @is_local).
  */
 static int netprio_set_prio(struct cgroup *cgrp, struct net_device *dev,
-			    u32 prio)
+			    u32 prio, bool is_local)
 {
 	struct netprio_map *map;
 	int ret;
 
-	/* avoid extending priomap for zero writes */
+	/* avoid extending priomap for clearing zero writes */
 	map = rtnl_dereference(dev->priomap);
-	if (!prio && (!map || map->priomap_len <= cgrp->id))
+	if (!is_local && !prio && (!map || map->priomap_len <= cgrp->id))
 		return 0;
 
 	ret = extend_netdev_table(dev, cgrp->id);
@@ -128,6 +154,7 @@ static int netprio_set_prio(struct cgroup *cgrp, struct net_device *dev,
 		return ret;
 
 	map = rtnl_dereference(dev->priomap);
+	map->aux[cgrp->id].is_local = is_local;
 	map->priomap[cgrp->id] = prio;
 	return 0;
 }
@@ -153,7 +180,7 @@ static void cgrp_css_free(struct cgroup *cgrp)
 
 	rtnl_lock();
 	for_each_netdev(&init_net, dev)
-		WARN_ON_ONCE(netprio_set_prio(cgrp, dev, 0));
+		WARN_ON_ONCE(netprio_set_prio(cgrp, dev, 0, false));
 	rtnl_unlock();
 	kfree(cs);
 }
@@ -170,7 +197,7 @@ static int read_priomap(struct cgroup *cont, struct cftype *cft,
 
 	rcu_read_lock();
 	for_each_netdev_rcu(&init_net, dev)
-		cb->fill(cb, dev->name, netprio_prio(cont, dev));
+		cb->fill(cb, dev->name, netprio_prio(cont, dev, NULL));
 	rcu_read_unlock();
 	return 0;
 }
@@ -180,25 +207,46 @@ static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
 {
 	char devname[IFNAMSIZ + 1];
 	struct net_device *dev;
+	s64 v;
 	u32 prio;
+	bool is_local;
 	int ret;
 
-	if (sscanf(buffer, "%"__stringify(IFNAMSIZ)"s %u", devname, &prio) != 2)
+	if (sscanf(buffer, "%"__stringify(IFNAMSIZ)"s %lld", devname, &v) != 2)
 		return -EINVAL;
 
+	prio = clamp_val(v, 0, UINT_MAX);
+	is_local = v >= 0;
+
 	dev = dev_get_by_name(&init_net, devname);
 	if (!dev)
 		return -ENODEV;
 
 	rtnl_lock();
 
-	ret = netprio_set_prio(cgrp, dev, prio);
+	ret = netprio_set_prio(cgrp, dev, prio, is_local);
 
 	rtnl_unlock();
 	dev_put(dev);
 	return ret;
 }
 
+static int netprio_read_is_local(struct cgroup *cont, struct cftype *cft,
+				 struct seq_file *m)
+{
+	struct net_device *dev;
+
+	rtnl_lock();
+	for_each_netdev(&init_net, dev) {
+		bool is_local;
+
+		netprio_prio(cont, dev, &is_local);
+		seq_printf(m, "%s %d\n", dev->name, is_local);
+	}
+	rtnl_unlock();
+	return 0;
+}
+
 static int update_netprio(const void *v, struct file *file, unsigned n)
 {
 	int err;
@@ -231,6 +279,10 @@ static struct cftype ss_files[] = {
 		.read_map = read_priomap,
 		.write_string = write_priomap,
 	},
+	{
+		.name = "is_local",
+		.read_seq_string = netprio_read_is_local,
+	},
 	{ }	/* terminate */
 };
 
@@ -270,7 +322,7 @@ static int netprio_device_event(struct notifier_block *unused,
 		old = rtnl_dereference(dev->priomap);
 		RCU_INIT_POINTER(dev->priomap, NULL);
 		if (old)
-			kfree_rcu(old, rcu);
+			free_netprio_map(old);
 		break;
 	}
 	return NOTIFY_DONE;
@@ -308,7 +360,7 @@ static void __exit exit_cgroup_netprio(void)
 		old = rtnl_dereference(dev->priomap);
 		RCU_INIT_POINTER(dev->priomap, NULL);
 		if (old)
-			kfree_rcu(old, rcu);
+			free_netprio_map(old);
 	}
 	rtnl_unlock();
 }
-- 
1.7.11.7
