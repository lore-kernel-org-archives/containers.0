From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 7/9] cr_tests: fs: Add random tree test
Date: Fri, 19 Feb 2010 18:18:55 -0800
Message-ID: <275a3dfd54a441b21e338bd4856c61be214ae12a.1266632319.git.matthltc@us.ibm.com>
References: <1266632337-13792-1-git-send-email-matthltc@us.ibm.com>
	<72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc@us.ibm.com>
	<a5516d2e94b044e946ac039172a3d9cab0df0c1f.1266632319.git.matthltc@us.ibm.com>
	<7f04acbefe832b0bfaa832222da150c33af76ca8.1266632319.git.matthltc@us.ibm.com>
	<0efaca297a696880440a982210325dc7c473b13d.1266632319.git.matthltc@us.ibm.com>
	<dfc5e84b2c8940b07be485b8df1e530e4128e253.1266632319.git.matthltc@us.ibm.com>
	<970e1b8ed6c9322e3c069bae404b6d8cd17a7a94.1266632319.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <970e1b8ed6c9322e3c069bae404b6d8cd17a7a94.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <72d007906376ee6de7e97ed02f3d7aa814b8017b.1266632319.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

This test creates a random tree of files and directories, opens them all,
unlinks them, "overwrites" their entries in the filesystem, and then awaits
checkpoint. Afterwards it checks the directories and file contents.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 fs/tree.sh |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)
 create mode 100755 fs/tree.sh

diff --git a/fs/tree.sh b/fs/tree.sh
new file mode 100755
index 0000000..1323594
--- /dev/null
+++ b/fs/tree.sh
@@ -0,0 +1,16 @@
+#!/bin/bash
+
+set -e
+# Generate a random tree and check its contents
+./rand_tree.py -r ./tree -d 4 -f 10 && trap 'rm -rf ./tree' EXIT
+./check_tree.py -r ./tree -c original
+
+# Fill its contents with new dummy values
+./fill_tree.py -r ./tree -c dummy
+./check_tree.py -r ./tree -c dummy
+
+# Fill its contents with "original" values
+./fill_tree.py -r ./tree -c original
+./hold_unlinked_tree.py -r ./tree -n && \
+# Expect "new" contents
+./check_tree.py -r ./tree -c new
-- 
1.6.3.3
