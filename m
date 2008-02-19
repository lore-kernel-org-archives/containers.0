From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/17 net-2.6.26] [NETFILTER]: Consolidate masq_inet_event and masq_device_event.
Date: Tue, 19 Feb 2008 10:31:23 +0300
Message-ID: <1203406297-32725-3-git-send-email-den@openvz.org>
References: <1203406116.27296.1.camel@iris.sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1203406116.27296.1.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: netdev@vger.kernel.org, containers@lists.osdl.org, devel@openvz.org, "Denis V. Lunev" <den@openvz.org>
List-Id: containers.vger.kernel.org

They do exactly the same job.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/netfilter/ipt_MASQUERADE.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index d80fee8..313b3fc 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -139,18 +139,8 @@ static int masq_inet_event(struct notifier_block *this,
 			   unsigned long event,
 			   void *ptr)
 {
-	const struct net_device *dev = ((struct in_ifaddr *)ptr)->ifa_dev->dev;
-
-	if (event == NETDEV_DOWN) {
-		/* IP address was deleted.  Search entire table for
-		   conntracks which were associated with that device,
-		   and forget them. */
-		NF_CT_ASSERT(dev->ifindex != 0);
-
-		nf_ct_iterate_cleanup(device_cmp, (void *)(long)dev->ifindex);
-	}
-
-	return NOTIFY_DONE;
+	struct net_device *dev = ((struct in_ifaddr *)ptr)->ifa_dev->dev;
+	return masq_device_event(this, event, dev);
 }
 
 static struct notifier_block masq_dev_notifier = {
-- 
1.5.3.rc5

