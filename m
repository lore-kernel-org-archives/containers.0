From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: don't unlock ipc before freeing
Date: Fri, 29 May 2009 17:37:35 -0400
Message-ID: <4A20559F.5020807@cs.columbia.edu>
References: <20090529212132.GA12973@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090529212132.GA12973-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


It's in.

Serge E. Hallyn wrote:
> Sorry, this should have been a part of the analogous sem fix.
> 
>     [re commit 615744ad97 ... c/r: support share-memory sysv-ipc]
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  ipc/checkpoint_msg.c |    4 ++--
>  ipc/checkpoint_shm.c |    4 ++--
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/ipc/checkpoint_msg.c b/ipc/checkpoint_msg.c
> index a988a9e..fb1a61e 100644
> --- a/ipc/checkpoint_msg.c
> +++ b/ipc/checkpoint_msg.c
> @@ -348,12 +348,12 @@ int restore_ipc_msg(struct ckpt_ctx *ctx)
>  	msq->q_qnum = h->q_qnum;
>  
>  	ret = load_ipc_msg_hdr(ctx, h, msq);
> -	ipc_unlock(perms);
>  
>  	if (ret < 0) {
>  		ckpt_debug("msq: need to remove (%d)\n", ret);
>  		freeque(current->nsproxy->ipc_ns, perms);
> -	}
> +	} else
> +		ipc_unlock(perms);
>  	up_write(&msg_ids->rw_mutex);
>   out:
>  	free_msg_list(&messages);  /* no-op if all ok, else cleanup msgs */
> diff --git a/ipc/checkpoint_shm.c b/ipc/checkpoint_shm.c
> index 713f910..0d8eb14 100644
> --- a/ipc/checkpoint_shm.c
> +++ b/ipc/checkpoint_shm.c
> @@ -239,7 +239,6 @@ int restore_ipc_shm(struct ckpt_ctx *ctx)
>  	get_file(file);
>  
>  	ret = load_ipc_shm_hdr(ctx, h, shp);
> -	ipc_unlock(perms);
>  	if (ret < 0)
>  		goto mutex;
>  
> @@ -253,7 +252,8 @@ int restore_ipc_shm(struct ckpt_ctx *ctx)
>  	if (ret < 0) {
>  		ckpt_debug("shm: need to remove (%d)\n", ret);
>  		do_shm_rmid(current->nsproxy->ipc_ns, perms);
> -	}
> +	} else
> +		ipc_unlock(perms);
>  	up_write(&shm_ids->rw_mutex);
>   out:
>  	ckpt_hdr_put(ctx, h);
