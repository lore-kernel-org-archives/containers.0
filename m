From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: define s390-specific checkpoint-restart code (v4)
Date: Tue, 24 Feb 2009 09:23:30 -0600
Message-ID: <20090224152330.GA17294@us.ibm.com>
References: <1235425143-9949-1-git-send-email-danms@us.ibm.com>
	<1235428269.26788.195.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1235428269.26788.195.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> > +	/* s390_fp_regs_t */
> > +	__u32 fpc;
> > +	struct {
> > +		float f;
> > +		double d;
> > +		__u64 ui;
> > +		__u32 fp_hi;
> > +		__u32 fp_lo;
> > +	} fprs[NUM_FPRS];
> 
> I don't see a lot of floating point code go by, so I'm a bit stupid on
> this.  But, this doesn't make a lot of sense to me.  Are there really
> parallel sets of float and double registers?  Or, do we want some kind
> of union here?

Heh, yeah, freg_t in arch/s390/include/asm/ptrace.h is a union.  Which
as you note ought to have been obvious based on the union members.  My
bad.

> I'm struggling to figure out how we're going to keep up with keeping
> checkpoint and restart synchronized.  This is all pretty mindless
> copying in both directions.  Is it possible and worthwhile for us to
> just define it once, but use it for both checkpoint and restart with
> some macro trickery?
> 
> #define CKPT 1
> #define RST  2
> 
> #define CR_COPY(op, a, b)
> 	do {
> 		WARN_ON(sizeof(a) != sizeof(b));
> 		if (op == CKPT)
> 			memcpy(&a, &b, sizeof(b));
> 		else
> 			memcpy(&b, &a, sizeof(b));
> 	} while (0);
> 
> void s390_cr_regs(int op, struct task_struct *thread, *hh)
> {
> 	CR_COPY(op, thread->per_info.lowcore.words.perc_atmid, hh->perc_atmid);
> 	CR_COPY(op, thread->per_info.lowcore.words.address, hh->address);
> 	CR_COPY(op, thread->per_info.lowcore.words.access_id, hh->access_id);
> 	...
> }
> 
> int cr_read_cpu(struct cr_ctx *ctx)
> {
> 	s390_cr_regs(RST, thread, hh);
> }
> 
> int cr_save_cpu(struct cr_ctx *ctx)
> {
> 	s390_cr_regs(CKPT, thread, hh);
> }
> 
> That works for both regular variables and for arrays.  Is the decreased
> line count worth the weirdo non-standard abstraction?

Well it's not necessarily nicer to read, but you're right it will
almost doubtless prevent at least one bug resulting from update
snafu between checkpoint and restart code.

Great idea!  Should we try and do that as much as possible for
the x86 code too?

-serge
