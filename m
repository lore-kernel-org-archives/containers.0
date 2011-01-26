From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 5/9] restart: obtain pid_max from /proc/sys/kernel/pid_max
Date: Wed, 26 Jan 2011 11:19:04 -0500
Message-ID: <1296058748-21418-6-git-send-email-orenl@cs.columbia.edu>
References: <1296058748-21418-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1296058748-21418-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 restart.c |   19 +++++++++++++++++--
 1 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/restart.c b/restart.c
index 9535543..d998834 100644
--- a/restart.c
+++ b/restart.c
@@ -157,6 +157,9 @@ struct ckpt_ctx {
 	struct cr_restart_args *args;
 
 	char *freezer;
+
+	/* system limits */
+	pid_t pid_max;
 };
 
 struct pid_swap {
@@ -488,6 +491,9 @@ int process_args(struct cr_restart_args *args)
 
 static void init_ctx(struct ckpt_ctx *ctx)
 {
+	FILE *file;
+	char buf[1024];
+
 	memset(ctx, 0, sizeof(*ctx));
 
 	/* mark all fds as unused */
@@ -499,6 +505,15 @@ static void init_ctx(struct ckpt_ctx *ctx)
 	ctx->pipe_feed[1] = -1;
 	ctx->pipe_coord[0] = -1;
 	ctx->pipe_coord[1] = -1;
+
+	/* system limits */
+	ctx->pid_max = SHRT_MAX;  /* default */
+	file = fopen("/proc/sys/kernel/pid_max", "r");
+	if (file) {
+		if (fgets(buf, 1024, file))
+			ctx->pid_max = atoi(buf);
+		fclose(file);
+	}
 }
 
 static void exit_ctx(struct ckpt_ctx *ctx)
@@ -1212,12 +1227,12 @@ static int ckpt_alloc_pid(struct ckpt_ctx *ctx)
 	 * (this will become inefficient if pid-space is exhausted)
 	 */
 	do {
-		if (ctx->tasks_pid == INT_MAX)
+		if (ctx->tasks_pid == ctx->pid_max)
 			ctx->tasks_pid = CKPT_RESERVED_PIDS;
 		else
 			ctx->tasks_pid++;
 
-		if (n++ == INT_MAX) {	/* ohhh... */
+		if (n++ == ctx->pid_max) {	/* ohhh... */
 			ckpt_err("pid namsepace exhausted");
 			return -1;
 		}
-- 
1.7.1
