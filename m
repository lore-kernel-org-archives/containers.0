From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 1/9] Use CKPT_ARCH_X86_32 for all x86 CKPT_ARCH_IDs
Date: Mon,  8 Feb 2010 19:59:58 -0600
Message-ID: <1265680806-13295-2-git-send-email-serue@us.ibm.com>
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

Sure we can rename it eventually, but I'm still just experimenting...

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/x86/include/asm/checkpoint_hdr.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/checkpoint_hdr.h b/arch/x86/include/asm/checkpoint_hdr.h
index 535a9c6..a1edeb6 100644
--- a/arch/x86/include/asm/checkpoint_hdr.h
+++ b/arch/x86/include/asm/checkpoint_hdr.h
@@ -36,13 +36,7 @@
 #include <asm/processor.h>
 #endif
 
-#ifdef CONFIG_X86_64
-#define CKPT_ARCH_ID	CKPT_ARCH_X86_64
-#endif
-
-#ifdef CONFIG_X86_32
 #define CKPT_ARCH_ID	CKPT_ARCH_X86_32
-#endif
 
 /* arch dependent header types */
 enum {
-- 
1.6.0.4
