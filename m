From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/4] shm.h: add checkpoint-related declarations
Date: Mon, 22 Jun 2009 18:06:15 -0500
Message-ID: <1245711978-1453-2-git-send-email-ntl@pobox.com>
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

shm.h apparently relies on ordering of includes in .c files to get
declarations of ckpt_ctx and ckpt_hdr_vma for ipcshm_restore's
prototype.  This is bad.  Add appropriate forward declarations.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 include/linux/shm.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/shm.h b/include/linux/shm.h
index 6edc26e..94ac1a7 100644
--- a/include/linux/shm.h
+++ b/include/linux/shm.h
@@ -124,6 +124,8 @@ extern int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
 
 #ifdef CONFIG_CHECKPOINT
 #ifdef CONFIG_SYSVIPC
+struct ckpt_ctx;
+struct ckpt_hdr_vma;
 extern int ipcshm_restore(struct ckpt_ctx *ctx, struct mm_struct *mm,
 			  struct ckpt_hdr_vma *h);
 #else
-- 
1.6.0.6
