From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 11/14][user-cr] restart: Define process_args()
Date: Thu, 18 Mar 2010 23:34:05 -0700
Message-ID: <20100319063405.GK24844@us.ibm.com>
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
Date: Sat, 6 Mar 2010 13:14:02 -0800
Subject: [PATCH 11/14][user-cr] restart: Define process_args()

Move the code that validates/processes the arguments into a separate
function.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |   27 ++++++++++++++++++++-------
 1 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/restart.c b/restart.c
index b6ee23c..139f6db 100644
--- a/restart.c
+++ b/restart.c
@@ -379,14 +379,12 @@ static int freezer_register(struct ckpt_ctx *ctx, pid_t pid)
 	return ret;
 }
 
-int app_restart(struct app_restart_args *args)
+/*
+ * Validate the specified arguments and initialize globals based on the
+ * arguments. Return 0 on success.
+ */
+int process_args(struct app_restart_args *args)
 {
-	struct ckpt_ctx ctx;
-	int ret;
-
-	memset(&ctx, 0, sizeof(ctx));
-	ctx.args = args;
-
 	global_debug = args->debug;
 	global_verbose = args->verbose;
 	global_ulogfd = args->ulogfd;
@@ -406,6 +404,21 @@ int app_restart(struct app_restart_args *args)
 	if (args->klogfd < 0)
 		args->klogfd = CHECKPOINT_FD_NONE;
 
+	return 0;
+}
+
+int app_restart(struct app_restart_args *args)
+{
+	struct ckpt_ctx ctx;
+	int ret;
+
+	memset(&ctx, 0, sizeof(ctx));
+	ctx.args = args;
+
+	ret = process_args(args);
+	if (ret < 0)
+		return ret;
+
 	/* freezer preparation */
 	if (args->freezer && freezer_prepare(&ctx) < 0)
 		exit(1);
-- 
1.6.0.4
