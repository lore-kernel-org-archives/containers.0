From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] freezer_cg: simplify freezer_change_state()
Date: Tue, 21 Oct 2008 14:45:39 -0700
Message-ID: <1224625539.2991.93.camel__15551.5050668784$1224625672$gmane$org@enoch>
References: <48FD26F5.1070809@cn.fujitsu.com>
	<48FD273F.3040505@cn.fujitsu.com> <48FD2784.30906@cn.fujitsu.com>
	<48FD27E1.5070903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48FD27E1.5070903-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Tue, 2008-10-21 at 08:52 +0800, Li Zefan wrote:
> Just call unfreeze_cgroup() if goal_state == THAWED, and call
> try_to_freeze_cgroup() if goal_state == FROZEN.
> 
> No behavior has been changed.

Another good one. Thanks!

Acked-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  kernel/cgroup_freezer.c |   19 +++++++------------
>  1 files changed, 7 insertions(+), 12 deletions(-)
> 
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index 3ea57e4..cdef2d8 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -296,27 +296,22 @@ static int freezer_change_state(struct cgroup *cgroup,
>  	int retval = 0;
> 
>  	freezer = cgroup_freezer(cgroup);
> +
>  	spin_lock_irq(&freezer->lock);
> +
>  	update_freezer_state(cgroup, freezer);
>  	if (goal_state == freezer->state)
>  		goto out;
> -	switch (freezer->state) {
> +
> +	switch (goal_state) {
>  	case CGROUP_THAWED:
> -		retval = try_to_freeze_cgroup(cgroup, freezer);
> +		unfreeze_cgroup(cgroup, freezer);
>  		break;
> -	case CGROUP_FREEZING:
> -		if (goal_state == CGROUP_FROZEN) {
> -			/* Userspace is retrying after
> -			 * "/bin/echo FROZEN > freezer.state" returned -EBUSY */
> -			retval = try_to_freeze_cgroup(cgroup, freezer);
> -			break;
> -		}
> -		/* state == FREEZING and goal_state == THAWED, so unfreeze */
>  	case CGROUP_FROZEN:
> -		unfreeze_cgroup(cgroup, freezer);
> +		retval = try_to_freeze_cgroup(cgroup, freezer);
>  		break;
>  	default:
> -		break;
> +		BUG();
>  	}
>  out:
>  	spin_unlock_irq(&freezer->lock);
