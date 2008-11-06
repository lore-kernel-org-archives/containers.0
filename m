From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -v2] freezer_cg: disable writing freezer.state of root
	cgroup
Date: Wed, 5 Nov 2008 17:24:49 -0800
Message-ID: <6599ad830811051724p1f97026fl96be5efe38b33152__35393.9501256265$1225934827$gmane$org@mail.gmail.com>
References: <491245F1.5070707@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <491245F1.5070707-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Nov 5, 2008 at 5:18 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> With this change, control file 'freezer.state' doesn't exist in root
> cgroup, making root cgroup unfreezable.
>
> I think it's reasonable to disallow freeze tasks in the root cgroup.
> And then we can avoid fork overhead when freezer subsystem is
> compiled but not used.
>
> Also make writing invalid value to freezer.state returns EINVAL
> rather than EIO. This is more consistent with other cgroup subsystem.
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

I might use the term "non-freezable" rather than "unfreezable".

Thanks,

Paul

> ---
>
> patch is based on freezer_cg-remove-task_lock-from-freezer_fork.patch
>
> ---
>  Documentation/cgroups/freezer-subsystem.txt |    3 +++
>  kernel/cgroup_freezer.c                     |   11 ++++++++++-
>  2 files changed, 13 insertions(+), 1 deletions(-)
>
> diff --git a/Documentation/cgroups/freezer-subsystem.txt b/Documentation/cgroups/freezer-subsystem.txt
> index c50ab58..91572b9 100644
> --- a/Documentation/cgroups/freezer-subsystem.txt
> +++ b/Documentation/cgroups/freezer-subsystem.txt
> @@ -54,6 +54,9 @@ freezer.state. Writing "FROZEN" to the state file will freeze all tasks in the
>  cgroup. Subsequently writing "THAWED" will unfreeze the tasks in the cgroup.
>  Reading will return the current state.
>
> +Note freezer.state doesn't exist in root cgroup, which means root cgroup
> +is unfreezable.
> +
>  * Examples of usage :
>
>    # mkdir /containers/freezer
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index 6605907..cf3fce9 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -192,6 +192,13 @@ static void freezer_fork(struct cgroup_subsys *ss, struct task_struct *task)
>         */
>        freezer = task_freezer(task);
>
> +       /*
> +        * The root cgroup is unfreezable, so we can skip the
> +        * following check.
> +        */
> +       if (!freezer->css.cgroup->parent)
> +               return;
> +
>        spin_lock_irq(&freezer->lock);
>        BUG_ON(freezer->state == CGROUP_FROZEN);
>
> @@ -335,7 +342,7 @@ static int freezer_write(struct cgroup *cgroup,
>        else if (strcmp(buffer, freezer_state_strs[CGROUP_FROZEN]) == 0)
>                goal_state = CGROUP_FROZEN;
>        else
> -               return -EIO;
> +               return -EINVAL;
>
>        if (!cgroup_lock_live_group(cgroup))
>                return -ENODEV;
> @@ -354,6 +361,8 @@ static struct cftype files[] = {
>
>  static int freezer_populate(struct cgroup_subsys *ss, struct cgroup *cgroup)
>  {
> +       if (!cgroup->parent)
> +               return 0;
>        return cgroup_add_files(cgroup, ss, files, ARRAY_SIZE(files));
>  }
>
> --
> 1.5.4.rc3
>
>
