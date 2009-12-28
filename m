From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [patch 1/1] remove EXPERIMENTAL on PID namespace
Date: Mon, 28 Dec 2009 23:00:17 +0100
Message-ID: <20091228220100.269036219@mai.lab.toulouse-stg.fr.ibm.com>
References: <20091228220016.114481294@mai.lab.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline; filename=remove-pid-ns-experimental.patch
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

The pid namespace is enabled by default in different distros
and the different bugs were fixed when they were reported.
No new bug is reported since some time now, so I guess it's safe to
remove the experimental condition on this subsystem.

Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
---
 init/Kconfig |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

Index: linux-2.6/init/Kconfig
===================================================================
--- linux-2.6.orig/init/Kconfig
+++ linux-2.6/init/Kconfig
@@ -690,17 +690,14 @@ config USER_NS
 	  If unsure, say N.
 
 config PID_NS
-	bool "PID Namespaces (EXPERIMENTAL)"
+	bool "PID Namespaces"
 	default n
-	depends on NAMESPACES && EXPERIMENTAL
+	depends on NAMESPACES
 	help
 	  Support process id namespaces.  This allows having multiple
 	  processes with the same pid as long as they are in different
 	  pid namespaces.  This is a building block of containers.
 
-	  Unless you want to work with an experimental feature
-	  say N here.
-
 config NET_NS
 	bool "Network namespace"
 	default n
