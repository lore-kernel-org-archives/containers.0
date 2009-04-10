From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/30] ipcns: add create_ipc_ns()
Date: Fri, 10 Apr 2009 17:29:16 -0500
Message-ID: <20090410222916.GA13873__4476.94014660573$1239402732$gmane$org@us.ibm.com>
References: <20090410023358.GE27788@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090410023358.GE27788-2ev+ksY9ol182hYKe6nXyg@public.gmane.org>
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
> clone_ipc_ns() is misnamed, it doesn't clone anything and doesn't uses passed
> parameter. Rename it.
> 
> create_ipc_ns() will be used by C/R to create ipcns on restart.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> ---
> 
>  include/linux/ipc_namespace.h |    1 +
>  ipc/namespace.c               |    9 ++-------
>  2 files changed, 3 insertions(+), 7 deletions(-)
> 
> --- a/include/linux/ipc_namespace.h
> +++ b/include/linux/ipc_namespace.h
> @@ -97,6 +97,7 @@ static inline int mq_init_ns(struct ipc_namespace *ns) { return 0; }
> 
>  #if defined(CONFIG_IPC_NS)
>  extern void free_ipc_ns(struct ipc_namespace *ns);
> +struct ipc_namespace *create_ipc_ns(void);
>  extern struct ipc_namespace *copy_ipcs(unsigned long flags,
>  				       struct ipc_namespace *ns);
>  extern void free_ipcs(struct ipc_namespace *ns, struct ipc_ids *ids,
> --- a/ipc/namespace.c
> +++ b/ipc/namespace.c
> @@ -14,7 +14,7 @@
> 
>  #include "util.h"
> 
> -static struct ipc_namespace *clone_ipc_ns(struct ipc_namespace *old_ns)
> +struct ipc_namespace *create_ipc_ns(void)
>  {
>  	struct ipc_namespace *ns;
>  	int err;
> @@ -48,14 +48,9 @@ static struct ipc_namespace *clone_ipc_ns(struct ipc_namespace *old_ns)
> 
>  struct ipc_namespace *copy_ipcs(unsigned long flags, struct ipc_namespace *ns)
>  {
> -	struct ipc_namespace *new_ns;
> -
>  	if (!(flags & CLONE_NEWIPC))
>  		return get_ipc_ns(ns);
> -
> -	new_ns = clone_ipc_ns(ns);
> -
> -	return new_ns;
> +	return create_ipc_ns();
>  }
> 
>  /*
