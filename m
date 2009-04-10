From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 13/30] cr: i386 LDT support
Date: Fri, 10 Apr 2009 06:36:25 +0400
Message-ID: <20090410023625.GN27788__13712.4998881065$1239331803$gmane$org@x200.localdomain>
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
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

FIXME: LDT actual restoration

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

 kernel/cr/cr-x86_32.c |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

--- a/kernel/cr/cr-x86_32.c
+++ b/kernel/cr/cr-x86_32.c
@@ -1,6 +1,7 @@
 /* Copyright (C) 2000-2009 Parallels Holdings, Ltd. */
 #include <linux/sched.h>
 #include <asm/i387.h>
+#include <asm/ldt.h>
 
 #include <linux/cr.h>
 #include "cr.h"
@@ -226,21 +227,25 @@ int cr_arch_restore_task_struct(struct task_struct *tsk, struct cr_image_task_st
 
 int cr_arch_check_mm_struct(struct mm_struct *mm)
 {
-	mutex_lock(&mm->context.lock);
-	if (mm->context.ldt || mm->context.size != 0) {
-		mutex_unlock(&mm->context.lock);
-		WARN_ON(1);
-		return -EINVAL;
-	}
 	return 0;
 }
 
 unsigned int cr_arch_len_mm_struct(struct mm_struct *mm)
 {
-	return 0;
+	unsigned int len;
+
+	mutex_lock(&mm->context.lock);
+	len = mm->context.size * LDT_ENTRY_SIZE;
+	mutex_unlock(&mm->context.lock);
+	return len;
 }
 
 int cr_arch_dump_mm_struct(struct cr_context *ctx, struct mm_struct *mm)
 {
-	return 0;
+	int rv;
+
+	mutex_lock(&mm->context.lock);
+	rv = cr_write(ctx, mm->context.ldt, mm->context.size * LDT_ENTRY_SIZE);
+	mutex_unlock(&mm->context.lock);
+	return rv;
 }
