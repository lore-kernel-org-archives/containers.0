From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 09/12][user-cr] Create app-checkpoint.h
Date: Fri, 5 Mar 2010 14:39:26 -0800
Message-ID: <20100305223926.GI15939@us.ibm.com>
References: <20100305223439.GA15300@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100305223439.GA15300-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Subject: [PATCH 09/12][user-cr] Create app-checkpoint.h

Create a new header file, app-checkpoint.h that can be used to export
the app_checkpoint() and app_restart() functionality to other users
(such as LXC).

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 Makefile         |    2 +-
 app-checkpoint.h |   37 +++++++++++++++++++++++++++++++++++++
 checkpoint.c     |    9 +--------
 restart.c        |   25 +------------------------
 4 files changed, 40 insertions(+), 33 deletions(-)
 create mode 100644 app-checkpoint.h

diff --git a/Makefile b/Makefile
index acebdd5..b037f93 100644
--- a/Makefile
+++ b/Makefile
@@ -43,7 +43,7 @@ $(LIB_ECLONE):
 # restart needs to be thread-safe
 restart: CFLAGS += -D__REENTRANT -pthread
 
-$(CR_OBJS): common.h
+$(CR_OBJS): common.h app-checkpoint.h
 
 # eclone() is architecture specific
 ifneq ($(SUBARCH),)
diff --git a/app-checkpoint.h b/app-checkpoint.h
new file mode 100644
index 0000000..75204b5
--- /dev/null
+++ b/app-checkpoint.h
@@ -0,0 +1,37 @@
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
+	int send_sigint;
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
index f65eafb..a9b287d 100644
--- a/restart.c
+++ b/restart.c
@@ -40,6 +40,7 @@
 #include "eclone.h"
 #include "genstack.h"
 #include "compat.h"
+#include "app-checkpoint.h"
 #include "common.h"
 
 static char usage_str[] =
@@ -279,30 +280,6 @@ struct pid_swap {
 	pid_t new;
 };
 
-struct app_restart_args {
-	int self;
-	int pids;
-	int pidns;
-	int inspect;
-	int send_sigint;
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
