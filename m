From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: [PATCH 1/4] Kconfig: make namespace a submenu
Date: Wed, 13 Oct 2010 11:28:42 +0200
Message-ID: <1286962125-23871-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Make the namespaces config option a submenu.

Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
---
 init/Kconfig |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index a7fe61e..14c84e7 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -727,7 +727,7 @@ config RELAY
 
 	  If unsure, say N.
 
-config NAMESPACES
+menuconfig NAMESPACES
 	bool "Namespaces support" if EMBEDDED
 	default !EMBEDDED
 	help
@@ -736,9 +736,10 @@ config NAMESPACES
 	  or same user id or pid may refer to different tasks when used in
 	  different namespaces.
 
+if NAMESPACES
+
 config UTS_NS
 	bool "UTS namespace"
-	depends on NAMESPACES
 	default y
 	help
 	  In this namespace tasks see different info provided with the
@@ -746,7 +747,7 @@ config UTS_NS
 
 config IPC_NS
 	bool "IPC namespace"
-	depends on NAMESPACES && (SYSVIPC || POSIX_MQUEUE)
+	depends on (SYSVIPC || POSIX_MQUEUE)
 	default y
 	help
 	  In this namespace tasks work with IPC ids which correspond to
@@ -754,7 +755,7 @@ config IPC_NS
 
 config USER_NS
 	bool "User namespace (EXPERIMENTAL)"
-	depends on NAMESPACES && EXPERIMENTAL
+	depends on EXPERIMENTAL
 	default y
 	help
 	  This allows containers, i.e. vservers, to use user namespaces
@@ -763,7 +764,6 @@ config USER_NS
 
 config PID_NS
 	bool "PID Namespaces"
-	depends on NAMESPACES
 	default y
 	help
 	  Support process id namespaces.  This allows having multiple
@@ -772,12 +772,14 @@ config PID_NS
 
 config NET_NS
 	bool "Network namespace"
-	depends on NAMESPACES && NET
+	depends on NET
 	default y
 	help
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
 
+endif # NAMESPACES
+
 config BLK_DEV_INITRD
 	bool "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
 	depends on BROKEN || !FRV
-- 
1.7.0.4
