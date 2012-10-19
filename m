From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.7-fixes 2/2] Revert "cgroup: Drop
	task_lock(parent) on cgroup_fork()"
Date: Fri, 19 Oct 2012 09:45:15 -0400
Message-ID: <CAFTL4hzH6mj-UqGx1CaOyJTtwWPEQU97537+-ooivzr+8vXVGQ__44149.6457592168$1350654330$gmane$org@mail.gmail.com>
References: <20121008020000.GB2575@localhost>
	<20121019005951.GH13370@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121019005951.GH13370-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

2012/10/18 Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>:
> From c8b27924a8b6fd74066088f1cf07c256bbc6ed74 Mon Sep 17 00:00:00 2001
> From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Date: Thu, 18 Oct 2012 17:52:07 -0700
>
> This reverts commit 7e381b0eb1e1a9805c37335562e8dc02e7d7848c.
>
> The commit incorrectly assumed that fork path always performed
> threadgroup_change_begin/end() and depended on that for
> synchronization against task exit and cgroup migration paths instead
> of explicitly grabbing task_lock().
>
> threadgroup_change is not locked when forking a new process (as
> opposed to a new thread in the same process) and even if it were it
> wouldn't be effective as different processes use different threadgroup
> locks.
>
> Revert the incorrect optimization.
>
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> LKML-Reference: <20121008020000.GB2575@localhost>

(bitterly) Acked-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> :-)


> Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  kernel/cgroup.c |   23 ++++++-----------------
>  1 files changed, 6 insertions(+), 17 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 2990dc7..f24f724 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -4814,31 +4814,20 @@ static const struct file_operations proc_cgroupstats_operations = {
>   *
>   * A pointer to the shared css_set was automatically copied in
>   * fork.c by dup_task_struct().  However, we ignore that copy, since
> - * it was not made under the protection of RCU, cgroup_mutex or
> - * threadgroup_change_begin(), so it might no longer be a valid
> - * cgroup pointer.  cgroup_attach_task() might have already changed
> - * current->cgroups, allowing the previously referenced cgroup
> - * group to be removed and freed.
> - *
> - * Outside the pointer validity we also need to process the css_set
> - * inheritance between threadgoup_change_begin() and
> - * threadgoup_change_end(), this way there is no leak in any process
> - * wide migration performed by cgroup_attach_proc() that could otherwise
> - * miss a thread because it is too early or too late in the fork stage.
> + * it was not made under the protection of RCU or cgroup_mutex, so
> + * might no longer be a valid cgroup pointer.  cgroup_attach_task() might
> + * have already changed current->cgroups, allowing the previously
> + * referenced cgroup group to be removed and freed.
>   *
>   * At the point that cgroup_fork() is called, 'current' is the parent
>   * task, and the passed argument 'child' points to the child task.
>   */
>  void cgroup_fork(struct task_struct *child)
>  {
> -       /*
> -        * We don't need to task_lock() current because current->cgroups
> -        * can't be changed concurrently here. The parent obviously hasn't
> -        * exited and called cgroup_exit(), and we are synchronized against
> -        * cgroup migration through threadgroup_change_begin().
> -        */
> +       task_lock(current);
>         child->cgroups = current->cgroups;
>         get_css_set(child->cgroups);
> +       task_unlock(current);
>         INIT_LIST_HEAD(&child->cg_list);
>  }
>
> --
> 1.7.7.3
>
