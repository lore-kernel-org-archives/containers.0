From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 12/12][user-cr] Have app_restart() return pid
Date: Fri, 5 Mar 2010 14:40:26 -0800
Message-ID: <20100305224026.GL15939@us.ibm.com>
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
Date: Fri, 5 Mar 2010 10:24:53 -0800
Subject: [PATCH 12/12][user-cr] Have app_restart() return pid

On success, return the pid of a the root of the restarted process tree.
This would enable callers to manage the restarted process-tree as a cgroup.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart-main.c |    7 ++++++-
 restart.c      |    6 ++++++
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/restart-main.c b/restart-main.c
index 96bca42..39ab05a 100644
--- a/restart-main.c
+++ b/restart-main.c
@@ -333,6 +333,7 @@ static void parse_args(struct app_restart_args *args, int argc, char *argv[])
 
 int main(int argc, char *argv[])
 {
+	int ret;
 	struct app_restart_args args;
 
 	/*
@@ -346,6 +347,10 @@ int main(int argc, char *argv[])
 
 	parse_args(&args, argc, argv);
 
-	return app_restart(&args);
+	ret = app_restart(&args);
+	if (ret > 0)
+		ret = 0;
+
+	return ret;
 }
 
diff --git a/restart.c b/restart.c
index 6ac4647..7ea3732 100644
--- a/restart.c
+++ b/restart.c
@@ -486,6 +486,12 @@ int app_restart(struct app_restart_args *args)
 		ret = ckpt_coordinator(&ctx);
 	}
 
+	/*
+	 * On success, return pid of root of the restart process tree.
+	 */
+	if (ret >= 0)
+		ret = global_child_pid;
+
 	return ret;
 }
 
-- 
1.6.0.4
