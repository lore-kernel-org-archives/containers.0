From: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] c/r: define s390-specific checkpoint-restart code (v3)
Date: Wed, 4 Feb 2009 10:19:53 +0100
Message-ID: <200902041019.53683.borntraeger@de.ibm.com>
References: <20090203161223.GA17998@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090203161223.GA17998-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
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
Cc: linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Am Tuesday 03 February 2009 17:12:23 schrieb Serge E. Hallyn:
[...]
> +/* Nothing to do for mm context state */
> +int cr_write_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int
> parent) +{
> +	struct cr_hdr h;
> +	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	int ret;
> +
> +	h.type = CR_HDR_MM_CONTEXT;
> +	h.len = sizeof(*hh);
> +	h.parent = parent;
> +
> +#if 0
> +	/* Oren's v13 is on an older kernel which has no vdso_base */
> +	/* on newer kernel, we'll have to enable this */
> +	hh->vdso_base = mm->context.vdso_base;
> +	printk(KERN_NOTICE "checkpointing vdso_base %lx\n", hh->vdso_base);
> +#else
> +	hh->vdso_base = 0;
> +#endif
> +
> +	ret = cr_write_obj(ctx, &h, hh);
> +	cr_hbuf_put(ctx, sizeof(*hh));
> +
> +	return ret;
> +}

Hmm, maybe you should also save/restore other elements of mm_context_t.

At least noexec, has_pgste and alloc_pgste have an impact on the page table 
layout and special features like no execute or the ability to run kvm guests.

[...]

> +int cr_read_mm_context(struct cr_ctx *ctx, struct mm_struct *mm, int
> rparent) +{
> +	struct cr_hdr_mm_context *hh = cr_hbuf_get(ctx, sizeof(*hh));
> +	int parent, ret = -EINVAL;
> +
> +	s390_enable_sie();

Hmm, why do you call s390_enable_sie()? It will fail on multi-threaded apps 
and will create enhanced page tables for running kvm guest otherwise. It is 
not needed for non-kvm processes. See the has_pgste/alloc_pgste topic above.
