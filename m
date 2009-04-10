From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [PATCH 04/30] ipcns: add create_ipc_ns()
Date: Fri, 10 Apr 2009 11:01:49 +0200
Message-ID: <20090410090149.GD17962@elte.hu>
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
To: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andy Whitcroft <apw-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org


* Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

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

Hm, doesnt the existing, correct pattern strike your eyes out:

  extern foo1();
  extern foo2();
  extern foo3();

and then you add a new method in this inconsistent way:

  extern foo1();
  foox();
  extern foo2();
  extern foo3();

Instead of continuing the existing pattern via:

  extern foo1();
  extern foox();
  extern foo2();
  extern foo3();

?

I think we need a new checkpatch warning for such things. It might 
be a small detail in the big picture, but a thousand small details 
create a big mess easily so we have to try to get all the small 
details right, all the time - that is the only way to create a 
better kernel in the end.

Thanks,

	Ingo
