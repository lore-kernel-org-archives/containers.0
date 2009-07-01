From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] Disable CLONE_PARENT for init
Date: Wed, 01 Jul 2009 16:27:38 -0700
Message-ID: <m1zlbooufp.fsf__7447.40647865019$1246490912$gmane$org@fess.ebiederm.org>
References: <20090701073140.GA14284@us.ibm.com>
	<20090701074654.A6C6321D57@magilla.sf.frob.com>
	<20090701082452.GA3297@redhat.com> <20090701214805.GA25734@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090701214805.GA25734-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Sukadev Bhattiprolu's
	message of "Wed\, 1 Jul 2009 14\:48\:05 -0700")
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

> | This won't fix the problem. The child won't autoreap itself if ->exit_signal
> | != SIGCHLD.
> | 
> | > If you want to make this change because of container-init issues, I think
> | > you should just say so independent of this global-init case.
> | 
> | Yes, agreed, the comment looks confusing.
> | 
> | Oleg
>
> Here is an updated patch with comments fixed.
>
> Roland pls ack again if this is better.
>
> ---
>
> Disable CLONE_PARENT for init.
>
> When global or container-init processes use CLONE_PARENT, they create a
> multi-rooted process tree. Besides if the siblings of init exit, the
> SIGCHLD is not sent to init process resulting in the zombies sticking
> around indefinitely.
>
> Changelog[v3]:
> 	- [Roland, Oleg] Simplify comment describing the change
> Changelog[v2]:
> 	- Simplify patch description based on comments from Eric Biederman
> 	  and Oleg Nesterov.
> 	- [Oleg Nesterov] Use SIGNAL_UNKILLABLE instead of is_global_init()
>
> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

> ---
>  kernel/fork.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
>
> Index: linux-mmotm/kernel/fork.c
> ===================================================================
> --- linux-mmotm.orig/kernel/fork.c	2009-06-30 23:01:06.000000000 -0700
> +++ linux-mmotm/kernel/fork.c	2009-07-01 14:43:10.000000000 -0700
> @@ -974,6 +974,14 @@ static struct task_struct *copy_process(
>  	if ((clone_flags & CLONE_SIGHAND) && !(clone_flags & CLONE_VM))
>  		return ERR_PTR(-EINVAL);
>  
> +	/*
> +	 * To avoid multi-rooted process-trees prevent global and container
> +	 * inits from creating siblings.
> +	 */
> +	if ((clone_flags & CLONE_PARENT) &&
> +				current->signal->flags & SIGNAL_UNKILLABLE)
> +		return ERR_PTR(-EINVAL);
> +
>  	retval = security_task_create(clone_flags);
>  	if (retval)
>  		goto fork_out;
