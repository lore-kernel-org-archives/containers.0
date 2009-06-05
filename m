From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 4/4] Conditionally force on namespaces
Date: Fri, 05 Jun 2009 12:15:30 -0700
Message-ID: <20090605191530.04562DD1@kernel>
References: <20090605191525.C3F1C2F2@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090605191525.C3F1C2F2@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org


This should work around the compile issues that Nathan
pointed out yesterday.  It's too bad that 'select' is
such a blunt object.  We could surely use a soft select
or something.  But this hacks around it a bit.

Create a separate "*_NS_DEP" Kconfig option for the
dependencies for each namespace.  Make the real config
option and the c/r 'select' bot dependent on the new
common one.

This should at least keep compile errors from being
introduced.  Whether this is rude or not is a separate
questions. :)

---

 linux-2.6.git-dave/checkpoint/Kconfig |    6 ++++++
 linux-2.6.git-dave/init/Kconfig       |   30 +++++++++++++++++++++++++-----
 2 files changed, 31 insertions(+), 5 deletions(-)

diff -puN init/Kconfig~force-on-namespaces init/Kconfig
--- linux-2.6.git/init/Kconfig~force-on-namespaces	2009-06-05 12:00:06.000000000 -0700
+++ linux-2.6.git-dave/init/Kconfig	2009-06-05 12:14:22.000000000 -0700
@@ -667,32 +667,48 @@ menuconfig NAMESPACES
 	  or same user id or pid may refer to different tasks when used in
 	  different namespaces.
 
+config UTS_NS_DEP
+	def_bool y
+	depends on NAMESPACES
+
 config UTS_NS
 	bool "UTS namespace"
-	depends on NAMESPACES
+	depends on UTS_NS_DEP
 	help
 	  In this namespace tasks see different info provided with the
 	  uname() system call
 
+config IPC_NS_DEP
+	def_bool y
+	depends on NAMESPACES && (SYSVIPC || POSIX_MQUEUE)
+
 config IPC_NS
 	bool "IPC namespace"
-	depends on NAMESPACES && (SYSVIPC || POSIX_MQUEUE)
+	depends on IPC_NS_DEP
 	help
 	  In this namespace tasks work with IPC ids which correspond to
 	  different IPC objects in different namespaces.
 
+config USER_NS_DEP
+	def_bool y
+	depends on NAMESPACES && EXPERIMENTAL
+
 config USER_NS
 	bool "User namespace (EXPERIMENTAL)"
-	depends on NAMESPACES && EXPERIMENTAL
+	depends on USER_NS_DEP
 	help
 	  This allows containers, i.e. vservers, to use user namespaces
 	  to provide different user info for different servers.
 	  If unsure, say N.
 
+config PID_NS_DEP
+	def_bool y
+	depends on NAMESPACES && EXPERIMENTAL
+
 config PID_NS
 	bool "PID Namespaces (EXPERIMENTAL)"
 	default n
-	depends on NAMESPACES && EXPERIMENTAL
+	depends on PID_NS_DEP
 	help
 	  Support process id namespaces.  This allows having multiple
 	  processes with the same pid as long as they are in different
@@ -701,10 +717,14 @@ config PID_NS
 	  Unless you want to work with an experimental feature
 	  say N here.
 
+config NET_NS_DEP
+	def_bool y
+	depends on NAMESPACES && EXPERIMENTAL && NET
+
 config NET_NS
 	bool "Network namespace"
 	default n
-	depends on NAMESPACES && EXPERIMENTAL && NET
+	depends on NET_NS_DEP
 	help
 	  Allow user space to create what appear to be multiple instances
 	  of the network stack.
diff -puN checkpoint/Kconfig~force-on-namespaces checkpoint/Kconfig
--- linux-2.6.git/checkpoint/Kconfig~force-on-namespaces	2009-06-05 12:00:06.000000000 -0700
+++ linux-2.6.git-dave/checkpoint/Kconfig	2009-06-05 12:02:56.000000000 -0700
@@ -10,6 +10,12 @@ config CHECKPOINT
 	bool "Checkpoint/restart (EXPERIMENTAL)"
 	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
 	select DEFERQUEUE
+	select NAMESPACE
+	select UTS_NS if UTS_NS_DEP
+	select IPC_NS if IPC_NS_DEP
+	select NET_NS if NET_NS_DEP
+	select PID_NS if PID_NS_DEP
+	select USER_NS if USER_NS_DEP
 	help
 	  Application checkpoint/restart is the ability to save the
 	  state of a running application so that it can later resume
_
