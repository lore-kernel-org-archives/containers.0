From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] c/r: define s390-specific checkpoint-restart code (v6)
Date: Wed, 25 Feb 2009 14:37:19 -0800
Message-ID: <87ab8ata74.fsf@caffeine.danplanet.com>
References: <1235585529-806-1-git-send-email-danms@us.ibm.com>
	<1235585529-806-4-git-send-email-danms@us.ibm.com>
	<20090225162817.2003383c@thinkcentre.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090225162817.2003383c-4v5LP+xe+1byhTdZtsIeww@public.gmane.org> (Nathan Lynch's message
	of "Wed, 25 Feb 2009 16:28:17 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

NL> In the powerpc implementation I was able to get away with
NL> returning zero, without writing dummy headers, for cases like
NL> this.

Right, as did we.  However, mktree.c expects to read a header in this
part of the stream.  The kernel expects what the kernel has written,
which is easy.  However, when writing something that needs to
interpret any platform's stream, I think it's easier if you don't have
a bunch of "optional" headers that you need to test for and maybe
handle (especially in the case of reading the stream over a socket or
the like).

>> +extern void cr_s390_regs(int op, struct cr_hdr_cpu *hh, struct task_struct *t);
>> +extern void cr_s390_mm(int op, struct cr_hdr_mm_context *hh,
>> +		       struct mm_struct *mm);

NL> These belong in a header, please...

Actually, I was hoping that Dave would stir up some conversation about
moving all of this back into a single file since we cut the line count
down so much with our evil macros :)

>> +	regs->psw.addr &= ~PSW_ADDR_INSN;
>> +	cr_s390_regs(CR_RST, hh, current);

NL> The PSW_ADDR_INSN bit in regs->psw.addr is cleared, and then
NL> regs-> psw.addr is overwritten by cr_s390_regs?

Yes, this is broken, thanks.  It is also an example of where the
macros won't work as nicely for us.  This is left over from Serge's
original code, where I believe he was attempting to avoid loading
anything into the PSW other than the instruction pointer bit.  A
trivial change to cr_s390_regs() will correct this.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
