From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v14][PATCH 31/54] powerpc: checkpoint/restart implementation
Date: Wed, 29 Apr 2009 15:33:40 -0500
Message-ID: <m3vdonryhn.fsf@pobox.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-32-git-send-email-orenl@cs.columbia.edu>
	<m34ow8ueyk.fsf@pobox.com> <49F899E1.2030207@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49F899E1.2030207-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Wed\, 29 Apr 2009 14\:18\:09 -0400")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
> Nathan Lynch wrote:
>> 
>> Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
>>> +/* dump the cpu state and registers of a given task */
>>> +int checkpoint_write_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
>>> +{
>>> +	struct ckpt_hdr_cpu *cpu_hdr;
>>> +	int rc;
>>> +
>>> +	rc = -ENOMEM;
>>> +	cpu_hdr = ckpt_hdr_get(ctx, sizeof(*cpu_hdr), CKPT_HDR_CPU);
>> 
>> This won't build (should be ckpt_hdr_get_type?).
>> 
>> I didn't write this code (I used kzalloc).
>> 
>> In the code I did write, I deliberately preferred the slab allocator to
>> the checkpoint-specific APIs.  I do not see the advantage of using an
>> arbitrarily fixed size special allocation stack that is prone to
>> overflow or, worse, data corruption if someone improperly interleaves
>> their gets and puts.
>> 
>
> There is a reason I insist on it: I plan to optimize c/r app downtime
> by buffering data in the kernel while apps are frozen, and write-back
> the output after the resume execution. To do this efficiently without
> extra data copy you need something smarted than just kmalloc/kfree().
>
> Since some API and implementation will be used later, it makes sense
> to me to enforce at API requirement already. IOW, I want the code to
> use ckpt_hdr_get(), ckpt_hdr_put() and ckpt_hdr_get_type().
>
> How they are implemented, now, doesn't really matter. Your point about
> using kmalloc() is correct, in particular at this stage of development.
>
> So here's what I'll do:  I'll keep the interface requirement, and
> change the implementation behind to use kmalloc/kfree().

That sounds reasonable to me, thanks.
