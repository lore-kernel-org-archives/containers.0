From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][cr-tests] pthread3: Ensure thread state is consistent
	across C/R
Date: Fri, 8 Jan 2010 17:30:40 -0800
Message-ID: <20100109013040.GB21607@us.ibm.com>
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
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org


From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Date: Fri, 8 Jan 2010 11:30:23 -0800
Subject: [PATCH] pthread3: Ensure thread state is consistent across C/R

Specifically, this test ensures that concurrency, thread-specific-info and
scheduling parameters are consistent across checkpoint/restart.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 process-tree/Makefile        |    2 +-
 process-tree/pthread3.c      |  376 ++++++++++++++++++++++++++++++++++++++++++
 process-tree/run-pthread3.sh |  205 +++++++++++++++++++++++
 3 files changed, 582 insertions(+), 1 deletions(-)
 create mode 100644 process-tree/pthread3.c
 create mode 100755 process-tree/run-pthread3.sh

diff --git a/process-tree/Makefile b/process-tree/Makefile
index 3d6010d..b043394 100644
--- a/process-tree/Makefile
+++ b/process-tree/Makefile
@@ -1,5 +1,5 @@
 
-targets		= ptree1 pthread1 pthread2
+targets		= ptree1 pthread1 pthread2 pthread3
 
 INCLUDE		= ../libcrtest
 LIBCRTEST	= ../libcrtest/common.o
diff --git a/process-tree/pthread3.c b/process-tree/pthread3.c
new file mode 100644
index 0000000..c025c9c
--- /dev/null
+++ b/process-tree/pthread3.c
@@ -0,0 +1,376 @@
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
+#define LOG_PREFIX	"logs.d/pthread3"
+
+FILE *logfp;
+int num_threads = 4;
+int *tstatus;
+pthread_barrier_t barrier;
+pthread_mutex_t dump_lock;
+pthread_key_t key;
+
+struct thread_info {
+	int tid;
+	int concurrency;
+	void *specific;
+	sigset_t sigmask;
+	int sched_policy;
+	struct sched_param sched_param;
+};
+
+static void usage(char *argv[])
+{
+	printf("%s [h] [-n num-threads]\n", argv[0]);
+	printf("\t <num-threads> # of threads, default 5\n");
+	do_exit(1);
+}
+
+set_thread_info(int tnum)
+{
+	int rc;
+	void *specific;
+	void *sp2;
+
+	specific = (void *)pthread_self();
+
+	rc = pthread_setspecific(key, specific);
+	if (rc < 0) {
+		fprintf(logfp, "%d: pthread_setspecific() failed, rc %d, "
+				"error %s\n", tnum, rc, strerror(errno));
+		do_exit(1);
+	}
+
+	/*
+	 * TODO: Change other fields in tinfo to some non-default value
+	 */
+}
+
+get_thread_info(int tnum, struct thread_info *tinfo)
+{
+	int rc;
+
+	tinfo->tid = pthread_self();
+	tinfo->concurrency = pthread_getconcurrency();
+	tinfo->specific = pthread_getspecific(key);
+
+	if (tinfo->specific != (void *)tinfo->tid) {
+		fprintf(logfp, "%d: pthread_getspcific(): expected %p, actual "
+				"%p\n", tnum, (void *)tinfo->tid,
+				tinfo->specific);
+		do_exit(1);
+	}
+
+	rc = pthread_sigmask(SIG_SETMASK, NULL, &tinfo->sigmask);
+	if (rc < 0) {
+		fprintf(logfp, "%d: pthread_sigmask() failed, rc %d, "
+				"error %s\n", tnum, rc, strerror(errno));
+		do_exit(1);
+	}
+
+	rc = pthread_getschedparam(pthread_self(), &tinfo->sched_policy,
+				&tinfo->sched_param);
+	if (rc < 0) {
+		fprintf(logfp, "%d: pthread_getschedparam() failed, rc %d, "
+				"error %s\n", tnum, rc, strerror(errno));
+		do_exit(1);
+	}
+}
+
+compare_thread_info(int tnum, struct thread_info *exp_tinfo,
+		struct thread_info *act_tinfo)
+{
+	int rc;
+
+	rc = 0;
+	if (exp_tinfo->tid != act_tinfo->tid) {
+		rc = 1;
+		fprintf(logfp, "thread_info.tid miscompare: expected %p, "
+				"actual %p\n", (void *)exp_tinfo->tid,
+				(void *)act_tinfo->tid);
+	}
+
+	if (exp_tinfo->concurrency != act_tinfo->concurrency) {
+		rc = 1;
+		fprintf(logfp, "thread_info.concurrency miscompare: expected "
+				"%d, actual %d\n", exp_tinfo->concurrency,
+				act_tinfo->concurrency);
+	}
+
+	if (exp_tinfo->specific != act_tinfo->specific) {
+		rc = 1;
+		fprintf(logfp, "thread_info.specific miscompare: expected "
+				"%p, actual %p\n", exp_tinfo->specific,
+				act_tinfo->specific);
+	}
+
+	if (memcmp(&exp_tinfo->sigmask, &act_tinfo->sigmask, sizeof(sigset_t))) {
+		rc = 1;
+		fprintf(logfp, "thread_info.sigmask miscompare: \n");
+	}
+
+	if (exp_tinfo->sched_policy != act_tinfo->sched_policy) {
+		rc = 1;
+		fprintf(logfp, "thread_info.sched_policy miscompare: expected "
+				"%d, actual %d\n", exp_tinfo->sched_policy,
+				act_tinfo->sched_policy);
+	}
+
+	if (memcmp(&exp_tinfo->sched_param, &act_tinfo->sched_param,
+				sizeof(struct sched_param))) {
+		rc = 1;
+		fprintf(logfp, "thread_info.sched_param miscompare: expected "
+				"priority %d, actual %d\n",
+				exp_tinfo->sched_param.sched_priority,
+				act_tinfo->sched_param.sched_priority);
+	}
+
+	if (rc)
+		do_exit(1);
+}
+
+
+void *do_work(void *arg)
+{
+	int tnum = (int)arg;
+	int rc;
+	struct thread_info exp_tinfo, act_tinfo;
+
+	memset(&exp_tinfo, 0, sizeof(struct thread_info));
+	memset(&act_tinfo, 0, sizeof(struct thread_info));
+
+	set_thread_info(tnum);
+
+	get_thread_info(tnum, &exp_tinfo);
+
+	fprintf(logfp, "%d: Thread %lu: waiting for checkpoint\n", tnum,
+			pthread_self());
+	fflush(logfp);
+
+	/*
+	 * Inform main-thread we are ready for checkpoint.
+	 */
+	rc = pthread_barrier_wait(&barrier);
+	if (rc != PTHREAD_BARRIER_SERIAL_THREAD && rc != 0) {
+		fprintf(logfp, "%d: pthread_barrier_wait() failed, rc %d, "
+				"error %s\n", tnum, rc, strerror(errno));
+		do_exit(1);
+	}
+
+	/*
+	 * Wait for checkpoint/restart.
+	 */
+	while(!test_done())
+		sleep(1);
+
+	/*
+	 * Collect attributes after checkpoint/restart.
+	 */
+	get_thread_info(tnum, &act_tinfo);
+
+	/*
+	 * Compare attributes before and after C/R.
+	 */
+	compare_thread_info(tnum, &exp_tinfo, &act_tinfo);
+
+	fprintf(logfp, "%d: Thread %lu: exiting, rc 0\n", tnum,
+			pthread_self());
+	fflush(logfp);
+
+	tstatus[tnum] = 0;
+	pthread_exit((void *)&tstatus[tnum]);
+}
+
+static void create_key(pthread_key_t *key)
+{
+	int rc;
+
+	rc = pthread_key_create(key, NULL);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_key_create() failed, rc %d, error %s\n",
+				rc, strerror(errno));
+		do_exit(1);
+	}
+}
+
+pthread_attr_t *alloc_thread_attr()
+{
+	int rc;
+	pthread_attr_t *attr;
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
+	return attr;
+}
+
+pthread_t *create_threads(int n)
+{
+	int i;
+	int rc;
+	pthread_t *tid_list;
+	pthread_t tid;
+	pthread_attr_t *attr = NULL;
+
+	tid_list = (pthread_t *)malloc(n * sizeof(pthread_t));
+	tstatus = malloc(sizeof(int) * n);
+
+	if (!tid_list || !tstatus) {
+		fprintf(logfp, "malloc() failed, n %d, error %s\n",
+				n, strerror(errno));
+		do_exit(1);
+	}
+
+	for (i = 0; i < n; i++) {
+		attr = alloc_thread_attr();
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
+	fprintf(stderr, "Redirecting output to %s\n", log_file);
+	fflush(stderr);
+
+	for (i=0; i<100; i++)  {
+		if (fileno(logfp) != i)
+			close(i);
+	}
+
+
+	/*
+	 * Create a barrier which the main-thread can use to determine
+	 * when all threads are ready for checkpoint.
+	 */
+	rc = pthread_barrier_init(&barrier, NULL, num_threads+1);
+	if (rc < 0) {
+		fprintf(logfp, "pthread_barrier_init() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+
+	rc = pthread_mutex_init(&dump_lock, NULL);
+	if (rc) {
+		fprintf(logfp, "pthread_mutex_init() failed, rc %d, error %s\n",
+				rc, strerror(errno));
+		do_exit(1);
+	}
+
+	create_key(&key);
+
+	tid_list = create_threads(num_threads);
+
+	/*
+	 * Wait for everyone to be ready for checkpoint
+	 */
+	pthread_barrier_wait(&barrier);
+	if (rc != PTHREAD_BARRIER_SERIAL_THREAD && rc != 0) {
+		fprintf(logfp, "main: pthread_barrier_wait() failed, rc %d, "
+				"error %s\n", rc, strerror(errno));
+		do_exit(1);
+	}
+
+	/*
+	 * Now that we closed the special files and created the threads,
+	 * tell any wrapper scripts, we are ready for checkpoint
+	 */
+	set_checkpoint_ready();
+
+	rc = wait_for_threads(tid_list, num_threads);
+
+	fprintf(logfp, "Exiting with status %d\n", rc);
+
+	do_exit(rc);
+}
diff --git a/process-tree/run-pthread3.sh b/process-tree/run-pthread3.sh
new file mode 100755
index 0000000..0cffe44
--- /dev/null
+++ b/process-tree/run-pthread3.sh
@@ -0,0 +1,205 @@
+#!/bin/bash
+
+source ../common.sh
+
+dir=`mktemp -p . -d -t cr_pthread3_XXXXXXX` || (echo "mktemp failed"; exit 1)
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
+TEST_CMD="../pthread3"
+TEST_ARGS="-n 4"			# -n: number of threads
+SCRIPT_LOG="log-run-pthread3"
+TEST_PID_FILE="pid.pthread3";
+
+SNAPSHOT_DIR="snap1.d"
+
+TEST_DONE="test-done"
+CHECKPOINT_FILE="checkpoint-pthread3";
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
