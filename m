From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 12/14][user-cr] app_restart(): mnt-pty implies mntns
Date: Thu, 18 Mar 2010 23:34:19 -0700
Message-ID: <20100319063419.GL24844@us.ibm.com>
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
Date: Sat, 6 Mar 2010 12:49:40 -0800
Subject: [PATCH 12/14][user-cr] app_restart(): mnt-pty implies mntns

If the mount_pty is set, mntns must be implied, otherwise the newinstance
mount of devpts will make the ptys in the original pts instance inaccessible.

parse_args() does this correctly, but move the code into app_restart() so
other callers of app_restart() also get this behavior.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 restart-main.c |    4 ----
 restart.c      |    3 +++
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/restart-main.c b/restart-main.c
index 237742e..36318a4 100644
--- a/restart-main.c
+++ b/restart-main.c
@@ -324,10 +324,6 @@ static void parse_args(struct app_restart_args *args, int argc, char *argv[])
 			exit(1);
 		}
 	}
-
-
-	if (args->mnt_pty)
-		args->mntns = 1;
 }
 
 int main(int argc, char *argv[])
diff --git a/restart.c b/restart.c
index 139f6db..d7b5b72 100644
--- a/restart.c
+++ b/restart.c
@@ -404,6 +404,9 @@ int process_args(struct app_restart_args *args)
 	if (args->klogfd < 0)
 		args->klogfd = CHECKPOINT_FD_NONE;
 
+	if (args->mnt_pty)
+		args->mntns = 1;
+
 	return 0;
 }
 
-- 
1.6.0.4
