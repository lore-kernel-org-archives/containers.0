From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 2/2] Prevent container-inits from using CLONE_PARENT
Date: Wed, 17 Jun 2009 20:20:21 -0700
Message-ID: <m18wjqkz2i.fsf@fess.ebiederm.org>
References: <20090618024743.GA31515@us.ibm.com>
	<20090618025103.GB31672@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090618025103.GB31672-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Sukadev Bhattiprolu's
	message of "Wed\, 17 Jun 2009 19\:51\:03 -0700")
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

> Prevent container-inits from using CLONE_PARENT
>
> If a container-init creates a sibling (using CLONE_PARENT), pid namespace
> semantics become complicated:
>
> 	- the "active pid namespace" of the sibling will be the descendant
> 	  container, but its not obvious if that is correct.

It is correct the sibling must not change pid namespaces.  You are not
allowed to escape out of a pid namespace.

> 	- if container-init exits, it will terminate the sibling, but again
> 	  its not clear if that is the correct behavior.

Again correct because the container-init is the child reaper for the pid namespace.
No reaper no namespace.

> 	- the sibling exists in both parent and child containers while current
> 	  pid namespace semantics assume that only container-init can exist
> 	  in both parent/child containers.

All tasks in the container also exist in the parent container.
What assumption are you talking about?

> 	- the parent of the sibling is not a descendant of container-init
> 	  (while pid namespaces assume that all processes in the container
> 	  are descendants of the container-init)

User space assumes that certainly.    What part of the pid namespace
code makes such an assumption?

> 	- When the sibling dies, the SIGCHLD is sent to its parent (if
> 	  alive), i.e the signal escapes the container to a parent container.
> 	  (if the parent of the sibling exits, the container-init then becomes
> 	  the reaper of the sibling).

Yes.

> To keep pid namespace semantics simple, prevent container-inits from using
> CLONE_PARENT at least until we have a better understanding of CLONE_PARENT
> and pid-namespace interactions.

The only argument that I can see that carries any weight is that unix
semantics fundamentally assume a process tree.  Allowing init to use
CLONE_PARENT creates a multi-rooted process tree.

At which point the is_global_init check is foolish.

Eric


> Untested, RFC patch :-)
>
> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/fork.c |    8 ++++++++
>  1 file changed, 8 insertions(+)
>
> Index: linux-mmotm/kernel/fork.c
> ===================================================================
> --- linux-mmotm.orig/kernel/fork.c	2009-06-17 18:23:23.000000000 -0700
> +++ linux-mmotm/kernel/fork.c	2009-06-17 19:17:54.000000000 -0700
> @@ -974,6 +974,14 @@ static struct task_struct *copy_process(
>  	if ((clone_flags & CLONE_SIGHAND) && !(clone_flags & CLONE_VM))
>  		return ERR_PTR(-EINVAL);
>  
> +	/*
> +	 * To keep pid namespace semantics simple, prevent container-inits
> +	 * from creating siblings.
> +	 */
> +	if ((clone_flags & CLONE_PARENT) &&
> +			is_container_init(current) && !is_global_init(current))
> +		return ERR_PTR(-EINVAL);
> +
>  	retval = security_task_create(clone_flags);
>  	if (retval)
>  		goto fork_out;
