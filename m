From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][cr-test]: filelock1: Test restore of adivsory locks during
	restart
Date: Wed, 20 Jan 2010 15:06:21 -0800
Message-ID: <20100120230621.GA30288@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


This test currently fails during restart on ckpt-v19-rc2.

On Serge's cr-next it fails cleanly during checkpoint due to:

	commit 5d1f1227384876dd13a66cad1f286d98f9b1891b
	Author: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
	Date:   Thu Dec 17 09:35:13 2009 -0800

	    ckpt-files: error out on file locks and leases

---
From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Fri, 15 Jan 2010 15:33:55 -0800
Subject: [PATCH] filelock1: Test restore of adivsory locks during restart

Test that any byte-range locks held by a process at the time of
checkpoint are restored correctly after restart.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fileio/Makefile         |    9 +-
 fileio/filelock1.c      |  383 +++++++++++++++++++++++++++++++++++++++++++++++
 fileio/run-filelock1.sh |  218 +++++++++++++++++++++++++++
 3 files changed, 608 insertions(+), 2 deletions(-)
 create mode 100644 fileio/filelock1.c
 create mode 100755 fileio/run-filelock1.sh

diff --git a/fileio/Makefile b/fileio/Makefile
index 071a9eb..40d19da 100644
--- a/fileio/Makefile
+++ b/fileio/Makefile
@@ -1,6 +1,11 @@
-targets = fileio1
+targets = fileio1 filelock1
 
-all: $(targets)
+INCLUDE   = ../libcrtest
+LIBCRTEST = ../libcrtest/common.o
+CFLAGS    = -I $(INCLUDE)
+LDFLAGS   = $(LIBCRTEST)
+
+all: $(LIBCRTEST) $(targets)
 
 clean:
 	rm -f $(targets)
diff --git a/fileio/filelock1.c b/fileio/filelock1.c
new file mode 100644
index 0000000..305cbeb
--- /dev/null
+++ b/fileio/filelock1.c
@@ -0,0 +1,383 @@
+#include <stdio.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <string.h>
+#include <signal.h>
+#include <errno.h>
+#include "libcrtest.h"
+
+#define TEST_FILE	"data.d/data.filelock1"
+#define LOG_FILE	"logs.d/log.filelock1"
+
+typedef unsigned long long u64;
+
+extern FILE *logfp;
+int test_fd;
+int event_fd1;
+int event_fd2;
+
+/*
+ * Description:
+ * 	Ensure that F_RDLCK and F_WRLCK byte-range locks held by a process at
+ * 	the time of checkpoint are properly restored when the process is
+ * 	restarted from the checkpoint.
+ *
+ * Implementation:
+ * 	Two processes, P0 and P1 acquire the set of locks described by
+ * 	locks_list[] below. Then, they notify the parent that they are ready for
+ * 	checkpoint and wait for checkpoint to be done.  When they are restarted
+ * 	(i.e when test_done() is TRUE), each process verifies that it has the
+ * 	locks it had at the time of checkpoint and that it cannot grab a lock
+ * 	held by the other process.
+ */
+
+setup_notification()
+{
+	int efd;
+
+	efd = eventfd(0, 0);
+	if (efd < 0) {
+		fprintf(logfp, "ERROR: eventfd(): %s\n", strerror(errno));
+		do_exit(1);
+	}
+	return efd;
+}
+
+wait_for_events(int efd, u64 total)
+{
+	int n;
+	u64 events;
+	u64 count = (u64)0;
+
+	do {
+		fprintf(logfp, "%d: wait_for_events: fd %d, reading for %llu\n",
+				getpid(), efd, total);
+		fflush(logfp);
+
+		n = read(efd, &events, sizeof(events));
+		if (n != sizeof(events)) {
+			fprintf(logfp, "ERROR: read(event_fd) %s\n",
+						strerror(errno));
+			do_exit(1);
+		}
+		fprintf(logfp, "%d: wait_for_events: fd %d read %llu\n",
+				getpid(), efd, events);
+
+		count += events;
+	} while (count < total);
+}
+
+notify_one_event(int efd)
+{
+	int n;
+	u64 event = (u64)1;
+
+	fprintf(logfp, "%d: Notifying one event on fd %d\n", getpid(), efd);
+	fflush(logfp);
+
+	n = write(efd, &event, sizeof(event));
+	if (n != sizeof(event)) {
+		fprintf(logfp, "ERROR: write(event_fd) %s\n", strerror(errno));
+		do_exit(1);
+	}
+}
+
+struct test_arg {
+	int child_idx;
+	int type;
+	int start;
+	int len;
+};
+
+struct test_arg locks_list[] = {
+	{ 0, F_WRLCK, 0, 17 },
+	{ 1, F_WRLCK, 18, 16 },
+	{ 0, F_WRLCK, 35, 27 },
+	{ 1, F_WRLCK, 63, 17 },
+	{ 0, F_RDLCK, 81, 25 },
+	{ 1, F_RDLCK, 81, 25 },
+};
+
+void set_lock(int fd, struct test_arg *tlock)
+{
+	int rc;
+	struct flock lock;
+
+	lock.l_type = tlock->type;
+	lock.l_whence = SEEK_SET;
+	lock.l_start = (off_t)tlock->start;
+	lock.l_len = (off_t)tlock->len;
+
+	rc = fcntl(fd, F_SETLK, &lock);
+	if (rc < 0 && errno != EAGAIN) {
+		fprintf(logfp, "%d: set_lock(): ERROR [%d, %llu, %llu]: %s\n",
+				getpid(), tlock->type, (u64)tlock->start,
+				(u64)tlock->len, strerror(errno));
+		fflush(logfp);
+		kill(getppid(), SIGUSR1);
+		do_exit(1);
+	}
+
+	fprintf(logfp, "%d: set_lock(): [%d, %llu, %llu] %s\n", getpid(),
+			tlock->type, (u64)tlock->start, (u64)tlock->len,
+			rc < 0 ? strerror(errno) : "done");
+}
+/*
+ * If @set is TRUE, ensure that the given lock is set.
+ * If @set is FALSE, ensure that the given lock is NOT set.
+ */
+void test_lock(int fd, int locked_by_me, struct test_arg *tlock)
+{
+	int rc;
+	int conflict;
+	struct flock lock;
+	char lock_info[512];
+
+	lock.l_type = tlock->type;
+	lock.l_whence = SEEK_SET;
+	lock.l_start = (off_t)tlock->start;
+	lock.l_len = (off_t)tlock->len;
+	lock.l_pid = 0;
+
+	sprintf(lock_info, "lock [%d, %llu, %llu] ", tlock->type,
+			(u64)tlock->start, (u64)tlock->len);
+
+	conflict = 0;
+	rc = fcntl(fd, F_SETLK, &lock);
+	if (rc < 0 && (errno == EAGAIN || errno == EACCES)) {
+		rc = fcntl(fd, F_GETLK, &lock);
+		if (rc < 0) {
+			fprintf(logfp, "ERROR: fcntl(F_GETLK): %s, error %s\n",
+					lock_info, strerror(errno));
+			goto error;
+		}
+
+		if (lock.l_type == F_UNLCK || lock.l_pid == 0) {
+			fprintf(logfp, "%d: ERROR: %s F_SETLK / F_GETLK "
+					"mismatch !!!\n", getpid(), lock_info);
+			goto error;
+		}
+		conflict = 1;
+	} else if (rc < 0) {
+		fprintf(logfp, "ERROR: fcntl(F_SETLK): %s, error %s\n",
+				lock_info, strerror(errno));
+		goto error;
+	}
+
+	fprintf(logfp, "%d: %s, locked_by_me: %d, conflict %d\n", getpid(),
+			lock_info, locked_by_me, conflict);
+
+	if (locked_by_me && conflict) {
+		fprintf(logfp, "%d: FAIL: %s is NOT set by me !!!\n", getpid(),
+				lock_info);
+		goto error;
+	} else if (!locked_by_me && !conflict) {
+		fprintf(logfp, "%d: FAIL: %s is NOT set by peer !!!\n",
+				getpid(), lock_info);
+		goto error;
+	} else {
+		fprintf(logfp, "%d: PASS: %s is %sset by me\n",
+				getpid(), lock_info, conflict ? "not " : "");
+		return;
+	}
+
+error:
+	fflush(logfp);
+	kill(getppid(), SIGUSR1);
+	do_exit(1);
+}
+
+void handler(int sig)
+{
+	/*
+	 * We completed the test and siblings have completed their test.
+	 * So, safe to drop our locks and exit.
+	 */
+	fprintf(logfp, "%d: Ok to exit...\n", getpid());
+	fflush(logfp);
+	do_exit(0);
+}
+
+int do_child1(int idx)
+{
+	int rc;
+	int locked_by_me;
+	int i;
+	int num_locks;
+	int failed;
+	
+	signal(SIGINT, handler);
+
+	num_locks = sizeof(locks_list) / sizeof(struct test_arg);
+
+	for (i = 0; i < num_locks; i++) {
+		if (idx != locks_list[i].child_idx)
+			continue;
+
+		set_lock(test_fd, &locks_list[i]);
+	}
+
+	/*
+	 * Tell parent we are ready for checkpoint...
+	 */
+	notify_one_event(event_fd1);
+
+	/*
+	 * Wait for checkpoint/restart
+	 */
+	fprintf(logfp, "%d: waiting for test-done\n", idx);
+	fflush(logfp);
+	while(!test_done()) {
+		sleep(1);
+	}
+	fprintf(logfp, "%d: Found test-done\n", idx);
+	fflush(logfp);
+
+	for (i = 0; i < num_locks; i++) {
+		/*
+		 * If we had (not) set the lock earlier, ensure we still have
+		 * it (not) set.
+		 */
+		locked_by_me = 0;
+		if (idx == locks_list[i].child_idx ||
+					locks_list[i].type == F_RDLCK)
+			locked_by_me = 1;
+
+		test_lock(test_fd, locked_by_me, &locks_list[i]);
+	}
+
+	/*
+	 * Notify parent that we are done testing the locks.
+	 */
+	notify_one_event(event_fd2);
+
+	/*
+	 * Hold onto our locks and wait for siblings to complete their
+	 * test on our locks. Parent will SIGINT us when it is safe to
+	 * exit.
+	 */
+	pause();
+
+	do_exit(0);
+}
+
+/*
+ * Populate the test file so the children can lock some portions of
+ * the file
+ */
+void setup_test_file()
+{
+	char buf[256];
+
+	test_fd = open(TEST_FILE, O_RDWR|O_CREAT|O_TRUNC, 0666);
+	if (test_fd < 0) {
+		fprintf(logfp, "ERROR: open(%s): %s\n", TEST_FILE,
+				strerror(errno));
+		do_exit(1);
+	}
+
+	memset(buf, 0, sizeof(buf));
+	write(test_fd, buf, sizeof(buf));
+}
+
+int pid1, pid2;
+void child_handler(int sig)
+{
+	/*
+	 * Wait for the child that exited prematurely
+	 */
+	fprintf(logfp, "%d: Got signal %d\n", getpid(), sig);
+	fflush(logfp);
+
+	if (sig == SIGCHLD)
+		do_wait(1);
+	fprintf(logfp, "%d: Test case FAILED\n", getpid());
+	fflush(logfp);
+	/*
+	 * Kill (remaining) children and exit.
+	 */
+	kill(pid1, SIGKILL);
+	kill(pid2, SIGKILL);
+
+	do_exit(-1);
+}
+
+main(int argc, char *argv[])
+{
+	int i, status, rc;
+
+	if (test_done()) {
+		printf("Remove %s before running test\n", TEST_DONE);
+		do_exit(1);
+	}
+
+	logfp = fopen(LOG_FILE, "w");
+	if (!logfp) {
+		perror("open() logfile");
+		do_exit(1);
+	}
+
+	printf("%s: Closing stdio fds and writing messages to %s\n",
+			argv[0], LOG_FILE);
+
+	for (i=0; i<100; i++)  {
+		if (fileno(logfp) != i)
+			close(i);
+	}
+
+	setup_test_file();
+	event_fd1 = setup_notification();
+	event_fd2 = setup_notification();
+
+	/*
+	 * Before waiting for events below, ensure we will be notified
+	 * if a child encounters an error and/or exits prematurely.
+	 */
+	signal(SIGUSR1, child_handler);
+	signal(SIGCHLD, child_handler);
+
+	/*
+	 * Create the first child and wait for it take its record locks
+	 */
+	pid1 = fork();
+	if (pid1 == 0)
+		do_child1(0);
+	wait_for_events(event_fd1, 1);
+
+	/*
+	 * Create the second child and wait for it take its locks.
+	 */
+	pid2 = fork();
+	if (pid2 == 0)
+		do_child1(1);
+	wait_for_events(event_fd1, 1);
+
+	/*
+	 * Now that the test processes are ready, tell any wrapper scripts,
+	 * we are ready for checkpoint
+	 */
+	set_checkpoint_ready();
+
+	fprintf(logfp, "***** %d: Ready for checkpoint\n", getpid());
+	fflush(logfp);
+
+	/*
+	 * Wait for all children to test the locks. Since a processes locks
+	 * are dropped on exit, if process P1 exits before process P2 has
+	 * completed testing a conflicting lock, P2 may acquire the lock
+	 * supposed to be held by P1 and wrongly assume that test failed.
+	 */
+	wait_for_events(event_fd2, 2);
+
+	signal(SIGCHLD, SIG_IGN);
+
+	/*
+	 * Tell children it is safe to exit
+	 */
+	kill(pid1, SIGINT);
+	kill(pid2, SIGINT);
+
+	do_wait(2);
+
+	do_exit(0);
+}
diff --git a/fileio/run-filelock1.sh b/fileio/run-filelock1.sh
new file mode 100755
index 0000000..0ba2d18
--- /dev/null
+++ b/fileio/run-filelock1.sh
@@ -0,0 +1,218 @@
+#!/bin/bash
+
+source ../common.sh
+
+dir=`mktemp -p . -d -t cr_filelock1_XXXXXXX` || (echo "mktemp failed"; exit 1)
+
+# NOTE: As of ckpt-v15-dev, the --container option to 'ckpt' causes this
+#	test to fail with "container not isolated" message due to the
+#	log-file being shared between the application threads.
+#
+CHECKPOINT="`which checkpoint` --container"
+RESTART=`which restart`
+ECHO="/bin/echo -e"
+
+TEST_CMD="../filelock1"
+TEST_ARGS=""
+TEST_LOG="logs.d/log.filelock1"
+SCRIPT_LOG="logs.d/log.run-filelock1"
+TEST_PID_FILE="pid.filelock1";
+
+SNAPSHOT_DIR="snap1.d"
+
+TEST_DONE="test-done"
+CHECKPOINT_FILE="checkpoint-filelock1";
+CHECKPOINT_READY="checkpoint-ready"
+CHECKPOINT_DONE="checkpoint-done"
+
+LOGS_DIR="logs.d"
+DATA_DIR="data.d"
+
+NS_EXEC="../../ns_exec"
+NS_EXEC_ARGS="-cgpuimP $TEST_PID_FILE"
+
+checkpoint()
+{
+	local pid=$1
+
+	$ECHO "\t- Checkpoint: $CHECKPOINT $pid \> $CHECKPOINT_FILE"
+	$CHECKPOINT $pid > $CHECKPOINT_FILE
+	ret=$?
+	if [ $ret -ne 0 ]; then
+		$ECHO "***** FAIL: Checkpoint of $pid failed"
+		ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
+		exit 1;
+	fi
+}
+
+function wait_for_checkpoint_ready()
+{
+	# Wait for test to finish setup
+	while [ ! -f $CHECKPOINT_READY ]; do
+		$ECHO "\t- Waiting for $CHECKPOINT_READY"
+		sleep 1;
+	done;
+}
+
+function create_container()
+{
+	local pid;
+
+	cmdline="$NS_EXEC $NS_EXEC_ARGS -- $TEST_CMD $TEST_ARGS"
+
+	$ECHO "\t- Creating container:"
+	$ECHO "\t- $cmdline"
+
+	$cmdline &
+
+	wait_for_checkpoint_ready;
+
+	# Find global pid of container-init
+	pid=`cat $TEST_PID_FILE`;
+	if [  "x$pid" == "x" ]; then
+		$ECHO "***** FAIL: Invalid container-init pid $pid"
+		ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
+		exit 1
+	fi
+	$ECHO "Created container with pid $pid" >> $SCRIPT_LOG
+}
+
+function restart_container
+{
+	local ret;
+
+	cmdline="$RESTART --pids --pidns --wait"
+	$ECHO "\t- $cmdline"
+
+	sleep 1
+
+	$cmdline < $CHECKPOINT_FILE >> $SCRIPT_LOG 2>&1 &
+	ret=$?
+
+	if [ $ret -ne 0 ]; then
+		$ECHO "***** FAIL: Restart of $pid failed"
+		ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
+		exit 1;
+	fi
+
+}
+
+function create_fs_snapshot()
+{
+	# Prepare for snapshot
+	if [ -d $SNAPSHOT_DIR ]; then
+		rm -rf ${SNAPSHOT_DIR}.prev
+		mv $SNAPSHOT_DIR ${SNAPSHOT_DIR}.prev
+		mkdir $SNAPSHOT_DIR
+	fi
+
+	# Snapshot the log files
+	cp ${LOGS_DIR}/* $SNAPSHOT_DIR
+}
+
+function restore_fs_snapshot()
+{
+	# Restore the snapshot after the main process has been killed
+	/bin/cp ${SNAPSHOT_DIR}/* $LOGS_DIR
+}
+
+cd $dir
+echo "Current directory: `pwd`"
+
+if [ ! -d $LOGS_DIR ]; then
+	mkdir $LOGS_DIR
+fi
+
+if [ ! -d $DATA_DIR ]; then
+	mkdir $DATA_DIR
+fi
+
+if [ ! -d $SNAPSHOT_DIR ]; then
+	mkdir $SNAPSHOT_DIR
+fi
+
+if [ ! -f $INPUT_DATA ]; then
+	$FILEIO -C $INPUT_DATA
+fi
+
+# Make sure no stray filelock1 process from another run is still going
+killall $TEST_CMD > $SCRIPT_LOG 2>&1
+
+> $SCRIPT_LOG;
+cnt=1
+while [ $cnt -lt 20 ]; do
+	$ECHO "===== Iteration $cnt"
+
+	# Remove any 'state' files, start the app and let it tell us
+	# when it is ready
+	rm -f $CHECKPOINT_READY $TEST_DONE $TEST_PID_FILE
+
+	create_container
+	wait_for_checkpoint_ready
+
+	pid=`cat $TEST_PID_FILE`
+
+	$ECHO "\t- Done creating container, cinit-pid $pid"
+
+	ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
+
+	# override default freezerdir
+	if [ -d $freezerdir ]; then
+		rmdir $freezerdir
+	fi
+	freezerdir=$freezermountpoint/$pid
+	freeze_pid $pid
+
+	num_pids1=`ps -efL |grep $TEST_CMD | wc -l`
+
+	create_fs_snapshot
+
+	checkpoint $pid
+
+	touch $CHECKPOINT_DONE
+
+	killall -9 `basename $TEST_CMD`
+
+	thaw
+
+	sleep 3
+
+	restore_fs_snapshot
+
+	restart_container
+
+	sleep 3;
+
+	num_pids2=`ps -efL |grep $TEST_CMD | wc -l`
+	ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
+	$ECHO "\t- num_pids1 $num_pids1, num_pids2 $num_pids2";
+
+	# ns_exec pid is parent-pid of restarted-container-init
+	nspid=`pidof restart`
+
+	if [ "x$nspid" == "x" ]; then
+		$ECHO "***** FAIL: Can't find pid of $RESTART"
+		exit 1;
+	fi
+
+	# End test gracefully
+	touch $TEST_DONE
+
+	$ECHO "\t- Waiting for restarted container to exit (gloabl-pid $nspid)"
+	wait $nspid;
+	ret=$?
+
+	grep --binary-files=text FAIL $PWD/$TEST_LOG > /dev/null 2>&1
+	if [ $? -eq 0 ]; then
+		$ECHO "\t***** Application FAILED after restart" >> $SCRIPT_LOG
+		$ECHO "\t***** See $TEST_LOG for details" >> $SCRIPT_LOG
+
+		$ECHO "\t***** Application FAILED after restart"
+		$ECHO "\tSee $PWD/$TEST_LOG for details"
+		exit 1;
+	fi
+
+	$ECHO "\t- Container exited, status $ret"
+
+	cnt=$((cnt+1))
+done
-- 
1.6.0.4
