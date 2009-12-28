From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/4] cgroups: subsystem module loading interface
Date: Mon, 28 Dec 2009 14:32:20 +0800
Message-ID: <4B3850F4.4090203__24115.1847913445$1261981980$gmane$org@cn.fujitsu.com>
References: <20091221203253.GA5683@andrew.cmu.edu>
	<20091221203613.GC5683@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091221203613.GC5683-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

> Add interface between cgroups subsystem management and module loading
> 
> From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
> 
> This patch implements rudimentary module-loading support for cgroups - namely,
> a cgroup_load_subsys (similar to cgroup_init_subsys) for use as a module
> initcall, and a struct module pointer in struct cgroup_subsys.
> 
> Several functions that might be wanted by modules have had EXPORT_SYMBOL added
> to them, but it's unclear exactly which functions want it and which won't.
> 
> Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

Acked-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Some small nitpicks:

> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2477,6 +2477,7 @@ int cgroup_add_file(struct cgroup *cgrp,
>  		error = PTR_ERR(dentry);
>  	return error;
>  }
> +EXPORT_SYMBOL_GPL(cgroup_add_file);

I got compile errors, because you forgot to include <linux/module.h>

...
> +	write_lock(&css_set_lock);
> +	for (i = 0; i < CSS_SET_TABLE_SIZE; i++) {
> +		struct css_set *cg;
> +		struct hlist_node *node, *tmp;
> +		struct hlist_head *bucket = &css_set_table[i], *new_bucket;

Please add a blank line between variable declaration and other code.

And elsewhere in this patchset.

> +		hlist_for_each_entry_safe(cg, node, tmp, bucket, hlist) {
> +			/* skip entries that we already rehashed */
> +			if (cg->subsys[ss->subsys_id])
> +				continue;
> +			/* remove existing entry */
> +			hlist_del(&cg->hlist);
> +			/* set new value */
> +			cg->subsys[ss->subsys_id] = css;
> +			/* recompute hash and restore entry */
> +			new_bucket = css_set_hash(cg->subsys);
> +			hlist_add_head(&cg->hlist, new_bucket);
> +		}
> +	}
> +	write_unlock(&css_set_lock);
