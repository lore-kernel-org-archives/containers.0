From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 2/2] Add keep_frozen field to struct app_restart_args
Date: Tue, 30 Mar 2010 23:56:02 -0700
Message-ID: <20100331065602.GA21318@us.ibm.com>
References: <20100331065443.GA21065@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100331065443.GA21065-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Tue, 30 Mar 2010 23:14:53 -0700
Subject: [PATCH 2/2] Add keep_frozen field to struct app_restart_args

Add a field, keep_frozen that callers of app_restart() can use to leave the
application frozen after restart. When this field is set, have app_restart()
set the RESTART_FROZEN flag to sys_restart().

TODO:
	For now, this field will be used in LXC containers.  A follow-on
	patch would add a command line option to /bin/restart to let users
	select this behavior.
---
 app-checkpoint.h |    3 +++
 restart.c        |    2 +-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/app-checkpoint.h b/app-checkpoint.h
index f740085..d2455f3 100644
--- a/app-checkpoint.h
+++ b/app-checkpoint.h
@@ -1,3 +1,5 @@
+#include <linux/checkpoint.h>
+#include <linux/checkpoint_hdr.h>
 
 struct app_checkpoint_args {
 	int outfd;
@@ -19,6 +21,7 @@ struct app_restart_args {
 	int show_status;
 	int copy_status;
 	char *freezer;
+	int keep_frozen;
 	int infd;
 	int klogfd;
 	int ulogfd;
diff --git a/restart.c b/restart.c
index 5408152..d5fee0b 100644
--- a/restart.c
+++ b/restart.c
@@ -914,7 +914,7 @@ static int ckpt_coordinator(struct ckpt_ctx *ctx)
 	if (ckpt_probe_child(root_pid, "root task") < 0)
 		exit(1);
 
-	if (ctx->args->freezer)
+	if (ctx->args->freezer || ctx->args->keep_frozen)
 		flags |= RESTART_FROZEN;
 	if (ctx->args->keep_lsm)
 		flags |= RESTART_KEEP_LSM;
-- 
1.6.6.1
