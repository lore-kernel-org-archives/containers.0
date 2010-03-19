From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 01/14][user-cr] Add app_restart_args->debug
Date: Thu, 18 Mar 2010 23:31:37 -0700
Message-ID: <20100319063137.GA24844@us.ibm.com>
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
Date: Thu, 4 Mar 2010 17:46:31 -0800
Subject: [PATCH 01/14][user-cr] Add app_restart_args->debug

Make 'debug' a field in struct app_restart_args so other callers of
app_restart() can also control the debug output of app_restart().

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/restart.c b/restart.c
index 0c74bb6..365b7ad 100644
--- a/restart.c
+++ b/restart.c
@@ -386,6 +386,7 @@ struct app_restart_args {
 	int infd;
 	int klogfd;
 	long warn;
+	int debug;
 	long fail;
 	int keep_lsm;
 };
@@ -581,7 +582,7 @@ static void parse_args(struct app_restart_args *args, int argc, char *argv[])
 			args->copy_status = 1;
 			break;
 		case 'd':
-			global_debug = 1;
+			global_debug = args->debug = 1;
 			break;
 		case 'F':
 			args->freezer = optarg;
@@ -815,6 +816,8 @@ int app_restart(struct app_restart_args *args)
 	memset(&ctx, 0, sizeof(ctx));
 	ctx.args = args;
 
+	global_debug = args->debug;
+
 	/* input file descriptor (default: stdin) */
 	if (args->infd >= 0) {
 		if (dup2(args->infd, STDIN_FILENO) < 0) {
-- 
1.6.0.4
