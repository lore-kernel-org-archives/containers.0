From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: s390: set return value for self-checkpoint
Date: Thu, 23 Jul 2009 21:47:41 -0400
Message-ID: <4A6912BD.1000408@cs.columbia.edu>
References: <20090723182125.GA18383@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090723182125.GA18383-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org


Got it, thanks.

Serge E. Hallyn wrote:
> If doing a self-checkpoint, then optimistically store 0 as the
> syscall return value to indicate success.
> 
> This was being done for x86, but not yet being done for s390.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  arch/s390/mm/checkpoint.c |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/s390/mm/checkpoint.c b/arch/s390/mm/checkpoint.c
> index a4a5da9..40dd417 100644
> --- a/arch/s390/mm/checkpoint.c
> +++ b/arch/s390/mm/checkpoint.c
> @@ -54,6 +54,17 @@ static void s390_copy_regs(int op, struct ckpt_hdr_cpu *h,
>  	CKPT_COPY(op, h->instruction_fetch, thr->per_info.instruction_fetch);
>  
>  	CKPT_COPY_ARRAY(op, h->gprs, regs->gprs, NUM_GPRS);
> +	/*
> +	 * for checkpoint in process context (from within a container),
> +	 * the actual syscall is taking place at this very moment; so
> +	 * we (optimistically) subtitute the future return value (0) of
> +	 * this syscall into the orig_eax, so that upon restart it will
> +	 * succeed (or it will endlessly retry checkpoint...)
> +	 */
> +	if (op == CKPT_CPT && t==current) {
> +		BUG_ON(h->gprs[2] < 0);
> +		h->gprs[2] = 0;
> +	}
>  	CKPT_COPY_ARRAY(op, h->fprs, thr->fp_regs.fprs, NUM_FPRS);
>  	CKPT_COPY_ARRAY(op, h->acrs, thr->acrs, NUM_ACRS);
>  	CKPT_COPY_ARRAY(op, h->per_control_regs,
