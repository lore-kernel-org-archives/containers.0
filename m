From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 00/10] container-based checkpoint/restart prototype
Date: Mon, 28 Feb 2011 19:08:52 -0600
Message-ID: <1298941732.25667.12.camel__5272.81954787231$1298941830$gmane$org@tp-t61>
References: <1298936432-29607-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1298936432-29607-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2011-02-28 at 17:40 -0600, ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org wrote:
> This is the tradeoff we ask users
> to make - the ability to C/R and migrate is provided in exchange for
> accepting some isolation and slightly reduced ease of use.  A tool
> such as lxc (http://lxc.sourceforge.net) can be used to isolate jobs.
> A patch against lxc is available which adds C/R capability.

Below is that patch (against the lxc-0.7.3 tag) and a usage example.

# export LXC_CMD_SOCK_ABSTRACT=test
# lxc-execute -n foo -- /bin/cat </dev/zero &>/dev/null &
# ps
  PID TTY          TIME CMD
 8736 pts/1    00:00:00 bash
 8842 pts/1    00:00:00 lxc-execute
 8843 pts/1    00:00:00 lxc-init
 8844 pts/1    00:00:01 cat
 8845 pts/1    00:00:00 ps
# lxc-checkpoint -S /tmp/ckpt.img -n foo -k
[1]+  Exit 137                lxc-execute -n foo -- /bin/cat < /dev/zero &>/dev/null
# ps
  PID TTY          TIME CMD
 8736 pts/1    00:00:00 bash
 8849 pts/1    00:00:00 ps
# lxc-restart -n foo -S /tmp/ckpt.img

[whee, watch resurrected /bin/cat eat cpu]

 doc/rootfs/Makefile.am |    2 +-
 lxc.spec.in            |    2 +-
 src/lxc/Makefile.am    |    3 +-
 src/lxc/checkpoint.c   |   59 ++++++-
 src/lxc/cr.h           |   71 ++++++++
 src/lxc/lxc_init.c     |  459 ++++++++++++++++++++++++++++++++++++++----------
 src/lxc/lxc_restart.c  |   25 ++-
 src/lxc/restart.c      |   77 --------
 src/lxc/start.c        |    3 +-
 templates/Makefile.am  |    2 +-
 10 files changed, 515 insertions(+), 188 deletions(-)

diff --git a/doc/rootfs/Makefile.am b/doc/rootfs/Makefile.am
index 98fb0e0..832bb4a 100644
--- a/doc/rootfs/Makefile.am
+++ b/doc/rootfs/Makefile.am
@@ -1,3 +1,3 @@
-READMEdir=@LXCROOTFSMOUNT@
+READMEdir=$(pkglibdir)/rootfs
 
 README_DATA=README
\ No newline at end of file
diff --git a/lxc.spec.in b/lxc.spec.in
index 379b53d..1ca6326 100644
--- a/lxc.spec.in
+++ b/lxc.spec.in
@@ -57,7 +57,7 @@ development of the linux containers.
 %setup
 %build
 PATH=$PATH:/usr/sbin:/sbin %configure
-make %{?_smp_mflags}
+make %{?_smp_mflags} CFLAGS='-Wall -Werror -g'
 
 %install
 %makeinstall
diff --git a/src/lxc/Makefile.am b/src/lxc/Makefile.am
index d2ee4d9..9e4d4c9 100644
--- a/src/lxc/Makefile.am
+++ b/src/lxc/Makefile.am
@@ -25,8 +25,7 @@ liblxc_so_SOURCES = \
 	monitor.c monitor.h \
 	console.c \
 	freezer.c \
-	checkpoint.c \
-	restart.c \
+	checkpoint.c cr.h\
 	error.h error.c \
 	parse.c parse.h \
 	cgroup.c cgroup.h \
diff --git a/src/lxc/checkpoint.c b/src/lxc/checkpoint.c
index a2d0d8a..b0c62a8 100644
--- a/src/lxc/checkpoint.c
+++ b/src/lxc/checkpoint.c
@@ -22,11 +22,64 @@
  */
 #include <lxc/lxc.h>
 #include <lxc/log.h>
+#include <stdlib.h>
+#include <sys/socket.h>
+#include <sys/un.h>
+#include <unistd.h>
+
+#include "af_unix.h"
+#include "cr.h"
 
 lxc_log_define(lxc_checkpoint, lxc);
 
-int lxc_checkpoint(const char *name, int sfd, int flags)
+int lxc_checkpoint(const char *name, int statefd, int flags)
 {
-	ERROR("'checkpoint' function not implemented");
-	return -1;
+	struct lxc_cr_cmd cmd = { .code = LXC_COMMAND_CHECKPOINT, };
+	struct lxc_cr_response response;
+	const char *cmd_sock_path;
+	char sun_path[sizeof(((struct sockaddr_un *)0)->sun_path)] = { 0 };
+	ssize_t ret;
+	int sockfd;
+
+	cmd_sock_path = getenv("LXC_CMD_SOCK_ABSTRACT");
+	if (!cmd_sock_path) {
+		ERROR("LXC_CMD_SOCK_ABSTRACT not set");
+		return -1;
+	}
+
+	strncpy(&sun_path[1], cmd_sock_path, sizeof(sun_path) - 2);
+
+	sockfd = lxc_af_unix_connect(sun_path);
+	if (sockfd == -1) {
+		ERROR("sock connect");
+		return -1;
+	}
+
+	ret = lxc_af_unix_send_fd(sockfd, statefd, &cmd, sizeof(cmd));
+	if (ret != sizeof(cmd)) {
+		ERROR("send fd");
+		return -1;
+	}
+
+	ret = recv(sockfd, &response, sizeof(response), 0);
+	if (ret != sizeof(response)) {
+		ERROR("recv");
+		return -1;
+	}
+
+	close(sockfd);
+
+	if (response.code != LXC_RESPONSE_SUCCESS) {
+		ERROR("checkpoint command failed (%u)", response.code);
+		return -1;
+	}
+
+	/* This is racy - we'd rather the container have no chance to
+	 * run between checkpoint and the stop request - but hopefully
+	 * it will do for now.
+	 */
+	if (flags & LXC_FLAG_HALT)
+		return lxc_stop(name);
+
+	return 0;
 }
diff --git a/src/lxc/cr.h b/src/lxc/cr.h
new file mode 100644
index 0000000..244c8f9
--- /dev/null
+++ b/src/lxc/cr.h
@@ -0,0 +1,71 @@
+/*
+ * lxc: Linux Container library
+ *
+ * Copyright IBM Corp. 2011
+ * This library is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU Lesser General Public
+ * License as published by the Free Software Foundation; either
+ * version 2.1 of the License, or (at your option) any later version.
+ *
+ * This library is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * Lesser General Public License for more details.
+ *
+ * You should have received a copy of the GNU Lesser General Public
+ * License along with this library; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ */
+
+#ifndef _LXC_CR_H
+
+#define _GNU_SOURCE
+#include <errno.h>
+#include <sys/syscall.h>
+#include <unistd.h>
+
+enum {
+	LXC_COMMAND_CHECKPOINT = 1,
+};
+
+enum {
+	LXC_RESPONSE_SUCCESS,
+	LXC_RESPONSE_FAILURE,
+};
+
+struct lxc_cr_cmd { unsigned int code; };
+struct lxc_cr_response { unsigned int code; };
+
+#ifndef SYS_checkpoint
+#if defined(__i386__)
+#define SYS_checkpoint 341
+#elif defined(__x86_64__)
+#define SYS_checkpoint 303
+#else
+#warning SYS_checkpoint not defined for this architecture
+#define SYS_checkpoint -1
+#endif
+#endif
+
+static inline int checkpoint(int fd, unsigned int flags)
+{
+	return syscall(SYS_checkpoint, fd, flags);
+}
+
+#ifndef SYS_restart
+#if defined(__i386__)
+#define SYS_restart 342
+#elif defined(__x86_64__)
+#define SYS_restart 304
+#else
+#warning SYS_restart not defined for this architecture
+#define SYS_restart -1
+#endif
+#endif
+
+static inline int restart(int fd, unsigned int flags)
+{
+	return syscall(SYS_restart, fd, flags);
+}
+
+#endif /* _LXC_CR_H */
diff --git a/src/lxc/lxc_init.c b/src/lxc/lxc_init.c
index a534b51..2e8f08a 100644
--- a/src/lxc/lxc_init.c
+++ b/src/lxc/lxc_init.c
@@ -1,10 +1,11 @@
 /*
  * lxc: linux Container library
  *
- * (C) Copyright IBM Corp. 2007, 2008
+ * (C) Copyright IBM Corp. 2007, 2008, 2011
  *
  * Authors:
  * Daniel Lezcano <dlezcano at fr.ibm.com>
+ * Nathan Lynch
  *
  * This library is free software; you can redistribute it and/or
  * modify it under the terms of the GNU Lesser General Public
@@ -21,21 +22,29 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
  */
 
-#include <stdio.h>
-#include <unistd.h>
-#include <stdlib.h>
+#define _GNU_SOURCE
+#include <assert.h>
 #include <errno.h>
-#include <signal.h>
+#include <getopt.h>
 #include <libgen.h>
+#include <signal.h>
+#include <stdbool.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <sys/epoll.h>
+#include <sys/signalfd.h>
+#include <sys/socket.h>
 #include <sys/stat.h>
 #include <sys/types.h>
+#include <sys/un.h>
 #include <sys/wait.h>
-#define _GNU_SOURCE
-#include <getopt.h>
 
-#include "log.h"
+#include "af_unix.h"
 #include "caps.h"
+#include "cr.h"
 #include "error.h"
+#include "log.h"
 #include "utils.h"
 
 lxc_log_define(lxc_init, lxc);
@@ -47,23 +56,305 @@ static struct option options[] = {
 	{ 0, 0, 0, 0 },
 };
 
-static	int was_interrupted = 0;
+static bool pidns_is_empty(void)
+{
+	assert(getpid() == (pid_t)1);
+
+	if (kill(-1, 0) == 0)
+		return false;
+	assert(errno == ESRCH);
+	return true;
+}
 
-int main(int argc, char *argv[])
+static struct lxc_init_state {
+	pid_t child_pid;             /* the child we initially created */
+	bool shutting_down;          /* we've received a request to exit */
+	bool child_status_collected; /* we've retrieved child_pid's status */
+	int exit_code;               /* status code to return from main() */
+	size_t nr_waited;            /* # children waited post-restart */
+} state;
+
+static void handle_sigterm(struct lxc_init_state *state)
 {
+	if (state->shutting_down)
+		return;
+
+	state->shutting_down = true;
+	kill(-1, SIGTERM);
+	alarm(1);
+}
+
+static void handle_sigalrm(struct lxc_init_state *state)
+{
+	kill(-1, SIGKILL);
+}
+
+static void handle_sigchld(struct lxc_init_state *state)
+{
+	pid_t pid;
+	int status;
+
+	while ((pid = waitpid(-1, &status, WNOHANG)) != 0) {
+
+		if (pid == (pid_t)-1)
+			return;
+
+		/* reset timer each time a process exits */
+		if (state->shutting_down)
+			alarm(1);
+
+		ERROR("collected pid %lu\n", (unsigned long)pid);
+
+		state->nr_waited++; /* for restart */
+
+		if (state->child_status_collected)
+			continue; /* don't care */
+
+		if (pid != state->child_pid)
+			continue; /* don't care */
+
+		state->child_status_collected = true;
+		state->exit_code = lxc_error_set_and_log(pid, status);
+	}
+}
+
+typedef void (*sigfd_handler_t)(struct lxc_init_state *);
+
+static const sigfd_handler_t sig_dispatch_table[NSIG] =
+{
+	[SIGTERM] = handle_sigterm,
+	[SIGALRM] = handle_sigalrm,
+	[SIGCHLD] = handle_sigchld,
+};
+
+static int epoll_sigfd_handler(struct lxc_init_state *state, int fd, uint32_t events)
+{
+	struct signalfd_siginfo siginfo;
+	int ret;
+
+	ret = read(fd, &siginfo, sizeof(struct signalfd_siginfo));
+	if (ret != sizeof(struct signalfd_siginfo)) {
+		ERROR("read signalfd");
+		return -1;
+	}
+
+	if (sig_dispatch_table[siginfo.ssi_signo] != NULL)
+		sig_dispatch_table[siginfo.ssi_signo](state);
+	else
+		kill(state->child_pid, siginfo.ssi_signo);
+
+	return 0;
+}
+
+static int epoll_cmd_handler(struct lxc_init_state *state, int listenfd, uint32_t events)
+{
+	struct lxc_cr_response response = { .code = LXC_RESPONSE_FAILURE, };
+	struct lxc_cr_cmd cmd;
+	int saved_errno;
+	ssize_t bytes;
+	int acceptfd;
+	int statefd;
+	int flags;
+	int rc;
+
+	acceptfd = accept(listenfd, NULL, NULL);
+	if (acceptfd == -1) {
+		ERROR("accept");
+		goto out;
+	}
+
+	statefd = -1;
+	bytes = lxc_af_unix_recv_fd(acceptfd, &statefd, &cmd, sizeof(cmd));
+
+	if (bytes == -1) {
+		ERROR("recv fd");
+		goto out;
+	}
+
+	if (cmd.code != LXC_COMMAND_CHECKPOINT) {
+		ERROR("unknown command %i", cmd.code);
+		goto out;
+	}
+
+	flags = 0;
+	rc = checkpoint(statefd, flags);
+	saved_errno = errno;
+	close(statefd);
+
+	if (rc == 0)
+		response.code = LXC_RESPONSE_SUCCESS;
+	else
+		ERROR("checkpoint error: %s", strerror(saved_errno));
+
+	bytes = send(acceptfd, &response, sizeof(response), 0);
+	if (bytes != sizeof(response))
+		ERROR("send (bytes = %zd)", bytes);
+out:
+	close(acceptfd);
+	return 0;
+}
+
+typedef int (*epoll_handler_t)(struct lxc_init_state *, int fd, uint32_t events);
+
+struct epoll_info;
+typedef int (*epoll_info_ctor_t)(struct epoll_info *);
+
+struct epoll_info {
+	const char *desc;        /* human-friendly string for debug/logging */
+	epoll_info_ctor_t ctor;  /* initializes fd */
+	epoll_handler_t handler; /* handles events from epoll_wait */
+	int fd;                  /* fd passed to epoll_ctl */
+	uint32_t events;         /* events relevant for this resource */
+};
+
+static int sigfd_ctor(struct epoll_info *info)
+{
+	sigset_t mask;
+
+	sigfillset(&mask);
+
+	return signalfd(-1, &mask, SFD_CLOEXEC);
+}
+
+static int cmd_sock_ctor(struct epoll_info *info)
+{
+	char sun_path[sizeof(((struct sockaddr_un *)0)->sun_path)] = { 0 };
+	const char *cmd_sock_path;
+	int fd;
+
+	cmd_sock_path = getenv("LXC_CMD_SOCK_ABSTRACT");
+	if (!cmd_sock_path) {
+		ERROR("LXC_CMD_SOCK_ABSTRACT not set");
+		return -1;
+	}
+
+	strncpy(&sun_path[1], cmd_sock_path, sizeof(sun_path) - 2);
+
+	fd = lxc_af_unix_open(sun_path, SOCK_STREAM, 0);
+	if (fd == -1)
+		return -1;
 
-	void interrupt_handler(int sig)
+	return fd;
+}
+
+static struct epoll_info epoll_info_table[] = {
+	{
+		.desc = "signalfd",
+		.ctor = sigfd_ctor,
+		.handler = epoll_sigfd_handler,
+		.events = EPOLLIN,
+	},
 	{
-		if (!was_interrupted)
-			was_interrupted = sig;
+		.desc = "command socket",
+		.ctor = cmd_sock_ctor,
+		.handler = epoll_cmd_handler,
+		.events = EPOLLIN | EPOLLPRI,
+	},
+};
+
+static const size_t epoll_info_table_size =
+	sizeof(epoll_info_table) / sizeof(epoll_info_table[0]);
+
+static int epoll_info_init_one(struct epoll_info *info, int epollfd)
+{
+	struct epoll_event event;
+
+	info->fd = info->ctor(info);
+	if (info->fd == -1)
+		return -1;
+
+	event.events = info->events;
+	event.data.ptr = info;
+
+	if (epoll_ctl(epollfd, EPOLL_CTL_ADD, info->fd, &event) == -1) {
+		ERROR("epoll_ctl");
+		return -1;
+	}
+
+	return 0;
+}
+
+static int epoll_setup(void)
+{
+	int epollfd;
+	int i;
+
+	epollfd = epoll_create1(O_CLOEXEC);
+	if  (epollfd == -1) {
+		ERROR("epoll_create1");
+		return epollfd;
+	}
+
+	for (i = 0; i < epoll_info_table_size; i++) {
+		struct epoll_info *info = &epoll_info_table[i];
+
+		if (epoll_info_init_one(info, epollfd) == -1) {
+			ERROR("%s failed", info->desc);
+			return -EINVAL;
+		}
 	}
 
+	return epollfd;
+}
+
+static int epoll_loop(int epollfd)
+{
+	do {
+		struct epoll_info *info;
+		struct epoll_event event;
+		int epollrc;
+
+		epollrc = epoll_wait(epollfd, &event, 1, -1);
+		if (epollrc == -1) {
+			/* e.g. SIGCONT from ptrace attach */
+			assert(errno == EINTR);
+			continue;
+		}
+
+		assert(event.data.ptr != NULL);
+
+		info = event.data.ptr;
+
+		assert(event.events & info->events);
+
+		if (info->handler(&state, info->fd, event.events) == -1)
+			return -1;
+	} while (!pidns_is_empty());
+
+	return 0;
+}
+
+static int get_restart_fd(void)
+{
+	const char *str;
+	int fd = -1;
+
+	str = getenv("LXC_RESTART_FD");
+	if (str) {
+		errno = 0;
+		fd = strtol(str, NULL, 0);
+		if (errno) {
+			ERROR("LXC_RESTART_FD has bad value '%s'", str);
+			fd = -1;
+		}
+	}
+
+	return fd;
+}
+
+int main(int argc, char *argv[])
+{
+	int restartfd;
+	int epollfd;
 	pid_t pid;
 	int nbargs = 0;
 	int err = -1;
 	char **aargv;
 	sigset_t mask, omask;
-	int i, shutdown = 0;
+	int i;
+
+	state.exit_code = EXIT_FAILURE;
+	state.nr_waited = 0;
 
 	while (1) {
 		int ret = getopt_long_only(argc, argv, "", options, NULL);
@@ -82,7 +373,9 @@ int main(int argc, char *argv[])
 	if (lxc_log_init(NULL, 0, basename(argv[0]), quiet))
 		exit(err);
 
-	if (!argv[optind]) {
+	restartfd = get_restart_fd();
+
+	if (!argv[optind] && restartfd == -1) {
 		ERROR("missing command to launch");
 		exit(err);
 	}
@@ -91,113 +384,89 @@ int main(int argc, char *argv[])
 	argc -= nbargs;
 
         /*
-	 * mask all the signals so we are safe to install a
+	 * mask most signals so we are safe to install a
 	 * signal handler and to fork
 	 */
 	sigfillset(&mask);
+	sigdelset(&mask, SIGILL);
+	sigdelset(&mask, SIGSEGV);
+	sigdelset(&mask, SIGBUS);
+	sigdelset(&mask, SIGFPE);
 	sigprocmask(SIG_SETMASK, &mask, &omask);
 
-	for (i = 1; i < NSIG; i++) {
-		struct sigaction act;
-
-		sigfillset(&act.sa_mask);
-		sigdelset(&mask, SIGILL);
-		sigdelset(&mask, SIGSEGV);
-		sigdelset(&mask, SIGBUS);
-		act.sa_flags = 0;
-		act.sa_handler = interrupt_handler;
-		sigaction(i, &act, NULL);
-	}
-
 	if (lxc_setup_fs())
 		exit(err);
 
 	if (lxc_caps_reset())
 		exit(err);
 
-	pid = fork();
-
-	if (pid < 0)
-		exit(err);
-
-	if (!pid) {
+	assert(pidns_is_empty());
 
-		/* restore default signal handlers */
-		for (i = 1; i < NSIG; i++)
-			signal(i, SIG_DFL);
+	/* restart */
+	if (restartfd != -1) {
+		unsigned int flags;
+		int ret;
 
-		sigprocmask(SIG_SETMASK, &omask, NULL);
+		epollfd = epoll_setup();
+		if (epollfd < 0)
+			exit(err);
 
-		NOTICE("about to exec '%s'", aargv[0]);
+		flags = 0;
+		ret = restart(restartfd, flags);
+		if (ret != 0) {
+			ERROR("restart: %s", strerror(errno));
+			goto out;
+		}
 
-		execvp(aargv[0], aargv);
-		ERROR("failed to exec: '%s' : %m", aargv[0]);
-		exit(err);
-	}
+		state.exit_code = epoll_loop(epollfd);
 
-	/* let's process the signals now */
-	sigdelset(&omask, SIGALRM);
-	sigprocmask(SIG_SETMASK, &omask, NULL);
+		/* FIXME: we don't know which pid's status should be
+		 * lxc-init's exit code
+		 */
 
-	/* no need of other inherited fds but stderr */
-	close(fileno(stdin));
-	close(fileno(stdout));
+		if (state.nr_waited > 1) {
+			ERROR("multiple task restart not supported yet");
+			state.exit_code = EXIT_FAILURE;
+		} else if (state.nr_waited == 0) {
+			ERROR("no tasks restarted?");
+			state.exit_code = EXIT_FAILURE;
+		}
 
-	err = 0;
-	for (;;) {
-		int status;
-		int orphan = 0;
-		pid_t waited_pid;
+		goto out;
+	} else { /* initial startup e.g. lxc-execute */
+		pid = fork();
 
-		switch (was_interrupted) {
+		if (pid < 0)
+			exit(err);
 
-		case 0:
-			break;
+		if (!pid) {
+			/* restore default signal handlers */
+			for (i = 1; i < NSIG; i++)
+				signal(i, SIG_DFL);
 
-		case SIGTERM:
-			if (!shutdown) {
-				shutdown = 1;
-				kill(-1, SIGTERM);
-				alarm(1);
-			}
-			break;
+			sigprocmask(SIG_SETMASK, &omask, NULL);
 
-		case SIGALRM:
-			kill(-1, SIGKILL);
-			break;
+			NOTICE("about to exec '%s'", aargv[0]);
 
-		default:
-			kill(pid, was_interrupted);
-			break;
+			execvp(aargv[0], aargv);
+			ERROR("failed to exec: '%s' : %m", aargv[0]);
+			exit(err);
 		}
 
-		was_interrupted = 0;
-		waited_pid = wait(&status);
-		if (waited_pid < 0) {
-			if (errno == ECHILD)
-				goto out;
-			if (errno == EINTR)
-				continue;
+		epollfd = epoll_setup();
+		if (epollfd < 0)
+			exit(err);
 
-			ERROR("failed to wait child : %s",
-			      strerror(errno));
-			goto out;
-		}
+		state.child_pid = pid;
+	}
 
-		/* reset timer each time a process exited */
-		if (shutdown)
-			alarm(1);
+/* wait: */
+	/* no need of other inherited fds but stderr */
+	close(fileno(stdin));
+	close(fileno(stdout));
+
+	epoll_loop(epollfd);
 
-		/*
-		 * keep the exit code of started application
-		 * (not wrapped pid) and continue to wait for
-		 * the end of the orphan group.
-		 */
-		if ((waited_pid != pid) || (orphan ==1))
-			continue;
-		orphan = 1;
-		err = lxc_error_set_and_log(waited_pid, status);
-	}
 out:
-	return err;
+	return state.exit_code;
 }
diff --git a/src/lxc/lxc_restart.c b/src/lxc/lxc_restart.c
index 7548682..3687429 100644
--- a/src/lxc/lxc_restart.c
+++ b/src/lxc/lxc_restart.c
@@ -37,7 +37,7 @@
 #include "confile.h"
 #include "arguments.h"
 
-lxc_log_define(lxc_restart_ui, lxc_restart);
+lxc_log_define(lxc_restart, lxc);
 
 static struct lxc_list defines;
 
@@ -109,8 +109,9 @@ Options :\n\
 
 int main(int argc, char *argv[])
 {
+	char *envstr;
+	static char **args;
 	int sfd = -1;
-	int ret;
 	char *rcfile = NULL;
 	struct lxc_conf *conf;
 
@@ -126,6 +127,10 @@ int main(int argc, char *argv[])
 			 my_args.progname, my_args.quiet))
 		return -1;
 
+	args = lxc_arguments_dup(LXCINITDIR "/lxc-init", &my_args);
+	if (!args)
+		return -1;
+
 	/* rcfile is specified in the cli option */
 	if (my_args.rcfile)
 		rcfile = (char *)my_args.rcfile;
@@ -162,7 +167,7 @@ int main(int argc, char *argv[])
 	if (my_args.statefd != -1)
 		sfd = my_args.statefd;
 
-#define OPEN_READ_MODE O_RDONLY | O_CLOEXEC | O_LARGEFILE
+#define OPEN_READ_MODE (O_RDONLY | O_LARGEFILE)
 	if (my_args.statefile) {
 		sfd = open(my_args.statefile, OPEN_READ_MODE, 0);
 		if (sfd < 0) {
@@ -171,9 +176,15 @@ int main(int argc, char *argv[])
 		}
 	}
 
-	ret = lxc_restart(my_args.name, sfd, conf, my_args.flags);
+	if (asprintf(&envstr, "LXC_RESTART_FD=%i", sfd) == -1) {
+		SYSERROR("asprintf: %s", strerror(errno));
+		return -1;
+	}
+
+	if (putenv(envstr) != 0) {
+		SYSERROR("putenv: %s", strerror(errno));
+		return -1;
+	}
 
-	if (my_args.statefile)
-		close(sfd);
-	return ret;
+	return lxc_start(my_args.name, args, conf);
 }
diff --git a/src/lxc/restart.c b/src/lxc/restart.c
deleted file mode 100644
index c947b81..0000000
--- a/src/lxc/restart.c
+++ /dev/null
@@ -1,77 +0,0 @@
-/*
- * lxc: linux Container library
- *
- * (C) Copyright IBM Corp. 2007, 2010
- *
- * Authors:
- * Daniel Lezcano <dlezcano at fr.ibm.com>
- *
- * This library is free software; you can redistribute it and/or
- * modify it under the terms of the GNU Lesser General Public
- * License as published by the Free Software Foundation; either
- * version 2.1 of the License, or (at your option) any later version.
- *
- * This library is distributed in the hope that it will be useful,
- * but WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * Lesser General Public License for more details.
- *
- * You should have received a copy of the GNU Lesser General Public
- * License along with this library; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
- */
-
-#include "../config.h"
-#include <stdio.h>
-#undef _GNU_SOURCE
-#include <string.h>
-#include <stdlib.h>
-#include <errno.h>
-#include <unistd.h>
-
-#include <lxc/log.h>
-#include <lxc/start.h>	/* for struct lxc_handler */
-#include <lxc/utils.h>
-#include <lxc/error.h>
-
-lxc_log_define(lxc_restart, lxc);
-
-struct restart_args {
-	int sfd;
-	int flags;
-};
-
-static int restart(struct lxc_handler *handler, void* data)
-{
-	struct restart_args *arg __attribute__ ((unused)) = data;
-
-	ERROR("'restart' function not implemented");
-	return -1;
-}
-
-static int post_restart(struct lxc_handler *handler, void* data)
-{
-	struct restart_args *arg __attribute__ ((unused)) = data;
-
-	NOTICE("'%s' container restarting with pid '%d'", handler->name,
-	       handler->pid);
-	return 0;
-}
-
-static struct lxc_operations restart_ops = {
-	.start = restart,
-	.post_start = post_restart
-};
-
-int lxc_restart(const char *name, int sfd, struct lxc_conf *conf, int flags)
-{
-	struct restart_args restart_arg = {
-		.sfd = sfd,
-		.flags = flags
-	};
-
-	if (lxc_check_inherited(sfd))
-		return -1;
-
-	return __lxc_start(name, conf, &restart_ops, &restart_arg);
-}
diff --git a/src/lxc/start.c b/src/lxc/start.c
index b963b85..8ff738f 100644
--- a/src/lxc/start.c
+++ b/src/lxc/start.c
@@ -629,8 +629,9 @@ int lxc_start(const char *name, char *const argv[], struct lxc_conf *conf)
 		.argv = argv,
 	};
 
+	/* At restart we allow lxc-init to inherit the fd for the image */
 	if (lxc_check_inherited(-1))
-		return -1;
+		ERROR("lxc_check_inherited failed; proceeding anyway");
 
 	return __lxc_start(name, conf, &start_ops, &start_arg);
 }
diff --git a/templates/Makefile.am b/templates/Makefile.am
index d55f53a..31de984 100644
--- a/templates/Makefile.am
+++ b/templates/Makefile.am
@@ -1,4 +1,4 @@
-templatesdir=@LXCTEMPLATEDIR@
+templatesdir=$(pkglibdir)
 
 templates_SCRIPTS = \
 	lxc-debian \
