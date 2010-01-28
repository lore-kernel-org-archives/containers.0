From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/2] allow 32-bit restart of 64-bit and vice versa
Date: Wed, 27 Jan 2010 22:22:07 -0600
Message-ID: <20100128042207.GA15779@us.ibm.com>
References: <20100128042137.GA15723@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100128042137.GA15723-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/kernel/checkpoint.c |   21 +++++----------------
 1 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/arch/x86/kernel/checkpoint.c b/arch/x86/kernel/checkpoint.c
index 0b8e2c3..fbe9521 100644
--- a/arch/x86/kernel/checkpoint.c
+++ b/arch/x86/kernel/checkpoint.c
@@ -272,22 +272,11 @@ int restore_thread(struct ckpt_ctx *ctx)
 	load_TLS(thread, cpu);
 	put_cpu();
 
-#if defined(CONFIG_X86_64)
-	{
-		int pre, post;
-		/*
-		 * Eventually we'd like to support mixed-bit restart, but for
-		 * now don't pretend to.
-		 */
-		pre = test_thread_flag(TIF_IA32);
-		post = h->thread_info_flags & _TIF_IA32;
-		if ((pre && !post) || (post && !pre)) {
-			ret = -EINVAL;
-			ckpt_err(ctx, ret, "%d-bit restarting %d-bit\n",
-				pre ? 32 : 64, post ? 32 : 64);
-			goto out;
-		}
-	}
+#if defined(CONFIG_X86_64) && defined(CONFIG_COMPAT)
+	if (h->thread_info_flags & _TIF_IA32)
+		set_thread_flag(TIF_IA32);
+	else
+		clear_thread_flag(TIF_IA32);
 #endif
 
 	/* TODO: restore TIF flags as necessary (e.g. TIF_NOTSC) */
-- 
1.6.0.6
