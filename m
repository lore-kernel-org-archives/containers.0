From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/8] cr_tests: crcounter: Don't report bogus waits
Date: Tue,  9 Mar 2010 14:48:13 -0800
Message-ID: <0c9ea18c7ffeb8688b31d01ce5f39a5a8c8a431f.1268174893.git.matthltc@us.ibm.com>
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
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

This outputs a bunch of garbage but according to the comments don't
absolutely need this wait anyway. So redirect stderr for the bash
wait to /dev/null.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 counterloop/cloop_serial.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/counterloop/cloop_serial.sh b/counterloop/cloop_serial.sh
index cc94db4..dcd11d3 100644
--- a/counterloop/cloop_serial.sh
+++ b/counterloop/cloop_serial.sh
@@ -52,7 +52,7 @@ for cnt in `seq 1 $NUMLOOPS`; do
 	echo checkpoint returned $?
 	kill -9 $pid
 	thaw
-	wait $pid
+	wait $pid 2> /dev/null
 	wait_on_crcounter
 	echo BAD > $dir/counter_out
 	$RESTART --pids < $dir/o.$cnt &
-- 
1.6.3.3
