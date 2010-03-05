From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 02/12][user-cr] restart: Add args->send_sigint
Date: Fri, 5 Mar 2010 14:36:58 -0800
Message-ID: <20100305223658.GB15939@us.ibm.com>
References: <20100305223439.GA15300@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100305223439.GA15300-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Thu, 4 Mar 2010 17:37:39 -0800
Subject: [PATCH 02/12][user-cr] restart: Add args->send_sigint

restart command supports a command line option, --send-sigint to let
user specify whether SIGINT signal should be processed/ignored during
restart. Make this a field in 'struct app_restart_args' so that other
callers of app_restart() in the future can also control the SIGINT
behavior.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/restart.c b/restart.c
index 0c74bb6..314390c 100644
--- a/restart.c
+++ b/restart.c
@@ -376,6 +376,7 @@ struct app_restart_args {
 	int pids;
 	int pidns;
 	int inspect;
+	int send_sigint;
 	char *root;
 	int wait;
 	int mntns;
@@ -497,6 +498,7 @@ static void parse_args(struct app_restart_args *args, int argc, char *argv[])
 	args->klogfd = -1;
 	args->warn = CKPT_COND_WARN;
 	args->fail = CKPT_COND_FAIL;
+	args->send_sigint = -1;
 	no_pidns = 0;
 
 	klogfile = NULL;
@@ -554,7 +556,7 @@ static void parse_args(struct app_restart_args *args, int argc, char *argv[])
 				ckpt_err("restart: invalid signal\n");
 				exit(1);
 			}
-			global_send_sigint = sig;
+			args->send_sigint = sig;
 			break;
 		case 3:  /* --pids */
 			args->pids = 1;
@@ -815,6 +817,8 @@ int app_restart(struct app_restart_args *args)
 	memset(&ctx, 0, sizeof(ctx));
 	ctx.args = args;
 
+	global_send_sigint = args->send_sigint;
+
 	/* input file descriptor (default: stdin) */
 	if (args->infd >= 0) {
 		if (dup2(args->infd, STDIN_FILENO) < 0) {
-- 
1.6.0.4
