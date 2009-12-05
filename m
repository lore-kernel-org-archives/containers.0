From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] cr_tests: fix syscall numbers for powerpc
Date: Fri,  4 Dec 2009 21:22:13 -0600
Message-ID: <1259983334-25854-1-git-send-email-ntl@pobox.com>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Update to the values for ckpt-v19-rc2, and add eclone.
---
 cr.h |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/cr.h b/cr.h
index a58c2e4..8acd750 100644
--- a/cr.h
+++ b/cr.h
@@ -71,12 +71,16 @@
 /* parisc unsupported. */
 #if __powerpc__
 
+#ifndef __NR_eclone
+#define __NR_eclone 323
+#endif
+
 #ifndef __NR_checkpoint
-#define __NR_checkpoint 323
+#define __NR_checkpoint 324
 #endif
 
 #ifndef __NR_restart
-#define __NR_restart 324
+#define __NR_restart 325
 #endif
 
 #elif __s390x__
-- 
1.6.0.6
