From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 06/11] cr_tests: Cleanup error handling in futex/run.sh
Date: Wed, 19 Aug 2009 21:58:09 -0700
Message-ID: <cef4734edac56cbf7188128c8f3d3576e69e6256.1250744013.git.matthltc@us.ibm.com>
References: <de6ca903a5d388cc10694ff95530b27d5142f1eb.1250744013.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <de6ca903a5d388cc10694ff95530b27d5142f1eb.1250744013.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

The previous trap handler didn't properly handle errors. It could leave
extra tasks around if the group was frozen or checkpoint-done hadn't
been touched. Add code to handle the errors as a special do_err()
function so that we don't bother the body of the test loop very much.

We use an error message to indicate if the problem seems to be a test
failure ("FAIL") or if it's probably the test itself that is broken
("BROK"). This means we don't constantly need to change the trap
-- just assign a different value to err_msg before and after executing
the interesting parts of the test.

We also need to recover if the cgroup has been frozen. Add that to the
trap temporarily.

Also, to avoid spurious messages about "break" only being valid inside
a loop, reset the trap after exiting the loop.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 futex/run.sh |   24 ++++++++++++++++++++++--
 1 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/futex/run.sh b/futex/run.sh
index e54c228..434a844 100755
--- a/futex/run.sh
+++ b/futex/run.sh
@@ -37,12 +37,27 @@ fi
 # mkdir /cg/1
 # chown -R $(id --name -u).$(id --name -g) /cg/1
 
+# Most failures indicate a broken test environment
+err_msg="BROK"
+function do_err()
+{
+	if [ -n "${TEST_PID}" ]; then
+		local PIDLIST=( $(ps --ppid ${TEST_PID} -o pid=) ${TEST_PID} )
+		kill ${PIDLIST[@]}
+	fi
+	echo "${err_msg}"
+	((failed++))
+	wait
+}
+
+failed=0
+
 NUMTESTS=${#TESTS[@]}
 CURTEST=0
 
 while [ $CURTEST -lt $NUMTESTS ]; do
 	T=${TESTS[$CURTEST]}
-	trap 'break' ERR EXIT
+	trap 'do_err; break' ERR EXIT
 	rm -f ./checkpoint-* TBROK
 	echo "Running test: ${T}"
 	./${T} &
@@ -51,8 +66,12 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 		sleep 1
 	done
 	freeze
+	trap 'thaw; do_err; break' ERR EXIT
+	err_msg="FAIL"
 	ckpt ${TEST_PID} > checkpoint-${T}
+	err_msg="BROK"
 	thaw
+	trap 'do_err; break' ERR EXIT
 	touch "./checkpoint-done"
 	wait ${TEST_PID}
 	retval=$?
@@ -78,9 +97,10 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 	else
 		echo PASS
 	fi
-	trap "" ERR EXIT
+	trap '' ERR EXIT
 	CURTEST=$((CURTEST+1))
 done
+trap '' ERR EXIT
 
 #rm -f ./checkpoint-*
 
-- 
1.5.6.3
