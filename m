From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 03/11] Check for failure while waiting for checkpoint-ready
Date: Fri, 29 Jan 2010 12:38:19 -0800
Message-ID: <20100129203819.GB26721@us.ibm.com>
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
Date: Mon, 25 Jan 2010 18:09:50 -0800
Subject: [PATCH 03/11] Check for failure while waiting for checkpoint-ready

It is possible that an application has encountered an error before creating
the checkpoint-ready file. So while polling for 'checkpoint-ready' to be true,
look for errors in the log file.

Also, ensure filelock temp files are cleaned up by 'make clean'.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fileio/Makefile         |    2 +-
 fileio/run-filelock1.sh |   24 +++++++++++++++---------
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/fileio/Makefile b/fileio/Makefile
index 40d19da..eb3887b 100644
--- a/fileio/Makefile
+++ b/fileio/Makefile
@@ -9,4 +9,4 @@ all: $(LIBCRTEST) $(targets)
 
 clean:
 	rm -f $(targets)
-	rm -rf cr_fileio*
+	rm -rf cr_fileio* cr_filelock1*
diff --git a/fileio/run-filelock1.sh b/fileio/run-filelock1.sh
index 0ba2d18..b4bbaec 100755
--- a/fileio/run-filelock1.sh
+++ b/fileio/run-filelock1.sh
@@ -45,11 +45,25 @@ checkpoint()
 	fi
 }
 
+function check_for_failure()
+{
+	grep --binary-files=text FAIL $PWD/$TEST_LOG > /dev/null 2>&1
+	if [ $? -eq 0 ]; then
+		$ECHO "\t***** Application FAILED after restart" >> $SCRIPT_LOG
+		$ECHO "\t***** See $TEST_LOG for details" >> $SCRIPT_LOG
+
+		$ECHO "\t***** Application FAILED after restart"
+		$ECHO "\tSee $PWD/$TEST_LOG for details"
+		exit 1;
+	fi
+}
+
 function wait_for_checkpoint_ready()
 {
 	# Wait for test to finish setup
 	while [ ! -f $CHECKPOINT_READY ]; do
 		$ECHO "\t- Waiting for $CHECKPOINT_READY"
+		check_for_failure;
 		sleep 1;
 	done;
 }
@@ -202,15 +216,7 @@ while [ $cnt -lt 20 ]; do
 	wait $nspid;
 	ret=$?
 
-	grep --binary-files=text FAIL $PWD/$TEST_LOG > /dev/null 2>&1
-	if [ $? -eq 0 ]; then
-		$ECHO "\t***** Application FAILED after restart" >> $SCRIPT_LOG
-		$ECHO "\t***** See $TEST_LOG for details" >> $SCRIPT_LOG
-
-		$ECHO "\t***** Application FAILED after restart"
-		$ECHO "\tSee $PWD/$TEST_LOG for details"
-		exit 1;
-	fi
+	check_for_failure;
 
 	$ECHO "\t- Container exited, status $ret"
 
-- 
1.6.0.4
