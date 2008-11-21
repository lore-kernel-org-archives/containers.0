From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] cpuset: use cgroup_path() in proc_cpuset_show()
Date: Fri, 21 Nov 2008 10:56:58 -0800
Message-ID: <6599ad830811211056x205f0fc7k6b0472dc34c03c69__12938.2786377848$1227293960$gmane$org@mail.gmail.com>
References: <4926762E.9010207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4926762E.9010207-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
> use cgroup_path() instead of
> task_subsys_state(tsk, cpuset_subsys_id)->cgroup

You mean:

use task_cgroup() instead of task_subsys_state()->cgroup

>
> Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 3e00526..e0e087e 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -2387,7 +2386,7 @@ static int proc_cpuset_show(struct seq_file *m, void *unused_v)
>        struct pid *pid;
>        struct task_struct *tsk;
>        char *buf;
> -       struct cgroup_subsys_state *css;
> +       struct cgroup *cgp;
>        int retval;
>
>        retval = -ENOMEM;
> @@ -2403,8 +2402,8 @@ static int proc_cpuset_show(struct seq_file *m, void *unused_v)
>
>        retval = -EINVAL;
>        cgroup_lock();
> -       css = task_subsys_state(tsk, cpuset_subsys_id);
> -       retval = cgroup_path(css->cgroup, buf, PAGE_SIZE);
> +       cgp = task_cgroup(tsk, cpuset_subsys_id);
> +       retval = cgroup_path(cgp, buf, PAGE_SIZE);
>        if (retval < 0)
>                goto out_unlock;
>        seq_puts(m, buf);
>
>
>
