From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] cr_tests: futex: Fix mktree usage in run.sh
Date: Mon, 13 Jul 2009 06:24:32 -0700
Message-ID: <20090713132432.GF5213@count0.beaverton.ibm.com>
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
To: Serge Hallyn <serue-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

 Restore the pids since robust and pi futexes rely on the pids to
 determine which task has the futex. Also use --copy-status to ensure
 that the exit code from the restarted processes propagate to run.sh

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
I believe this is the most important fix to get robust futex tests
running properly via run.sh. I've actually got a whole series that
tweaks run.sh but most of those are only beneficial if the tests fail
at various stages.

 futex/run.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/futex/run.sh b/futex/run.sh
index 1ed23ad..d66e64e 100755
--- a/futex/run.sh
+++ b/futex/run.sh
@@ -61,7 +61,7 @@ for T in ${TESTS[@]} ; do
 	fi
 
 	# now try restarting
-	$MKTREE < checkpoint-$T
+	$MKTREE -p --copy-status < checkpoint-$T
 	retval=$?
 	echo "Restart of test ${T} done, returned $retval"
 	if [ $retval -ne 0 ]; then
-- 
1.5.6.3
