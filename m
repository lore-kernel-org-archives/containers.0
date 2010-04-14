From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 1/6][usercr] Change API prefix to cr_
Date: Tue, 13 Apr 2010 17:52:08 -0700
Message-ID: <20100414005208.GA13532@us.ibm.com>
References: <20100414004927.GA13012@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100414004927.GA13012-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Tue, 13 Apr 2010 12:26:03 -0700
Subject: [RFC][PATCH 1/6][usercr] Change API prefix to cr_

Change the "app_" prefix to "cr_" in function names and data structures.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 Makefile          |    2 +-
 app-checkpoint.h  |   45 ---------------------------------------------
 checkpoint-main.c |    8 ++++----
 checkpoint.c      |    6 +++---
 cr_checkpoint.h   |   45 +++++++++++++++++++++++++++++++++++++++++++++
 restart-main.c    |    8 ++++----
 restart.c         |    8 ++++----
 7 files changed, 61 insertions(+), 61 deletions(-)
 delete mode 100644 app-checkpoint.h
 create mode 100644 cr_checkpoint.h

diff --git a/Makefile b/Makefile
index 6c9ff93..afe144f 100644
--- a/Makefile
+++ b/Makefile
@@ -52,7 +52,7 @@ $(LIB_ECLONE):
 # restart needs to be thread-safe
 restart: CFLAGS += -D__REENTRANT -pthread
 
-$(CR_OBJS): common.h app-checkpoint.h
+$(CR_OBJS): common.h cr_checkpoint.h
 
 restart: restart.o restart-main.o
 
diff --git a/app-checkpoint.h b/app-checkpoint.h
deleted file mode 100644
index d2455f3..0000000
--- a/app-checkpoint.h
+++ /dev/null
@@ -1,45 +0,0 @@
-#include <linux/checkpoint.h>
-#include <linux/checkpoint_hdr.h>
-
-struct app_checkpoint_args {
-	int outfd;
-	int logfd;
-	int uerrfd;
-	int container;
-	int verbose;
-};
-
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
-	int keep_frozen;
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
-/*
- * TODO: Implement an API to let callers choose if/how an interrupt be sent
- *  	 and remove global_send_sigint.
- */
-extern int global_send_sigint;
-
-extern int app_checkpoint(int pid, unsigned long flags,
-				struct app_checkpoint_args *args);
-
-extern int app_restart(struct app_restart_args *args);
diff --git a/checkpoint-main.c b/checkpoint-main.c
index bac65cc..48c54f6 100644
--- a/checkpoint-main.c
+++ b/checkpoint-main.c
@@ -9,7 +9,7 @@
 
 #include <linux/checkpoint.h>
 
-#include "app-checkpoint.h"
+#include "cr_checkpoint.h"
 #include "common.h"
 
 static int global_uerrfd = -1;
@@ -51,7 +51,7 @@ static int str2num(char *str)
 	return num;
 }
 
-static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
+static void parse_args(struct cr_checkpoint_args *args, int argc, char *argv[])
 {
 	static struct option opts[] = {
 		{ "help",	no_argument,		NULL, 'h' },
@@ -146,7 +146,7 @@ static void parse_args(struct app_checkpoint_args *args, int argc, char *argv[])
 int main(int argc, char *argv[])
 {
 	int ret;
-	struct app_checkpoint_args args;
+	struct cr_checkpoint_args args;
 	unsigned long flags = 0;
 	pid_t pid;
 
@@ -168,6 +168,6 @@ int main(int argc, char *argv[])
 	if (!args.container)
 		flags |= CHECKPOINT_SUBTREE;
 
-	ret = app_checkpoint(pid, flags, &args);
+	ret = cr_checkpoint(pid, flags, &args);
 	return (ret > 0) ? 0 : 1;
 }
diff --git a/checkpoint.c b/checkpoint.c
index e0290c9..5472bfe 100644
--- a/checkpoint.c
+++ b/checkpoint.c
@@ -21,7 +21,7 @@
 
 #include <linux/checkpoint.h>
 
-#include "app-checkpoint.h"
+#include "cr_checkpoint.h"
 #include "common.h"
 
 static int global_uerrfd = -1;
@@ -31,8 +31,8 @@ inline static int checkpoint(pid_t pid, int fd, unsigned long flags, int logfd)
 	return syscall(__NR_checkpoint, pid, fd, flags, logfd);
 }
 
-int app_checkpoint(int pid, unsigned long flags,
-				struct app_checkpoint_args *args)
+int cr_checkpoint(int pid, unsigned long flags,
+				struct cr_checkpoint_args *args)
 {
 	int ret;
 
diff --git a/cr_checkpoint.h b/cr_checkpoint.h
new file mode 100644
index 0000000..81fa2c2
--- /dev/null
+++ b/cr_checkpoint.h
@@ -0,0 +1,45 @@
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
+
+struct cr_checkpoint_args {
+	int outfd;
+	int logfd;
+	int uerrfd;
+	int container;
+	int verbose;
+};
+
+struct cr_restart_args {
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
+	int keep_frozen;
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
+extern int cr_checkpoint(int pid, unsigned long flags,
+				struct cr_checkpoint_args *args);
+
+extern int cr_restart(struct cr_restart_args *args);
diff --git a/restart-main.c b/restart-main.c
index 656d49f..1f1a749 100644
--- a/restart-main.c
+++ b/restart-main.c
@@ -8,7 +8,7 @@
 #include <limits.h>
 #include <getopt.h>
 
-#include "app-checkpoint.h"
+#include "cr_checkpoint.h"
 #include "common.h"
 
 static int global_ulogfd;
@@ -105,7 +105,7 @@ static int str2sig(char *str)
 	return -1;
 }
 
-static void parse_args(struct app_restart_args *args, int argc, char *argv[])
+static void parse_args(struct cr_restart_args *args, int argc, char *argv[])
 {
 	static struct option opts[] = {
 		{ "help",	no_argument,		NULL, 'h' },
@@ -299,7 +299,7 @@ static void parse_args(struct app_restart_args *args, int argc, char *argv[])
 int main(int argc, char *argv[])
 {
 	int ret;
-	struct app_restart_args args;
+	struct cr_restart_args args;
 
 	/*
 	 * Initialize the log/error fds early so even parse_args() errors
@@ -312,7 +312,7 @@ int main(int argc, char *argv[])
 
 	parse_args(&args, argc, argv);
 
-	ret = app_restart(&args);
+	ret = cr_restart(&args);
 	if (ret > 0)
 		ret = 0;
 
diff --git a/restart.c b/restart.c
index 3224335..c98d377 100644
--- a/restart.c
+++ b/restart.c
@@ -40,7 +40,7 @@
 #include "eclone.h"
 #include "genstack.h"
 #include "compat.h"
-#include "app-checkpoint.h"
+#include "cr_checkpoint.h"
 #include "common.h"
 
 /*
@@ -162,7 +162,7 @@ struct ckpt_ctx {
 	char tree[BUFSIZE];
 	char vpids[BUFSIZE];
 	char buf[BUFSIZE];
-	struct app_restart_args *args;
+	struct cr_restart_args *args;
 
 	char *freezer;
 };
@@ -400,7 +400,7 @@ static int freezer_register(struct ckpt_ctx *ctx, pid_t pid)
  * Validate the specified arguments and initialize globals based on the
  * arguments. Return 0 on success.
  */
-int process_args(struct app_restart_args *args)
+int process_args(struct cr_restart_args *args)
 {
 	global_debug = args->debug;
 	global_verbose = args->verbose;
@@ -463,7 +463,7 @@ int process_args(struct app_restart_args *args)
 	return 0;
 }
 
-int app_restart(struct app_restart_args *args)
+int cr_restart(struct cr_restart_args *args)
 {
 	struct ckpt_ctx ctx;
 	int ret;
-- 
1.6.6.1
