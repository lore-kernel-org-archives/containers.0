From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 2/2][LXC] Have lxc_restart call app_restart()
Date: Wed, 24 Feb 2010 00:41:56 -0800
Message-ID: <20100224084156.GH18758@us.ibm.com>
References: <20100224084108.GG18758@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100224084108.GG18758-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From 86023fbab91bc5c7a727e43e853615f27b70fbcf Mon Sep 17 00:00:00 2001
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Tue, 23 Feb 2010 22:38:14 -0800
Subject: [PATCH 2/2][LXC] Have lxc_restart call app_restart()

Have lxc_restart() call app_restart() exported by libcheckpoint.a from
the USER-CR git tree.

TODO: 	- Similarly implement lxc_checkpoint
	- Use dynamic linking with liblxc.so

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 src/lxc/Makefile2 |   16 +++++++++
 src/lxc/restart.c |   91 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 107 insertions(+), 0 deletions(-)
 create mode 100644 src/lxc/Makefile2

diff --git a/src/lxc/Makefile2 b/src/lxc/Makefile2
new file mode 100644
index 0000000..9aba841
--- /dev/null
+++ b/src/lxc/Makefile2
@@ -0,0 +1,16 @@
+
+CFLAGS = -static -I . -I ..
+
+LDFLAGS = /lib/libcheckpoint.a -lutil
+
+LXC_OBJS = start.o conf.o confile.o arguments.o monitor.o log.o mainloop.o \
+		utils.o commands.o state.o cgroup.o error.o namespace.o \
+		parse.o network.o af_unix.o console.o nl.o stop.o
+
+RESTART_OBJS = $(LXC_OBJS) lxc_restart.o restart.o
+
+lxc_restart: $(RESTART_OBJS)
+	$(CC) -o lxc_restart $(RESTART_OBJS) $(LDFLAGS)
+
+clean:
+	rm -f $(RESTART_OBJS)
diff --git a/src/lxc/restart.c b/src/lxc/restart.c
index 467489e..b49939a 100644
--- a/src/lxc/restart.c
+++ b/src/lxc/restart.c
@@ -22,11 +22,102 @@
  */
 #include <lxc/lxc.h>
 #include <lxc/log.h>
+#include <lxc/start.h>
+#include <lxc/namespace.h>
+#include <errno.h>
+#include <signal.h>
+#include <sys/prctl.h>
+#include <usercr.h>
 
 lxc_log_define(lxc_restart, lxc);
 
+struct lxc_restart_arg {
+	const char *name;
+	const char *statefile;
+	char *const argv;
+	struct lxc_handler *handler;
+};
+
+static int do_restart(struct lxc_restart_arg *lxcarg)
+{
+	int pid;
+	struct lxc_handler *handler = lxcarg->handler;
+	const char *name = lxcarg->name;
+	char *const argv = lxcarg->argv;
+	const char *statefile = lxcarg->statefile;
+	struct restart_args restart_args;
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
+	restart_args.pids = 1;
+	restart_args.pidns = 1;
+	restart_args.no_pidns = 0;
+	restart_args.mnt_pty = 1;
+	restart_args.input = statefile;
+	restart_args.infd = -1;
+	restart_args.logfd = lxc_log_fd;
+	restart_args.wait = 0;
+
+        pid = app_restart(&restart_args);
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
