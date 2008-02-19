From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 8/17 net-2.6.26] [NETNS]: Enable inetdev_event notifier.
Date: Tue, 19 Feb 2008 10:31:28 +0300
Message-ID: <1203406297-32725-8-git-send-email-den@openvz.org>
References: <1203406116.27296.1.camel@iris.sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
List-Id: containers.vger.kernel.org

After all these preparations it is time to enable main IPv4 device
initialization routine inside namespace. It is safe do this now.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/devinet.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index f282b26..963e711 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1044,9 +1044,6 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
 	struct net_device *dev = ptr;
 	struct in_device *in_dev = __in_dev_get_rtnl(dev);
 
-	if (dev->nd_net != &init_net)
-		return NOTIFY_DONE;
-
 	ASSERT_RTNL();
 
 	if (!in_dev) {
-- 
1.5.3.rc5

