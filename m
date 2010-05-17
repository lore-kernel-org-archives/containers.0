From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] [PATCH] memcg: cleanup memory thresholds
Date: Mon, 17 May 2010 13:17:47 -0700
Message-ID: <AANLkTilPPYOQ62mzDA4ttrXnkwxN1sYZWK0M871x4Eso__21900.683877948$1274127612$gmane$org@mail.gmail.com>
References: <1273363872-8031-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1273363872-8031-1-git-send-email-kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sat, May 8, 2010 at 5:11 PM, Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> w=
rote:
> Introduce struct mem_cgroup_thresholds. It helps to reduce number of
> checks of thresholds type (memory or mem+swap).
>
> Signed-off-by: Kirill A. Shutemov <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>

Acked-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks,
Paul

> ---
> =A0mm/memcontrol.c | =A0151 ++++++++++++++++++++++++---------------------=
----------
> =A01 files changed, 66 insertions(+), 85 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a6d2a4c..a6c6268 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -158,6 +158,18 @@ struct mem_cgroup_threshold_ary {
> =A0 =A0 =A0 =A0/* Array of thresholds */
> =A0 =A0 =A0 =A0struct mem_cgroup_threshold entries[0];
> =A0};
> +
> +struct mem_cgroup_thresholds {
> + =A0 =A0 =A0 /* Primary thresholds array */
> + =A0 =A0 =A0 struct mem_cgroup_threshold_ary *primary;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Spare threshold array.
> + =A0 =A0 =A0 =A0* It needed to make mem_cgroup_unregister_event() "never=
 fail".
> + =A0 =A0 =A0 =A0* It must be able to store at least primary->size - 1 en=
tires.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct mem_cgroup_threshold_ary *spare;
> +};
> +
> =A0/* for OOM */
> =A0struct mem_cgroup_eventfd_list {
> =A0 =A0 =A0 =A0struct list_head list;
> @@ -224,20 +236,10 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0struct mutex thresholds_lock;
>
> =A0 =A0 =A0 =A0/* thresholds for memory usage. RCU-protected */
> - =A0 =A0 =A0 struct mem_cgroup_threshold_ary *thresholds;
> -
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Preallocated buffer to be used in mem_cgroup_unregiste=
r_event()
> - =A0 =A0 =A0 =A0* to make it "never fail".
> - =A0 =A0 =A0 =A0* It must be able to store at least thresholds->size - 1=
 entries.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 struct mem_cgroup_threshold_ary *__thresholds;
> + =A0 =A0 =A0 struct mem_cgroup_thresholds thresholds;
>
> =A0 =A0 =A0 =A0/* thresholds for mem+swap usage. RCU-protected */
> - =A0 =A0 =A0 struct mem_cgroup_threshold_ary *memsw_thresholds;
> -
> - =A0 =A0 =A0 /* the same as __thresholds, but for memsw_thresholds */
> - =A0 =A0 =A0 struct mem_cgroup_threshold_ary *__memsw_thresholds;
> + =A0 =A0 =A0 struct mem_cgroup_thresholds memsw_thresholds;
>
> =A0 =A0 =A0 =A0/* For oom notifier event fd */
> =A0 =A0 =A0 =A0struct list_head oom_notify;
> @@ -3438,9 +3440,9 @@ static void __mem_cgroup_threshold(struct mem_cgrou=
p *memcg, bool swap)
>
> =A0 =A0 =A0 =A0rcu_read_lock();
> =A0 =A0 =A0 =A0if (!swap)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 t =3D rcu_dereference(memcg->thresholds);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 t =3D rcu_dereference(memcg->thresholds.pri=
mary);
> =A0 =A0 =A0 =A0else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 t =3D rcu_dereference(memcg->memsw_threshol=
ds);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 t =3D rcu_dereference(memcg->memsw_threshol=
ds.primary);
>
> =A0 =A0 =A0 =A0if (!t)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto unlock;
> @@ -3514,91 +3516,78 @@ static int mem_cgroup_usage_register_event(struct=
 cgroup *cgrp,
> =A0 =A0 =A0 =A0struct cftype *cft, struct eventfd_ctx *eventfd, const cha=
r *args)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> - =A0 =A0 =A0 struct mem_cgroup_threshold_ary *thresholds, *thresholds_ne=
w;
> + =A0 =A0 =A0 struct mem_cgroup_thresholds *thresholds;
> + =A0 =A0 =A0 struct mem_cgroup_threshold_ary *new;
> =A0 =A0 =A0 =A0int type =3D MEMFILE_TYPE(cft->private);
> =A0 =A0 =A0 =A0u64 threshold, usage;
> - =A0 =A0 =A0 int size;
> - =A0 =A0 =A0 int i, ret;
> + =A0 =A0 =A0 int i, size, ret;
>
> =A0 =A0 =A0 =A0ret =3D res_counter_memparse_write_strategy(args, &thresho=
ld);
> =A0 =A0 =A0 =A0if (ret)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
>
> =A0 =A0 =A0 =A0mutex_lock(&memcg->thresholds_lock);
> +
> =A0 =A0 =A0 =A0if (type =3D=3D _MEM)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D memcg->thresholds;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D &memcg->thresholds;
> =A0 =A0 =A0 =A0else if (type =3D=3D _MEMSWAP)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D memcg->memsw_thresholds;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D &memcg->memsw_thresholds;
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
>
> =A0 =A0 =A0 =A0usage =3D mem_cgroup_usage(memcg, type =3D=3D _MEMSWAP);
>
> =A0 =A0 =A0 =A0/* Check if a threshold crossed before adding a new one */
> - =A0 =A0 =A0 if (thresholds)
> + =A0 =A0 =A0 if (thresholds->primary)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__mem_cgroup_threshold(memcg, type =3D=3D =
_MEMSWAP);
>
> - =A0 =A0 =A0 if (thresholds)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 size =3D thresholds->size + 1;
> - =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 size =3D 1;
> + =A0 =A0 =A0 size =3D thresholds->primary ? thresholds->primary->size + =
1 : 1;
>
> =A0 =A0 =A0 =A0/* Allocate memory for new array of thresholds */
> - =A0 =A0 =A0 thresholds_new =3D kmalloc(sizeof(*thresholds_new) +
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size * sizeof(struct mem_cg=
roup_threshold),
> + =A0 =A0 =A0 new =3D kmalloc(sizeof(*new) + size * sizeof(struct mem_cgr=
oup_threshold),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0GFP_KERNEL);
> - =A0 =A0 =A0 if (!thresholds_new) {
> + =A0 =A0 =A0 if (!new) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D -ENOMEM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto unlock;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 thresholds_new->size =3D size;
> + =A0 =A0 =A0 new->size =3D size;
>
> =A0 =A0 =A0 =A0/* Copy thresholds (if any) to new array */
> - =A0 =A0 =A0 if (thresholds)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(thresholds_new->entries, thresholds-=
>entries,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds-=
>size *
> + =A0 =A0 =A0 if (thresholds->primary) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(new->entries, thresholds->primary->e=
ntries, (size - 1) *
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(str=
uct mem_cgroup_threshold));
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/* Add new threshold */
> - =A0 =A0 =A0 thresholds_new->entries[size - 1].eventfd =3D eventfd;
> - =A0 =A0 =A0 thresholds_new->entries[size - 1].threshold =3D threshold;
> + =A0 =A0 =A0 new->entries[size - 1].eventfd =3D eventfd;
> + =A0 =A0 =A0 new->entries[size - 1].threshold =3D threshold;
>
> =A0 =A0 =A0 =A0/* Sort thresholds. Registering of new threshold isn't tim=
e-critical */
> - =A0 =A0 =A0 sort(thresholds_new->entries, size,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sizeof(struct mem_cgroup_th=
reshold),
> + =A0 =A0 =A0 sort(new->entries, size, sizeof(struct mem_cgroup_threshold=
),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compare_thresholds, NULL);
>
> =A0 =A0 =A0 =A0/* Find current threshold */
> - =A0 =A0 =A0 thresholds_new->current_threshold =3D -1;
> + =A0 =A0 =A0 new->current_threshold =3D -1;
> =A0 =A0 =A0 =A0for (i =3D 0; i < size; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (thresholds_new->entries[i].threshold < =
usage) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new->entries[i].threshold < usage) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* thresholds_new->curren=
t_threshold will not be used
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* until rcu_assign_point=
er(), so it's safe to increment
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* new->current_threshold=
 will not be used until
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* rcu_assign_pointer(), =
so it's safe to increment
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * it here.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++thresholds_new->current_t=
hreshold;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++new->current_threshold;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (type =3D=3D _MEM)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(memcg->thresholds, thres=
holds_new);
> - =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(memcg->memsw_thresholds,=
 thresholds_new);
> + =A0 =A0 =A0 /* Free old spare buffer and save old primary buffer as spa=
re */
> + =A0 =A0 =A0 kfree(thresholds->spare);
> + =A0 =A0 =A0 thresholds->spare =3D thresholds->primary;
> +
> + =A0 =A0 =A0 rcu_assign_pointer(thresholds->primary, new);
>
> =A0 =A0 =A0 =A0/* To be sure that nobody uses thresholds */
> =A0 =A0 =A0 =A0synchronize_rcu();
>
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Free old preallocated buffer and use thresholds as new
> - =A0 =A0 =A0 =A0* preallocated buffer.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (type =3D=3D _MEM) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(memcg->__thresholds);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->__thresholds =3D thresholds;
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(memcg->__memsw_thresholds);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->__memsw_thresholds =3D thresholds;
> - =A0 =A0 =A0 }
> =A0unlock:
> =A0 =A0 =A0 =A0mutex_unlock(&memcg->thresholds_lock);
>
> @@ -3609,17 +3598,17 @@ static void mem_cgroup_usage_unregister_event(str=
uct cgroup *cgrp,
> =A0 =A0 =A0 =A0struct cftype *cft, struct eventfd_ctx *eventfd)
> =A0{
> =A0 =A0 =A0 =A0struct mem_cgroup *memcg =3D mem_cgroup_from_cont(cgrp);
> - =A0 =A0 =A0 struct mem_cgroup_threshold_ary *thresholds, *thresholds_ne=
w;
> + =A0 =A0 =A0 struct mem_cgroup_thresholds *thresholds;
> + =A0 =A0 =A0 struct mem_cgroup_threshold_ary *new;
> =A0 =A0 =A0 =A0int type =3D MEMFILE_TYPE(cft->private);
> =A0 =A0 =A0 =A0u64 usage;
> - =A0 =A0 =A0 int size =3D 0;
> - =A0 =A0 =A0 int i, j;
> + =A0 =A0 =A0 int i, j, size;
>
> =A0 =A0 =A0 =A0mutex_lock(&memcg->thresholds_lock);
> =A0 =A0 =A0 =A0if (type =3D=3D _MEM)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D memcg->thresholds;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D &memcg->thresholds;
> =A0 =A0 =A0 =A0else if (type =3D=3D _MEMSWAP)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D memcg->memsw_thresholds;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds =3D &memcg->memsw_thresholds;
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
>
> @@ -3635,53 +3624,45 @@ static void mem_cgroup_usage_unregister_event(str=
uct cgroup *cgrp,
> =A0 =A0 =A0 =A0__mem_cgroup_threshold(memcg, type =3D=3D _MEMSWAP);
>
> =A0 =A0 =A0 =A0/* Calculate new number of threshold */
> - =A0 =A0 =A0 for (i =3D 0; i < thresholds->size; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (thresholds->entries[i].eventfd !=3D eve=
ntfd)
> + =A0 =A0 =A0 size =3D 0;
> + =A0 =A0 =A0 for (i =3D 0; i < thresholds->primary->size; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (thresholds->primary->entries[i].eventfd=
 !=3D eventfd)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0size++;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 /* Use preallocated buffer for new array of thresholds */
> - =A0 =A0 =A0 if (type =3D=3D _MEM)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds_new =3D memcg->__thresholds;
> - =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds_new =3D memcg->__memsw_threshold=
s;
> + =A0 =A0 =A0 new =3D thresholds->spare;
>
> =A0 =A0 =A0 =A0/* Set thresholds array to NULL if we don't have threshold=
s */
> =A0 =A0 =A0 =A0if (!size) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(thresholds_new);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds_new =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(new);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto swap_buffers;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 thresholds_new->size =3D size;
> + =A0 =A0 =A0 new->size =3D size;
>
> =A0 =A0 =A0 =A0/* Copy thresholds and find current threshold */
> - =A0 =A0 =A0 thresholds_new->current_threshold =3D -1;
> - =A0 =A0 =A0 for (i =3D 0, j =3D 0; i < thresholds->size; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (thresholds->entries[i].eventfd =3D=3D e=
ventfd)
> + =A0 =A0 =A0 new->current_threshold =3D -1;
> + =A0 =A0 =A0 for (i =3D 0, j =3D 0; i < thresholds->primary->size; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (thresholds->primary->entries[i].eventfd=
 =3D=3D eventfd)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 thresholds_new->entries[j] =3D thresholds->=
entries[i];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (thresholds_new->entries[j].threshold < =
usage) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->entries[j] =3D thresholds->primary->en=
tries[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new->entries[j].threshold < usage) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* thresholds_new->curren=
t_threshold will not be used
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* new->current_threshold=
 will not be used
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * until rcu_assign_pointe=
r(), so it's safe to increment
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * it here.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++thresholds_new->current_t=
hreshold;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++new->current_threshold;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0j++;
> =A0 =A0 =A0 =A0}
>
> =A0swap_buffers:
> - =A0 =A0 =A0 /* Swap thresholds array and preallocated buffer */
> - =A0 =A0 =A0 if (type =3D=3D _MEM) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->__thresholds =3D thresholds;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(memcg->thresholds, thres=
holds_new);
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->__memsw_thresholds =3D thresholds;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(memcg->memsw_thresholds,=
 thresholds_new);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 /* Swap primary and spare array */
> + =A0 =A0 =A0 thresholds->spare =3D thresholds->primary;
> + =A0 =A0 =A0 rcu_assign_pointer(thresholds->primary, new);
>
> =A0 =A0 =A0 =A0/* To be sure that nobody uses thresholds */
> =A0 =A0 =A0 =A0synchronize_rcu();
> --
> 1.7.0.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo-Bw31MaZKKs0EbZ0PF+XxCw@public.gmane.org =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org"> email-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org </a>
>
