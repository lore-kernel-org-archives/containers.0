From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] fix sysvipc=n compile
Date: Mon, 15 Mar 2010 17:51:54 -0400
Message-ID: <4B9EABFA.4030307@cs.columbia.edu>
References: <20100315194151.GA24909@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100315194151.GA24909-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Pushed this and the recent patches (without net-ns) to ckpt-v20-rc2.
Unless we hit new troubles with this one, I'll fold it and send out.

Oren.

Serge E. Hallyn wrote:
> checkpoint_bad and restore_bad no longer exist, use NULL.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/checkpoint.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index 8053ca4..792b523 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -215,8 +215,8 @@ extern void *restore_ipc_ns(struct ckpt_ctx *ctx);
>  extern int ckpt_collect_ipc_ns(struct ckpt_ctx *ctx,
>  			       struct ipc_namespace *ipc_ns);
>  #else
> -#define checkpoint_ipc_ns  checkpoint_bad
> -#define restore_ipc_ns  restore_bad
> +#define checkpoint_ipc_ns  NULL
> +#define restore_ipc_ns  NULL
>  static inline int ckpt_collect_ipc_ns(struct ckpt_ctx *ctx,
>  				      struct ipc_namespace *ipc_ns)
>  {
