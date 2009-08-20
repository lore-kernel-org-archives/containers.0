From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 09/11] cr_tests: Checkpoint/restart the logs produced by
	futex/run.sh
Date: Wed, 19 Aug 2009 21:58:12 -0700
Message-ID: <d443a880b17c324b497d0923dfe478d700572fac.1250744013.git.matthltc@us.ibm.com>
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

Checkpoint/restart the logs produced by futex/run.sh, keeping copies of
the originals for later comparison between resumed and restarted runs.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
---
 futex/run.sh |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/futex/run.sh b/futex/run.sh
index 0e0b2eb..ae80111 100755
--- a/futex/run.sh
+++ b/futex/run.sh
@@ -67,6 +67,8 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 	done
 	freeze
 	trap 'thaw; do_err; break' ERR EXIT
+	sync
+	cp log.${T} log.${T}.pre-ckpt
 	err_msg="FAIL"
 	ckpt ${TEST_PID} > checkpoint-${T}
 	err_msg="BROK"
@@ -86,6 +88,8 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 	echo PASS
 
 	# now try restarting
+	mv log.${T} log.${T}.post-ckpt
+	cp log.${T}.pre-ckpt log.${T}
 	err_msg="FAIL"
 	# We need to pass -p to mktree since futexes often store the
 	# pid of the task that owns the futex in the futex, even in
@@ -94,6 +98,9 @@ while [ $CURTEST -lt $NUMTESTS ]; do
 	${MKTREE} -p --copy-status < checkpoint-${T}
 	retval=$?
 	err_msg="BROK"
+	mv log.${T} log.${T}.post-rstr
+	# Now we can do something _like_:
+	#         diff log.${T}.post-ckpt log.${T}.post-rstr
 	echo "Restart of test ${T} done, returned $retval"
 	err_msg="FAIL"
 	[ $retval -eq 0 ];
-- 
1.5.6.3
