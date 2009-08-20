From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 05/11] cr_tests: Fixup run.sh to use the same variable
	expansion convention.
Date: Wed, 19 Aug 2009 21:58:08 -0700
Message-ID: <1c1379a67c3c60a79d04c2b82ef44289ce446d82.1250744013.git.matthltc@us.ibm.com>
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
 futex/run.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/futex/run.sh b/futex/run.sh
index 305f9d1..e54c228 100755
--- a/futex/run.sh
+++ b/futex/run.sh
@@ -51,7 +51,7 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 		sleep 1
 	done
 	freeze
-	ckpt $TEST_PID > checkpoint-$T
+	ckpt ${TEST_PID} > checkpoint-${T}
 	thaw
 	touch "./checkpoint-done"
 	wait ${TEST_PID}
@@ -69,7 +69,7 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 	fi
 
 	# now try restarting
-	$MKTREE -p --copy-status < checkpoint-$T
+	${MKTREE} -p --copy-status < checkpoint-${T}
 	retval=$?
 	echo "Restart of test ${T} done, returned $retval"
 	if [ $retval -ne 0 ]; then
-- 
1.5.6.3
