From: Vivien Chappelier <vivien.chappelier-L+G57L1VLRbR7s880joybQ@public.gmane.org>
Subject: [PATCH 6/6] netns: configurable number of initial network namespaces
Date: Thu, 30 Oct 2008 14:11:11 +0100
Message-ID: <20081030131111.GF17665@thomson.net>
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

This allows the creation of more than one network namespace at boot time.
---
 net/Kconfig              |    7 +++++++
 net/core/net_namespace.c |   19 ++++++++++++++++++-
 2 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index 8c3d97c..c896bdf 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -32,6 +32,13 @@ config NET_NS
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
 
+config NET_NS_NR
+	int "Initial number of network namespaces"
+	default 1
+	depends on NET_NS
+	help
+	  Number of network stacks to create at start-up.
+
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 596cb83..1cafa31 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -297,8 +297,25 @@ static int __init net_ns_init(void)
 	rtnl_unlock();
 
 	mutex_unlock(&net_mutex);
+
+#if defined(CONFIG_NET_NS) && CONFIG_NET_NS_NR > 1
+	/* Create additional initial namespaces */
+	{
+		struct net *net;
+		int i;
+
+		for (i = 1; i < CONFIG_NET_NS_NR; i++) {
+			net = copy_net_ns(CLONE_NEWNET, &init_net);
+			if (IS_ERR(net)) {
+				err = PTR_ERR(net);
+				break;
+			}
+		}
+	}
+#endif
+
 	if (err)
-		panic("Could not setup the initial network namespace");
+		panic("Could not setup the initial network namespace(s)");
 
 	return 0;
 }
-- 
1.5.4.4
