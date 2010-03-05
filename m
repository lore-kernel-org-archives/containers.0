From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 01/12][user-cr] restart: Mark globals as static
Date: Fri, 5 Mar 2010 14:36:37 -0800
Message-ID: <20100305223637.GA15939@us.ibm.com>
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
Date: Thu, 4 Mar 2010 17:41:04 -0800
Subject: [PATCH 01/12][user-cr] restart: Mark globals as static

app_restart() will in the future be exported to other programs.
To avoid potential variable-name collisions, make the globals
in restart.c static.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/restart.c b/restart.c
index 6994298..0c74bb6 100644
--- a/restart.c
+++ b/restart.c
@@ -301,15 +301,15 @@ struct ckpt_ctx {
  * TODO: Do we need to direct user-space restart messages to two different
  * 	 fds (like stdout and stderr) or can we just use one ?
  */
-int global_ulogfd;
-int global_uerrfd;
-int global_debug;
-int global_verbose;
-pid_t global_child_pid;
-int global_child_status;
-int global_child_collected;
-int global_send_sigint = -1;
-int global_sent_sigint;
+static int global_ulogfd;
+static int global_uerrfd;
+static int global_debug;
+static int global_verbose;
+static pid_t global_child_pid;
+static int global_child_status;
+static int global_child_collected;
+static int global_send_sigint = -1;
+static int global_sent_sigint;
 
 static int ckpt_remount_proc(struct ckpt_ctx *ctx);
 static int ckpt_remount_devpts(struct ckpt_ctx *ctx);
-- 
1.6.0.4
