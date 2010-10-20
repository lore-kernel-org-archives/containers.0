From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 02/11] checkpoint: check actual array size before dereferencing
Date: Wed, 20 Oct 2010 13:56:37 -0500
Message-ID: <1287601006-13794-3-git-send-email-ntl@pobox.com>
References: <1287601006-13794-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1287601006-13794-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

The restore_vma_ops table is indexed by vma type (enum vma_type in
checkpoint_hdr.h).  We check the incoming VMA's type against
CKPT_VMA_MAX (which happens to be the size of the table), but it seems
more to-the-point to compare the type against the actual size of the
array.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 mm/checkpoint.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/checkpoint.c b/mm/checkpoint.c
index 00cbadd..c30a195 100644
--- a/mm/checkpoint.c
+++ b/mm/checkpoint.c
@@ -1207,7 +1207,7 @@ static int restore_vma(struct ckpt_ctx *ctx, struct mm_struct *mm)
 		goto out;
 	if (h->vma_objref < 0 || h->ino_objref < 0)
 		goto out;
-	if (h->vma_type >= CKPT_VMA_MAX)
+	if (h->vma_type >= ARRAY_SIZE(restore_vma_ops))
 		goto out;
 	ret = -ENOSYS;
 	if (h->vm_flags & CKPT_VMA_NOT_SUPPORTED)
-- 
1.7.2.2
