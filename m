From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 5/7] cr_tests: epoll: Add sk10k - poll io on ten thousand
	sockets with epoll
Date: Mon, 12 Oct 2009 12:38:26 -0700
Message-ID: <1255376302-11022-5-git-send-email-matthltc@us.ibm.com>
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

This test opens a specified number of socket pairs, sends a message over
each, reads the message, and exits. It uses epoll to "wait" for events
on the sockets. This tests epoll sets that may stress the watch
limit, the open file descriptor limit, and the limits of epoll c/r
itself.

Since an epoll item c/r struct takes 20 bytes on i386 we need at least
205 sockets to have multiple 4k pages worth of epoll items to
checkpoint.

The goal is to foil the kmalloc used to checkpoint epoll items in the kernel
such that we can't checkpoint them all in one go and without needing to
reproduce OOM conditions. Since we can't rely on PAGE_SIZE to calculate the
number of sockets needed to do this and since we're limited by rlimit
anyhow, we just go with the hard limit for now.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 epoll/Makefile |    2 +-
 epoll/run.sh   |    2 +-
 epoll/sk10k.c  |  311 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 313 insertions(+), 2 deletions(-)
 create mode 100644 epoll/sk10k.c

diff --git a/epoll/Makefile b/epoll/Makefile
index f701352..c94f5f5 100644
--- a/epoll/Makefile
+++ b/epoll/Makefile
@@ -3,7 +3,7 @@
 LIBS := ../libcrtest/libcrtest.a ./libeptest.a
 CFLAGS := -Wall $(ARCHOPTS) -I../ -I../libcrtest
 
-PROGS=empty pipe
+PROGS=empty pipe sk10k
 
 .PHONY: all clean
 
diff --git a/epoll/run.sh b/epoll/run.sh
index 405692a..6f64ee8 100755
--- a/epoll/run.sh
+++ b/epoll/run.sh
@@ -20,7 +20,7 @@ fi ) | grep -E '^[[:space:]]*CONFIG_EPOLL=y' > /dev/null 2>&1
 	exit 1
 }
 
-TESTS=( empty pipe )
+TESTS=( empty pipe sk10k )
 #make ${TESTS[@]}
 
 # mount -t cgroup foo /cg
diff --git a/epoll/sk10k.c b/epoll/sk10k.c
new file mode 100644
index 0000000..5cc4ea9
--- /dev/null
+++ b/epoll/sk10k.c
@@ -0,0 +1,311 @@
+/*
+ * Open a number of sockets, write sample content, seek to the beginning,
+ * and verify that the writes completed. This test is meant to run with
+ * thousands or more sockets open.
+ *
+ * Usage:
+ *         sk10k [-L|-l LABEL] [--help] [-n NUM]
+ * -L - Print the valid LABELs in order and exit.
+ * -l - Wait for checkpoint at LABEL.
+ * -N - Print the maximum label number and exit.
+ * -n - Wait for checkpoint at NUM.
+ * -h - help
+ * -s - num socket pairs
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
+/* socketpair AF_UNIX */
+#include <sys/socket.h>
+#include <sys/un.h>
+
+/* waitpid() and W* status macros */
+#include <sys/wait.h>
+
+#include "libeptest.h"
+
+#define LOG_FILE	"log.sk10k"
+
+void usage(FILE *pout)
+{
+	fprintf(pout, "\nsk10k [-L] [-N] [-h|--help] [-l LABEL] [-n NUM]\n"
+"Create a large number of sockets, add them to an epoll set, and use epoll to\n"
+"wait for IO on the sockets.\n"
+"\n"
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
+	{ "num-skp",		1, 0, 's'},
+	{0, 0, 0, 0},
+};
+
+int num_sk = 1000;
+
+void set_default_num_sk(void)
+{
+	struct rlimit lim;
+
+	/*
+	 * Get num_sk from hard rlimit. The goal of this default is to open
+	 * enough sockets that we can't kmalloc() enough space for all the
+	 * checkpointed epoll items at one time.
+	 */
+	getrlimit(RLIMIT_NOFILE, &lim);
+	num_sk = lim.rlim_cur & ~1; /* round down to nearest multiple of 2 */
+
+	/*
+	 * Of course if we're running as root then we may have an
+	 * insanely high rlimit -- so high that the test will never pass.
+	 * Keep it reasonable enough to pass.
+	 */
+	if (num_sk > 1000000)
+		num_sk = 1000000;
+}
+
+void parse_args(int argc, char **argv)
+{
+	ckpt_label = last_label;
+	ckpt_op_num = num_labels;
+
+	set_default_num_sk();
+
+	while (1) {
+		char c;
+		c = getopt_long(argc, argv, "LNhl:n:s:", long_options, NULL);
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
+			case 's':
+				if (sscanf(optarg, "%u", &num_sk) < 1) {
+					fprintf(stderr, "Option -f requires an argument in the range 1-INT_MAX. Got %d\n", num_sk);
+					usage(stderr);
+					exit(EXIT_FAILURE);
+				}
+				num_sk *= 2; /* pairs of sockets */
+
+				{
+					/* rlimit restricts max sk */
+					struct rlimit lim;
+					getrlimit(RLIMIT_NOFILE, &lim);
+					fprintf(stdout, "INFO: RLIMIT_NOFILE: soft (cur): %ld hard (max): %ld\n", lim.rlim_cur, lim.rlim_max);
+					if (num_sk >= lim.rlim_cur) {
+						fprintf(stderr, "WARN: process is restricted from opening %d sockets. Opening %ld instead.\n", num_sk, lim.rlim_cur);
+						num_sk = lim.rlim_cur;
+					}
+				}
+				break;
+			default: /* unknown option */
+				break;
+		}
+	}
+}
+
+const char __attribute__((__section__(".LABELs"))) *first_label = "<start>";
+int main(int argc, char **argv)
+{
+	char rbuf[128];
+	struct epoll_event *evs = NULL;
+	int *sk = NULL;
+	int op_num = 0;
+	int efd;
+	int ec = EXIT_FAILURE;
+	int ret;
+	int i;
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
+	sk = malloc(num_sk*sizeof(sk[0]));
+	if (!sk) {
+		log_error("sk = malloc()");
+		goto out;
+	}
+	evs = malloc(num_sk*sizeof(evs[0]));
+	if (!evs) {
+		log_error("evs = malloc()");
+		goto out;
+	}
+
+	if (!move_to_cgroup("freezer", "1", getpid())) {
+		log_error("move_to_cgroup");
+		exit(2);
+	}
+
+label(create,
+	efd, epoll_create(num_sk));
+
+label(open, ret, ret + 0);
+	for (i = 0; i < num_sk; i+=2) {
+		ret = socketpair(AF_UNIX, SOCK_SEQPACKET, 0, &sk[i]);
+		evs[i].data.fd = sk[i];
+		evs[i].events = EPOLLOUT;
+		evs[i + 1].data.fd = sk[i + 1];
+		evs[i + 1].events = EPOLLOUT;
+		ret = epoll_ctl(efd, EPOLL_CTL_ADD, sk[i], &evs[i]);
+		if (ret < 0) {
+			log("FAIL", "epoll_ctl(ADD, sk[%d])\n", i);
+			goto out;
+		}
+		ret = epoll_ctl(efd, EPOLL_CTL_ADD, sk[i + 1], &evs[i + 1]);
+		if (ret < 0) {
+			log("FAIL", "epoll_ctl(ADD, sk[%d])\n", i);
+			goto out;
+		}
+	}
+
+label(wait_write,
+	ret, epoll_wait(efd, evs, num_sk, 1000));
+	if (ret != num_sk) {
+		log_error("Expected epoll_wait() to return num_sk events.\n");
+		goto out;
+	}
+	for (i = 0; i < num_sk; i++) {
+		if (!(evs[i].events & EPOLLOUT)) {
+			log("FAIL", "Expected EPOLLOUT (0x%X) flag, got %s (0x%X)\n", 
+				  EPOLLOUT, eflags(evs[i].events), evs[i].events);
+			goto out;
+		}
+	}
+	for (i = 0; i < num_sk; i++) {
+		ret = write(sk[i], HELLO, strlen(HELLO) + 1);
+		if (ret < (strlen(HELLO) + 1)) {
+			log("FAIL", "Unable to write all %d bytes of \"%s\" to sk[%d] (%d)\n",
+				 strlen(HELLO) + 1, HELLO, i, sk[i]);
+			goto out;
+		}
+	}
+
+label(mod, ret, ret + 0);
+	for (i = 0; i < num_sk; i++) {
+		evs[i].events = EPOLLIN;
+		ret = lseek(sk[i], 0, SEEK_SET);
+		ret = epoll_ctl(efd, EPOLL_CTL_MOD, sk[i], &evs[i]);
+	}
+
+label(wait_read,
+	ret, epoll_wait(efd, evs, num_sk, 5000));
+	if (ret != num_sk) {
+		log_error("Expected epoll_wait() to return num_sk events.\n");
+		goto out;
+	}
+	for (i = 0; i < num_sk; i++) {
+		if (!(evs[i].events & EPOLLIN)) {
+			log("FAIL", "Expected EPOLLIN (0x%X) flag, got %s (0x%X)\n", 
+				  EPOLLIN, eflags(evs[i].events), evs[i].events);
+			goto out;
+		}
+	}
+
+label(do_read, ret, ret + 0);
+	for (i = 0; i < num_sk; i++) {
+		ret = read(sk[i], rbuf, strlen(HELLO) + 1);
+		if (ret < (strlen(HELLO) + 1)) {
+			log("FAIL", "Unable to read all %d bytes of \"%s\"\n",
+				 strlen(HELLO) + 1, HELLO);
+			goto out;
+		}
+		if (strcmp(HELLO, rbuf)) {
+			log("FAIL", "File was corrupted. Expected: \"%s\" Got: \"%s\"\n",
+				 HELLO, rbuf);
+			goto out;
+		}
+	}
+	log("INFO", "read len ok\n");
+	log("INFO", "read socket contents ok\n");
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
+	if (sk) {
+		for (i = 0; i < num_sk; i++) {
+			if (sk[i] >= 0) {
+				close(sk[i]);
+				sk[i] = -1;
+			}
+		}
+		free(sk);
+	}
+	if (evs)
+		free(evs);
+	fflush(logfp);
+	fclose(logfp);
+	exit(ec);
+}
+
+const char __attribute__((__section__(".LABELs"))) *last_label  = "<end>";
-- 
1.5.6.3
