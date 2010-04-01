From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 5/6][v3][lxc] Hook up lxc_restart() with app_restart()
Date: Wed, 31 Mar 2010 18:56:51 -0700
Message-ID: <20100401015651.GE25712@us.ibm.com>
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
Date: Thu, 11 Mar 2010 20:47:56 -0800
Subject: [PATCH 5/6][v3][lxc] Hook up lxc_restart() with app_restart()

Have lxc_restart() call app_restart() implemented in the 'restart.o' from
USER-CR git tree.

Changelog[v3]:
	- (Daniel Lezcano) Remove unnecessary check for 'statefile' before
	  opening it
	- [Daniel Lezcano] Rebase to more recent version and use
	  lxc_check_inherited() instead of lxc_close_inherited_fd().
	- Have lxc_restart unfreeze the container if the --pause option
	  was not specified.
	- Use -D LIBCR to fix compile error when --with-libcr config is
	  not specified. Return ENOSYS if built with LIBCR undefined.
	- Implement the --pause option to set the RESTART_FROZEN flag.

Changelog[v2]:
	- Link with restart.o from usercr rather than libcheckpoint.a
	- rename 'struct restart_args' to 'struct app_restart_args'
	- Initialize the new field app_restart_args->uerrfd
	- (Oren Laadan)Remove ->send_sigint field from 'struct app_restart_args'

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 src/lxc/restart.c |  129 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 128 insertions(+), 1 deletions(-)

diff --git a/src/lxc/restart.c b/src/lxc/restart.c
index 467489e..c9ff565 100644
--- a/src/lxc/restart.c
+++ b/src/lxc/restart.c
@@ -22,11 +22,138 @@
  */
 #include <lxc/lxc.h>
 #include <lxc/log.h>
+#include <lxc/start.h>
+#include <lxc/namespace.h>
+#include <lxc/cgroup.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <signal.h>
+#include <sys/prctl.h>
+#include <sys/wait.h>
+#include "error.h"
+#ifdef LIBCR
+#include <app-checkpoint.h>
+#endif
 
 lxc_log_define(lxc_restart, lxc);
 
+#ifdef LIBCR
+
+struct lxc_restart_arg {
+	const char *name;
+	const char *statefile;
+	char *const argv;
+	struct lxc_handler *handler;
+	int lxc_flags;
+};
+
+static int do_restart(struct lxc_restart_arg *lxcarg)
+{
+	int pid;
+	int lxc_flags = lxcarg->lxc_flags;
+	struct lxc_handler *handler = lxcarg->handler;
+	const char *statefile = lxcarg->statefile;
+	struct app_restart_args restart_args;
+
+	if (sigprocmask(SIG_SETMASK, &handler->oldmask, NULL)) {
+		SYSERROR("failed to set sigprocmask");
+		return -1;
+	}
+
+	if (prctl(PR_SET_PDEATHSIG, SIGKILL, 0, 0, 0)) {
+		SYSERROR("failed to set pdeath signal");
+		return -1;
+	}
+
+	memset(&restart_args, 0, sizeof(restart_args));
+
+	restart_args.infd = open(statefile, O_RDONLY, 0);
+	if (restart_args.infd < 0) {
+		SYSERROR("Failed to open statefile %s\n", statefile);
+		return -1;
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
+	if (lxc_flags & LXC_FLAG_PAUSE)
+		restart_args.keep_frozen = 1;
+
+	pid = app_restart(&restart_args);
+
+	return pid;
+}
+
 int lxc_restart(const char *name, const char *statefile, struct lxc_conf *conf,
-		int flags)
+		int lxc_flags)
 {
+	int err;
+	int status;
+	struct lxc_handler *handler;
+	struct lxc_restart_arg lxcarg = {
+		.name = name,
+		.statefile = statefile,
+		.lxc_flags = lxc_flags,
+		.handler = NULL,
+	};
+
+	if (lxc_check_inherited())
+		return -1;
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
+	err = lxc_poll(name, handler);
+	if (err) {
+		ERROR("mainloop exited with an error");
+		goto out_abort;
+	}
+
+	while (waitpid(handler->pid, &status, 0) < 0 && errno == EINTR)
+		continue;
+
+	if (!(lxc_flags & LXC_FLAG_PAUSE)) {
+		err = lxc_unfreeze(name);
+		if (err) {
+			ERROR("lxc_restart(): Unable to unfreeze\n");
+			goto out_fini;
+		}
+	}
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
+#else
+int lxc_restart(const char *name, const char *statefile, struct lxc_conf *conf,
+		int lxc_flags)
+{
+	ERROR("'restart' function not configured");
+	ERROR("Try --with-libcr option to 'configure' script");
+	return -1;
+}
+#endif
-- 
1.6.0.4
