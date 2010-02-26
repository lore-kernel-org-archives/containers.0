From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 05/12] Move mm checkpoint ops to mm/mmap.c
Date: Fri, 26 Feb 2010 00:45:06 -0800
Message-ID: <4f4de129024a206dad6ef5484d3eed3b8426d16d.1267173752.git.matthltc@us.ibm.com>
References: <1267173913-28084-1-git-send-email-matthltc@us.ibm.com>
	<3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc@us.ibm.com>
	<5d3d0d1f5d294ccd13453a19c15828faa789bb0f.1267173752.git.matthltc@us.ibm.com>
	<06ebd7532cbaeb5d2b13fc7b02db194840098b6d.1267173752.git.matthltc@us.ibm.com>
	<e3af5631e13c748bb0cc16fb9281b582f4d8d079.1267173752.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <e3af5631e13c748bb0cc16fb9281b582f4d8d079.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
In-Reply-To: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
References: <3badfe4be5db05524ac303b54186a8e43970c06c.1267173752.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
List-Id: containers.vger.kernel.org

Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/objhash.c |   27 ---------------------------
 mm/mmap.c            |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 27 deletions(-)

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index e2c2ce3..ce89066 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -89,22 +89,6 @@ static int obj_file_users(void *ptr)
 	return atomic_long_read(&((struct file *) ptr)->f_count);
 }
 
-static int obj_mm_grab(void *ptr)
-{
-	atomic_inc(&((struct mm_struct *) ptr)->mm_users);
-	return 0;
-}
-
-static void obj_mm_drop(void *ptr, int lastref)
-{
-	mmput((struct mm_struct *) ptr);
-}
-
-static int obj_mm_users(void *ptr)
-{
-	return atomic_read(&((struct mm_struct *) ptr)->mm_users);
-}
-
 static int obj_fs_grab(void *ptr)
 {
 	get_fs_struct((struct fs_struct *) ptr);
@@ -352,16 +336,6 @@ static const struct ckpt_obj_ops ckpt_obj_file_ops = {
 	.checkpoint = checkpoint_file,
 	.restore = restore_file,
 };
-/* mm object */
-static const struct ckpt_obj_ops ckpt_obj_mm_ops = {
-	.obj_name = "MM",
-	.obj_type = CKPT_OBJ_MM,
-	.ref_drop = obj_mm_drop,
-	.ref_grab = obj_mm_grab,
-	.ref_users = obj_mm_users,
-	.checkpoint = checkpoint_mm,
-	.restore = restore_mm,
-};
 /* fs object */
 static const struct ckpt_obj_ops ckpt_obj_fs_ops = {
 	.obj_name = "FS",
@@ -506,7 +480,6 @@ static const struct ckpt_obj_ops *ckpt_obj_ops[] = {
 	[CKPT_OBJ_INODE] = &ckpt_obj_inode_ops,
 	[CKPT_OBJ_FILE_TABLE] = &ckpt_obj_files_struct_ops,
 	[CKPT_OBJ_FILE] = &ckpt_obj_file_ops,
-	[CKPT_OBJ_MM] = &ckpt_obj_mm_ops,
 	[CKPT_OBJ_FS] = &ckpt_obj_fs_ops,
 	[CKPT_OBJ_SIGHAND] = &ckpt_obj_sighand_ops,
 	[CKPT_OBJ_SIGNAL] = &ckpt_obj_signal_ops,
diff --git a/mm/mmap.c b/mm/mmap.c
index 6aa606a..b19a754 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2623,6 +2623,43 @@ void mm_drop_all_locks(struct mm_struct *mm)
 	mutex_unlock(&mm_all_locks_mutex);
 }
 
+#ifdef CONFIG_CHECKPOINT
+static int obj_mm_grab(void *ptr)
+{
+	atomic_inc(&((struct mm_struct *) ptr)->mm_users);
+	return 0;
+}
+
+static void obj_mm_drop(void *ptr, int lastref)
+{
+	mmput((struct mm_struct *) ptr);
+}
+
+static int obj_mm_users(void *ptr)
+{
+	return atomic_read(&((struct mm_struct *) ptr)->mm_users);
+}
+
+/* mm object */
+static const struct ckpt_obj_ops ckpt_obj_mm_ops = {
+	.obj_name = "MM",
+	.obj_type = CKPT_OBJ_MM,
+	.ref_drop = obj_mm_drop,
+	.ref_grab = obj_mm_grab,
+	.ref_users = obj_mm_users,
+	.checkpoint = checkpoint_mm,
+	.restore = restore_mm,
+};
+
+static inline void register_mmap_checkpoint(void)
+{
+	register_checkpoint_obj(&ckpt_obj_mm_ops);
+}
+#else
+static inline void register_mmap_checkpoint(void)
+{}
+#endif
+
 /*
  * initialise the VMA slab
  */
@@ -2630,6 +2667,7 @@ void __init mmap_init(void)
 {
 	int ret;
 
+	register_mmap_checkpoint();
 	ret = percpu_counter_init(&vm_committed_as, 0);
 	VM_BUG_ON(ret);
 }
-- 
1.6.3.3
