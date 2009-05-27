From: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 02/20] io-controller: Common flat fair queuing code in
	elevaotor layer
Date: Wed, 27 May 2009 13:53:59 -0700
Message-ID: <e98e18940905271353kc6890dbxa1ea63026c8faec1__23167.2382251874$1243459627$gmane$org@mail.gmail.com>
References: <1243377729-2176-1-git-send-email-vgoyal@redhat.com>
	<1243377729-2176-3-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1243377729-2176-3-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jbaron-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, May 26, 2009 at 3:41 PM, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> This is common fair queuing code in elevator layer. This is controlled by
> config option CONFIG_ELV_FAIR_QUEUING. This patch initially only introduc=
es
> flat fair queuing support where there is only one group, "root group" and=
 all
> the tasks belong to root group.
>
> This elevator layer changes are backward compatible. That means any iosch=
eduler
> using old interfaces will continue to work.
>
> This code is essentially the CFQ code for fair queuing. The primary diffe=
rence
> is that flat rounding robin algorithm of CFQ has been replaced with BFQ (=
WF2Q+).
>
> Signed-off-by: Nauman Rafique <nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
> Signed-off-by: Paolo Valente <paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org>
> Signed-off-by: Aristeu Rozanski <aris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---
> =A0block/Kconfig.iosched =A0 =A0| =A0 13 +
> =A0block/Makefile =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0block/blk-sysfs.c =A0 =A0 =A0 =A0| =A0 25 +
> =A0block/elevator-fq.c =A0 =A0 =A0| 2078 ++++++++++++++++++++++++++++++++=
++++++++++++++
> =A0block/elevator-fq.h =A0 =A0 =A0| =A0488 +++++++++++
> =A0block/elevator.c =A0 =A0 =A0 =A0 | =A0 46 +-
> =A0include/linux/blkdev.h =A0 | =A0 =A05 +
> =A0include/linux/elevator.h | =A0 51 ++
> =A08 files changed, 2696 insertions(+), 11 deletions(-)
> =A0create mode 100644 block/elevator-fq.c
> =A0create mode 100644 block/elevator-fq.h
>
> diff --git a/block/Kconfig.iosched b/block/Kconfig.iosched
> index 7e803fc..3398134 100644
> --- a/block/Kconfig.iosched
> +++ b/block/Kconfig.iosched
> @@ -2,6 +2,19 @@ if BLOCK
>
> =A0menu "IO Schedulers"
>
> +config ELV_FAIR_QUEUING
> + =A0 =A0 =A0 bool "Elevator Fair Queuing Support"
> + =A0 =A0 =A0 default n
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 Traditionally only cfq had notion of multiple queues an=
d it did
> + =A0 =A0 =A0 =A0 fair queuing at its own. With the cgroups and need of c=
ontrolling
> + =A0 =A0 =A0 =A0 IO, now even the simple io schedulers like noop, deadli=
ne, as will
> + =A0 =A0 =A0 =A0 have one queue per cgroup and will need hierarchical fa=
ir queuing.
> + =A0 =A0 =A0 =A0 Instead of every io scheduler implementing its own fair=
 queuing
> + =A0 =A0 =A0 =A0 logic, this option enables fair queuing in elevator lay=
er so that
> + =A0 =A0 =A0 =A0 other ioschedulers can make use of it.
> + =A0 =A0 =A0 =A0 If unsure, say N.
> +
> =A0config IOSCHED_NOOP
> =A0 =A0 =A0 =A0bool
> =A0 =A0 =A0 =A0default y
> diff --git a/block/Makefile b/block/Makefile
> index e9fa4dd..94bfc6e 100644
> --- a/block/Makefile
> +++ b/block/Makefile
> @@ -15,3 +15,4 @@ obj-$(CONFIG_IOSCHED_CFQ) =A0 =A0 +=3D cfq-iosched.o
>
> =A0obj-$(CONFIG_BLOCK_COMPAT) =A0 =A0 +=3D compat_ioctl.o
> =A0obj-$(CONFIG_BLK_DEV_INTEGRITY) =A0 =A0 =A0 =A0+=3D blk-integrity.o
> +obj-$(CONFIG_ELV_FAIR_QUEUING) +=3D elevator-fq.o
> diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
> index 3ff9bba..082a273 100644
> --- a/block/blk-sysfs.c
> +++ b/block/blk-sysfs.c
> @@ -276,6 +276,26 @@ static struct queue_sysfs_entry queue_iostats_entry =
=3D {
> =A0 =A0 =A0 =A0.store =3D queue_iostats_store,
> =A0};
>
> +#ifdef CONFIG_ELV_FAIR_QUEUING
> +static struct queue_sysfs_entry queue_slice_idle_entry =3D {
> + =A0 =A0 =A0 .attr =3D {.name =3D "slice_idle", .mode =3D S_IRUGO | S_IW=
USR },
> + =A0 =A0 =A0 .show =3D elv_slice_idle_show,
> + =A0 =A0 =A0 .store =3D elv_slice_idle_store,
> +};
> +
> +static struct queue_sysfs_entry queue_slice_sync_entry =3D {
> + =A0 =A0 =A0 .attr =3D {.name =3D "slice_sync", .mode =3D S_IRUGO | S_IW=
USR },
> + =A0 =A0 =A0 .show =3D elv_slice_sync_show,
> + =A0 =A0 =A0 .store =3D elv_slice_sync_store,
> +};
> +
> +static struct queue_sysfs_entry queue_slice_async_entry =3D {
> + =A0 =A0 =A0 .attr =3D {.name =3D "slice_async", .mode =3D S_IRUGO | S_I=
WUSR },
> + =A0 =A0 =A0 .show =3D elv_slice_async_show,
> + =A0 =A0 =A0 .store =3D elv_slice_async_store,
> +};
> +#endif
> +
> =A0static struct attribute *default_attrs[] =3D {
> =A0 =A0 =A0 =A0&queue_requests_entry.attr,
> =A0 =A0 =A0 =A0&queue_ra_entry.attr,
> @@ -287,6 +307,11 @@ static struct attribute *default_attrs[] =3D {
> =A0 =A0 =A0 =A0&queue_nomerges_entry.attr,
> =A0 =A0 =A0 =A0&queue_rq_affinity_entry.attr,
> =A0 =A0 =A0 =A0&queue_iostats_entry.attr,
> +#ifdef CONFIG_ELV_FAIR_QUEUING
> + =A0 =A0 =A0 &queue_slice_idle_entry.attr,
> + =A0 =A0 =A0 &queue_slice_sync_entry.attr,
> + =A0 =A0 =A0 &queue_slice_async_entry.attr,
> +#endif
> =A0 =A0 =A0 =A0NULL,
> =A0};
>
> diff --git a/block/elevator-fq.c b/block/elevator-fq.c
> new file mode 100644
> index 0000000..c5cc080
> --- /dev/null
> +++ b/block/elevator-fq.c
> @@ -0,0 +1,2078 @@
> +/*
> + * BFQ: Hierarchical B-WF2Q+ scheduler.
> + *
> + * Based on ideas and code from CFQ:
> + * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
> + *
> + * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Paolo Valente <paolo.valente@unim=
ore.it>
> + */
> +
> +#include <linux/blkdev.h>
> +#include "elevator-fq.h"
> +#include <linux/blktrace_api.h>
> +
> +/* Values taken from cfq */
> +const int elv_slice_sync =3D HZ / 10;
> +int elv_slice_async =3D HZ / 25;
> +const int elv_slice_async_rq =3D 2;
> +int elv_slice_idle =3D HZ / 125;
> +static struct kmem_cache *elv_ioq_pool;
> +
> +#define ELV_SLICE_SCALE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(5)
> +#define ELV_HW_QUEUE_MIN =A0 =A0 =A0 (5)
> +#define IO_SERVICE_TREE_INIT =A0 ((struct io_service_tree) =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 { RB_ROOT, =
RB_ROOT, NULL, NULL, 0, 0 })
> +
> +static inline struct io_queue *elv_close_cooperator(struct request_queue=
 *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct io_queue *ioq, int probe);
> +struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0int extract);
> +
> +static inline int elv_prio_slice(struct elv_fq_data *efqd, int sync,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned short prio)
> +{
> + =A0 =A0 =A0 const int base_slice =3D efqd->elv_slice[sync];
> +
> + =A0 =A0 =A0 WARN_ON(prio >=3D IOPRIO_BE_NR);
> +
> + =A0 =A0 =A0 return base_slice + (base_slice/ELV_SLICE_SCALE * (4 - prio=
));
> +}
> +
> +static inline int
> +elv_prio_to_slice(struct elv_fq_data *efqd, struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 return elv_prio_slice(efqd, elv_ioq_sync(ioq), ioq->entity.=
ioprio);
> +}
> +
> +/* Mainly the BFQ scheduling code Follows */
> +
> +/*
> + * Shift for timestamp calculations. =A0This actually limits the maximum
> + * service allowed in one timestamp delta (small shift values increase i=
t),
> + * the maximum total weight that can be used for the queues in the system
> + * (big shift values increase it), and the period of virtual time wrapar=
ounds.
> + */
> +#define WFQ_SERVICE_SHIFT =A0 =A0 =A022
> +
> +/**
> + * bfq_gt - compare two timestamps.
> + * @a: first ts.
> + * @b: second ts.
> + *
> + * Return @a > @b, dealing with wrapping correctly.
> + */
> +static inline int bfq_gt(bfq_timestamp_t a, bfq_timestamp_t b)
> +{
> + =A0 =A0 =A0 return (s64)(a - b) > 0;
> +}
> +
> +/**
> + * bfq_delta - map service into the virtual time domain.
> + * @service: amount of service.
> + * @weight: scale factor.
> + */
> +static inline bfq_timestamp_t bfq_delta(bfq_service_t service,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 bfq_weight_t weight)
> +{
> + =A0 =A0 =A0 bfq_timestamp_t d =3D (bfq_timestamp_t)service << WFQ_SERVI=
CE_SHIFT;
> +
> + =A0 =A0 =A0 do_div(d, weight);
> + =A0 =A0 =A0 return d;
> +}
> +
> +/**
> + * bfq_calc_finish - assign the finish time to an entity.
> + * @entity: the entity to act upon.
> + * @service: the service to be charged to the entity.
> + */
> +static inline void bfq_calc_finish(struct io_entity *entity,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bfq_=
service_t service)
> +{
> + =A0 =A0 =A0 BUG_ON(entity->weight =3D=3D 0);
> +
> + =A0 =A0 =A0 entity->finish =3D entity->start + bfq_delta(service, entit=
y->weight);
> +}
> +
> +static inline struct io_queue *io_entity_to_ioq(struct io_entity *entity)
> +{
> + =A0 =A0 =A0 struct io_queue *ioq =3D NULL;
> +
> + =A0 =A0 =A0 BUG_ON(entity =3D=3D NULL);
> + =A0 =A0 =A0 if (entity->my_sched_data =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioq =3D container_of(entity, struct io_queu=
e, entity);
> + =A0 =A0 =A0 return ioq;
> +}
> +
> +/**
> + * bfq_entity_of - get an entity from a node.
> + * @node: the node field of the entity.
> + *
> + * Convert a node pointer to the relative entity. =A0This is used only
> + * to simplify the logic of some functions and not as the generic
> + * conversion mechanism because, e.g., in the tree walking functions,
> + * the check for a %NULL value would be redundant.
> + */
> +static inline struct io_entity *bfq_entity_of(struct rb_node *node)
> +{
> + =A0 =A0 =A0 struct io_entity *entity =3D NULL;
> +
> + =A0 =A0 =A0 if (node !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity =3D rb_entry(node, struct io_entity,=
 rb_node);
> +
> + =A0 =A0 =A0 return entity;
> +}
> +
> +/**
> + * bfq_extract - remove an entity from a tree.
> + * @root: the tree root.
> + * @entity: the entity to remove.
> + */
> +static inline void bfq_extract(struct rb_root *root, struct io_entity *e=
ntity)
> +{
> + =A0 =A0 =A0 BUG_ON(entity->tree !=3D root);
> +
> + =A0 =A0 =A0 entity->tree =3D NULL;
> + =A0 =A0 =A0 rb_erase(&entity->rb_node, root);
> +}
> +
> +/**
> + * bfq_idle_extract - extract an entity from the idle tree.
> + * @st: the service tree of the owning @entity.
> + * @entity: the entity being removed.
> + */
> +static void bfq_idle_extract(struct io_service_tree *st,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct io_e=
ntity *entity)
> +{
> + =A0 =A0 =A0 struct rb_node *next;
> + =A0 =A0 =A0 struct io_queue *ioq =3D io_entity_to_ioq(entity);
> +
> + =A0 =A0 =A0 BUG_ON(entity->tree !=3D &st->idle);
> +
> + =A0 =A0 =A0 if (entity =3D=3D st->first_idle) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 next =3D rb_next(&entity->rb_node);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 st->first_idle =3D bfq_entity_of(next);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (entity =3D=3D st->last_idle) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 next =3D rb_prev(&entity->rb_node);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 st->last_idle =3D bfq_entity_of(next);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 bfq_extract(&st->idle, entity);
> +
> + =A0 =A0 =A0 /* Delete queue from idle list */
> + =A0 =A0 =A0 if (ioq)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&ioq->queue_list);
> +}
> +
> +/**
> + * bfq_insert - generic tree insertion.
> + * @root: tree root.
> + * @entity: entity to insert.
> + *
> + * This is used for the idle and the active tree, since they are both
> + * ordered by finish time.
> + */
> +static void bfq_insert(struct rb_root *root, struct io_entity *entity)
> +{
> + =A0 =A0 =A0 struct io_entity *entry;
> + =A0 =A0 =A0 struct rb_node **node =3D &root->rb_node;
> + =A0 =A0 =A0 struct rb_node *parent =3D NULL;
> +
> + =A0 =A0 =A0 BUG_ON(entity->tree !=3D NULL);
> +
> + =A0 =A0 =A0 while (*node !=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 parent =3D *node;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D rb_entry(parent, struct io_entity=
, rb_node);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bfq_gt(entry->finish, entity->finish))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node =3D &parent->rb_left;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node =3D &parent->rb_right;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 rb_link_node(&entity->rb_node, parent, node);
> + =A0 =A0 =A0 rb_insert_color(&entity->rb_node, root);
> +
> + =A0 =A0 =A0 entity->tree =3D root;
> +}
> +
> +/**
> + * bfq_update_min - update the min_start field of a entity.
> + * @entity: the entity to update.
> + * @node: one of its children.
> + *
> + * This function is called when @entity may store an invalid value for
> + * min_start due to updates to the active tree. =A0The function =A0assum=
es
> + * that the subtree rooted at @node (which may be its left or its right
> + * child) has a valid min_start value.
> + */
> +static inline void bfq_update_min(struct io_entity *entity,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct rb_node *node)
> +{
> + =A0 =A0 =A0 struct io_entity *child;
> +
> + =A0 =A0 =A0 if (node !=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 child =3D rb_entry(node, struct io_entity, =
rb_node);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bfq_gt(entity->min_start, child->min_st=
art))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->min_start =3D child=
->min_start;
> + =A0 =A0 =A0 }
> +}
> +
> +/**
> + * bfq_update_active_node - recalculate min_start.
> + * @node: the node to update.
> + *
> + * @node may have changed position or one of its children may have moved,
> + * this function updates its min_start value. =A0The left and right subt=
rees
> + * are assumed to hold a correct min_start value.
> + */
> +static inline void bfq_update_active_node(struct rb_node *node)
> +{
> + =A0 =A0 =A0 struct io_entity *entity =3D rb_entry(node, struct io_entit=
y, rb_node);
> +
> + =A0 =A0 =A0 entity->min_start =3D entity->start;
> + =A0 =A0 =A0 bfq_update_min(entity, node->rb_right);
> + =A0 =A0 =A0 bfq_update_min(entity, node->rb_left);
> +}
> +
> +/**
> + * bfq_update_active_tree - update min_start for the whole active tree.
> + * @node: the starting node.
> + *
> + * @node must be the deepest modified node after an update. =A0This func=
tion
> + * updates its min_start using the values held by its children, assuming
> + * that they did not change, and then updates all the nodes that may have
> + * changed in the path to the root. =A0The only nodes that may have chan=
ged
> + * are the ones in the path or their siblings.
> + */
> +static void bfq_update_active_tree(struct rb_node *node)
> +{
> + =A0 =A0 =A0 struct rb_node *parent;
> +
> +up:
> + =A0 =A0 =A0 bfq_update_active_node(node);
> +
> + =A0 =A0 =A0 parent =3D rb_parent(node);
> + =A0 =A0 =A0 if (parent =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 if (node =3D=3D parent->rb_left && parent->rb_right !=3D NU=
LL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_update_active_node(parent->rb_right);
> + =A0 =A0 =A0 else if (parent->rb_left !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_update_active_node(parent->rb_left);
> +
> + =A0 =A0 =A0 node =3D parent;
> + =A0 =A0 =A0 goto up;
> +}
> +
> +/**
> + * bfq_active_insert - insert an entity in the active tree of its group/=
device.
> + * @st: the service tree of the entity.
> + * @entity: the entity being inserted.
> + *
> + * The active tree is ordered by finish time, but an extra key is kept
> + * per each node, containing the minimum value for the start times of
> + * its children (and the node itself), so it's possible to search for
> + * the eligible node with the lowest finish time in logarithmic time.
> + */
> +static void bfq_active_insert(struct io_service_tree *st,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct io_entity *entity)
> +{
> + =A0 =A0 =A0 struct rb_node *node =3D &entity->rb_node;
> +
> + =A0 =A0 =A0 bfq_insert(&st->active, entity);
> +
> + =A0 =A0 =A0 if (node->rb_left !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 node =3D node->rb_left;
> + =A0 =A0 =A0 else if (node->rb_right !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 node =3D node->rb_right;
> +
> + =A0 =A0 =A0 bfq_update_active_tree(node);
> +}
> +
> +/**
> + * bfq_ioprio_to_weight - calc a weight from an ioprio.
> + * @ioprio: the ioprio value to convert.
> + */
> +static bfq_weight_t bfq_ioprio_to_weight(int ioprio)
> +{
> + =A0 =A0 =A0 WARN_ON(ioprio < 0 || ioprio >=3D IOPRIO_BE_NR);
> + =A0 =A0 =A0 return IOPRIO_BE_NR - ioprio;
> +}
> +
> +void bfq_get_entity(struct io_entity *entity)
> +{
> + =A0 =A0 =A0 struct io_queue *ioq =3D io_entity_to_ioq(entity);
> +
> + =A0 =A0 =A0 if (ioq)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_get_ioq(ioq);
> +}
> +
> +void bfq_init_entity(struct io_entity *entity, struct io_group *iog)
> +{
> + =A0 =A0 =A0 entity->ioprio =3D entity->new_ioprio;
> + =A0 =A0 =A0 entity->ioprio_class =3D entity->new_ioprio_class;
> + =A0 =A0 =A0 entity->sched_data =3D &iog->sched_data;
> +}
> +
> +/**
> + * bfq_find_deepest - find the deepest node that an extraction can modif=
y.
> + * @node: the node being removed.
> + *
> + * Do the first step of an extraction in an rb tree, looking for the
> + * node that will replace @node, and returning the deepest node that
> + * the following modifications to the tree can touch. =A0If @node is the
> + * last node in the tree return %NULL.
> + */
> +static struct rb_node *bfq_find_deepest(struct rb_node *node)
> +{
> + =A0 =A0 =A0 struct rb_node *deepest;
> +
> + =A0 =A0 =A0 if (node->rb_right =3D=3D NULL && node->rb_left =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 deepest =3D rb_parent(node);
> + =A0 =A0 =A0 else if (node->rb_right =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 deepest =3D node->rb_left;
> + =A0 =A0 =A0 else if (node->rb_left =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 deepest =3D node->rb_right;
> + =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 deepest =3D rb_next(node);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (deepest->rb_right !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 deepest =3D deepest->rb_rig=
ht;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (rb_parent(deepest) !=3D node)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 deepest =3D rb_parent(deepe=
st);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return deepest;
> +}
> +
> +/**
> + * bfq_active_extract - remove an entity from the active tree.
> + * @st: the service_tree containing the tree.
> + * @entity: the entity being removed.
> + */
> +static void bfq_active_extract(struct io_service_tree *st,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct io_e=
ntity *entity)
> +{
> + =A0 =A0 =A0 struct rb_node *node;
> +
> + =A0 =A0 =A0 node =3D bfq_find_deepest(&entity->rb_node);
> + =A0 =A0 =A0 bfq_extract(&st->active, entity);
> +
> + =A0 =A0 =A0 if (node !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_update_active_tree(node);
> +}
> +
> +/**
> + * bfq_idle_insert - insert an entity into the idle tree.
> + * @st: the service tree containing the tree.
> + * @entity: the entity to insert.
> + */
> +static void bfq_idle_insert(struct io_service_tree *st,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct io_entity *entity)
> +{
> + =A0 =A0 =A0 struct io_entity *first_idle =3D st->first_idle;
> + =A0 =A0 =A0 struct io_entity *last_idle =3D st->last_idle;
> + =A0 =A0 =A0 struct io_queue *ioq =3D io_entity_to_ioq(entity);
> +
> + =A0 =A0 =A0 if (first_idle =3D=3D NULL || bfq_gt(first_idle->finish, en=
tity->finish))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 st->first_idle =3D entity;
> + =A0 =A0 =A0 if (last_idle =3D=3D NULL || bfq_gt(entity->finish, last_id=
le->finish))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 st->last_idle =3D entity;
> +
> + =A0 =A0 =A0 bfq_insert(&st->idle, entity);
> +
> + =A0 =A0 =A0 /* Add this queue to idle list */
> + =A0 =A0 =A0 if (ioq)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add(&ioq->queue_list, &ioq->efqd->idle=
_list);
> +}
> +
> +/**
> + * bfq_forget_entity - remove an entity from the wfq trees.
> + * @st: the service tree.
> + * @entity: the entity being removed.
> + *
> + * Update the device status and forget everything about @entity, putting
> + * the device reference to it, if it is a queue. =A0Entities belonging to
> + * groups are not refcounted.
> + */
> +static void bfq_forget_entity(struct io_service_tree *st,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct io_e=
ntity *entity)
> +{
> + =A0 =A0 =A0 struct io_queue *ioq =3D NULL;
> +
> + =A0 =A0 =A0 BUG_ON(!entity->on_st);
> + =A0 =A0 =A0 entity->on_st =3D 0;
> + =A0 =A0 =A0 st->wsum -=3D entity->weight;
> + =A0 =A0 =A0 ioq =3D io_entity_to_ioq(entity);
> + =A0 =A0 =A0 if (!ioq)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 elv_put_ioq(ioq);
> +}
> +
> +/**
> + * bfq_put_idle_entity - release the idle tree ref of an entity.
> + * @st: service tree for the entity.
> + * @entity: the entity being released.
> + */
> +void bfq_put_idle_entity(struct io_service_tree *st,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct io_e=
ntity *entity)
> +{
> + =A0 =A0 =A0 bfq_idle_extract(st, entity);
> + =A0 =A0 =A0 bfq_forget_entity(st, entity);
> +}
> +
> +/**
> + * bfq_forget_idle - update the idle tree if necessary.
> + * @st: the service tree to act upon.
> + *
> + * To preserve the global O(log N) complexity we only remove one entry h=
ere;
> + * as the idle tree will not grow indefinitely this can be done safely.
> + */
> +void bfq_forget_idle(struct io_service_tree *st)
> +{
> + =A0 =A0 =A0 struct io_entity *first_idle =3D st->first_idle;
> + =A0 =A0 =A0 struct io_entity *last_idle =3D st->last_idle;
> +
> + =A0 =A0 =A0 if (RB_EMPTY_ROOT(&st->active) && last_idle !=3D NULL &&
> + =A0 =A0 =A0 =A0 =A0 !bfq_gt(last_idle->finish, st->vtime)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Active tree is empty. Pull back vtime =
to finish time of
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* last idle entity on idle tree.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Rational seems to be that it reduces t=
he possibility of
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* vtime wraparound (bfq_gt(V-F) < 0).
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 st->vtime =3D last_idle->finish;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (first_idle !=3D NULL && !bfq_gt(first_idle->finish, st-=
>vtime))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_put_idle_entity(st, first_idle);
> +}
> +
> +
> +static struct io_service_tree *
> +__bfq_entity_update_prio(struct io_service_tree *old_st,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct io_e=
ntity *entity)
> +{
> + =A0 =A0 =A0 struct io_service_tree *new_st =3D old_st;
> + =A0 =A0 =A0 struct io_queue *ioq =3D io_entity_to_ioq(entity);
> +
> + =A0 =A0 =A0 if (entity->ioprio_changed) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->ioprio =3D entity->new_ioprio;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->ioprio_class =3D entity->new_ioprio=
_class;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->ioprio_changed =3D 0;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Also update the scaled budget for ioq.=
 Group will get the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* updated budget once ioq is selected to=
 run next.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioq) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct elv_fq_data *efqd =
=3D ioq->efqd;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->budget =3D elv_prio=
_to_slice(efqd, ioq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 old_st->wsum -=3D entity->weight;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->weight =3D bfq_ioprio_to_weight(ent=
ity->ioprio);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* NOTE: here we may be changing the weig=
ht too early,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* this will cause unfairness. =A0The cor=
rect approach
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* would have required additional complex=
ity to defer
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* weight changes to the proper time inst=
ants (i.e.,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* when entity->finish <=3D old_st->vtime=
).
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_st =3D io_entity_service_tree(entity);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_st->wsum +=3D entity->weight;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (new_st !=3D old_st)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->start =3D new_st->v=
time;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return new_st;
> +}
> +
> +/**
> + * __bfq_activate_entity - activate an entity.
> + * @entity: the entity being activated.
> + *
> + * Called whenever an entity is activated, i.e., it is not active and one
> + * of its children receives a new request, or has to be reactivated due =
to
> + * budget exhaustion. =A0It uses the current budget of the entity (and t=
he
> + * service received if @entity is active) of the queue to calculate its
> + * timestamps.
> + */
> +static void __bfq_activate_entity(struct io_entity *entity, int add_fron=
t)
> +{
> + =A0 =A0 =A0 struct io_sched_data *sd =3D entity->sched_data;
> + =A0 =A0 =A0 struct io_service_tree *st =3D io_entity_service_tree(entit=
y);
> +
> + =A0 =A0 =A0 if (entity =3D=3D sd->active_entity) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(entity->tree !=3D NULL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we are requeueing the current entit=
y we have
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to take care of not charging to it ser=
vice it has
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* not received.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_calc_finish(entity, entity->service);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->start =3D entity->finish;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sd->active_entity =3D NULL;
> + =A0 =A0 =A0 } else if (entity->tree =3D=3D &st->active) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Requeueing an entity due to a change o=
f some
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* next_active entity below it. =A0We reu=
se the old
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* start time.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_active_extract(st, entity);
> + =A0 =A0 =A0 } else if (entity->tree =3D=3D &st->idle) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Must be on the idle tree, bfq_idle_ext=
ract() will
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* check for that.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_idle_extract(st, entity);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->start =3D bfq_gt(st->vtime, entity-=
>finish) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0st->vtime : entity->finish;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* The finish time of the entity may be i=
nvalid, and
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* it is in the past for sure, otherwise =
the queue
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* would have been on the idle tree.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->start =3D st->vtime;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 st->wsum +=3D entity->weight;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_get_entity(entity);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(entity->on_st);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->on_st =3D 1;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 st =3D __bfq_entity_update_prio(st, entity);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* This is to emulate cfq like functionality where preemp=
tion can
> + =A0 =A0 =A0 =A0* happen with-in same class, like sync queue preempting =
async queue
> + =A0 =A0 =A0 =A0* May be this is not a very good idea from fairness poin=
t of view
> + =A0 =A0 =A0 =A0* as preempting queue gains share. Keeping it for now.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (add_front) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct io_entity *next_entity;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Determine the entity which will be dis=
patched next
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Use sd->next_active once hierarchical =
patch is applied
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 next_entity =3D bfq_lookup_next_entity(sd, =
0);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (next_entity && next_entity !=3D entity)=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct io_service_tree *new=
_st;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_timestamp_t delta;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_st =3D io_entity_servic=
e_tree(next_entity);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* At this point, both en=
tities should belong to
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* same service tree as c=
ross service tree preemption
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* is automatically taken=
 care by algorithm
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(new_st !=3D st);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->finish =3D next_ent=
ity->finish - 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 delta =3D bfq_delta(entity-=
>budget, entity->weight);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->start =3D entity->f=
inish - delta;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bfq_gt(entity->start, s=
t->vtime))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->sta=
rt =3D st->vtime;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_calc_finish(entity, entity->budget);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 bfq_active_insert(st, entity);
> +}
> +
> +/**
> + * bfq_activate_entity - activate an entity.
> + * @entity: the entity to activate.
> + */
> +void bfq_activate_entity(struct io_entity *entity, int add_front)
> +{
> + =A0 =A0 =A0 __bfq_activate_entity(entity, add_front);
> +}
> +
> +/**
> + * __bfq_deactivate_entity - deactivate an entity from its service tree.
> + * @entity: the entity to deactivate.
> + * @requeue: if false, the entity will not be put into the idle tree.
> + *
> + * Deactivate an entity, independently from its previous state. =A0If the
> + * entity was not on a service tree just return, otherwise if it is on
> + * any scheduler tree, extract it from that tree, and if necessary
> + * and if the caller did not specify @requeue, put it on the idle tree.
> + *
> + */
> +int __bfq_deactivate_entity(struct io_entity *entity, int requeue)
> +{
> + =A0 =A0 =A0 struct io_sched_data *sd =3D entity->sched_data;
> + =A0 =A0 =A0 struct io_service_tree *st =3D io_entity_service_tree(entit=
y);
> + =A0 =A0 =A0 int was_active =3D entity =3D=3D sd->active_entity;
> + =A0 =A0 =A0 int ret =3D 0;
> +
> + =A0 =A0 =A0 if (!entity->on_st)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 BUG_ON(was_active && entity->tree !=3D NULL);
> +
> + =A0 =A0 =A0 if (was_active) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_calc_finish(entity, entity->service);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sd->active_entity =3D NULL;
> + =A0 =A0 =A0 } else if (entity->tree =3D=3D &st->active)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_active_extract(st, entity);
> + =A0 =A0 =A0 else if (entity->tree =3D=3D &st->idle)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_idle_extract(st, entity);
> + =A0 =A0 =A0 else if (entity->tree !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
> +
> + =A0 =A0 =A0 if (!requeue || !bfq_gt(entity->finish, st->vtime))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_forget_entity(st, entity);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_idle_insert(st, entity);
> +
> + =A0 =A0 =A0 BUG_ON(sd->active_entity =3D=3D entity);
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +/**
> + * bfq_deactivate_entity - deactivate an entity.
> + * @entity: the entity to deactivate.
> + * @requeue: true if the entity can be put on the idle tree
> + */
> +void bfq_deactivate_entity(struct io_entity *entity, int requeue)
> +{
> + =A0 =A0 =A0 __bfq_deactivate_entity(entity, requeue);
> +}
> +
> +/**
> + * bfq_update_vtime - update vtime if necessary.
> + * @st: the service tree to act upon.
> + *
> + * If necessary update the service tree vtime to have at least one
> + * eligible entity, skipping to its start time. =A0Assumes that the
> + * active tree of the device is not empty.
> + *
> + * NOTE: this hierarchical implementation updates vtimes quite often,
> + * we may end up with reactivated tasks getting timestamps after a
> + * vtime skip done because we needed a ->first_active entity on some
> + * intermediate node.
> + */
> +static void bfq_update_vtime(struct io_service_tree *st)
> +{
> + =A0 =A0 =A0 struct io_entity *entry;
> + =A0 =A0 =A0 struct rb_node *node =3D st->active.rb_node;
> +
> + =A0 =A0 =A0 entry =3D rb_entry(node, struct io_entity, rb_node);
> + =A0 =A0 =A0 if (bfq_gt(entry->min_start, st->vtime)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 st->vtime =3D entry->min_start;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_forget_idle(st);
> + =A0 =A0 =A0 }
> +}
> +
> +/**
> + * bfq_first_active - find the eligible entity with the smallest finish =
time
> + * @st: the service tree to select from.
> + *
> + * This function searches the first schedulable entity, starting from the
> + * root of the tree and going on the left every time on this side there =
is
> + * a subtree with at least one eligible (start <=3D vtime) entity. =A0Th=
e path
> + * on the right is followed only if a) the left subtree contains no elig=
ible
> + * entities and b) no eligible entity has been found yet.
> + */
> +static struct io_entity *bfq_first_active_entity(struct io_service_tree =
*st)
> +{
> + =A0 =A0 =A0 struct io_entity *entry, *first =3D NULL;
> + =A0 =A0 =A0 struct rb_node *node =3D st->active.rb_node;
> +
> + =A0 =A0 =A0 while (node !=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D rb_entry(node, struct io_entity, =
rb_node);
> +left:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!bfq_gt(entry->start, st->vtime))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 first =3D entry;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(bfq_gt(entry->min_start, st->vtime));
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (node->rb_left !=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry =3D rb_entry(node->rb=
_left,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct io_entity, rb_node);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!bfq_gt(entry->min_star=
t, st->vtime)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node =3D no=
de->rb_left;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto left;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (first !=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 node =3D node->rb_right;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 BUG_ON(first =3D=3D NULL && !RB_EMPTY_ROOT(&st->active));
> + =A0 =A0 =A0 return first;
> +}
> +
> +/**
> + * __bfq_lookup_next_entity - return the first eligible entity in @st.
> + * @st: the service tree.
> + *
> + * Update the virtual time in @st and return the first eligible entity
> + * it contains.
> + */
> +static struct io_entity *__bfq_lookup_next_entity(struct io_service_tree=
 *st)
> +{
> + =A0 =A0 =A0 struct io_entity *entity;
> +
> + =A0 =A0 =A0 if (RB_EMPTY_ROOT(&st->active))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 bfq_update_vtime(st);

Vivek, Paolo, Fabio,
Over here we call bfq_update_vtime(), and this function could have
been called even when we are just doing a lookup (and not an extract).
So vtime is updated while we are not really selecting the next queue
for service (for an example, see elv_preempt_queue()). This can result
in a call to update_vtime when only an entity with small weight (say
weight=3D1) is backlogged and another entity with bigger weight (say 10)
is getting serviced so it is not in the tree (we extract the entity
which is getting service). This results in a big vtime jump to the
start time of the entity with weight 1 (entity of weight 1 would have
big start times, as it has small weight). Now when another entity with
bigger weight (say 90) gets backlogged, it is assigned a new vtime
from service tree's vtime, causing it to get a big value. In the
meanwhile, iog for weight 10 keeps getting service for many quantums,
as it was continuously backlogged.

The problem happens because we extract an entity (removing it from the
tree) while it is getting service, and do vtime jumps based on what is
still in the tree. I think we need to add an extra check on the vtime
of the entity in service, before we take a vtime jump.

I have actually seen this happening when trying to debug on of my
tests. Please let me know what you think.

> + =A0 =A0 =A0 entity =3D bfq_first_active_entity(st);
> + =A0 =A0 =A0 BUG_ON(bfq_gt(entity->start, st->vtime));
> +
> + =A0 =A0 =A0 return entity;
> +}
> +
> +/**
> + * bfq_lookup_next_entity - return the first eligible entity in @sd.
> + * @sd: the sched_data.
> + * @extract: if true the returned entity will be also extracted from @sd.
> + *
> + * NOTE: since we cache the next_active entity at each level of the
> + * hierarchy, the complexity of the lookup can be decreased with
> + * absolutely no effort just returning the cached next_active value;
> + * we prefer to do full lookups to test the consistency of * the data
> + * structures.
> + */
> +struct io_entity *bfq_lookup_next_entity(struct io_sched_data *sd,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0int extract)
> +{
> + =A0 =A0 =A0 struct io_service_tree *st =3D sd->service_tree;
> + =A0 =A0 =A0 struct io_entity *entity;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* One can check for which will be next selected entity w=
ithout
> + =A0 =A0 =A0 =A0* expiring the current one.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 BUG_ON(extract && sd->active_entity !=3D NULL);
> +
> + =A0 =A0 =A0 for (i =3D 0; i < IO_IOPRIO_CLASSES; i++, st++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity =3D __bfq_lookup_next_entity(st);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (entity !=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (extract) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bfq_active_=
extract(st, entity);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sd->active_=
entity =3D entity;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return entity;
> +}
> +
> +void entity_served(struct io_entity *entity, bfq_service_t served)
> +{
> + =A0 =A0 =A0 struct io_service_tree *st;
> +
> + =A0 =A0 =A0 st =3D io_entity_service_tree(entity);
> + =A0 =A0 =A0 entity->service +=3D served;
> + =A0 =A0 =A0 BUG_ON(st->wsum =3D=3D 0);
> + =A0 =A0 =A0 st->vtime +=3D bfq_delta(served, st->wsum);
> + =A0 =A0 =A0 bfq_forget_idle(st);
> +}
> +
> +/* Elevator fair queuing function */
> +struct io_queue *rq_ioq(struct request *rq)
> +{
> + =A0 =A0 =A0 return rq->ioq;
> +}
> +
> +static inline struct io_queue *elv_active_ioq(struct elevator_queue *e)
> +{
> + =A0 =A0 =A0 return e->efqd.active_queue;
> +}
> +
> +void *elv_active_sched_queue(struct elevator_queue *e)
> +{
> + =A0 =A0 =A0 return ioq_sched_queue(elv_active_ioq(e));
> +}
> +EXPORT_SYMBOL(elv_active_sched_queue);
> +
> +int elv_nr_busy_ioq(struct elevator_queue *e)
> +{
> + =A0 =A0 =A0 return e->efqd.busy_queues;
> +}
> +EXPORT_SYMBOL(elv_nr_busy_ioq);
> +
> +int elv_nr_busy_rt_ioq(struct elevator_queue *e)
> +{
> + =A0 =A0 =A0 return e->efqd.busy_rt_queues;
> +}
> +EXPORT_SYMBOL(elv_nr_busy_rt_ioq);
> +
> +int elv_hw_tag(struct elevator_queue *e)
> +{
> + =A0 =A0 =A0 return e->efqd.hw_tag;
> +}
> +EXPORT_SYMBOL(elv_hw_tag);
> +
> +/* Helper functions for operating on elevator idle slice timer */
> +int elv_mod_idle_slice_timer(struct elevator_queue *eq, unsigned long ex=
pires)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &eq->efqd;
> +
> + =A0 =A0 =A0 return mod_timer(&efqd->idle_slice_timer, expires);
> +}
> +EXPORT_SYMBOL(elv_mod_idle_slice_timer);
> +
> +int elv_del_idle_slice_timer(struct elevator_queue *eq)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &eq->efqd;
> +
> + =A0 =A0 =A0 return del_timer(&efqd->idle_slice_timer);
> +}
> +EXPORT_SYMBOL(elv_del_idle_slice_timer);
> +
> +unsigned int elv_get_slice_idle(struct elevator_queue *eq)
> +{
> + =A0 =A0 =A0 return eq->efqd.elv_slice_idle;
> +}
> +EXPORT_SYMBOL(elv_get_slice_idle);
> +
> +void elv_ioq_served(struct io_queue *ioq, bfq_service_t served)
> +{
> + =A0 =A0 =A0 entity_served(&ioq->entity, served);
> +}
> +
> +/* Tells whether ioq is queued in root group or not */
> +static inline int is_root_group_ioq(struct request_queue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> +
> + =A0 =A0 =A0 return (ioq->entity.sched_data =3D=3D &efqd->root_group->sc=
hed_data);
> +}
> +
> +/* Functions to show and store elv_idle_slice value through sysfs */
> +ssize_t elv_slice_idle_show(struct request_queue *q, char *name)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd;
> + =A0 =A0 =A0 unsigned int data;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(q->queue_lock, flags);
> + =A0 =A0 =A0 efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 data =3D jiffies_to_msecs(efqd->elv_slice_idle);
> + =A0 =A0 =A0 spin_unlock_irqrestore(q->queue_lock, flags);
> + =A0 =A0 =A0 return sprintf(name, "%d\n", data);
> +}
> +
> +ssize_t elv_slice_idle_store(struct request_queue *q, const char *name,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t count)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd;
> + =A0 =A0 =A0 unsigned int data;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 char *p =3D (char *)name;
> +
> + =A0 =A0 =A0 data =3D simple_strtoul(p, &p, 10);
> +
> + =A0 =A0 =A0 if (data < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 data =3D 0;
> + =A0 =A0 =A0 else if (data > INT_MAX)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 data =3D INT_MAX;
> +
> + =A0 =A0 =A0 data =3D msecs_to_jiffies(data);
> +
> + =A0 =A0 =A0 spin_lock_irqsave(q->queue_lock, flags);
> + =A0 =A0 =A0 efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 efqd->elv_slice_idle =3D data;
> + =A0 =A0 =A0 spin_unlock_irqrestore(q->queue_lock, flags);
> +
> + =A0 =A0 =A0 return count;
> +}
> +
> +/* Functions to show and store elv_slice_sync value through sysfs */
> +ssize_t elv_slice_sync_show(struct request_queue *q, char *name)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd;
> + =A0 =A0 =A0 unsigned int data;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(q->queue_lock, flags);
> + =A0 =A0 =A0 efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 data =3D efqd->elv_slice[1];
> + =A0 =A0 =A0 spin_unlock_irqrestore(q->queue_lock, flags);
> + =A0 =A0 =A0 return sprintf(name, "%d\n", data);
> +}
> +
> +ssize_t elv_slice_sync_store(struct request_queue *q, const char *name,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t count)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd;
> + =A0 =A0 =A0 unsigned int data;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 char *p =3D (char *)name;
> +
> + =A0 =A0 =A0 data =3D simple_strtoul(p, &p, 10);
> +
> + =A0 =A0 =A0 if (data < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 data =3D 0;
> + =A0 =A0 =A0 /* 100ms is the limit for now*/
> + =A0 =A0 =A0 else if (data > 100)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 data =3D 100;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(q->queue_lock, flags);
> + =A0 =A0 =A0 efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 efqd->elv_slice[1] =3D data;
> + =A0 =A0 =A0 spin_unlock_irqrestore(q->queue_lock, flags);
> +
> + =A0 =A0 =A0 return count;
> +}
> +
> +/* Functions to show and store elv_slice_async value through sysfs */
> +ssize_t elv_slice_async_show(struct request_queue *q, char *name)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd;
> + =A0 =A0 =A0 unsigned int data;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(q->queue_lock, flags);
> + =A0 =A0 =A0 efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 data =3D efqd->elv_slice[0];
> + =A0 =A0 =A0 spin_unlock_irqrestore(q->queue_lock, flags);
> + =A0 =A0 =A0 return sprintf(name, "%d\n", data);
> +}
> +
> +ssize_t elv_slice_async_store(struct request_queue *q, const char *name,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t count)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd;
> + =A0 =A0 =A0 unsigned int data;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 char *p =3D (char *)name;
> +
> + =A0 =A0 =A0 data =3D simple_strtoul(p, &p, 10);
> +
> + =A0 =A0 =A0 if (data < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 data =3D 0;
> + =A0 =A0 =A0 /* 100ms is the limit for now*/
> + =A0 =A0 =A0 else if (data > 100)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 data =3D 100;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(q->queue_lock, flags);
> + =A0 =A0 =A0 efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 efqd->elv_slice[0] =3D data;
> + =A0 =A0 =A0 spin_unlock_irqrestore(q->queue_lock, flags);
> +
> + =A0 =A0 =A0 return count;
> +}
> +
> +void elv_schedule_dispatch(struct request_queue *q)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> +
> + =A0 =A0 =A0 if (elv_nr_busy_ioq(q->elevator)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_log(efqd, "schedule dispatch");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kblockd_schedule_work(efqd->queue, &efqd->u=
nplug_work);
> + =A0 =A0 =A0 }
> +}
> +EXPORT_SYMBOL(elv_schedule_dispatch);
> +
> +void elv_kick_queue(struct work_struct *work)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 container_of(work, struct elv_fq_data, unpl=
ug_work);
> + =A0 =A0 =A0 struct request_queue *q =3D efqd->queue;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(q->queue_lock, flags);
> + =A0 =A0 =A0 blk_start_queueing(q);
> + =A0 =A0 =A0 spin_unlock_irqrestore(q->queue_lock, flags);
> +}
> +
> +void elv_shutdown_timer_wq(struct elevator_queue *e)
> +{
> + =A0 =A0 =A0 del_timer_sync(&e->efqd.idle_slice_timer);
> + =A0 =A0 =A0 cancel_work_sync(&e->efqd.unplug_work);
> +}
> +EXPORT_SYMBOL(elv_shutdown_timer_wq);
> +
> +void elv_ioq_set_prio_slice(struct request_queue *q, struct io_queue *io=
q)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> +
> + =A0 =A0 =A0 ioq->slice_end =3D jiffies + ioq->entity.budget;
> + =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "set_slice=3D%lu", ioq->entity.budge=
t);
> +}
> +
> +static void elv_ioq_update_io_thinktime(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D ioq->efqd;
> + =A0 =A0 =A0 unsigned long elapsed =3D jiffies - ioq->last_end_request;
> + =A0 =A0 =A0 unsigned long ttime =3D min(elapsed, 2UL * efqd->elv_slice_=
idle);
> +
> + =A0 =A0 =A0 ioq->ttime_samples =3D (7*ioq->ttime_samples + 256) / 8;
> + =A0 =A0 =A0 ioq->ttime_total =3D (7*ioq->ttime_total + 256*ttime) / 8;
> + =A0 =A0 =A0 ioq->ttime_mean =3D (ioq->ttime_total + 128) / ioq->ttime_s=
amples;
> +}
> +
> +/*
> + * Disable idle window if the process thinks too long.
> + * This idle flag can also be updated by io scheduler.
> + */
> +static void elv_ioq_update_idle_window(struct elevator_queue *eq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct io_q=
ueue *ioq, struct request *rq)
> +{
> + =A0 =A0 =A0 int old_idle, enable_idle;
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D ioq->efqd;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Don't idle for async or idle io prio class
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!elv_ioq_sync(ioq) || elv_ioq_class_idle(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 enable_idle =3D old_idle =3D elv_ioq_idle_window(ioq);
> +
> + =A0 =A0 =A0 if (!efqd->elv_slice_idle)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enable_idle =3D 0;
> + =A0 =A0 =A0 else if (ioq_sample_valid(ioq->ttime_samples)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioq->ttime_mean > efqd->elv_slice_idle)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enable_idle =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enable_idle =3D 1;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* From think time perspective idle should be enabled. Ch=
eck with
> + =A0 =A0 =A0 =A0* io scheduler if it wants to disable idling based on ad=
ditional
> + =A0 =A0 =A0 =A0* considrations like seek pattern.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (enable_idle) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (eq->ops->elevator_update_idle_window_fn)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enable_idle =3D eq->ops->el=
evator_update_idle_window_fn(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 eq, ioq->sched_queue, rq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!enable_idle)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "ios=
ched disabled idle");
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (old_idle !=3D enable_idle) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "idle=3D%d", enable_=
idle);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (enable_idle)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_mark_ioq_idle_window(io=
q);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_clear_ioq_idle_window(i=
oq);
> + =A0 =A0 =A0 }
> +}
> +
> +struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp_mask)
> +{
> + =A0 =A0 =A0 struct io_queue *ioq =3D NULL;
> +
> + =A0 =A0 =A0 ioq =3D kmem_cache_alloc_node(elv_ioq_pool, gfp_mask, q->no=
de);
> + =A0 =A0 =A0 return ioq;
> +}
> +EXPORT_SYMBOL(elv_alloc_ioq);
> +
> +void elv_free_ioq(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 kmem_cache_free(elv_ioq_pool, ioq);
> +}
> +EXPORT_SYMBOL(elv_free_ioq);
> +
> +int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *sched_queue, int iopr=
io_class, int ioprio,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int is_sync)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &eq->efqd;
> + =A0 =A0 =A0 struct io_group *iog =3D io_lookup_io_group_current(efqd->q=
ueue);
> +
> + =A0 =A0 =A0 RB_CLEAR_NODE(&ioq->entity.rb_node);
> + =A0 =A0 =A0 atomic_set(&ioq->ref, 0);
> + =A0 =A0 =A0 ioq->efqd =3D efqd;
> + =A0 =A0 =A0 elv_ioq_set_ioprio_class(ioq, ioprio_class);
> + =A0 =A0 =A0 elv_ioq_set_ioprio(ioq, ioprio);
> + =A0 =A0 =A0 ioq->pid =3D current->pid;
> + =A0 =A0 =A0 ioq->sched_queue =3D sched_queue;
> + =A0 =A0 =A0 if (is_sync && !elv_ioq_class_idle(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_mark_ioq_idle_window(ioq);
> + =A0 =A0 =A0 bfq_init_entity(&ioq->entity, iog);
> + =A0 =A0 =A0 ioq->entity.budget =3D elv_prio_to_slice(efqd, ioq);
> + =A0 =A0 =A0 return 0;
> +}
> +EXPORT_SYMBOL(elv_init_ioq);
> +
> +void elv_put_ioq(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D ioq->efqd;
> + =A0 =A0 =A0 struct elevator_queue *e =3D container_of(efqd, struct elev=
ator_queue,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 efqd);
> +
> + =A0 =A0 =A0 BUG_ON(atomic_read(&ioq->ref) <=3D 0);
> + =A0 =A0 =A0 if (!atomic_dec_and_test(&ioq->ref))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 BUG_ON(ioq->nr_queued);
> + =A0 =A0 =A0 BUG_ON(ioq->entity.tree !=3D NULL);
> + =A0 =A0 =A0 BUG_ON(elv_ioq_busy(ioq));
> + =A0 =A0 =A0 BUG_ON(efqd->active_queue =3D=3D ioq);
> +
> + =A0 =A0 =A0 /* Can be called by outgoing elevator. Don't use q */
> + =A0 =A0 =A0 BUG_ON(!e->ops->elevator_free_sched_queue_fn);
> +
> + =A0 =A0 =A0 e->ops->elevator_free_sched_queue_fn(e, ioq->sched_queue);
> + =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "put_queue");
> + =A0 =A0 =A0 elv_free_ioq(ioq);
> +}
> +EXPORT_SYMBOL(elv_put_ioq);
> +
> +void elv_release_ioq(struct elevator_queue *e, struct io_queue **ioq_ptr)
> +{
> + =A0 =A0 =A0 struct io_queue *ioq =3D *ioq_ptr;
> +
> + =A0 =A0 =A0 if (ioq !=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Drop the reference taken by the io group=
 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_put_ioq(ioq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *ioq_ptr =3D NULL;
> + =A0 =A0 =A0 }
> +}
> +
> +/*
> + * Normally next io queue to be served is selected from the service tree.
> + * This function allows one to choose a specific io queue to run next
> + * out of order. This is primarily to accomodate the close_cooperator
> + * feature of cfq.
> + *
> + * Currently it is done only for root level as to begin with supporting
> + * close cooperator feature only for root group to make sure default
> + * cfq behavior in flat hierarchy is not changed.
> + */
> +void elv_set_next_ioq(struct request_queue *q, struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 struct io_entity *entity =3D &ioq->entity;
> + =A0 =A0 =A0 struct io_sched_data *sd =3D &efqd->root_group->sched_data;
> + =A0 =A0 =A0 struct io_service_tree *st =3D io_entity_service_tree(entit=
y);
> +
> + =A0 =A0 =A0 BUG_ON(efqd->active_queue !=3D NULL || sd->active_entity !=
=3D NULL);
> + =A0 =A0 =A0 BUG_ON(!efqd->busy_queues);
> + =A0 =A0 =A0 BUG_ON(sd !=3D entity->sched_data);
> + =A0 =A0 =A0 BUG_ON(!st);
> +
> + =A0 =A0 =A0 bfq_update_vtime(st);
> + =A0 =A0 =A0 bfq_active_extract(st, entity);
> + =A0 =A0 =A0 sd->active_entity =3D entity;
> + =A0 =A0 =A0 entity->service =3D 0;
> + =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "set_next_ioq");
> +}
> +
> +/* Get next queue for service. */
> +struct io_queue *elv_get_next_ioq(struct request_queue *q, int extract)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 struct io_entity *entity =3D NULL;
> + =A0 =A0 =A0 struct io_queue *ioq =3D NULL;
> + =A0 =A0 =A0 struct io_sched_data *sd;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* one can check for which queue will be selected next wh=
ile having
> + =A0 =A0 =A0 =A0* one queue active. preempt logic uses it.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 BUG_ON(extract && efqd->active_queue !=3D NULL);
> +
> + =A0 =A0 =A0 if (!efqd->busy_queues)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 sd =3D &efqd->root_group->sched_data;
> + =A0 =A0 =A0 if (extract)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity =3D bfq_lookup_next_entity(sd, 1);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity =3D bfq_lookup_next_entity(sd, 0);
> +
> + =A0 =A0 =A0 BUG_ON(!entity);
> + =A0 =A0 =A0 if (extract)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 entity->service =3D 0;
> + =A0 =A0 =A0 ioq =3D io_entity_to_ioq(entity);
> +
> + =A0 =A0 =A0 return ioq;
> +}
> +
> +/*
> + * coop tells that io scheduler selected a queue for us and we did not
> + * select the next queue based on fairness.
> + */
> +static void __elv_set_active_ioq(struct elv_fq_data *efqd, struct io_que=
ue *ioq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int coop)
> +{
> + =A0 =A0 =A0 struct request_queue *q =3D efqd->queue;
> +
> + =A0 =A0 =A0 if (ioq) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "set_active, busy=3D=
%d",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 efqd->busy_queues);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioq->slice_end =3D 0;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_clear_ioq_wait_request(ioq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_clear_ioq_must_dispatch(ioq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_mark_ioq_slice_new(ioq);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer(&efqd->idle_slice_timer);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 efqd->active_queue =3D ioq;
> +
> + =A0 =A0 =A0 /* Let iosched know if it wants to take some action */
> + =A0 =A0 =A0 if (ioq) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (q->elevator->ops->elevator_active_ioq_s=
et_fn)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->elevator->ops->elevator_=
active_ioq_set_fn(q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioq->sched_queue, coop);
> + =A0 =A0 =A0 }
> +}
> +
> +/* Get and set a new active queue for service. */
> +struct io_queue *elv_set_active_ioq(struct request_queue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 int coop =3D 0;
> +
> + =A0 =A0 =A0 if (!ioq)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioq =3D elv_get_next_ioq(q, 1);
> + =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_set_next_ioq(q, ioq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* io scheduler selected the next queue f=
or us. Pass this
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* this info back to io scheudler. cfq cu=
rrently uses it
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to reset coop flag on the queue.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 coop =3D 1;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 __elv_set_active_ioq(efqd, ioq, coop);
> + =A0 =A0 =A0 return ioq;
> +}
> +
> +void elv_reset_active_ioq(struct elv_fq_data *efqd)
> +{
> + =A0 =A0 =A0 struct request_queue *q =3D efqd->queue;
> + =A0 =A0 =A0 struct io_queue *ioq =3D elv_active_ioq(efqd->queue->elevat=
or);
> +
> + =A0 =A0 =A0 if (q->elevator->ops->elevator_active_ioq_reset_fn)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->elevator->ops->elevator_active_ioq_reset=
_fn(q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioq->sched_queue);
> + =A0 =A0 =A0 efqd->active_queue =3D NULL;
> + =A0 =A0 =A0 del_timer(&efqd->idle_slice_timer);
> +}
> +
> +void elv_activate_ioq(struct io_queue *ioq, int add_front)
> +{
> + =A0 =A0 =A0 bfq_activate_entity(&ioq->entity, add_front);
> +}
> +
> +void elv_deactivate_ioq(struct elv_fq_data *efqd, struct io_queue *ioq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int requeue)
> +{
> + =A0 =A0 =A0 if (ioq =3D=3D efqd->active_queue)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_reset_active_ioq(efqd);
> +
> + =A0 =A0 =A0 bfq_deactivate_entity(&ioq->entity, requeue);
> +}
> +
> +/* Called when an inactive queue receives a new request. */
> +void elv_add_ioq_busy(struct elv_fq_data *efqd, struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 BUG_ON(elv_ioq_busy(ioq));
> + =A0 =A0 =A0 BUG_ON(ioq =3D=3D efqd->active_queue);
> + =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "add to busy");
> + =A0 =A0 =A0 elv_activate_ioq(ioq, 0);
> + =A0 =A0 =A0 elv_mark_ioq_busy(ioq);
> + =A0 =A0 =A0 efqd->busy_queues++;
> + =A0 =A0 =A0 if (elv_ioq_class_rt(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 efqd->busy_rt_queues++;
> +}
> +
> +void elv_del_ioq_busy(struct elevator_queue *e, struct io_queue *ioq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int requeue)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &e->efqd;
> +
> + =A0 =A0 =A0 BUG_ON(!elv_ioq_busy(ioq));
> + =A0 =A0 =A0 BUG_ON(ioq->nr_queued);
> + =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "del from busy");
> + =A0 =A0 =A0 elv_clear_ioq_busy(ioq);
> + =A0 =A0 =A0 BUG_ON(efqd->busy_queues =3D=3D 0);
> + =A0 =A0 =A0 efqd->busy_queues--;
> + =A0 =A0 =A0 if (elv_ioq_class_rt(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 efqd->busy_rt_queues--;
> +
> + =A0 =A0 =A0 elv_deactivate_ioq(efqd, ioq, requeue);
> +}
> +
> +/*
> + * Do the accounting. Determine how much service (in terms of time slice=
s)
> + * current queue used and adjust the start, finish time of queue and vti=
me
> + * of the tree accordingly.
> + *
> + * Determining the service used in terms of time is tricky in certain
> + * situations. Especially when underlying device supports command queuing
> + * and requests from multiple queues can be there at same time, then it
> + * is not clear which queue consumed how much of disk time.
> + *
> + * To mitigate this problem, cfq starts the time slice of the queue only
> + * after first request from the queue has completed. This does not work
> + * very well if we expire the queue before we wait for first and more
> + * request to finish from the queue. For seeky queues, we will expire the
> + * queue after dispatching few requests without waiting and start dispat=
ching
> + * from next queue.
> + *
> + * Not sure how to determine the time consumed by queue in such scenario=
s.
> + * Currently as a crude approximation, we are charging 25% of time slice
> + * for such cases. A better mechanism is needed for accurate accounting.
> + */
> +void __elv_ioq_slice_expired(struct request_queue *q, struct io_queue *i=
oq)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 struct io_entity *entity =3D &ioq->entity;
> + =A0 =A0 =A0 long slice_unused =3D 0, slice_used =3D 0, slice_overshoot =
=3D 0;
> +
> + =A0 =A0 =A0 assert_spin_locked(q->queue_lock);
> + =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "slice expired");
> +
> + =A0 =A0 =A0 if (elv_ioq_wait_request(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer(&efqd->idle_slice_timer);
> +
> + =A0 =A0 =A0 elv_clear_ioq_wait_request(ioq);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* if ioq->slice_end =3D 0, that means a queue was expire=
d before first
> + =A0 =A0 =A0 =A0* reuqest from the queue got completed. Of course we are=
 not planning
> + =A0 =A0 =A0 =A0* to idle on the queue otherwise we would not have expir=
ed it.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* Charge for the 25% slice in such cases. This is not th=
e best thing
> + =A0 =A0 =A0 =A0* to do but at the same time not very sure what's the ne=
xt best
> + =A0 =A0 =A0 =A0* thing to do.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* This arises from that fact that we don't have the noti=
on of
> + =A0 =A0 =A0 =A0* one queue being operational at one time. io scheduler =
can dispatch
> + =A0 =A0 =A0 =A0* requests from multiple queues in one dispatch round. I=
deally for
> + =A0 =A0 =A0 =A0* more accurate accounting of exact disk time used by di=
sk, one
> + =A0 =A0 =A0 =A0* should dispatch requests from only one queue and wait =
for all
> + =A0 =A0 =A0 =A0* the requests to finish. But this will reduce throughpu=
t.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!ioq->slice_end)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 slice_used =3D entity->budget/4;
> + =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (time_after(ioq->slice_end, jiffies)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slice_unused =3D ioq->slice=
_end - jiffies;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (slice_unused =3D=3D ent=
ity->budget) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* queue =
got expired immediately after
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* comple=
ting first request. Charge 25% of
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* slice.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slice_used =
=3D entity->budget/4;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slice_used =
=3D entity->budget - slice_unused;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slice_overshoot =3D jiffies=
 - ioq->slice_end;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slice_used =3D entity->budg=
et + slice_overshoot;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "sl_end=3D%lx, jiffies=3D%lx", ioq->=
slice_end,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 jiffies);
> + =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "sl_used=3D%ld, budget=3D%ld oversho=
ot=3D%ld",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slice_used,=
 entity->budget, slice_overshoot);
> + =A0 =A0 =A0 elv_ioq_served(ioq, slice_used);
> +
> + =A0 =A0 =A0 BUG_ON(ioq !=3D efqd->active_queue);
> + =A0 =A0 =A0 elv_reset_active_ioq(efqd);
> +
> + =A0 =A0 =A0 if (!ioq->nr_queued)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_del_ioq_busy(q->elevator, ioq, 1);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_activate_ioq(ioq, 0);
> +}
> +EXPORT_SYMBOL(__elv_ioq_slice_expired);
> +
> +/*
> + * =A0Expire the ioq.
> + */
> +void elv_ioq_slice_expired(struct request_queue *q)
> +{
> + =A0 =A0 =A0 struct io_queue *ioq =3D elv_active_ioq(q->elevator);
> +
> + =A0 =A0 =A0 if (ioq)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __elv_ioq_slice_expired(q, ioq);
> +}
> +
> +/*
> + * Check if new_cfqq should preempt the currently active queue. Return 0=
 for
> + * no or if we aren't sure, a 1 will cause a preemption attempt.
> + */
> +int elv_should_preempt(struct request_queue *q, struct io_queue *new_ioq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct request *rq)
> +{
> + =A0 =A0 =A0 struct io_queue *ioq;
> + =A0 =A0 =A0 struct elevator_queue *eq =3D q->elevator;
> +
> + =A0 =A0 =A0 ioq =3D elv_active_ioq(eq);
> +
> + =A0 =A0 =A0 if (!ioq)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 if (elv_ioq_slice_used(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> +
> + =A0 =A0 =A0 if (elv_ioq_class_idle(new_ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 if (elv_ioq_class_idle(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Allow an RT request to pre-empt an ongoing non-RT cfqq=
 timeslice.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (elv_ioq_class_rt(new_ioq) && !elv_ioq_class_rt(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Check with io scheduler if it has additional criterion=
 based on
> + =A0 =A0 =A0 =A0* which it wants to preempt existing queue.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (eq->ops->elevator_should_preempt_fn)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return eq->ops->elevator_should_preempt_fn(=
q, new_ioq, rq);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static void elv_preempt_queue(struct request_queue *q, struct io_queue *=
ioq)
> +{
> + =A0 =A0 =A0 elv_log_ioq(&q->elevator->efqd, ioq, "preempt");
> + =A0 =A0 =A0 elv_ioq_slice_expired(q);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Put the new queue at the front of the of the current l=
ist,
> + =A0 =A0 =A0 =A0* so we know that it will be selected next.
> + =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 elv_activate_ioq(ioq, 1);
> + =A0 =A0 =A0 elv_ioq_set_slice_end(ioq, 0);
> + =A0 =A0 =A0 elv_mark_ioq_slice_new(ioq);
> +}
> +
> +void elv_ioq_request_add(struct request_queue *q, struct request *rq)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 struct io_queue *ioq =3D rq->ioq;
> +
> + =A0 =A0 =A0 if (!elv_iosched_fair_queuing_enabled(q->elevator))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 BUG_ON(!efqd);
> + =A0 =A0 =A0 BUG_ON(!ioq);
> + =A0 =A0 =A0 efqd->rq_queued++;
> + =A0 =A0 =A0 ioq->nr_queued++;
> +
> + =A0 =A0 =A0 if (!elv_ioq_busy(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_add_ioq_busy(efqd, ioq);
> +
> + =A0 =A0 =A0 elv_ioq_update_io_thinktime(ioq);
> + =A0 =A0 =A0 elv_ioq_update_idle_window(q->elevator, ioq, rq);
> +
> + =A0 =A0 =A0 if (ioq =3D=3D elv_active_ioq(q->elevator)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Remember that we saw a request from th=
is process, but
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* don't start queuing just yet. Otherwis=
e we risk seeing lots
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* of tiny requests, because we disrupt t=
he normal plugging
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and merging. If the request is already=
 larger than a single
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* page, let it rip immediately. For that=
 case we assume that
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* merging is already done. Ditto for a b=
usy system that
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* has other work pending, don't risk del=
aying until the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* idle timer unplug to continue working.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (elv_ioq_wait_request(ioq)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (blk_rq_bytes(rq) > PAGE=
_CACHE_SIZE ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 efqd->busy_queues >=
 1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer(&=
efqd->idle_slice_timer);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_start_q=
ueueing(q);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_mark_ioq_must_dispatch(=
ioq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 } else if (elv_should_preempt(q, ioq, rq)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* not the active queue - expire current =
slice if it is
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* idle and has expired it's mean thinkti=
me or this new queue
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* has some old slice time left and is of=
 higher priority or
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* this new queue is RT and the current o=
ne is BE
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_preempt_queue(q, ioq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 blk_start_queueing(q);
> + =A0 =A0 =A0 }
> +}
> +
> +void elv_idle_slice_timer(unsigned long data)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D (struct elv_fq_data *)data;
> + =A0 =A0 =A0 struct io_queue *ioq;
> + =A0 =A0 =A0 unsigned long flags;
> + =A0 =A0 =A0 struct request_queue *q =3D efqd->queue;
> +
> + =A0 =A0 =A0 elv_log(efqd, "idle timer fired");
> +
> + =A0 =A0 =A0 spin_lock_irqsave(q->queue_lock, flags);
> +
> + =A0 =A0 =A0 ioq =3D efqd->active_queue;
> +
> + =A0 =A0 =A0 if (ioq) {
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We saw a request before the queue expi=
red, let it through
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (elv_ioq_must_dispatch(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_kick;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* expired
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (elv_ioq_slice_used(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto expire;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* only expire and reinvoke request handl=
er, if there are
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* other queues with pending requests
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!elv_nr_busy_ioq(q->elevator))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_cont;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* not expired and it has a request pendi=
ng, let it dispatch
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioq->nr_queued)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_kick;
> + =A0 =A0 =A0 }
> +expire:
> + =A0 =A0 =A0 elv_ioq_slice_expired(q);
> +out_kick:
> + =A0 =A0 =A0 elv_schedule_dispatch(q);
> +out_cont:
> + =A0 =A0 =A0 spin_unlock_irqrestore(q->queue_lock, flags);
> +}
> +
> +void elv_ioq_arm_slice_timer(struct request_queue *q)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 struct io_queue *ioq =3D elv_active_ioq(q->elevator);
> + =A0 =A0 =A0 unsigned long sl;
> +
> + =A0 =A0 =A0 BUG_ON(!ioq);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* SSD device without seek penalty, disable idling. But o=
nly do so
> + =A0 =A0 =A0 =A0* for devices that support queuing, otherwise we still h=
ave a problem
> + =A0 =A0 =A0 =A0* with sync vs async workloads.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (blk_queue_nonrot(q) && efqd->hw_tag)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* still requests with the driver, don't idle
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (efqd->rq_in_driver)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* idle is disabled, either manually or by past process h=
istory
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!efqd->elv_slice_idle || !elv_ioq_idle_window(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* may be iosched got its own idling logic. In that case =
io
> + =A0 =A0 =A0 =A0* schduler will take care of arming the timer, if need b=
e.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (q->elevator->ops->elevator_arm_slice_timer_fn) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 q->elevator->ops->elevator_arm_slice_timer_=
fn(q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 ioq->sched_queue);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_mark_ioq_wait_request(ioq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sl =3D efqd->elv_slice_idle;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mod_timer(&efqd->idle_slice_timer, jiffies =
+ sl);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "arm idle: %lu", sl);
> + =A0 =A0 =A0 }
> +}
> +
> +void elv_free_idle_ioq_list(struct elevator_queue *e)
> +{
> + =A0 =A0 =A0 struct io_queue *ioq, *n;
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &e->efqd;
> +
> + =A0 =A0 =A0 list_for_each_entry_safe(ioq, n, &efqd->idle_list, queue_li=
st)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_deactivate_ioq(efqd, ioq, 0);
> +}
> +
> +/* Common layer function to select the next queue to dispatch from */
> +void *elv_fq_select_ioq(struct request_queue *q, int force)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> + =A0 =A0 =A0 struct io_queue *new_ioq =3D NULL, *ioq =3D elv_active_ioq(=
q->elevator);
> +
> + =A0 =A0 =A0 if (!elv_nr_busy_ioq(q->elevator))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 if (ioq =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto new_queue;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Force dispatch. Continue to dispatch from current queu=
e as long
> + =A0 =A0 =A0 =A0* as it has requests.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (unlikely(force)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioq->nr_queued)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto keep_queue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto expire;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* The active queue has run out of time, expire it and se=
lect new.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (elv_ioq_slice_used(ioq) && !elv_ioq_must_dispatch(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto expire;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* If we have a RT cfqq waiting, then we pre-empt the cur=
rent non-rt
> + =A0 =A0 =A0 =A0* cfqq.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!elv_ioq_class_rt(ioq) && efqd->busy_rt_queues) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We simulate this as cfqq timed out so =
that it gets to bank
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the remaining of its time slice.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "preempt");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto expire;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* The active queue has requests and isn't expired, allow=
 it to
> + =A0 =A0 =A0 =A0* dispatch.
> + =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 if (ioq->nr_queued)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto keep_queue;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* If another queue has a request waiting within our mean=
 seek
> + =A0 =A0 =A0 =A0* distance, let it run. =A0The expire code will check fo=
r close
> + =A0 =A0 =A0 =A0* cooperators and put the close queue at the front of th=
e service
> + =A0 =A0 =A0 =A0* tree.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 new_ioq =3D elv_close_cooperator(q, ioq, 0);
> + =A0 =A0 =A0 if (new_ioq)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto expire;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* No requests pending. If the active queue still has req=
uests in
> + =A0 =A0 =A0 =A0* flight or is idling for a new request, allow either of=
 these
> + =A0 =A0 =A0 =A0* conditions to happen (or time out) before selecting a =
new queue.
> + =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 if (timer_pending(&efqd->idle_slice_timer) ||
> + =A0 =A0 =A0 =A0 =A0 (elv_ioq_nr_dispatched(ioq) && elv_ioq_idle_window(=
ioq))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioq =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto keep_queue;
> + =A0 =A0 =A0 }
> +
> +expire:
> + =A0 =A0 =A0 elv_ioq_slice_expired(q);
> +new_queue:
> + =A0 =A0 =A0 ioq =3D elv_set_active_ioq(q, new_ioq);
> +keep_queue:
> + =A0 =A0 =A0 return ioq;
> +}
> +
> +/* A request got removed from io_queue. Do the accounting */
> +void elv_ioq_request_removed(struct elevator_queue *e, struct request *r=
q)
> +{
> + =A0 =A0 =A0 struct io_queue *ioq;
> + =A0 =A0 =A0 struct elv_fq_data *efqd;
> +
> + =A0 =A0 =A0 if (!elv_iosched_fair_queuing_enabled(e))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 ioq =3D rq->ioq;
> + =A0 =A0 =A0 BUG_ON(!ioq);
> + =A0 =A0 =A0 ioq->nr_queued--;
> +
> + =A0 =A0 =A0 efqd =3D ioq->efqd;
> + =A0 =A0 =A0 BUG_ON(!efqd);
> + =A0 =A0 =A0 efqd->rq_queued--;
> +
> + =A0 =A0 =A0 if (elv_ioq_busy(ioq) && (elv_active_ioq(e) !=3D ioq) && !i=
oq->nr_queued)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_del_ioq_busy(e, ioq, 1);
> +}
> +
> +/* A request got dispatched. Do the accounting. */
> +void elv_fq_dispatched_request(struct elevator_queue *e, struct request =
*rq)
> +{
> + =A0 =A0 =A0 struct io_queue *ioq =3D rq->ioq;
> +
> + =A0 =A0 =A0 if (!elv_iosched_fair_queuing_enabled(e))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 BUG_ON(!ioq);
> + =A0 =A0 =A0 elv_ioq_request_dispatched(ioq);
> + =A0 =A0 =A0 elv_ioq_request_removed(e, rq);
> + =A0 =A0 =A0 elv_clear_ioq_must_dispatch(ioq);
> +}
> +
> +void elv_fq_activate_rq(struct request_queue *q, struct request *rq)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> +
> + =A0 =A0 =A0 if (!elv_iosched_fair_queuing_enabled(q->elevator))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 efqd->rq_in_driver++;
> + =A0 =A0 =A0 elv_log_ioq(efqd, rq_ioq(rq), "activate rq, drv=3D%d",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 efqd->rq_in_driver);
> +}
> +
> +void elv_fq_deactivate_rq(struct request_queue *q, struct request *rq)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> +
> + =A0 =A0 =A0 if (!elv_iosched_fair_queuing_enabled(q->elevator))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 WARN_ON(!efqd->rq_in_driver);
> + =A0 =A0 =A0 efqd->rq_in_driver--;
> + =A0 =A0 =A0 elv_log_ioq(efqd, rq_ioq(rq), "deactivate rq, drv=3D%d",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 efqd->rq_in_driver);
> +}
> +
> +/*
> + * Update hw_tag based on peak queue depth over 50 samples under
> + * sufficient load.
> + */
> +static void elv_update_hw_tag(struct elv_fq_data *efqd)
> +{
> + =A0 =A0 =A0 if (efqd->rq_in_driver > efqd->rq_in_driver_peak)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 efqd->rq_in_driver_peak =3D efqd->rq_in_dri=
ver;
> +
> + =A0 =A0 =A0 if (efqd->rq_queued <=3D ELV_HW_QUEUE_MIN &&
> + =A0 =A0 =A0 =A0 =A0 efqd->rq_in_driver <=3D ELV_HW_QUEUE_MIN)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 if (efqd->hw_tag_samples++ < 50)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 if (efqd->rq_in_driver_peak >=3D ELV_HW_QUEUE_MIN)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 efqd->hw_tag =3D 1;
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 efqd->hw_tag =3D 0;
> +
> + =A0 =A0 =A0 efqd->hw_tag_samples =3D 0;
> + =A0 =A0 =A0 efqd->rq_in_driver_peak =3D 0;
> +}
> +
> +/*
> + * If ioscheduler has functionality of keeping track of close cooperator=
, check
> + * with it if it has got a closely co-operating queue.
> + */
> +static inline struct io_queue *elv_close_cooperator(struct request_queue=
 *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct io_queue *ioq, int probe)
> +{
> + =A0 =A0 =A0 struct elevator_queue *e =3D q->elevator;
> + =A0 =A0 =A0 struct io_queue *new_ioq =3D NULL;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Currently this feature is supported only for flat hier=
archy or
> + =A0 =A0 =A0 =A0* root group queues so that default cfq behavior is not =
changed.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (!is_root_group_ioq(q, ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 if (q->elevator->ops->elevator_close_cooperator_fn)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_ioq =3D e->ops->elevator_close_cooperat=
or_fn(q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 ioq->sched_queue, probe);
> +
> + =A0 =A0 =A0 /* Only select co-operating queue if it belongs to root gro=
up */
> + =A0 =A0 =A0 if (new_ioq && !is_root_group_ioq(q, new_ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 return new_ioq;
> +}
> +
> +/* A request got completed from io_queue. Do the accounting. */
> +void elv_ioq_completed_request(struct request_queue *q, struct request *=
rq)
> +{
> + =A0 =A0 =A0 const int sync =3D rq_is_sync(rq);
> + =A0 =A0 =A0 struct io_queue *ioq;
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> +
> + =A0 =A0 =A0 if (!elv_iosched_fair_queuing_enabled(q->elevator))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 ioq =3D rq->ioq;
> +
> + =A0 =A0 =A0 elv_log_ioq(efqd, ioq, "complete");
> +
> + =A0 =A0 =A0 elv_update_hw_tag(efqd);
> +
> + =A0 =A0 =A0 WARN_ON(!efqd->rq_in_driver);
> + =A0 =A0 =A0 WARN_ON(!ioq->dispatched);
> + =A0 =A0 =A0 efqd->rq_in_driver--;
> + =A0 =A0 =A0 ioq->dispatched--;
> +
> + =A0 =A0 =A0 if (sync)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioq->last_end_request =3D jiffies;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* If this is the active queue, check if it needs to be e=
xpired,
> + =A0 =A0 =A0 =A0* or if we want to idle in case it has no pending reques=
ts.
> + =A0 =A0 =A0 =A0*/
> +
> + =A0 =A0 =A0 if (elv_active_ioq(q->elevator) =3D=3D ioq) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (elv_ioq_slice_new(ioq)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_ioq_set_prio_slice(q, i=
oq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_clear_ioq_slice_new(ioq=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If there are no requests waiting in th=
is queue, and
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* there are other queues ready to issue =
requests, AND
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* those other queues are issuing request=
s within our
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* mean seek distance, give them a chance=
 to run instead
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* of idling.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (elv_ioq_slice_used(ioq) || elv_ioq_clas=
s_idle(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_ioq_slice_expired(q);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (!ioq->nr_queued && !elv_close_coop=
erator(q, ioq, 1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0&& sync && !rq_noidle(rq=
))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_ioq_arm_slice_timer(q);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (!efqd->rq_in_driver)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_schedule_dispatch(q);
> +}
> +
> +struct io_group *io_lookup_io_group_current(struct request_queue *q)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &q->elevator->efqd;
> +
> + =A0 =A0 =A0 return efqd->root_group;
> +}
> +EXPORT_SYMBOL(io_lookup_io_group_current);
> +
> +void *io_group_async_queue_prio(struct io_group *iog, int ioprio_class,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int ioprio)
> +{
> + =A0 =A0 =A0 struct io_queue *ioq =3D NULL;
> +
> + =A0 =A0 =A0 switch (ioprio_class) {
> + =A0 =A0 =A0 case IOPRIO_CLASS_RT:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioq =3D iog->async_queue[0][ioprio];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case IOPRIO_CLASS_BE:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioq =3D iog->async_queue[1][ioprio];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case IOPRIO_CLASS_IDLE:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioq =3D iog->async_idle_queue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (ioq)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ioq->sched_queue;
> + =A0 =A0 =A0 return NULL;
> +}
> +EXPORT_SYMBOL(io_group_async_queue_prio);
> +
> +void io_group_set_async_queue(struct io_group *iog, int ioprio_class,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int ioprio, struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 switch (ioprio_class) {
> + =A0 =A0 =A0 case IOPRIO_CLASS_RT:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iog->async_queue[0][ioprio] =3D ioq;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case IOPRIO_CLASS_BE:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iog->async_queue[1][ioprio] =3D ioq;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 case IOPRIO_CLASS_IDLE:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iog->async_idle_queue =3D ioq;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 default:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Take the group reference and pin the queue. Group exit=
 will
> + =A0 =A0 =A0 =A0* clean it up
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 elv_get_ioq(ioq);
> +}
> +EXPORT_SYMBOL(io_group_set_async_queue);
> +
> +/*
> + * Release all the io group references to its async queues.
> + */
> +void io_put_io_group_queues(struct elevator_queue *e, struct io_group *i=
og)
> +{
> + =A0 =A0 =A0 int i, j;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < 2; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (j =3D 0; j < IOPRIO_BE_NR; j++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_release_ioq(e, &iog->as=
ync_queue[i][j]);
> +
> + =A0 =A0 =A0 /* Free up async idle queue */
> + =A0 =A0 =A0 elv_release_ioq(e, &iog->async_idle_queue);
> +}
> +
> +struct io_group *io_alloc_root_group(struct request_queue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct elevator_queue *e, void *key)
> +{
> + =A0 =A0 =A0 struct io_group *iog;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 iog =3D kmalloc_node(sizeof(*iog), GFP_KERNEL | __GFP_ZERO,=
 q->node);
> + =A0 =A0 =A0 if (iog =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < IO_IOPRIO_CLASSES; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iog->sched_data.service_tree[i] =3D IO_SERV=
ICE_TREE_INIT;
> +
> + =A0 =A0 =A0 return iog;
> +}
> +
> +void io_free_root_group(struct elevator_queue *e)
> +{
> + =A0 =A0 =A0 struct io_group *iog =3D e->efqd.root_group;
> + =A0 =A0 =A0 io_put_io_group_queues(e, iog);
> + =A0 =A0 =A0 kfree(iog);
> +}
> +
> +static void elv_slab_kill(void)
> +{
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Caller already ensured that pending RCU callbacks are =
completed,
> + =A0 =A0 =A0 =A0* so we should have no busy allocations at this point.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (elv_ioq_pool)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_cache_destroy(elv_ioq_pool);
> +}
> +
> +static int __init elv_slab_setup(void)
> +{
> + =A0 =A0 =A0 elv_ioq_pool =3D KMEM_CACHE(io_queue, 0);
> + =A0 =A0 =A0 if (!elv_ioq_pool)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;
> +
> + =A0 =A0 =A0 return 0;
> +fail:
> + =A0 =A0 =A0 elv_slab_kill();
> + =A0 =A0 =A0 return -ENOMEM;
> +}
> +
> +/* Initialize fair queueing data associated with elevator */
> +int elv_init_fq_data(struct request_queue *q, struct elevator_queue *e)
> +{
> + =A0 =A0 =A0 struct io_group *iog;
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &e->efqd;
> +
> + =A0 =A0 =A0 if (!elv_iosched_fair_queuing_enabled(e))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 iog =3D io_alloc_root_group(q, e, efqd);
> + =A0 =A0 =A0 if (iog =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> +
> + =A0 =A0 =A0 efqd->root_group =3D iog;
> + =A0 =A0 =A0 efqd->queue =3D q;
> +
> + =A0 =A0 =A0 init_timer(&efqd->idle_slice_timer);
> + =A0 =A0 =A0 efqd->idle_slice_timer.function =3D elv_idle_slice_timer;
> + =A0 =A0 =A0 efqd->idle_slice_timer.data =3D (unsigned long) efqd;
> +
> + =A0 =A0 =A0 INIT_WORK(&efqd->unplug_work, elv_kick_queue);
> +
> + =A0 =A0 =A0 INIT_LIST_HEAD(&efqd->idle_list);
> +
> + =A0 =A0 =A0 efqd->elv_slice[0] =3D elv_slice_async;
> + =A0 =A0 =A0 efqd->elv_slice[1] =3D elv_slice_sync;
> + =A0 =A0 =A0 efqd->elv_slice_idle =3D elv_slice_idle;
> + =A0 =A0 =A0 efqd->hw_tag =3D 1;
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/*
> + * elv_exit_fq_data is called before we call elevator_exit_fn. Before
> + * we ask elevator to cleanup its queues, we do the cleanup here so
> + * that all the group and idle tree references to ioq are dropped. Later
> + * during elevator cleanup, ioc reference will be dropped which will lead
> + * to removal of ioscheduler queue as well as associated ioq object.
> + */
> +void elv_exit_fq_data(struct elevator_queue *e)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &e->efqd;
> + =A0 =A0 =A0 struct request_queue *q =3D efqd->queue;
> +
> + =A0 =A0 =A0 if (!elv_iosched_fair_queuing_enabled(e))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 elv_shutdown_timer_wq(e);
> +
> + =A0 =A0 =A0 spin_lock_irq(q->queue_lock);
> + =A0 =A0 =A0 /* This should drop all the idle tree references of ioq */
> + =A0 =A0 =A0 elv_free_idle_ioq_list(e);
> + =A0 =A0 =A0 spin_unlock_irq(q->queue_lock);
> +
> + =A0 =A0 =A0 elv_shutdown_timer_wq(e);
> +
> + =A0 =A0 =A0 BUG_ON(timer_pending(&efqd->idle_slice_timer));
> + =A0 =A0 =A0 io_free_root_group(e);
> +}
> +
> +/*
> + * This is called after the io scheduler has cleaned up its data structr=
es.
> + * I don't think that this function is required. Right now just keeping =
it
> + * because cfq cleans up timer and work queue again after freeing up
> + * io contexts. To me io scheduler has already been drained out, and all
> + * the active queue have already been expired so time and work queue sho=
uld
> + * not been activated during cleanup process.
> + *
> + * Keeping it here for the time being. Will get rid of it later.
> + */
> +void elv_exit_fq_data_post(struct elevator_queue *e)
> +{
> + =A0 =A0 =A0 struct elv_fq_data *efqd =3D &e->efqd;
> +
> + =A0 =A0 =A0 if (!elv_iosched_fair_queuing_enabled(e))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 elv_shutdown_timer_wq(e);
> + =A0 =A0 =A0 BUG_ON(timer_pending(&efqd->idle_slice_timer));
> +}
> +
> +
> +static int __init elv_fq_init(void)
> +{
> + =A0 =A0 =A0 if (elv_slab_setup())
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 /* could be 0 on HZ < 1000 setups */
> +
> + =A0 =A0 =A0 if (!elv_slice_async)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_slice_async =3D 1;
> +
> + =A0 =A0 =A0 if (!elv_slice_idle)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_slice_idle =3D 1;
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> +module_init(elv_fq_init);
> diff --git a/block/elevator-fq.h b/block/elevator-fq.h
> new file mode 100644
> index 0000000..3bea279
> --- /dev/null
> +++ b/block/elevator-fq.h
> @@ -0,0 +1,488 @@
> +/*
> + * BFQ: data structures and common functions prototypes.
> + *
> + * Based on ideas and code from CFQ:
> + * Copyright (C) 2003 Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
> + *
> + * Copyright (C) 2008 Fabio Checconi <fabio-f9ZlEuEWxVeACYmtYXMKmw@public.gmane.org>
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Paolo Valente <paolo.valente@unim=
ore.it>
> + */
> +
> +#include <linux/blkdev.h>
> +
> +#ifndef _BFQ_SCHED_H
> +#define _BFQ_SCHED_H
> +
> +#define IO_IOPRIO_CLASSES =A0 =A0 =A03
> +
> +typedef u64 bfq_timestamp_t;
> +typedef unsigned long bfq_weight_t;
> +typedef unsigned long bfq_service_t;
> +struct io_entity;
> +struct io_queue;
> +
> +#ifdef CONFIG_ELV_FAIR_QUEUING
> +
> +/**
> + * struct bfq_service_tree - per ioprio_class service tree.
> + * @active: tree for active entities (i.e., those backlogged).
> + * @idle: tree for idle entities (i.e., those not backlogged, with V <=
=3D F_i).
> + * @first_idle: idle entity with minimum F_i.
> + * @last_idle: idle entity with maximum F_i.
> + * @vtime: scheduler virtual time.
> + * @wsum: scheduler weight sum; active and idle entities contribute to i=
t.
> + *
> + * Each service tree represents a B-WF2Q+ scheduler on its own. =A0Each
> + * ioprio_class has its own independent scheduler, and so its own
> + * bfq_service_tree. =A0All the fields are protected by the queue lock
> + * of the containing efqd.
> + */
> +struct io_service_tree {
> + =A0 =A0 =A0 struct rb_root active;
> + =A0 =A0 =A0 struct rb_root idle;
> +
> + =A0 =A0 =A0 struct io_entity *first_idle;
> + =A0 =A0 =A0 struct io_entity *last_idle;
> +
> + =A0 =A0 =A0 bfq_timestamp_t vtime;
> + =A0 =A0 =A0 bfq_weight_t wsum;
> +};
> +
> +/**
> + * struct bfq_sched_data - multi-class scheduler.
> + * @active_entity: entity under service.
> + * @next_active: head-of-the-line entity in the scheduler.
> + * @service_tree: array of service trees, one per ioprio_class.
> + *
> + * bfq_sched_data is the basic scheduler queue. =A0It supports three
> + * ioprio_classes, and can be used either as a toplevel queue or as
> + * an intermediate queue on a hierarchical setup.
> + * @next_active points to the active entity of the sched_data service
> + * trees that will be scheduled next.
> + *
> + * The supported ioprio_classes are the same as in CFQ, in descending
> + * priority order, IOPRIO_CLASS_RT, IOPRIO_CLASS_BE, IOPRIO_CLASS_IDLE.
> + * Requests from higher priority queues are served before all the
> + * requests from lower priority queues; among requests of the same
> + * queue requests are served according to B-WF2Q+.
> + * All the fields are protected by the queue lock of the containing bfqd.
> + */
> +struct io_sched_data {
> + =A0 =A0 =A0 struct io_entity *active_entity;
> + =A0 =A0 =A0 struct io_service_tree service_tree[IO_IOPRIO_CLASSES];
> +};
> +
> +/**
> + * struct bfq_entity - schedulable entity.
> + * @rb_node: service_tree member.
> + * @on_st: flag, true if the entity is on a tree (either the active or
> + * =A0 =A0 =A0 =A0 the idle one of its service_tree).
> + * @finish: B-WF2Q+ finish timestamp (aka F_i).
> + * @start: B-WF2Q+ start timestamp (aka S_i).
> + * @tree: tree the entity is enqueued into; %NULL if not on a tree.
> + * @min_start: minimum start time of the (active) subtree rooted at
> + * =A0 =A0 =A0 =A0 =A0 =A0 this entity; used for O(log N) lookups into a=
ctive trees.
> + * @service: service received during the last round of service.
> + * @budget: budget used to calculate F_i; F_i =3D S_i + @budget / @weigh=
t.
> + * @weight: weight of the queue, calculated as IOPRIO_BE_NR - @ioprio.
> + * @parent: parent entity, for hierarchical scheduling.
> + * @my_sched_data: for non-leaf nodes in the cgroup hierarchy, the
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 associated scheduler queue, %NULL on =
leaf nodes.
> + * @sched_data: the scheduler queue this entity belongs to.
> + * @ioprio: the ioprio in use.
> + * @new_ioprio: when an ioprio change is requested, the new ioprio value
> + * @ioprio_class: the ioprio_class in use.
> + * @new_ioprio_class: when an ioprio_class change is requested, the new
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ioprio_class value.
> + * @ioprio_changed: flag, true when the user requested an ioprio or
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ioprio_class change.
> + *
> + * A bfq_entity is used to represent either a bfq_queue (leaf node in the
> + * cgroup hierarchy) or a bfq_group into the upper level scheduler. =A0E=
ach
> + * entity belongs to the sched_data of the parent group in the cgroup
> + * hierarchy. =A0Non-leaf entities have also their own sched_data, stored
> + * in @my_sched_data.
> + *
> + * Each entity stores independently its priority values; this would allow
> + * different weights on different devices, but this functionality is not
> + * exported to userspace by now. =A0Priorities are updated lazily, first
> + * storing the new values into the new_* fields, then setting the
> + * @ioprio_changed flag. =A0As soon as there is a transition in the enti=
ty
> + * state that allows the priority update to take place the effective and
> + * the requested priority values are synchronized.
> + *
> + * The weight value is calculated from the ioprio to export the same
> + * interface as CFQ. =A0When dealing with ``well-behaved'' queues (i.e.,
> + * queues that do not spend too much time to consume their budget and
> + * have true sequential behavior, and when there are no external factors
> + * breaking anticipation) the relative weights at each level of the
> + * cgroups hierarchy should be guaranteed.
> + * All the fields are protected by the queue lock of the containing bfqd.
> + */
> +struct io_entity {
> + =A0 =A0 =A0 struct rb_node rb_node;
> +
> + =A0 =A0 =A0 int on_st;
> +
> + =A0 =A0 =A0 bfq_timestamp_t finish;
> + =A0 =A0 =A0 bfq_timestamp_t start;
> +
> + =A0 =A0 =A0 struct rb_root *tree;
> +
> + =A0 =A0 =A0 bfq_timestamp_t min_start;
> +
> + =A0 =A0 =A0 bfq_service_t service, budget;
> + =A0 =A0 =A0 bfq_weight_t weight;
> +
> + =A0 =A0 =A0 struct io_entity *parent;
> +
> + =A0 =A0 =A0 struct io_sched_data *my_sched_data;
> + =A0 =A0 =A0 struct io_sched_data *sched_data;
> +
> + =A0 =A0 =A0 unsigned short ioprio, new_ioprio;
> + =A0 =A0 =A0 unsigned short ioprio_class, new_ioprio_class;
> +
> + =A0 =A0 =A0 int ioprio_changed;
> +};
> +
> +/*
> + * A common structure embedded by every io scheduler into their respecti=
ve
> + * queue structure.
> + */
> +struct io_queue {
> + =A0 =A0 =A0 struct io_entity entity;
> + =A0 =A0 =A0 atomic_t ref;
> + =A0 =A0 =A0 unsigned int flags;
> +
> + =A0 =A0 =A0 /* Pointer to generic elevator data structure */
> + =A0 =A0 =A0 struct elv_fq_data *efqd;
> + =A0 =A0 =A0 struct list_head queue_list;
> + =A0 =A0 =A0 pid_t pid;
> +
> + =A0 =A0 =A0 /* Number of requests queued on this io queue */
> + =A0 =A0 =A0 unsigned long nr_queued;
> +
> + =A0 =A0 =A0 /* Requests dispatched from this queue */
> + =A0 =A0 =A0 int dispatched;
> +
> + =A0 =A0 =A0 /* Keep a track of think time of processes in this queue */
> + =A0 =A0 =A0 unsigned long last_end_request;
> + =A0 =A0 =A0 unsigned long ttime_total;
> + =A0 =A0 =A0 unsigned long ttime_samples;
> + =A0 =A0 =A0 unsigned long ttime_mean;
> +
> + =A0 =A0 =A0 unsigned long slice_end;
> +
> + =A0 =A0 =A0 /* Pointer to io scheduler's queue */
> + =A0 =A0 =A0 void *sched_queue;
> +};
> +
> +struct io_group {
> + =A0 =A0 =A0 struct io_sched_data sched_data;
> +
> + =A0 =A0 =A0 /* async_queue and idle_queue are used only for cfq */
> + =A0 =A0 =A0 struct io_queue *async_queue[2][IOPRIO_BE_NR];
> + =A0 =A0 =A0 struct io_queue *async_idle_queue;
> +};
> +
> +struct elv_fq_data {
> + =A0 =A0 =A0 struct io_group *root_group;
> +
> + =A0 =A0 =A0 /* List of io queues on idle tree. */
> + =A0 =A0 =A0 struct list_head idle_list;
> +
> + =A0 =A0 =A0 struct request_queue *queue;
> + =A0 =A0 =A0 unsigned int busy_queues;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Used to track any pending rt requests so we can pre-em=
pt current
> + =A0 =A0 =A0 =A0* non-RT cfqq in service when this value is non-zero.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 unsigned int busy_rt_queues;
> +
> + =A0 =A0 =A0 /* Number of requests queued */
> + =A0 =A0 =A0 int rq_queued;
> +
> + =A0 =A0 =A0 /* Pointer to the ioscheduler queue being served */
> + =A0 =A0 =A0 void *active_queue;
> +
> + =A0 =A0 =A0 int rq_in_driver;
> + =A0 =A0 =A0 int hw_tag;
> + =A0 =A0 =A0 int hw_tag_samples;
> + =A0 =A0 =A0 int rq_in_driver_peak;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* elevator fair queuing layer has the capability to prov=
ide idling
> + =A0 =A0 =A0 =A0* for ensuring fairness for processes doing dependent re=
ads.
> + =A0 =A0 =A0 =A0* This might be needed to ensure fairness among two proc=
esses doing
> + =A0 =A0 =A0 =A0* synchronous reads in two different cgroups. noop and d=
eadline don't
> + =A0 =A0 =A0 =A0* have any notion of anticipation/idling. As of now, the=
se are the
> + =A0 =A0 =A0 =A0* users of this functionality.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 unsigned int elv_slice_idle;
> + =A0 =A0 =A0 struct timer_list idle_slice_timer;
> + =A0 =A0 =A0 struct work_struct unplug_work;
> +
> + =A0 =A0 =A0 unsigned int elv_slice[2];
> +};
> +
> +extern int elv_slice_idle;
> +extern int elv_slice_async;
> +
> +/* Logging facilities. */
> +#define elv_log_ioq(efqd, ioq, fmt, args...) \
> + =A0 =A0 =A0 blk_add_trace_msg((efqd)->queue, "elv%d%c " fmt, (ioq)->pid=
, =A0 =A0\
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_ioq_syn=
c(ioq) ? 'S' : 'A', ##args)
> +
> +#define elv_log(efqd, fmt, args...) \
> + =A0 =A0 =A0 blk_add_trace_msg((efqd)->queue, "elv " fmt, ##args)
> +
> +#define ioq_sample_valid(samples) =A0 ((samples) > 80)
> +
> +/* Some shared queue flag manipulation functions among elevators */
> +
> +enum elv_queue_state_flags {
> + =A0 =A0 =A0 ELV_QUEUE_FLAG_busy =3D 0, =A0 =A0 =A0 =A0 =A0/* has reques=
ts or is under service */
> + =A0 =A0 =A0 ELV_QUEUE_FLAG_sync, =A0 =A0 =A0 =A0 =A0 =A0 =A0/* synchron=
ous queue */
> + =A0 =A0 =A0 ELV_QUEUE_FLAG_idle_window, =A0 =A0 =A0 /* elevator slice i=
dling enabled */
> + =A0 =A0 =A0 ELV_QUEUE_FLAG_wait_request, =A0 =A0 =A0/* waiting for a re=
quest */
> + =A0 =A0 =A0 ELV_QUEUE_FLAG_must_dispatch, =A0 =A0 /* must be allowed a =
dispatch */
> + =A0 =A0 =A0 ELV_QUEUE_FLAG_slice_new, =A0 =A0 =A0 =A0 /* no requests di=
spatched in slice */
> + =A0 =A0 =A0 ELV_QUEUE_FLAG_NR,
> +};
> +
> +#define ELV_IO_QUEUE_FLAG_FNS(name) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> +static inline void elv_mark_ioq_##name(struct io_queue *ioq) =A0 =A0 =A0=
 =A0 =A0 \
> +{ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 (ioq)->flags |=3D (1 << ELV_QUEUE_FLAG_##name); =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 \
> +} =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> +static inline void elv_clear_ioq_##name(struct io_queue *ioq) =A0 =A0 =
=A0 =A0 =A0\
> +{ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 (ioq)->flags &=3D ~(1 << ELV_QUEUE_FLAG_##name); =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0\
> +} =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> +static inline int elv_ioq_##name(struct io_queue *ioq) =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> +{ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 return ((ioq)->flags & (1 << ELV_QUEUE_FLAG_##name)) !=3D 0=
; =A0 =A0 =A0\
> +}
> +
> +ELV_IO_QUEUE_FLAG_FNS(busy)
> +ELV_IO_QUEUE_FLAG_FNS(sync)
> +ELV_IO_QUEUE_FLAG_FNS(wait_request)
> +ELV_IO_QUEUE_FLAG_FNS(must_dispatch)
> +ELV_IO_QUEUE_FLAG_FNS(idle_window)
> +ELV_IO_QUEUE_FLAG_FNS(slice_new)
> +
> +static inline struct io_service_tree *
> +io_entity_service_tree(struct io_entity *entity)
> +{
> + =A0 =A0 =A0 struct io_sched_data *sched_data =3D entity->sched_data;
> + =A0 =A0 =A0 unsigned int idx =3D entity->ioprio_class - 1;
> +
> + =A0 =A0 =A0 BUG_ON(idx >=3D IO_IOPRIO_CLASSES);
> + =A0 =A0 =A0 BUG_ON(sched_data =3D=3D NULL);
> +
> + =A0 =A0 =A0 return sched_data->service_tree + idx;
> +}
> +
> +/* A request got dispatched from the io_queue. Do the accounting. */
> +static inline void elv_ioq_request_dispatched(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 ioq->dispatched++;
> +}
> +
> +static inline int elv_ioq_slice_used(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 if (elv_ioq_slice_new(ioq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 if (time_before(jiffies, ioq->slice_end))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> +
> + =A0 =A0 =A0 return 1;
> +}
> +
> +/* How many request are currently dispatched from the queue */
> +static inline int elv_ioq_nr_dispatched(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 return ioq->dispatched;
> +}
> +
> +/* How many request are currently queued in the queue */
> +static inline int elv_ioq_nr_queued(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 return ioq->nr_queued;
> +}
> +
> +static inline pid_t elv_ioq_pid(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 return ioq->pid;
> +}
> +
> +static inline unsigned long elv_ioq_ttime_mean(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 return ioq->ttime_mean;
> +}
> +
> +static inline unsigned long elv_ioq_sample_valid(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 return ioq_sample_valid(ioq->ttime_samples);
> +}
> +
> +static inline void elv_get_ioq(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 atomic_inc(&ioq->ref);
> +}
> +
> +static inline void elv_ioq_set_slice_end(struct io_queue *ioq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 unsigned long slice_end)
> +{
> + =A0 =A0 =A0 ioq->slice_end =3D slice_end;
> +}
> +
> +static inline int elv_ioq_class_idle(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 return ioq->entity.ioprio_class =3D=3D IOPRIO_CLASS_IDLE;
> +}
> +
> +static inline int elv_ioq_class_rt(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 return ioq->entity.ioprio_class =3D=3D IOPRIO_CLASS_RT;
> +}
> +
> +static inline int elv_ioq_ioprio_class(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 return ioq->entity.new_ioprio_class;
> +}
> +
> +static inline int elv_ioq_ioprio(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 return ioq->entity.new_ioprio;
> +}
> +
> +static inline void elv_ioq_set_ioprio_class(struct io_queue *ioq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 int ioprio_class)
> +{
> + =A0 =A0 =A0 ioq->entity.new_ioprio_class =3D ioprio_class;
> + =A0 =A0 =A0 ioq->entity.ioprio_changed =3D 1;
> +}
> +
> +static inline void elv_ioq_set_ioprio(struct io_queue *ioq, int ioprio)
> +{
> + =A0 =A0 =A0 ioq->entity.new_ioprio =3D ioprio;
> + =A0 =A0 =A0 ioq->entity.ioprio_changed =3D 1;
> +}
> +
> +static inline void *ioq_sched_queue(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 if (ioq)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ioq->sched_queue;
> + =A0 =A0 =A0 return NULL;
> +}
> +
> +static inline struct io_group *ioq_to_io_group(struct io_queue *ioq)
> +{
> + =A0 =A0 =A0 return container_of(ioq->entity.sched_data, struct io_group,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 sched_data);
> +}
> +
> +/* Functions used by blksysfs.c */
> +extern ssize_t elv_slice_idle_show(struct request_queue *q, char *name);
> +extern ssize_t elv_slice_idle_store(struct request_queue *q, const char =
*name,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 size_t count);
> +extern ssize_t elv_slice_sync_show(struct request_queue *q, char *name);
> +extern ssize_t elv_slice_sync_store(struct request_queue *q, const char =
*name,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 size_t count);
> +extern ssize_t elv_slice_async_show(struct request_queue *q, char *name);
> +extern ssize_t elv_slice_async_store(struct request_queue *q, const char=
 *name,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 size_t count);
> +
> +/* Functions used by elevator.c */
> +extern int elv_init_fq_data(struct request_queue *q, struct elevator_que=
ue *e);
> +extern void elv_exit_fq_data(struct elevator_queue *e);
> +extern void elv_exit_fq_data_post(struct elevator_queue *e);
> +
> +extern void elv_ioq_request_add(struct request_queue *q, struct request =
*rq);
> +extern void elv_ioq_request_removed(struct elevator_queue *e,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct request *rq);
> +extern void elv_fq_dispatched_request(struct elevator_queue *e,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct request *rq);
> +
> +extern void elv_fq_activate_rq(struct request_queue *q, struct request *=
rq);
> +extern void elv_fq_deactivate_rq(struct request_queue *q, struct request=
 *rq);
> +
> +extern void elv_ioq_completed_request(struct request_queue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct requ=
est *rq);
> +
> +extern void *elv_fq_select_ioq(struct request_queue *q, int force);
> +extern struct io_queue *rq_ioq(struct request *rq);
> +
> +/* Functions used by io schedulers */
> +extern void elv_put_ioq(struct io_queue *ioq);
> +extern void __elv_ioq_slice_expired(struct request_queue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct io_queue *ioq);
> +extern int elv_init_ioq(struct elevator_queue *eq, struct io_queue *ioq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *sched_queue, int ioprio_class, int io=
prio, int is_sync);
> +extern void elv_schedule_dispatch(struct request_queue *q);
> +extern int elv_hw_tag(struct elevator_queue *e);
> +extern void *elv_active_sched_queue(struct elevator_queue *e);
> +extern int elv_mod_idle_slice_timer(struct elevator_queue *eq,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 unsigned long expires);
> +extern int elv_del_idle_slice_timer(struct elevator_queue *eq);
> +extern unsigned int elv_get_slice_idle(struct elevator_queue *eq);
> +extern void *io_group_async_queue_prio(struct io_group *iog, int ioprio_=
class,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int ioprio);
> +extern void io_group_set_async_queue(struct io_group *iog, int ioprio_cl=
ass,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 int ioprio, struct io_queue *ioq);
> +extern struct io_group *io_lookup_io_group_current(struct request_queue =
*q);
> +extern int elv_nr_busy_ioq(struct elevator_queue *e);
> +extern int elv_nr_busy_rt_ioq(struct elevator_queue *e);
> +extern struct io_queue *elv_alloc_ioq(struct request_queue *q, gfp_t gfp=
_mask);
> +extern void elv_free_ioq(struct io_queue *ioq);
> +
> +#else /* CONFIG_ELV_FAIR_QUEUING */
> +
> +static inline int elv_init_fq_data(struct request_queue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct elevator_queue *e)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static inline void elv_exit_fq_data(struct elevator_queue *e) {}
> +static inline void elv_exit_fq_data_post(struct elevator_queue *e) {}
> +
> +static inline void elv_fq_activate_rq(struct request_queue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct request *rq)
> +{
> +}
> +
> +static inline void elv_fq_deactivate_rq(struct request_queue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct request *rq)
> +{
> +}
> +
> +static inline void elv_fq_dispatched_request(struct elevator_queue *e,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct request *rq)
> +{
> +}
> +
> +static inline void elv_ioq_request_removed(struct elevator_queue *e,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct request *rq)
> +{
> +}
> +
> +static inline void elv_ioq_request_add(struct request_queue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 struct request *rq)
> +{
> +}
> +
> +static inline void elv_ioq_completed_request(struct request_queue *q,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct request *rq)
> +{
> +}
> +
> +static inline void *ioq_sched_queue(struct io_queue *ioq) { return NULL;=
 }
> +static inline struct io_queue *rq_ioq(struct request *rq) { return NULL;=
 }
> +static inline void *elv_fq_select_ioq(struct request_queue *q, int force)
> +{
> + =A0 =A0 =A0 return NULL;
> +}
> +#endif /* CONFIG_ELV_FAIR_QUEUING */
> +#endif /* _BFQ_SCHED_H */
> diff --git a/block/elevator.c b/block/elevator.c
> index 7073a90..c2f07f5 100644
> --- a/block/elevator.c
> +++ b/block/elevator.c
> @@ -231,6 +231,9 @@ static struct elevator_queue *elevator_alloc(struct r=
equest_queue *q,
> =A0 =A0 =A0 =A0for (i =3D 0; i < ELV_HASH_ENTRIES; i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0INIT_HLIST_HEAD(&eq->hash[i]);
>
> + =A0 =A0 =A0 if (elv_init_fq_data(q, eq))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto err;
> +
> =A0 =A0 =A0 =A0return eq;
> =A0err:
> =A0 =A0 =A0 =A0kfree(eq);
> @@ -301,9 +304,11 @@ EXPORT_SYMBOL(elevator_init);
> =A0void elevator_exit(struct elevator_queue *e)
> =A0{
> =A0 =A0 =A0 =A0mutex_lock(&e->sysfs_lock);
> + =A0 =A0 =A0 elv_exit_fq_data(e);
> =A0 =A0 =A0 =A0if (e->ops->elevator_exit_fn)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0e->ops->elevator_exit_fn(e);
> =A0 =A0 =A0 =A0e->ops =3D NULL;
> + =A0 =A0 =A0 elv_exit_fq_data_post(e);
> =A0 =A0 =A0 =A0mutex_unlock(&e->sysfs_lock);
>
> =A0 =A0 =A0 =A0kobject_put(&e->kobj);
> @@ -314,6 +319,8 @@ static void elv_activate_rq(struct request_queue *q, =
struct request *rq)
> =A0{
> =A0 =A0 =A0 =A0struct elevator_queue *e =3D q->elevator;
>
> + =A0 =A0 =A0 elv_fq_activate_rq(q, rq);
> +
> =A0 =A0 =A0 =A0if (e->ops->elevator_activate_req_fn)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0e->ops->elevator_activate_req_fn(q, rq);
> =A0}
> @@ -322,6 +329,8 @@ static void elv_deactivate_rq(struct request_queue *q=
, struct request *rq)
> =A0{
> =A0 =A0 =A0 =A0struct elevator_queue *e =3D q->elevator;
>
> + =A0 =A0 =A0 elv_fq_deactivate_rq(q, rq);
> +
> =A0 =A0 =A0 =A0if (e->ops->elevator_deactivate_req_fn)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0e->ops->elevator_deactivate_req_fn(q, rq);
> =A0}
> @@ -446,6 +455,7 @@ void elv_dispatch_sort(struct request_queue *q, struc=
t request *rq)
> =A0 =A0 =A0 =A0elv_rqhash_del(q, rq);
>
> =A0 =A0 =A0 =A0q->nr_sorted--;
> + =A0 =A0 =A0 elv_fq_dispatched_request(q->elevator, rq);
>
> =A0 =A0 =A0 =A0boundary =3D q->end_sector;
> =A0 =A0 =A0 =A0stop_flags =3D REQ_SOFTBARRIER | REQ_HARDBARRIER | REQ_STA=
RTED;
> @@ -486,6 +496,7 @@ void elv_dispatch_add_tail(struct request_queue *q, s=
truct request *rq)
> =A0 =A0 =A0 =A0elv_rqhash_del(q, rq);
>
> =A0 =A0 =A0 =A0q->nr_sorted--;
> + =A0 =A0 =A0 elv_fq_dispatched_request(q->elevator, rq);
>
> =A0 =A0 =A0 =A0q->end_sector =3D rq_end_sector(rq);
> =A0 =A0 =A0 =A0q->boundary_rq =3D rq;
> @@ -553,6 +564,7 @@ void elv_merge_requests(struct request_queue *q, stru=
ct request *rq,
> =A0 =A0 =A0 =A0elv_rqhash_del(q, next);
>
> =A0 =A0 =A0 =A0q->nr_sorted--;
> + =A0 =A0 =A0 elv_ioq_request_removed(e, next);
> =A0 =A0 =A0 =A0q->last_merge =3D rq;
> =A0}
>
> @@ -657,12 +669,8 @@ void elv_insert(struct request_queue *q, struct requ=
est *rq, int where)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->last_me=
rge =3D rq;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Some ioscheds (cfq) run q->request_fn =
directly, so
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* rq cannot be accessed after calling
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* elevator_add_req_fn.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->elevator->ops->elevator_add_req_fn(q, r=
q);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_ioq_request_add(q, rq);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> =A0 =A0 =A0 =A0case ELEVATOR_INSERT_REQUEUE:
> @@ -872,13 +880,12 @@ void elv_dequeue_request(struct request_queue *q, s=
truct request *rq)
>
> =A0int elv_queue_empty(struct request_queue *q)
> =A0{
> - =A0 =A0 =A0 struct elevator_queue *e =3D q->elevator;
> -
> =A0 =A0 =A0 =A0if (!list_empty(&q->queue_head))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> - =A0 =A0 =A0 if (e->ops->elevator_queue_empty_fn)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return e->ops->elevator_queue_empty_fn(q);
> + =A0 =A0 =A0 /* Hopefully nr_sorted works and no need to call queue_empt=
y_fn */
> + =A0 =A0 =A0 if (q->nr_sorted)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>
> =A0 =A0 =A0 =A0return 1;
> =A0}
> @@ -953,8 +960,11 @@ void elv_completed_request(struct request_queue *q, =
struct request *rq)
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (blk_account_rq(rq)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0q->in_flight--;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (blk_sorted_rq(rq) && e->ops->elevator_c=
ompleted_req_fn)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->ops->elevator_completed_=
req_fn(q, rq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (blk_sorted_rq(rq)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (e->ops->elevator_comple=
ted_req_fn)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 e->ops->ele=
vator_completed_req_fn(q, rq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 elv_ioq_completed_request(q=
, rq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/*
> @@ -1242,3 +1252,17 @@ struct request *elv_rb_latter_request(struct reque=
st_queue *q,
> =A0 =A0 =A0 =A0return NULL;
> =A0}
> =A0EXPORT_SYMBOL(elv_rb_latter_request);
> +
> +/* Get the io scheduler queue pointer. For cfq, it is stored in rq->ioq*/
> +void *elv_get_sched_queue(struct request_queue *q, struct request *rq)
> +{
> + =A0 =A0 =A0 return ioq_sched_queue(rq_ioq(rq));
> +}
> +EXPORT_SYMBOL(elv_get_sched_queue);
> +
> +/* Select an ioscheduler queue to dispatch request from. */
> +void *elv_select_sched_queue(struct request_queue *q, int force)
> +{
> + =A0 =A0 =A0 return ioq_sched_queue(elv_fq_select_ioq(q, force));
> +}
> +EXPORT_SYMBOL(elv_select_sched_queue);
> diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
> index b4f71f1..96a94c9 100644
> --- a/include/linux/blkdev.h
> +++ b/include/linux/blkdev.h
> @@ -245,6 +245,11 @@ struct request {
>
> =A0 =A0 =A0 =A0/* for bidi */
> =A0 =A0 =A0 =A0struct request *next_rq;
> +
> +#ifdef CONFIG_ELV_FAIR_QUEUING
> + =A0 =A0 =A0 /* io queue request belongs to */
> + =A0 =A0 =A0 struct io_queue *ioq;
> +#endif
> =A0};
>
> =A0static inline unsigned short req_get_ioprio(struct request *req)
> diff --git a/include/linux/elevator.h b/include/linux/elevator.h
> index c59b769..679c149 100644
> --- a/include/linux/elevator.h
> +++ b/include/linux/elevator.h
> @@ -2,6 +2,7 @@
> =A0#define _LINUX_ELEVATOR_H
>
> =A0#include <linux/percpu.h>
> +#include "../../block/elevator-fq.h"
>
> =A0#ifdef CONFIG_BLOCK
>
> @@ -29,6 +30,18 @@ typedef void (elevator_deactivate_req_fn) (struct requ=
est_queue *, struct reques
>
> =A0typedef void *(elevator_init_fn) (struct request_queue *);
> =A0typedef void (elevator_exit_fn) (struct elevator_queue *);
> +#ifdef CONFIG_ELV_FAIR_QUEUING
> +typedef void (elevator_free_sched_queue_fn) (struct elevator_queue*, voi=
d *);
> +typedef void (elevator_active_ioq_set_fn) (struct request_queue*, void *=
, int);
> +typedef void (elevator_active_ioq_reset_fn) (struct request_queue *, voi=
d*);
> +typedef void (elevator_arm_slice_timer_fn) (struct request_queue*, void*=
);
> +typedef int (elevator_should_preempt_fn) (struct request_queue*, void*,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct request*);
> +typedef int (elevator_update_idle_window_fn) (struct elevator_queue*, vo=
id*,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct request*);
> +typedef struct io_queue* (elevator_close_cooperator_fn) (struct request_=
queue*,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 void*, int probe);
> +#endif
>
> =A0struct elevator_ops
> =A0{
> @@ -56,6 +69,17 @@ struct elevator_ops
> =A0 =A0 =A0 =A0elevator_init_fn *elevator_init_fn;
> =A0 =A0 =A0 =A0elevator_exit_fn *elevator_exit_fn;
> =A0 =A0 =A0 =A0void (*trim)(struct io_context *);
> +
> +#ifdef CONFIG_ELV_FAIR_QUEUING
> + =A0 =A0 =A0 elevator_free_sched_queue_fn *elevator_free_sched_queue_fn;
> + =A0 =A0 =A0 elevator_active_ioq_set_fn *elevator_active_ioq_set_fn;
> + =A0 =A0 =A0 elevator_active_ioq_reset_fn *elevator_active_ioq_reset_fn;
> +
> + =A0 =A0 =A0 elevator_arm_slice_timer_fn *elevator_arm_slice_timer_fn;
> + =A0 =A0 =A0 elevator_should_preempt_fn *elevator_should_preempt_fn;
> + =A0 =A0 =A0 elevator_update_idle_window_fn *elevator_update_idle_window=
_fn;
> + =A0 =A0 =A0 elevator_close_cooperator_fn *elevator_close_cooperator_fn;
> +#endif
> =A0};
>
> =A0#define ELV_NAME_MAX =A0 (16)
> @@ -76,6 +100,9 @@ struct elevator_type
> =A0 =A0 =A0 =A0struct elv_fs_entry *elevator_attrs;
> =A0 =A0 =A0 =A0char elevator_name[ELV_NAME_MAX];
> =A0 =A0 =A0 =A0struct module *elevator_owner;
> +#ifdef CONFIG_ELV_FAIR_QUEUING
> + =A0 =A0 =A0 int elevator_features;
> +#endif
> =A0};
>
> =A0/*
> @@ -89,6 +116,10 @@ struct elevator_queue
> =A0 =A0 =A0 =A0struct elevator_type *elevator_type;
> =A0 =A0 =A0 =A0struct mutex sysfs_lock;
> =A0 =A0 =A0 =A0struct hlist_head *hash;
> +#ifdef CONFIG_ELV_FAIR_QUEUING
> + =A0 =A0 =A0 /* fair queuing data */
> + =A0 =A0 =A0 struct elv_fq_data efqd;
> +#endif
> =A0};
>
> =A0/*
> @@ -209,5 +240,25 @@ enum {
> =A0 =A0 =A0 =A0__val; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> =A0})
>
> +/* iosched can let elevator know their feature set/capability */
> +#ifdef CONFIG_ELV_FAIR_QUEUING
> +
> +/* iosched wants to use fq logic of elevator layer */
> +#define =A0 =A0 =A0 =A0ELV_IOSCHED_NEED_FQ =A0 =A0 1
> +
> +static inline int elv_iosched_fair_queuing_enabled(struct elevator_queue=
 *e)
> +{
> + =A0 =A0 =A0 return (e->elevator_type->elevator_features) & ELV_IOSCHED_=
NEED_FQ;
> +}
> +
> +#else /* ELV_IOSCHED_FAIR_QUEUING */
> +
> +static inline int elv_iosched_fair_queuing_enabled(struct elevator_queue=
 *e)
> +{
> + =A0 =A0 =A0 return 0;
> +}
> +#endif /* ELV_IOSCHED_FAIR_QUEUING */
> +extern void *elv_get_sched_queue(struct request_queue *q, struct request=
 *rq);
> +extern void *elv_select_sched_queue(struct request_queue *q, int force);
> =A0#endif /* CONFIG_BLOCK */
> =A0#endif
> --
> 1.6.0.1
>
>
