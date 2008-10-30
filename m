From: Vivien Chappelier <vivien.chappelier-L+G57L1VLRbR7s880joybQ@public.gmane.org>
Subject: [PATCH 5/6] netlink: add IFLA_NET_NS to move interface to network
	namespace by nsid
Date: Thu, 30 Oct 2008 14:10:14 +0100
Message-ID: <20081030131014.GE17665@thomson.net>
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

This corresponds exactly to IFLA_NET_NS_PID except it takes a nsid parameter instead of a pid.
---
 include/linux/if_link.h |    1 +
 net/core/rtnetlink.c    |   16 ++++++++++++++++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f9032c8..9e473eb 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -80,6 +80,7 @@ enum
 #define IFLA_LINKINFO IFLA_LINKINFO
 	IFLA_NET_NS_PID,
 	IFLA_IFALIAS,
+	IFLA_NET_NS,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 31f29d2..3e90c0b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -718,6 +718,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_LINKINFO]		= { .type = NLA_NESTED },
 	[IFLA_NET_NS_PID]	= { .type = NLA_U32 },
 	[IFLA_IFALIAS]	        = { .type = NLA_STRING, .len = IFALIASZ-1 },
+	[IFLA_NET_NS]		= { .type = NLA_U32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -779,6 +780,21 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		modified = 1;
 	}
 
+	if (tb[IFLA_NET_NS]) {
+		struct net *net;
+
+		net = __get_net_ns_by_id(nla_get_u32(tb[IFLA_NET_NS]));
+		if (net == NULL) {
+			err = -EINVAL;
+			goto errout;
+		}
+		err = dev_change_net_namespace(dev, net, ifname);
+		put_net(net);
+		if (err)
+			goto errout;
+		modified = 1;
+	}
+
 	if (tb[IFLA_MAP]) {
 		struct rtnl_link_ifmap *u_map;
 		struct ifmap k_map;
-- 
1.5.4.4
