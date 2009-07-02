From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [cr_tests PATCH 1/1] process-tree tests: several changes
Date: Wed, 1 Jul 2009 22:43:07 -0500
Message-ID: <20090702034307.GA2324@us.ibm.com>
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
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Make the freeze() function work right.

Use ns_exec -g and drop the use of ns cgroup.

Don't restart with ns_exec.  Use mktree --pids and --pidns
to create pidns.

run-ptree1.sh now passes for me.  run-pthread1.sh does not
(checkpoint: Resource temporarily unavailable).

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 process-tree/run-pthread1.sh |   36 +++++++++++++++---------------------
 process-tree/run-ptree1.sh   |   36 +++++++++++++++---------------------
 2 files changed, 30 insertions(+), 42 deletions(-)

diff --git a/process-tree/run-pthread1.sh b/process-tree/run-pthread1.sh
index 4a29e7c..d217c4d 100755
--- a/process-tree/run-pthread1.sh
+++ b/process-tree/run-pthread1.sh
@@ -1,6 +1,6 @@
 #!/bin/bash
 
-freezermountpoint=/cgroups
+freezermountpoint=/cgroup
 CHECKPOINT=".."
 
 # NOTE: As of ckpt-v15-dev, the --container option to 'ckpt' causes this
@@ -27,26 +27,22 @@ CHECKPOINT_DONE="checkpoint-done"
 LOGS_DIR="logs.d"
 
 NS_EXEC="../ns_exec"
-NS_EXEC_ARGS="-cpuimP $TEST_PID_FILE"
+NS_EXEC_ARGS="-cgpuimP $TEST_PID_FILE"
 
 freeze()
 {
 	$ECHO "\t - Freezing $1"
-	$ECHO FROZEN > ${freezermountpoint}/$1/freezer.state
-	ret=$?
-	if [ $ret -ne 0 ]; then
-		$ECHO "***** FAIL: \'echo FROZEN \> $state\' returned $ret"
-	fi
+	fnam="${freezermountpoint}/$1/freezer.state"
+	$ECHO FROZEN > $fnam
+	while [ `cat $fnam` != "FROZEN" ]; do
+		$ECHO FROZEN > $fnam
+	done
 }
 
 unfreeze()
 {
 	$ECHO "\t - Unfreezing $1"
 	$ECHO THAWED > ${freezermountpoint}/$1/freezer.state
-	ret=$?
-	if [ $ret -ne 0 ]; then
-		$ECHO "***** FAIL: \'echo THAWED \> $state\' returned $ret"
-	fi
 }
 
 cleancgroup()
@@ -110,7 +106,7 @@ function restart_container
 {
 	local ret;
 
-	cmdline="$NS_EXEC $NS_EXEC_ARGS -- $MKTREE --no-pids"
+	cmdline="$MKTREE --pids --pidns --wait"
 	$ECHO "\t- $cmdline"
 
 	sleep 1
@@ -156,21 +152,20 @@ function restore_fs_snapshot()
 
 # Check freezer mount point
 line=`grep freezer /proc/mounts`
-$ECHO $line | grep "\<ns\>"
 if [ $? -ne 0 ]; then
-	$ECHO "please mount freezer and ns cgroups"
-	$ECHO "  mkdir /cgroups"
-	$ECHO "  mount -t cgroup -o freezer,ns cgroup /cgroups"
+	$ECHO "please mount freezer cgroup"
+	$ECHO "  mkdir /cgroup"
+	$ECHO "  mount -t cgroup -o freezer cgroup /cgroup"
 	exit 1
 fi
 #freezermountpoint=`$ECHO $line | awk '{ print $2 '}`
 
-# Make sure no stray e2 from another run is still going
+# Make sure no stray pthread1 from another run is still going
 killall $TEST_CMD > $SCRIPT_LOG 2>&1
 
 > $SCRIPT_LOG;
 cnt=1
-while [ 1 ]; do
+while [ $cnt -lt 15 ]; do
 	$ECHO "===== Iteration $cnt"
 
 	# Remove any 'state' files, start the app and let it tell us
@@ -214,11 +209,10 @@ while [ 1 ]; do
 	$ECHO "\t- num_pids1 $num_pids1, num_pids2 $num_pids2";
 
 	# ns_exec pid is parent-pid of restarted-container-init
-	cinit_pid=`cat $TEST_PID_FILE`;
-	nspid=`awk '/PPid:/ {print $2}' /proc/$cinit_pid/status`
+	nspid=`pidof mktree`
 
 	if [ "x$nspid" == "x" ]; then
-		$ECHO "***** FAIL: Can't find pid of $NS_EXEC"
+		$ECHO "***** FAIL: Can't find pid of $MKTREE"
 		exit 1;
 	fi
 	
diff --git a/process-tree/run-ptree1.sh b/process-tree/run-ptree1.sh
index bc283f6..83d7bf8 100755
--- a/process-tree/run-ptree1.sh
+++ b/process-tree/run-ptree1.sh
@@ -1,6 +1,6 @@
 #!/bin/bash
 
-freezermountpoint=/cgroups
+freezermountpoint=/cgroup
 BASE_DIR=".."
 
 CR=`which ckpt`
@@ -28,27 +28,23 @@ CHECKPOINT_DONE="checkpoint-done"
 INPUT_DATA="input.data";
 
 NS_EXEC="$BASE_DIR/ns_exec"
-NS_EXEC_ARGS="-cpuimP $TEST_PID_FILE"
+NS_EXEC_ARGS="-cgpuimP $TEST_PID_FILE"
 
 
 freeze()
 {
 	$ECHO "\t - Freezing $1"
-	$ECHO FROZEN > ${freezermountpoint}/$1/freezer.state
-	ret=$?
-	if [ $ret -ne 0 ]; then
-		$ECHO "***** FAIL: \'echo FROZEN \> $state\' returned $ret"
-	fi
+	fnam="${freezermountpoint}/$1/freezer.state"
+	$ECHO FROZEN > $fnam
+	while [ `cat $fnam` != "FROZEN" ]; do
+		$ECHO FROZEN > $fnam
+	done
 }
 
 unfreeze()
 {
 	$ECHO "\t - Unfreezing $1"
 	$ECHO THAWED > ${freezermountpoint}/$1/freezer.state
-	ret=$?
-	if [ $ret -ne 0 ]; then
-		$ECHO "***** FAIL: \'echo THAWED \> $state\' returned $ret"
-	fi
 }
 
 cleancgroup()
@@ -112,7 +108,7 @@ function restart_container
 {
 	local ret;
 
-	cmdline="$NS_EXEC $NS_EXEC_ARGS -- $MKTREE --no-pids"
+	cmdline="$MKTREE --pids --pidns --wait"
 	$ECHO "\t- $cmdline"
 
 	sleep 1
@@ -158,16 +154,15 @@ function restore_fs_snapshot()
 
 # Check freezer mount point
 line=`grep freezer /proc/mounts`
-$ECHO $line | grep "\<ns\>"
 if [ $? -ne 0 ]; then
-	$ECHO "please mount freezer and ns cgroups"
-	$ECHO "  mkdir /cgroups"
-	$ECHO "  mount -t cgroup -o freezer,ns cgroup /cgroups"
+	$ECHO "please mount freezer cgroup"
+	$ECHO "  mkdir /cgroup"
+	$ECHO "  mount -t cgroup -o freezer cgroup /cgroup"
 	exit 1
 fi
 #freezermountpoint=`$ECHO $line | awk '{ print $2 '}`
 
-# Make sure no stray e2 from another run is still going
+# Make sure no stray ptree1 from another run is still going
 killall $TEST_CMD > $SCRIPT_LOG 2>&1
 
 if [ ! -d $LOGS_DIR ]; then
@@ -188,7 +183,7 @@ fi
 
 > $SCRIPT_LOG;
 cnt=1
-while [ 1 ]; do
+while [ $cnt -lt 15 ]; do
 	$ECHO "===== Iteration $cnt"
 
 	# Remove any 'state' files, start the app and let it tell us
@@ -234,11 +229,10 @@ while [ 1 ]; do
 	$ECHO "\t- num_pids1 $num_pids1, num_pids2 $num_pids2";
 
 	# ns_exec pid is parent-pid of restarted-container-init
-	cinit_pid=`cat $TEST_PID_FILE`;
-	nspid=`awk '/PPid:/ {print $2}' /proc/$cinit_pid/status`
+	nspid=`pidof mktree`
 
 	if [ "x$nspid" == "x" ]; then
-		$ECHO "***** FAIL: Can't find pid of $NS_EXEC"
+		$ECHO "***** FAIL: Can't find pid of $MKTREE"
 		exit 1;
 	fi
 	
-- 
1.6.1.1
