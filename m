From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cr_tests: Add two testcases for epoll checkpoint/restart.
Date: Wed, 19 Aug 2009 22:05:44 -0700
Message-ID: <1250744745-1360-1-git-send-email-matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

The first, "empty" creates an empty epoll set, waits for checkpoint,
and closes it afterwards.

The second test creates and epoll set, adds the write end of a pipe,
waits for EPOLLOUT (writability) with epoll, writes, adds the
read end, removes the write end, waits for EPOLLIN (readability),
reads, and closes the epoll set.

Finally the patch adds a run.sh script much like the one for futexes.
This one contains modifications which run all of the "subtests" of
the pipe test as well.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 Makefile       |    2 +-
 epoll/Makefile |   21 ++++
 epoll/empty.c  |   83 ++++++++++++++
 epoll/pipe.c   |  338 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 epoll/run.sh   |  135 ++++++++++++++++++++++
 5 files changed, 578 insertions(+), 1 deletions(-)
 create mode 100644 epoll/Makefile
 create mode 100644 epoll/empty.c
 create mode 100644 epoll/pipe.c
 create mode 100755 epoll/run.sh

diff --git a/Makefile b/Makefile
index 5af82d6..79fa1bd 100644
--- a/Makefile
+++ b/Makefile
@@ -1,5 +1,5 @@
 SUBDIRS = libcrtest counterloop fileio simple cr-ipc-test userns ipc \
-	  sleep process-tree futex
+	  sleep process-tree futex epoll
 
 targets = ns_exec
 
diff --git a/epoll/Makefile b/epoll/Makefile
new file mode 100644
index 0000000..e1e3351
--- /dev/null
+++ b/epoll/Makefile
@@ -0,0 +1,21 @@
+.PHONY: clean all
+
+LIBS := ../libcrtest/libcrtest.a
+CFLAGS := -Wall $(ARCHOPTS) -I./libfutex -I../ -I../libcrtest
+
+PROGS=empty pipe
+
+.PHONY: all clean
+
+all: $(PROGS)
+
+../libcrtest/libcrtest.a: ../libcrtest/libcrtest.h ../libcrtest/common.c
+	$(MAKE) -C ../libcrtest libcrtest.a
+
+$(PROGS): %: %.c $(LIBS)
+	gcc -Wall $(CFLAGS) -o $@ $< $(LIBS)
+
+clean:
+	rm -f $(PROGS)
+	rm -rf log.* checkpoint-ready checkpoint-done
+	$(MAKE) -C ../libcrtest clean
diff --git a/epoll/empty.c b/epoll/empty.c
new file mode 100644
index 0000000..c8c2109
--- /dev/null
+++ b/epoll/empty.c
@@ -0,0 +1,83 @@
+/*
+ * Make sure epoll sets stay empty across c/r.
+ *
+ * epoll create
+ * checkpoint
+ * close epoll
+ */
+/* pretty standard stuff really */
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <unistd.h>
+#include <string.h>
+
+/* open() */
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+
+/* waitpid() and W* status macros */
+#include <sys/wait.h>
+
+/* epoll syscalls */
+#include <sys/epoll.h>
+
+#include "libcrtest/libcrtest.h"
+
+#define LOG_FILE	"log.empty"
+FILE *logfp = NULL;
+
+/*
+ * Log output with a tag (INFO, WARN, FAIL, PASS) and a format.
+ * Adds information about the thread originating the message.
+ *
+ * Flush the log after every write to make sure we get consistent, and
+ * complete logs.
+ */
+#define log(tag, fmt, ...) \
+do { \
+	pid_t __tid = getpid(); \
+	fprintf(logfp, ("%s: thread %d: " fmt), (tag), __tid, ##__VA_ARGS__ ); \
+	fflush(logfp); \
+	fsync(fileno(logfp)); \
+} while(0)
+
+/* like perror() except to the log */
+#define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
+
+int main (int argc, char **argv)
+{
+	int efd;
+
+	/* FIXME eventually stdio streams should be harmless */
+	close(0);
+	logfp = fopen(LOG_FILE, "w");
+	if (!logfp) {
+		perror("could not open logfile");
+		exit(1);
+	}
+	dup2(fileno(logfp), 1); /* redirect stdout and stderr to the log file */
+	dup2(fileno(logfp), 2);
+	if (!move_to_cgroup("freezer", "1", getpid())) {
+		log_error("move_to_cgroup");
+		exit(2);
+	}
+
+	efd = epoll_create(1);
+	if (efd < 0) {
+		perror("epoll_create(1)");
+		fclose(logfp);
+		exit(EXIT_FAILURE);
+	}
+	set_checkpoint_ready();
+	while (!test_checkpoint_done())
+		usleep(10000);
+	if (close(efd) < 0) {
+		perror("close()");
+		fclose(logfp);
+		exit(EXIT_FAILURE);
+	}
+	fclose(logfp);
+	exit(EXIT_SUCCESS);
+}
diff --git a/epoll/pipe.c b/epoll/pipe.c
new file mode 100644
index 0000000..7d1f5f0
--- /dev/null
+++ b/epoll/pipe.c
@@ -0,0 +1,338 @@
+/*
+ * Open a pipe and test whether epoll retrieves events related to IO on the
+ * pipe.
+ *
+ * Usage:
+ *         epoll_pipe [-L|-l LABEL] [--help] [-n NUM]
+ * -L - Print the valid LABELs in order and exit.
+ * -l - Wait for checkpoint at LABEL.
+ * -N - Print the maximum label number and exit.
+ * -n - Wait for checkpoint at NUM.
+ *
+ *  You may only specify one LABEL or NUM and you may not specify both.
+ */
+
+/* pretty standard stuff really */
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <unistd.h>
+#include <string.h>
+#include <limits.h>
+#include <getopt.h>
+
+/* open() */
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <fcntl.h>
+
+/* waitpid() and W* status macros */
+#include <sys/wait.h>
+
+/* epoll syscalls */
+#include <sys/epoll.h>
+
+#include "libcrtest/libcrtest.h"
+
+#define LOG_FILE	"log.pipe"
+FILE *logfp = NULL;
+
+/*
+ * Log output with a tag (INFO, WARN, FAIL, PASS) and a format.
+ * Adds information about the thread originating the message.
+ *
+ * Flush the log after every write to make sure we get consistent, and
+ * complete logs.
+ */
+#define log(tag, fmt, ...) \
+do { \
+	pid_t __tid = getpid(); \
+	fprintf(logfp, ("%s: thread %d: " fmt), (tag), __tid, ##__VA_ARGS__ ); \
+	fflush(logfp); \
+	fsync(fileno(logfp)); \
+} while(0)
+
+/* like perror() except to the log */
+#define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
+
+#define stringify(expr) #expr
+
+/* Print EPOLL flag */
+#define peflag(flag) \
+do { \
+	if (!events & flag)  \
+		break; \
+	len = snprintf(p, sz, stringify(flag)); \
+	if (len > 0) { \
+		sz -= len; \
+		p += len; \
+	} else \
+		abort(); \
+} while (0)
+
+const char * eflags(unsigned int events)
+{
+	static char buffer[256];
+	char *p = buffer;
+	size_t sz = 256;
+	int len;
+
+	peflag(EPOLLIN);
+	peflag(EPOLLPRI);
+	peflag(EPOLLOUT);
+	peflag(EPOLLERR);
+	peflag(EPOLLHUP);
+	peflag(EPOLLRDHUP);
+	peflag(EPOLLET);
+	peflag(EPOLLONESHOT);
+
+	return buffer;
+}
+#undef peflag
+
+/*
+ * A LABEL is a point in the program we can goto where it's interesting to
+ * checkpoint. These enable us to have a set of labels that can be specified
+ * on the commandline.
+ */
+const char __attribute__((__section__(".LABELs"))) *first_label = "<start>";
+const char __attribute__((__section__(".LABELs"))) *last_label;
+
+#define num_labels ((&last_label - &first_label) - 1)
+
+static inline const char * labels(int i)
+{
+	return (&first_label)[num_labels - i];
+}
+
+void print_labels(FILE *pout)
+{
+	int i;
+
+	if (num_labels > 0)
+		fprintf(pout, "\tNUM\tLABEL\n");
+	for (i = 0; i < num_labels; i++)
+		fprintf(pout, "\t%d\t%s\n", i, labels(i));
+}
+
+void usage(FILE *pout)
+{
+	fprintf(pout, "\nepoll_pipe [-L] [-N] [-h|--help] [-l LABEL] [-n NUM]\n"
+"\t-L\tPrint the valid LABELs in order and exit.\n"
+"\t-l\tWait for checkpoint at LABEL.\n"
+"\t-N\tPrint the maximum label number and exit.\n"
+"\t-n\tWait for checkpoint at NUM.\n"
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
+	{0, 0, 0, 0},
+};
+
+/* The spot (LABEL or label number) where we should test checkpoint/restart */
+char const *ckpt_label;
+int ckpt_op_num = 0;
+
+void parse_args(int argc, char **argv)
+{
+	ckpt_label = last_label;
+	ckpt_op_num = num_labels;
+	while (1) {
+		char c;
+		c = getopt_long(argc, argv, "LNhl:n:", long_options, NULL);
+		if (c == -1)
+			break;
+		switch(c) {
+			case 'L':
+				print_labels(stdout);
+				exit(EXIT_SUCCESS);
+				break;
+			case 'N':
+				printf("%d\n", num_labels - 1);
+				exit(EXIT_SUCCESS);
+				break;
+			case 'h':
+				usage(stdout);
+				exit(EXIT_SUCCESS);
+				break;
+			case 'l':
+				ckpt_label = optarg;
+				break;
+			case 'n':
+				if ((sscanf(optarg, "%d", &ckpt_op_num) < 1) ||
+				    (ckpt_op_num < 0) ||
+				    (ckpt_op_num >= num_labels)) {
+					fprintf(stderr, "Option -n requires an argument in the range 0-%d. Got %d\n", num_labels - 1, ckpt_op_num);
+					usage(stderr);
+					exit(EXIT_FAILURE);
+				}
+				break;
+			default: /* unknown option */
+				break;
+		}
+	}
+}
+
+/* Signal ready for and await the checkpoint */
+void do_ckpt(void)
+{
+	set_checkpoint_ready();
+	while (!test_checkpoint_done())
+		usleep(10000);
+
+}
+
+/* Label a spot in the code... */
+#define label(lbl, ret, action) \
+do { \
+	static char __attribute__((__section__(".LABELs"))) *___ ##lbl## _l = stringify(lbl); \
+	goto lbl ; \
+lbl: \
+\
+        log("INFO", "label: %s: \"%s\"\n", \
+		    labels(op_num), stringify(action)); \
+\
+	ret = action ; \
+\
+	if ((ckpt_op_num == op_num) || \
+	    (strcmp(ckpt_label, ___ ##lbl## _l) == 0)) \
+		do_ckpt(); \
+	if (ret < 0) { \
+		log("FAIL", "%d\t%s: %s\n", \
+		    op_num, ___ ##lbl## _l, stringify(action) ); \
+		goto out; \
+	} \
+	op_num++; \
+} while(0)
+
+#define HELLO "Hello world!\n"
+int main(int argc, char **argv)
+{
+	struct epoll_event ev[2] = {
+		{ .events = EPOLLIN,  },
+		{ .events = EPOLLOUT, },
+	};
+	int op_num = 0;
+	int tube[2];
+	int efd;
+	int ec = EXIT_FAILURE;
+	int ret;
+	char rbuf[128];
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
+		log_error("dup2(logfp, 1)");
+		goto out;
+	}
+	if (dup2(fileno(logfp), 2) < 0) {
+		log_error("dup2(logfp, 2)");
+		goto out;
+	}
+	if (!move_to_cgroup("freezer", "1", getpid())) {
+		log_error("move_to_cgroup");
+		exit(2);
+	}
+
+label(create,
+	efd, epoll_create(1));
+
+	ret = pipe(tube);
+	if (ret < 0)
+		goto out;
+	ev[0].data.fd = tube[0];
+	ev[1].data.fd = tube[1];
+
+label(ctl_add_wfd,
+	ret, epoll_ctl(efd, EPOLL_CTL_ADD, tube[1], &ev[1]));
+
+label(wait_write,
+	ret, epoll_wait(efd, &ev[1], 1, 1000));
+	if (ret != 1) {
+		log_error("Expected epoll_wait() to return one event.\n");
+		goto out;
+	}
+	if (!(ev[1].events & EPOLLOUT)) {
+		log("FAIL", "Expected EPOLLOUT (0x%X) flag, got %s (0x%X)\n", 
+			  EPOLLOUT, eflags(ev[1].events), ev[1].events);
+		goto out;
+	}
+
+label(do_write,
+	ret, write(tube[1], HELLO, strlen(HELLO) + 1));
+	if (ret < (strlen(HELLO) + 1)) {
+		log("FAIL", "Unable to write all %d bytes of \"%s\"\n",
+			 strlen(HELLO) + 1, HELLO);
+		goto out;
+	}
+
+label(ctl_add_rfd,
+	ret, epoll_ctl(efd, EPOLL_CTL_ADD, tube[0], &ev[0]));
+
+label(ctl_rm_wfd,
+	ret, epoll_ctl(efd, EPOLL_CTL_DEL, tube[1], &ev[1]));
+
+label(wait_read,
+	ret, epoll_wait(efd, &ev[0], 1, 5000));
+	if (ret != 1) {
+		log_error("Expected epoll_wait() to return one event.\n");
+		goto out;
+	}
+	if (!(ev[0].events & EPOLLIN)) {
+		log("FAIL", "Expected EPOLLIN (0x%X) flag, got %s (0x%X)\n", 
+			  EPOLLIN, eflags(ev[0].events), ev[0].events);
+		goto out;
+	}
+
+label(do_read,
+	ret, read(tube[0], rbuf, strlen(HELLO) + 1));
+	if (ret < (strlen(HELLO) + 1)) {
+		log("FAIL", "Unable to read all %d bytes of \"%s\"\n",
+			 strlen(HELLO) + 1, HELLO);
+		goto out;
+	}
+	log("INFO", "read len ok\n");
+	if (strcmp(HELLO, rbuf)) {
+		log("FAIL", "Pipe buffer was corrupted. Expected: \"%s\" Got: \"%s\"\n",
+			 HELLO, rbuf);
+		goto out;
+	}
+	log("INFO", "read buffer contents ok\n");
+	ec = EXIT_SUCCESS;
+	op_num = INT_MAX;
+
+out:
+	if ((efd >= 0) && close(efd) < 0) {
+		log_error("close()");
+		efd = -1;
+		goto out;
+	}
+	if (op_num != INT_MAX) {
+		log("FAIL", "error at label %s (op num: %d)\n",
+			  labels(op_num), op_num);
+	}
+	close(tube[0]);
+	close(tube[1]);
+	fflush(logfp);
+	fclose(logfp);
+	exit(ec);
+}
+
+const char __attribute__((__section__(".LABELs"))) *last_label  = "<end>";
diff --git a/epoll/run.sh b/epoll/run.sh
new file mode 100755
index 0000000..b37e2c0
--- /dev/null
+++ b/epoll/run.sh
@@ -0,0 +1,135 @@
+#!/bin/bash
+
+
+source ../common.sh
+
+#
+# Check if the running kernel supports futexes
+#
+( if [ -r /proc/config.gz ]; then
+	zcat /proc/config.gz
+elif [ -r /proc/config ]; then
+	cat /proc/config
+# elif TODO look for CONFIG_EPOLL=y in /boot/config-$(uname -r)
+else
+# There is no way to test CONFIG_EPOLL -- assume it is set =y
+	echo 'CONFIG_EPOLL=y'
+fi ) | grep -E '^[[:space:]]*CONFIG_EPOLL=y' > /dev/null 2>&1
+[ $? ] || {
+	echo "WARNING: Kernel does not support epoll. Skipping tests."
+	exit 1
+}
+
+TESTS=( empty pipe )
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
+               kill ${PIDLIST[@]}
+       fi
+       echo "${err_msg}"
+       ((failed++))
+       wait
+}
+
+failed=0
+
+
+NUMTESTS=${#TESTS[@]}
+CURTEST=0
+((IMAX = -1))
+
+while [ $CURTEST -lt $NUMTESTS ]; do
+	T=${TESTS[$CURTEST]}
+	set -x
+	if [ "${T}" == "pipe" ]; then
+		if (( IMAX < 0 )); then
+			((IMAX = $(./${T} -N)))
+			((I = 0))
+		fi
+		TARGS=( "-n" "${I}" )
+	else
+		TARGS=()
+		I=""
+	fi
+	set +x
+	trap 'do_err; break' ERR EXIT
+	rm -f ./checkpoint-{ready,done} TBROK
+	echo "Running test: ${T}"
+	set -x
+	./${T} ${TARGS[@]} &
+	TEST_PID=$!
+	set +x
+	while [ '!' -r "./checkpoint-ready" ]; do
+		sleep 1
+	done
+	freeze
+	trap 'thaw; do_err; break' ERR EXIT
+	sync
+	cp log.${T} log.${T}${I}.pre-ckpt
+	err_msg="FAIL"
+	ckpt ${TEST_PID} > checkpoint-${T}${I}
+	err_msg="BROK"
+	thaw
+	trap 'do_err; break' ERR EXIT
+	touch "./checkpoint-done"
+	wait ${TEST_PID}
+	retval=$?
+	echo "Test ${T}${I} done, returned ${retval}"
+	if [ -f "TBROK" ]; then
+		echo "BROK: epoll snafu, re-running this test"
+		continue
+	fi
+	err_msg="FAIL"
+	[ $retval -eq 0 ]
+	err_msg="BROK"
+	echo PASS
+
+	# now try restarting
+	mv log.${T} log.${T}${I}.post-ckpt
+	cp log.${T}${I}.pre-ckpt log.${T}
+	err_msg="FAIL"
+	# We need to pass -p to mktree since futexes often store the
+	# pid of the task that owns the futex in the futex, even in
+	# the uncontended cases where the kernel is entirely unaware
+	# of the futex. --copy-status ensures that we trap on error.
+	${MKTREE} -p --copy-status < checkpoint-${T}${I}
+	retval=$?
+	err_msg="FAIL"
+	[ ${retval} -eq 0 ];
+	echo PASS
+	err_msg="BROK"
+	if [ ! -f log.${T}${I} ]; then
+		mv log.${T} log.${T}${I}
+	fi
+	trap '' ERR EXIT
+
+	set -x
+	if [ "${T}" == "pipe" ]; then
+		((I = I + 1))
+		if (( I > IMAX )); then
+			((CURTEST = CURTEST + 1))
+			((IMAX = -1))
+			((I = 0))
+		fi
+	else
+		((CURTEST = CURTEST + 1))
+	fi
+	set +x
+	wait
+done
+trap '' ERR EXIT
+
+rm -f ./checkpoint-{ready,done}
+
+
+# rmdir /cg/1
+# umount /cg
+
+exit ${failed}
-- 
1.5.6.3
