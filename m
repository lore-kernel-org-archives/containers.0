From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/9] Introduce context structure needed
	during	checkpointing/restart
Date: Wed, 03 Sep 2008 16:13:08 +0200
Message-ID: <48BE9B74.7010600__24314.5779510543$1220453363$gmane$org@fr.ibm.com>
References: <1220439476-16465-1-git-send-email-major@openvz.org>	<1220439476-16465-2-git-send-email-major@openvz.org>	<1220439476-16465-3-git-send-email-major@openvz.org>
	<1220439476-16465-4-git-send-email-major@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1220439476-16465-4-git-send-email-major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org


> +void context_release(struct cpt_context *ctx)
> +{
> +	ctx->ctx_state = CPT_CTX_ERROR;
> +
> +	if (ctx->file)
> +		fput(ctx->file);
> +	kfree(ctx);
> +}
> +
> +static void context_put(struct cpt_context *ctx)
> +{
> +	if (!--ctx->refcount)
> +		context_release(ctx);
> +}
> +
>  static int checkpoint(pid_t pid, int fd, unsigned long flags)
>  {
> -	return -ENOSYS; 
> +	struct file *file;
> +	struct cpt_context *ctx;
> +	int err;
> +
> +	err = -EBADF;
> +	file = fget(fd);
> +	if (!file)
> +		goto out;
> +
> +	err = -ENOMEM;
> +	ctx = context_alloc();
> +	if (!ctx)
> +		goto out_file;
> +
> +	ctx->file = file;
> +	ctx->ctx_state = CPT_CTX_DUMPING;
> +
> +	/* checkpoint */
> +	err = -ENOSYS;
> +
> +	context_put(ctx);
> +
> +out_file:
> +	fput(file);
> +out:
> +	return err; 
>  }

it looks like fput(file) is done twice in checkpoint() and context_release() ?

C.
