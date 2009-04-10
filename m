From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 05/30] nsproxy: add create_nsproxy()
Date: Fri, 10 Apr 2009 17:33:18 -0500
Message-ID: <20090410223318.GB13873__45192.1942331412$1239402957$gmane$org@us.ibm.com>
References: <20090410023413.GF27788@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090410023413.GF27788-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> clone_nsproxy() does useless copying of old nsproxy -- every pointer
> will be rewritten to new ns or to old ns.
> 
> Remove copying, rename clone_nsproxy(), it will be used by C/R code
> to create fresh nsproxy on restart.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
> 
>  kernel/nsproxy.c |   19 +++++++------------
>  1 file changed, 7 insertions(+), 12 deletions(-)
> 
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -26,19 +26,14 @@ static struct kmem_cache *nsproxy_cachep;
> 
>  struct nsproxy init_nsproxy = INIT_NSPROXY(init_nsproxy);
> 
> -/*
> - * creates a copy of "orig" with refcount 1.
> - */
> -static inline struct nsproxy *clone_nsproxy(struct nsproxy *orig)
> +static inline struct nsproxy *create_nsproxy(void)
>  {
> -	struct nsproxy *ns;
> +	struct nsproxy *nsproxy;
> 
> -	ns = kmem_cache_alloc(nsproxy_cachep, GFP_KERNEL);
> -	if (ns) {
> -		memcpy(ns, orig, sizeof(struct nsproxy));
> -		atomic_set(&ns->count, 1);
> -	}
> -	return ns;
> +	nsproxy = kmem_cache_alloc(nsproxy_cachep, GFP_KERNEL);
> +	if (nsproxy)
> +		atomic_set(&nsproxy->count, 1);
> +	return nsproxy;
>  }
> 
>  /*
> @@ -52,7 +47,7 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
>  	struct nsproxy *new_nsp;
>  	int err;
> 
> -	new_nsp = clone_nsproxy(tsk->nsproxy);
> +	new_nsp = create_nsproxy();
>  	if (!new_nsp)
>  		return ERR_PTR(-ENOMEM);
