From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH][cr-test]: run-fcntltests.sh: Thaw and cleanup processes on
	error
Date: Tue, 9 Feb 2010 11:31:55 -0800
Message-ID: <20100209193155.GA30005@us.ibm.com>
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
Date: Tue, 9 Feb 2010 11:08:22 -0800
Subject: [PATCH][cr-test]: run-fcntltests.sh: Thaw and cleanup processes on error

If the fcntl tests (filelock[12], filelease1 and fsetown1) fail during
checkpoint, the processes end up frozen and appear hung.  Thaw the
processes and terminate them before exiting the script.

Bug reported by Serge Hallyn.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fileio/run-fcntltests.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fileio/run-fcntltests.sh b/fileio/run-fcntltests.sh
index f76c942..35be131 100755
--- a/fileio/run-fcntltests.sh
+++ b/fileio/run-fcntltests.sh
@@ -54,6 +54,8 @@ checkpoint()
 	if [ $ret -ne 0 ]; then
 		$ECHO "***** FAIL: Checkpoint of $pid failed"
 		ps -efL |grep $TEST_CMD >> $SCRIPT_LOG
+		killall -9 `basename $TEST_CMD`
+		thaw
 		exit 1;
 	fi
 }
-- 
1.6.6.1
