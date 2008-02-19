From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 9/17 net-2.6.26] [NETNS]: DST cleanup routines should be called inside namespace.
Date: Tue, 19 Feb 2008 10:31:29 +0300
Message-ID: <1203406297-32725-9-git-send-email-den@openvz.org>
References: <1203406116.27296.1.camel@iris.sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
List-Id: containers.vger.kernel.org

Device inside the namespace can be started and downed. So, active routing
cache should be cleaned up on device stop.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/core/dst.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 7deef48..3a01a81 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -295,9 +295,6 @@ static int dst_dev_event(struct notifier_block *this, unsigned long event, void
 	struct net_device *dev = ptr;
 	struct dst_entry *dst, *last = NULL;
 
-	if (dev->nd_net != &init_net)
-		return NOTIFY_DONE;
-
 	switch (event) {
 	case NETDEV_UNREGISTER:
 	case NETDEV_DOWN:
-- 
1.5.3.rc5

