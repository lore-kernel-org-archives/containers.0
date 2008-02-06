From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 5/17] [NETNS]: Register neighbour parameters of the net device in the correct namespace.
Date: Wed,  6 Feb 2008 13:53:25 +0300
Message-ID: <1202295217-22769-5-git-send-email-den@openvz.org>
References: <47A99196.2030105@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <47A99196.2030105@sw.ru>
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
List-Id: containers.vger.kernel.org

neigh_sysctl_register should register sysctl entries inside correct namespace
to avoid naming conflict. Typical example is a loopback. Entries for it
present in all namespaces.

Required to make inetdev_event working.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/core/neighbour.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index a16cf1e..1ed7b0a 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2738,7 +2738,8 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	neigh_path[NEIGH_CTL_PATH_PROTO].procname = p_name;
 	neigh_path[NEIGH_CTL_PATH_PROTO].ctl_name = p_id;
 
-	t->sysctl_header = register_sysctl_paths(neigh_path, t->neigh_vars);
+	t->sysctl_header =
+		register_net_sysctl_table(p->net, neigh_path, t->neigh_vars);
 	if (!t->sysctl_header)
 		goto free_procname;
 
-- 
1.5.3.rc5

