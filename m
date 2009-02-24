From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] c/r: define s390-specific checkpoint-restart code (v5)
Date: Tue, 24 Feb 2009 11:56:59 -0800
Message-ID: <87k57flib8.fsf@caffeine.danplanet.com>
References: <1235500639-9597-1-git-send-email-danms@us.ibm.com>
	<1235500639-9597-3-git-send-email-danms@us.ibm.com>
	<20090224193737.GB24007@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090224193737.GB24007-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message of
	"Tue, 24 Feb 2009 13:37:37 -0600")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

>> +struct cr_hdr_cpu {
>> +	__u64 args[1];

SH> Dave wanted this to not be an array, right?

I think he was okay with it since it matched what is in the rest of
the s390 code.  I think that the use of the CR_COPY() macros makes it
nicer to have matching types as closely as possible.

>> +	union {
>> +		float f;
>> +		double d;
>> +		__u64 ui;

SH> Since this is a union, and you don't deal with its members but
SH> just memcpy it, why not just change it to

That's a fair argument, although I was thinking that there was some
expectation of being able to include this in userspace at some point
to inspect the contents of the CR stream.  The #ifdef __KERNEL__ at
the top of the file makes me think that's true.  If so, does it make
sense to leave this as-is for easier inspection of the contents?

>> +		struct {
>> +			__u32 fp_hi;
>> +			__u32 fp_lo;
>> +		} fp;
>> +	} fprs[NUM_FPRS];
>> +
>> +	/* per_struct */
>> +	__u64 per_control_regs[3];

SH> I assume Dave still wants you to add a

SH> #define PER_NUM_REGS 3

SH> into the arch/s390/include/asm/processor.h or something.

Ah, right, I thought I was getting out of fixing that with the
CR_COPY() macro, but I forgot about this one :)

>> +void cr_s390_mm(int op, struct cr_hdr_mm_context *hh, struct mm_struct *mm)
>> +{
>> +#if 0

SH> The comment about why this is ifdefed out for now should stay
SH> here.

Yep.

>> +/* Nothing to do for mm context state */

SH> The above comment is clearly wrong :)

Oops :)

>> +	restore_access_regs(hh->acrs);

SH> Just a comment explaining why?

But it's *so* obvious, right?  <ahem> ... Yeah, agreed :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
