From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] cr_tests: attempt all tests
Date: Fri,  4 Dec 2009 21:22:14 -0600
Message-ID: <1259983334-25854-2-git-send-email-ntl@pobox.com>
References: <1259983334-25854-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1259983334-25854-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

Bailing at the first failure in runall.sh inhibits good test coverage.

Attempt to run all tests and keep running counts of tests passed and
attempted.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 runall.sh |   60 ++++++++++++++++++++++++------------------------------------
 1 files changed, 24 insertions(+), 36 deletions(-)

diff --git a/runall.sh b/runall.sh
index 11e8fab..d15dc25 100644
--- a/runall.sh
+++ b/runall.sh
@@ -2,6 +2,20 @@
 # Copyright 2009 IBM Corp.
 # Author: Serge Hallyn
 
+declare -i total=0
+declare -i passed=0
+
+# $1 = status
+update_totals() {
+    local status=$1
+    total+=1
+    if [ $status -eq 0 ] ; then
+	passed+=1
+    else
+	echo FAIL
+    fi
+}
+
 which checkpoint > /dev/null 2>&1
 if [ $? -ne 0 ]; then
 	echo Please place ckpt from user-cr in your PATH
@@ -32,82 +46,56 @@ fi
 echo Running simple checkpoint/restart test
 pushd simple
 bash runtests.sh
-if [ $? -ne 0 ]; then
-	echo FAIL
-	exit 1
-fi
+update_totals $?
 popd
 
 echo Running counterloop tests
 pushd counterloop
 bash runtests.sh
-if [ $? -ne 0 ]; then
-	echo FAIL
-	exit 2
-fi
+update_totals $?
 popd
 
 echo Running fileio test
 pushd fileio
 bash runtests.sh
-if [ $? -ne 0 ]; then
-	echo FAIL
-	exit 3
-fi
+update_totals $?
 popd
 
 echo Running futex tests
 pushd futex
 bash run.sh
-if [ $? -ne 0 ]; then
-	echo FAIL
-	exit 8
-fi
+update_totals $?
 popd
 
 echo Running restart block test
 pushd sleep
 bash runtest.sh
-if [ $? -ne 0 ]; then
-	echo FAIL
-	exit 6
-fi
+update_totals $?
 popd
 
 echo Running process-tree tests
 pushd process-tree
 sh runtests.sh
-if [ $? -ne 0 ]; then
-	echo FAIL
-	exit 7
-fi
+update_totals $?
 popd
 
 echo Running bash test
 pushd bashckpt
 bash bash-cr.sh
-if [ $? -ne 0 ]; then
-	echo FAIL
-	exit 5
-fi
+update_totals $?
 popd
 
 echo Running ipc tests
 pushd ipc
 bash runtests.sh
-if [ $? -ne 0 ]; then
-	echo FAIL
-	exit 6
-fi
+update_totals $?
 popd
 
 echo Running userid/namespace test
 pushd userns
 bash runtests.sh
-if [ $? -ne 0 ]; then
-	echo FAIL
-	exit 4
-fi
+update_totals $?
 popd
 
+echo $passed out of $total test groups passed.
 exit 0
-- 
1.6.0.6
