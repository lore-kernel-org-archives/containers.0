From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v14][PATCH 31/54] powerpc: checkpoint/restart implementation
Date: Wed, 29 Apr 2009 01:54:59 -0500
Message-ID: <m34ow8ueyk.fsf@pobox.com>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-32-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240961064-13991-32-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren
	Laadan's message of "Tue\, 28 Apr 2009 19\:24\:01 -0400")
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

Hello Oren,

Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:

> From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
>
> Support for checkpointing and restarting GPRs, FPU state, DABR, and
> Altivec state.

...

> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

...

> +/* dump the cpu state and registers of a given task */
> +int checkpoint_write_cpu(struct ckpt_ctx *ctx, struct task_struct *t)
> +{
> +	struct ckpt_hdr_cpu *cpu_hdr;
> +	int rc;
> +
> +	rc = -ENOMEM;
> +	cpu_hdr = ckpt_hdr_get(ctx, sizeof(*cpu_hdr), CKPT_HDR_CPU);

This won't build (should be ckpt_hdr_get_type?).

I didn't write this code (I used kzalloc).

In the code I did write, I deliberately preferred the slab allocator to
the checkpoint-specific APIs.  I do not see the advantage of using an
arbitrarily fixed size special allocation stack that is prone to
overflow or, worse, data corruption if someone improperly interleaves
their gets and puts.

I don't believe you were acting in bad faith here, and I'm not sure
there's an established etiquette.  But my signed-off-by line is on this
patch, and I don't think it belongs there unless I've actually written
the code or agreed to the modifications.

If you insist on replacing kzalloc with ckpt_hdr_get, then please do so
in a separate commit with an explanation in the changelog.  I'd have no
objection to that -- it's your tree, after all.  Or if you want to munge
my patch in place, just replace my signoff with yours and note "based on
work by Nathan Lynch" or something.

Which brings me to the subject of tree management... it's rather
difficult for interested parties to follow development of a tree that is
frequently rewritten.  It would be much easier to base work on a linear
"append-only" branch.  The guesswork involved in tracking down
regressions in C/R function would be reduced because bisection would
work.  And we would have an accurate history of the changes made over
time.  The cost would be that the checkpoint/restart work would not have
an easily-reviewable native form, but I think it would be possible to
generate comprehensible diffs for review since the majority of the code
is in self-contained files.
