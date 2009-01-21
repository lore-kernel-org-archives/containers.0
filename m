From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroups: fix lock inconsistency in cgroup_clone()
Date: Wed, 21 Jan 2009 02:05:49 -0800
Message-ID: <6599ad830901210205jea6274rf898f59b9a48fa73__25362.0321782821$1232532500$gmane$org@mail.gmail.com>
References: <497572AA.8020101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <497572AA.8020101-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Jan 19, 2009 at 10:43 PM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> I fixed a bug in cgroup_clone() in Linus' tree (commit 7b574b7), without
> noticing there was a cleanup patch in -mm tree that should be rebased
> (now commit 104cbd5), thus resulted in lock inconsistency.
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks.

> ---
>
> for 2.6.29
>
> ---
>  kernel/cgroup.c |   13 +++++++------
>  1 files changed, 7 insertions(+), 6 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index c298310..a5826f3 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2991,20 +2991,21 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
>                mutex_unlock(&cgroup_mutex);
>                return 0;
>        }
> -       task_lock(tsk);
> -       cg = tsk->cgroups;
> -       parent = task_cgroup(tsk, subsys->subsys_id);
>
>        /* Pin the hierarchy */
> -       if (!atomic_inc_not_zero(&parent->root->sb->s_active)) {
> +       if (!atomic_inc_not_zero(&root->sb->s_active)) {
>                /* We race with the final deactivate_super() */
>                mutex_unlock(&cgroup_mutex);
>                return 0;
>        }
>
>        /* Keep the cgroup alive */
> +       task_lock(tsk);
> +       parent = task_cgroup(tsk, subsys->subsys_id);
> +       cg = tsk->cgroups;
>        get_css_set(cg);
>        task_unlock(tsk);
> +
>        mutex_unlock(&cgroup_mutex);
>
>        /* Now do the VFS work to create a cgroup */
> @@ -3043,7 +3044,7 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
>                mutex_unlock(&inode->i_mutex);
>                put_css_set(cg);
>
> -               deactivate_super(parent->root->sb);
> +               deactivate_super(root->sb);
>                /* The cgroup is still accessible in the VFS, but
>                 * we're not going to try to rmdir() it at this
>                 * point. */
> @@ -3069,7 +3070,7 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
>        mutex_lock(&cgroup_mutex);
>        put_css_set(cg);
>        mutex_unlock(&cgroup_mutex);
> -       deactivate_super(parent->root->sb);
> +       deactivate_super(root->sb);
>        return ret;
>  }
>
> --
> 1.5.4.rc3
>
>
>
