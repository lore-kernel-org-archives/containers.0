From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] test_and_set_bit returns oldval
Date: Sun, 18 Oct 2009 23:01:34 -0400
Message-ID: <4ADBD68E.7080707@librato.com>
References: <20091018211911.GA17271@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091018211911.GA17271-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Serge E. Hallyn wrote:
> ckpt_set_ctx_error() was not setting ctx->errno when it should - it
> apparently thought that test_and_set_bit(x,y) would return 1 if the
> set_bit succeeded?
> 
> Fix ckpt_set_ctx_error() to set ctx->errno the first (and only the
> first) time that CKPT_CTX_ERROR gets set in ctx->kflags.

Yeah .. and it explains why you never saw the error as you expected.

Applied, thanks !

> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/checkpoint.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 4b61378..c550039 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -111,7 +111,7 @@ extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
>  
>  static inline void ckpt_set_ctx_error(struct ckpt_ctx *ctx, int errno)
>  {
> -	if (ckpt_test_and_set_ctx_kflag(ctx, CKPT_CTX_ERROR))
> +	if (!ckpt_test_and_set_ctx_kflag(ctx, CKPT_CTX_ERROR))
>  		ctx->errno = errno;
>  }
>  
