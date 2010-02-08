From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] restart only same bit-ness
Date: Mon, 8 Feb 2010 12:39:51 -0800
Message-ID: <20100208203951.GJ3714@count0.beaverton.ibm.com>
References: <20100208170555.GA16943@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100208170555.GA16943-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

On Mon, Feb 08, 2010 at 11:05:55AM -0600, Serge E. Hallyn wrote:
> v19-rc3 actually tries to reset the TIF_IA32 flag according to
> how it was set at checkpoint.  It should not, at least for now.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Reviewed-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
>  arch/x86/kernel/checkpoint.c |   21 +++++++++++++++------
>  1 files changed, 15 insertions(+), 6 deletions(-)
> 
> diff --git a/arch/x86/kernel/checkpoint.c b/arch/x86/kernel/checkpoint.c
> index 5952e27..b01a2fc 100644
> --- a/arch/x86/kernel/checkpoint.c
> +++ b/arch/x86/kernel/checkpoint.c
> @@ -283,12 +283,21 @@ int restore_thread(struct ckpt_ctx *ctx)
>  	load_TLS(thread, cpu);
>  	put_cpu();
> 
> -#if defined(CONFIG_X86_64) && defined(CONFIG_COMPAT)
> -	if (h->thread_info_flags & _TIF_IA32)
> -		set_thread_flag(TIF_IA32);
> -	else
> -		clear_thread_flag(TIF_IA32);
> -#endif
> +	{
> +		int pre, post;
> +		/*
> +		 * Eventually we'd like to support mixed-bit restart, but for
> +		 * now don't pretend to.
> +		 */
> +		pre = test_thread_flag(TIF_IA32);
> +		post = h->thread_info_flags & _TIF_IA32;
> +		if ((pre && !post) || (post && !pre)) {

This might be clearer:

		pre = test_thread_flag(TIF_IA32);
		post = !!(h->thread_info_flags & _TIF_IA32);
		if (pre != post) {

Cheers,
	-Matt Helsley
