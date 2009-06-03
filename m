From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/9] exec_path 4/9: switch oprofile to ->exec_path
Date: Thu, 4 Jun 2009 03:06:13 +0400
Message-ID: <20090603230613.GE853@x200.localdomain>
References: <20090526113618.GJ28083@us.ibm.com>
	<20090526162415.fb9cefef.akpm@linux-foundation.org>
	<20090531215427.GA29534@x200.localdomain>
	<20090531151953.8f8b14b5.akpm@linux-foundation.org>
	<20090603230422.GB853@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090603230422.GB853-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/oprofile/buffer_sync.c |   30 ++++++++----------------------
 1 files changed, 8 insertions(+), 22 deletions(-)

diff --git a/drivers/oprofile/buffer_sync.c b/drivers/oprofile/buffer_sync.c
index 8574622..64c6d7d 100644
--- a/drivers/oprofile/buffer_sync.c
+++ b/drivers/oprofile/buffer_sync.c
@@ -25,6 +25,7 @@
 #include <linux/workqueue.h>
 #include <linux/notifier.h>
 #include <linux/dcookies.h>
+#include <linux/path.h>
 #include <linux/profile.h>
 #include <linux/module.h>
 #include <linux/fs.h>
@@ -213,30 +214,15 @@ static inline unsigned long fast_get_dcookie(struct path *path)
 	return cookie;
 }
 
-
-/* Look up the dcookie for the task's first VM_EXECUTABLE mapping,
- * which corresponds loosely to "application name". This is
- * not strictly necessary but allows oprofile to associate
- * shared-library samples with particular applications
- */
-static unsigned long get_exec_dcookie(struct mm_struct *mm)
+static unsigned long get_exec_dcookie(struct task_struct *tsk)
 {
 	unsigned long cookie = NO_COOKIE;
-	struct vm_area_struct *vma;
+	struct path exec_path;
 
-	if (!mm)
-		goto out;
-
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		if (!vma->vm_file)
-			continue;
-		if (!(vma->vm_flags & VM_EXECUTABLE))
-			continue;
-		cookie = fast_get_dcookie(&vma->vm_file->f_path);
-		break;
-	}
-
-out:
+	get_task_exec_path(tsk, &exec_path);
+	if (exec_path.mnt && exec_path.dentry)
+		cookie = fast_get_dcookie(&exec_path);
+	path_put(&exec_path);
 	return cookie;
 }
 
@@ -543,7 +529,7 @@ void sync_buffer(int cpu)
 				release_mm(oldmm);
 				mm = take_tasks_mm(new);
 				if (mm != oldmm)
-					cookie = get_exec_dcookie(mm);
+					cookie = get_exec_dcookie(new);
 				add_user_ctx_switch(new, cookie);
 			}
 			if (op_cpu_buffer_get_size(&entry))
