From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][cr-tests] Have ps list all threads in application
Date: Thu, 10 Dec 2009 20:08:40 -0800
Message-ID: <20091211040840.GA20947@us.ibm.com>
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
Date: Tue, 8 Dec 2009 23:13:05 +0530
Subject: [PATCH 1/4] Have ps list all threads in application

Have ps list all threads in application

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 process-tree/run-pthread1.sh |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/process-tree/run-pthread1.sh b/process-tree/run-pthread1.sh
index 800ff30..e616753 100755
--- a/process-tree/run-pthread1.sh
+++ b/process-tree/run-pthread1.sh
@@ -40,7 +40,7 @@ checkpoint()
 	ret=$?
 	if [ $ret -ne 0 ]; then
 		$ECHO "***** FAIL: Checkpoint of $pid failed"
-		ps aux |grep $TEST_CMD >> $SCRIPT_LOG
+		ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
 		exit 1;
 	fi
 }
@@ -73,7 +73,7 @@ function create_container()
 	pid=`cat $TEST_PID_FILE`;
 	if [  "x$pid" == "x" ]; then
 		$ECHO "***** FAIL: Invalid container-init pid $pid"
-		ps aux |grep $TEST_CMD >> $SCRIPT_LOG
+		ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
 		exit 1
 	fi
 	$ECHO "Created container with pid $pid" >> $SCRIPT_LOG
@@ -93,7 +93,7 @@ function restart_container
 
 	if [ $ret -ne 0 ]; then
 		$ECHO "***** FAIL: Restart of $pid failed"
-		ps aux |grep $TEST_CMD >> $SCRIPT_LOG
+		ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
 		exit 1;
 	fi
 }
@@ -160,7 +160,7 @@ while [ $cnt -lt 15 ]; do
 	$ECHO "\t- Done creating container, cinit-pid $pid"
 
 	wait_for_checkpoint_ready
-	ps aux |grep $TEST_CMD >> $SCRIPT_LOG
+	ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
 
 	# override default freezerdir
 	if [ -d $freezerdir ]; then
@@ -169,7 +169,7 @@ while [ $cnt -lt 15 ]; do
 	freezerdir=$freezermountpoint/$pid
 	freeze_pid $pid
 
-	num_pids1=`ps aux |grep $TEST_CMD | wc -l`
+	num_pids1=`ps -efL |grep $TEST_CMD | wc -l`
 
 	create_fs_snapshot
 
@@ -189,8 +189,8 @@ while [ $cnt -lt 15 ]; do
 
 	sleep 3;
 
-	num_pids2=`ps aux |grep $TEST_CMD | wc -l`
-	ps aux |grep $TEST_CMD >> $SCRIPT_LOG
+	num_pids2=`ps -efL |grep $TEST_CMD | wc -l`
+	ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
 	$ECHO "\t- num_pids1 $num_pids1, num_pids2 $num_pids2";
 
 	# ns_exec pid is parent-pid of restarted-container-init
-- 
1.6.0.4
