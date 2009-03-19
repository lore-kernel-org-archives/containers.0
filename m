From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/3] s390: Expose a constant for the number of words
	representing the CRs
Date: Thu, 19 Mar 2009 15:41:17 -0400
Message-ID: <1237491679-14433-2-git-send-email-danms@us.ibm.com>
References: <1237491679-14433-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1237491679-14433-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

We need to use this value in the checkpoint/restart code and would like to
have a constant instead of a magic '3'.

Changelog:
    Mar 03:
            . Picked up additional use of magic '3' in ptrace.h

Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/include/asm/ptrace.h   |    4 +++-
 arch/s390/kernel/compat_ptrace.h |    3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/s390/include/asm/ptrace.h b/arch/s390/include/asm/ptrace.h
index 8920025..f1b0516 100644
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
@@ -334,7 +336,7 @@ struct pt_regs
  */
 typedef struct
 {
-	unsigned long cr[3];
+	unsigned long cr[NUM_CR_WORDS];
 } per_cr_words;
 
 #define PER_EM_MASK 0xE8000000UL
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
