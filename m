From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH] pidns: Place under CONFIG_EXPERIMENTAL
Date: Fri, 26 Oct 2007 11:40:59 -0600
Message-ID: <m1640t3has.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org


I finally found a chance to review the pid namespace implementation in
detail and currently it is much to easy to find issues where the
kernel does the wrong thing outside of the initial pid namespace.
At the same time the pid namespace code we have does appear
to be a good base to build on.

Therefore until the dust settles and we are certain we have the
ABI and the implementation as correct as humanly possible let's
hide the availability of process ID namespaces behind
CONFIG_EXPERIMENTAL.

Allowing users to avoid bugs, and removing a guarantee of bug
compatibility.  Allowing any issues that may be found to
be fixed properly.

If CONFIG_PID_NS=N this patch will cause copy_pid_ns to
unconditionally return -EINVAL removing the availability
of multiple pid namespaces.

Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 init/Kconfig |   12 ++++++++++++
 kernel/pid.c |    4 ++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 8b88d0b..72e37c0 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -215,6 +215,18 @@ config USER_NS
 	  vservers, to use user namespaces to provide different
 	  user info for different servers.  If unsure, say N.
 
+config PID_NS
+	bool "PID Namespaces (EXPERIMENTAL)"
+	default n
+	depends on EXPERIMENTAL
+	help
+	  Suport process id namespaces.  This allows having multiple
+	  process with the same pid as long as they are in different
+	  pid namespaces.  This is a building block of containers.
+
+	  Unless you want to work with an experimental feature
+	  say N here.
+
 config AUDIT
 	bool "Auditing support"
 	depends on NET
diff --git a/kernel/pid.c b/kernel/pid.c
index d1db36b..8a5637b 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -599,6 +599,10 @@ struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *old
 	if (flags & CLONE_THREAD)
 		goto out_put;
 
+#ifndef CONFIG_PID_NS
+	goto out_put;
+#endif
+
 	new_ns = create_pid_namespace(old_ns->level + 1);
 	if (!IS_ERR(new_ns))
 		new_ns->parent = get_pid_ns(old_ns);
-- 
1.5.3.rc6.17.g1911
