From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v13][PATCH 05/14] x86 support for checkpoint/restart
Date: Tue, 24 Feb 2009 01:47:39 -0600
Message-ID: <20090224014739.1b82fc35__23873.402135405$1235461863$gmane$org@thinkcentre.lan>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1233076092-8660-6-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1233076092-8660-6-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: Linus Torvalds <torvalds-3NddpPZAyC0@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dave-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter
	Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi, this is an old thread I guess, but I just noticed some issues while
looking at this code.

On Tue, 27 Jan 2009 12:08:03 -0500
Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:
> +static int cr_read_cpu_fpu(struct cr_ctx *ctx, struct task_struct *t)
> +{
> +	void *xstate_buf = cr_hbuf_get(ctx, xstate_size);
> +	int ret;
> +
> +	ret = cr_kread(ctx, xstate_buf, xstate_size);
> +	if (ret < 0)
> +		goto out;
> +
> +	/* i387 + MMU + SSE */
> +	preempt_disable();
> +
> +	/* init_fpu() also calls set_used_math() */
> +	ret = init_fpu(current);
> +	if (ret < 0)
> +		return ret;

Several problems here:
* init_fpu can call kmem_cache_alloc(GFP_KERNEL), but is called here
  with preempt disabled (init_fpu could use a might_sleep annotation?)
* if init_fpu returns an error, we get preempt imbalance
* if init_fpu returns an error, we "leak" the cr_hbuf_get for
  xstate_buf

Speaking of cr_hbuf_get... I'd prefer to see that "allocator" go away
and its users converted to kmalloc/kfree (this is what I've done for
the powerpc C/R code, btw).

Using the slab allocator would:

* make the code less obscure and easier to review
* make the code more amenable to static analysis
* gain the benefits of slab debugging at runtime

But I think this has been pointed out before.  If I understand the
justification for cr_hbuf_get correctly, the allocations it services
are somehow known to be bounded in size and nesting.  But even if that
is the case, it's not much of a reason to avoid using kmalloc, is it?
