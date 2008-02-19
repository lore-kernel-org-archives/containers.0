From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] [NETNS]: Namespace leak in pneigh_lookup.
Date: Tue, 19 Feb 2008 16:12:38 +0300
Message-ID: <1203426758-27813-1-git-send-email-den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org, dlezcano@fr.ibm.com, "Denis V. Lunev" <den@openvz.org>
List-Id: containers.vger.kernel.org

release_net is missed on the error path in pneigh_lookup.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/core/neighbour.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 7bb6a9a..174e29e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -507,6 +507,7 @@ struct pneigh_entry * pneigh_lookup(struct neigh_table *tbl,
 	if (tbl->pconstructor && tbl->pconstructor(n)) {
 		if (dev)
 			dev_put(dev);
+		release_net(net);
 		kfree(n);
 		n = NULL;
 		goto out;
-- 
1.5.3.rc5

