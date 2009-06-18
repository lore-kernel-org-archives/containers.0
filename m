From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: fix compilation with CONFIG_UTS_NS=n
Date: Thu, 18 Jun 2009 12:46:25 -0400
Message-ID: <4A3A6F61.5030401@cs.columbia.edu>
References: <20090617001723.GA9452@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090617001723.GA9452-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


I think it's useful to be able to

1) checkpoint on a system with !CONFIG_UTS_NS,  and -
2) checkpoint on a system with CONFIG_UTS_NS and restart on a
system with !CONFIG_UTS_NS (as long as all tasks in the image
share a single uts-ns)

So I moved the code to checkpoint/namespace.c where it compiles
either way.

Oren

Serge E. Hallyn wrote:
> It looks like Oren wanted ns c/r to "sort of work" with CONFIG_UTS_NS=n
> but kernel/utsname.c is not compiled if CONFIG_UTS_NS=n.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  include/linux/checkpoint.h |    5 +++++
>  kernel/utsname.c           |   13 -------------
>  2 files changed, 5 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
> index c2f04c5..ef4fc33 100644
> --- a/include/linux/checkpoint.h
> +++ b/include/linux/checkpoint.h
> @@ -136,8 +136,13 @@ extern int checkpoint_ns(struct ckpt_ctx *ctx, void *ptr);
>  extern void *restore_ns(struct ckpt_ctx *ctx);
>  
>  /* uts-ns */
> +#ifdef CONFIG_UTS_NS
>  extern int checkpoint_uts_ns(struct ckpt_ctx *ctx, void *ptr);
>  extern void *restore_uts_ns(struct ckpt_ctx *ctx);
> +#else
> +#define checkpoint_uts_ns checkpoint_bad
> +#define restore_uts_ns restore_bad
> +#endif
>  
>  /* ipc-ns */
>  #ifdef CONFIG_SYSVIPC
> diff --git a/kernel/utsname.c b/kernel/utsname.c
> index 76f9966..5c12ebb 100644
> --- a/kernel/utsname.c
> +++ b/kernel/utsname.c
> @@ -130,11 +130,6 @@ static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
>  	    h->domainname_len > sizeof(uts_ns->name.domainname))
>  		goto out;
>  
> -	/*
> -	 * If !CONFIG_UTS_NS, do not restore the global uts state, as
> -	 * it is used by other processes.
> -	 */
> -#ifdef CONFIG_UTS_NS
>  	ret = -ENOMEM;
>  	uts_ns = create_uts_ns();
>  	if (!uts_ns)
> @@ -153,14 +148,6 @@ static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
>  	up_read(&uts_sem);
>  	if (ret < 0)
>  		goto out;
> -#else
> -	ret = -EEXIST;
> -	/* complain if image contains multiple namespaces */
> -	if (ctx->stats.uts_ns)
> -		goto out;
> -	uts_ns = current->nsproxy->uts_ns;
> -	get_uts_ns(uts_ns);
> -#endif
>  
>  	ctx->stats.uts_ns++;
>   out:
