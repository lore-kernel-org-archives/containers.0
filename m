From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [cr_tests PATCH] robust futex: handle -EINTR snafus
Date: Tue, 4 Aug 2009 13:03:03 -0500
Message-ID: <20090804180303.GA8419@us.ibm.com>
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
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

[ will apply this patch to cr_tests unless Matt has comments ]

Freezing the robust futex waiters makes the syscall return with
-EINTR.  The task then ends up caling futex_wait_restart.  If
the futex value has already been changed by the parent, then
the futex_wait_restart will return -EAGAIN.

If that happens, have the kid create a file called 'TBROK'
and exit so the parent can reap it.  The run.sh shell is
rewritten so it will rerun the test if the file TBROK has
been created.

(note this has little to do with c/r, but rather with how
the freezer affects the futex api)

To recreate a hang with the robust testcase without this fix,
run the following script:

==============================================================
 #!/bin/bash

 #set -e

TEST=robust

source ../common.sh

lcv=0
while [ $lcv -lt 100 ]; do
	echo loop num $lcv
	rm -f ./checkpoint-*
	rm -f TBROK
	./${TEST} &
	TEST_PID=$!
	while [ '!' -r "./checkpoint-ready" ]; do
		sleep 1
	done
	freeze
	echo ckpt $TEST_PID
	ckpt $TEST_PID > checkpoint-${TEST}
	thaw
	touch "./checkpoint-done"
	wait ${TEST_PID}
	retval=$?
	if [ -f "TBROK" ]; then
		echo "XXX Futex snafu, re-running this test XXX"
		lcv=$((lcv-1))
		continue
	fi
	echo "Test ${TEST} done, returned $retval"
	if [ $retval -ne 0 ]; then
		echo FAIL
		exit 1
	else
		echo PASS
	fi

	lcv=$((lcv+1))
done

Signed-off-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 futex/robust.c |   10 +++++++++-
 futex/run.sh   |   13 +++++++++++--
 2 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/futex/robust.c b/futex/robust.c
index a52f638..6a5da78 100644
--- a/futex/robust.c
+++ b/futex/robust.c
@@ -103,10 +103,11 @@ void add_rfutex(struct futex *rf)
 
 void acquire_rfutex(struct futex *rf, pid_t tid)
 {
-	int val = 0;
+	int oldval, newval, val = 0;
 
 	rlist.list_op_pending = &rf->rlist; /* ARCH TODO make sure this assignment is atomic */
 
+	oldval = atomic_read(&rf->tid);
 	tid = tid & FUTEX_TID_MASK;
 	do {
 		val = atomic_cmpxchg(&rf->tid, 0, tid);
@@ -134,6 +135,13 @@ void acquire_rfutex(struct futex *rf, pid_t tid)
 				continue;
 			case EAGAIN:
 				log("WARN", "EAGAIN while sleeping on futex\n");
+				newval = atomic_read(&rf->tid);
+				if (newval != oldval) {
+					int ret = creat("TBROK", 0755);  
+					if (ret == -1)
+						fail++;
+					return;
+				}
 				continue;
 			case EINTR:
 				log("WARN", "EINTR while sleeping on futex\n");
diff --git a/futex/run.sh b/futex/run.sh
index 1ed23ad..1545841 100755
--- a/futex/run.sh
+++ b/futex/run.sh
@@ -37,9 +37,13 @@ fi
 # mkdir /cg/1
 # chown -R $(id --name -u).$(id --name -g) /cg/1
 
-for T in ${TESTS[@]} ; do
+NUMTESTS=${#TESTS[@]}
+CURTEST=0
+
+while [ $CURTEST -lt $NUMTESTS ]; do
+	T=${TESTS[$CURTEST]}
 	trap 'break' ERR EXIT
-	rm -f ./checkpoint-*
+	rm -f ./checkpoint-* TBROK
 	echo "Running test: ${T}"
 	./${T} &
 	TEST_PID=$!
@@ -53,6 +57,10 @@ for T in ${TESTS[@]} ; do
 	wait ${TEST_PID}
 	retval=$?
 	echo "Test ${T} done, returned $retval"
+	if [ -f "TBROK" ]; then
+		echo "BROK: Futex snafu, re-running this test"
+		continue
+	fi
 	if [ $retval -ne 0 ]; then
 		echo FAIL
 		exit 1
@@ -71,6 +79,7 @@ for T in ${TESTS[@]} ; do
 		echo PASS
 	fi
 	trap "" ERR EXIT
+	CURTEST=$((CURTEST+1))
 done
 
 #rm -f ./checkpoint-*
-- 
1.6.1.1
