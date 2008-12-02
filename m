From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] cgroups: add inactive subsystems to
	rootnode.root_list
Date: Mon, 1 Dec 2008 17:35:15 -0800
Message-ID: <6599ad830812011735i565087dfg7ebad01a1f0400ad__48424.3947583765$1228181949$gmane$org@mail.gmail.com>
References: <492FC1BD.4010705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <492FC1BD.4010705-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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

On Fri, Nov 28, 2008 at 2:02 AM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> Though for an inactive hierarchy, we have subsys->root == &rootnode,
> but rootnode's root_list is always empty.

I think you mean "rootnode's subsys_list is always empty".

>
> The above code assumes rootnode.subsys_list links all inactive
> hierarchies.
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  kernel/cgroup.c |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 33ba756..4e50e97 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -716,7 +716,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
>                        BUG_ON(dummytop->subsys[i]->cgroup != dummytop);
>                        cgrp->subsys[i] = dummytop->subsys[i];
>                        cgrp->subsys[i]->cgroup = cgrp;
> -                       list_add(&ss->sibling, &root->subsys_list);
> +                       list_move(&ss->sibling, &root->subsys_list);
>                        rcu_assign_pointer(ss->root, root);
>                        if (ss->bind)
>                                ss->bind(ss, cgrp);
> @@ -730,7 +730,7 @@ static int rebind_subsystems(struct cgroupfs_root *root,
>                        dummytop->subsys[i]->cgroup = dummytop;
>                        cgrp->subsys[i] = NULL;
>                        rcu_assign_pointer(subsys[i]->root, &rootnode);
> -                       list_del(&ss->sibling);
> +                       list_move(&ss->sibling, &rootnode.subsys_list);
>                } else if (bit & final_bits) {
>                        /* Subsystem state should already exist */
>                        BUG_ON(!cgrp->subsys[i]);
> @@ -2522,6 +2522,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
>        printk(KERN_INFO "Initializing cgroup subsys %s\n", ss->name);
>
>        /* Create the top cgroup state for this subsystem */
> +       list_add(&ss->sibling, &rootnode.root_list);

This is wrong. cgroup_subsys.sibling is a member of the list of
subsystems attached to a given root, and rootnode.root_list is a
member of the list of hierarchies. Did you actually meant
&rootnode.subsys_list?

Paul
