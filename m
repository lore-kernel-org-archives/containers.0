From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 8/17] [NETNS]: Enable inetdev_event notifier.
Date: Wed,  6 Feb 2008 13:53:28 +0300
Message-ID: <1202295217-22769-8-git-send-email-den@openvz.org>
References: <47A99196.2030105@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <47A99196.2030105@sw.ru>
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, devel@openvz.org, containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
List-Id: containers.vger.kernel.org

After all these preparations it is time to enable main IPv4 device
initialization routine inside namespace. It is safe do this now.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/devinet.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a06fcae..f7e78b7 100644
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

