From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/4] cr_tests/ptree1: remove dead code
Date: Fri, 26 Feb 2010 13:51:51 -0600
Message-ID: <1267213914-32219-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

The return status of a background command (e.g. "ls &") is always 0.
Failure to restart can't be detected this way.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 process-tree/run-ptree1.sh |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/process-tree/run-ptree1.sh b/process-tree/run-ptree1.sh
index 23955d0..6d56a66 100755
--- a/process-tree/run-ptree1.sh
+++ b/process-tree/run-ptree1.sh
@@ -90,13 +90,6 @@ function restart_container
 	sleep 1
 
 	$cmdline < $CHECKPOINT_FILE >> $SCRIPT_LOG 2>&1 &
-	ret=$?
-
-	if [ $ret -ne 0 ]; then
-		$ECHO "***** FAIL: Restart of $pid failed"
-		ps aux |grep $TEST_CMD >> $SCRIPT_LOG
-		exit 1;
-	fi
 }
 
 function wait_for_checkpoint_ready()
-- 
1.6.0.6
