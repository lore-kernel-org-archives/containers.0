From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 6/6][cr-tests]: eclone/runtests.sh: Wrapper script for
	eclone tests
Date: Tue, 2 Feb 2010 11:43:05 -0800
Message-ID: <20100202194305.GA10030@us.ibm.com>
References: <20100202193508.GA8542@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100202193508.GA8542-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Date: Tue, 2 Feb 2010 11:21:07 -0800
Subject: [PATCH 6/6][cr-tests]: eclone/runtests.sh: Wrapper script for eclone tests

A simple wrapper script to run all eclone tests in this directory.

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 eclone/runtests.sh |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)
 create mode 100755 eclone/runtests.sh

diff --git a/eclone/runtests.sh b/eclone/runtests.sh
new file mode 100755
index 0000000..de3f586
--- /dev/null
+++ b/eclone/runtests.sh
@@ -0,0 +1,23 @@
+#!/bin/bash
+
+TEST_LOG=`mktemp -p . runtests-XXXXXXX`.log
+
+echo Logfile: $TEST_LOG
+
+> $TEST_LOG
+
+TESTS="eclone-1 eclone-2 eclone-3 eclone-4 eclone-5"
+#TESTS="eclone-5"
+
+for t in $TESTS
+do
+	echo "===== Test: $t" >> $TEST_LOG
+	./$t >> $TEST_LOG 2>&1
+	if [ $? -eq 0 ]; then
+		echo "Test '$t' PASSED" >> $TEST_LOG
+	else
+		echo "Test '$t' FAILED" >> $TEST_LOG
+	fi
+done
+
+cat $TEST_LOG
-- 
1.6.6.1
