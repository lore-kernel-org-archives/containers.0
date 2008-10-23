From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: External checkpoint patch
Date: Thu, 23 Oct 2008 09:51:13 +0200
Message-ID: <49002CF1.3070505@fr.ibm.com>
References: <1224612971.1848.193.camel@nimitz>
	<Pine.LNX.4.64.0810211857140.22085@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0810211857140.22085-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Dave Hansen <dave-gkUM19QKKo4@public.gmane.org>
List-Id: containers.vger.kernel.org

minor issue,


> -struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
> +static struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
>  {
>  	struct cr_ctx *ctx;
> +	int err;
> 
>  	ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
>  	if (!ctx)
>  		return ERR_PTR(-ENOMEM);

with the err goto, you're calling cr_ctx_free() in a few places where
ctx is partially initialized. you should at least do :

	INIT_LIST_HEAD(&ctx->pgarr_list);

right after the kzalloc() and probably check the value of ctx->hbuf. 
There might be other issues.

> +	ctx->flags = flags;
> +	ctx->pid = pid;
> +
> +	err = -EBADF;
>  	ctx->file = fget(fd);
> -	if (!ctx->file) {
> -		cr_ctx_free(ctx);
> -		return ERR_PTR(-EBADF);
> -	}
> +	if (!ctx->file)
> +		goto err;
>
> 
> +	err = -ENOMEM;
>  	ctx->hbuf = kmalloc(CR_HBUF_TOTAL, GFP_KERNEL);
> -	if (!ctx->hbuf) {
> -		cr_ctx_free(ctx);
> -		return ERR_PTR(-ENOMEM);
> -	}
> +	if (!ctx->hbuf)
> +		goto err;
> 
> -	if (cr_objhash_alloc(ctx) < 0) {
> -		cr_ctx_free(ctx);
> -		return ERR_PTR(-ENOMEM);
> -	}
> +	if (cr_objhash_alloc(ctx) < 0)
> +		goto err;
> 
>  	/*
>  	 * assume checkpointer is in container's root vfs
> @@ -206,12 +206,13 @@ struct cr_ctx *cr_ctx_alloc(pid_t pid, int fd, unsigned long flags)
> 
>  	INIT_LIST_HEAD(&ctx->pgarr_list);
> 
> -	ctx->pid = pid;
> -	ctx->flags = flags;
> -
>  	ctx->crid = atomic_inc_return(&cr_ctx_count);
> 
>  	return ctx;
> +
> + err:
> +	cr_ctx_free(ctx);
> +	return ERR_PTR(err);
>  }
> 
>  /**

here's a patch for it.

C.

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
---
 checkpoint/sys.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: 2.6.27-lxc/checkpoint/sys.c
===================================================================
--- 2.6.27-lxc.orig/checkpoint/sys.c
+++ 2.6.27-lxc/checkpoint/sys.c
@@ -217,7 +217,8 @@ static void cr_ctx_free(struct cr_ctx *c
 	if (ctx->file)
 		fput(ctx->file);
 
-	kfree(ctx->hbuf);
+	if (ctx->hbuf)
+		kfree(ctx->hbuf);
 
 	if (ctx->vfsroot)
 		path_put(ctx->vfsroot);
@@ -239,6 +240,7 @@ static struct cr_ctx *cr_ctx_alloc(pid_t
 	if (!ctx)
 		return ERR_PTR(-ENOMEM);
 
+	INIT_LIST_HEAD(&ctx->pgarr_list);
 	ctx->flags = flags;
 
 	err = -EBADF;
@@ -265,8 +267,6 @@ static struct cr_ctx *cr_ctx_alloc(pid_t
 	ctx->vfsroot = &ctx->root_task->fs->root;
 	path_get(ctx->vfsroot);
 
-	INIT_LIST_HEAD(&ctx->pgarr_list);
-
 	ctx->crid = atomic_inc_return(&cr_ctx_count);
 
 	return ctx;
