From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH linux-cr] s390: save_access_regs for self-checkpoint
Date: Thu, 25 Feb 2010 11:05:54 -0600
Message-ID: <20100225170554.GA16683@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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

When doing a self-checkpoint, we have to get the access registers
from hw.

Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
---
 arch/s390/kernel/checkpoint.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/arch/s390/kernel/checkpoint.c b/arch/s390/kernel/checkpoint.c
index 03307e2..894bca3 100644
--- a/arch/s390/kernel/checkpoint.c
+++ b/arch/s390/kernel/checkpoint.c
@@ -79,7 +79,11 @@ static void s390_copy_regs(int op, struct ckpt_hdr_cpu *h,
 	}
 
 	CKPT_COPY_ARRAY(op, h->fprs, thr->fp_regs.fprs, NUM_FPRS);
-	CKPT_COPY_ARRAY(op, h->acrs, thr->acrs, NUM_ACRS);
+	if (op == CKPT_CPT && t == current) {
+		save_access_regs(h->acrs);
+	} else {
+		CKPT_COPY_ARRAY(op, h->acrs, thr->acrs, NUM_ACRS);
+	}
 	CKPT_COPY_ARRAY(op, h->per_control_regs,
 		      thr->per_info.control_regs.words.cr, NUM_CR_WORDS);
 }
-- 
1.6.1
