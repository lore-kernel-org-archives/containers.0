From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] Fix compile failures when CONFIG_CHECKPOINT=n
Date: Thu, 30 Apr 2009 16:57:07 -0700
Message-ID: <20090430235707.GI11734@us.ibm.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

    Fix compile failures when CONFIG_CHECKPOINT=n
    
    These structure members are only defined if CONFIG_CHECKPOINT=y.
    Ensure that we can always build by protecting them with #ifdef
    CONFIG_CHECKPOINT. Would be nice to avoid the #ifdefferry but I
    don't see a better way to do it...
    
    Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---

diff --git a/ipc/shm.c b/ipc/shm.c
index 70e0651..da27d92 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -376,7 +376,7 @@ int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 	return ret;
 }
 #else
-define ipcshm_checkpoint NULL
+#define ipcshm_checkpoint NULL
 #endif
 
 static const struct file_operations shm_file_operations = {
@@ -394,7 +394,9 @@ static struct vm_operations_struct shm_vm_ops = {
 	.set_policy = shm_set_policy,
 	.get_policy = shm_get_policy,
 #endif
+#ifdef CONFIG_CHECKPOINT
 	.checkpoint = ipcshm_checkpoint,
+#endif
 };
 
 /**
diff --git a/mm/filemap.c b/mm/filemap.c
index af83da7..93aa64b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1716,7 +1716,9 @@ int filemap_restore(struct ckpt_ctx *ctx,
 
 struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+#ifdef CONFIG_CHECKPOINT
 	.checkpoint	= filemap_checkpoint,
+#endif /* CONFIG_CHECKPOINT */
 };
 
 /* This is used for a general mmap of a disk file */
diff --git a/mm/mmap.c b/mm/mmap.c
index 555a6a3..ef7c9e0 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2322,7 +2322,9 @@ int special_mapping_restore(struct ckpt_ctx *ctx,
 static struct vm_operations_struct special_mapping_vmops = {
 	.close = special_mapping_close,
 	.fault = special_mapping_fault,
+#ifdef CONFIG_CHECKPOINT
 	.checkpoint = special_mapping_checkpoint,
+#endif
 };
 
 /*
