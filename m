From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] s390: Expose a constant for the number of words
	representing the CRs
Date: Wed, 25 Feb 2009 13:12:07 -0500
Message-ID: <1235585529-806-2-git-send-email-danms@us.ibm.com>
References: <1235585529-806-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1235585529-806-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

We need to use this value in the checkpoint/restart code and would like to
have a constant instead of a magic '3'.

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 arch/s390/include/asm/ptrace.h   |    2 ++
 arch/s390/kernel/compat_ptrace.h |    3 ++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/arch/s390/include/asm/ptrace.h b/arch/s390/include/asm/ptrace.h
index 5396f9f..d5b0781 100644
--- a/arch/s390/include/asm/ptrace.h
+++ b/arch/s390/include/asm/ptrace.h
@@ -172,6 +172,8 @@
 #define NUM_CRS		16
 #define NUM_ACRS	16
 
+#define NUM_CR_WORDS	3
+
 #define FPR_SIZE	8
 #define FPC_SIZE	4
 #define FPC_PAD_SIZE	4 /* gcc insists on aligning the fpregs */
diff --git a/arch/s390/kernel/compat_ptrace.h b/arch/s390/kernel/compat_ptrace.h
index a2be3a9..123dd66 100644
--- a/arch/s390/kernel/compat_ptrace.h
+++ b/arch/s390/kernel/compat_ptrace.h
@@ -1,10 +1,11 @@
 #ifndef _PTRACE32_H
 #define _PTRACE32_H
 
+#include <asm/ptrace.h>    /* needed for NUM_CR_WORDS */
 #include "compat_linux.h"  /* needed for psw_compat_t */
 
 typedef struct {
-	__u32 cr[3];
+	__u32 cr[NUM_CR_WORDS];
 } per_cr_words32;
 
 typedef struct {
-- 
1.6.1
