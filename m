From: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Subject: [NETNS][patch 1/1] fix allnoconfig compilation error
Date: Wed, 12 Sep 2007 22:48:27 +0200
Message-ID: <20070912205028.838067239@mai.toulouse-stg.fr.ibm.com>
References: <20070912204826.676639734@mai.toulouse-stg.fr.ibm.com>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=net-ns-fix-allnoconfig.patch
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

When CONFIG_NET=no, init_net is unresolved because net_namespace.c
is not compiled and the include pull init_net definition.

This problem was very similar with the ipc namespace where the kernel
can be compiled with SYSV ipc out.

This patch fix that defining a macro which simply remove init_net
initialization from nsproxy namespace aggregator.

Compiled and booted on qemu-i386 with CONFIG_NET=no and CONFIG_NET=yes.

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
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
