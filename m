From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 07/30] netns: extract net_create()
Date: Fri, 10 Apr 2009 17:56:36 -0500
Message-ID: <20090410225636.GD13873__35668.2411082604$1239404481$gmane$org@us.ibm.com>
References: <20090410023448.GH27788@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090410023448.GH27788-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
> net_create() will be used by C/R code to create fresh netns on restart.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Although this ends up making a new assumption that setup_net(), and
therefore the pernet_ops->init() functions, do not return error > 0.
There's nothing actually stopping that (outside of code review, but
there appears to be no comment anywhere saying that's uncooth).

If it returns > 0, then we return the ns as though it were valid, but
don't add it to the list of namespaces...  Do we care?

-serge

> ---
> 
>  include/net/net_namespace.h |    1 +
>  net/core/net_namespace.c    |   44 ++++++++++++++++++++------------------------
>  2 files changed, 21 insertions(+), 24 deletions(-)
> 
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -107,6 +107,7 @@ static inline struct net *copy_net_ns(unsigned long flags, struct net *net_ns)
>  extern struct list_head net_namespace_list;
> 
>  #ifdef CONFIG_NET_NS
> +struct net *net_create(void);
>  extern void __put_net(struct net *net);
> 
>  static inline struct net *get_net(struct net *net)
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -115,38 +115,34 @@ static void net_free(struct net *net)
>  	kmem_cache_free(net_cachep, net);
>  }
> 
> -struct net *copy_net_ns(unsigned long flags, struct net *old_net)
> +struct net *net_create(void)
>  {
> -	struct net *new_net = NULL;
> -	int err;
> -
> -	if (!(flags & CLONE_NEWNET))
> -		return get_net(old_net);
> -
> -	err = -ENOMEM;
> -	new_net = net_alloc();
> -	if (!new_net)
> -		goto out_err;
> +	struct net *net;
> +	int rv;
> 
> +	net = net_alloc();
> +	if (!net)
> +		return ERR_PTR(-ENOMEM);
>  	mutex_lock(&net_mutex);
> -	err = setup_net(new_net);
> -	if (!err) {
> +	rv = setup_net(net);
> +	if (rv == 0) {
>  		rtnl_lock();
> -		list_add_tail(&new_net->list, &net_namespace_list);
> +		list_add_tail(&net->list, &net_namespace_list);
>  		rtnl_unlock();
>  	}
>  	mutex_unlock(&net_mutex);
> +	if (rv < 0) {
> +		net_free(net);
> +		return ERR_PTR(rv);
> +	}
> +	return net;
> +}
> 
> -	if (err)
> -		goto out_free;
> -out:
> -	return new_net;
> -
> -out_free:
> -	net_free(new_net);
> -out_err:
> -	new_net = ERR_PTR(err);
> -	goto out;
> +struct net *copy_net_ns(unsigned long flags, struct net *old_net)
> +{
> +	if (!(flags & CLONE_NEWNET))
> +		return get_net(old_net);
> +	return net_create();
>  }
> 
>  static void cleanup_net(struct work_struct *work)
