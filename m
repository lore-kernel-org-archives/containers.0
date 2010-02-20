From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 9/9] cr_tests: fs: Add fsnotify test for dnotify
Date: Fri, 19 Feb 2010 18:18:57 -0800
Message-ID: <f89119d7952fdc8fbb0381b54e11c6b90e478076.1266632319.git.matthltc@us.ibm.com>
References: <1266632337-13792-1-git-send-email-matthltc@us.ibm.com>
	<72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc@us.ibm.com>
	<a5516d2e94b044e946ac039172a3d9cab0df0c1f.1266632319.git.matthltc@us.ibm.com>
	<7f04acbefe832b0bfaa832222da150c33af76ca8.1266632319.git.matthltc@us.ibm.com>
	<0efaca297a696880440a982210325dc7c473b13d.1266632319.git.matthltc@us.ibm.com>
	<dfc5e84b2c8940b07be485b8df1e530e4128e253.1266632319.git.matthltc@us.ibm.com>
	<970e1b8ed6c9322e3c069bae404b6d8cd17a7a94.1266632319.git.matthltc@us.ibm.com>
	<275a3dfd54a441b21e338bd4856c61be214ae12a.1266632319.git.matthltc@us.ibm.com>
	<dbe8e8154db60f36f7f22c5ec1c3218d765c5b62.1266632319.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <dbe8e8154db60f36f7f22c5ec1c3218d765c5b62.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Test that all dnotify flags are saved and restored properly.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/notify/dnotify.c |  226 +++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/notify/module.mk |   12 +++
 fs/notify/run.sh    |  146 +++++++++++++++++++++++++++++++++
 3 files changed, 384 insertions(+), 0 deletions(-)
 create mode 100644 fs/notify/dnotify.c
 create mode 100644 fs/notify/module.mk
 create mode 100755 fs/notify/run.sh

diff --git a/fs/notify/dnotify.c b/fs/notify/dnotify.c
new file mode 100644
index 0000000..9f7652d
--- /dev/null
+++ b/fs/notify/dnotify.c
@@ -0,0 +1,226 @@
+/*
+ * Copyright 2009 IBM Corp.
+ * Author: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+ */
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <fcntl.h> /* also for dnotify definitions like DN_* */
+#include <signal.h>
+#include <dirent.h> /* for dirfd */
+#include <assert.h>
+#include <getopt.h>
+#include <poll.h> /* POLL* definitions */
+#include <string.h>
+#include <errno.h>
+
+#include <sys/stat.h> /* for mkdir */
+#include <sys/types.h>
+
+#include "libcrtest/libcrtest.h"
+#include "libcrtest/labels.h"
+
+#define LOG_FILE	"log.dnotify"
+extern FILE *logfp;
+
+static void usage(FILE *pout)
+{
+	fprintf(pout, "\ndnotify [-L] [-N] [-h|--help] [-l LABEL] [-n NUM] [-f DIR]\n"
+"Create and monitor a directory with dnotify.\n"
+"\n"
+"\t-L\tPrint the valid LABELs in order and exit.\n"
+"\t-l\tWait for checkpoint at LABEL.\n"
+"\t-N\tPrint the maximum label number and exit.\n"
+"\t-n\tWait for checkpoint at NUM.\n"
+"\t-f\tUse cgroup specified by DIR to freeze.\n"
+"\n"
+"You may only specify one LABEL or NUM and you may not specify both.\n"
+"Label numbers are integers in the range 0-%d\n"
+"Valid label numbers and their corresponding LABELs are:\n", num_labels - 1);
+	print_labels(pout);
+}
+
+const struct option long_options[] = {
+	{ "print-labels",	0, 0, 'L'},
+	{ "print-max-label-no",	0, 0, 'N'},
+	{ "help",		0, 0, 'h'},
+	{ "label",		1, 0, 'l'},
+	{ "num",		1, 0, 'n'},
+	{ "freezer",		1, 0, 'f'},
+	{0, 0, 0, 0},
+};
+
+static char *freezer = "1";
+
+static void parse_args(int argc, char **argv)
+{
+	ckpt_op_num = num_labels - 1;
+	ckpt_label = labels[ckpt_op_num];
+	while (1) {
+		int c;
+		c = getopt_long(argc, argv, "f:LNhl:n:", long_options, NULL);
+		if (c == -1)
+			break;
+		switch(c) {
+		case 'f':
+			freezer = optarg;
+			printf("Will enter freezer cgroup %s\n", freezer);
+			break;
+		case 'L':
+			print_labels(stdout);
+			exit(EXIT_SUCCESS);
+			break;
+		case 'N':
+			printf("%d\n", num_labels - 1);
+			exit(EXIT_SUCCESS);
+			break;
+		case 'h':
+			usage(stdout);
+			exit(EXIT_SUCCESS);
+			break;
+		case 'l':
+			ckpt_label = optarg;
+			break;
+		case 'n':
+			if ((sscanf(optarg, "%d", &ckpt_op_num) < 1) ||
+			    (ckpt_op_num < 0) ||
+			    (ckpt_op_num >= num_labels)) {
+				fprintf(stderr, "Option -n requires an argument in the range 0-%d. Got %d\n", num_labels - 1, ckpt_op_num);
+				usage(stderr);
+				exit(EXIT_FAILURE);
+			}
+			break;
+		default: /* unknown option */
+			break;
+		}
+	}
+}
+
+#define eassert(cond) do { \
+	typeof(cond) ____cond = (cond); \
+	if (!____cond) \
+		perror(stringify(cond)); \
+	assert(!!____cond); \
+} while(0)
+
+#define DN_ALL (DN_CREATE|DN_DELETE|DN_RENAME|DN_ATTRIB|DN_MODIFY|DN_ACCESS)
+static int watchfd = -1;
+
+static void dnotify_sigio(int signo, siginfo_t *info, void *ucontext)
+{
+	assert(signo == SIGIO);
+	assert(info->si_signo == SIGIO);
+/*	assert(info->si_fd == watchfd);
+	assert(info->si_code == POLLMSG);
+	assert(info->si_band == (POLLIN|POLLRDNORM|POLLMSG));*/
+	/* TODO find a way to double-check dn_events ?? siginfo doesn't give enough */ \
+}
+
+#define dn_expect_events(dn_events) do { \
+	struct timespec __timeout = { \
+		.tv_sec = 1, \
+		.tv_nsec = 0 \
+	}; \
+	siginfo_t __info; \
+label(dn_events ## _sigio_wait, ret, sigtimedwait(&sigio, &__info, &__timeout)); \
+	dnotify_sigio(ret, &__info, NULL); \
+} while (0)
+
+int main (int argc, char **argv)
+{
+	const char *writ_contents = "hello world";
+	char contents[16];
+	sigset_t sigio;
+	DIR *dir;
+	int ret = 0, fd = -1;
+	int op_num = 0;
+
+	parse_args(argc, argv);
+
+	/* FIXME eventually stdio streams should be harmless */
+	close(0);
+	logfp = fopen(LOG_FILE, "w+");
+	if (!logfp) {
+		perror("could not open logfile");
+		exit(1);
+	}
+	/* redirect stdout and stderr to the log file */
+	if (dup2(fileno(logfp), 1) < 0) {
+		fprintf(logfp, "dup2(logfp, 1)\n");
+		goto out;
+	}
+	if (dup2(fileno(logfp), 2) < 0) {
+		fprintf(logfp, "dup2(logfp, 2)\n");
+		goto out;
+	}
+	if (!move_to_cgroup("freezer", freezer, getpid())) {
+		fprintf(logfp, "move_to_cgroup\n");
+		goto out;
+	}
+	printf("entered cgroup %s\n", freezer);
+	ret = mkdir("./dwatch", S_IRWXU);
+	eassert(ret == 0);
+	dir = opendir("./dwatch");
+	eassert(dir);
+	watchfd = dirfd(dir);
+	eassert(watchfd >= 0);
+
+	/* Block SIGIO -- handle it synchronously with dn_expect_events() */
+	ret = sigemptyset(&sigio);
+	eassert(ret == 0);
+	ret = sigaddset(&sigio, SIGIO);
+	eassert(ret == 0);
+	ret = sigprocmask(SIG_BLOCK, &sigio, NULL);
+	eassert(ret == 0);
+
+label(watch_create, ret, fcntl(watchfd, F_NOTIFY, DN_CREATE));
+label(do_create, ret, open("./dwatch/create", O_CREAT|O_EXCL|O_RDWR));
+	fd = ret;
+	assert(fd != watchfd);
+	assert(fd >= 0);
+	dn_expect_events(DN_CREATE);
+
+label(watch_modify, ret, fcntl(watchfd, F_NOTIFY, DN_MODIFY));
+label(do_modify, ret, write(fd, writ_contents, strlen(writ_contents) + 1));
+	assert(ret == (strlen(writ_contents) + 1));
+	dn_expect_events(DN_MODIFY);
+
+	ret = lseek(fd, 0, SEEK_SET);
+	assert(ret == 0);
+label(watch_access, ret, fcntl(watchfd, F_NOTIFY, DN_ACCESS));
+label(do_access, ret, read(fd, contents, strlen(writ_contents) + 1));
+	assert(ret == (strlen(writ_contents) + 1));
+	assert(strcmp(contents, writ_contents) == 0);
+	dn_expect_events(DN_ACCESS);
+
+label(watch_attrib, ret, fcntl(watchfd, F_NOTIFY, DN_ATTRIB));
+label(do_attrib, ret, fchmod(fd, S_IRUSR));
+	assert(ret == 0);
+	ret = close(fd);
+	assert(ret == 0);
+	fd = 0;
+	dn_expect_events(DN_ATTRIB);
+
+label(watch_rename, ret, fcntl(watchfd, F_NOTIFY, DN_RENAME));
+label(do_rename, ret, rename("./dwatch/create", "./dwatch/rename"));
+	assert(ret == 0);
+	dn_expect_events(DN_RENAME);
+
+label(watch_delete, ret, fcntl(watchfd, F_NOTIFY, DN_DELETE|DN_MULTISHOT));
+label(do_delete, ret, unlink("./dwatch/rename"));
+	assert(ret == 0);
+	dn_expect_events(DN_DELETE);
+label(do_rmdir, ret, rmdir("./dwatch"));
+	assert(ret == 0);
+	ret = EXIT_SUCCESS;
+out:
+	fprintf(logfp, "\nerrno: %s\n", strerror(errno));
+	if (fd >= 0)
+		close(fd);
+	closedir(dir);
+	fclose(logfp);
+	if (ret != EXIT_SUCCESS)
+		ret = EXIT_FAILURE;
+	exit(ret);
+}
+
diff --git a/fs/notify/module.mk b/fs/notify/module.mk
new file mode 100644
index 0000000..6c2eb44
--- /dev/null
+++ b/fs/notify/module.mk
@@ -0,0 +1,12 @@
+local_dir := fs/notify
+local_progs := $(addprefix $(local_dir)/, dnotify)
+
+sources += $(addprefix $(local_dir)/,../libfstest.c)
+progs += $(local_progs)
+test_clean += $(local_dir)/cr_fsnotify*
+
+# fs tests include libcrtest/libcrtest.h
+$(local_progs): CFLAGS += -D_GNU_SOURCE=1
+$(local_progs): CPPFLAGS += -I .
+$(local_progs): LDFLAGS += -Xlinker -dT -Xlinker libcrtest/labels.lds
+$(local_progs): $(local_dir)/../libfstest.o libcrtest/libcrtest.a
diff --git a/fs/notify/run.sh b/fs/notify/run.sh
new file mode 100755
index 0000000..603d7df
--- /dev/null
+++ b/fs/notify/run.sh
@@ -0,0 +1,146 @@
+#!/bin/bash
+
+
+source ../../common.sh
+dir=`mktemp -p . -d -t cr_fsnotify_XXXXXXX` || (echo "mktemp failed"; exit 1)
+echo "Using output dir $dir"
+cd $dir
+
+#
+# Check if the running kernel supports fsnotify
+#
+( if [ -r /proc/config.gz ]; then
+	zcat /proc/config.gz
+elif [ -r /proc/config ]; then
+	cat /proc/config
+# elif TODO look for CONFIG_DNOTIFY=y in /boot/config-$(uname -r)
+else
+# There is no way to test CONFIG_DNOTIFY -- assume it is set =y
+	echo 'CONFIG_DNOTIFY=y'
+fi ) | grep -E '^[[:space:]]*CONFIG_[DI]NOTIFY=y' > /dev/null 2>&1
+[ $? ] || {
+	echo "WARNING: Kernel does not support fsnotify (dnotify, inotify, fanotify). Skipping tests."
+	exit 1
+}
+
+TESTS=( dnotify )
+
+#make ${TESTS[@]}
+
+# mount -t cgroup foo /cg
+# mkdir /cg/1
+# chown -R $(id --name -u).$(id --name -g) /cg/1
+err_msg="BROK"
+function do_err()
+{
+       if [ -n "${TEST_PID}" ]; then
+               local PIDLIST=( $(ps --ppid ${TEST_PID} -o pid=) ${TEST_PID} )
+               kill ${PIDLIST[@]} || kill -9 ${PIDLIST[@]}
+       fi
+       echo "${err_msg}"
+       ((failed++))
+       wait
+}
+
+failed=0
+
+NUMTESTS=${#TESTS[@]}
+for (( CURTEST = 0; CURTEST < NUMTESTS; CURTEST = CURTEST + 1 )); do
+	T=${TESTS[$CURTEST]}
+	((IMAX = $(../${T} -N)))
+	echo "INFO: Test ${T} does:"
+	../${T} -L | sed -e 's/^/INFO:/'
+
+	TEST_LABELS=( $(../${T} -L | tail -n '+2' | cut -f 3) )
+
+	# First we run the test taking checkpoints at all the labelled points
+	rm -f "./checkpoint-"{ready,done,skip}
+	echo "Running test: \"${T}\""
+	../${T} &
+	TEST_PID=$!
+
+	trap 'do_err; break 2' ERR EXIT
+	for ((I = 0; I <= IMAX; I = I + 1)); do
+		TLABEL="${TEST_LABELS[$I]}"
+		while [ '!' -r "./checkpoint-ready" ]; do
+			sleep 0.1 # slow
+		done
+		echo "Taking checkpoint ${I}: ${TLABEL}."
+		freeze
+		trap 'thaw; do_err; break 2' ERR EXIT
+		sync # slow
+		cp log.${T} log.${T}.${I}.${TLABEL}
+		err_msg="FAIL"
+		${CHECKPOINT} ${TEST_PID} > "checkpoint-${T}.${I}.${TLABEL}"
+		err_msg="BROK"
+
+		# Reset for the next iteration
+		touch "./checkpoint-done"
+		thaw
+		trap 'do_err; break 2' ERR EXIT
+	done
+
+	sleep 0.1
+	while [ '!' -r "./checkpoint-done" ]; do
+		touch "./checkpoint-done"
+		sleep 0.1
+	done
+
+	echo "Done taking checkpoints. Waiting for ${TEST_PID} to finish."
+
+	# FAIL if the status of the test program's original run isn't 0.
+	err_msg="FAIL"
+	wait ${TEST_PID} || /bin/true # FIXME why can't we wait for TEST_PID ?
+	err_msg="BROK"
+
+	echo "Original completed running."
+
+	# Save the original run's log for later comparison.
+	mv log.${T} log.${T}.orig
+
+	# Now that the original, non-restart run is complete let's restart
+	# each checkpoint and make sure they produce the same results.
+	trap 'do_err; break 2' EXIT
+	trap '' ERR
+	echo "Restarting checkpoints"
+	for ((I=0; I <= IMAX; I = I + 1)); do
+		touch "./checkpoint-ready" "./checkpoint-done" "./checkpoint-skip"
+		TLABEL="${TEST_LABELS[$I]}"
+
+		# now try restarting. restore log first
+		cp log.${T}.${I}.${TLABEL} log.${T}
+		echo "Restart ${I} ${TLABEL}"
+		err_msg="FAIL"
+		# --copy-status ensures that we trap on error.
+		trap 'do_err; break 2' ERR
+		${RESTART} --copy-status -w < checkpoint-${T}.${I}.${TLABEL}
+		echo restart returned $?
+		trap '' ERR
+		err_msg="BROK"
+
+		# Now compare the logs. We can strip the thread id differences
+		# since all of these tests are single-threaded.
+		SEDEXPR='s/^INFO: thread [[:digit:]]\+: //'
+		sed -i -e "${SEDEXPR}" "log.${T}.orig"
+		sed -i -e "${SEDEXPR}" "log.${T}"
+
+		err_msg="FAIL"
+		diff -s -pu "log.${T}.orig" "log.${T}" > "log.${T}.${I}.${TLABEL}.diff"
+		err_msg="BROK"
+		echo "PASS \"${T}\""
+		rm -f "log.${T}.${I}.${TLABEL}"* "log.${T}" "checkpoint-${T}.${I}.${TLABEL}"
+	done
+	rm -f "log.${T}.orig"
+
+	trap '' EXIT
+	wait
+done
+trap '' EXIT
+
+rm -f "./checkpoint-"{ready,done,skip}
+
+
+# rmdir /cg/1
+# umount /cg
+
+exit ${failed}
-- 
1.6.3.3
