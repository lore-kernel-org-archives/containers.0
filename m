From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 07/38] pidns 1/2: make create_pid_namespace() accept
	parent pidns
Date: Sun, 24 May 2009 17:44:46 -0500
Message-ID: <20090524224446.GC12734__46350.5803527825$1243204923$gmane$org@hallyn.com>
References: <1242968132-1044-1-git-send-email-adobriyan@gmail.com>
	<1242968132-1044-7-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1242968132-1044-7-git-send-email-adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Alexey Dobriyan (adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> create_pid_namespace() creates everything, but caller has to assign parent
> pidns by hand, which is unnatural. At the moment of call new ->level has
> to be taken from somewhere and parent pidns is already available.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Reviewed-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

(I actually did so on both this and the next one, which are both quite
nice, on May 08)

> ---
>  kernel/pid_namespace.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
> index 2d1001b..495d5de 100644
> --- a/kernel/pid_namespace.c
> +++ b/kernel/pid_namespace.c
> @@ -67,9 +67,10 @@ err_alloc:
>  	return NULL;
>  }
>  
> -static struct pid_namespace *create_pid_namespace(unsigned int level)
> +static struct pid_namespace *create_pid_namespace(struct pid_namespace *parent_pid_ns)
>  {
>  	struct pid_namespace *ns;
> +	unsigned int level = parent_pid_ns->level + 1;
>  	int i;
>  
>  	ns = kmem_cache_zalloc(pid_ns_cachep, GFP_KERNEL);
> @@ -86,6 +87,7 @@ static struct pid_namespace *create_pid_namespace(unsigned int level)
>  
>  	kref_init(&ns->kref);
>  	ns->level = level;
> +	ns->parent = get_pid_ns(parent_pid_ns);
>  
>  	set_bit(0, ns->pidmap[0].page);
>  	atomic_set(&ns->pidmap[0].nr_free, BITS_PER_PAGE - 1);
> @@ -125,9 +127,7 @@ struct pid_namespace *copy_pid_ns(unsigned long flags, struct pid_namespace *old
>  	if (flags & CLONE_THREAD)
>  		goto out_put;
>  
> -	new_ns = create_pid_namespace(old_ns->level + 1);
> -	if (!IS_ERR(new_ns))
> -		new_ns->parent = get_pid_ns(old_ns);
> +	new_ns = create_pid_namespace(old_ns);
>  
>  out_put:
>  	put_pid_ns(old_ns);
> -- 
> 1.5.6.5
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
