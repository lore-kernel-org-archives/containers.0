From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroups: fix incorrect using rcu_dereference() in
	cgroup_subsys_state()
Date: Fri, 21 Nov 2008 10:07:48 -0800
Message-ID: <6599ad830811211007s43f0c683s9d56e0aed3af938__20969.7223770947$1227291735$gmane$org@mail.gmail.com>
References: <4926761E.8030002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4926761E.8030002-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
> It's task->cgroups protected by RCU. and struct css_set.subsys[subsys_id]
> is readonly(after init). so we don't need rcu_dereference() for
> struct css_set.subsys[subsys_id].
>
> the ways using cgroup_subsys_state() safely:
>
> #1:
> rcu_read_lock() / task_lock();
> c = cgroup_subsys_state(tsk, id);
> use c;
> rcu_read_unlock() / task_unlock();

You need to qualify that with the fact that if you're just using RCU,
the subsys state may no longer be the state for the task that you're
interested in, since we don't guarantee that the task won't move
directly after you read the state pointer.

>
>
> #2: use cgroup_lock() for _current_ task.
> cgroup_lock();
> c = cgroup_subsys_state(current, id);
> use c;
> cgroup_unlock();

No, if you use cgroup_lock() you can do this for any task.
cgroup_lock() is the cgroups equivalent of the BKL, and definitely
prevents all task movement between groups.
>  static inline struct cgroup_subsys_state *task_subsys_state(
>        struct task_struct *task, int subsys_id)
>  {
> -       return rcu_dereference(task->cgroups->subsys[subsys_id]);
> +       /*
> +        * ->subsys[subsys_id] are read-only data, so we do not need
> +        * rcu_dereference() for it.
> +        */
> +       return rcu_dereference(task->cgroups)->subsys[subsys_id];
>  }

Change looks OK but I think we can lose the additional comment.

Paul
