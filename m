From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] clean up checkpoint_task_objs
Date: Tue, 22 Dec 2009 19:47:30 -0500
Message-ID: <4B3168A2.9080102@cs.columbia.edu>
References: <20091214194145.GA21259@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091214194145.GA21259-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Queued for v19-rc3, thanks.


Serge E. Hallyn wrote:
> Make the flow more regular.  With the existing code, one can barely
> find the call to checkpoint_task_obj_ns() even if looking for it!
> 
> This is on top of the task->fs c/r patch I sent last week.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/process.c |   17 ++++++++++++-----
>  1 files changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/checkpoint/process.c b/checkpoint/process.c
> index 603bbf4..bef909a 100644
> --- a/checkpoint/process.c
> +++ b/checkpoint/process.c
> @@ -247,12 +247,17 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
>  
>  	ret = checkpoint_task_creds(ctx, t);
>  	ckpt_debug("cred: objref %d\n", ret);
> -	if (!ret) {
> -		ret = checkpoint_task_ns(ctx, t);
> -		ckpt_debug("ns: objref %d\n", ret);
> +	if (ret < 0) {
> +		ckpt_err(ctx, ret, "%(T)process credentials\n");
> +		return ret;
>  	}
> -	if (ret < 0)
> +
> +	ret = checkpoint_task_ns(ctx, t);
> +	ckpt_debug("ns: objref %d\n", ret);
> +	if (ret < 0) {
> +		ckpt_err(ctx, ret, "%(T)process namespaces\n");
>  		return ret;
> +	}
>  
>  	fs_objref = checkpoint_get_task_fs(ctx, t);
>  	if (fs_objref < 0) {
> @@ -291,8 +296,10 @@ static int checkpoint_task_objs(struct ckpt_ctx *ctx, struct task_struct *t)
>  	signal_objref = ckpt_obj_lookup_add(ctx, t->signal,
>  					    CKPT_OBJ_SIGNAL, &first);
>  	ckpt_debug("signal: objref %d\n", signal_objref);
> -	if (signal_objref < 0)
> +	if (signal_objref < 0) {
> +		ckpt_err(ctx, signal_objref, "%(T)process signals\n");
>  		return signal_objref;
> +	}
>  
>  	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_TASK_OBJS);
>  	if (!h)
