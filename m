From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 05/18] user-cr: Fixup missing unshare definition
Date: Thu, 17 Mar 2011 10:27:37 -0700
Message-ID: <c9471f79da9f1ddbbbc9d8f565951c2bc5fd5ee7.1300382276.git.matthltc@us.ibm.com>
References: <1300382870-28486-1-git-send-email-matthltc@us.ibm.com>
	<beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc@us.ibm.com>
	<1525d5365ced342871277f7a94a42bcd960c04a9.1300382276.git.matthltc@us.ibm.com>
	<ccf68c276e54e7cb9dce0df9b8fec8391dd0e349.1300382276.git.matthltc@us.ibm.com>
	<143894c882d1339322b36ea459531a7debec7f29.1300382276.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <143894c882d1339322b36ea459531a7debec7f29.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

New libcs may have unshare but old ones do not. Make a "weak" definition
which will defer to libc.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 nsexec.c            |    5 +++++
 test/ipcshm_multi.c |    6 ++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/nsexec.c b/nsexec.c
index 1cf9c97..a9ed016 100644
--- a/nsexec.c
+++ b/nsexec.c
@@ -27,6 +27,11 @@ extern pid_t getsid(pid_t pid);
 
 static const char* procname;
 
+int  __attribute__((weak)) unshare(int flags)
+{
+	return syscall(__NR_unshare, flags);
+}
+
 static void usage(const char *name)
 {
 	printf("usage: %s [-h] [-c] [-mnuUip] [-P <pid-file>]"
diff --git a/test/ipcshm_multi.c b/test/ipcshm_multi.c
index ff3712f..da37feb 100644
--- a/test/ipcshm_multi.c
+++ b/test/ipcshm_multi.c
@@ -13,6 +13,12 @@
 /* For CLONE_NEWIPC */
 #include "../clone.h"
 
+int  __attribute__((weak)) unshare(int flags)
+{
+       return syscall(__NR_unshare, flags);
+}
+
+
 #define OUTFILE  "/tmp/cr-test.out"
 #define SEG_SIZE (20 * 4096)
 #define DELAY 20
-- 
1.6.3.3
