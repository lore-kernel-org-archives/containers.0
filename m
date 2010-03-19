From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 5/5][lxc] Hook up lxc_checkpoint() with app_checkpoint()
Date: Thu, 18 Mar 2010 23:41:41 -0700
Message-ID: <20100319064141.GF25732@us.ibm.com>
References: <20100319063912.GA25732@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100319063912.GA25732-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Thu, 11 Mar 2010 21:32:38 -0800
Subject: [PATCH 5/5][lxc] Hook up lxc_checkpoint() with app_checkpoint()

Have lxc_checkpoint() call app_checkpoint() implemented in checkpoint.o
in the USER-CR git tree

TODO:
	- Map lxc_flags to flags in sys_checkpoint()
	- Initialize app_checkpoint_args.debug and other fields based on
	  command line options to lxc_checkpoint rather than hard-coding
	  them

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 src/lxc/checkpoint.c |   91 +++++++++++++++++++++++++++++++++++++++++++++++++-
 src/lxc/commands.c   |    3 ++
 src/lxc/commands.h   |    1 +
 src/lxc/state.c      |   26 ++++++++++++++
 4 files changed, 120 insertions(+), 1 deletions(-)

diff --git a/src/lxc/checkpoint.c b/src/lxc/checkpoint.c
index 7e8a93e..0fbabc8 100644
--- a/src/lxc/checkpoint.c
+++ b/src/lxc/checkpoint.c
@@ -22,10 +22,99 @@
  */
 #include <lxc/lxc.h>
 #include <lxc/log.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <errno.h>
+#include <linux/checkpoint.h>
+
+#include "commands.h"
+#include "arguments.h"
+#include "app-checkpoint.h"
 
 lxc_log_define(lxc_checkpoint, lxc);
 
-int lxc_checkpoint(const char *name, const char *statefile, int flags)
+find_cinit_pid(const char *name)
 {
+	struct lxc_command command = {
+		.request = { .type = LXC_COMMAND_CINIT_PID },
+	};
+
+	int ret, stopped;
+
+	ret = lxc_command(name, &command, &stopped);
+	if (ret < 0) {
+		ERROR("failed to send command");
+		return -1;
+	}
+
+	ERROR("find_cinit_pid %d\n", command.answer.ret);
+
+	return command.answer.ret;
+}
+
+int lxc_checkpoint(const char *name, const char *statefile, int lxc_flags)
+{
+	int ret;
+	int pid;
+	int flags;
+	struct stat statbuf;
+	struct app_checkpoint_args crargs;
+
+	if (access(statefile, F_OK) == 0) {
+		ret = stat(statefile, &statbuf);
+		if (ret < 0) {
+			ERROR("stat(%s): %s\n", statefile, strerror(errno));
+			return -1;
+		}
+
+		if (S_ISDIR(statbuf.st_mode)) {
+			ERROR("--directory option not implemented");
+			return -1;
+		} else {
+			ERROR("Checkpoint image file %s exists\n", statefile);
+			return -1;
+		}
+	}
+
+	pid = find_cinit_pid(name);
+	if (pid < 0) {
+		ERROR("Unable to find cinit pid");
+		return -1;
+	}
+
+	memset(&crargs, 0, sizeof(crargs));
+
+	ret = open(statefile, O_CREAT|O_RDWR|O_EXCL, 0644);
+	if (ret < 0) {
+		ERROR("open(%s) failed\n", statefile);
+		return -1;
+	}
+
+	crargs.outfd = ret;
+	crargs.logfd = lxc_log_fd;
+	crargs.uerrfd = lxc_log_fd;
+	/*
+	 * TODO: Set this to 0 for now - otherwise we get an objhash leak
+	 * 	 due to mismatched references to current PTY which needs to
+	 * 	 be investigated.
+	 *
+	 * TODO: Map @lxc_flags to user-cr flags ?
+	 *
+	 * TODO: We can probably drop the ->container field since @flags
+	 * 	 can provide the same selection. 
+	 *
+	 * TODO: Do we may need a --container option to lxc_checkpoint or
+	 * 	 assume that we always work with full containers ?
+	 */
+	crargs.container = 0;
+
+	flags = CHECKPOINT_SUBTREE;
+
+	ret = app_checkpoint(pid, flags, &crargs);
+	if (ret < 0) {
+		ERROR("checkpoint of %s (pid %d) failed\n", name);
+		return -1;
+	}
+
 	return 0;
 }
diff --git a/src/lxc/commands.c b/src/lxc/commands.c
index 4c48571..af5c947 100644
--- a/src/lxc/commands.c
+++ b/src/lxc/commands.c
@@ -114,6 +114,8 @@ extern void lxc_console_remove_fd(int, struct lxc_tty_info *);
 extern int  lxc_console_callback(int, struct lxc_request *, struct lxc_handler *);
 extern int  lxc_stop_callback(int, struct lxc_request *, struct lxc_handler *);
 extern int  lxc_state_callback(int, struct lxc_request *, struct lxc_handler *);
+extern int  lxc_cinit_pid_callback(int, struct lxc_request *,
+				struct lxc_handler *);
 
 static int trigger_command(int fd, struct lxc_request *request,
 			   struct lxc_handler *handler)
@@ -124,6 +126,7 @@ static int trigger_command(int fd, struct lxc_request *request,
 		[LXC_COMMAND_TTY]   = lxc_console_callback,
 		[LXC_COMMAND_STOP]  = lxc_stop_callback,
 		[LXC_COMMAND_STATE] = lxc_state_callback,
+		[LXC_COMMAND_CINIT_PID] = lxc_cinit_pid_callback,
 	};
 
 	if (request->type < 0 || request->type >= LXC_COMMAND_MAX)
diff --git a/src/lxc/commands.h b/src/lxc/commands.h
index 3c6c082..22b24a9 100644
--- a/src/lxc/commands.h
+++ b/src/lxc/commands.h
@@ -27,6 +27,7 @@ enum {
 	LXC_COMMAND_TTY,
 	LXC_COMMAND_STOP,
 	LXC_COMMAND_STATE,
+	LXC_COMMAND_CINIT_PID,
 	LXC_COMMAND_MAX,
 };
 
diff --git a/src/lxc/state.c b/src/lxc/state.c
index ba63805..837d2da 100644
--- a/src/lxc/state.c
+++ b/src/lxc/state.c
@@ -168,3 +168,29 @@ out:
 	return ret;
 }
 
+extern int lxc_cinit_pid_callback(int fd, struct lxc_request *request,
+		struct lxc_handler *handler)
+{
+	struct lxc_answer answer;
+	int ret;
+	FILE *fp;
+
+	answer.ret = handler->pid;
+
+	INFO("Returning pid %d\n", handler->pid);
+
+	ret = send(fd, &answer, sizeof(answer), 0);
+	if (ret < 0) {
+		WARN("failed to send answer to the peer");
+		goto out;
+	}
+
+	if (ret != sizeof(answer)) {
+		ERROR("partial answer sent");
+		goto out;
+	}
+
+out:
+	return ret;
+}
+
-- 
1.6.6.1
