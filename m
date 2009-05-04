From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] utsns: extract creeate_uts_ns()
Date: Mon, 4 May 2009 15:05:01 -0500
Message-ID: <20090504200501.GA29833__34878.5328249962$1241467596$gmane$org@us.ibm.com>
References: <20090503232510.GA16631@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090503232510.GA16631-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> create_uts_ns() will be used by C/R to create fresh uts_ns.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

thanks,
-serge

> ---
>  kernel/utsname.c |   13 +++++++++++--
>  1 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/utsname.c b/kernel/utsname.c
> index 815237a..8a82b4b 100644
> --- a/kernel/utsname.c
> +++ b/kernel/utsname.c
> @@ -15,6 +15,16 @@
>  #include <linux/err.h>
>  #include <linux/slab.h>
> 
> +static struct uts_namespace *create_uts_ns(void)
> +{
> +	struct uts_namespace *uts_ns;
> +
> +	uts_ns = kmalloc(sizeof(struct uts_namespace), GFP_KERNEL);
> +	if (uts_ns)
> +		kref_init(&uts_ns->kref);
> +	return uts_ns;
> +}
> +
>  /*
>   * Clone a new ns copying an original utsname, setting refcount to 1
>   * @old_ns: namespace to clone
> @@ -24,14 +34,13 @@ static struct uts_namespace *clone_uts_ns(struct uts_namespace *old_ns)
>  {
>  	struct uts_namespace *ns;
> 
> -	ns = kmalloc(sizeof(struct uts_namespace), GFP_KERNEL);
> +	ns = create_uts_ns();
>  	if (!ns)
>  		return ERR_PTR(-ENOMEM);
> 
>  	down_read(&uts_sem);
>  	memcpy(&ns->name, &old_ns->name, sizeof(ns->name));
>  	up_read(&uts_sem);
> -	kref_init(&ns->kref);
>  	return ns;
>  }
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
