From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 4/7] cr_tests: epoll: Factor out common parts
Date: Mon, 12 Oct 2009 12:38:25 -0700
Message-ID: <1255376302-11022-4-git-send-email-matthltc@us.ibm.com>
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

Factor out the common label, log, and print functions so that the
meat of the testcases is more apparent. Make the run.sh script use
this common structure to print INFO and try checkpointing at more
interesting points in the test programs.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 epoll/Makefile    |    7 ++-
 epoll/empty.c     |  120 +++++++++++++++++++++++++++++++++++++-----------
 epoll/libeptest.c |   65 ++++++++++++++++++++++++++
 epoll/libeptest.h |   83 +++++++++++++++++++++++++++++++++
 epoll/pipe.c      |  131 ++++-------------------------------------------------
 epoll/run.sh      |   56 +++++++++--------------
 6 files changed, 277 insertions(+), 185 deletions(-)
 create mode 100644 epoll/libeptest.c
 create mode 100644 epoll/libeptest.h

diff --git a/epoll/Makefile b/epoll/Makefile
index f6cae7e..f701352 100644
--- a/epoll/Makefile
+++ b/epoll/Makefile
@@ -1,6 +1,6 @@
 .PHONY: clean all
 
-LIBS := ../libcrtest/libcrtest.a
+LIBS := ../libcrtest/libcrtest.a ./libeptest.a
 CFLAGS := -Wall $(ARCHOPTS) -I../ -I../libcrtest
 
 PROGS=empty pipe
@@ -12,10 +12,13 @@ all: $(PROGS)
 ../libcrtest/libcrtest.a: ../libcrtest/libcrtest.h ../libcrtest/common.c
 	$(MAKE) -C ../libcrtest libcrtest.a
 
+libeptest.a: libeptest.o libeptest.h
+	ar cr libeptest.a libeptest.o
+
 $(PROGS): %: %.c $(LIBS)
 	gcc -Wall $(CFLAGS) -o $@ $< $(LIBS)
 
 clean:
-	rm -f $(PROGS)
+	rm -f $(PROGS) libeptest.[ao]
 	rm -rf log.* checkpoint-*
 	$(MAKE) -C ../libcrtest clean
diff --git a/epoll/empty.c b/epoll/empty.c
index c8c2109..1e7f7ce 100644
--- a/epoll/empty.c
+++ b/epoll/empty.c
@@ -11,6 +11,8 @@
 #include <errno.h>
 #include <unistd.h>
 #include <string.h>
+#include <limits.h>
+#include <getopt.h>
 
 /* open() */
 #include <sys/types.h>
@@ -20,59 +22,119 @@
 /* waitpid() and W* status macros */
 #include <sys/wait.h>
 
-/* epoll syscalls */
-#include <sys/epoll.h>
-
-#include "libcrtest/libcrtest.h"
+#include "libeptest.h"
 
 #define LOG_FILE	"log.empty"
-FILE *logfp = NULL;
+
+void usage(FILE *pout)
+{
+	fprintf(pout, "\nempty [-L] [-N] [-h|--help] [-l LABEL] [-n NUM]\n"
+"Create an empty epoll set.\n"
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
+	{0, 0, 0, 0},
+};
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
 
 /*
- * Log output with a tag (INFO, WARN, FAIL, PASS) and a format.
- * Adds information about the thread originating the message.
- *
- * Flush the log after every write to make sure we get consistent, and
- * complete logs.
+ * A LABEL is a point in the program we can goto where it's interesting to
+ * checkpoint. These enable us to have a set of labels that can be specified
+ * on the commandline.
  */
-#define log(tag, fmt, ...) \
-do { \
-	pid_t __tid = getpid(); \
-	fprintf(logfp, ("%s: thread %d: " fmt), (tag), __tid, ##__VA_ARGS__ ); \
-	fflush(logfp); \
-	fsync(fileno(logfp)); \
-} while(0)
-
-/* like perror() except to the log */
-#define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
+const char __attribute__((__section__(".LABELs"))) *first_label = "<start>";
 
 int main (int argc, char **argv)
 {
-	int efd;
+	int efd, ret = 0;
+	int op_num = 0;
+
+	parse_args(argc, argv);
 
 	/* FIXME eventually stdio streams should be harmless */
 	close(0);
-	logfp = fopen(LOG_FILE, "w");
+	logfp = fopen(LOG_FILE, "w+");
 	if (!logfp) {
 		perror("could not open logfile");
 		exit(1);
 	}
-	dup2(fileno(logfp), 1); /* redirect stdout and stderr to the log file */
-	dup2(fileno(logfp), 2);
+	/* redirect stdout and stderr to the log file */
+	if (dup2(fileno(logfp), 1) < 0) {
+		log_error("dup2(logfp, 1)");
+		goto out;
+	}
+	if (dup2(fileno(logfp), 2) < 0) {
+		log_error("dup2(logfp, 2)");
+		goto out;
+	}
 	if (!move_to_cgroup("freezer", "1", getpid())) {
 		log_error("move_to_cgroup");
 		exit(2);
 	}
 
-	efd = epoll_create(1);
+label(create,
+	efd, epoll_create(1));
 	if (efd < 0) {
 		perror("epoll_create(1)");
 		fclose(logfp);
 		exit(EXIT_FAILURE);
 	}
-	set_checkpoint_ready();
-	while (!test_checkpoint_done())
-		usleep(10000);
+label(do_nothing, ret, ret + 0);
+out:
 	if (close(efd) < 0) {
 		perror("close()");
 		fclose(logfp);
@@ -81,3 +143,5 @@ int main (int argc, char **argv)
 	fclose(logfp);
 	exit(EXIT_SUCCESS);
 }
+
+const char __attribute__((__section__(".LABELs"))) *last_label  = "<end>";
diff --git a/epoll/libeptest.c b/epoll/libeptest.c
new file mode 100644
index 0000000..2700ca9
--- /dev/null
+++ b/epoll/libeptest.c
@@ -0,0 +1,65 @@
+#include "libeptest.h"
+
+FILE *logfp = NULL;
+
+/* Print EPOLL flag */
+#define peflag(flag) \
+do { \
+	if (!(events & flag))  \
+		break; \
+	len = snprintf(p, sz, "%s%s", sep, stringify(flag)); \
+	if (len > 0) { \
+		sz -= len; \
+		p += len; \
+		sep = "|"; \
+	} else \
+		abort(); \
+} while (0)
+
+/* WARNING: Non-reentrant!! 
+ *
+ * Print out the epoll events
+ */
+const char * eflags(unsigned int events)
+{
+	static char buffer[256];
+	char *sep = "";
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
+/* Signal ready for and await the checkpoint */
+void do_ckpt(void)
+{
+	set_checkpoint_ready();
+	while (!test_checkpoint_done())
+		usleep(10000);
+
+}
+
+/* The spot (LABEL or label number) where we should test checkpoint/restart */
+char const *ckpt_label;
+int ckpt_op_num = 0;
diff --git a/epoll/libeptest.h b/epoll/libeptest.h
new file mode 100644
index 0000000..4854062
--- /dev/null
+++ b/epoll/libeptest.h
@@ -0,0 +1,83 @@
+/* epoll syscalls */
+#include <stdlib.h>
+#include <stdio.h>
+#include <unistd.h>
+
+#include <sys/epoll.h>
+
+#include "libcrtest/libcrtest.h"
+
+extern FILE *logfp;
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
+/* Non-reentrant!! */
+const char * eflags(unsigned int events);
+
+/*
+ * A LABEL is a point in the program we can goto where it's interesting to
+ * checkpoint. These enable us to have a set of labels that can be specified
+ * on the commandline.
+ */
+extern const char __attribute__((__section__(".LABELs"))) *first_label;
+extern const char __attribute__((__section__(".LABELs"))) *last_label;
+
+#define num_labels ((&last_label - &first_label) - 1)
+
+static inline const char * labels(int i)
+{
+	return (&first_label)[num_labels - i];
+}
+
+/* Print the labels that this program has to pout */
+void print_labels(FILE *pout);
+
+/* Signal ready for and await the checkpoint */
+void do_ckpt(void);
+
+/* The spot (LABEL or label number) where we should test checkpoint/restart */
+extern char const *ckpt_label;
+extern int ckpt_op_num;
+
+#define stringify(expr) #expr
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
diff --git a/epoll/pipe.c b/epoll/pipe.c
index 5d6def8..835caab 100644
--- a/epoll/pipe.c
+++ b/epoll/pipe.c
@@ -29,95 +29,15 @@
 /* waitpid() and W* status macros */
 #include <sys/wait.h>
 
-/* epoll syscalls */
-#include <sys/epoll.h>
-
-#include "libcrtest/libcrtest.h"
+#include "libeptest.h"
 
 #define LOG_FILE	"log.pipe"
-FILE *logfp = NULL;
-
-/*
- * Log output with a tag (INFO, WARN, FAIL, PASS) and a format.
- * Adds information about the thread originating the message.
- *
- * Flush the log after every write to make sure we get consistent, and
- * complete logs.
- */
-#define log(tag, fmt, ...) \
-do { \
-	pid_t __tid = getpid(); \
-	fprintf(logfp, ("%s: thread %d: " fmt), (tag), __tid, ##__VA_ARGS__ ); \
-	fflush(logfp); \
-	fsync(fileno(logfp)); \
-} while(0)
-
-/* like perror() except to the log */
-#define log_error(s) log("FAIL", "%s: %s\n", (s), strerror(errno))
-
-#define stringify(expr) #expr
-
-/* Print EPOLL flag */
-#define peflag(flag) \
-do { \
-	if (!events & flag)  \
-		break; \
-	len = snprintf(p, sz, stringify(flag)); \
-	if (len > 0) { \
-		sz -= len; \
-		p += len; \
-	} else \
-		abort(); \
-} while (0)
-
-const char * eflags(unsigned int events)
-{
-	static char buffer[256];
-	char *p = buffer;
-	size_t sz = 256;
-	int len;
-
-	peflag(EPOLLIN);
-	peflag(EPOLLPRI);
-	peflag(EPOLLOUT);
-	peflag(EPOLLERR);
-	peflag(EPOLLHUP);
-	peflag(EPOLLRDHUP);
-	peflag(EPOLLET);
-	peflag(EPOLLONESHOT);
-
-	return buffer;
-}
-#undef peflag
-
-/*
- * A LABEL is a point in the program we can goto where it's interesting to
- * checkpoint. These enable us to have a set of labels that can be specified
- * on the commandline.
- */
-const char __attribute__((__section__(".LABELs"))) *first_label = "<start>";
-const char __attribute__((__section__(".LABELs"))) *last_label;
-
-#define num_labels ((&last_label - &first_label) - 1)
-
-static inline const char * labels(int i)
-{
-	return (&first_label)[num_labels - i];
-}
-
-void print_labels(FILE *pout)
-{
-	int i;
-
-	if (num_labels > 0)
-		fprintf(pout, "\tNUM\tLABEL\n");
-	for (i = 0; i < num_labels; i++)
-		fprintf(pout, "\t%d\t%s\n", i, labels(i));
-}
 
 void usage(FILE *pout)
 {
-	fprintf(pout, "\nepoll_pipe [-L] [-N] [-h|--help] [-l LABEL] [-n NUM]\n"
+	fprintf(pout, "\npipe [-L] [-N] [-h|--help] [-l LABEL] [-n NUM]\n"
+"Create an epoll set and use it to wait for IO on a pipe.\n"
+"\n"
 "\t-L\tPrint the valid LABELs in order and exit.\n"
 "\t-l\tWait for checkpoint at LABEL.\n"
 "\t-N\tPrint the maximum label number and exit.\n"
@@ -138,10 +58,6 @@ const struct option long_options[] = {
 	{0, 0, 0, 0},
 };
 
-/* The spot (LABEL or label number) where we should test checkpoint/restart */
-char const *ckpt_label;
-int ckpt_op_num = 0;
-
 void parse_args(int argc, char **argv)
 {
 	ckpt_label = last_label;
@@ -182,39 +98,12 @@ void parse_args(int argc, char **argv)
 	}
 }
 
-/* Signal ready for and await the checkpoint */
-void do_ckpt(void)
-{
-	set_checkpoint_ready();
-	while (!test_checkpoint_done())
-		usleep(10000);
-
-}
-
-/* Label a spot in the code... */
-#define label(lbl, ret, action) \
-do { \
-	static char __attribute__((__section__(".LABELs"))) *___ ##lbl## _l = stringify(lbl); \
-	goto lbl ; \
-lbl: \
-\
-        log("INFO", "label: %s: \"%s\"\n", \
-		    labels(op_num), stringify(action)); \
-\
-	ret = action ; \
-\
-	if ((ckpt_op_num == op_num) || \
-	    (strcmp(ckpt_label, ___ ##lbl## _l) == 0)) \
-		do_ckpt(); \
-	if (ret < 0) { \
-		log("FAIL", "%d\t%s: %s\n", \
-		    op_num, ___ ##lbl## _l, stringify(action) ); \
-		goto out; \
-	} \
-	op_num++; \
-} while(0)
-
-#define HELLO "Hello world!\n"
+/*
+ * A LABEL is a point in the program we can goto where it's interesting to
+ * checkpoint. These enable us to have a set of labels that can be specified
+ * on the commandline.
+ */
+const char __attribute__((__section__(".LABELs"))) *first_label = "<start>";
 int main(int argc, char **argv)
 {
 	struct epoll_event ev[2] = {
diff --git a/epoll/run.sh b/epoll/run.sh
index 6ee475d..405692a 100755
--- a/epoll/run.sh
+++ b/epoll/run.sh
@@ -47,41 +47,35 @@ CURTEST=0
 
 while [ $CURTEST -lt $NUMTESTS ]; do
 	T=${TESTS[$CURTEST]}
-	set -x
-	if [ "${T}" == "pipe" ]; then
-		if (( IMAX < 0 )); then
-			((IMAX = $(./${T} -N)))
-			((I = 0))
-		fi
-		TARGS=( "-n" "${I}" )
-	else
-		TARGS=()
-		I=""
+	if (( IMAX < 0 )); then
+		((IMAX = $(./${T} -N)))
+		((I = 0))
+		echo "INFO: Test ${T} does:"
+		./${T} -h | sed -e 's/^/INFO:/'
 	fi
-	set +x
+	TLABEL=$(./${T} -L | head -n +$((I + 2)) | tail -n 1 | cut -f 3)
+	TARGS=( "-l" "${TLABEL}" )
 	trap 'do_err; break' ERR EXIT
 	rm -f ./checkpoint-{ready,done} TBROK
-	echo "Running test: ${T}"
-	set -x
+	echo "Running test: ${T} -l ${TLABEL}"
 	./${T} ${TARGS[@]} &
 	TEST_PID=$!
-	set +x
 	while [ '!' -r "./checkpoint-ready" ]; do
 		sleep 1
 	done
 	freeze
 	trap 'thaw; do_err; break' ERR EXIT
 	sync
-	cp log.${T} log.${T}${I}.pre-ckpt
+	cp log.${T} log.${T}${LABEL}.pre-ckpt
 	err_msg="FAIL"
-	${CHECKPOINT} ${TEST_PID} > checkpoint-${T}${I}
+	${CHECKPOINT} ${TEST_PID} > checkpoint-${T}${LABEL}
 	err_msg="BROK"
 	thaw
 	trap 'do_err; break' ERR EXIT
 	touch "./checkpoint-done"
 	wait ${TEST_PID}
 	retval=$?
-	echo "Test ${T}${I} done, returned ${retval}"
+	echo "Test ${T}${LABEL} done, returned ${retval}"
 	if [ -f "TBROK" ]; then
 		echo "BROK: epoll snafu, re-running this test"
 		continue
@@ -89,36 +83,30 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 	err_msg="FAIL"
 	[ $retval -eq 0 ]
 	err_msg="BROK"
-	echo PASS
+	echo "PASS ${T} ${TLABEL} original"
 
 	# now try restarting
-	mv log.${T} log.${T}${I}.post-ckpt
-	cp log.${T}${I}.pre-ckpt log.${T}
+	mv log.${T} log.${T}${LABEL}.post-ckpt
+	cp log.${T}${LABEL}.pre-ckpt log.${T}
 	err_msg="FAIL"
 	# --copy-status ensures that we trap on error.
-	${RESTART} --copy-status < checkpoint-${T}${I}
+	${RESTART} --copy-status < checkpoint-${T}${LABEL}
 	retval=$?
 	err_msg="FAIL"
 	[ ${retval} -eq 0 ];
-	echo PASS
+	echo "PASS ${T} ${TLABEL} restart"
 	err_msg="BROK"
-	if [ ! -f log.${T}${I} ]; then
-		mv log.${T} log.${T}${I}
+	if [ ! -f log.${T}${LABEL} ]; then
+		mv log.${T} log.${T}${LABEL}
 	fi
 	trap '' ERR EXIT
 
-	set -x
-	if [ "${T}" == "pipe" ]; then
-		((I = I + 1))
-		if (( I > IMAX )); then
-			((CURTEST = CURTEST + 1))
-			((IMAX = -1))
-			((I = 0))
-		fi
-	else
+	((I = I + 1))
+	if (( I > IMAX )); then
 		((CURTEST = CURTEST + 1))
+		((IMAX = -1))
+		((I = 0))
 	fi
-	set +x
 	wait
 done
 trap '' ERR EXIT
-- 
1.5.6.3
