From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [RFC v14-rc3][PATCH 33/36] Support for share memory address spaces
Date: Tue,  7 Apr 2009 08:27:41 -0400
Message-ID: <1239107264-21775-34-git-send-email-orenl@cs.columbia.edu>
References: <1239107264-21775-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1239107264-21775-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

The task address space (task->mm) may be shared between processes if
CLONE_VM is used, and particularly among threads. Accordingly, treat
'task->mm' as a shared object: during checkpoint check against the
objhash and only dump the contents if seen for the first time. During
restart, likewise, only restore if it's a new instance, otherwise use
the one already registered in the objhash.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/ckpt_mem.c      |   36 +++++++++++++++++++++++-------------
 checkpoint/objhash.c       |    6 ++++++
 checkpoint/rstr_mem.c      |   31 +++++++++++++++++++++++++++----
 include/linux/checkpoint.h |    1 +
 4 files changed, 57 insertions(+), 17 deletions(-)

diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
index 92a3edc..0df3cda 100644
--- a/checkpoint/ckpt_mem.c
+++ b/checkpoint/ckpt_mem.c
@@ -733,22 +733,29 @@ int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
 	struct cr_hdr_mm *hh;
 	struct mm_struct *mm;
 	struct vm_area_struct *vma;
-	int objref, ret;
+	int objref, new;
+	int ret;
+
+	mm = get_task_mm(t);
+
+	new = cr_obj_add_ptr(ctx, mm, &objref, CR_OBJ_MM, 0);
+	if (new < 0) {
+		ret = new;
+		goto mmput;
+	}
 
 	h.type = CR_HDR_MM;
 	h.len = sizeof(*hh);
 
+	ret = -ENOMEM;
 	hh = cr_hbuf_get(ctx, sizeof(*hh));
 	if (!hh)
-		return -ENOMEM;
+		goto mmput;
 
-	mm = get_task_mm(t);
+	down_read(&mm->mmap_sem);
 
-	objref = 0;	/* will be meaningful with multiple processes */
 	hh->objref = objref;
 
-	down_read(&mm->mmap_sem);
-
 	hh->start_code = mm->start_code;
 	hh->end_code = mm->end_code;
 	hh->start_data = mm->start_data;
@@ -770,17 +777,20 @@ int cr_write_mm(struct cr_ctx *ctx, struct task_struct *t)
 	if (ret < 0)
 		goto out;
 
-	/* write the vma's */
-	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		ret = cr_write_vma(ctx, vma);
-		if (ret < 0)
-			goto out;
-	}
+	if (new) {
+		/* write the vma's */
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			ret = cr_write_vma(ctx, vma);
+			if (ret < 0)
+				goto out;
+		}
 
-	ret = cr_write_mm_context(ctx, mm);
+		ret = cr_write_mm_context(ctx, mm);
+	}
 
  out:
 	up_read(&mm->mmap_sem);
+ mmput:
 	mmput(mm);
 	return ret;
 }
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 25916c1..6584579 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -38,6 +38,9 @@ static void cr_obj_ref_drop(struct cr_objref *obj)
 	case CR_OBJ_INODE:
 		iput((struct inode *) obj->ptr);
 		break;
+	case CR_OBJ_MM:
+		mmput((struct mm_struct *) obj->ptr);
+		break;
 	default:
 		BUG();
 	}
@@ -55,6 +58,9 @@ static int cr_obj_ref_grab(struct cr_objref *obj)
 		if (!igrab((struct inode *) obj->ptr))
 			ret = -EBADF;
 		break;
+	case CR_OBJ_MM:
+		atomic_inc(&((struct mm_struct *) obj->ptr)->mm_users);
+		break;
 	default:
 		BUG();
 	}
diff --git a/checkpoint/rstr_mem.c b/checkpoint/rstr_mem.c
index da3eb0e..7e73129 100644
--- a/checkpoint/rstr_mem.c
+++ b/checkpoint/rstr_mem.c
@@ -505,16 +505,39 @@ int cr_read_mm(struct cr_ctx *ctx)
 	if (ret < 0)
 		goto out;
 
-	cr_debug("map_count %d\n", hh->map_count);
+	cr_debug("map_count %d objref %d\n", hh->map_count, hh->objref);
 
-	/* XXX need more sanity checks */
+	/* FIX need more sanity checks */
 
 	ret = -EINVAL;
-	if ((hh->start_code > hh->end_code) ||
-	    (hh->start_data > hh->end_data))
+	if (hh->objref < 0)
 		goto out;
+	if ((hh->start_code > hh->end_code) || (hh->start_data > hh->end_data))
+		goto out;
+
+	/* if the mm's objref is in the objhash, use that instance */
+	mm = cr_obj_get_by_ref(ctx, hh->objref, CR_OBJ_MM);
+	if (IS_ERR(mm)) {
+		ret = PTR_ERR(mm);
+		goto out;
+	}
 
+	if (mm) {
+		if (mm != current->mm) {
+			ret = exec_mmap(mm);
+			if (ret < 0)
+				goto out;
+			atomic_inc(&mm->mm_users);
+		}
+		ret = 0;
+		goto out;
+	}
+
+	/* otherwise, add our mm to the objhash for future generations */
 	mm = current->mm;
+	ret = cr_obj_add_ref(ctx, mm, hh->objref, CR_OBJ_MM, 0);
+	if (ret < 0)
+		goto out;
 
 	/* point of no return -- destruct current mm */
 	down_write(&mm->mmap_sem);
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 043535c..1bfe284 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -77,6 +77,7 @@ extern void cr_ctx_put(struct cr_ctx *ctx);
 enum {
 	CR_OBJ_FILE = 1,
 	CR_OBJ_INODE,
+	CR_OBJ_MM,
 	CR_OBJ_MAX
 };
 
-- 
1.5.4.3
