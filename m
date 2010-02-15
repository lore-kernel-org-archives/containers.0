From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH cr-tests] file locks: don't report failed checkpoint as failure
Date: Mon, 15 Feb 2010 10:52:54 -0600
Message-ID: <20100215165254.GA5482@us.ibm.com>
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

And report failure if checkpoint succeeds, bc it should not.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fileio/run-fcntltests.sh |   10 +++++++++-
 fileio/runtests.sh       |    3 +++
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/fileio/run-fcntltests.sh b/fileio/run-fcntltests.sh
index 35be131..2a5f628 100755
--- a/fileio/run-fcntltests.sh
+++ b/fileio/run-fcntltests.sh
@@ -51,8 +51,16 @@ checkpoint()
 	$ECHO "\t- Checkpoint: $CHECKPOINT $pid \> $CHECKPOINT_FILE"
 	$CHECKPOINT $pid > $CHECKPOINT_FILE
 	ret=$?
+	# At the moment we expect failure because checkpoint
+	# of file locks is not supported
 	if [ $ret -ne 0 ]; then
-		$ECHO "***** FAIL: Checkpoint of $pid failed"
+		$ECHO "***** PASS: Checkpoint of $pid failed"
+		ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
+		killall -9 `basename $TEST_CMD`
+		thaw
+		exit 0;
+	else
+		$ECHO "***** FAIL: Checkpoint of $pid did not fail"
 		ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
 		killall -9 `basename $TEST_CMD`
 		thaw
diff --git a/fileio/runtests.sh b/fileio/runtests.sh
index b808927..cb633fb 100755
--- a/fileio/runtests.sh
+++ b/fileio/runtests.sh
@@ -7,15 +7,18 @@ echo
 
 echo
 echo "****** $0: Running test: filelock1"
+echo "****** (expect FAIL)"
 echo
 ./run-fcntltests.sh filelock1
 
 echo
 echo "****** $0: Running test: filelease1"
+echo "****** (expect FAIL)"
 echo
 ./run-fcntltests.sh filelease1
 
 echo
 echo "****** $0: Running test: fsetown1"
+echo "****** (expect FAIL)"
 echo
 ./run-fcntltests.sh fsetown1
-- 
1.6.3.3
