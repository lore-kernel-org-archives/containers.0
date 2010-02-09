From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 4/9] x86_32: add TIF_IA32 to thread flags
Date: Mon,  8 Feb 2010 20:00:01 -0600
Message-ID: <1265680806-13295-5-git-send-email-serue@us.ibm.com>
References: <1265680806-13295-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1265680806-13295-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

X86-32 does not set TIF_IA32 on tasks.  But since we now use the
same CKPT_ARCH_ID for X86-32 and X86-64, this means that when we
restart a task from X86-32 on X86-64, we can't tell that it should
have been 32-bit.

So always set TIF_IA32 in thread_info_flags for a task when
checkpointing on X86-32.

Likewise, at restart, when comparing the current task (the running
restart binary) to the checkpointed one (to be restarted) to make
sure both are either 32-bit or 64-bit, we obviously can't count
on TIF_IA32 being set in current_flags on X86-32.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/kernel/checkpoint.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/arch/x86/kernel/checkpoint.c b/arch/x86/kernel/checkpoint.c
index b01a2fc..961b131 100644
--- a/arch/x86/kernel/checkpoint.c
+++ b/arch/x86/kernel/checkpoint.c
@@ -103,6 +103,9 @@ int checkpoint_thread(struct ckpt_ctx *ctx, struct task_struct *t)
 
 	h->thread_info_flags =
 		task_thread_info(t)->flags & ~CKPT_X86_TIF_UNSUPPORTED;
+#ifndef CONFIG_X86_64
+	h->thread_info_flags |= _TIF_IA32;
+#endif
 	h->gdt_entry_tls_entries = GDT_ENTRY_TLS_ENTRIES;
 	h->sizeof_tls_array = tls_size;
 
@@ -289,7 +292,11 @@ int restore_thread(struct ckpt_ctx *ctx)
 		 * Eventually we'd like to support mixed-bit restart, but for
 		 * now don't pretend to.
 		 */
+#ifndef CONFIG_X86_64
+		pre = 1;
+#else
 		pre = test_thread_flag(TIF_IA32);
+#endif
 		post = h->thread_info_flags & _TIF_IA32;
 		if ((pre && !post) || (post && !pre)) {
 			ret = -EINVAL;
-- 
1.6.0.4
