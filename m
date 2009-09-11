From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Update to work with new user-cr command names, and on f11
Date: Fri, 11 Sep 2009 15:24:43 -0500
Message-ID: <20090911202443.GA13191@us.ibm.com>
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

1. Several .c files to be checkpointed are changed to close all
	fds between 0 and 100.  On F11, for some reason fds 4 and
	5 now point to libnspr4.so, which for some reason doesn't want
	to be checkpointed.
2. user-cr now renames mktree to restart, rstr to restart_self, and
	ckpt to checkpoint.  Stop using 'rstr' at all, just always
	use restart.  (Though it might lead to regressions in
	restart_self)

Note that the previous commit will still be available in the
'mktree' branch of cr_tests.

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 common.sh                     |   26 ++++++++------------------
 counterloop/cloop_once.sh     |   10 +++++-----
 counterloop/cloop_parallel.sh |    8 ++++----
 counterloop/cloop_serial.sh   |   13 ++++++-------
 counterloop/crcounter.c       |    7 +++----
 fileio/fileio1.c              |    3 ++-
 fileio/rstrsh                 |    4 ++--
 fileio/runtests.sh            |    4 ++--
 futex/run.sh                  |    6 +++---
 ipc/mktree.sh                 |    6 +++---
 ipc/test-mq.sh                |    8 ++++----
 ipc/test-sem.sh               |   12 ++++++------
 ipc/test-shm.sh               |   12 ++++++------
 process-tree/pthread1.c       |    2 +-
 process-tree/ptree1.c         |    2 +-
 process-tree/run-pthread1.sh  |   15 +++++++--------
 process-tree/run-ptree1.sh    |   15 +++++++--------
 runall.sh                     |   14 ++++----------
 simple/runtests.sh            |    8 ++++----
 sleep/runtest.sh              |    9 ++++-----
 userns/run_depth.sh           |    4 ++--
 userns/run_sbits.sh           |    4 ++--
 userns/run_simple.sh          |    4 ++--
 userns/run_userns.sh          |    4 ++--
 userns/run_usertask.sh        |    4 ++--
 25 files changed, 92 insertions(+), 112 deletions(-)

diff --git a/common.sh b/common.sh
index 911dc2a..c8de74f 100644
--- a/common.sh
+++ b/common.sh
@@ -13,19 +13,14 @@ verify_freezer()
 
 verify_paths()
 {
-	which ckpt > /dev/null 2>&1
+	which checkpoint > /dev/null 2>&1
 	if [ $? -ne 0 ]; then
-		echo "BROK: ckpt not in path"
+		echo "BROK: checkpoint not in path"
 		exit 1
 	fi
-	which rstr > /dev/null 2>&1
+	which restart > /dev/null 2>&1
 	if [ $? -ne 0 ]; then
-		echo "BROK: rstr not in path"
-		exit 1
-	fi
-	which mktree > /dev/null 2>&1
-	if [ $? -ne 0 ]; then
-		echo "BROK: mktree not in path"
+		echo "BROK: restart not in path"
 		exit 1
 	fi
 }
@@ -82,18 +77,13 @@ settimer()
 	timerpid=`jobs -p | tail -1`
 }
 
-CKPT=`which ckpt`
-if [ $? -ne 0 ]; then
-	echo "BROK: ckpt not found in your path"
-	exit 1
-fi
-RSTR=`which rstr`
+CHECKPOINT=`which checkpoint`
 if [ $? -ne 0 ]; then
-	echo "BROK: rstr not found in your path"
+	echo "BROK: checkpoint not found in your path"
 	exit 1
 fi
-MKTREE=`which mktree`
+RESTART=`which restart`
 if [ $? -ne 0 ]; then
-	echo "BROK: mktree not found in your path"
+	echo "BROK: restart not found in your path"
 	exit 1
 fi
diff --git a/counterloop/cloop_once.sh b/counterloop/cloop_once.sh
index 093d82f..741c34d 100644
--- a/counterloop/cloop_once.sh
+++ b/counterloop/cloop_once.sh
@@ -6,8 +6,8 @@
 
 freezermountpoint=/cgroup
 
-CKPT=`which ckpt`
-RSTR=`which rstr`
+CHECKPOINT=`which checkpoint`
+RESTART=`which restart`
 
 DEBUG=0
 my_debug()
@@ -59,7 +59,7 @@ pid=`pidof crcounter`
 
 freeze $pid
 pre=`cat counter_out`
-$CKPT $pid > o.1
+$CHECKPOINT $pid > o.1
 unfreeze $pid
 
 echo "sleeping for 7 seconds to let counter_out be incremented"
@@ -70,8 +70,8 @@ prekill=`cat counter_out`
 unfreeze $pid
 kill $pid
 
-#../ns_exec -m $usercrdir/rstr < ./o.1 &
-$RSTR < ./o.1 &
+#../ns_exec -m $usercrdir/restart < ./o.1 &
+$RESTART < ./o.1 &
 
 echo "sleeping for 4 seconds to inc counter_out by less than last time"
 sleep 4
diff --git a/counterloop/cloop_parallel.sh b/counterloop/cloop_parallel.sh
index 34358ce..81ead65 100644
--- a/counterloop/cloop_parallel.sh
+++ b/counterloop/cloop_parallel.sh
@@ -8,8 +8,8 @@ freezermountpoint=/cgroup
 
 source ../common.sh
 
-CKPT=`which ckpt`
-RSTR=`which rstr`
+CHECKPOINT=`which checkpoint`
+RESTART=`which restart`
 
 cleanup()
 {
@@ -44,7 +44,7 @@ do_checkpoint()
 	pid=$1
 	cnt=$2
 	freeze $pid
-	$CKPT $pid > d.$cnt/ckpt.out
+	$CHECKPOINT $pid > d.$cnt/ckpt.out
 	unfreeze $pid
 	touch d.$cnt/ckptdone
 }
@@ -118,7 +118,7 @@ done
 echo Restarting all jobs in parallel
 
 for i in `seq 1 $NUMJOBS`; do
-	(cd d.$i; $RSTR < ckpt.out) &
+	(cd d.$i; $RESTART < ckpt.out) &
 done
 
 settimer 10
diff --git a/counterloop/cloop_serial.sh b/counterloop/cloop_serial.sh
index f72cb80..a19f4fc 100644
--- a/counterloop/cloop_serial.sh
+++ b/counterloop/cloop_serial.sh
@@ -7,9 +7,8 @@
 
 freezermountpoint=/cgroup
 
-CKPT=`which ckpt`
-RSTR=`which rstr`
-MKTREE=`which mktree`
+CHECKPOINT=`which checkpoint`
+RESTART=`which restart`
 
 DEBUG=0
 debug()
@@ -71,14 +70,14 @@ for cnt in `seq 1 $NUMLOOPS`; do
 		exit 1
 	fi
 	freeze $pid
-	$CKPT $pid > o.$cnt
-	echo ckpt returned $?
+	$CHECKPOINT $pid > o.$cnt
+	echo checkpoint returned $?
 	kill -9 $pid
 	unfreeze $pid
-	#../ns_exec -m $RSTR < ./o.$cnt &
+	#../ns_exec -m $RESTART < ./o.$cnt &
 	wait $pid
 	rm -f counter_out
-	$RSTR < ./o.$cnt &
+	$RESTART < ./o.$cnt &
 	while [ ! -f counter_out ]; do : ; done
 done
 
diff --git a/counterloop/crcounter.c b/counterloop/crcounter.c
index fb0e619..0d2e5e1 100644
--- a/counterloop/crcounter.c
+++ b/counterloop/crcounter.c
@@ -14,11 +14,10 @@ int main()
 	int cnt=0;
 	FILE *f;
 	char fnam[20];
+	int i;
 
-	close(0);
-	close(1);
-	close(2);
-	close(3);
+	for (i=0; i<100; i++)
+		close(i);
 	f = fopen("counter_out", "r");
 	if (!f) {
 		cnt = 1;
diff --git a/fileio/fileio1.c b/fileio/fileio1.c
index f899b20..4b43611 100644
--- a/fileio/fileio1.c
+++ b/fileio/fileio1.c
@@ -226,6 +226,7 @@ int main(int argc, char *argv[])
 {
 	int c;
 	int fd;
+	int i;
 	char *srcfile;
 	char *destfile;
 	enum test_mode mode;
@@ -244,7 +245,7 @@ int main(int argc, char *argv[])
 	 * Cannot checkpoint process with open device files yet;
 	 */
 	printf("Closing stdio fds and writing messages to %s\n", LOG_FILE);
-	close(0);close(1);close(2);
+	for (i=0; i<100; i++) close(i);
 
 	/*
 	 * Announce that we are now prepared for a checkpoint 
diff --git a/fileio/rstrsh b/fileio/rstrsh
index bb0dbf0..843b892 100755
--- a/fileio/rstrsh
+++ b/fileio/rstrsh
@@ -1,3 +1,3 @@
 #!/bin/sh
-RSTR=`which rstr`
-$RSTR < $1
+RESTART=`which restart`
+$RESTART < $1
diff --git a/fileio/runtests.sh b/fileio/runtests.sh
index 5990a0e..40692b5 100755
--- a/fileio/runtests.sh
+++ b/fileio/runtests.sh
@@ -5,8 +5,8 @@
 freezermountpoint=/cgroup
 CHECKPOINT="../"
 NS_EXEC="../ns_exec"
-CR=`which ckpt`
-RSTR=`which rstr`
+CR=`which checkpoint`
+RSTR=`which restart`
 
 SLOW_DOWN="slow-down-fileio"
 CKPT_FILE="ckpt-fileio1";
diff --git a/futex/run.sh b/futex/run.sh
index ae80111..0f7d2b1 100755
--- a/futex/run.sh
+++ b/futex/run.sh
@@ -70,7 +70,7 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 	sync
 	cp log.${T} log.${T}.pre-ckpt
 	err_msg="FAIL"
-	ckpt ${TEST_PID} > checkpoint-${T}
+	$CHECKPOINT ${TEST_PID} > checkpoint-${T}
 	err_msg="BROK"
 	thaw
 	trap 'do_err; break' ERR EXIT
@@ -91,11 +91,11 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 	mv log.${T} log.${T}.post-ckpt
 	cp log.${T}.pre-ckpt log.${T}
 	err_msg="FAIL"
-	# We need to pass -p to mktree since futexes often store the
+	# We need to pass -p to restart since futexes often store the
 	# pid of the task that owns the futex in the futex, even in
 	# the uncontended cases where the kernel is entirely unaware
 	# of the futex. --copy-status ensures that we trap on error.
-	${MKTREE} -p --copy-status < checkpoint-${T}
+	${RESTART} -p --copy-status < checkpoint-${T}
 	retval=$?
 	err_msg="BROK"
 	mv log.${T} log.${T}.post-rstr
diff --git a/ipc/mktree.sh b/ipc/mktree.sh
index a747ba4..5d1ca99 100755
--- a/ipc/mktree.sh
+++ b/ipc/mktree.sh
@@ -1,4 +1,4 @@
 #!/bin/bash
-MKTREE=`which mktree`
-echo mktree.sh: running $MKTREE $1
-$MKTREE $1
+RESTART=`which restart`
+echo mktree.sh: running $RESTART $1
+$RESTART $1
diff --git a/ipc/test-mq.sh b/ipc/test-mq.sh
index 1db439c..e8a7fea 100644
--- a/ipc/test-mq.sh
+++ b/ipc/test-mq.sh
@@ -22,7 +22,7 @@ do_checkpoint() {
 		echo "failed to execute testcase"
 		exit 2
 	fi
-	ckpt $pid > ckpt.msq
+	${CHECKPOINT} $pid > ckpt.msq
 	thaw
 	killall check-mq
 }
@@ -32,7 +32,7 @@ clean_all
 ../ns_exec -ci ./check-mq &
 do_checkpoint
 # Restart it.  If it finds the msq it created, it creates msq-ok
-$MKTREE < ckpt.msq
+$RESTART < ckpt.msq
 if [ ! -f sandbox/msq-ok ]; then
 	echo "Fail: sysv msq was not re-created"
 	exit 1
@@ -44,7 +44,7 @@ clean_all
 ../ns_exec -ci ./check-mq -u 501 &
 do_checkpoint
 # restart should fail to create msq
-$MKTREE < ckpt.msq
+$RESTART < ckpt.msq
 if [ -f sandbox/msq-ok ]; then
 	echo "Fail: sysv msq was re-created"
 	exit 1
@@ -57,7 +57,7 @@ clean_all
 ../ns_exec -ci ./check-mq -e -u 501 &
 do_checkpoint
 # restart should be able to create msq
-$MKTREE < ckpt.msq
+$RESTART < ckpt.msq
 if [ ! -f sandbox/msq-ok ]; then
 	echo "Fail: sysv msq was not re-created"
 	exit 1
diff --git a/ipc/test-sem.sh b/ipc/test-sem.sh
index 1d012d5..89533db 100644
--- a/ipc/test-sem.sh
+++ b/ipc/test-sem.sh
@@ -22,7 +22,7 @@ do_checkpoint() {
 		echo "failed to execute testcase"
 		exit 2
 	fi
-	ckpt $pid > ckpt.sem
+	${CHECKPOINT} $pid > ckpt.sem
 	thaw
 	killall create-sem
 }
@@ -32,7 +32,7 @@ clean_all
 ../ns_exec -ci ./create-sem &
 do_checkpoint
 # Restart it.  If it finds the sem it created, it creates sem-ok
-$MKTREE < ckpt.sem
+$RESTART < ckpt.sem
 if [ ! -f sandbox/sem-ok ]; then
 	echo "Fail: sysv sem was not re-created"
 	exit 1
@@ -44,7 +44,7 @@ clean_all
 ../ns_exec -ci ./create-sem -u 501 &
 do_checkpoint
 # restart should fail to create sems
-$MKTREE < ckpt.sem
+$RESTART < ckpt.sem
 if [ -f sandbox/sem-ok ]; then
 	echo "Fail: sysv sem was re-created"
 	exit 1
@@ -57,7 +57,7 @@ clean_all
 ../ns_exec -ci ./create-sem -e -u 501 &
 do_checkpoint
 # restart should be able to create sems
-$MKTREE < ckpt.sem
+$RESTART < ckpt.sem
 if [ ! -f sandbox/sem-ok ]; then
 	echo "Fail: sysv sem was not re-created"
 	exit 1
@@ -73,11 +73,11 @@ fi
 ../ns_exec -ci ./create-sem -r -u $uid &
 do_checkpoint
 chown $uid ckpt.sem
-setcap cap_sys_admin+pe $MKTREE
+setcap cap_sys_admin+pe $RESTART
 cat ckpt.sem | su ltp -c ./mktree.sh ckpt.sem
 if [ -f sandbox/sem-ok ]; then
 	echo "Fail: uid $uid managed to recreate root-owned sems"
 	exit 1
 fi
-setcap -r $MKTREE
+setcap -r $RESTART
 echo "PASS: restart failed as it was supposed to"
diff --git a/ipc/test-shm.sh b/ipc/test-shm.sh
index 5157435..55e3da2 100644
--- a/ipc/test-shm.sh
+++ b/ipc/test-shm.sh
@@ -22,7 +22,7 @@ do_checkpoint() {
 		echo "failed to execute testcase"
 		exit 2
 	fi
-	ckpt $pid > ckpt.shm
+	${CHECKPOINT} $pid > ckpt.shm
 	thaw
 	killall create-shm
 }
@@ -32,7 +32,7 @@ clean_all
 ../ns_exec -ci ./create-shm &
 do_checkpoint
 # Restart it.  If it finds the shm it created, it creates shm-ok
-$MKTREE < ckpt.shm
+$RESTART < ckpt.shm
 if [ ! -f sandbox/shm-ok ]; then
 	echo "Fail: sysv shm was not re-created"
 	exit 1
@@ -44,7 +44,7 @@ clean_all
 ../ns_exec -ci ./create-shm -u 501 &
 do_checkpoint
 # restart should fail to create shm
-$MKTREE < ckpt.shm
+$RESTART < ckpt.shm
 if [ -f sandbox/shm-ok ]; then
 	echo "Fail: sysv shm was re-created"
 	exit 1
@@ -57,7 +57,7 @@ clean_all
 ../ns_exec -ci ./create-shm -e -u 501 &
 do_checkpoint
 # restart should be able to create shm
-$MKTREE < ckpt.shm
+$RESTART < ckpt.shm
 if [ ! -f sandbox/shm-ok ]; then
 	echo "Fail: sysv shm was not re-created"
 	exit 1
@@ -73,11 +73,11 @@ fi
 ../ns_exec -ci ./create-shm -r -u $uid &
 do_checkpoint
 chown $uid ckpt.shm
-setcap cap_sys_admin+pe $MKTREE
+setcap cap_sys_admin+pe $RESTART
 cat ckpt.shm | su ltp -c ./mktree.sh
 if [ -f sandbox/shm-ok ]; then
 	echo "Fail: uid $uid managed to recreate root-owned shms"
 	exit 1
 fi
-setcap -r $MKTREE
+setcap -r $RESTART
 echo "PASS: restart failed as it was supposed to"
diff --git a/process-tree/pthread1.c b/process-tree/pthread1.c
index b49d1a2..8bf2c44 100644
--- a/process-tree/pthread1.c
+++ b/process-tree/pthread1.c
@@ -105,7 +105,7 @@ main(int argc, char *argv[])
 		}
 	};
 
-	close(0);close(1);close(2);
+	for (i=0; i<100; i++) close(i);
 
 	tid_list = create_threads(num_threads);
 
diff --git a/process-tree/ptree1.c b/process-tree/ptree1.c
index 21f525c..4c8e747 100644
--- a/process-tree/ptree1.c
+++ b/process-tree/ptree1.c
@@ -176,7 +176,7 @@ main(int argc, char *argv[])
 		}
 	};
 
-	close(0);close(1);close(2);
+	for (i=0; i<100; i++) close(i);
 
 	create_children(1, id_str);
 
diff --git a/process-tree/run-pthread1.sh b/process-tree/run-pthread1.sh
index d217c4d..f11a547 100755
--- a/process-tree/run-pthread1.sh
+++ b/process-tree/run-pthread1.sh
@@ -7,9 +7,8 @@ CHECKPOINT=".."
 #	test to fail with "container not isolated" message due to the
 #	log-file being shared between the application threads.
 #
-CR="`which ckpt` --container"
-RSTR=`which rstr`
-MKTREE=`which mktree`
+CHECKPOINT="`which checkpoint` --container"
+RESTART=`which restart`
 ECHO="/bin/echo -e"
 
 TEST_CMD="./pthread1"
@@ -58,8 +57,8 @@ checkpoint()
 {
 	local pid=$1
 
-	$ECHO "Checkpoint: $CR $pid \> $CHECKPOINT_FILE"
-	$CR $pid > $CHECKPOINT_FILE
+	$ECHO "Checkpoint: $CHECKPOINT $pid \> $CHECKPOINT_FILE"
+	$CHECKPOINT $pid > $CHECKPOINT_FILE
 	ret=$?
 	if [ $ret -ne 0 ]; then
 		$ECHO "***** FAIL: Checkpoint of $pid failed"
@@ -106,7 +105,7 @@ function restart_container
 {
 	local ret;
 
-	cmdline="$MKTREE --pids --pidns --wait"
+	cmdline="$RESTART --pids --pidns --wait"
 	$ECHO "\t- $cmdline"
 
 	sleep 1
@@ -209,10 +208,10 @@ while [ $cnt -lt 15 ]; do
 	$ECHO "\t- num_pids1 $num_pids1, num_pids2 $num_pids2";
 
 	# ns_exec pid is parent-pid of restarted-container-init
-	nspid=`pidof mktree`
+	nspid=`pidof restart`
 
 	if [ "x$nspid" == "x" ]; then
-		$ECHO "***** FAIL: Can't find pid of $MKTREE"
+		$ECHO "***** FAIL: Can't find pid of $RESTART"
 		exit 1;
 	fi
 	
diff --git a/process-tree/run-ptree1.sh b/process-tree/run-ptree1.sh
index 83d7bf8..fc554c6 100755
--- a/process-tree/run-ptree1.sh
+++ b/process-tree/run-ptree1.sh
@@ -3,9 +3,8 @@
 freezermountpoint=/cgroup
 BASE_DIR=".."
 
-CR=`which ckpt`
-RSTR=`which rstr`
-MKTREE=`which mktree`
+CHECKPOINT=`which checkpoint`
+RESTART=`which restart`
 FILEIO="../fileio/fileio1"
 
 ECHO="/bin/echo -e"
@@ -60,8 +59,8 @@ checkpoint()
 {
 	local pid=$1
 
-	$ECHO "Checkpoint: $CR $pid \> $CHECKPOINT_FILE"
-	$CR $pid > $CHECKPOINT_FILE
+	$ECHO "Checkpoint: $CHECKPOINT $pid \> $CHECKPOINT_FILE"
+	$CHECKPOINT $pid > $CHECKPOINT_FILE
 	ret=$?
 	if [ $ret -ne 0 ]; then
 		$ECHO "***** FAIL: Checkpoint of $pid failed"
@@ -108,7 +107,7 @@ function restart_container
 {
 	local ret;
 
-	cmdline="$MKTREE --pids --pidns --wait"
+	cmdline="$RESTART --pids --pidns --wait"
 	$ECHO "\t- $cmdline"
 
 	sleep 1
@@ -229,10 +228,10 @@ while [ $cnt -lt 15 ]; do
 	$ECHO "\t- num_pids1 $num_pids1, num_pids2 $num_pids2";
 
 	# ns_exec pid is parent-pid of restarted-container-init
-	nspid=`pidof mktree`
+	nspid=`pidof restart`
 
 	if [ "x$nspid" == "x" ]; then
-		$ECHO "***** FAIL: Can't find pid of $MKTREE"
+		$ECHO "***** FAIL: Can't find pid of $RESTART"
 		exit 1;
 	fi
 	
diff --git a/runall.sh b/runall.sh
index 756a7b5..77e8001 100644
--- a/runall.sh
+++ b/runall.sh
@@ -2,25 +2,19 @@
 # Copyright 2009 IBM Corp.
 # Author: Serge Hallyn
 
-which ckpt > /dev/null 2>&1
+which checkpoint > /dev/null 2>&1
 if [ $? -ne 0 ]; then
 	echo Please place ckpt from user-cr in your PATH
 	exit 1
 fi
-which rstr > /dev/null 2>&1
+which restart > /dev/null 2>&1
 if [ $? -ne 0 ]; then
 	echo Please place rstr from user-cr in your PATH
 	exit 1
 fi
-which mktree > /dev/null 2>&1
-if [ $? -ne 0 ]; then
-	echo Please place mktree from user-cr in your PATH
-	exit 1
-fi
 
-export CKPT=`which ckpt`
-export MKTREE=`which mktree`
-export RSTR=`which rstr`
+export CHECKPOINT=`which checkpoint`
+export RESTART=`which restart`
 
 line=`grep freezer /proc/mounts`
 if [ $? -ne 0 ]; then
diff --git a/simple/runtests.sh b/simple/runtests.sh
index 860a5ee..d682137 100755
--- a/simple/runtests.sh
+++ b/simple/runtests.sh
@@ -2,7 +2,7 @@
 # Copyright 2009 IBM Corp.
 # Author: Serge Hallyn
 
-RSTR=`which rstr`
+RESTART=`which restart`
 
 ./ckpt > out
 if [ ! -f /tmp/cr-test.out ]; then
@@ -21,14 +21,14 @@ if [ ! $v -gt 0 ]; then
 	exit 3
 fi
 
-$RSTR < out
+$RESTART < out
 v=`grep ret /tmp/cr-test.out | awk -F=  '{ print $2 }'`
 if [ "x$v" == "x" ]; then
-	echo "FAIL - rstrt return value was not in /tmp/cr-test.out"
+	echo "FAIL - restart return value was not in /tmp/cr-test.out"
 	exit 4
 fi
 if [ $v -ne 0 ]; then
-	echo "FAIL - rstrt return value was $v, should be == 0"
+	echo "FAIL - restart return value was $v, should be == 0"
 	exit 5
 fi
 echo PASS
diff --git a/sleep/runtest.sh b/sleep/runtest.sh
index 3119167..a6fabf1 100644
--- a/sleep/runtest.sh
+++ b/sleep/runtest.sh
@@ -13,9 +13,8 @@ fi
 freezermountpoint=`echo $line | awk '{ print $2 '}`
 mkdir $freezermountpoint/1 > /dev/null 2>&1
 
-MKTREE=`which mktree`
-CKPT=`which ckpt`
-RSTR=`which rstr`
+RESTART=`which restart`
+CHECKPOINT=`which checkpoint`
 
 freeze()
 {
@@ -32,10 +31,10 @@ killall sleeptest > /dev/null 2>&1
 ./sleeptest &
 sleep 1
 freeze
-$CKPT `pidof sleeptest` > o.sleep
+$CHECKPOINT `pidof sleeptest` > o.sleep
 thaw
 killall sleeptest
-$MKTREE --pids < o.sleep &
+$RESTART --pids < o.sleep &
 sleep 1
 pidof sleeptest
 if [ $? -ne 0 ]; then
diff --git a/userns/run_depth.sh b/userns/run_depth.sh
index d13d73c..fd69ed6 100644
--- a/userns/run_depth.sh
+++ b/userns/run_depth.sh
@@ -15,12 +15,12 @@ canceltimer
 job=`jobs -p | head -1`
 freeze
 echo "Checkpointing job $job"
-$CKPT $job > o.deep
+$CHECKPOINT $job > o.deep
 thaw
 killall userns_deep
 
 echo "Restarting jobs"
-$MKTREE < o.deep &
+$RESTART < o.deep &
 
 touch sandbox/go
 touch sandbox/die
diff --git a/userns/run_sbits.sh b/userns/run_sbits.sh
index 0369b3f..9955f05 100644
--- a/userns/run_sbits.sh
+++ b/userns/run_sbits.sh
@@ -23,10 +23,10 @@ do_yer_thang()
 		exit 1
 	fi;
 	freeze
-	$CKPT $pid > out.$pid
+	$CHECKPOINT $pid > out.$pid
 	thaw
 	killall sbits
-	$RSTR < out.$pid &
+	$RESTART < out.$pid &
 	touch checkpointed
 
 	settimer 5
diff --git a/userns/run_simple.sh b/userns/run_simple.sh
index 913a6cb..e023f55 100644
--- a/userns/run_simple.sh
+++ b/userns/run_simple.sh
@@ -14,12 +14,12 @@ canceltimer
 job=`jobs -p | head -1`
 freeze
 echo "Checkpointing job $job"
-$CKPT $job > o.simple
+$CHECKPOINT $job > o.simple
 thaw
 killall simple_deep
 
 echo "Restarting jobs"
-$MKTREE < o.simple &
+$RESTART < o.simple &
 
 touch sandbox/go
 touch sandbox/die
diff --git a/userns/run_userns.sh b/userns/run_userns.sh
index e5ff107..6d94484 100644
--- a/userns/run_userns.sh
+++ b/userns/run_userns.sh
@@ -15,12 +15,12 @@ canceltimer
 job=`jobs -p|head -1`
 freeze
 echo "Checkpointing job $job"
-$CKPT $job > o.userns
+$CHECKPOINT $job > o.userns
 thaw
 killall userns_ckptme
 
 echo "Restarting jobs"
-$MKTREE < o.userns &
+$RESTART < o.userns &
 
 touch sandbox/go
 touch sandbox/die
diff --git a/userns/run_usertask.sh b/userns/run_usertask.sh
index 7cf4685..8f0408b 100644
--- a/userns/run_usertask.sh
+++ b/userns/run_usertask.sh
@@ -26,10 +26,10 @@ canceltimer
 pid=`pidof usertask`
 
 freeze
-$CKPT $pid > ckpt.out
+$CHECKPOINT $pid > ckpt.out
 thaw
 kill -9 $pid
-$RSTR < ckpt.out &
+$RESTART < ckpt.out &
 touch sandbox/go
 
 settimer 5
-- 
1.6.2.5
