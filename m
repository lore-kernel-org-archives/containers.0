From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/9] exec_path 3/9: switch TOMOYO to ->exec_path
Date: Thu, 4 Jun 2009 03:05:50 +0400
Message-ID: <20090603230550.GD853@x200.localdomain>
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
 security/tomoyo/common.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/security/tomoyo/common.c b/security/tomoyo/common.c
index ddfb9cc..d26deea 100644
--- a/security/tomoyo/common.c
+++ b/security/tomoyo/common.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/uaccess.h>
+#include <linux/path.h>
 #include <linux/security.h>
 #include <linux/hardirq.h>
 #include "realpath.h"
@@ -700,20 +701,13 @@ bool tomoyo_io_printf(struct tomoyo_io_buffer *head, const char *fmt, ...)
  */
 static const char *tomoyo_get_exe(void)
 {
-	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *vma;
+	struct path exec_path;
 	const char *cp = NULL;
 
-	if (!mm)
-		return NULL;
-	down_read(&mm->mmap_sem);
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		if ((vma->vm_flags & VM_EXECUTABLE) && vma->vm_file) {
-			cp = tomoyo_realpath_from_path(&vma->vm_file->f_path);
-			break;
-		}
-	}
-	up_read(&mm->mmap_sem);
+	get_task_exec_path(current, &exec_path);
+	if (exec_path.mnt && exec_path.dentry)
+		cp = tomoyo_realpath_from_path(&exec_path);
+	path_put(&exec_path);
 	return cp;
 }
