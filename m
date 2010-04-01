From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 4/6][v3][lxc] Move get_init_pid() into checkpoint.c
Date: Wed, 31 Mar 2010 18:56:33 -0700
Message-ID: <20100401015633.GD25712@us.ibm.com>
References: <20100401015503.GA25228@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100401015503.GA25228-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Mon, 29 Mar 2010 23:53:55 -0700
Subject: [PATCH 4/6][v3][lxc] Move get_init_pid() into checkpoint.c

lxc_attach.c is currently not included in liblxc.so. In  afollowon
patch, checkpoint() function needs to also use the get_init_pid()
interface. So move the defintions into checkpoint.c - which would
then be accessible to both lxc_attach and lxc-checkpoint.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 src/lxc/checkpoint.c |   29 +++++++++++++++++++++++++++++
 src/lxc/lxc.h        |    6 ++++++
 src/lxc/lxc_attach.c |   29 +----------------------------
 3 files changed, 36 insertions(+), 28 deletions(-)

diff --git a/src/lxc/checkpoint.c b/src/lxc/checkpoint.c
index 7e8a93e..4e75cb6 100644
--- a/src/lxc/checkpoint.c
+++ b/src/lxc/checkpoint.c
@@ -22,9 +22,38 @@
  */
 #include <lxc/lxc.h>
 #include <lxc/log.h>
+#include <lxc/commands.h>
 
 lxc_log_define(lxc_checkpoint, lxc);
 
+pid_t get_init_pid(const char *name)
+{
+	struct lxc_command command = {
+		.request = { .type = LXC_COMMAND_PID },
+	};
+
+	int ret, stopped = 0;
+
+	ret = lxc_command(name, &command, &stopped);
+	if (ret < 0 && stopped) {
+		INFO("'%s' is already stopped", name);
+		return 0;
+	}
+
+	if (ret < 0) {
+		ERROR("failed to send command");
+		return -1;
+	}
+
+	if (command.answer.ret) {
+		ERROR("failed to retrieve the init pid: %s",
+		      strerror(-command.answer.ret));
+		return -1;
+	}
+
+	return command.answer.pid;
+}
+
 int lxc_checkpoint(const char *name, const char *statefile, int flags)
 {
 	return 0;
diff --git a/src/lxc/lxc.h b/src/lxc/lxc.h
index b0b9f4e..bd87bdb 100644
--- a/src/lxc/lxc.h
+++ b/src/lxc/lxc.h
@@ -27,6 +27,7 @@
 extern "C" {
 #endif
 
+#include <unistd.h>
 #include <stddef.h>
 #include <lxc/state.h>
 
@@ -56,6 +57,11 @@ extern int lxc_start(const char *name, char *const argv[], struct lxc_conf *);
 extern int lxc_stop(const char *name);
 
 /*
+ * Get the pid of the root application process tree in parent-pid namespace
+ */
+extern pid_t get_init_pid(const char *name);
+
+/*
  * Open the monitoring mechanism for a specific container
  * The function will return an fd corresponding to the events
  * Returns a file descriptor on success, < 0 otherwise
diff --git a/src/lxc/lxc_attach.c b/src/lxc/lxc_attach.c
index a012c2c..3d2cdd5 100644
--- a/src/lxc/lxc_attach.c
+++ b/src/lxc/lxc_attach.c
@@ -28,6 +28,7 @@
 #include "commands.h"
 #include "arguments.h"
 #include "namespace.h"
+#include "lxc.h"
 #include "log.h"
 
 lxc_log_define(lxc_attach_ui, lxc);
@@ -50,34 +51,6 @@ Options :\n\
 	.checker  = NULL,
 };
 
-pid_t get_init_pid(const char *name)
-{
-	struct lxc_command command = {
-		.request = { .type = LXC_COMMAND_PID },
-	};
-
-	int ret, stopped = 0;
-
-	ret = lxc_command(name, &command, &stopped);
-	if (ret < 0 && stopped) {
-		INFO("'%s' is already stopped", name);
-		return 0;
-	}
-
-	if (ret < 0) {
-		ERROR("failed to send command");
-		return -1;
-	}
-
-	if (command.answer.ret) {
-		ERROR("failed to retrieve the init pid: %s",
-		      strerror(-command.answer.ret));
-		return -1;
-	}
-
-	return command.answer.pid;
-}
-
 int main(int argc, char *argv[], char *envp[])
 {
 	int ret;
-- 
1.6.0.4
