From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [C/R PATCH] reject checkpoint of fd subject to F_SETSIG
Date: Mon, 2 May 2011 08:18:24 -0500
Message-ID: <20110502131824.GC9375@mail.hallyn.com>
References: <1304112454-24641-1-git-send-email-ntl@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1304112454-24641-1-git-send-email-ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> Similar to our handling of fds that have been subject to F_SETOWN,
> detect when an fd has had its f_owner->signum changed from the
> default.
> 
> Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>

Hey Nathan,

Can you give more motivation for this?  Do you just feel that it
isn't worth the risk of mis-coding the check at restart?

For safety check, what about forcing such a task to be restarted
in a private pidns?

I'm not nacking it, don't mind it going in temporarily, but this
commit message makes it sound like using F_SETSIG is an application
error.

thanks,
-serge

> ---
>  fs/checkpoint.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/checkpoint.c b/fs/checkpoint.c
> index fd539c5..bf4d2d4 100644
> --- a/fs/checkpoint.c
> +++ b/fs/checkpoint.c
> @@ -265,6 +265,7 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
>  	struct file *file = NULL;
>  	struct fdtable *fdt;
>  	int objref, ret;
> +	int signum;
>  	int coe = 0;	/* avoid gcc warning */
>  	pid_t pid;
>  
> @@ -311,6 +312,13 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
>  		goto out;
>  	}
>  
> +	signum = ACCESS_ONCE(file->f_owner.signum);
> +	if (signum != 0) {
> +		ret = -EBUSY;
> +		ckpt_err(ctx, ret, "%(T)fd %d has a signal set (%d)\n", fd, signum);
> +		goto out;
> +	}
> +
>  	/*
>  	 * if seen first time, this will add 'file' to the objhash, keep
>  	 * a reference to it, dump its state while at it.
> -- 
> 1.7.4.4
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
