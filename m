From: Serge Hallyn <serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 06/17] ckpt_write_err update checkpoint/memory.c
Date: Tue, 27 Oct 2009 17:46:16 -0500
Message-ID: <1256683587-23961-7-git-send-email-serge@us.ibm.com>
References: <1256683587-23961-1-git-send-email-serge@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256683587-23961-1-git-send-email-serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/memory.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index 656614c..c94a85e 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -679,7 +679,7 @@ static int checkpoint_vmas(struct ckpt_ctx *ctx, struct mm_struct *mm)
 			 vma->vm_start, vma->vm_end, vma->vm_flags);
 
 		if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
-			ckpt_write_err(ctx, "TE", "vma: bad flags (%#lx)\n",
+			ckpt_write_err(ctx, "%(T)%(E)vma: bad flags (%#lx)\n",
 				       -ENOSYS, vma->vm_flags);
 			ret = -ENOSYS;
 			break;
@@ -692,7 +692,7 @@ static int checkpoint_vmas(struct ckpt_ctx *ctx, struct mm_struct *mm)
 		else
 			ret = -ENOSYS;
 		if (ret < 0) {
-			ckpt_write_err(ctx, "TE", "vma: failed", ret);
+			ckpt_write_err(ctx, "%(T)%(E)vma: failed", ret);
 			break;
 		}
 		/*
@@ -821,7 +821,7 @@ static int collect_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	if (mm->exe_file) {
 		ret = ckpt_collect_file(ctx, mm->exe_file);
 		if (ret < 0) {
-			ckpt_write_err(ctx, "TE", "mm: collect exe_file", ret);
+			ckpt_write_err(ctx, "%(T)%(E)mm: collect exe_file", ret);
 			goto out;
 		}
 	}
@@ -831,7 +831,7 @@ static int collect_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 			continue;
 		ret = ckpt_collect_file(ctx, file);
 		if (ret < 0) {
-			ckpt_write_err(ctx, "TE", "mm: collect vm_file", ret);
+			ckpt_write_err(ctx, "%(T)%(E)mm: collect vm_file", ret);
 			break;
 		}
 	}
-- 
1.6.1
