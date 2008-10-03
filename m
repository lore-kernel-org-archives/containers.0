From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH] net: Support specifying the network namespace upon device
	creation.
Date: Thu, 02 Oct 2008 17:46:55 -0700
Message-ID: <m1vdwatshs.fsf@frodo.ebiederm.org>
References: <m18wt6v7eb.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m18wt6v7eb.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org> (Eric W. Biederman's message
	of "Thu, 02 Oct 2008 17:39:40 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org


There is no good reason to not support userspace specifying the
network namespace during device creation and it seems a handy
thing to do.

We have to be a little extra careful in this case to ensure that
the network namespace exists through the point where we call
register_netdevice.

In addition we need to pass the network namespace to the
rtnl_link_ops.newlink method so we can properly create
the new device in another namespace and have it be a vlan
device of a device in our current network namespace.

In summary this patch makes ip link add somename netns NNN type sometype
do the obvious thing instead of ignoring the network namespace parameter.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/macvlan.c    |    4 ++--
 drivers/net/veth.c       |    5 +++--
 include/net/rtnetlink.h  |    3 ++-
 net/8021q/vlan_netlink.c |    4 ++--
 net/core/rtnetlink.c     |   17 ++++++++++++++++-
 5 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 4239450..fc5933b 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -416,7 +416,7 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
-static int macvlan_newlink(struct net_device *dev,
+static int macvlan_newlink(struct net *net, struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
@@ -427,7 +427,7 @@ static int macvlan_newlink(struct net_device *dev,
 	if (!tb[IFLA_LINK])
 		return -EINVAL;
 
-	lowerdev = __dev_get_by_index(dev_net(dev), nla_get_u32(tb[IFLA_LINK]));
+	lowerdev = __dev_get_by_index(net, nla_get_u32(tb[IFLA_LINK]));
 	if (lowerdev == NULL)
 		return -ENODEV;
 
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 31cd817..3a2d818 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -335,7 +335,7 @@ static int veth_validate(struct nlattr *tb[], struct nlattr *data[])
 
 static struct rtnl_link_ops veth_link_ops;
 
-static int veth_newlink(struct net_device *dev,
+static int veth_newlink(struct net *net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
 	int err;
@@ -375,7 +375,7 @@ static int veth_newlink(struct net_device *dev,
 	else
 		snprintf(ifname, IFNAMSIZ, DRV_NAME "%%d");
 
-	peer = rtnl_create_link(dev_net(dev), ifname, &veth_link_ops, tbp);
+	peer = rtnl_create_link(net, ifname, &veth_link_ops, tbp);
 	if (IS_ERR(peer))
 		return PTR_ERR(peer);
 
@@ -383,6 +383,7 @@ static int veth_newlink(struct net_device *dev,
 		random_ether_addr(peer->dev_addr);
 
 	err = register_netdevice(peer);
+	put_net(peer->nd_net);
 	if (err < 0)
 		goto err_register_peer;
 
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 3c1895e..dbf546f 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -55,7 +55,8 @@ struct rtnl_link_ops {
 	int			(*validate)(struct nlattr *tb[],
 					    struct nlattr *data[]);
 
-	int			(*newlink)(struct net_device *dev,
+	int			(*newlink)(struct net *net,
+					   struct net_device *dev,
 					   struct nlattr *tb[],
 					   struct nlattr *data[]);
 	int			(*changelink)(struct net_device *dev,
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index e9c91dc..e6190f7 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -100,7 +100,7 @@ static int vlan_changelink(struct net_device *dev,
 	return 0;
 }
 
-static int vlan_newlink(struct net_device *dev,
+static int vlan_newlink(struct net *net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
@@ -112,7 +112,7 @@ static int vlan_newlink(struct net_device *dev,
 
 	if (!tb[IFLA_LINK])
 		return -EINVAL;
-	real_dev = __dev_get_by_index(dev_net(dev), nla_get_u32(tb[IFLA_LINK]));
+	real_dev = __dev_get_by_index(net, nla_get_u32(tb[IFLA_LINK]));
 	if (!real_dev)
 		return -ENODEV;
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 8862498..069b176 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1002,6 +1002,19 @@ struct net_device *rtnl_create_link(struct net *net, char *ifname,
 			goto err_free;
 	}
 
+	/* To support userspace specifying a network namespace during
+	 * device creation we grab the network namespace here and hold
+	 * it until just after register_netdevice to prevent races.
+	 */
+	if (!tb[IFLA_NET_NS_PID])
+		get_net(net);
+	else {
+		net = get_net_ns_by_pid(nla_get_u32(tb[IFLA_NET_NS_PID]));
+		if (IS_ERR(net)) {
+			err = PTR_ERR(net);
+			goto err_free;
+		}
+	}
 	dev_net_set(dev, net);
 	dev->rtnl_link_ops = ops;
 
@@ -1150,10 +1163,12 @@ replay:
 		if (IS_ERR(dev))
 			err = PTR_ERR(dev);
 		else if (ops->newlink)
-			err = ops->newlink(dev, tb, data);
+			err = ops->newlink(net, dev, tb, data);
 		else
 			err = register_netdevice(dev);
 
+		if (!IS_ERR(dev))
+			put_net(dev->nd_net);
 		if (err < 0 && !IS_ERR(dev))
 			free_netdev(dev);
 		return err;
-- 
1.5.3.rc6.17.g1911
