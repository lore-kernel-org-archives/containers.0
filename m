From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] powerpc: vdso build fix (ckpt-v17)
Date: Wed, 12 Aug 2009 02:11:19 -0400
Message-ID: <4A825D07.9060000@librato.com>
References: <m3hbwn70uz.fsf@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m3hbwn70uz.fsf-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Nathan Lynch wrote:
> arch/powerpc/kernel/vdso.c: In function 'arch_setup_additional_pages':
> arch/powerpc/kernel/vdso.c:244: error: 'ret' undeclared (first use in this function)
> arch/powerpc/kernel/vdso.c:244: error: (Each undeclared identifier is reported only once
> arch/powerpc/kernel/vdso.c:244: error: for each function it appears in.)
> 
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  arch/powerpc/kernel/vdso.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
> index c25213b..679b394 100644
> --- a/arch/powerpc/kernel/vdso.c
> +++ b/arch/powerpc/kernel/vdso.c
> @@ -241,7 +241,7 @@ int arch_setup_additional_pages(struct linux_binprm *bprm,
>  
>  	/* for restart(2), double check that we got we asked for */
>  	if (start && vdso_base != start) {
> -		ret = -EBUSY;
> +		rc = -EBUSY;
>  		goto fail_mmapsem;
>  	}
>  

Oops !

Thanks, I hope this time around I'll get it right...
Pushed to ckpt-v17-dev.

Oren.
