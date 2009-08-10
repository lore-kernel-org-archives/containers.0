From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/5] Add an errno validation function (v2)
Date: Mon, 10 Aug 2009 13:31:06 -0500
Message-ID: <20090810183106.GA24373@us.ibm.com>
References: <1249918379-29414-1-git-send-email-danms@us.ibm.com>
	<1249918379-29414-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1249918379-29414-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Ok, I do think it should be <= MAX_ERRNO but it's not particularly
urgent atm :)  So with or without that change:

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> Changes in v2:
>   - Compare against MAX_ERRNO instead of more stringent but obscure
>     constant
> ---
>  include/linux/checkpoint.h |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 45cf0fe..87b683b 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -28,7 +28,7 @@
>  #include <linux/user_namespace.h>
>  #include <linux/checkpoint_types.h>
>  #include <linux/checkpoint_hdr.h>
> -
> +#include <linux/err.h>
> 
>  /* ckpt_ctx: kflags */
>  #define CKPT_CTX_CHECKPOINT_BIT		0
> @@ -267,6 +267,10 @@ extern void *restore_sighand(struct ckpt_ctx *ctx);
>  			memcpy(LIVE, SAVE, count * sizeof(*SAVE));	\
>  	} while (0)
> 
> +static inline int ckpt_validate_errno(int errno)
> +{
> +	return (errno >= 0) && (errno < MAX_ERRNO);
> +}
> 
>  /* debugging flags */
>  #define CKPT_DBASE	0x1		/* anything */
> -- 
> 1.6.2.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
