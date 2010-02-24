From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 1/4][user-cr] Move common definitions to restart.h
Date: Wed, 24 Feb 2010 00:35:34 -0800
Message-ID: <20100224083534.GC18758@us.ibm.com>
References: <20100224083452.GB18758@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100224083452.GB18758-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 23 Feb 2010 15:25:31 -0800
Subject: [PATCH 1/4][user-cr] Move common definitions to restart.h

To make restart() a library interface, the main() and related code in
restart.c should be moved to a separate file. To prepare for the move,
move some common definitions to a new file, 'restart.h'
---
 restart.c |   44 ++------------------------------------------
 restart.h |   45 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+), 42 deletions(-)
 create mode 100644 restart.h

diff --git a/restart.c b/restart.c
index f5d23bb..7140786 100644
--- a/restart.c
+++ b/restart.c
@@ -39,6 +39,7 @@
 #include "eclone.h"
 #include "genstack.h"
 #include "compat.h"
+#include "restart.h"
 
 static char usage_str[] =
 "usage: restart [opts]\n"
@@ -128,12 +129,7 @@ static char usage_str[] =
 			printf(__VA_ARGS__);	\
 	} while(0)
 
-#define SIGNAL_ENTRY(signal)  { SIG ## signal, #signal }
-
-struct {
-	int signum;
-	char *sigstr;
-} signal_array[] = {
+struct signal_array signal_array[] = {
 	{ 0, "NONE" },
 	SIGNAL_ENTRY(ALRM),
 	SIGNAL_ENTRY(HUP),
@@ -196,7 +192,6 @@ inline static int restart(pid_t pid, int fd, unsigned long flags, int logfd)
 	return syscall(__NR_restart, pid, fd, flags, logfd);
 }
 
-#define BUFSIZE  (4 * 4096)
 
 struct hashent {
 	long key;
@@ -205,29 +200,6 @@ struct hashent {
 };
 
 struct task;
-struct ckpt_ctx;
-
-struct task {
-	int flags;		/* state and (later) actions */
-
-	struct task *children;	/* pointers to first child, next and prev */
-	struct task *next_sib;	/*   sibling, and the creator of a process */
-	struct task *prev_sib;
-	struct task *creator;
-
-	struct task *phantom;	/* pointer to place-holdler task (if any) */
-
-	pid_t pid;		/* process IDs, our bread-&-butter */
-	pid_t ppid;
-	pid_t tgid;
-	pid_t sid;
-	
-	pid_t rpid;		/* [restart without vpids] actual (real) pid */
-
-	struct ckpt_ctx *ctx;	/* points back to the c/r context */
-
-	pid_t real_parent;	/* pid of task's real parent */
-};
 
 /* zero_task represents creator of root_task (all pids 0) */
 struct task zero_task;
@@ -360,18 +332,6 @@ struct args {
 	int keep_lsm;
 };
 
-#define CKPT_COND_PIDZERO  0x1
-#define CKPT_COND_MNTPROC  0x2
-#define CKPT_COND_MNTPTY   0x4
-
-#define CKPT_COND_NONE     0
-#define CKPT_COND_ANY      ULONG_MAX
-
-/* default for skip/warn/fail */
-#define CKPT_COND_WARN     (CKPT_COND_MNTPROC | \
-			    CKPT_COND_MNTPTY)
-#define CKPT_COND_FAIL     (CKPT_COND_NONE)
-
 static void usage(char *str)
 {
 	fprintf(stderr, "%s", str);
diff --git a/restart.h b/restart.h
new file mode 100644
index 0000000..6782399
--- /dev/null
+++ b/restart.h
@@ -0,0 +1,45 @@
+struct ckpt_ctx;
+
+struct task {
+	int flags;		/* state and (later) actions */
+
+	struct task *children;	/* pointers to first child, next and prev */
+	struct task *next_sib;	/*   sibling, and the creator of a process */
+	struct task *prev_sib;
+	struct task *creator;
+
+	struct task *phantom;	/* pointer to place-holdler task (if any) */
+
+	pid_t pid;		/* process IDs, our bread-&-butter */
+	pid_t ppid;
+	pid_t tgid;
+	pid_t sid;
+	
+	pid_t rpid;		/* [restart without vpids] actual (real) pid */
+
+	struct ckpt_ctx *ctx;	/* points back to the c/r context */
+
+	pid_t real_parent;	/* pid of task's real parent */
+};
+
+#define BUFSIZE  (4 * 4096)
+
+#define CKPT_COND_PIDZERO  0x1
+#define CKPT_COND_MNTPROC  0x2
+#define CKPT_COND_MNTPTY   0x4
+
+#define CKPT_COND_NONE     0
+#define CKPT_COND_ANY      ULONG_MAX
+
+/* default for skip/warn/fail */
+#define CKPT_COND_WARN     (CKPT_COND_MNTPROC | \
+			    CKPT_COND_MNTPTY)
+#define CKPT_COND_FAIL     (CKPT_COND_NONE)
+
+#define SIGNAL_ENTRY(signal)  { SIG ## signal, #signal }
+
+struct signal_array {
+	int signum;
+	char *sigstr;
+};
+
-- 
1.6.6.1
