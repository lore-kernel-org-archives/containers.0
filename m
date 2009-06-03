From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/9] exec_path 2/9: switch audit to ->exec_path
Date: Thu, 4 Jun 2009 03:05:20 +0400
Message-ID: <20090603230520.GC853__28880.5501223125$1244070360$gmane$org@x200.localdomain>
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
 kernel/auditsc.c |   23 +++++++----------------
 1 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index 7d6ac7c..76829b6 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -53,6 +53,7 @@
 #include <linux/socket.h>
 #include <linux/mqueue.h>
 #include <linux/audit.h>
+#include <linux/path.h>
 #include <linux/personality.h>
 #include <linux/time.h>
 #include <linux/netlink.h>
@@ -949,8 +950,7 @@ EXPORT_SYMBOL(audit_log_task_context);
 static void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk)
 {
 	char name[sizeof(tsk->comm)];
-	struct mm_struct *mm = tsk->mm;
-	struct vm_area_struct *vma;
+	struct path exec_path;
 
 	/* tsk == current */
 
@@ -958,20 +958,11 @@ static void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk
 	audit_log_format(ab, " comm=");
 	audit_log_untrustedstring(ab, name);
 
-	if (mm) {
-		down_read(&mm->mmap_sem);
-		vma = mm->mmap;
-		while (vma) {
-			if ((vma->vm_flags & VM_EXECUTABLE) &&
-			    vma->vm_file) {
-				audit_log_d_path(ab, "exe=",
-						 &vma->vm_file->f_path);
-				break;
-			}
-			vma = vma->vm_next;
-		}
-		up_read(&mm->mmap_sem);
-	}
+	get_task_exec_path(tsk, &exec_path);
+	if (exec_path.mnt && exec_path.dentry)
+		audit_log_d_path(ab, "exe=", &exec_path);
+	path_put(&exec_path);
+
 	audit_log_task_context(ab);
 }
