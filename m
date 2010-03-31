From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 6/6][lxc][v3] Hook up lxc_checkpoint() with app_checkpoint()
Date: Wed, 31 Mar 2010 00:10:16 -0700
Message-ID: <20100331071016.GF23567@us.ibm.com>
References: <20100331070440.GA21570@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100331070440.GA21570-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Subject: [PATCH 6/6][lxc][v3] Hook up lxc_checkpoint() with app_checkpoint()

Have lxc_checkpoint() call app_checkpoint() implemented in checkpoint.o
in the USER-CR git tree

TODO:
	- Map lxc_flags to flags in sys_checkpoint()
	- Initialize app_checkpoint_args.debug and other fields based on
	  command line options to lxc_checkpoint rather than hard-coding
	  them

Changelog:[v2]:
	- Drop find_cinit_pid() and use get_init_pid() from a recent checkin
	- Implement --pause and --kill options to lxc-checkpoint
	- Use -D LIBCR to fix compile error when --with-libcr config option
	  is not specified. Return ENOSYS when LIBCR is undefined.
	- Add CHECKPOINT_NONETNS to flags arg to app_checkpoint() which
	  is needed to checkpoint an application that is not in a private
	  netns (new in ckpt-v20-dev).

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 src/lxc/checkpoint.c |   88 ++++++++++++++++++++++++++++++++++++++++++++++++-
 src/lxc/state.c      |    1 -
 2 files changed, 86 insertions(+), 3 deletions(-)

diff --git a/src/lxc/checkpoint.c b/src/lxc/checkpoint.c
index 4e75cb6..6e905ff 100644
--- a/src/lxc/checkpoint.c
+++ b/src/lxc/checkpoint.c
@@ -22,7 +22,17 @@
  */
 #include <lxc/lxc.h>
 #include <lxc/log.h>
-#include <lxc/commands.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <errno.h>
+#include <linux/checkpoint.h>
+
+#include "commands.h"
+#include "arguments.h"
+#include "namespace.h"
+#ifdef LIBCR
+#include "app-checkpoint.h"
+#endif
 
 lxc_log_define(lxc_checkpoint, lxc);
 
@@ -54,7 +64,81 @@ pid_t get_init_pid(const char *name)
 	return command.answer.pid;
 }
 
-int lxc_checkpoint(const char *name, const char *statefile, int flags)
+#ifdef LIBCR
+int lxc_checkpoint(const char *name, const char *statefile, int lxc_flags)
 {
+	int ret;
+	int pid;
+	int flags;
+	struct app_checkpoint_args crargs;
+
+	pid = get_init_pid(name);
+	if (pid < 0) {
+		ERROR("Unable to find cinit pid");
+		return -1;
+	}
+
+	ret = lxc_freeze(name);
+	if (ret < 0)
+		return ret;
+
+	memset(&crargs, 0, sizeof(crargs));
+
+	ret = open(statefile, O_CREAT|O_RDWR|O_EXCL, 0600);
+	if (ret < 0) {
+		ERROR("open(%s) failed, %s\n", statefile, strerror(errno));
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
+	/*
+	 * TODO: Set the CHECKPOINT_NONETNS unconditionally for now. Otherwise
+	 * 	 it would require running the application in a private netns.
+	 * 	 Implement a command-line option to allow user selection.
+	 */
+	flags = CHECKPOINT_SUBTREE|CHECKPOINT_NONETNS;
+
+	ret = app_checkpoint(pid, flags, &crargs);
+	if (ret < 0) {
+		ERROR("checkpoint of %s (pid %d) failed\n", name, pid);
+		return -1;
+	}
+
+	if (lxc_flags & LXC_FLAG_HALT) {
+		ret = lxc_stop(name);
+		if (ret < 0)
+			return ret;
+
+		return lxc_unfreeze(name);
+	}
+
+	if (!(lxc_flags & LXC_FLAG_PAUSE))
+		return lxc_unfreeze(name);
+
 	return 0;
 }
+#else
+int lxc_checkpoint(const char *name, const char *statefile, int lxc_flags)
+{
+	ERROR("'checkpoint' not configured");
+	ERROR("Try --with-libcr option to 'configure' script");
+	return -1;
+}
+#endif
diff --git a/src/lxc/state.c b/src/lxc/state.c
index b29ae09..1e4c7e1 100644
--- a/src/lxc/state.c
+++ b/src/lxc/state.c
@@ -167,4 +167,3 @@ extern int lxc_state_callback(int fd, struct lxc_request *request,
 out:
 	return ret;
 }
-
-- 
1.6.6.1
