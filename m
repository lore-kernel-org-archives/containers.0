From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] c/r: define s390-specific checkpoint-restart code (v4)
Date: Mon, 23 Feb 2009 16:27:02 -0800
Message-ID: <1235435222.26788.207.camel@nimitz>
References: <1235425143-9949-1-git-send-email-danms@us.ibm.com>
	<1235428269.26788.195.camel@nimitz>
	<87fxi492lr.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87fxi492lr.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2009-02-23 at 15:04 -0800, Dan Smith wrote:
> > +#define CR_390_PACK_TRACE_FLAGS(hdr, thread)	\
> >> +  do {						\
> >> +    hdr->em_instr = 0;				\
> >> +    if (thread->per_info.single_step)		\
> >> +      hdr->em_instr |= 1;			\
> >> +    if (thread->per_info.instruction_fetch)	\
> >> +      hdr->em_instr |= 2;			\
> >> +} while (0)
> >> +
> >> +#define CR_390_UNPACK_TRACE_FLAGS(hdr, thread)	\
> >> +  do {						\
> >> +    if (hdr->em_instr & 1)			\
> >> +      thread->per_info.single_step = 1;		\
> >> +    if (hdr->em_instr & 2)			\
> >> +      thread->per_info.instruction_fetch = 1;	\
> >> +  } while (0)
> 
> DH> Why are these macros?
> 
> Well, almost the exact code above was spread between the checkpoint
> and restart paths.  I think that this makes it a little clearer what 1
> and 2 are since you can see them together.

I'm just saying to use a 'static inline' instead.  Can they be functions
instead of macros.

> DH> Why do we need to pack them, anyway?
> 
> I assume Serge was trying not to waste a word per flag, and expecting
> more flags to be needed to justify the savings.

I actually think consistency with all the other fields and uniformity in
looking at the code is probably worth 14 bits of waste.  

> >> +	hh->svcnr = regs->svcnr;
> >> +	hh->ilc = regs->ilc;
> >> +	memcpy(hh->gprs, regs->gprs, NUM_GPRS*sizeof(unsigned long));
> >> +	hh->orig_gpr2 = regs->orig_gpr2;
> >> +
> >> +	hh->ieee_instruction_pointer = thread->ieee_instruction_pointer;
> >> +
> >> +	/* per_info */
> >> +	memcpy(&hh->per_control_regs, &thread->per_info.control_regs.words,
> >> +		3 * sizeof(unsigned long));
> 
> DH> This '3' is a magic number and is used in a few places.  Does it
> DH> make sense to define it as a variable.
> 
> You know, I said the same thing when I reviewed this set initially.
> However the actual s390 code where its defined uses the magic 3, so if
> we define a constant we could still be out of sync with the actual
> definition.

Then go fix the dang s390 code!  It is already bad style, so let's not
propagate it further.  The fact that you (Serge) could do this patch
without touching *any* current s390 code is really a sign that it is
done wrong, not right. ;)

> 
> DH> I'm struggling to figure out how we're going to keep up with
> DH> keeping checkpoint and restart synchronized.  This is all pretty
> DH> mindless copying in both directions.  Is it possible and
> DH> worthwhile for us to just define it once, but use it for both
> DH> checkpoint and restart with some macro trickery?
> 
> DH> #define CKPT 1
> DH> #define RST  2
> 
> DH> #define CR_COPY(op, a, b)
> DH> 	do {
> DH> 		WARN_ON(sizeof(a) != sizeof(b));
> DH> 		if (op == CKPT)
> DH> 			memcpy(&a, &b, sizeof(b));
> DH> 		else
> DH> 			memcpy(&b, &a, sizeof(b));
> DH> 	} while (0);
> 
> DH> void s390_cr_regs(int op, struct task_struct *thread, *hh)
> DH> {
> DH> 	CR_COPY(op, thread->per_info.lowcore.words.perc_atmid, hh->perc_atmid);
> DH> 	CR_COPY(op, thread->per_info.lowcore.words.address, hh->address);
> DH> 	CR_COPY(op, thread->per_info.lowcore.words.access_id, hh->access_id);
> DH> 	...
> DH> }
> 
> DH> int cr_read_cpu(struct cr_ctx *ctx)
> DH> {
> DH> 	s390_cr_regs(RST, thread, hh);
> DH> }
> 
> DH> int cr_save_cpu(struct cr_ctx *ctx)
> DH> {
> DH> 	s390_cr_regs(CKPT, thread, hh);
> DH> }
> 
> DH> That works for both regular variables and for arrays.  Is the
> DH> decreased line count worth the weirdo non-standard abstraction?
> 
> It looks cleaner to me, so I'm happy to change it if people think that
> would be better.

Yeah, I'm just curious what everyone thinks as a whole.  Keep it in the
back of your mind.

-- Dave
