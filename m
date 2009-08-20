From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 08/11] cr_tests: Cleanup more stuff after futex/run.sh runs.
Date: Wed, 19 Aug 2009 21:58:11 -0700
Message-ID: <4203cdac2e7c50452a1ebf23509ff65fc3767670.1250744013.git.matthltc@us.ibm.com>
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

In this case, wait for any running tasks to complete before going onto
the next iteration of the test loop and remove the checkpoint-ready and
checkpoint-done files after the loop.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 futex/run.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/futex/run.sh b/futex/run.sh
index 5587520..0e0b2eb 100755
--- a/futex/run.sh
+++ b/futex/run.sh
@@ -100,10 +100,13 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 	echo PASS
 	trap '' ERR EXIT
 	CURTEST=$((CURTEST+1))
+
+	# Wait for restarted tasks to complete.
+	wait
 done
 trap '' ERR EXIT
 
-#rm -f ./checkpoint-*
+rm -f ./checkpoint-{ready,done}
 
 # rmdir /cg/1
 # umount /cg
-- 
1.5.6.3
