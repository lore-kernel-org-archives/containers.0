From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 04/12] checkpoint/memory.c ckpt_write_err->ckpt_err
Date: Mon,  2 Nov 2009 16:23:32 -0600
Message-ID: <1257200620-15499-5-git-send-email-serue@us.ibm.com>
References: <1257200620-15499-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257200620-15499-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/memory.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/checkpoint/memory.c b/checkpoint/memory.c
index 656614c..6cfd079 100644
--- a/checkpoint/memory.c
+++ b/checkpoint/memory.c
@@ -679,8 +679,8 @@ static int checkpoint_vmas(struct ckpt_ctx *ctx, struct mm_struct *mm)
 			 vma->vm_start, vma->vm_end, vma->vm_flags);
 
 		if (vma->vm_flags & CKPT_VMA_NOT_SUPPORTED) {
-			ckpt_write_err(ctx, "TE", "vma: bad flags (%#lx)\n",
-				       -ENOSYS, vma->vm_flags);
+			ckpt_err(ctx, "%(T)%(E)vma: bad flags (%#lx)\n",
+					-ENOSYS, vma->vm_flags);
 			ret = -ENOSYS;
 			break;
 		}
@@ -692,7 +692,7 @@ static int checkpoint_vmas(struct ckpt_ctx *ctx, struct mm_struct *mm)
 		else
 			ret = -ENOSYS;
 		if (ret < 0) {
-			ckpt_write_err(ctx, "TE", "vma: failed", ret);
+			ckpt_err(ctx, "%(T)%(E)vma: failed\n", ret);
 			break;
 		}
 		/*
@@ -821,7 +821,7 @@ static int collect_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 	if (mm->exe_file) {
 		ret = ckpt_collect_file(ctx, mm->exe_file);
 		if (ret < 0) {
-			ckpt_write_err(ctx, "TE", "mm: collect exe_file", ret);
+			ckpt_err(ctx, "%(T)%(E)mm: collect exe_file\n", ret);
 			goto out;
 		}
 	}
@@ -831,7 +831,7 @@ static int collect_mm(struct ckpt_ctx *ctx, struct mm_struct *mm)
 			continue;
 		ret = ckpt_collect_file(ctx, file);
 		if (ret < 0) {
-			ckpt_write_err(ctx, "TE", "mm: collect vm_file", ret);
+			ckpt_err(ctx, "%(T)%(E)mm: collect vm_file\n", ret);
 			break;
 		}
 	}
-- 
1.6.1
