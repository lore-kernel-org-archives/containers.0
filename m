From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: Linux Checkpoint-Restart - v19
Date: Tue, 06 Apr 2010 16:49:45 -0500
Message-ID: <1270590585.2375.189.camel@localhost>
References: <0B4E8136-FFC6-490D-B04A-23A6E1A924FF@dependable-os.net>
	<20100317205556.GA20750@us.ibm.com>
	<EF179F3A-4FBA-4776-B7A4-48F5EF73DC9C@dependable-os.net>
	<4BA39971.2080402@cs.columbia.edu>
	<FF5CB8EA-436D-4685-B7A2-946A83DF3F78@dependable-os.net>
	<20100324164758.GA21021@us.ibm.com>
	<BC2CC354-59BA-465A-A863-0CDCD921A99A@dependable-os.net>
	<20100330030535.GA13362@us.ibm.com>
	<18557515-762E-4EE6-90D7-C8F782E487B2@dependable-os.net>
	<20100405140629.GG32049@us.ibm.com>
	<20100405143157.GX3345@count0.beaverton.ibm.com>
	<39FCECBC-BFE3-4328-BCFC-CBACA3CB442E@dependable-os.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <39FCECBC-BFE3-4328-BCFC-CBACA3CB442E-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jiro SEKIBA <jir-Xy3Dp9s2+bNGIRItUzBvX16hYfS7NtTn@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello-

On Tue, 2010-04-06 at 11:54 +0900, Jiro SEKIBA wrote:
> I tried checkpointing/restarting with this binary, but still get SEGV at the same point, 
> still get same gdb warning(Cannot find thread-local variables on this target)

I believe I have been experiencing a similar problem:

https://lists.linux-foundation.org/pipermail/containers/2010-April/024105.html

I may have found a fix.  Can you please test whether this kernel patch
makes the SEGVs after restart go away?


 arch/x86/kernel/checkpoint_32.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kernel/checkpoint_32.c b/arch/x86/kernel/checkpoint_32.c
index 32cde34..d80c168 100644
--- a/arch/x86/kernel/checkpoint_32.c
+++ b/arch/x86/kernel/checkpoint_32.c
@@ -86,7 +86,6 @@ static unsigned short decode_segment(__u16 seg)
 
 void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
 {
-	struct thread_struct *thread = &t->thread;
 	struct pt_regs *regs = task_pt_regs(t);
 	unsigned long _gs;
 
@@ -116,7 +115,7 @@ void save_cpu_regs(struct ckpt_hdr_cpu *h, struct task_struct *t)
 	if (t == current)
 		_gs = get_user_gs(regs);
 	else
-		_gs = thread->gs;
+		_gs = task_user_gs(t);
 
 	h->fsindex = encode_segment(regs->fs);
 	h->gsindex = encode_segment(_gs);
