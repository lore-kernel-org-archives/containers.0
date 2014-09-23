From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: [RFC PATCH net-next v2 4/5] iptunnels: advertise link netns via
	netlink
Date: Tue, 23 Sep 2014 15:20:29 +0200
Message-ID: <1411478430-4989-5-git-send-email-nicolas.dichtel__26830.6375401609$1411478507$gmane$org@6wind.com>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1411478430-4989-1-git-send-email-nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Implement rtnl_link_ops->get_link_net() callback so that IFLA_LINK_NETNSID is
added to rtnetlink messages.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
---
 include/net/ip_tunnels.h | 1 +
 net/ipv4/ip_gre.c        | 2 ++
 net/ipv4/ip_tunnel.c     | 8 ++++++++
 net/ipv4/ip_vti.c        | 1 +
 net/ipv4/ipip.c          | 1 +
 net/ipv6/sit.c           | 1 +
 6 files changed, 14 insertions(+)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 7f538ba6e267..c92a99b5b77e 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -119,6 +119,7 @@ struct ip_tunnel_net {
 int ip_tunnel_init(struct net_device *dev);
 void ip_tunnel_uninit(struct net_device *dev);
 void  ip_tunnel_dellink(struct net_device *dev, struct list_head *head);
+struct net *ip_tunnel_get_link_net(const struct net_device *dev);
 int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 		       struct rtnl_link_ops *ops, char *devname);
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 829aff8bf723..05157427d8f0 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -825,6 +825,7 @@ static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
 	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipgre_get_size,
 	.fill_info	= ipgre_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
@@ -839,6 +840,7 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipgre_get_size,
 	.fill_info	= ipgre_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static int __net_init ipgre_tap_init_net(struct net *net)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index e3a3dc91e49c..da5a2b6fed81 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -954,6 +954,14 @@ void ip_tunnel_dellink(struct net_device *dev, struct list_head *head)
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_dellink);
 
+struct net *ip_tunnel_get_link_net(const struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+
+	return tunnel->net;
+}
+EXPORT_SYMBOL(ip_tunnel_get_link_net);
+
 int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
 				  struct rtnl_link_ops *ops, char *devname)
 {
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index e453cb724a95..93862411669c 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -530,6 +530,7 @@ static struct rtnl_link_ops vti_link_ops __read_mostly = {
 	.changelink	= vti_changelink,
 	.get_size	= vti_get_size,
 	.fill_info	= vti_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static int __init vti_init(void)
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index bfec31df8b21..fd423e65d6df 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -496,6 +496,7 @@ static struct rtnl_link_ops ipip_link_ops __read_mostly = {
 	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipip_get_size,
 	.fill_info	= ipip_fill_info,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static struct xfrm_tunnel ipip_handler __read_mostly = {
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index db75809ab843..5c227cc13170 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1761,6 +1761,7 @@ static struct rtnl_link_ops sit_link_ops __read_mostly = {
 	.get_size	= ipip6_get_size,
 	.fill_info	= ipip6_fill_info,
 	.dellink	= ipip6_dellink,
+	.get_link_net	= ip_tunnel_get_link_net,
 };
 
 static struct xfrm_tunnel sit_handler __read_mostly = {
-- 
2.1.0
