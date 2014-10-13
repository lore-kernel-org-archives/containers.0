From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V5 09/13] fork: audit on creation of new namespace(s)
Date: Mon, 13 Oct 2014 15:14:54 +0200
Message-ID: <20141013131454.GG24703@mail.hallyn.com>
References: <cover.1412543112.git.rgb@redhat.com>
	<b9607ab778a84381b4a82cf0110d031f19b17525.1412543112.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <b9607ab778a84381b4a82cf0110d031f19b17525.1412543112.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: aviro-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Richard Guy Briggs (rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> When clone(2) is called to fork a new process creating one or more namespaces,
> audit the event to tie the new pid with the namespace IDs.
> 
> Signed-off-by: Richard Guy Briggs

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> ---
>  kernel/fork.c    |    3 +++
>  kernel/nsproxy.c |    1 +
>  2 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 6a13c46..a7fe4d5 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1624,6 +1624,9 @@ long do_fork(unsigned long clone_flags,
>  			get_task_struct(p);
>  		}
>  
> +		if (unlikely(clone_flags & CLONE_NEW_MASK)) {
> +			audit_log_ns_info(p);
> +		}
>  		wake_up_new_task(p);
>  
>  		/* forking complete and child started to run, tell ptracer */
> diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
> index 0c2f25e..2cdc16b 100644
> --- a/kernel/nsproxy.c
> +++ b/kernel/nsproxy.c
> @@ -25,6 +25,7 @@
>  #include <linux/proc_ns.h>
>  #include <linux/file.h>
>  #include <linux/syscalls.h>
> +#include <linux/audit.h>
>  
>  static struct kmem_cache *nsproxy_cachep;
>  
> -- 
> 1.7.1
