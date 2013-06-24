From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] cgroup: implement for_each_[builtin_]subsys()
Date: Mon, 24 Jun 2013 18:50:42 +0800
Message-ID: <51C82482.9020902@huawei.com>
References: <1371864854-28364-1-git-send-email-tj@kernel.org>
	<1371864854-28364-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1371864854-28364-7-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On 2013/6/22 9:34, Tejun Heo wrote:
> There are quite a few places where all loaded [builtin] subsys are
> iterated.  Implement for_each_[builtin_]subsys() and replace manual
> iterations with those to simplify those places a bit.  The new
> iterators automatically skip NULL subsystems.  This shouldn't cause
> any functional difference.
> 
> Iteration loops which scan all subsystems and then skipping modular
> ones explicitly are converted to use for_each_builtin_subsys().
> 
> While at it, reorder variable declarations and adjust whitespaces a
> bit in the affected functions.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  kernel/cgroup.c | 143 ++++++++++++++++++++++++++------------------------------
>  1 file changed, 67 insertions(+), 76 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index c4bbafb..a890b56 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -259,6 +259,27 @@ static int notify_on_release(const struct cgroup *cgrp)
>  	return test_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->flags);
>  }
>  
> +/**
> + * for_each_subsys - iterate all loaded cgroup subsystems
> + * @ss: the iteration cursor
> + * @i: the index of @ss, CGROUP_SUBSYS_COUNT after reaching the end
> + */
> +#define for_each_subsys(ss, i)						\

This should be called with cgroup_mutex held, so how about add a comment or
a lock assert for it?

> +	for ((i) = 0; (i) < CGROUP_SUBSYS_COUNT; (i)++)			\
> +		if (!((ss) = cgroup_subsys[i])) { }			\
> +		else
> +
> +/**
> + * for_each_builtin_subsys - iterate all built-in cgroup subsystems
> + * @ss: the iteration cursor
> + * @i: the index of @ss, CGROUP_BUILTIN_SUBSYS_COUNT after reaching the end
> + *
> + * Bulit-in subsystems are always present.
> + */
> +#define for_each_builtin_subsys(ss, i)					\
> +	for ((i) = 0; (i) < CGROUP_BUILTIN_SUBSYS_COUNT &&		\
> +	     (((ss) = cgroup_subsys[i]) || true); (i)++)

Why "true" is needed here? given ss can't be NULL.

> +
>  /* iterate each subsystem attached to a hierarchy */
>  #define for_each_root_subsys(root, ss)					\
>  	list_for_each_entry((ss), &(root)->subsys_list, sibling)
> @@ -356,10 +377,11 @@ static DEFINE_HASHTABLE(css_set_table, CSS_SET_HASH_BITS);
>  
=
