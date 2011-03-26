From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] powerpc: Remove remaining debugreg bits from forward
	port of v22-dev patches
Date: Fri, 25 Mar 2011 22:09:54 -0400
Message-ID: <4D8D4AF2.6040909@cs.columbia.edu>
References: <cd26e0322da9081a888336f40ea2057dad70cea2.1296134526.git.matthltc@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cd26e0322da9081a888336f40ea2057dad70cea2.1296134526.git.matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Matt/Nathan:

I lost track with the ppc patches - and I wouldn't be able to test
the code anyway. Any chance you could resend an updated ppc-c/r set ?

Thanks ...

Oren.


On 01/27/2011 08:22 AM, Matt Helsley wrote:
> The commit 'powerpc: provide APIs for validating and updating DABR'
> from ckpt-v22-dev can be dropped for v23-rc1 but other patches in
> the v22-dev series for powerpc use the debugreg functions introduced
> there. They can be rebased and merged with this patch and the
> debugreg code can be pushed as a later, independent patch.
> 
> Signed-off-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Cc: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> ---
>  arch/powerpc/kernel/checkpoint.c |    8 --------
>  1 files changed, 0 insertions(+), 8 deletions(-)
> 
> diff --git a/arch/powerpc/kernel/checkpoint.c b/arch/powerpc/kernel/checkpoint.c
> index 9aeab89..00fc2bb 100644
> --- a/arch/powerpc/kernel/checkpoint.c
> +++ b/arch/powerpc/kernel/checkpoint.c
> @@ -350,14 +350,6 @@ static int restore_dabr(const struct ckpt_hdr_cpu *cpu_hdr,
>  		goto out;
>  
>  	rc = -EINVAL;
> -	if (!debugreg_valid(cpu_hdr->dabr, 0))
> -		goto out;
> -
> -	rc = 0;
> -	if (!update)
> -		goto out;
> -
> -	debugreg_update(task, cpu_hdr->dabr, 0);
>  out:
>  	return rc;
>  }
