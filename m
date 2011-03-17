From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 02/18] user-cr: extract headers: Defer to unistd.h
Date: Thu, 17 Mar 2011 10:27:34 -0700
Message-ID: <1525d5365ced342871277f7a94a42bcd960c04a9.1300382276.git.matthltc@us.ibm.com>
References: <1300382870-28486-1-git-send-email-matthltc@us.ibm.com>
	<beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <beb6aa37e82e8ca96766438cae2c93c7168eedaa.1300382276.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Defer to unistd.h for definitions of basic types and values. In the
future, when the __NR_checkpoint and __NR_restart values are defined
via unistd.h we should use those rather than define our own. This
also requires checking for those definitions before error'ing out.

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 scripts/extract-headers.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/scripts/extract-headers.sh b/scripts/extract-headers.sh
index 19f63b4..c4a596e 100755
--- a/scripts/extract-headers.sh
+++ b/scripts/extract-headers.sh
@@ -126,6 +126,7 @@ cat - > "${OUTPUT_INCLUDES}/linux/checkpoint_hdr.h" <<-EOFOO
 #ifndef _CHECKPOINT_CKPT_HDR_H_
 #define _CHECKPOINT_CKPT_HDR_H_
 
+#include <unistd.h>
 EOFOO
 
 do_cpp "${KERNELSRC}/include/linux/checkpoint_hdr.h" "_CHECKPOINT_CKPT_HDR_H_" \
@@ -173,6 +174,7 @@ cat - <<-EOFOE
 #ifndef _LINUX_CHECKPOINT_H_
 #define _LINUX_CHECKPOINT_H_
 
+#include <unistd.h>
 EOFOE
 
 do_cpp "${KERNELSRC}/include/linux/checkpoint.h" "_LINUX_CHECKPOINT_H_"
@@ -196,8 +198,12 @@ done
 
 cat - <<-EOFOFOE
 #else
+
+#if !defined(__NR_checkpoint) || !defined(__NR_restart)
 #error "Architecture does not have definitons for __NR_(checkpoint|restart)"
 #endif
+
+#endif
 #endif /* _LINUX_CHECKPOINT_H_ */
 EOFOFOE
 
-- 
1.6.3.3
