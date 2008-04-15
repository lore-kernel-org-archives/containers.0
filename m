From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 6/8 net-2.6.26] [NETNS]: Add netns refcnt debug for dst ops.
Date: Tue, 15 Apr 2008 16:37:53 +0400
Message-ID: <1208263075-28016-6-git-send-email-den@openvz.org>
References: <1208262959.21529.32.camel@iris.sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1208262959.21529.32.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, dlezcano@fr.ibm.com, "Denis V. Lunev" <den@openvz.org>
List-Id: containers.vger.kernel.org

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv6/route.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6293cb9..210a079 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2622,7 +2622,7 @@ static int ip6_route_net_init(struct net *net)
 					GFP_KERNEL);
 	if (!net->ipv6.ip6_dst_ops)
 		goto out;
-	net->ipv6.ip6_dst_ops->dst_net = net;
+	net->ipv6.ip6_dst_ops->dst_net = hold_net(net);
 
 	net->ipv6.ip6_null_entry = kmemdup(&ip6_null_entry_template,
 					   sizeof(*net->ipv6.ip6_null_entry),
@@ -2669,6 +2669,7 @@ out:
 	return ret;
 
 out_ip6_dst_ops:
+	release_net(net->ipv6.ip6_dst_ops->dst_net);
 	kfree(net->ipv6.ip6_dst_ops);
 	goto out;
 }
@@ -2684,6 +2685,7 @@ static void ip6_route_net_exit(struct net *net)
 	kfree(net->ipv6.ip6_prohibit_entry);
 	kfree(net->ipv6.ip6_blk_hole_entry);
 #endif
+	release_net(net->ipv6.ip6_dst_ops->dst_net);
 	kfree(net->ipv6.ip6_dst_ops);
 }
 
-- 
1.5.3.rc5

