From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 4/4] remove checkpoint_types.h dependency from mm.h
Date: Mon, 22 Jun 2009 18:06:18 -0500
Message-ID: <1245711978-1453-5-git-send-email-ntl@pobox.com>
References: <1245711978-1453-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1245711978-1453-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

The checkpoint-related declarations in mm.h don't require the
definitions of struct ckpt_ctx and ckpt_hdr_vma; simply forward
declare these and remove the include of checkpoint_types.h.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/mm.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index c8e8972..fa89212 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -14,13 +14,12 @@
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
 
-#include <linux/checkpoint_types.h>
-
 struct mempolicy;
 struct anon_vma;
 struct file_ra_state;
 struct user_struct;
 struct writeback_control;
+struct ckpt_ctx;
 
 #ifndef CONFIG_DISCONTIGMEM          /* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
@@ -1199,6 +1198,7 @@ void task_dirty_inc(struct task_struct *tsk);
 
 /* checkpoint/restart */
 #ifdef CONFIG_CHECKPOINT
+struct ckpt_hdr_vma;
 extern int filemap_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 			   struct ckpt_hdr_vma *hh);
 extern int special_mapping_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
-- 
1.6.0.6
