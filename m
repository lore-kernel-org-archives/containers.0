From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 06/12][user-cr] Add app_restart_args->uerrfd
Date: Fri, 5 Mar 2010 14:38:26 -0800
Message-ID: <20100305223826.GF15939@us.ibm.com>
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
Date: Thu, 4 Mar 2010 22:36:31 -0800
Subject: [PATCH 06/12][user-cr] Add app_restart_args->uerrfd

Add a 'uerrfd' field in struct app_restart_args so other callers of
app_restart() can also choose a file descriptor for the error messages
from app_restart().

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/restart.c b/restart.c
index ac0acf3..d4a4000 100644
--- a/restart.c
+++ b/restart.c
@@ -387,6 +387,7 @@ struct app_restart_args {
 	int infd;
 	int klogfd;
 	int ulogfd;
+	int uerrfd;
 	long warn;
 	int debug;
 	int verbose;
@@ -500,6 +501,7 @@ static void parse_args(struct app_restart_args *args, int argc, char *argv[])
 	args->infd = -1;
 	args->klogfd = -1;
 	args->ulogfd = fileno(stdout);
+	args->uerrfd = fileno(stderr);
 	args->warn = CKPT_COND_WARN;
 	args->fail = CKPT_COND_FAIL;
 	args->send_sigint = -1;
@@ -825,6 +827,7 @@ int app_restart(struct app_restart_args *args)
 	global_debug = args->debug;
 	global_verbose = args->verbose;
 	global_ulogfd = args->ulogfd;
+	global_uerrfd = args->uerrfd;
 
 	/* input file descriptor (default: stdin) */
 	if (args->infd >= 0) {
-- 
1.6.0.4
