From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] checkpoint/i386: use task_user_gs to checkpoint gs
Date: Tue,  6 Apr 2010 18:37:41 -0500
Message-ID: <1270597061-26041-1-git-send-email-ntl@pobox.com>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Depending on the setting of CONFIG_X86_32_LAZY_GS, gs may be saved in
the thread_struct or in pt_regs.  Use the task_user_gs() accessor to
checkpoint gs appropriately for both cases.  This solves post-restart
program crashes when CONFIG_X86_32_LAZY_GS=n.

Tested-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 arch/x86/kernel/checkpoint_32.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/arch/x86/kernel/checkpoint_32.c b/arch/x86/kernel/checkpoint_32.c
index 32cde34..c4ce450 100644
--- a/arch/x86/kernel/checkpoint_32.c
+++ b/arch/x86/kernel/checkpoint_32.c
@@ -86,7 +86,6 @@ static unsigned short decode_segment(__u16 seg)
 
 void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
 {
-	struct thread_struct *thread = &t->thread;
 	struct pt_regs *regs = task_pt_regs(t);
 	unsigned long _gs;
 
@@ -108,15 +107,10 @@ void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
 	h->ds = encode_segment(regs->ds);
 	h->es = encode_segment(regs->es);
 
-	/*
-	 * for checkpoint in process context (from within a container)
-	 * the GS segment register should be saved from the hardware;
-	 * otherwise it is already saved on the thread structure
-	 */
 	if (t == current)
 		_gs = get_user_gs(regs);
 	else
-		_gs = thread->gs;
+		_gs = task_user_gs(t);
 
 	h->fsindex = encode_segment(regs->fs);
 	h->gsindex = encode_segment(_gs);
-- 
1.6.6.1
