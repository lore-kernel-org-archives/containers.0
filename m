From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: uts: don't pass an unsigned var as a signed int
Date: Fri, 19 Jun 2009 23:27:13 -0500
Message-ID: <m3prczfs2m.fsf@pobox.com>
References: <20090619203719.GA30093@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090619203719.GA30093-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Serge E. Hallyn's message
	of "Fri\, 19 Jun 2009 15\:37\:19 -0500")
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

"Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:

> Else my checkpoing image gets reeeaallly huge.  Just passing the
> result of sizeof() however does the right thing.
>
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/namespace.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)

But right above the code you're changing we have:

	h->sysname_len = sizeof(name->sysname);
	h->nodename_len = sizeof(name->nodename);
	h->release_len = sizeof(name->release);
	h->version_len = sizeof(name->version);
	h->machine_len = sizeof(name->machine);
	h->domainname_len = sizeof(name->domainname);

Your patch shouldn't change any behavior.  What gives?

(PS: ckpt_write_string and friends should take a size_t or some other
unsigned type for len.)


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
