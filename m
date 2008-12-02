From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/3] cgroups: introduce link_css_set() to remove duplicate
	code
Date: Mon, 1 Dec 2008 16:20:42 -0800
Message-ID: <6599ad830812011620ld861aabgc70846a07ce1d487__20246.5066373863$1228177475$gmane$org@mail.gmail.com>
References: <492FC1C2.9050001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <492FC1C2.9050001-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
> Add a common function link_css_set() to link a css_set to a cgroup.
>
> Signed-off-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Overall the change looks like an improvement, but:

- the new function could do with comments about the semantics of its
parameters, particularly tmp_cg_links.
- why are you renaming cgrp -> root_cgrp in cgroup_get_sb()? That
seems like unnecessary churn.

Thanks,

Paul

> ---
>  kernel/cgroup.c |   62 +++++++++++++++++++++---------------------------------
>  1 files changed, 24 insertions(+), 38 deletions(-)
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 4e50e97..1442077 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -385,6 +385,19 @@ static int allocate_cg_links(int count, struct list_head *tmp)
>        return 0;
>  }
>
> +static void link_css_set(struct list_head *tmp_cg_links,
> +                        struct css_set *cg, struct cgroup *cgrp)
> +{
> +       struct cg_cgroup_link *link;
> +
> +       BUG_ON(list_empty(tmp_cg_links));
> +       link = list_first_entry(tmp_cg_links, struct cg_cgroup_link,
> +                               cgrp_link_list);
> +       link->cg = cg;
> +       list_move(&link->cgrp_link_list, &cgrp->css_sets);
> +       list_add(&link->cg_link_list, &cg->cg_links);
> +}
> +
>  /*
>  * find_css_set() takes an existing cgroup group and a
>  * cgroup object, and returns a css_set object that's
> @@ -400,7 +413,6 @@ static struct css_set *find_css_set(
>        int i;
>
>        struct list_head tmp_cg_links;
> -       struct cg_cgroup_link *link;
>
>        struct hlist_head *hhead;
>
> @@ -445,26 +457,11 @@ static struct css_set *find_css_set(
>                 * only do it for the first subsystem in each
>                 * hierarchy
>                 */
> -               if (ss->root->subsys_list.next == &ss->sibling) {
> -                       BUG_ON(list_empty(&tmp_cg_links));
> -                       link = list_entry(tmp_cg_links.next,
> -                                         struct cg_cgroup_link,
> -                                         cgrp_link_list);
> -                       list_del(&link->cgrp_link_list);
> -                       list_add(&link->cgrp_link_list, &cgrp->css_sets);
> -                       link->cg = res;
> -                       list_add(&link->cg_link_list, &res->cg_links);
> -               }
> -       }
> -       if (list_empty(&rootnode.subsys_list)) {
> -               link = list_entry(tmp_cg_links.next,
> -                                 struct cg_cgroup_link,
> -                                 cgrp_link_list);
> -               list_del(&link->cgrp_link_list);
> -               list_add(&link->cgrp_link_list, &dummytop->css_sets);
> -               link->cg = res;
> -               list_add(&link->cg_link_list, &res->cg_links);
> +               if (ss->root->subsys_list.next == &ss->sibling)
> +                       link_css_set(&tmp_cg_links, res, cgrp);
>        }
> +       if (list_empty(&rootnode.subsys_list))
> +               link_css_set(&tmp_cg_links, res, dummytop);
>
>        BUG_ON(!list_empty(&tmp_cg_links));
>
> @@ -992,7 +989,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>                root = NULL;
>        } else {
>                /* New superblock */
> -               struct cgroup *cgrp = &root->top_cgroup;
> +               struct cgroup *root_cgrp = &root->top_cgroup;
>                struct inode *inode;
>                int i;
>
> @@ -1033,7 +1030,7 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>                list_add(&root->root_list, &roots);
>                root_count++;
>
> -               sb->s_root->d_fsdata = &root->top_cgroup;
> +               sb->s_root->d_fsdata = root_cgrp;
>                root->top_cgroup.dentry = sb->s_root;
>
>                /* Link the top cgroup in this hierarchy into all
> @@ -1044,29 +1041,18 @@ static int cgroup_get_sb(struct file_system_type *fs_type,
>                        struct hlist_node *node;
>                        struct css_set *cg;
>
> -                       hlist_for_each_entry(cg, node, hhead, hlist) {
> -                               struct cg_cgroup_link *link;
> -
> -                               BUG_ON(list_empty(&tmp_cg_links));
> -                               link = list_entry(tmp_cg_links.next,
> -                                                 struct cg_cgroup_link,
> -                                                 cgrp_link_list);
> -                               list_del(&link->cgrp_link_list);
> -                               link->cg = cg;
> -                               list_add(&link->cgrp_link_list,
> -                                        &root->top_cgroup.css_sets);
> -                               list_add(&link->cg_link_list, &cg->cg_links);
> -                       }
> +                       hlist_for_each_entry(cg, node, hhead, hlist)
> +                               link_css_set(&tmp_cg_links, cg, root_cgrp);
>                }
>                write_unlock(&css_set_lock);
>
>                free_cg_links(&tmp_cg_links);
>
> -               BUG_ON(!list_empty(&cgrp->sibling));
> -               BUG_ON(!list_empty(&cgrp->children));
> +               BUG_ON(!list_empty(&root_cgrp->sibling));
> +               BUG_ON(!list_empty(&root_cgrp->children));
>                BUG_ON(root->number_of_cgroups != 1);
>
> -               cgroup_populate_dir(cgrp);
> +               cgroup_populate_dir(root_cgrp);
>                mutex_unlock(&inode->i_mutex);
>                mutex_unlock(&cgroup_mutex);
>        }
> --
> 1.5.4.rc3
>
