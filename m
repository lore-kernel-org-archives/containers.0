From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 2/4] restart only same bit-ness
Date: Mon, 25 Jan 2010 19:48:13 -0600
Message-ID: <1264470494-14049-3-git-send-email-serue@us.ibm.com>
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

I'm hoping to get restart of 32-bit tasks on x86-64 working
for v19, but restart of 32-bit tasks using a 64-bit restart
program I'm not going to even try right now.  Rather than
get a completely uncommented '-22' return value from restore_cpu()
or do_munmap(), catch it early enough to give a meaningful
error in the logfile.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/kernel/checkpoint.c |   21 ++++++++++++++++-----
 1 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/checkpoint.c b/arch/x86/kernel/checkpoint.c
index fbe9521..0b8e2c3 100644
--- a/arch/x86/kernel/checkpoint.c
+++ b/arch/x86/kernel/checkpoint.c
@@ -272,11 +272,22 @@ int restore_thread(struct ckpt_ctx *ctx)
 	load_TLS(thread, cpu);
 	put_cpu();
 
-#if defined(CONFIG_X86_64) && defined(CONFIG_COMPAT)
-	if (h->thread_info_flags & _TIF_IA32)
-		set_thread_flag(TIF_IA32);
-	else
-		clear_thread_flag(TIF_IA32);
+#if defined(CONFIG_X86_64)
+	{
+		int pre, post;
+		/*
+		 * Eventually we'd like to support mixed-bit restart, but for
+		 * now don't pretend to.
+		 */
+		pre = test_thread_flag(TIF_IA32);
+		post = h->thread_info_flags & _TIF_IA32;
+		if ((pre && !post) || (post && !pre)) {
+			ret = -EINVAL;
+			ckpt_err(ctx, ret, "%d-bit restarting %d-bit\n",
+				pre ? 32 : 64, post ? 32 : 64);
+			goto out;
+		}
+	}
 #endif
 
 	/* TODO: restore TIF flags as necessary (e.g. TIF_NOTSC) */
-- 
1.6.0.6
