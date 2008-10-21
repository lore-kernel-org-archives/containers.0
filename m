From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/4] freezer_cg: fix improper BUG_ON() causing oops
Date: Tue, 21 Oct 2008 09:16:29 +0200
Message-ID: <48FD81CD.7080103__12021.1686626591$1224573571$gmane$org@fr.ibm.com>
References: <48FD26F5.1070809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48FD26F5.1070809-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> The BUG_ON() should be protected by freezer->lock, otherwise it
> can be triggered easily when a task has been unfreezed but the
> corresponding cgroup hasn't been changed to FROZEN state.

yes. thanks,

Acked-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  kernel/cgroup_freezer.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index e950569..7f54d1c 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -190,8 +190,9 @@ static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
>  	freezer = task_freezer(task);
>  	task_unlock(task);
>  
> -	BUG_ON(freezer->state == CGROUP_FROZEN);
>  	spin_lock_irq(&freezer->lock);
> +	BUG_ON(freezer->state == CGROUP_FROZEN);
> +
>  	/* Locking avoids race with FREEZING -> THAWED transitions. */
>  	if (freezer->state == CGROUP_FREEZING)
>  		freeze_task(task, true);
