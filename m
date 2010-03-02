From: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mmotm 2/3] memcg: dirty pages accounting and limiting
	infrastructure
Date: Tue, 2 Mar 2010 10:08:17 -0800
Message-ID: <49b004811003021008t4fae71bbu8d56192e48c32f39__14544.9576004923$1267553361$gmane$org@mail.gmail.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-3-git-send-email-arighi@develer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1267478620-5276-3-git-send-email-arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Comments below.  Yet to be tested on my end, but I will test it.

On Mon, Mar 1, 2010 at 1:23 PM, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:
> Infrastructure to account dirty pages per cgroup and add dirty limit
> interfaces in the cgroupfs:
>
> =A0- Direct write-out: memory.dirty_ratio, memory.dirty_bytes
>
> =A0- Background write-out: memory.dirty_background_ratio, memory.dirty_ba=
ckground_bytes
>
> Signed-off-by: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
> ---
> =A0include/linux/memcontrol.h | =A0 77 ++++++++++-
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0336 ++++++++++++++++++++++=
++++++++++++++++++----
> =A02 files changed, 384 insertions(+), 29 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 1f9b119..cc88b2e 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -19,12 +19,50 @@
>
> =A0#ifndef _LINUX_MEMCONTROL_H
> =A0#define _LINUX_MEMCONTROL_H
> +
> +#include <linux/writeback.h>
> =A0#include <linux/cgroup.h>
> +
> =A0struct mem_cgroup;
> =A0struct page_cgroup;
> =A0struct page;
> =A0struct mm_struct;
>
> +/* Cgroup memory statistics items exported to the kernel */
> +enum mem_cgroup_page_stat_item {
> + =A0 =A0 =A0 MEMCG_NR_DIRTYABLE_PAGES,
> + =A0 =A0 =A0 MEMCG_NR_RECLAIM_PAGES,
> + =A0 =A0 =A0 MEMCG_NR_WRITEBACK,
> + =A0 =A0 =A0 MEMCG_NR_DIRTY_WRITEBACK_PAGES,
> +};
> +
> +/*
> + * Statistics for memory cgroup.
> + */
> +enum mem_cgroup_stat_index {
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* For MEM_CONTAINER_TYPE_ALL, usage =3D pagecache + rss.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 MEM_CGROUP_STAT_CACHE, =A0 =A0 /* # of pages charged as cac=
he */
> + =A0 =A0 =A0 MEM_CGROUP_STAT_RSS, =A0 =A0 =A0 /* # of pages charged as a=
non rss */
> + =A0 =A0 =A0 MEM_CGROUP_STAT_FILE_MAPPED, =A0/* # of pages charged as fi=
le rss */
> + =A0 =A0 =A0 MEM_CGROUP_STAT_PGPGIN_COUNT, =A0 /* # of pages paged in */
> + =A0 =A0 =A0 MEM_CGROUP_STAT_PGPGOUT_COUNT, =A0/* # of pages paged out */
> + =A0 =A0 =A0 MEM_CGROUP_STAT_EVENTS, /* sum of pagein + pageout for inte=
rnal use */
> + =A0 =A0 =A0 MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> + =A0 =A0 =A0 MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/ou=
t.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 used by soft limit implementation */
> + =A0 =A0 =A0 MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/o=
ut.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 used by threshold implementation */
> + =A0 =A0 =A0 MEM_CGROUP_STAT_FILE_DIRTY, =A0 /* # of dirty pages in page=
 cache */
> + =A0 =A0 =A0 MEM_CGROUP_STAT_WRITEBACK, =A0 /* # of pages under writebac=
k */
> + =A0 =A0 =A0 MEM_CGROUP_STAT_WRITEBACK_TEMP, =A0 /* # of pages under wri=
teback using
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 temporary buffers */
> + =A0 =A0 =A0 MEM_CGROUP_STAT_UNSTABLE_NFS, =A0 /* # of NFS unstable page=
s */
> +
> + =A0 =A0 =A0 MEM_CGROUP_STAT_NSTATS,
> +};
> +
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> =A0/*
> =A0* All "charge" functions with gfp_mask should use GFP_KERNEL or
> @@ -117,6 +155,13 @@ extern void mem_cgroup_print_oom_info(struct mem_cgr=
oup *memcg,
> =A0extern int do_swap_account;
> =A0#endif
>
> +extern long mem_cgroup_dirty_ratio(void);
> +extern unsigned long mem_cgroup_dirty_bytes(void);
> +extern long mem_cgroup_dirty_background_ratio(void);
> +extern unsigned long mem_cgroup_dirty_background_bytes(void);
> +
> +extern s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item item);
> +
> =A0static inline bool mem_cgroup_disabled(void)
> =A0{
> =A0 =A0 =A0 =A0if (mem_cgroup_subsys.disabled)
> @@ -125,7 +170,8 @@ static inline bool mem_cgroup_disabled(void)
> =A0}
>
> =A0extern bool mem_cgroup_oom_called(struct task_struct *task);
> -void mem_cgroup_update_file_mapped(struct page *page, int val);
> +void mem_cgroup_update_stat(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum mem_cgroup_stat_index =
idx, int val);
> =A0unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int ord=
er,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0gfp_t gfp_mask, int nid,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0int zid);
> @@ -300,8 +346,8 @@ mem_cgroup_print_oom_info(struct mem_cgroup *memcg, s=
truct task_struct *p)
> =A0{
> =A0}
>
> -static inline void mem_cgroup_update_file_mapped(struct page *page,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int val)
> +static inline void mem_cgroup_update_stat(struct page *page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum mem_cgroup_stat_index =
idx, int val)
> =A0{
> =A0}
>
> @@ -312,6 +358,31 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct z=
one *zone, int order,
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +static inline long mem_cgroup_dirty_ratio(void)
> +{
> + =A0 =A0 =A0 return vm_dirty_ratio;
> +}
> +
> +static inline unsigned long mem_cgroup_dirty_bytes(void)
> +{
> + =A0 =A0 =A0 return vm_dirty_bytes;
> +}
> +
> +static inline long mem_cgroup_dirty_background_ratio(void)
> +{
> + =A0 =A0 =A0 return dirty_background_ratio;
> +}
> +
> +static inline unsigned long mem_cgroup_dirty_background_bytes(void)
> +{
> + =A0 =A0 =A0 return dirty_background_bytes;
> +}
> +
> +static inline s64 mem_cgroup_page_stat(enum mem_cgroup_page_stat_item it=
em)
> +{
> + =A0 =A0 =A0 return -ENOMEM;
> +}
> +
> =A0#endif /* CONFIG_CGROUP_MEM_CONT */
>
> =A0#endif /* _LINUX_MEMCONTROL_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a443c30..e74cf66 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -66,31 +66,16 @@ static int really_do_swap_account __initdata =3D 1; /=
* for remember boot option*/
> =A0#define SOFTLIMIT_EVENTS_THRESH (1000)
> =A0#define THRESHOLDS_EVENTS_THRESH (100)
>
> -/*
> - * Statistics for memory cgroup.
> - */
> -enum mem_cgroup_stat_index {
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* For MEM_CONTAINER_TYPE_ALL, usage =3D pagecache + rss.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 MEM_CGROUP_STAT_CACHE, =A0 =A0 /* # of pages charged as cac=
he */
> - =A0 =A0 =A0 MEM_CGROUP_STAT_RSS, =A0 =A0 =A0 /* # of pages charged as a=
non rss */
> - =A0 =A0 =A0 MEM_CGROUP_STAT_FILE_MAPPED, =A0/* # of pages charged as fi=
le rss */
> - =A0 =A0 =A0 MEM_CGROUP_STAT_PGPGIN_COUNT, =A0 /* # of pages paged in */
> - =A0 =A0 =A0 MEM_CGROUP_STAT_PGPGOUT_COUNT, =A0/* # of pages paged out */
> - =A0 =A0 =A0 MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> - =A0 =A0 =A0 MEM_CGROUP_STAT_SOFTLIMIT, /* decrements on each page in/ou=
t.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 used by soft limit implementation */
> - =A0 =A0 =A0 MEM_CGROUP_STAT_THRESHOLDS, /* decrements on each page in/o=
ut.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 used by threshold implementation */
> -
> - =A0 =A0 =A0 MEM_CGROUP_STAT_NSTATS,
> -};
> -
> =A0struct mem_cgroup_stat_cpu {
> =A0 =A0 =A0 =A0s64 count[MEM_CGROUP_STAT_NSTATS];
> =A0};
>
> +/* Per cgroup page statistics */
> +struct mem_cgroup_page_stat {
> + =A0 =A0 =A0 enum mem_cgroup_page_stat_item item;
> + =A0 =A0 =A0 s64 value;
> +};
> +
> =A0/*
> =A0* per-zone information in memory controller.
> =A0*/
> @@ -157,6 +142,15 @@ struct mem_cgroup_threshold_ary {
> =A0static bool mem_cgroup_threshold_check(struct mem_cgroup *mem);
> =A0static void mem_cgroup_threshold(struct mem_cgroup *mem);
>
> +enum mem_cgroup_dirty_param {
> + =A0 =A0 =A0 MEM_CGROUP_DIRTY_RATIO,
> + =A0 =A0 =A0 MEM_CGROUP_DIRTY_BYTES,
> + =A0 =A0 =A0 MEM_CGROUP_DIRTY_BACKGROUND_RATIO,
> + =A0 =A0 =A0 MEM_CGROUP_DIRTY_BACKGROUND_BYTES,
> +
> + =A0 =A0 =A0 MEM_CGROUP_DIRTY_NPARAMS,
> +};
> +
> =A0/*
> =A0* The memory controller data structure. The memory controller controls=
 both
> =A0* page cache and RSS per cgroup. We would eventually like to provide
> @@ -205,6 +199,9 @@ struct mem_cgroup {
>
> =A0 =A0 =A0 =A0unsigned int =A0 =A0swappiness;
>
> + =A0 =A0 =A0 /* control memory cgroup dirty pages */
> + =A0 =A0 =A0 unsigned long dirty_param[MEM_CGROUP_DIRTY_NPARAMS];
> +
> =A0 =A0 =A0 =A0/* set when res.limit =3D=3D memsw.limit */
> =A0 =A0 =A0 =A0bool =A0 =A0 =A0 =A0 =A0 =A0memsw_is_minimum;
>
> @@ -1021,6 +1018,164 @@ static unsigned int get_swappiness(struct mem_cgr=
oup *memcg)
> =A0 =A0 =A0 =A0return swappiness;
> =A0}
>
> +static unsigned long get_dirty_param(struct mem_cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum mem_cgroup_dirty_param=
 idx)
> +{
> + =A0 =A0 =A0 unsigned long ret;
> +
> + =A0 =A0 =A0 VM_BUG_ON(idx >=3D MEM_CGROUP_DIRTY_NPARAMS);
> + =A0 =A0 =A0 spin_lock(&memcg->reclaim_param_lock);
> + =A0 =A0 =A0 ret =3D memcg->dirty_param[idx];
> + =A0 =A0 =A0 spin_unlock(&memcg->reclaim_param_lock);
> +
> + =A0 =A0 =A0 return ret;
> +}
> +

> +long mem_cgroup_dirty_ratio(void)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *memcg;
> + =A0 =A0 =A0 long ret =3D vm_dirty_ratio;
> +
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* It's possible that "current" may be moved to other cgr=
oup while we
> + =A0 =A0 =A0 =A0* access cgroup. But precise check is meaningless becaus=
e the task can
> + =A0 =A0 =A0 =A0* be moved after our access and writeback tends to take =
long time.
> + =A0 =A0 =A0 =A0* At least, "memcg" will not be freed under rcu_read_loc=
k().
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 memcg =3D mem_cgroup_from_task(current);
> + =A0 =A0 =A0 if (likely(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D get_dirty_param(memcg, MEM_CGROUP_D=
IRTY_RATIO);
> + =A0 =A0 =A0 rcu_read_unlock();
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +unsigned long mem_cgroup_dirty_bytes(void)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *memcg;
> + =A0 =A0 =A0 unsigned long ret =3D vm_dirty_bytes;
> +
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 memcg =3D mem_cgroup_from_task(current);
> + =A0 =A0 =A0 if (likely(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D get_dirty_param(memcg, MEM_CGROUP_D=
IRTY_BYTES);
> + =A0 =A0 =A0 rcu_read_unlock();
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +long mem_cgroup_dirty_background_ratio(void)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *memcg;
> + =A0 =A0 =A0 long ret =3D dirty_background_ratio;
> +
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 memcg =3D mem_cgroup_from_task(current);
> + =A0 =A0 =A0 if (likely(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D get_dirty_param(memcg, MEM_CGROUP_D=
IRTY_BACKGROUND_RATIO);
> + =A0 =A0 =A0 rcu_read_unlock();
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +unsigned long mem_cgroup_dirty_background_bytes(void)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *memcg;
> + =A0 =A0 =A0 unsigned long ret =3D dirty_background_bytes;
> +
> + =A0 =A0 =A0 if (mem_cgroup_disabled())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 memcg =3D mem_cgroup_from_task(current);
> + =A0 =A0 =A0 if (likely(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D get_dirty_param(memcg, MEM_CGROUP_D=
IRTY_BACKGROUND_BYTES);
> + =A0 =A0 =A0 rcu_read_unlock();
> +
> + =A0 =A0 =A0 return ret;
> +}

Given that mem_cgroup_dirty_[background_]{ratio,bytes}() are similar,
should we refactor the majority of them into a single routine?

--
Greg
