From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH RFC] refuse checkpoint of file with f_owner
Date: Tue, 22 Dec 2009 19:49:10 -0500
Message-ID: <4B316906.20501@cs.columbia.edu>
References: <20091216212258.GA31602@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091216212258.GA31602-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


Also for v19-rc3.

Serge E. Hallyn wrote:
> ... because we don't yet support its restore.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/files.c |   12 ++++++++++++
>  1 files changed, 12 insertions(+), 0 deletions(-)
> 
> diff --git a/checkpoint/files.c b/checkpoint/files.c
> index c8e8d7f..cac5236 100644
> --- a/checkpoint/files.c
> +++ b/checkpoint/files.c
> @@ -261,6 +261,7 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
>  	struct fdtable *fdt;
>  	int objref, ret;
>  	int coe = 0;	/* avoid gcc warning */
> +	pid_t pid;
>  
>  	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_FILE_DESC);
>  	if (!h)
> @@ -283,6 +284,17 @@ static int checkpoint_file_desc(struct ckpt_ctx *ctx,
>  	}
>  
>  	/*
> +	 * TODO: Implement c/r of fowner and f_sigio.  Should be
> +	 * trivial, but for now we just refuse its checkpoint
> +	 */
> +	pid = f_getown(file);
> +	if (pid) {
> +		ret = -EBUSY;
> +		ckpt_err(ctx, ret, "%(T)fd %d has an owner (%d)\n", fd);
> +		goto out;
> +	}
> +
> +	/*
>  	 * if seen first time, this will add 'file' to the objhash, keep
>  	 * a reference to it, dump its state while at it.
>  	 */
