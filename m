From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH user-cr] define MNT_DETACH in older userspace
Date: Mon, 22 Feb 2010 12:07:29 -0600
Message-ID: <1266862049.12720.1.camel@localhost.localdomain>
References: <20100222174755.GA8329@us.ibm.com>
	<1266861478.3760.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1266861478.3760.2.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2010-02-22 at 11:58 -0600, Nathan Lynch wrote:
> Thanks, I had already put together a local fix which adds a compat
> header -- please use this instead of duplicating the work across files?

Sorry, please use this one instead - fixed include guard in compat.h

From c0869556338592a92bad3b587d394add82267f99 Mon Sep 17 00:00:00 2001
From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Date: Mon, 22 Feb 2010 11:50:46 -0600
Subject: [PATCH 1/1] user-cr: add compat.h; define MNT_DETACH

"nsexec: remount proc and devpts" introduced usage of the MNT_DETACH
umount2 flag, which is not defined even in some relatively recent
glibc headers (e.g. Fedora 10/glibc 2.9-3).  Add a compat.h header
where we can add fixups like this for older build environments.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/compat.h |    8 ++++++++
 nsexec.c         |    1 +
 restart.c        |    1 +
 3 files changed, 10 insertions(+), 0 deletions(-)
 create mode 100644 include/compat.h

diff --git a/include/compat.h b/include/compat.h
new file mode 100644
index 0000000..bcdd149
--- /dev/null
+++ b/include/compat.h
@@ -0,0 +1,8 @@
+#ifndef USER_CR_COMPAT_H
+#define USER_CR_COMPAT_H
+
+#ifndef MNT_DETACH
+#define MNT_DETACH 2
+#endif
+
+#endif /* USER_CR_COMPAT_H */
diff --git a/nsexec.c b/nsexec.c
index 7a0294c..1cf9c97 100644
--- a/nsexec.c
+++ b/nsexec.c
@@ -20,6 +20,7 @@
 #include "clone.h"
 #include "eclone.h"
 #include "genstack.h"
+#include "compat.h"
 
 extern pid_t getpgid(pid_t pid);
 extern pid_t getsid(pid_t pid);
diff --git a/restart.c b/restart.c
index 166a499..f5d23bb 100644
--- a/restart.c
+++ b/restart.c
@@ -38,6 +38,7 @@
 
 #include "eclone.h"
 #include "genstack.h"
+#include "compat.h"
 
 static char usage_str[] =
 "usage: restart [opts]\n"
-- 
1.6.0.6
