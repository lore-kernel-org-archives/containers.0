From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] make cr depend on all namespaces
Date: Mon, 15 Mar 2010 17:45:01 -0400
Message-ID: <4B9EAA5D.1080802@cs.columbia.edu>
References: <20100315200559.GA25911@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100315200559.GA25911-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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



Serge E. Hallyn wrote:
> This should let us get rid of some ifdefed code and reduce
> chances for bad config combinations.  There's really no reason
> to support it.

I disagree.

You are right that this will reduce the changes of bad config
combinations.

However, it will also introduce some restrictions on the kernel
config which are unnecessary. Some people may not want to have
all namespaces configured.

Note that the namespaces are independent in the sense that we
don't need to test all combination of all namespaces - instead,
I consider turning on/off one at a time to be safe enough.

(FWIW, is it because you only wanted to show a point that you
only remove UTS_NS ifdefs ?)

Oren.

> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/Kconfig     |    5 +++++
>  checkpoint/namespace.c |   10 ----------
>  2 files changed, 5 insertions(+), 10 deletions(-)
> 
> diff --git a/checkpoint/Kconfig b/checkpoint/Kconfig
> index 4a2c845..549668e 100644
> --- a/checkpoint/Kconfig
> +++ b/checkpoint/Kconfig
> @@ -9,6 +9,11 @@ config DEFERQUEUE
>  config CHECKPOINT
>  	bool "Checkpoint/restart (EXPERIMENTAL)"
>  	depends on CHECKPOINT_SUPPORT && EXPERIMENTAL
> +	depends on UTS_NS
> +	depends on USER_NS
> +	depends on PID_NS
> +	depends on NET_NS
> +	depends on DEVPTS_MULTIPLE_INSTANCES
>  	depends on CGROUP_FREEZER
>  	select DEFERQUEUE
>  	help
> diff --git a/checkpoint/namespace.c b/checkpoint/namespace.c
> index 4b3ac5a..6389dbd 100644
> --- a/checkpoint/namespace.c
> +++ b/checkpoint/namespace.c
> @@ -63,7 +63,6 @@ static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
>  	if (IS_ERR(h))
>  		return (struct uts_namespace *) h;
>  
> -#ifdef CONFIG_UTS_NS
>  	uts_ns = create_uts_ns();
>  	if (!uts_ns) {
>  		uts_ns = ERR_PTR(-ENOMEM);
> @@ -78,15 +77,6 @@ static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
>  	memcpy(name->machine, h->machine, sizeof(name->machine));
>  	memcpy(name->domainname, h->domainname, sizeof(name->domainname));
>  	up_read(&uts_sem);
> -#else
> -	/* complain if image contains multiple namespaces */
> -	if (ctx->stats.uts_ns) {
> -		uts_ns = ERR_PTR(-EEXIST);
> -		goto out;
> -	}
> -	uts_ns = current->nsproxy->uts_ns;
> -	get_uts_ns(uts_ns);
> -#endif
>  
>  	ctx->stats.uts_ns++;
>   out:
