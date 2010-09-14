From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 6/8] remove VM_HUGETLB and VM_RESERVED from
	CKPT_VMA_NOT_SUPPORTED
Date: Tue, 14 Sep 2010 15:02:08 -0500
Message-ID: <1284494530-25946-7-git-send-email-ntl@pobox.com>
References: <1284494530-25946-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1284494530-25946-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

Now that the hugetlb c/r support code is in place we can remove
VM_HUGETLB from the bitmask of unsupported vma flags.

All huge pages are VM_RESERVED so a less coarse method is needed to
prevent checkpoint of other reserved pages.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/checkpoint.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index d9a65a7..e224490 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -308,8 +308,7 @@ extern int checkpoint_memory_contents(struct ckpt_ctx *ctx,
 extern int restore_memory_contents(struct ckpt_ctx *ctx, struct inode *inode);
 
 #define CKPT_VMA_NOT_SUPPORTED						\
-	(VM_IO | VM_HUGETLB | VM_NONLINEAR | VM_PFNMAP |		\
-	 VM_RESERVED | VM_HUGETLB | VM_NONLINEAR |	\
+	(VM_IO | VM_NONLINEAR | VM_PFNMAP | VM_NONLINEAR |		\
 	 VM_MAPPED_COPY | VM_INSERTPAGE | VM_MIXEDMAP | VM_SAO)
 
 /* signals */
-- 
1.7.2.2
