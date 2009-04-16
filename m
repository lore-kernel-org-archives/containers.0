From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Take uts_sem during checkpoint and restart
Date: Thu, 16 Apr 2009 11:33:40 -0500
Message-ID: <20090416163340.GB20736@us.ibm.com>
References: <1239897585-19246-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1239897585-19246-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Fix the potential for breakage if our UTS changes during checkpoint or
> restart by grabbing uts_sem during these operations.

Thanks, but I think you're waving too big a stick here.

At checkpoint, you only need the uts_sem right around the reading
(and length-checking) of uts_ns->name.  You're keeping it around
writing into the checkpoint image (and cr_hbuf_get).

At restart, you shouldn't actually need uts_sem - the nsproxy is
not yet available to anyone else, so there is no chance of a
race, right?  Hmm, well maybe I'm being overly optimistic, since restart
is coordinated by userspace which could mess up and somehow run
sethostname(2) while it's supposed to be running sys_restart().
But then sys_restart() wouldn't yet have hooked up the task to the
new nsproxy.

So yeah, I don't think you need uts_sem at restart.

thanks,
-serge

> Cc: orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org
> Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/ckpt_task.c |   12 ++++++++----
>  checkpoint/rstr_task.c |   17 +++++++++++------
>  2 files changed, 19 insertions(+), 10 deletions(-)
> 
> diff --git a/checkpoint/ckpt_task.c b/checkpoint/ckpt_task.c
> index 4d19e31..589f304 100644
> --- a/checkpoint/ckpt_task.c
> +++ b/checkpoint/ckpt_task.c
> @@ -173,14 +173,16 @@ static int cr_write_utsns(struct cr_ctx *ctx, struct uts_namespace *uts_ns)
>  	struct cr_hdr_utsns *hh;
>  	int domainname_len;
>  	int nodename_len;
> -	int ret;
> +	int ret = -ENOMEM;
> +
> + 	down_read(&uts_sem);
> 
>  	h.type = CR_HDR_UTSNS;
>  	h.len = sizeof(*hh);
> 
>  	hh = cr_hbuf_get(ctx, sizeof(*hh));
>  	if (!hh)
> -		return -ENOMEM;
> +		goto out;
> 
>  	nodename_len = strlen(uts_ns->name.nodename) + 1;
>  	domainname_len = strlen(uts_ns->name.domainname) + 1;
> @@ -191,13 +193,15 @@ static int cr_write_utsns(struct cr_ctx *ctx, struct uts_namespace *uts_ns)
>  	ret = cr_write_obj(ctx, &h, hh);
>  	cr_hbuf_put(ctx, sizeof(*hh));
>  	if (ret < 0)
> -		return ret;
> +		goto out;
> 
>  	ret = cr_write_string(ctx, uts_ns->name.nodename, nodename_len);
>  	if (ret < 0)
> -		return ret;
> +		goto out;
> 
>  	ret = cr_write_string(ctx, uts_ns->name.domainname, domainname_len);
> + out:
> +	up_read(&uts_sem);
>  	return ret;
>  }
> 
> diff --git a/checkpoint/rstr_task.c b/checkpoint/rstr_task.c
> index fe5c059..ccf60f8 100644
> --- a/checkpoint/rstr_task.c
> +++ b/checkpoint/rstr_task.c
> @@ -171,32 +171,37 @@ static int cr_read_utsns(struct cr_ctx *ctx)
>  {
>  	struct cr_hdr_utsns *hh;
>  	struct uts_namespace *ns;
> -	int ret;
> +	int ret = -ENOMEM;
> +
> +	down_write(&uts_sem);
> 
>  	hh = cr_hbuf_get(ctx, sizeof(*hh));
>  	if (!hh)
> -		return -ENOMEM;
> +		goto out;
> 
>  	ret = cr_read_obj_type(ctx, hh, sizeof(*hh), CR_HDR_UTSNS);
>  	if (ret < 0)
> -		goto out;
> +		goto out_hbuf;
> 
>  	ret = -EINVAL;
>  	if (hh->nodename_len > sizeof(ns->name.nodename) ||
>  	    hh->domainname_len > sizeof(ns->name.domainname))
> -		goto out;
> +		goto out_hbuf;
> 
>  	ns = current->nsproxy->uts_ns;
> 
>  	memset(ns->name.nodename, 0, sizeof(ns->name.nodename));
>  	ret = cr_read_string(ctx, ns->name.nodename, hh->nodename_len);
>  	if (ret < 0)
> -		goto out;
> +		goto out_hbuf;
> 
>  	memset(ns->name.domainname, 0, sizeof(ns->name.domainname));
>  	ret = cr_read_string(ctx, ns->name.domainname, hh->domainname_len);
> +
> + out_hbuf:
> + 	cr_hbuf_put(ctx, sizeof(*hh));
>   out:
> -	cr_hbuf_put(ctx, sizeof(*hh));
> +	up_write(&uts_sem);
>  	return ret;
>  }
> 
> -- 
> 1.5.6.3
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
