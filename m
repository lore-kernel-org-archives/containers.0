From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 02/11] Make runtests.sh a wrapper for fileio tests
Date: Fri, 29 Jan 2010 12:37:43 -0800
Message-ID: <20100129203743.GA26721@us.ibm.com>
References: <20100129202842.GA25490@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100129202842.GA25490-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Fri, 22 Jan 2010 11:55:45 -0800
Subject: [PATCH 02/11] Make runtests.sh a wrapper for fileio tests

Move runtests.sh to run-fileio1.sh and create a runtests.sh that
runs both run-fileio1.sh and run-filelock1.sh. It can later be
extended to run other, possibly all, fileio tests.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fileio/run-fileio1.sh |  148 +++++++++++++++++++++++++++++++++++++++++++++++
 fileio/runtests.sh    |  153 +++----------------------------------------------
 2 files changed, 156 insertions(+), 145 deletions(-)
 create mode 100755 fileio/run-fileio1.sh
 mode change 100644 => 100755 fileio/runtests.sh

diff --git a/fileio/run-fileio1.sh b/fileio/run-fileio1.sh
new file mode 100755
index 0000000..c7179ab
--- /dev/null
+++ b/fileio/run-fileio1.sh
@@ -0,0 +1,148 @@
+#!/bin/bash
+# Copyright 2009 IBM Corp.
+# Author: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
+
+source ../common.sh
+
+# test_case could be a command-line-arg, but since only one test
+# uses this for now, hard code.
+test_case="fileio1"
+
+dir=`mktemp -p . -d -t cr_${test_case}_XXXXXXX` || (echo "mktemp failed"; exit 1)
+echo "Using output dir $dir"
+
+SLOW_DOWN="$dir/slow-down-fileio"
+CKPT_FILE="$dir/checkpoint-${test_case}"
+CKPT_READY="$dir/checkpoint.ready"
+COPY_DONE="$dir/copy.done"
+SRC_FILE="$dir/input-data.1";
+DEST_FILE="$dir/output-data.1";
+DEST_FILE_SNAP="$dir/output-data.1.snap";
+TEST_LOG="$dir/log.${test_case}"
+TEST_LOG_SNAP="$dir/log.${test_case}.snap"
+
+LOG_FILE="$dir/f1-loop.log"
+TEST_CMD="./$test_case"
+NS_EXEC="../ns_exec"
+
+# Make sure no stray TEST_CMD from another run is still going
+killall $TEST_CMD
+
+#echo > $LOG_FILE
+
+#Create the SRC_FILE
+$TEST_CMD -d  $dir -C $SRC_FILE
+
+cnt=1
+sleep_time=3;
+
+NUMTESTS=5
+for testnum in `seq 1 $NUMTESTS`; do
+	echo "----- Iteration $cnt"
+
+	# Copy file slowly, so we can checkpoint
+	touch $SLOW_DOWN
+
+	# Remove CKPT_READY file, start the application and let app tell
+	# us when it is ready
+	rm -f $CKPT_READY;
+	$NS_EXEC -m $TEST_CMD -d $dir -c $SRC_FILE $DEST_FILE &
+	while [ ! -f $CKPT_READY ]; do
+		sleep 1;
+	done;
+
+	# Let it run for a while before checkpointing
+	echo "Created $TEST_CMD process, sleep $sleep_time"
+	sleep $sleep_time
+
+	pid=`pidof $TEST_CMD`
+	if [  "x$pid" == "x" ]; then
+		echo "$TEST_CMD is not running!  pid is $pid.  fail"
+		ps -ef |grep $TEST_CMD
+		exit 1
+	fi
+
+	freeze_pid $pid
+
+	# Checkpoint
+	echo $CHECKPOINT $pid > $CKPT_FILE
+	$CHECKPOINT $pid > $CKPT_FILE
+	ret=$?
+	if [ $ret -ne 0 ]; then
+		echo "===== Checkpoint of $pid failed"
+		ps aux |grep $TEST_CMD
+		exit 1;
+	fi
+
+	# Snapshot the outfile and log file
+	cp $DEST_FILE $DEST_FILE_SNAP
+	cp $TEST_LOG $TEST_LOG_SNAP
+
+	ls -l $SRC_FILE $DEST_FILE
+
+	thaw $pid
+
+	kill -9 $pid
+
+	# Restore the snapshot after the main process has been killed
+	cp ${DEST_FILE}.snap $DEST_FILE
+
+	cp $TEST_LOG_SNAP $TEST_LOG
+
+	# Remove COPY_DONE file. We will wait below for application to
+	# finish copying and let us know.
+	rm -f $COPY_DONE;
+
+	# Restart.
+	$NS_EXEC -m rstrsh $CKPT_FILE &
+	ret=$?
+
+	if [ $ret -ne 0 ]; then
+		echo "===== Restart of $pid failed"
+		ps aux |grep $TEST_CMD
+		exit 1;
+	fi
+
+	# Find pid of restarted test cmd...
+
+	sleep 1;
+	pid=`pidof $TEST_CMD`
+	if [ "x$pid" == "x" ]; then
+		echo "Can't find pid of $TEST_CMD"
+		exit 1
+	fi
+
+	nspid=`pidof $NS_EXEC`
+	if [ "x$nspid" == "x" ]; then
+		echo "Can't find pid of $NS_EXEC"
+		exit 1
+	fi
+
+	# ...then zip through rest of copy.
+	rm $SLOW_DOWN
+
+	wait $nspid;
+	ret=$?
+
+	echo "$nspid exited, status $ret"
+
+	#ls -l $SRC_FILE $DEST_FILE $CKPT_FILE
+
+	/usr/bin/cmp $SRC_FILE $DEST_FILE
+	if [ $? -ne 0 ]; then
+		echo "file copy ($SRC_FILE -> $DEST_FILE) failed after restart"
+		exit 1;
+	fi
+
+	cnt=$((cnt+1))
+
+	# Change delay so next checkpoint happens at a different point
+	sleep_time=$((sleep_time+1))
+	if [ $sleep_time -gt 10 ]; then
+		sleep_time=2;
+	fi
+done
+
+echo PASS
+
+exit 0
diff --git a/fileio/runtests.sh b/fileio/runtests.sh
old mode 100644
new mode 100755
index 69758f0..3e3e495
--- a/fileio/runtests.sh
+++ b/fileio/runtests.sh
@@ -1,148 +1,11 @@
 #!/bin/bash
-# Copyright 2009 IBM Corp.
-# Author: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
 
-source ../common.sh
+echo
+echo "****** $0: Running test: fileio1"
+echo
+./run-fileio1.sh
 
-# test_case could be a command-line-arg, but since only one test
-# uses this for now, hard code.
-test_case="fileio1"
-
-dir=`mktemp -p . -d -t cr_${test_case}_XXXXXXX` || (echo "mktemp failed"; exit 1)
-echo "Using output dir $dir"
-
-SLOW_DOWN="$dir/slow-down-fileio"
-CKPT_FILE="$dir/checkpoint-${test_case}"
-CKPT_READY="$dir/checkpoint.ready"
-COPY_DONE="$dir/copy.done"
-SRC_FILE="$dir/input-data.1";
-DEST_FILE="$dir/output-data.1";
-DEST_FILE_SNAP="$dir/output-data.1.snap";
-TEST_LOG="$dir/log.${test_case}"
-TEST_LOG_SNAP="$dir/log.${test_case}.snap"
-
-LOG_FILE="$dir/f1-loop.log"
-TEST_CMD="./$test_case"
-NS_EXEC="../ns_exec"
-
-# Make sure no stray TEST_CMD from another run is still going
-killall $TEST_CMD
-
-#echo > $LOG_FILE
-
-#Create the SRC_FILE
-$TEST_CMD -d  $dir -C $SRC_FILE
-
-cnt=1
-sleep_time=3;
-
-NUMTESTS=5
-for testnum in `seq 1 $NUMTESTS`; do
-	echo "----- Iteration $cnt"
-
-	# Copy file slowly, so we can checkpoint
-	touch $SLOW_DOWN
-
-	# Remove CKPT_READY file, start the application and let app tell
-	# us when it is ready
-	rm -f $CKPT_READY;
-	$NS_EXEC -m $TEST_CMD -d $dir -c $SRC_FILE $DEST_FILE &
-	while [ ! -f $CKPT_READY ]; do
-		sleep 1;
-	done;
-
-	# Let it run for a while before checkpointing
-	echo "Created $TEST_CMD process, sleep $sleep_time"
-	sleep $sleep_time
-
-	pid=`pidof $TEST_CMD`
-	if [  "x$pid" == "x" ]; then
-		echo "$TEST_CMD is not running!  pid is $pid.  fail"
-		ps -ef |grep $TEST_CMD
-		exit 1
-	fi
-
-	freeze_pid $pid
-
-	# Checkpoint
-	echo $CHECKPOINT $pid > $CKPT_FILE
-	$CHECKPOINT $pid > $CKPT_FILE
-	ret=$?
-	if [ $ret -ne 0 ]; then
-		echo "===== Checkpoint of $pid failed"
-		ps aux |grep $TEST_CMD
-		exit 1;
-	fi
-
-	# Snapshot the outfile and log file
-	cp $DEST_FILE $DEST_FILE_SNAP
-	cp $TEST_LOG $TEST_LOG_SNAP 
-
-	ls -l $SRC_FILE $DEST_FILE
-
-	thaw $pid
-
-	kill -9 $pid
-
-	# Restore the snapshot after the main process has been killed
-	cp ${DEST_FILE}.snap $DEST_FILE
-
-	cp $TEST_LOG_SNAP $TEST_LOG
-
-	# Remove COPY_DONE file. We will wait below for application to
-	# finish copying and let us know.
-	rm -f $COPY_DONE;
-
-	# Restart.
-	$NS_EXEC -m rstrsh $CKPT_FILE &
-	ret=$?
-
-	if [ $ret -ne 0 ]; then
-		echo "===== Restart of $pid failed"
-		ps aux |grep $TEST_CMD
-		exit 1;
-	fi
-
-	# Find pid of restarted test cmd...
-
-	sleep 1;
-	pid=`pidof $TEST_CMD`
-	if [ "x$pid" == "x" ]; then
-		echo "Can't find pid of $TEST_CMD"
-		exit 1
-	fi
-
-	nspid=`pidof $NS_EXEC`
-	if [ "x$nspid" == "x" ]; then
-		echo "Can't find pid of $NS_EXEC"
-		exit 1
-	fi
-
-	# ...then zip through rest of copy.
-	rm $SLOW_DOWN
-
-	wait $nspid;
-	ret=$?
-
-	echo "$nspid exited, status $ret"
-
-	#ls -l $SRC_FILE $DEST_FILE $CKPT_FILE
-
-	/usr/bin/cmp $SRC_FILE $DEST_FILE
-	if [ $? -ne 0 ]; then
-		echo "file copy ($SRC_FILE -> $DEST_FILE) failed after restart"
-		exit 1;
-	fi
-
-	cnt=$((cnt+1))
-
-	# Change delay so next checkpoint happens at a different point
-	sleep_time=$((sleep_time+1))
-	if [ $sleep_time -gt 10 ]; then
-		sleep_time=2;
-	fi
-done
-
-echo PASS
-
-exit 0
+echo
+echo "****** $0: Running test: filelock1"
+echo
+./run-filelock1.sh
-- 
1.6.0.4
