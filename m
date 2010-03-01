From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: enclose arch_setup_additional_pages() call between
	#ifdefs
Date: Mon,  1 Mar 2010 01:28:09 -0500
Message-ID: <1267424889-31388-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

Invocation of arch_setup_additional_pages() should occur only for
those architectures that provide it:

#ifdef ARCH_HAS_SETUP_ADDITIONAL_PAGES
...
#endif

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 mm/mmap.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 6aa606a..6aadf2e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2394,17 +2394,28 @@ int special_mapping_restore(struct ckpt_ctx *ctx,
 			    struct mm_struct *mm,
 			    struct ckpt_hdr_vma *h)
 {
+	int ret = 0;
+
 	/*
 	 * FIX:
 	 * Currently, we only handle VDSO/vsyscall special handling.
 	 * Even that, is very basic - call arch_setup_additional_pages
 	 * requiring the same mapping (start address) as before.
 	 */
+
+	if (h->vma_type != CKPT_VMA_VDSO)
+		return -EINVAL;
+
+#ifdef ARCH_HAS_SETUP_ADDITIONAL_PAGES
 #if defined(CONFIG_X86_64) && defined(CONFIG_COMPAT)
 	if (test_thread_flag(TIF_IA32))
-		return syscall32_setup_pages(NULL, h->vm_start, 0);
+		ret = syscall32_setup_pages(NULL, h->vm_start, 0);
+	else
+#endif
+	ret = arch_setup_additional_pages(NULL, h->vm_start, 0);
 #endif
-	return arch_setup_additional_pages(NULL, h->vm_start, 0);
+
+	return ret;
 }
 #else /* !CONFIG_CHECKPOINT */
 #define special_mapping_checkpoint NULL
-- 
1.6.3.3
