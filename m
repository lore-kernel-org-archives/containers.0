From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 07/14][user-cr] Create app-checkpoint.h
Date: Thu, 18 Mar 2010 23:33:10 -0700
Message-ID: <20100319063310.GG24844@us.ibm.com>
References: <20100319062659.GA23838@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100319062659.GA23838-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Thu, 4 Mar 2010 21:51:27 -0800
Subject: [PATCH 07/14][user-cr] Create app-checkpoint.h

Create a new header file, app-checkpoint.h that can be used to export
the app_checkpoint() and app_restart() functionality to other users
(such as LXC).

For now, leave 'global_send_sigint' as an external variable. We should
eventually implement an API that gives callers better control of how
to handle signals during restart.

Changelog[v2]:
	- (In response to Oren Laadan's comment): Leave 'global_send_sigint'
	  as an extern and add a TODO to remove later.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 Makefile         |    2 +-
 app-checkpoint.h |   42 ++++++++++++++++++++++++++++++++++++++++++
 checkpoint.c     |    9 +--------
 restart.c        |   31 +++++++------------------------
 4 files changed, 51 insertions(+), 33 deletions(-)
 create mode 100644 app-checkpoint.h

diff --git a/Makefile b/Makefile
index 406f685..639d42f 100644
--- a/Makefile
+++ b/Makefile
@@ -52,7 +52,7 @@ $(LIB_ECLONE):
 # restart needs to be thread-safe
 restart: CFLAGS += -D__REENTRANT -pthread
 
-$(CR_OBJS): common.h
+$(CR_OBJS): common.h app-checkpoint.h
 
 # eclone() is architecture specific
 ifneq ($(SUBARCH),)
diff --git a/app-checkpoint.h b/app-checkpoint.h
new file mode 100644
index 0000000..f740085
--- /dev/null
+++ b/app-checkpoint.h
@@ -0,0 +1,42 @@
+
+struct app_checkpoint_args {
+	int outfd;
+	int logfd;
+	int uerrfd;
+	int container;
+	int verbose;
+};
+
+struct app_restart_args {
+	int self;
+	int pids;
+	int pidns;
+	int inspect;
+	char *root;
+	int wait;
+	int mntns;
+	int mnt_pty;
+	int show_status;
+	int copy_status;
+	char *freezer;
+	int infd;
+	int klogfd;
+	int ulogfd;
+	int uerrfd;
+	long warn;
+	int debug;
+	int verbose;
+	long fail;
+	int keep_lsm;
+};
+
+/*
+ * TODO: Implement an API to let callers choose if/how an interrupt be sent
+ *  	 and remove global_send_sigint.
+ */
+extern int global_send_sigint;
+
+extern int app_checkpoint(int pid, unsigned long flags,
+				struct app_checkpoint_args *args);
+
+extern int app_restart(struct app_restart_args *args);
diff --git a/checkpoint.c b/checkpoint.c
index 6e91149..291cb36 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -21,6 +21,7 @@
 
 #include <linux/checkpoint.h>
 
+#include "app-checkpoint.h"
 #include "common.h"
 
 static char usage_str[] =
@@ -44,14 +45,6 @@ static char usage_str[] =
 
 static int global_uerrfd = -1;
 
-struct app_checkpoint_args {
-	int outfd;
-	int logfd;
-	int uerrfd;
-	int container;
-	int verbose;
-};
-
 inline static int checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
 {
 	return syscall(__NR_checkpoint, pid, fd, flags, logfd);
diff --git a/restart.c b/restart.c
index 7c9db80..bbc5ef3 100644
--- a/restart.c
+++ b/restart.c
@@ -40,6 +40,7 @@
 #include "eclone.h"
 #include "genstack.h"
 #include "compat.h"
+#include "app-checkpoint.h"
 #include "common.h"
 
 static char usage_str[] =
@@ -216,9 +217,14 @@ static int global_verbose;
 static pid_t global_child_pid;
 static int global_child_status;
 static int global_child_collected;
-static int global_send_sigint = -1;
 static int global_sent_sigint;
 
+/*
+ * TODO: Implement an API to let callers choose if/how an interrupt be sent
+ * 	 and remove global_send_sigint.
+ */
+int global_send_sigint = -1;
+
 static int ckpt_remount_proc(struct ckpt_ctx *ctx);
 static int ckpt_remount_devpts(struct ckpt_ctx *ctx);
 
@@ -279,29 +285,6 @@ struct pid_swap {
 	pid_t new;
 };
 
-struct app_restart_args {
-	int self;
-	int pids;
-	int pidns;
-	int inspect;
-	char *root;
-	int wait;
-	int mntns;
-	int mnt_pty;
-	int show_status;
-	int copy_status;
-	char *freezer;
-	int infd;
-	int klogfd;
-	int ulogfd;
-	int uerrfd;
-	long warn;
-	int debug;
-	int verbose;
-	long fail;
-	int keep_lsm;
-};
-
 static void usage(char *str)
 {
 	ckpt_err("%s", str);
-- 
1.6.0.4
