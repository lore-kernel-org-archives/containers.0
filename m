From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] cgroups: defer free css_set
Date: Fri, 21 Nov 2008 10:28:44 -0800
Message-ID: <6599ad830811211028v2d9532cfsfef18c0af5935964__5045.53169380433$1227292330$gmane$org@mail.gmail.com>
References: <4926761B.2060608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4926761B.2060608-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
> we free css_set when refcnt became 0 immediately(except cgroup_attach_task()).
> I will destroy the data which read side maybe still access it.
> this patch use call_rcu() to defer free css_set
>
> Signed-off-by: Lai Jiangshan <laijs-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 1164963..22901ff 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -178,6 +178,8 @@ struct css_set {
>         */
>        struct list_head cg_links;
>
> +       struct rcu_head rcu;
> +
>        /*
>         * Set of subsystem states, one for each subsystem. This array
>         * is immutable after creation apart from the init_css_set
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 358e775..ddc10ac 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -252,6 +252,11 @@ static void unlink_css_set(struct css_set *cg)
>        }
>  }
>
> +static void rcu_free_css_set(struct rcu_head *head)
> +{
> +       kfree(container_of(head, struct css_set, rcu));
> +}
> +
>  static void __put_css_set(struct css_set *cg, int taskexit)
>  {
>        int i;
> @@ -281,7 +286,7 @@ static void __put_css_set(struct css_set *cg, int taskexit)
>                }
>        }
>        rcu_read_unlock();
> -       kfree(cg);
> +       call_rcu(&cg->rcu, rcu_free_css_set);
>  }
>
>  /*
> @@ -1267,7 +1277,6 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
>                        ss->attach(ss, cgrp, oldcgrp, tsk);
>        }
>        set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
> -       synchronize_rcu();

I'm reluctant to remove this synchronize_rcu() call - it gives the
property that if you get a pointer to a task's cgroup protected by
RCU, then even if you race with the task moving away to a different
cgroup, then no other cgroup_mutex-protected operation can start until
you've finished your RCU section (since the thread that you raced with
is blocking in synchronize_rcu() while holding cgroup_mutex). I'm
pretty sure that some of the cgroups code relies on that property,
although I can't find exactly which bit I'm thinking of.

Also, using call_rcu() for freeing all css_sets seems unnecessary -
the only one that appears to be potentially broken is the one from
cgroup_exit(), since in the other cases the css_set hasn't been
visible via a task->cgroups pointer. So how about making
__put_css_set() do a call_rcu() for the case when taskexit is true,
and a plain free() otherwise? That would also reduce the change of
overloading the RCU system with too many deferred frees.

Paul
