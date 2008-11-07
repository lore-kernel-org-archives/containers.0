From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -last version] freezer_cg: disable writing freezer.state
	of root  cgroup
Date: Fri, 07 Nov 2008 14:58:53 +0800
Message-ID: <4913E72D.3060108__3093.3584007018$1226041461$gmane$org@cn.fujitsu.com>
References: <491245F1.5070707@cn.fujitsu.com>
	<6599ad830811051724p1f97026fl96be5efe38b33152@mail.gmail.com>
	<49124DFF.1090702@cn.fujitsu.com>
	<49125006.4050206@cn.fujitsu.com> <4912A73C.4080308@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4912A73C.4080308-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

> I would make a small macro is_root_freezer() to show explicitly
> what we are testing and use the CSS_ROOT bit to test. That's what
> the CSS_ROOT bit is for Paul ?
> 

I think yes CSS_ROOT can be used, though currently CSS_ROOT is used in
cgroup internal only (in css_get() and css_put()).

> if yes, here's a possible result is below. 
> 

is_root_freezer() looks a bit better, but I don't have strong option about
this change, the original code and the comment is enough to explain what
we are doing.

> C.
> 
> Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
> ---
>  kernel/cgroup_freezer.c |   15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> Index: 2.6.27-lxc/kernel/cgroup_freezer.c
> ===================================================================
> --- 2.6.27-lxc.orig/kernel/cgroup_freezer.c
> +++ 2.6.27-lxc/kernel/cgroup_freezer.c
> @@ -47,6 +47,11 @@ static inline struct freezer *task_freez
>  			    struct freezer, css);
>  }
>  
> +static inline int is_root_freezer(struct freezer *freezer)
> +{
> +	return test_bit(CSS_ROOT, &freezer->css.flags);
> +}
> +
>  int cgroup_frozen(struct task_struct *task)
>  {
>  	struct freezer *freezer;
> @@ -190,6 +195,13 @@ static void freezer_fork(struct cgroup_s
>  	freezer = task_freezer(task);
>  	task_unlock(task);
>  
> +	/*
> +	 * The root cgroup is non-freezable, so we can skip the
> +	 * following check.
> +	 */
> +	if (is_root_freezer(freezer))
> +		return;
> +
>  	BUG_ON(freezer->state == CGROUP_FROZEN);
>  	spin_lock_irq(&freezer->lock);
>  	/* Locking avoids race with FREEZING -> THAWED transitions. */
> @@ -363,6 +375,9 @@ static struct cftype files[] = {
>  
>  static int freezer_populate(struct cgroup_subsys *ss, struct cgroup *cgroup)
>  {
> +	if (is_root_freezer(cgroup_freezer(cgroup)))
> +		return 0;
> +
>  	return cgroup_add_files(cgroup, ss, files, ARRAY_SIZE(files));
>  }
> 
