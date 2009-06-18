From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] Prevent container-inits from using CLONE_PARENT
Date: Thu, 18 Jun 2009 17:35:01 +0200
Message-ID: <20090618153501.GA6404@redhat.com>
References: <20090618024743.GA31515@us.ibm.com>
	<20090618025103.GB31672@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090618025103.GB31672-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "David C. Hansen" <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 06/17, Sukadev Bhattiprolu wrote:
>
> Prevent container-inits from using CLONE_PARENT
>
> If a container-init creates a sibling (using CLONE_PARENT), pid namespace
> semantics become complicated:
>
> 	- the "active pid namespace" of the sibling will be the descendant
> 	  container, but its not obvious if that is correct.
>
> 	- if container-init exits, it will terminate the sibling, but again
> 	  its not clear if that is the correct behavior.
>
> 	- the sibling exists in both parent and child containers while current
> 	  pid namespace semantics assume that only container-init can exist
> 	  in both parent/child containers.
>
> 	- the parent of the sibling is not a descendant of container-init
> 	  (while pid namespaces assume that all processes in the container
> 	  are descendants of the container-init)

I agree, this all a bit strange and perhaps should be fixed. But afaics,
nothing bad can happen? I mean, if the sub-namespace does stupid things
it can't do a harm to the parent namespace? Or I missed something?

> 	- When the sibling dies, the SIGCHLD is sent to its parent (if
> 	  alive), i.e the signal escapes the container to a parent container.

The same if container-init exits, we send SIGCHLD up. But yes, I agree,
this is a bit strange.

> 	  (if the parent of the sibling exits, the container-init then becomes
> 	  the reaper of the sibling).

Again, strange but harmless.

> To keep pid namespace semantics simple, prevent container-inits from using
> CLONE_PARENT at least until we have a better understanding of CLONE_PARENT
> and pid-namespace interactions.

Yes, perhaps makes sense.

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

Both is_ checks are not right afaics. There are per-thread. This means
that container-init can do clone(CLONE_THREAD), and then this thread
does CLONE_PARENT and fools copy_process().

As for !is_global_init(). I never understood what should we do if the
global init does CLONE_PARENT, this attaches another process to swapper,
not good.

Oleg.
