From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] fix oops in checkpoint/restart error path
Date: Thu, 16 Oct 2008 23:53:36 -0400
Message-ID: <48F80C40.2030401@cs.columbia.edu>
References: <20081016225128.43636F12@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081016225128.43636F12@kernel>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Dave -

You must have tested on the wrong version; this line already appears
in the recent patch, in particular in the one that you re-posted !

Also, your reposted the patch-set without the fix to the FPU state.
It's gonna crash as soon as someone tries to use a float variable.

Patience ...

Oren.

Dave Hansen wrote:
> The 'ctx' is kzmalloc()'d.  So, all its contents are zeroed.
> It has a list_head, which is walked during cr_ctx_free().
> list_for_each() on a non-initalized list_head is bad.  Whoops.
> 
> 
> Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> ---
> 
>  linux-2.6.git-dave/checkpoint/sys.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff -puN checkpoint/sys.c~fix-cr-oops0 checkpoint/sys.c
> --- linux-2.6.git/checkpoint/sys.c~fix-cr-oops0	2008-10-16 15:48:18.000000000 -0700
> +++ linux-2.6.git-dave/checkpoint/sys.c	2008-10-16 15:48:35.000000000 -0700
> @@ -179,6 +179,7 @@ struct cr_ctx *cr_ctx_alloc(pid_t pid, i
>  	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
>  	if (!ctx)
>  		return ERR_PTR(-ENOMEM);
> +	INIT_LIST_HEAD(&ctx->pgarr_list);
>  
>  	ctx->file = fget(fd);
>  	if (!ctx->file) {
> diff -L checkpoint/ckpt_mem.h -puN /dev/null /dev/null
> _
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
