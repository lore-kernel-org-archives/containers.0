From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [PATCH 01/11] runtests.sh: Make test bit more generic
Date: Fri, 29 Jan 2010 12:28:42 -0800
Message-ID: <20100129202842.GA25490@us.ibm.com>
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
Date: Fri, 22 Jan 2010 11:53:01 -0800
Subject: [PATCH 01/11] runtests.sh: Make test bit more generic

Remove hardcoding of test case name so it is a bit more generic
(although other test cases can't use this script as is).

Signed-off-by: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
---
 fileio/runtests.sh |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)
 mode change 100755 => 100644 fileio/runtests.sh

diff --git a/fileio/runtests.sh b/fileio/runtests.sh
old mode 100755
new mode 100644
index 88dcebd..69758f0
--- a/fileio/runtests.sh
+++ b/fileio/runtests.sh
@@ -4,21 +4,25 @@
 
 source ../common.sh
 
-dir=`mktemp -p . -d -t cr_fileio_XXXXXXX` || (echo "mktemp failed"; exit 1)
+# test_case could be a command-line-arg, but since only one test
+# uses this for now, hard code.
+test_case="fileio1"
+
+dir=`mktemp -p . -d -t cr_${test_case}_XXXXXXX` || (echo "mktemp failed"; exit 1)
 echo "Using output dir $dir"
 
 SLOW_DOWN="$dir/slow-down-fileio"
-CKPT_FILE="$dir/ckpt-fileio1";
+CKPT_FILE="$dir/checkpoint-${test_case}"
 CKPT_READY="$dir/checkpoint.ready"
 COPY_DONE="$dir/copy.done"
 SRC_FILE="$dir/input-data.1";
 DEST_FILE="$dir/output-data.1";
 DEST_FILE_SNAP="$dir/output-data.1.snap";
-TEST_LOG="$dir/log.fileio1"
-TEST_LOG_SNAP="$dir/log.fileio1.snap"
+TEST_LOG="$dir/log.${test_case}"
+TEST_LOG_SNAP="$dir/log.${test_case}.snap"
 
 LOG_FILE="$dir/f1-loop.log"
-TEST_CMD="./fileio1"
+TEST_CMD="./$test_case"
 NS_EXEC="../ns_exec"
 
 # Make sure no stray TEST_CMD from another run is still going
-- 
1.6.0.4
