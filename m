From: dlezcano@fr.ibm.com
Subject: [net-2.6.24][NETNS][patch 1/1] fix allnoconfig compilation error
Date: Thu, 13 Sep 2007 08:01:52 +0200
Message-ID: <20070913060545.740930015@mai.toulouse-stg.fr.ibm.com>
References: <20070913060151.898030855@mai.toulouse-stg.fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline; filename=net-ns-fix-allnoconfig.patch
Sender: netdev-owner@vger.kernel.org
To: davem@davemloft.net
Cc: ebiederm@xmission.com, containers@lists.osdl.org, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>

When CONFIG_NET=no, init_net is unresolved because net_namespace.c
is not compiled and the include pull init_net definition.

This problem was very similar with the ipc namespace where the kernel
can be compiled with SYSV ipc out.

This patch fix that defining a macro which simply remove init_net
initialization from nsproxy namespace aggregator.

Compiled and booted on qemu-i386 with CONFIG_NET=no and CONFIG_NET=yes.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/init_task.h   |    2 +-
 include/net/net_namespace.h |    7 +++++++
 2 files changed, 8 insertions(+), 1 deletion(-)

Index: net-2.6.24/include/linux/init_task.h
===================================================================
--- net-2.6.24.orig/include/linux/init_task.h
+++ net-2.6.24/include/linux/init_task.h
@@ -79,7 +79,7 @@ extern struct nsproxy init_nsproxy;
 	.nslock		= __SPIN_LOCK_UNLOCKED(nsproxy.nslock),		\
 	.uts_ns		= &init_uts_ns,					\
 	.mnt_ns		= NULL,						\
-	.net_ns		= &init_net,					\
+	INIT_NET_NS(net_ns)                                             \
 	INIT_IPC_NS(ipc_ns)						\
 	.user_ns	= &init_user_ns,				\
 }
Index: net-2.6.24/include/net/net_namespace.h
===================================================================
--- net-2.6.24.orig/include/net/net_namespace.h
+++ net-2.6.24/include/net/net_namespace.h
@@ -28,7 +28,14 @@ struct net {
 	struct hlist_head	*dev_index_head;
 };
 
+#ifdef CONFIG_NET
+/* Init's network namespace */
 extern struct net init_net;
+#define INIT_NET_NS(net_ns) .net_ns = &init_net,
+#else
+#define INIT_NET_NS(net_ns)
+#endif
+
 extern struct list_head net_namespace_list;
 
 extern void __put_net(struct net *net);

-- 
