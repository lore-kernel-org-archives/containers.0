From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/3] Set the CHECKPOINTED flag on objects before calling
	checkpoint
Date: Tue, 25 Aug 2009 01:53:43 -0400
Message-ID: <4A937C67.20603@librato.com>
References: <1251133918-8117-1-git-send-email-danms@us.ibm.com>
	<1251133918-8117-2-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1251133918-8117-2-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Right, added.

Dan Smith wrote:
> This helps prevent infinite recursion where the checkpoint() operation on an
> object could potentially result in another checkpoint() of itself.
> 
> UNIX sockets would easily encounter this when we call checkpoint on all
> related sockets, which would in turn try to checkpoint us again.
> 
> 
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/objhash.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
> index dc0a10a..019077b 100644
> --- a/checkpoint/objhash.c
> +++ b/checkpoint/objhash.c
> @@ -677,9 +677,8 @@ int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
>  
>  		/* invoke callback to actually dump the state */
>  		BUG_ON(!obj->ops->checkpoint);
> -		ret = obj->ops->checkpoint(ctx, ptr);
> -
>  		obj->flags |= CKPT_OBJ_CHECKPOINTED;
> +		ret = obj->ops->checkpoint(ctx, ptr);
>  	}
>  
>  	obj->flags |= CKPT_OBJ_VISITED;
