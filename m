From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: export filemap_checkpoint()
Date: Thu, 21 Jan 2010 18:20:04 -0500
Message-ID: <1264116004-1892-1-git-send-email-orenl@cs.columbia.edu>
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

Allow file systems and devices that use filemap_checkpoint() in their
vm_ops structure to be compiled as modules gracefully.

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 mm/filemap.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 7efb315..2411849 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1668,6 +1668,7 @@ int filemap_checkpoint(struct ckpt_ctx *ctx, struct vm_area_struct *vma)
 
 	return ret;
 }
+EXPORT_SYMBOL(filemap_checkpoint);
 
 int filemap_restore(struct ckpt_ctx *ctx,
 		    struct mm_struct *mm,
-- 
1.6.3.3
