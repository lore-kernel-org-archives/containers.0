From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH user-cr] define MNT_DETACH in older userspace
Date: Mon, 22 Feb 2010 11:47:55 -0600
Message-ID: <20100222174755.GA8329@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Reported-by: Nathan T Lynch <natlynch-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 nsexec.c  |    4 ++++
 restart.c |    4 ++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/nsexec.c b/nsexec.c
index 79fcc70..90db229 100644
--- a/nsexec.c
+++ b/nsexec.c
@@ -21,6 +21,10 @@
 #include "eclone.h"
 #include "genstack.h"
 
+#ifndef MNT_DETACH
+#define MNT_DETACH 2
+#endif
+
 extern pid_t getpgid(pid_t pid);
 extern pid_t getsid(pid_t pid);
 
diff --git a/restart.c b/restart.c
index 166a499..5d781c2 100644
--- a/restart.c
+++ b/restart.c
@@ -39,6 +39,10 @@
 #include "eclone.h"
 #include "genstack.h"
 
+#ifndef MNT_DETACH
+#define MNT_DETACH 2
+#endif
+
 static char usage_str[] =
 "usage: restart [opts]\n"
 "  restart restores from a checkpoint image by first creating in userspace\n"
-- 
1.7.0
