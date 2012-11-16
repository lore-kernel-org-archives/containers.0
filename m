From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/8] netprio: simplify write_priomap()
Date: Fri, 16 Nov 2012 11:20:18 -0800
Message-ID: <1353093624-22608-3-git-send-email-tj@kernel.org>
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

sscanf() doesn't bite.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 net/core/netprio_cgroup.c | 56 ++++++++++-------------------------------------
 1 file changed, 11 insertions(+), 45 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index f0b6b0d..66d98da 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -176,66 +176,32 @@ static int read_priomap(struct cgroup *cont, struct cftype *cft,
 static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
 			 const char *buffer)
 {
-	char *devname = kstrdup(buffer, GFP_KERNEL);
-	int ret = -EINVAL;
 	u32 prioidx = cgrp_netprio_state(cgrp)->prioidx;
-	unsigned long priority;
-	char *priostr;
+	char devname[IFNAMSIZ + 1];
 	struct net_device *dev;
 	struct netprio_map *map;
+	u32 prio;
+	int ret;
 
-	if (!devname)
-		return -ENOMEM;
-
-	/*
-	 * Minimally sized valid priomap string
-	 */
-	if (strlen(devname) < 3)
-		goto out_free_devname;
-
-	priostr = strstr(devname, " ");
-	if (!priostr)
-		goto out_free_devname;
-
-	/*
-	 *Separate the devname from the associated priority
-	 *and advance the priostr pointer to the priority value
-	 */
-	*priostr = '\0';
-	priostr++;
-
-	/*
-	 * If the priostr points to NULL, we're at the end of the passed
-	 * in string, and its not a valid write
-	 */
-	if (*priostr == '\0')
-		goto out_free_devname;
-
-	ret = kstrtoul(priostr, 10, &priority);
-	if (ret < 0)
-		goto out_free_devname;
-
-	ret = -ENODEV;
+	if (sscanf(buffer, "%"__stringify(IFNAMSIZ)"s %u", devname, &prio) != 2)
+		return -EINVAL;
 
 	dev = dev_get_by_name(&init_net, devname);
 	if (!dev)
-		goto out_free_devname;
+		return -ENODEV;
 
 	rtnl_lock();
+
 	ret = write_update_netdev_table(dev);
-	if (ret < 0)
-		goto out_put_dev;
+	if (ret)
+		goto out_unlock;
 
 	map = rtnl_dereference(dev->priomap);
 	if (map)
-		map->priomap[prioidx] = priority;
-
-out_put_dev:
+		map->priomap[prioidx] = prio;
+out_unlock:
 	rtnl_unlock();
 	dev_put(dev);
-
-out_free_devname:
-	kfree(devname);
 	return ret;
 }
 
-- 
1.7.11.7
