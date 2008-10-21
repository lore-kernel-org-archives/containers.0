From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] freezer_cg: remove redundant check in
	freezer_can_attach()
Date: Tue, 21 Oct 2008 14:40:33 -0700
Message-ID: <1224625233.2991.87.camel__41207.1655191996$1224625452$gmane$org@enoch>
References: <48FD26F5.1070809@cn.fujitsu.com> <48FD273F.3040505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48FD273F.3040505-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2008-10-21 at 08:50 +0800, Li Zefan wrote:
> It is sufficient to check if @task is frozen, and no need to check if
> the original freezer is frozen.

Looks great! Thanks!

Acked-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  kernel/cgroup_freezer.c |   16 +++++++---------
>  1 files changed, 7 insertions(+), 9 deletions(-)
> 
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index 7f54d1c..6fadafe 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -162,9 +162,13 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
>  			      struct task_struct *task)
>  {
>  	struct freezer *freezer;
> -	int retval;
> 
> -	/* Anything frozen can't move or be moved to/from */
> +	/*
> +	 * Anything frozen can't move or be moved to/from.
> +	 *
> +	 * Since orig_freezer->state == FROZEN means that @task has been
> +	 * frozen, so it's sufficient to check the latter condition.
> +	 */
> 
>  	if (is_task_frozen_enough(task))
>  		return -EBUSY;
> @@ -173,13 +177,7 @@ static int freezer_can_attach(struct cgroup_subsys *ss,
>  	if (freezer->state == CGROUP_FROZEN)
>  		return -EBUSY;
> 
> -	retval = 0;
> -	task_lock(task);
> -	freezer = task_freezer(task);
> -	if (freezer->state == CGROUP_FROZEN)
> -		retval = -EBUSY;
> -	task_unlock(task);
> -	return retval;
> +	return 0;
>  }
> 
>  static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
