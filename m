From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] fix ckpt_mem build on ppc64
Date: Thu, 15 Jan 2009 13:34:40 -0600
Message-ID: <20090115193440.GA4924@localdomain>
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
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On 64-bit powerpc:

checkpoint/ckpt_mem.c: In function 'cr_write_vma':
checkpoint/ckpt_mem.c:447: error: request for member 'pgprot' in something not a structure or union

pgprot_t is an abstract type; use the proper accessor.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 checkpoint/ckpt_mem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

This is based on v12 of the C/R patches.

diff --git a/checkpoint/ckpt_mem.c b/checkpoint/ckpt_mem.c
index ccb14c7..4925ff2 100644
--- a/checkpoint/ckpt_mem.c
+++ b/checkpoint/ckpt_mem.c
@@ -444,7 +444,7 @@ static int cr_write_vma(struct cr_ctx *ctx, struct vm_area_struct *vma)
 
 	hh->vm_start = vma->vm_start;
 	hh->vm_end = vma->vm_end;
-	hh->vm_page_prot = vma->vm_page_prot.pgprot;
+	hh->vm_page_prot = pgprot_val(vma->vm_page_prot);
 	hh->vm_flags = vma->vm_flags;
 	hh->vm_pgoff = vma->vm_pgoff;
 
-- 
1.5.5
