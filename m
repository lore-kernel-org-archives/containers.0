From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroups: use task_lock() for access tsk->cgroups safe in
	cgroup_clone()
Date: Fri, 21 Nov 2008 11:18:29 -0800
Message-ID: <6599ad830811211118kd410ce0o68db8249e60c8dd8__7012.08903124115$1227295277$gmane$org@mail.gmail.com>
References: <49267633.8040607@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49267633.8040607-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Nov 21, 2008 at 12:49 AM, Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
> use task_lock() protect tsk->cgroups and get_css_set(tsk->cgroups)
>
>
> Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Sounds reasonable, given the race with cgroup_exit()

Reviewed-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks,

Paul

> ---
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 358e775..ddc10ac 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2933,6 +2943,7 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
>                mutex_unlock(&cgroup_mutex);
>                return 0;
>        }
> +       task_lock(tsk);
>        cg = tsk->cgroups;
>        parent = task_cgroup(tsk, subsys->subsys_id);
>
> @@ -2941,6 +2952,7 @@ int cgroup_clone(struct task_struct *tsk, struct cgroup_subsys *subsys,
>
>        /* Keep the cgroup alive */
>        get_css_set(cg);
> +       task_unlock(tsk);
>        mutex_unlock(&cgroup_mutex);
>
>        /* Now do the VFS work to create a cgroup */
>
>
