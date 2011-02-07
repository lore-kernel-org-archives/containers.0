From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH 02/11] restart: cleanup setup/cleanup of freezer cgroups
Date: Mon,  7 Feb 2011 12:21:23 -0500
Message-ID: <1297099292-18772-3-git-send-email-orenl@cs.columbia.edu>
References: <1297099292-18772-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1297099292-18772-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
 restart.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/restart.c b/restart.c
index 8106fd6..195a892 100644
--- a/restart.c
+++ b/restart.c
@@ -359,35 +359,32 @@ static void sigint_handler(int sig)
 
 static int freezer_prepare(struct ckpt_ctx *ctx)
 {
-	char *freezer;
 	int fd, ret;
 
 #define FREEZER_THAWED  "THAWED"
 
-	freezer = malloc(strlen(ctx->args->freezer) + 32);
-	if (!freezer) {
+	ctx->freezer = malloc(strlen(ctx->args->freezer) + 32);
+	if (!ctx->freezer) {
 		ckpt_perror("malloc freezer buf");
-		return -1;
+		return ctx_set_errno(ctx);
 	}
 
-	sprintf(freezer, "%s/freezer.state", ctx->args->freezer);
+	sprintf(ctx->freezer, "%s/freezer.state", ctx->args->freezer);
 
-	fd = open(freezer, O_WRONLY, 0);
+	fd = open(ctx->freezer, O_WRONLY, 0);
 	if (fd < 0) {
 		ckpt_perror("freezer path");
-		free(freezer);
-		return -1;
+		return ctx_set_errno(ctx);
 	}
 	ret = write(fd, FREEZER_THAWED, sizeof(FREEZER_THAWED)); 
 	if (ret != sizeof(FREEZER_THAWED)) {
 		ckpt_perror("thawing freezer");
-		free(freezer);
+		ctx_set_errno(ctx);
 		close(fd);
 		return -1;
 	}
 
-	sprintf(freezer, "%s/tasks", ctx->args->freezer);
-	ctx->freezer = freezer;
+	sprintf(ctx->freezer, "%s/tasks", ctx->args->freezer);
 	close(fd);
 	return 0;
 }
@@ -400,13 +397,14 @@ static int freezer_register(struct ckpt_ctx *ctx, pid_t pid)
 	fd = open(ctx->freezer, O_WRONLY, 0);
 	if (fd < 0) {
 		ckpt_perror("freezer path");
-		return -1;
+		return ctx_set_errno(ctx);
 	}
 
 	n = sprintf(pidstr, "%d", pid);
 	ret = write(fd, pidstr, n);
 	if (ret != n) {
 		ckpt_perror("adding pid %d to freezer");
+		ctx_set_errno(ctx);
 		close(fd);
 		return -1;
 	}
-- 
1.7.1
