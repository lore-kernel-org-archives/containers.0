From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -mm 1/3] cgroup: use a hash table for css_set finding
Date: Thu, 3 Apr 2008 16:24:59 +0900
Message-ID: <20080403162459.4a90d574.kamezawa.hiroyu__35156.876469455$1207207389$gmane$org@jp.fujitsu.com>
References: <47F470AB.2070904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47F470AB.2070904-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
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
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org


On Thu, 03 Apr 2008 13:52:43 +0800
Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> +/* hash table for cgroup groups. This improves the performance to
> + * find an existing css_set */
> +#define CSS_SET_HASH_BITS	7
> +#define CSS_SET_TABLE_SIZE	(1 << CSS_SET_HASH_BITS)
> +static struct hlist_head css_set_table[CSS_SET_TABLE_SIZE];

How above number is selected ?

> +static struct hlist_head *css_set_hash(struct cgroup_subsys_state *css[])
> +{
> +	int i;
> +	int index;
> +	unsigned long tmp = 0UL;
> +
> +	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++)
> +		tmp += (unsigned long)css[i];
> +

maybe css[i]'s lower 2-3 bits will be ignored. because thery are always 0.

And I don't like "+" for hash. how about
==
	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++)
	unsigned long x;
	x = (unsigned long)css[i];
	tmp = (x >> 16) ^ (x & 0xffff)
==
or some func, which uses full bits.


> +	index = hash_long(tmp, CSS_SET_HASH_BITS);
> +
> +	return &css_set_table[index];
> +}
> +
>  /* We don't maintain the lists running through each css_set to its
>   * task until after the first call to cgroup_iter_start(). This
>   * reduces the fork()/exit() overhead for people who have cgroups
> @@ -219,6 +240,7 @@ static int use_task_css_set_links;
>  static void unlink_css_set(struct css_set *cg)
>  {
>  	write_lock(&css_set_lock);
> +	hlist_del(&cg->hlist);
>  	list_del(&cg->list);
>  	css_set_count--;

This css_set_lock is worth to be rwlock ?
how about per hashline spinlock ? (but per-hashline seems overkill..)

Thanks,
-Kame
