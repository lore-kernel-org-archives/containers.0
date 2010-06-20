From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/6] pid:  Remove the child_reaper special case in
	init/main.c
Date: Sun, 20 Jun 2010 20:29:48 +0200
Message-ID: <20100620182948.GB3258@redhat.com>
References: <20100617212003.GA4182@redhat.com>
	<20100618082033.GD16877@hawkmoon.kerlabs.com>
	<20100618111554.GA3252@redhat.com>
	<20100618160849.GA7404@redhat.com>
	<20100618173320.GG16877@hawkmoon.kerlabs.com>
	<20100618175541.GA13680@redhat.com>
	<20100618212355.GA29478@redhat.com>
	<20100619190840.GA3424@redhat.com>
	<m1pqzmqema.fsf_-_@fess.ebiederm.org>
	<m1ljaaqejm.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1ljaaqejm.fsf_-_-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 06/20, Eric W. Biederman wrote:
>
> It turns out that the existing assignment in copy_process of
> the child_reaper can handle the initial assignment of child_reaper
> we just need to generalize the test in kernel/fork.c
>
> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  init/main.c   |    9 ---------
>  kernel/fork.c |    2 +-
>  2 files changed, 1 insertions(+), 10 deletions(-)
>
> diff --git a/init/main.c b/init/main.c
> index 3bdb152..38f7edc 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -865,15 +865,6 @@ static int __init kernel_init(void * unused)
>  	 * init can run on any cpu.
>  	 */
>  	set_cpus_allowed_ptr(current, cpu_all_mask);
> -	/*
> -	 * Tell the world that we're going to be the grim
> -	 * reaper of innocent orphaned children.
> -	 *
> -	 * We don't want people to have to make incorrect
> -	 * assumptions about where in the task array this
> -	 * can be found.
> -	 */
> -	init_pid_ns.child_reaper = current;
>
>  	cad_pid = task_pid(current);
>
> diff --git a/kernel/fork.c b/kernel/fork.c
> index b6cce14..8b85b17 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -1263,7 +1263,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
>  		tracehook_finish_clone(p, clone_flags, trace);
>
>  		if (thread_group_leader(p)) {
> -			if (clone_flags & CLONE_NEWPID)
> +			if (pid->numbers[pid->level].nr == 1)
>  				p->nsproxy->pid_ns->child_reaper = p;

I must admit, personally I dislike this change. If it is needed for
the next changes, please explain the need?

Yes, it removes the line from __init function, but it complicates
copy_process(), this doesn't look fair to me ;) I agree, the complication
is minor, but still. And, in fact, to me this change hides CLONE_NEWPID
from grep.

In fact, I was looking at this code when I did 1/4. And I think it is
better to move it (and perhaps another CLONE_NEWPID check in copy_signal)
into copy_pid_ns() path.

Oleg.
