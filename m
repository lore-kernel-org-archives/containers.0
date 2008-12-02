From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] cgroups: make root_list contains active hierarchies
	only
Date: Mon, 1 Dec 2008 17:31:10 -0800
Message-ID: <6599ad830812011731w75eda049tc809856041ecb707__42634.7351204187$1228181631$gmane$org@mail.gmail.com>
References: <492FC1B9.1040403@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <492FC1B9.1040403-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
> Don't link rootnode to the root list, so root_list contains active
> hierarchies only as the comment indicates. And rename for_each_root()
> to for_each_active_root().

Why is that change an improvement? If you're concerned about the
comment's accuracy then it would be better to just change it to say "A
list running through all hierarchies (including the inactive subsystem
hierarchy)"?

Also, with this change, "root_count" is no longer the length of the
"roots" list, but instead is length + 1, which doesn't seem good.

Paul

>
> Also remove redundant check in cgroup_kill_sb().
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
>  kernel/cgroup.c |   19 +++++++------------
>  1 files changed, 7 insertions(+), 12 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index fe00b3b..33ba756 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -84,7 +84,7 @@ struct cgroupfs_root {
>        /* Tracks how many cgroups are currently defined in hierarchy.*/
>        int number_of_cgroups;
>
> -       /* A list running through the mounted hierarchies */
> +       /* A list running through the active hierarchies */
>        struct list_head root_list;
>
>        /* Hierarchy-specific flags */
> @@ -149,8 +149,8 @@ static int notify_on_release(const struct cgroup *cgrp)
>  #define for_each_subsys(_root, _ss) \
>  list_for_each_entry(_ss, &_root->subsys_list, sibling)
>
> -/* for_each_root() allows you to iterate across the active hierarchies */
> -#define for_each_root(_root) \
> +/* for_each_active_root() allows you to iterate across the active hierarchies */
> +#define for_each_active_root(_root) \
>  list_for_each_entry(_root, &roots, root_list)
>
>  /* the list of cgroups eligible for automatic release. Protected by
> @@ -1114,10 +1114,9 @@ static void cgroup_kill_sb(struct super_block *sb) {
>        }
>        write_unlock(&css_set_lock);
>
> -       if (!list_empty(&root->root_list)) {
> -               list_del(&root->root_list);
> -               root_count--;
> -       }
> +       list_del(&root->root_list);
> +       root_count--;
> +
>        mutex_unlock(&cgroup_mutex);
>
>        kfree(root);
> @@ -2561,7 +2560,6 @@ int __init cgroup_init_early(void)
>        INIT_HLIST_NODE(&init_css_set.hlist);
>        css_set_count = 1;
>        init_cgroup_root(&rootnode);
> -       list_add(&rootnode.root_list, &roots);
>        root_count = 1;
>        init_task.cgroups = &init_css_set;
>
> @@ -2668,15 +2666,12 @@ static int proc_cgroup_show(struct seq_file *m, void *v)
>
>        mutex_lock(&cgroup_mutex);
>
> -       for_each_root(root) {
> +       for_each_active_root(root) {
>                struct cgroup_subsys *ss;
>                struct cgroup *cgrp;
>                int subsys_id;
>                int count = 0;
>
> -               /* Skip this hierarchy if it has no active subsystems */
> -               if (!root->actual_subsys_bits)
> -                       continue;
>                seq_printf(m, "%lu:", root->subsys_bits);
>                for_each_subsys(root, ss)
>                        seq_printf(m, "%s%s", count++ ? "," : "", ss->name);
> --
> 1.5.4.rc3
>
>
