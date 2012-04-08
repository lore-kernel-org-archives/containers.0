From: "\"Eric W. Beiderman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 14/43] userns: Add a Kconfig option to enforce strict kuid and
	kgid type checks
Date: Sat,  7 Apr 2012 22:15:10 -0700
Message-ID: <1333862139-31737-14-git-send-email-ebiederm@xmission.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m11unyn70b.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Make it possible to easily switch between strong mandatory
type checks and relaxed type checks so that the code can
easily be tested with the type checks and then built
with the strong type checks disabled so the resulting
code can be used.

Require strong mandatory type checks when enabling the user namespace.
It is very simple to make a typo and use the wrong type allowing
conversions to/from userspace values to be bypassed by accident,
the strong type checks prevent this.

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/linux/uidgid.h |    2 +-
 init/Kconfig           |   12 +++++++++++-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/linux/uidgid.h b/include/linux/uidgid.h
index a0addb8..5398568 100644
--- a/include/linux/uidgid.h
+++ b/include/linux/uidgid.h
@@ -17,7 +17,7 @@
 struct user_namespace;
 extern struct user_namespace init_user_ns;
 
-#if defined(NOTYET)
+#ifdef CONFIG_UIDGID_STRICT_TYPE_CHECKS
 
 typedef struct {
 	uid_t val;
diff --git a/init/Kconfig b/init/Kconfig
index 72f33fa..86cf760 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -828,7 +828,8 @@ config IPC_NS
 config USER_NS
 	bool "User namespace (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
-	default y
+	select UIDGID_STRICT_TYPE_CHECKS
+	default n
 	help
 	  This allows containers, i.e. vservers, to use user namespaces
 	  to provide different user info for different servers.
@@ -852,6 +853,15 @@ config NET_NS
 
 endif # NAMESPACES
 
+config UIDGID_STRICT_TYPE_CHECKS
+	bool "Require conversions between uid/gids and their internal representation"
+	default n
+	help
+	 While the nececessary conversions are being added to all subsystems this option allows
+	 the code to continue to build for unconverted subsystems.
+
+	 Say Y here if you want the strict type checking enabled
+
 config SCHED_AUTOGROUP
 	bool "Automatic process group scheduling"
 	select EVENTFD
-- 
1.7.2.5
