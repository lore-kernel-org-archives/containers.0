From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 4/5][lxc] Hook up lxc_restart() with app_restart()
Date: Thu, 18 Mar 2010 23:41:21 -0700
Message-ID: <20100319064121.GE25732@us.ibm.com>
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
Date: Thu, 11 Mar 2010 20:47:56 -0800
Subject: [PATCH 4/5][lxc] Hook up lxc_restart() with app_restart()

Have lxc_restart() call app_restart() implemented in the 'restart.o' from
USER-CR git tree.

Changelog[v2]:
	- Link with restart.o from usercr rather than libcheckpoint.a
	- rename 'struct restart_args' to 'struct app_restart_args'
	- Initialize the new field app_restart_args->uerrfd
	- (Oren Laadan)Remove ->send_sigint field from 'struct app_restart_args'
---
 src/lxc/restart.c |  104 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 104 insertions(+), 0 deletions(-)

diff --git a/src/lxc/restart.c b/src/lxc/restart.c
index 467489e..945435c 100644
--- a/src/lxc/restart.c
+++ b/src/lxc/restart.c
@@ -22,11 +22,115 @@
  */
 #include <lxc/lxc.h>
 #include <lxc/log.h>
+#include <lxc/start.h>
+#include <lxc/namespace.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <signal.h>
+#include <sys/prctl.h>
+#include <app-checkpoint.h>
+
+struct lxc_restart_arg {
+	const char *name;
+	const char *statefile;
+	char *const argv;
+	struct lxc_handler *handler;
+};
 
 lxc_log_define(lxc_restart, lxc);
 
+static int do_restart(struct lxc_restart_arg *lxcarg)
+{
+	int pid;
+	struct lxc_handler *handler = lxcarg->handler;
+	const char *name = lxcarg->name;
+	char *const argv = lxcarg->argv;
+	const char *statefile = lxcarg->statefile;
+	struct app_restart_args restart_args;
+
+        if (sigprocmask(SIG_SETMASK, &handler->oldmask, NULL)) {
+                SYSERROR("failed to set sigprocmask");
+                return -1;
+        }
+
+        if (prctl(PR_SET_PDEATHSIG, SIGKILL, 0, 0, 0)) {
+                SYSERROR("failed to set pdeath signal");
+                return -1;
+        }
+
+	memset(&restart_args, 0, sizeof(restart_args));
+
+	if (statefile) {
+		restart_args.infd = open(statefile, O_RDONLY, 0);
+		if (restart_args.infd < 0) {
+			SYSERROR("Failed to open statefile %s\n", statefile);
+			return -1;
+		}
+	}
+
+	restart_args.pids = 1;
+	restart_args.pidns = 1;
+	restart_args.mnt_pty = 1;
+	restart_args.mntns = 1;
+	restart_args.klogfd = -1;
+	restart_args.ulogfd = lxc_log_fd;
+	restart_args.uerrfd = fileno(stderr);
+	restart_args.debug = 1;
+	restart_args.wait = 0;
+
+        pid = app_restart(&restart_args);
+
+        return pid;
+}
+
 int lxc_restart(const char *name, const char *statefile, struct lxc_conf *conf,
 		int flags)
 {
+	int err;
+	int status;
+	struct lxc_handler *handler;
+	struct lxc_restart_arg lxcarg = {
+		.name = name,
+		.statefile = statefile,
+		.handler = NULL,
+	};
+
+	handler = lxc_init(name, conf);
+	if (!handler) {
+		ERROR("failed to initialize the container");
+		return -1;
+	}
+
+	lxcarg.handler = handler;
+	handler->pid = do_restart(&lxcarg);
+
+	INFO("do_restart(): returns pid %d\n", handler->pid);
+	lxc_rename_nsgroup(name, handler);
+
+	err = lxc_close_all_inherited_fd();
+	if (err) {
+		ERROR("unable to close inherited fds");
+		goto out_abort;
+	}
+
+	err = lxc_poll(name, handler);
+	if (err) {
+		ERROR("mainloop exited with an error");
+		goto out_abort;
+	}
+
+	while (waitpid(handler->pid, &status, 0) < 0 && errno == EINTR)
+		continue;
+
+	err =  lxc_error_set_and_log(handler->pid, status);
+
+out_fini:
+	lxc_fini(name, handler);
+	return err;
+
+out_abort:
+	lxc_abort(name, handler);
+	goto out_fini;
+
 	return 0;
 }
-- 
1.6.6.1
