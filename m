From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: uts: don't deref h after freeing
Date: Wed, 24 Jun 2009 12:54:09 -0400
Message-ID: <4A425A31.4010902@cs.columbia.edu>
References: <20090623193702.GA25291@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090623193702.GA25291-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nathan T Lynch <natlynch-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


I actually fixed it differently:  I observed that the kernel
constants in question need only be saved once for the entire
checkpoint, rather than per object in which they are used.

So I added a sub-header "ckpt_hdr_constants" to the header that
is filled at checkpoint. Once these values are confirmed at
restart, the remaining code can safely use the kernel constants
directly.

This is fixed in the latest ckpt-v16-dev.

Oren.

Serge E. Hallyn wrote:
> Don't pass h->xyz_len etc as lengths after freeing h!  Send
> the result of sizeof(name->xyz) directly.
> 
> Changelog: Jun 23: resend with new description which accurately
> 	describes what is being fixed (figured out by Nathan Lynch).
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/namespace.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/checkpoint/namespace.c b/checkpoint/namespace.c
> index 5726acb..8206aee 100644
> --- a/checkpoint/namespace.c
> +++ b/checkpoint/namespace.c
> @@ -46,22 +46,22 @@ static int do_checkpoint_uts_ns(struct ckpt_ctx *ctx,
>  		return ret;
>  
>  	down_read(&uts_sem);
> -	ret = ckpt_write_string(ctx, name->sysname, h->sysname_len);
> +	ret = ckpt_write_string(ctx, name->sysname, sizeof(name->sysname));
>  	if (ret < 0)
>  		goto up;
> -	ret = ckpt_write_string(ctx, name->nodename, h->nodename_len);
> +	ret = ckpt_write_string(ctx, name->nodename, sizeof(name->nodename));
>  	if (ret < 0)
>  		goto up;
> -	ret = ckpt_write_string(ctx, name->release, h->release_len);
> +	ret = ckpt_write_string(ctx, name->release, sizeof(name->release));
>  	if (ret < 0)
>  		goto up;
> -	ret = ckpt_write_string(ctx, name->version, h->version_len);
> +	ret = ckpt_write_string(ctx, name->version, sizeof(name->version));
>  	if (ret < 0)
>  		goto up;
> -	ret = ckpt_write_string(ctx, name->machine, h->machine_len);
> +	ret = ckpt_write_string(ctx, name->machine, sizeof(name->machine));
>  	if (ret < 0)
>  		goto up;
> -	ret = ckpt_write_string(ctx, name->domainname, h->domainname_len);
> +	ret = ckpt_write_string(ctx, name->domainname, sizeof(name->domainname));
>   up:
>  	up_read(&uts_sem);
>  	return ret;
