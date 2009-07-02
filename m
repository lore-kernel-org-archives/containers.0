From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] Deny CLONE_PARENT|CLONE_NEWPID|CLONE_SIGHAND
	combination
Date: Thu, 2 Jul 2009 13:57:40 +0200
Message-ID: <20090702115740.GB3552__18884.6771060073$1246536071$gmane$org@redhat.com>
References: <20090701074045.GA14595@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090701074045.GA14595-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On 07/01, Sukadev Bhattiprolu wrote:
>
> Deny CLONE_PARENT|CLONE_NEWPID|CLONE_SIGHAND combination.
>
> CLONE_PARENT was used to implement an older threading model.  For consistency
> with the CLONE_THREAD check in copy_pid_ns(), disable CLONE_PARENT and
> CLONE_SIGHAND with CLONE_NEWPID, at least until the required semantics of
> the pid namespaces are clear.
>
> Changelog[v2]:
> 	[Eric Biederman] Disable CLONE_SIGHAND also ???
>
> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Acked-by: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/pid_namespace.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: linux-mmotm/kernel/pid_namespace.c
> ===================================================================
> --- linux-mmotm.orig/kernel/pid_namespace.c	2009-06-30 23:01:09.000000000 -0700
> +++ linux-mmotm/kernel/pid_namespace.c	2009-06-30 23:49:06.000000000 -0700
> @@ -118,7 +118,7 @@ struct pid_namespace *copy_pid_ns(unsign
>  {
>  	if (!(flags & CLONE_NEWPID))
>  		return get_pid_ns(old_ns);
> -	if (flags & CLONE_THREAD)
> +	if (flags & (CLONE_THREAD|CLONE_PARENT|CLONE_SIGHAND))
>  		return ERR_PTR(-EINVAL);

Still can't understand why CLONE_SIGHAND is forbidden...

CLONE_SIGHAND doesn't mean we share the signal queue, so what is
the reason?

Oleg.
