From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 1/2] Deny CLONE_PARENT|CLONE_NEWPID combination
Date: Wed, 17 Jun 2009 20:30:51 -0700
Message-ID: <m1d492jk0k.fsf@fess.ebiederm.org>
References: <20090618024743.GA31515@us.ibm.com>
	<20090618024934.GA31672@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090618024934.GA31672-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Sukadev Bhattiprolu's
	message of "Wed\, 17 Jun 2009 19\:49\:34 -0700")
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

> Deny CLONE_PARENT|CLONE_NEWPID combination.
>
> CLONE_PARENT was probably used to implement an older threading model.

Yes it was.

> If so, for consistency with CLONE_THREAD, the CLONE_PARENT|CLONE_NEWPID
> combination should also fail with -EINVAL.

CLONE_THREAD can not work with CLONE_NEWPID because the processes share
a signal queue.

I can see a similar argument going for CLONE_SIGHAND even though there is not
as much sharing there.  I don't see how CLONE_PARENT could cause any harm.
Without CLONE_SIGHAND.

Eric

> Signed-off-by: Sukadev Bhattiprolu <sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/pid_namespace.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> Index: linux-mmotm/kernel/pid_namespace.c
> ===================================================================
> --- linux-mmotm.orig/kernel/pid_namespace.c	2009-06-17 18:19:42.000000000 -0700
> +++ linux-mmotm/kernel/pid_namespace.c	2009-06-17 18:19:58.000000000 -0700
> @@ -118,7 +118,7 @@ struct pid_namespace *copy_pid_ns(unsign
>  {
>  	if (!(flags & CLONE_NEWPID))
>  		return get_pid_ns(old_ns);
> -	if (flags & CLONE_THREAD)
> +	if (flags & (CLONE_THREAD|CLONE_PARENT))
>  		return ERR_PTR(-EINVAL);
>  	return create_pid_namespace(old_ns);
>  }
