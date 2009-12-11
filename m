From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][cr-tests] Ensure pthread stack attributes are restored
Date: Thu, 10 Dec 2009 20:11:26 -0800
Message-ID: <20091211041126.GC20947@us.ibm.com>
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


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Wed, 9 Dec 2009 18:31:47 +0530
Subject: [PATCH] Ensure pthread stack attributes are restored

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 process-tree/Makefile        |    2 +-
 process-tree/pthread2.c      |  244 ++++++++++++++++++++++++++++++++++++++++++
 process-tree/run-pthread2.sh |  206 +++++++++++++++++++++++++++++++++++
 3 files changed, 451 insertions(+), 1 deletions(-)
 create mode 100644 process-tree/pthread2.c
 create mode 100755 process-tree/run-pthread2.sh

diff --git a/process-tree/Makefile b/process-tree/Makefile
index d460834..3d6010d 100644
--- a/process-tree/Makefile
+++ b/process-tree/Makefile
@@ -1,5 +1,5 @@
 
-targets		= ptree1 pthread1
+targets		= ptree1 pthread1 pthread2
 
 INCLUDE		= ../libcrtest
 LIBCRTEST	= ../libcrtest/common.o
diff --git a/process-tree/pthread2.c b/process-tree/pthread2.c
new file mode 100644
index 0000000..5e1a5bb
--- /dev/null
+++ b/process-tree/pthread2.c
@@ -0,0 +1,244 @@
+#include <stdio.h>
+#include <unistd.h>
+#include <wait.h>
+#include <errno.h>
+#include <string.h>
+#include <stdlib.h>
+#include <libcrtest.h>
+#include <pthread.h>
+
+#define	ERROR_EXIT	((void *)1)
+#define MIN_STACK_SIZE	(64 *1024)
+#define LOG_PREFIX	"logs.d/pthread2"
+
+FILE *logfp;
+
+int num_threads = 8;
+void **exp_addrs;
+int  *exp_sizes;
+int *tstatus;
+
+static void usage(char *argv[])
+{
+	printf("%s [h] [-n num-threads]\n", argv[0]);
+	printf("\t <num-threads> # of threads, default 5\n");
+	do_exit(1);
+}
+
+pthread_attr_t *get_thread_attr(int tnum)
+{
+	int rc, size;
+	pthread_attr_t *attr;
+	void *stack;
+
+	size = MIN_STACK_SIZE + (tnum * getpagesize());
+
+	stack = malloc(size);
+	if (!stack) {
+		fprintf(logfp, "malloc(stack): error %s\n", strerror(errno));
+		do_exit(1);
+	}
+
+	attr = malloc(sizeof(pthread_attr_t));
+	if (!attr) {
+		fprintf(logfp, "malloc(attr): error %s\n", strerror(errno));
+		do_exit(1);
+	}
+
+	rc = pthread_attr_init(attr);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_attr_init(): rc %d error %s\n", rc,
+				strerror(errno));
+		do_exit(1);
+	}
+
+	rc = pthread_attr_setstack(attr, stack, size);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_attr_setstack(): rc %d error %s\n",
+				rc, strerror(errno));
+		do_exit(1);
+	}
+
+	return attr;
+}
+
+int get_stack_info(pthread_t tid, void **addrp, int *sizep)
+{
+	int rc;
+	pthread_attr_t attr;
+
+	rc = pthread_getattr_np(tid, &attr);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_getattr_np failed, rc %d, %s\n", rc,
+				strerror(errno));
+		pthread_exit(ERROR_EXIT);
+	}
+
+	rc = pthread_attr_getstack(&attr, (void **)addrp, sizep);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_attr_getstackaddr failed, rc %d, %s\n",
+					rc, strerror(errno));
+		pthread_exit(ERROR_EXIT);
+	}
+
+	return 0;
+}
+
+void *do_work(void *arg)
+{
+	int tnum = (int)arg;
+	int rc;
+	void *act_addr;
+	int act_size;
+
+	fprintf(logfp, "%d: Thread %lu: waiting for checkpoint\n", tnum,
+			pthread_self());
+	fflush(logfp);
+
+	while(!test_done())
+		sleep(1);
+
+	rc = get_stack_info(pthread_self(), &act_addr, &act_size);
+	if (rc < 0)
+		pthread_exit(ERROR_EXIT);
+
+	if (act_addr != exp_addrs[tnum] || act_size != exp_sizes[tnum]) {
+		fprintf(logfp, "%d: Expected: (%p, %d), actual (%p, %d)\n",
+				tnum, exp_addrs[tnum], exp_sizes[tnum],
+				act_addr, act_size);
+		fflush(logfp);
+		rc = 1;
+	}
+
+	fprintf(logfp, "%d: Thread %lu: exiting, rc %d\n", tnum,
+			pthread_self(), rc);
+	fflush(logfp);
+
+	tstatus[tnum] = rc;
+	pthread_exit((void *)&tstatus[tnum]);
+}
+
+pthread_t *create_threads(int n)
+{
+	int i;
+	int rc;
+	pthread_t *tid_list;
+	pthread_t tid;
+	pthread_attr_t *attr;
+
+	tid_list = (pthread_t *)malloc(n * sizeof(pthread_t));
+	exp_addrs = malloc(sizeof(void *) * n);
+	exp_sizes = malloc(sizeof(int) * n);
+	tstatus = malloc(sizeof(int) * n);
+
+	if (!tid_list || !exp_addrs || !exp_sizes || !tstatus) {
+		fprintf(logfp, "malloc() failed, n %d, error %s\n",
+				n, strerror(errno));
+		do_exit(1);
+	}
+
+	for (i = 0; i < n; i++) {
+		attr = get_thread_attr(i);
+		if (!attr)
+			do_exit(1);
+
+		rc = pthread_create(&tid, attr, do_work, (void *)i);
+		if (rc < 0) {
+			fprintf(logfp, "pthread_create(): i %d, rc %d, "
+					"error %s\n", i, rc, strerror(errno));
+			do_exit(1);
+		}
+
+		rc = get_stack_info(tid, &exp_addrs[i], &exp_sizes[i]);
+		if (rc < 0)
+			do_exit(1);
+
+		tid_list[i] = tid;
+	}
+
+	fprintf(logfp, "Created %d threads\n", n);
+	fflush(logfp);
+
+	return tid_list;
+}
+
+int wait_for_threads(pthread_t *tid_list, int n)
+{
+	int i;
+	int rc;
+	int status;
+	int *statusp;
+	int exit_status;
+
+	exit_status = 0;
+	for (i = 0; i < n; i++) {
+		rc = pthread_join(tid_list[i], (void **)&statusp);
+		if (rc < 0) {
+			fprintf(logfp, "pthread_join() failed, i %d, rc %d "
+					"error %s\n", i, rc, strerror(errno));
+			do_exit(1);
+		}
+
+		fprintf(logfp, "i %d: *statusp %x\n", i, *statusp);
+		fflush(logfp);
+
+		if (*statusp)
+			exit_status = 1;
+	}
+
+	return exit_status;
+}
+
+
+main(int argc, char *argv[])
+{
+	int c;
+	int i;
+	int rc;
+	int status;
+	pthread_t *tid_list;
+	char log_file[256];
+
+	sprintf(log_file, "%s.log", LOG_PREFIX);
+
+	if (test_done()) {
+		fprintf(stderr, "Remove %s before running test\n", TEST_DONE);
+		do_exit(1);
+	}
+
+
+	while ((c = getopt(argc, argv, "hn:")) != EOF) {
+		switch (c) {
+		case 'n': num_threads = atoi(optarg); break;
+		case 'h':
+		default:
+			usage(argv);
+		}
+	};
+
+	logfp = fopen(log_file, "w");
+	if (!logfp) {
+		fprintf(stderr, "fopen(%s) failed, %s\n", log_file,
+					strerror(errno));
+		fflush(stderr);
+		do_exit(1);
+	}
+
+	for (i=0; i<100; i++)  {
+		if (fileno(logfp) != i)
+			close(i);
+	}
+
+
+	tid_list = create_threads(num_threads);
+
+	/*
+	 * Now that we closed the special files and created the threads,
+	 * tell any wrapper scripts, we are ready for checkpoint
+	 */
+	set_checkpoint_ready();
+
+	rc = wait_for_threads(tid_list, num_threads);
+
+	do_exit(rc);
+}
diff --git a/process-tree/run-pthread2.sh b/process-tree/run-pthread2.sh
new file mode 100755
index 0000000..0686cbd
--- /dev/null
+++ b/process-tree/run-pthread2.sh
@@ -0,0 +1,206 @@
+#!/bin/bash
+
+source ../common.sh
+
+#dir=`mktemp -p . -d -t cr_pthread2_XXXXXXX` || (echo "mktemp failed"; exit 1)
+dir=cr_pthread2
+mkdir $dir
+echo "Using output dir $dir"
+cd $dir
+
+# NOTE: As of ckpt-v15-dev, the --container option to 'ckpt' causes this
+#	test to fail with "container not isolated" message due to the
+#	log-file being shared between the application threads.
+#
+CHECKPOINT="`which checkpoint` --container"
+RESTART=`which restart`
+ECHO="/bin/echo -e"
+
+TEST_CMD="../pthread2"
+TEST_ARGS="-n 128"			# -n: number of threads
+SCRIPT_LOG="log-run-pthread2"
+TEST_PID_FILE="pid.pthread2";
+
+SNAPSHOT_DIR="snap1.d"
+
+TEST_DONE="test-done"
+CHECKPOINT_FILE="checkpoint-pthread2";
+CHECKPOINT_READY="checkpoint-ready"
+CHECKPOINT_DONE="checkpoint-done"
+
+LOGS_DIR="logs.d"
+
+NS_EXEC="../../ns_exec"
+NS_EXEC_ARGS="-cgpuimP $TEST_PID_FILE"
+
+checkpoint()
+{
+	local pid=$1
+
+	$ECHO "Checkpoint: $CHECKPOINT $pid \> $CHECKPOINT_FILE"
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
+# Make sure no stray pthread1 from another run is still going
+killall $TEST_CMD > $SCRIPT_LOG 2>&1
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
+> $SCRIPT_LOG;
+cnt=1
+while [ $cnt -lt 15 ]; do
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
+	$ECHO "\t- Container exited, status $ret"
+
+	cnt=$((cnt+1))
+done
-- 
1.6.0.4
