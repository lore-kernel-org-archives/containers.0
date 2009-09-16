From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/9] futex.h: fix compat builds
Date: Wed, 16 Sep 2009 03:56:52 -0500
Message-ID: <1253091418-14807-4-git-send-email-ntl@pobox.com>
References: <1253091418-14807-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253091418-14807-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

With any build where CONFIG_COMPAT=y:

checkpoint/process.c: In function 'save_task_robust_futex_list':
checkpoint/process.c:37: error: implicit declaration of function 'ptr_to_compat'
checkpoint/process.c:38: error: dereferencing pointer to incomplete type
checkpoint/process.c: In function 'restore_task_robust_futex_list':
checkpoint/process.c:54: error: implicit declaration of function 'compat_ptr'
checkpoint/process.c:54: warning: assignment makes pointer from integer without a cast
checkpoint/process.c:55: error: implicit declaration of function 'do_compat_set_robust_list'

ptr_to_compat et al need compat.h; however, futex.h is exported while
compat.h is not.  So the include is guarded by #ifdef __KERNEL__.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/futex.h |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/linux/futex.h b/include/linux/futex.h
index 2e126a9..3fb9f33 100644
--- a/include/linux/futex.h
+++ b/include/linux/futex.h
@@ -4,6 +4,10 @@
 #include <linux/compiler.h>
 #include <linux/types.h>
 
+#ifdef __KERNEL__
+#include <linux/compat.h>
+#endif
+
 struct inode;
 struct mm_struct;
 struct task_struct;
-- 
1.6.0.6
