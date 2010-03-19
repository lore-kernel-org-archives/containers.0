From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 02/14][user-cr] Add app_restart_args->verbose
Date: Thu, 18 Mar 2010 23:31:51 -0700
Message-ID: <20100319063151.GB24844@us.ibm.com>
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
Date: Thu, 4 Mar 2010 17:53:27 -0800
Subject: [PATCH 02/14][user-cr] Add app_restart_args->verbose

Make 'verbose' a field in struct app_restart_args so other callers of
app_restart() can also control the verbose output of app_restart().

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/restart.c b/restart.c
index 365b7ad..9d16a4d 100644
--- a/restart.c
+++ b/restart.c
@@ -387,6 +387,7 @@ struct app_restart_args {
 	int klogfd;
 	long warn;
 	int debug;
+	int verbose;
 	long fail;
 	int keep_lsm;
 };
@@ -513,7 +514,7 @@ static void parse_args(struct app_restart_args *args, int argc, char *argv[])
 		case 'h':
 			usage(usage_str);
 		case 'v':
-			global_verbose = 1;
+			global_verbose = args->verbose = 1;
 			break;
 		case 5:  /* --inspect */
 			args->inspect = 1;
@@ -817,6 +818,7 @@ int app_restart(struct app_restart_args *args)
 	ctx.args = args;
 
 	global_debug = args->debug;
+	global_verbose = args->verbose;
 
 	/* input file descriptor (default: stdin) */
 	if (args->infd >= 0) {
-- 
1.6.0.4
