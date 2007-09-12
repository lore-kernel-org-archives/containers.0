From: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Subject: [RFC][patch 1/1] From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Date: Wed, 12 Sep 2007 19:07:40 +0200
Message-ID: <20070912170950.684354765@mai.toulouse-stg.fr.ibm.com>
References: <20070912170739.187625566@mai.toulouse-stg.fr.ibm.com>
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

Fix allnoconfig compilation error

Signed-off-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 init/version.c           |    4 ++++
 net/core/net_namespace.c |    3 ---
 2 files changed, 4 insertions(+), 3 deletions(-)

Index: net-2.6.24/init/version.c
===================================================================
--- net-2.6.24.orig/init/version.c
+++ net-2.6.24/init/version.c
@@ -12,6 +12,7 @@
 #include <linux/utsname.h>
 #include <linux/utsrelease.h>
 #include <linux/version.h>
+#include <net/net_namespace.h>
 
 #define version(a) Version_ ## a
 #define version_string(a) version(a)
@@ -33,6 +34,9 @@ struct uts_namespace init_uts_ns = {
 };
 EXPORT_SYMBOL_GPL(init_uts_ns);
 
+struct net init_net;
+EXPORT_SYMBOL_GPL(init_net);
+
 /* FIXED STRINGS! Don't touch! */
 const char linux_banner[] =
 	"Linux version " UTS_RELEASE " (" LINUX_COMPILE_BY "@"
Index: net-2.6.24/net/core/net_namespace.c
===================================================================
--- net-2.6.24.orig/net/core/net_namespace.c
+++ net-2.6.24/net/core/net_namespace.c
@@ -19,9 +19,6 @@ LIST_HEAD(net_namespace_list);
 
 static struct kmem_cache *net_cachep;
 
-struct net init_net;
-EXPORT_SYMBOL_GPL(init_net);
-
 void net_lock(void)
 {
 	mutex_lock(&net_list_mutex);

-- 
