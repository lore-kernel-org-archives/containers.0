From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 7/9] exec_path 7/9: switch cell SPU thing to ->exec_path
Date: Thu, 4 Jun 2009 03:07:12 +0400
Message-ID: <20090603230712.GH853__32805.7779618122$1244070472$gmane$org@x200.localdomain>
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
 arch/powerpc/oprofile/cell/spu_task_sync.c |   28 ++++++++++++----------------
 1 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/arch/powerpc/oprofile/cell/spu_task_sync.c b/arch/powerpc/oprofile/cell/spu_task_sync.c
index 6b793ae..fe17a0a 100644
--- a/arch/powerpc/oprofile/cell/spu_task_sync.c
+++ b/arch/powerpc/oprofile/cell/spu_task_sync.c
@@ -26,6 +26,7 @@
 #include <linux/notifier.h>
 #include <linux/numa.h>
 #include <linux/oprofile.h>
+#include <linux/path.h>
 #include <linux/spinlock.h>
 #include "pr_util.h"
 
@@ -303,9 +304,8 @@ static inline unsigned long fast_get_dcookie(struct path *path)
 	return cookie;
 }
 
-/* Look up the dcookie for the task's first VM_EXECUTABLE mapping,
- * which corresponds loosely to "application name". Also, determine
- * the offset for the SPU ELF object.  If computed offset is
+/*
+ * Determine the offset for the SPU ELF object.  If computed offset is
  * non-zero, it implies an embedded SPU object; otherwise, it's a
  * separate SPU binary, in which case we retrieve it's dcookie.
  * For the embedded case, we must determine if SPU ELF is embedded
@@ -320,26 +320,22 @@ get_exec_dcookie_and_offset(struct spu *spu, unsigned int *offsetp,
 {
 	unsigned long app_cookie = 0;
 	unsigned int my_offset = 0;
-	struct file *app = NULL;
 	struct vm_area_struct *vma;
+	struct task_struct *tsk = spu->tsk;
 	struct mm_struct *mm = spu->mm;
+	struct path exec_path;
 
 	if (!mm)
 		goto out;
 
-	down_read(&mm->mmap_sem);
-
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		if (!vma->vm_file)
-			continue;
-		if (!(vma->vm_flags & VM_EXECUTABLE))
-			continue;
-		app_cookie = fast_get_dcookie(&vma->vm_file->f_path);
-		pr_debug("got dcookie for %s\n",
-			 vma->vm_file->f_dentry->d_name.name);
-		app = vma->vm_file;
-		break;
+	get_task_exec_path(tsk, &exec_path);
+	if (exec_path.mnt && exec_path.dentry) {
+		app_cookie = fast_get_dcookie(&exec_path);
+		pr_debug("got dcookie for %s\n", exec_path.dentry->d_name.name);
 	}
+	path_put(&exec_path);
+
+	down_read(&mm->mmap_sem);
 
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->vm_start > spu_ref || vma->vm_end <= spu_ref)
