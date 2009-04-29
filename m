From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [RFC v14][PATCH 31/54] powerpc: checkpoint/restart implementation
Date: Wed, 29 Apr 2009 14:05:28 -0400
Message-ID: <49F896E8.7020802@cs.columbia.edu>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-32-git-send-email-orenl@cs.columbia.edu>
	<m34ow8ueyk.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m34ow8ueyk.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org



Nathan Lynch wrote:
> Hello Oren,
> 
> Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
> 
>> From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
>>
>> Support for checkpointing and restarting GPRs, FPU state, DABR, and
>> Altivec state.
> 
> ...
> 
>> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> 
> ...
> 
>> +/* dump the cpu state and registers of a given task */
>> +int checkpoint_write_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
>> +{
>> +	struct ckpt_hdr_cpu *cpu_hdr;
>> +	int rc;
>> +
>> +	rc = -ENOMEM;
>> +	cpu_hdr = ckpt_hdr_get(ctx, sizeof(*cpu_hdr), CKPT_HDR_CPU);
> 
> This won't build (should be ckpt_hdr_get_type?).
> 
> I didn't write this code (I used kzalloc).
> 
> In the code I did write, I deliberately preferred the slab allocator to
> the checkpoint-specific APIs.  I do not see the advantage of using an
> arbitrarily fixed size special allocation stack that is prone to
> overflow or, worse, data corruption if someone improperly interleaves
> their gets and puts.
> 
> I don't believe you were acting in bad faith here, and I'm not sure
> there's an established etiquette.  But my signed-off-by line is on this
> patch, and I don't think it belongs there unless I've actually written
> the code or agreed to the modifications.
> 
> If you insist on replacing kzalloc with ckpt_hdr_get, then please do so
> in a separate commit with an explanation in the changelog.  I'd have no
> objection to that -- it's your tree, after all.  Or if you want to munge
> my patch in place, just replace my signoff with yours and note "based on
> work by Nathan Lynch" or something.

You are correct. Originally I was unsure how to modify that, and
later in the flood of  other changes I forgot to get back to that
commit message. I apologize for that.

Oren.
