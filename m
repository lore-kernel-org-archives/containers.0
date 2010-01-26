From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 3/4] x86_64: make some changes to fs/gs register handling
Date: Mon, 25 Jan 2010 19:48:14 -0600
Message-ID: <1264470494-14049-4-git-send-email-serue@us.ibm.com>
References: <1264470494-14049-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1264470494-14049-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

1. always save/restore fs/gs

	not just if CONFIG_COMPAT and the task is 64-bit.  Pretty
	sure that block wasn't doing what it wanted to do anyway :)

2. use rdmsrl for fs/gs for self-checkpoint

	<shrug>  other code seems to do it.  It doesn't seem to make
	a difference one way or the other.

3. null out fs/gs if index is set

	like __switch_to() does

4. fs and gs are not encoded segments, so don't run them through
check_segment().

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/kernel/checkpoint_64.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/arch/x86/kernel/checkpoint_64.c b/arch/x86/kernel/checkpoint_64.c
index ee01e17..46f2256 100644
--- a/arch/x86/kernel/checkpoint_64.c
+++ b/arch/x86/kernel/checkpoint_64.c
@@ -162,21 +162,26 @@ void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
 		savesegment(es, _es);
 		savesegment(fs, _fs);
 		savesegment(gs, _gs);
+		rdmsrl(MSR_FS_BASE, h->fs);
+		rdmsrl(MSR_KERNEL_GS_BASE, h->gs);
 	} else {
 		_ds = t->thread.ds;
 		_es = t->thread.es;
 		_fs = t->thread.fsindex;
 		_gs = t->thread.gsindex;
+		h->fs = t->thread.fs;
+		h->gs = t->thread.gs;
 	}
 	h->ds = encode_segment(_ds);
 	h->es = encode_segment(_es);
 	h->fsindex = encode_segment(_fs);
 	h->gsindex = encode_segment(_gs);
 
-	if (!test_tsk_thread_flag(t, TIF_IA32)) {
-		h->fs = t->thread.fs;
-		h->gs = t->thread.gs;
-	}
+	/* see comment in __switch_to() */
+	if (_fs)
+		h->fs = 0;
+	if (_gs)
+		h->gs = 0;
 
 	/*
 	 * for checkpoint in process context (from within a container),
@@ -203,12 +208,6 @@ int load_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
 	    !check_segment(h->fsindex) || !check_segment(h->gsindex))
 		return -EINVAL;
 
-#ifdef CONFIG_COMPAT
-	if (test_tsk_thread_flag(t, TIF_IA32) &&
-	    (!check_segment(h->fs) || !check_segment(h->gs)))
-		return -EINVAL;
-#endif
-
 	regs->r15 = h->r15;
 	regs->r14 = h->r14;
 	regs->r13 = h->r13;
@@ -240,18 +239,19 @@ int load_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
 	thread->fsindex = decode_segment(h->fsindex);
 	thread->gsindex = decode_segment(h->gsindex);
 
-#ifdef CONFIG_COMPAT
-	if (!test_tsk_thread_flag(t, TIF_IA32)) {
-		thread->fs = h->fs;
-		thread->gs = h->gs;
-	}
-#endif
+	thread->fs = h->fs;
+	thread->gs = h->gs;
 
 	/* XXX - unsure is this really needed ... */
 	loadsegment(fs, thread->fsindex);
         if (thread->fs)
 		wrmsrl(MSR_FS_BASE, thread->fs);
 	load_gs_index(thread->gsindex);
+	/*
+	 * when we switch to user-space, the MSR_KERNEL_GS_BASE
+	 * will be moved back to MSR_GS_BASE.
+	 * http://lists.openwall.net/linux-kernel/2008/11/18/340
+	 */
         if (thread->gs)
 		wrmsrl(MSR_KERNEL_GS_BASE, thread->gs);
 
-- 
1.6.0.6
