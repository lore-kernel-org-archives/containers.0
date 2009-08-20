From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 07/11] cr_tests: Compress more of the error handling code
	using trap.
Date: Wed, 19 Aug 2009 21:58:10 -0700
Message-ID: <0a55d0f0ad3a30a6bc4ecb380e072a2667ef4622.1250744013.git.matthltc@us.ibm.com>
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

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 futex/run.sh |   29 ++++++++++++++++-------------
 1 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/futex/run.sh b/futex/run.sh
index 434a844..5587520 100755
--- a/futex/run.sh
+++ b/futex/run.sh
@@ -1,6 +1,6 @@
 #!/bin/bash
 
-#set -e
+set -e
 
 source ../common.sh
 
@@ -80,23 +80,24 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 		echo "BROK: Futex snafu, re-running this test"
 		continue
 	fi
-	if [ $retval -ne 0 ]; then
-		echo FAIL
-		exit 1
-	else
-		echo PASS
-	fi
+	err_msg="FAIL"
+	[ $retval -eq 0 ]
+	err_msg="BROK"
+	echo PASS
 
 	# now try restarting
+	err_msg="FAIL"
+	# We need to pass -p to mktree since futexes often store the
+	# pid of the task that owns the futex in the futex, even in
+	# the uncontended cases where the kernel is entirely unaware
+	# of the futex. --copy-status ensures that we trap on error.
 	${MKTREE} -p --copy-status < checkpoint-${T}
 	retval=$?
+	err_msg="BROK"
 	echo "Restart of test ${T} done, returned $retval"
-	if [ $retval -ne 0 ]; then
-		echo FAIL
-		exit 1
-	else
-		echo PASS
-	fi
+	err_msg="FAIL"
+	[ $retval -eq 0 ];
+	echo PASS
 	trap '' ERR EXIT
 	CURTEST=$((CURTEST+1))
 done
@@ -106,3 +107,5 @@ trap '' ERR EXIT
 
 # rmdir /cg/1
 # umount /cg
+
+exit ${failed}
-- 
1.5.6.3
