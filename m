From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [RFC][PATCH 3/6][usercr] Minor reorg of restart.c
Date: Tue, 13 Apr 2010 17:52:41 -0700
Message-ID: <20100414005241.GC13532@us.ibm.com>
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
Date: Tue, 13 Apr 2010 12:34:28 -0700
Subject: [RFC][PATCH 3/6][usercr] Minor reorg of restart.c

Just a minor reorg to group global variables, declarations, system-call
wrappers and helper functions together. A follow-on patch will combine
the checkpoint and restart functionality into one file and this reorg
would help keep related code together.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |   43 +++++++++++++++++++++----------------------
 1 files changed, 21 insertions(+), 22 deletions(-)

diff --git a/restart.c b/restart.c
index c98d377..11628e0 100644
--- a/restart.c
+++ b/restart.c
@@ -68,24 +68,6 @@
  * of the checkpoint image stream.
  */
 
-static struct signal_array signal_array[] = INIT_SIGNAL_ARRAY;
-
-static char *sig2str(int sig)
-{
-	int i = 0;
-
-	do {
-		if (signal_array[i].signum == sig)
-			return signal_array[i].sigstr;
-	} while (signal_array[++i].signum >= 0);
-	return "UNKNOWN SIGNAL";
-}
-
-inline static int restart(pid_t pid, int fd, unsigned long flags, int klogfd)
-{
-	return syscall(__NR_restart, pid, fd, flags, klogfd);
-}
-
 struct hashent {
 	long key;
 	void *data;
@@ -167,6 +149,11 @@ struct ckpt_ctx {
 	char *freezer;
 };
 
+struct pid_swap {
+	pid_t old;
+	pid_t new;
+};
+
 /*
  * TODO: Do we need to direct user-space restart messages to two different
  * 	 fds (like stdout and stderr) or can we just use one ?
@@ -179,6 +166,7 @@ static pid_t global_child_pid;
 static int global_child_status;
 static int global_child_collected;
 static int global_sent_sigint;
+static struct signal_array signal_array[] = INIT_SIGNAL_ARRAY;
 
 /*
  * TODO: Implement an API to let callers choose if/how an interrupt be sent
@@ -244,10 +232,10 @@ static inline pid_t _getpid(void)
 	return syscall(__NR_getpid);
 }
 
-struct pid_swap {
-	pid_t old;
-	pid_t new;
-};
+static inline int restart(pid_t pid, int fd, unsigned long flags, int klogfd)
+{
+	return syscall(__NR_restart, pid, fd, flags, klogfd);
+}
 
 static inline int ckpt_cond_warn(struct ckpt_ctx *ctx, long mask)
 {
@@ -276,6 +264,17 @@ static void report_exit_status(int status, char *str, int debug)
 		ckpt_err("%s\n", msg);
 }
 
+static char *sig2str(int sig)
+{
+	int i = 0;
+
+	do {
+		if (signal_array[i].signum == sig)
+			return signal_array[i].sigstr;
+	} while (signal_array[++i].signum >= 0);
+	return "UNKNOWN SIGNAL";
+}
+
 static void sigchld_handler(int sig)
 {
 	int collected = 0;
-- 
1.6.6.1
