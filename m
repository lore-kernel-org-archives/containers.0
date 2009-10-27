From: Serge Hallyn <serge-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [RFC PATCH 03/17] ckpt_write_err update arch/x86/mm/checkpoint.c
Date: Tue, 27 Oct 2009 17:46:13 -0500
Message-ID: <1256683587-23961-4-git-send-email-serge@us.ibm.com>
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
 arch/x86/mm/checkpoint.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/checkpoint.c b/arch/x86/mm/checkpoint.c
index 9dd8e12..3b0f514 100644
--- a/arch/x86/mm/checkpoint.c
+++ b/arch/x86/mm/checkpoint.c
@@ -116,11 +116,11 @@ static unsigned short decode_segment(__u16 seg)
 static int may_checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 {
 	if (t->thread.vm86_info) {
-		ckpt_write_err(ctx, "TE", "task in VM86 mode", -EBUSY);
+		ckpt_write_err(ctx, "%(T)%(E)task in VM86 mode", -EBUSY);
 		return -EBUSY;
 	}
 	if (task_thread_info(t)->flags & CKPT_X86_TIF_UNSUPPORTED) {
-		ckpt_write_err(ctx, "TE", "bad thread info flags %#lx", -EBUSY);
+		ckpt_write_err(ctx, "%(T)%(E)bad thread info flags %#lx", -EBUSY);
 		return -EBUSY;
 	}
 	return 0;
-- 
1.6.1
