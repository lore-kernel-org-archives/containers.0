From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/4] cr_tests/ptree1: count tasks accurately
Date: Fri, 26 Feb 2010 13:51:52 -0600
Message-ID: <1267213914-32219-2-git-send-email-ntl@pobox.com>
References: <1267213914-32219-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1267213914-32219-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

"ps aux |grep $TEST_CMD | wc -l" tends to also count the grep process.
The test script already assumes pidof is available, so just use that.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 process-tree/run-ptree1.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/process-tree/run-ptree1.sh b/process-tree/run-ptree1.sh
index 6d56a66..d0cefff 100755
--- a/process-tree/run-ptree1.sh
+++ b/process-tree/run-ptree1.sh
@@ -174,7 +174,7 @@ while [ $cnt -lt 15 ]; do
 	freezerdir=$freezermountpoint/$pid
 	freeze_pid $pid
 
-	num_pids1=`ps aux |grep $TEST_CMD | wc -l`
+	num_pids1=`pidof $TEST_CMD | wc -w`
 
 	create_fs_snapshot
 
@@ -196,7 +196,7 @@ while [ $cnt -lt 15 ]; do
 
 	sleep 3;
 
-	num_pids2=`ps aux |grep $TEST_CMD | wc -l`
+	num_pids2=`pidof $TEST_CMD | wc -w`
 	ps aux |grep $TEST_CMD >> $SCRIPT_LOG
 	$ECHO "\t- num_pids1 $num_pids1, num_pids2 $num_pids2";
 
-- 
1.6.0.6
