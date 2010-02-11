From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] c/r: restart to handle checkpoint images lacking {uts,
	ipc}-ns
Date: Thu, 11 Feb 2010 13:47:31 -0500
Message-ID: <4B7450C3.7050104@cs.columbia.edu>
References: <1265913760-26854-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1265913760-26854-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


An innocent ctrl-t misspelled Dan's email :(
Resending with the proper address.

Oren.

Oren Laadan wrote:
> A checkpoint taken on a kernel without CONFIG_{IPC,UTS}_NS will leave
> the corresponding objref field in the nsproxy header untouched, and
> therefore it will remain zero.
> 
> This patch ensures that do_restore_ns() gracefully handles this by
> borrowing from the nsproxy of the root-task.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> ---
>  kernel/nsproxy.c |   71 +++++++++++++++++++++++++++++------------------------
>  1 files changed, 39 insertions(+), 32 deletions(-)
> 
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index b0e71f2..cfef7bc 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -312,54 +312,61 @@ static struct nsproxy *do_restore_ns(struct ckpt_ctx *ctx)
>  	struct nsproxy *nsproxy = NULL;
>  	struct uts_namespace *uts_ns;
>  	struct ipc_namespace *ipc_ns;
> +	struct mnt_namespace *mnt_ns;
> +	struct net *net_ns;
>  	int ret;
>  
>  	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_NS);
>  	if (IS_ERR(h))
>  		return (struct nsproxy *) h;
>  
> -	ret = -EINVAL;
> -	if (h->uts_objref <= 0 ||
> -	    h->ipc_objref <= 0)
> -		goto out;
> -
> -	uts_ns = ckpt_obj_fetch(ctx, h->uts_objref, CKPT_OBJ_UTS_NS);
> +	if (h->uts_objref == 0)
> +		uts_ns = ctx->root_nsproxy->uts_ns;
> +	else
> +		uts_ns = ckpt_obj_fetch(ctx, h->uts_objref, CKPT_OBJ_UTS_NS);
>  	if (IS_ERR(uts_ns)) {
>  		ret = PTR_ERR(uts_ns);
>  		goto out;
>  	}
> -	ipc_ns = ckpt_obj_fetch(ctx, h->ipc_objref, CKPT_OBJ_IPC_NS);
> +
> +	if (h->ipc_objref == 0)
> +		ipc_ns = ctx->root_nsproxy->ipc_ns;
> +	else
> +		ipc_ns = ckpt_obj_fetch(ctx, h->ipc_objref, CKPT_OBJ_IPC_NS);
>  	if (IS_ERR(ipc_ns)) {
>  		ret = PTR_ERR(ipc_ns);
>  		goto out;
>  	}
>  
> -#if defined(COFNIG_UTS_NS) || defined(CONFIG_IPC_NS)
> -	ret = -ENOMEM;
> -	nsproxy = create_nsproxy();
> -	if (!nsproxy)
> -		goto out;
> +	mnt_ns = ctx->root_nsproxy->mnt_ns;
> +	net_ns = ctx->root_nsproxy->net_ns;
> +
> +	if (uts_ns == current->nsproxy->uts_ns &&
> +	    ipc_ns == current->nsproxy->ipc_ns &&
> +	    mnt_ns == current->nsproxy->mnt_ns &&
> +	    net_ns == current->nsproxy->net_ns) {
> +		/* all xxx-ns are identical: reuse nsproxy */
> +		nsproxy = current->nsproxy;
> +		get_nsproxy(nsproxy);
> +	} else {
> +		ret = -ENOMEM;
> +		nsproxy = create_nsproxy();
> +		if (!nsproxy)
> +			goto out;
> +
> +		get_uts_ns(uts_ns);
> +		nsproxy->uts_ns = uts_ns;
> +		get_ipc_ns(ipc_ns);
> +		nsproxy->ipc_ns = ipc_ns;
> +		get_mnt_ns(mnt_ns);
> +		nsproxy->mnt_ns = mnt_ns;
> +		get_net(net_ns);
> +		nsproxy->net_ns = net_ns;
> +
> +		get_pid_ns(current->nsproxy->pid_ns);
> +		nsproxy->pid_ns = current->nsproxy->pid_ns;
> +	}
>  
> -	get_uts_ns(uts_ns);
> -	nsproxy->uts_ns = uts_ns;
> -	get_ipc_ns(ipc_ns);
> -	nsproxy->ipc_ns = ipc_ns;
> -
> -	get_pid_ns(current->nsproxy->pid_ns);
> -	nsproxy->pid_ns = current->nsproxy->pid_ns;
> -	get_mnt_ns(current->nsproxy->mnt_ns);
> -	nsproxy->mnt_ns = current->nsproxy->mnt_ns;
> -	get_net(current->nsproxy->net_ns);
> -	nsproxy->net_ns = current->nsproxy->net_ns;
> -#else
> -	nsproxy = current->nsproxy;
> -	get_nsproxy(nsproxy);
> -
> -	BUG_ON(nsproxy->uts_ns != uts_ns);
> -	BUG_ON(nsproxy->ipc_ns != ipc_ns);
> -#endif
> -
> -	/* TODO: add more namespaces here */
>  	ret = 0;
>   out:
>  	if (ret < 0)
