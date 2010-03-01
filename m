From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH linux-cr] nsproxy: record ambient namespaces
Date: Mon, 01 Mar 2010 14:20:14 -0500
Message-ID: <4B8C136E.5060704@cs.columbia.edu>
References: <20100225225641.GA9386@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100225225641.GA9386-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Applied.

Serge E. Hallyn wrote:
> The nsproxy restore path recognizes that an objref of 0 for
> ipc or uts ns means don't unshare it.  But the checkpoint side
> forgot to write down 0 when the ipc or uts ns isn't unshared!
> 
> Fix that.
> 
> To test, run a program with a private pidns but shared utsns
> which does
> 
> 	sleep(5);
> 	sethostname("serge", 6);
> 
> checkpoint it, reset your hostname (if you let the program
> complete), then restart the program: without this patch, it
> will not reset your hostname.  It should, and with this patch
> it will.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/nsproxy.c |   19 +++++++++++++------
>  1 files changed, 13 insertions(+), 6 deletions(-)
> 
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index 0da0d83..dcb502c 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -280,13 +280,20 @@ static int do_checkpoint_ns(struct ckpt_ctx *ctx, struct nsproxy *nsproxy)
>  	if (!h)
>  		return -ENOMEM;
>  
> -	ret = checkpoint_obj(ctx, nsproxy->uts_ns, CKPT_OBJ_UTS_NS);
> -	if (ret <= 0)
> -		goto out;
> +	ret = 0;
> +	if (nsproxy->uts_ns != ctx->root_nsproxy->uts_ns) {
> +		ret = checkpoint_obj(ctx, nsproxy->uts_ns, CKPT_OBJ_UTS_NS);
> +		if (ret <= 0)
> +			goto out;
> +	}
>  	h->uts_objref = ret;
> -	ret = checkpoint_obj(ctx, nsproxy->ipc_ns, CKPT_OBJ_IPC_NS);
> -	if (ret < 0)
> -		goto out;
> +
> +	ret = 0;
> +	if (nsproxy->ipc_ns != ctx->root_nsproxy->ipc_ns) {
> +		ret = checkpoint_obj(ctx, nsproxy->ipc_ns, CKPT_OBJ_IPC_NS);
> +		if (ret < 0)
> +			goto out;
> +	}
>  	h->ipc_objref = ret;
>  
>  	/* FIXME: for now, only marked visited to pacify leaks */
