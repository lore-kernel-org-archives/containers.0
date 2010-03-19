From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 13/14][user-cr] restart: Move args checking to app_restart()
Date: Thu, 18 Mar 2010 23:34:33 -0700
Message-ID: <20100319063433.GM24844@us.ibm.com>
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
Date: Sat, 6 Mar 2010 13:06:35 -0800
Subject: [PATCH 13/14][user-cr] restart: Move args checking to app_restart()

parse_args() validates the specified arguments to ensure they are consistent.
Move this code into app_restart() so that these checks apply to other callers
of app_restart() also.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart-main.c |   33 +--------------------------------
 restart.c      |   36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+), 32 deletions(-)

diff --git a/restart-main.c b/restart-main.c
index 36318a4..681ff8e 100644
--- a/restart-main.c
+++ b/restart-main.c
@@ -261,38 +261,7 @@ static void parse_args(struct app_restart_args *args, int argc, char *argv[])
 	if (no_pidns)
 		args->pidns = 0;
 
-#ifndef CLONE_NEWPID
-	if (args->pidns) {
-		ckpt_err("This version of restart was compiled without "
-		       "support for --pidns.\n");
-		exit(1);
-	}
-#endif
-
-#ifndef CHECKPOINT_DEBUG
-	if (global_debug) {
-		ckpt_err("This version of restart was compiled without "
-		       "support for --debug.\n");
-		exit(1);
-	}
-#endif
-
-	if (args->pidns)
-		args->pids = 1;
-
-#if 0   /* Defered until __NR_eclone makes it to standard headers */
-#ifndef __NR_eclone
-	if (args->pids) {
-		ckpt_err("This version of restart was compiled without "
-		       "support for --pids.\n");
-		exit(1);
-	}
-#endif
-#endif
-
-	if (args->self &&
-	    (args->pids || args->pidns || no_pidns ||
-	     args->show_status || args->copy_status || args->freezer)) {
+	if (args->self && no_pidns) {
 		ckpt_err("Invalid mix of --self with multiprocess options\n");
 		exit(1);
 	}
diff --git a/restart.c b/restart.c
index d7b5b72..b2708c3 100644
--- a/restart.c
+++ b/restart.c
@@ -407,6 +407,42 @@ int process_args(struct app_restart_args *args)
 	if (args->mnt_pty)
 		args->mntns = 1;
 
+#ifndef CLONE_NEWPID
+	if (args->pidns) {
+		ckpt_err("This version of restart was compiled without "
+		       "support for --pidns.\n");
+		exit(1);
+	}
+#endif
+
+#ifndef CHECKPOINT_DEBUG
+	if (global_debug) {
+		ckpt_err("This version of restart was compiled without "
+		       "support for --debug.\n");
+		exit(1);
+	}
+#endif
+
+	if (args->pidns)
+		args->pids = 1;
+
+#if 0   /* Defered until __NR_eclone makes it to standard headers */
+#ifndef __NR_eclone
+	if (args->pids) {
+		ckpt_err("This version of restart was compiled without "
+		       "support for --pids.\n");
+		exit(1);
+	}
+#endif
+#endif
+
+	if (args->self &&
+	    (args->pids || args->pidns || args->show_status ||
+	     args->copy_status || args->freezer)) {
+		ckpt_err("Invalid mix of --self with multiprocess options\n");
+		exit(1);
+	}
+
 	return 0;
 }
 
-- 
1.6.0.4
