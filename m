From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/3] checkpoint/powerpc: warn if full register state
	unavailable
Date: Fri,  4 Dec 2009 20:48:27 -0600
Message-ID: <1259981307-24936-4-git-send-email-ntl@pobox.com>
References: <1259981307-24936-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1259981307-24936-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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

Emit a warning if we attempt to checkpoint a task for which the user
nonvolatile register state (r13-r31) has not been saved.  This should
not ever happen.

Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
---
 arch/powerpc/mm/checkpoint.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/mm/checkpoint.c b/arch/powerpc/mm/checkpoint.c
index de18467..2634011 100644
--- a/arch/powerpc/mm/checkpoint.c
+++ b/arch/powerpc/mm/checkpoint.c
@@ -107,6 +107,8 @@ static void checkpoint_gprs(struct ckpt_hdr_cpu *cpu_hdr,
 
 	cpu_hdr->pt_regs_size = sizeof(*pt_regs);
 	pt_regs = task_pt_regs(task);
+	WARN_ON(!FULL_REGS(pt_regs));
+
 	cpu_hdr->pt_regs = *pt_regs;
 
 	if (task == current)
-- 
1.6.0.6
