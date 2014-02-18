From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/4] x86: Add Cache QoS Monitoring (CQM) support
Date: Tue, 18 Feb 2014 17:29:42 +0000
Message-ID: <1392744567.3069.42.camel@ppwaskie-mobl.amr.corp.intel.com>
References: <20140106212623.GH30183@twins.programming.kicks-ass.net>
	<1389044899.32504.43.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140106221251.GJ30183@twins.programming.kicks-ass.net>
	<1389048315.32504.57.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140107083440.GL30183@twins.programming.kicks-ass.net>
	<1389107743.32504.69.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140107211229.GF2480@laptop.programming.kicks-ass.net>
	<1389380100.32504.172.camel@ppwaskie-mobl.amr.corp.intel.com>
	<20140113075528.GR7572@laptop.programming.kicks-ass.net>
	<52D57AC2.3090109@zytor.com>
	<20140127173420.GA9636@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4613417894915767777=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140127173420.GA9636-ndre7Fmf5hadTX5a5knrm8zTDFooKrT+cvkQGrU6aU0@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Stephane Eranian <eranian-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, "cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
List-Id: containers.vger.kernel.org

--===============4613417894915767777==
Content-Language: en-US
Content-Type: multipart/signed; micalg=sha-1;
	protocol="application/x-pkcs7-signature"; boundary="=-Y6Hnq9jaSTxGHYRJvlaz"

--=-Y6Hnq9jaSTxGHYRJvlaz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-01-27 at 18:34 +0100, Peter Zijlstra wrote:

Hi Peter,

First of all, sorry for the delay in responding.  I've been talking with
the CPU architects to make sure we're going down the right path here
before coming back to this. Responses below.

> On Tue, Jan 14, 2014 at 09:58:26AM -0800, H. Peter Anvin wrote:
> > On 01/12/2014 11:55 PM, Peter Zijlstra wrote:
> > >=20
> > > The problem is, since there's a limited number of RMIDs we have to
> > > rotate at some point, but since changing RMIDs is nondeterministic we
> > > can't.
> > >=20
> >=20
> > This is fundamentally the crux here.  RMIDs are quite expensive for the
> > hardware to implement, so they are limited - but recycling them is
> > *very* expensive because you literally have to touch every line in the
> > cache.
>=20
> Its not a problem that changing the task:RMID map is expensive, what is
> a problem is that there's no deterministic fashion of doing it.

We are going to add to the SDM that changing RMID's often/frequently is
not the intended use case for this feature, and can cause bogus data.
The real intent is to land threads into an RMID, and run that until the
threads are effectively done.

That being said, reassigning a thread to a new RMID is certainly
supported, just "frequent" updates is not encouraged at all.

> That said; I think I've got a sort-of workaround for that. See the
> largish comment near cache_pmu_rotate().



> I've also illustrated how to use perf-cgroup for this.

I do see that, however the userspace interface for this isn't ideal for
how the feature is intended to be used.  I'm still planning to have this
be managed per process in /proc/<pid>, I just had other priorities push
this back a bit on my stovetop.

Also, now that the new SDM is available, there is a new feature added to
the same family as CQM, called Memory Bandwidth Monitoring (MBM).  The
original cgroup approach would have allowed another subsystem be added
next to cacheqos; the perf-cgroup here is not easily expandable.
The /proc/<pid> approach can add MBM pretty easily alongside CQM.

> The below is a rough draft, most if not all XXXs should be
> fixed/finished. But given I don't actually have hardware that supports
> this stuff (afaik) I couldn't be arsed.

The hardware is not publicly available yet, but I know that Red Hat and
others have some of these platforms for testing.

I really appreciate the patch.  There was a good amount of thought put
into this, and gave a good set of different viewpoints.  I'll keep the
comments all here in one place, it'll be easier to discuss than
disjointed in the code.

The rotation idea to reclaim RMID's no longer in use is interesting.
This differs from the original patch where the original patch would
reclaim the RMID when monitoring was disabled for that group of
processes.

I can see a merged sort of approach, where if monitoring for a group of
processes is disabled, we can place that RMID onto a reclaim list.  The
next time an RMID is requested (monitoring is enabled for a
process/group of processes), the reclaim list is searched for an RMID
that has 0 occupancy (i.e. not in use), or worst-case, find and assign
one with the lowest occupancy.  I did discuss this with hpa offline and
this seemed reasonable.

Thoughts?

Thanks,
-PJ

>=20
> ---
>  include/linux/perf_event.h              |   33 +
>  kernel/events/core.c                    |   22 -
>  x86/kernel/cpu/perf_event_intel_cache.c |  687 +++++++++++++++++++++++++=
+++++++
>  3 files changed, 725 insertions(+), 17 deletions(-)
>=20
> --- a/include/linux/perf_event.h
> +++ b/include/linux/perf_event.h
> @@ -126,6 +126,14 @@ struct hw_perf_event {
>  			/* for tp_event->class */
>  			struct list_head	tp_list;
>  		};
> +		struct { /* cache_pmu */
> +			struct task_struct	*cache_target;
> +			int			cache_state;
> +			int			cache_rmid;
> +			struct list_head	cache_events_entry;
> +			struct list_head	cache_groups_entry;
> +			struct list_head	cache_group_entry;
> +		};
>  #ifdef CONFIG_HAVE_HW_BREAKPOINT
>  		struct { /* breakpoint */
>  			/*
> @@ -526,6 +534,31 @@ struct perf_output_handle {
>  	int				page;
>  };
> =20
> +#ifdef CONFIG_CGROUP_PERF
> +
> +struct perf_cgroup_info;
> +
> +struct perf_cgroup {
> +	struct cgroup_subsys_state	css;
> +	struct perf_cgroup_info	__percpu *info;
> +};
> +
> +/*
> + * Must ensure cgroup is pinned (css_get) before calling
> + * this function. In other words, we cannot call this function
> + * if there is no cgroup event for the current CPU context.
> + *
> + * XXX: its not safe to use this thing!!!
> + */
> +static inline struct perf_cgroup *
> +perf_cgroup_from_task(struct task_struct *task)
> +{
> +	return container_of(task_css(task, perf_subsys_id),
> +			    struct perf_cgroup, css);
> +}
> +
> +#endif /* CONFIG_CGROUP_PERF */
> +
>  #ifdef CONFIG_PERF_EVENTS
> =20
>  extern int perf_pmu_register(struct pmu *pmu, const char *name, int type=
);
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -329,23 +329,6 @@ struct perf_cgroup_info {
>  	u64				timestamp;
>  };
> =20
> -struct perf_cgroup {
> -	struct cgroup_subsys_state	css;
> -	struct perf_cgroup_info	__percpu *info;
> -};
> -
> -/*
> - * Must ensure cgroup is pinned (css_get) before calling
> - * this function. In other words, we cannot call this function
> - * if there is no cgroup event for the current CPU context.
> - */
> -static inline struct perf_cgroup *
> -perf_cgroup_from_task(struct task_struct *task)
> -{
> -	return container_of(task_css(task, perf_subsys_id),
> -			    struct perf_cgroup, css);
> -}
> -
>  static inline bool
>  perf_cgroup_match(struct perf_event *event)
>  {
> @@ -6711,6 +6694,11 @@ perf_event_alloc(struct perf_event_attr
>  	if (task) {
>  		event->attach_state =3D PERF_ATTACH_TASK;
> =20
> +		/*
> +		 * XXX fix for cache_target, dynamic type won't have an easy test,
> +		 * maybe move target crap into generic event.
> +		 */
> +
>  		if (attr->type =3D=3D PERF_TYPE_TRACEPOINT)
>  			event->hw.tp_target =3D task;
>  #ifdef CONFIG_HAVE_HW_BREAKPOINT
> --- /dev/null
> +++ b/x86/kernel/cpu/perf_event_intel_cache.c
> @@ -0,0 +1,687 @@
> +#include <asm/processor.h>
> +#include <linux/idr.h>
> +#include <linux/raw_spinlock.h>
> +#include <linux/perf_event.h>
> +
> +
> +#define MSR_IA32_PQR_ASSOC	0x0c8f
> +#define MSR_IA32_QM_CTR		0x0c8e
> +#define MSR_IA32_QM_EVTSEL	0x0c8d
> +
> +unsigned int max_rmid;
> +
> +unsigned int l3_scale; /* supposedly cacheline size */
> +unsigned int l3_max_rmid;
> +
> +
> +struct cache_pmu_state {
> +	raw_spin_lock		lock;
> +	int			rmid;
> +	int 			cnt;
> +};
> +
> +static DEFINE_PER_CPU(struct cache_pmu_state, state);
> +
> +/*
> + * Protects the global state, hold both for modification, hold either fo=
r
> + * stability.
> + *
> + * XXX we modify RMID with only cache_mutex held, racy!
> + */
> +static DEFINE_MUTEX(cache_mutex);
> +static DEFINE_RAW_SPINLOCK(cache_lock);
> +
> +static unsigned long *cache_rmid_bitmap;
> +
> +/*
> + * All events
> + */
> +static LIST_HEAD(cache_events);
> +
> +/*
> + * Groups of events that have the same target(s), one RMID per group.
> + */
> +static LIST_HEAD(cache_groups);
> +
> +/*
> + * The new RMID we must not use until cache_pmu_stable().
> + * See cache_pmu_rotate().
> + */
> +static unsigned long *cache_limbo_bitmap;
> +
> +/*
> + * The spare RMID that make rotation possible; keep out of the
> + * cache_rmid_bitmap to avoid it getting used for new events.
> + */
> +static int cache_rotation_rmid;
> +
> +/*
> + * The freed RMIDs, see cache_pmu_rotate().
> + */
> +static int cache_freed_nr;
> +static int *cache_freed_rmid;
> +
> +/*
> + * One online cpu per package, for cache_pmu_stable().
> + */
> +static cpumask_t cache_cpus;
> +
> +/*
> + * Returns < 0 on fail.
> + */
> +static int __get_rmid(void)
> +{
> +	return bitmap_find_free_region(cache_rmid_bitmap, max_rmid, 0);
> +}
> +
> +static void __put_rmid(int rmid)
> +{
> +	bitmap_release_region(cache_rmid_bitmap, rmid, 0);
> +}
> +
> +/*
> + * Needs a quesent state before __put, see cache_pmu_stabilize().
> + */
> +static void __free_rmid(int rmid)
> +{
> +	cache_freed_rmid[cache_freed_nr++] =3D rmid;
> +}
> +
> +#define RMID_VAL_ERROR		(1ULL << 63)
> +#define RMID_VAL_UNAVAIL	(1ULL << 62)
> +
> +static u64 __rmid_read(unsigned long rmid)
> +{
> +	u64 val;
> +
> +	/*
> +	 * Ignore the SDM, this thing is _NOTHING_ like a regular perfcnt,
> +	 * it just says that to increase confusion.
> +	 */
> +	wrmsr(MSR_IA32_QM_EVTSEL, 1 | (rmid << 32));
> +	rdmsr(MSR_IA32_QM_CTR, val);
> +
> +	/*
> +	 * Aside from the ERROR and UNAVAIL bits, assume this thing returns
> +	 * the number of cachelines tagged with @rmid.
> +	 */
> +	return val;
> +}
> +
> +static void smp_test_stable(void *info)
> +{
> +	bool *used =3D info;
> +	int i;
> +
> +	for (i =3D 0; i < cache_freed_nr; i++) {
> +		if (__rmid_read(cache_freed_rmid[i]))
> +			*used =3D false;
> +	}
> +}
> +
> +/*
> + * Test if the rotation_rmid is unused; see the comment near
> + * cache_pmu_rotate().
> + */
> +static bool cache_pmu_is_stable(void)
> +{
> +	bool used =3D true;
> +
> +	smp_call_function_many(&cache_cpus, smp_test_stable, &used, true);
> +
> +	return used;
> +}
> +
> +/*
> + * Quescent state; wait for all the 'freed' RMIDs to become unused.  Aft=
er this
> + * we can can reuse them and know that the current set of active RMIDs i=
s
> + * stable.
> + */
> +static void cache_pmu_stabilize(void)
> +{
> +	int i =3D 0;
> +
> +	if (!cache_freed_nr)
> +		return;
> +
> +	/*
> +	 * Now wait until the old RMID drops back to 0 again, this means all
> +	 * cachelines have acquired a new tag and the new RMID is now stable.
> +	 */
> +	while (!cache_pmu_is_stable()) {
> +		/*
> +		 * XXX adaptive timeout? Ideally the hardware would get us an
> +		 * interrupt :/
> +		 */
> +		schedule_timeout_uninterruptible(1);
> +	}
> +
> +	bitmap_clear(cache_limbo_bitmap, 0, max_rmid);
> +
> +	if (cache_rotation_rmid <=3D 0) {
> +		cache_rotation_rmid =3D cache_freed_rmid[0];
> +		i++;
> +	}
> +
> +	for (; i < cache_freed_nr; i++)
> +		__put_rmid(cache_freed_rmid[i]);
> +
> +	cache_freed_nr =3D 0;
> +}
> +
> +/*
> + * Exchange the RMID of a group of events.
> + */
> +static unsigned long cache_group_xchg_rmid(struct perf_event *group, uns=
igned long rmid)
> +{
> +	struct perf_event *event;
> +	unsigned long old_rmid =3D group->hw.cache_rmid;
> +
> +	group->hw.cache_rmid =3D rmid;
> +	list_for_each_entry(event, &group->hw.cache_group_entry, hw.cache_group=
_entry)
> +		event->hw.cache_rmid =3D rmid;
> +
> +	return old_rmid;
> +}
> +
> +/*
> + * Determine if @a and @b measure the same set of tasks.
> + */
> +static bool __match_event(struct perf_event *a, struct perf_event *b)
> +{
> +	if ((a->attach_state & PERF_ATTACH_TASK) !=3D
> +	    (b->attach_state & PERF_ATTACH_TASK))
> +		return false;
> +
> +	if (a->attach_state & PERF_ATTACH_TASK) {
> +		if (a->hw.cache_target !=3D b->hw.cache_target)
> +			return false;
> +
> +		return true;
> +	}
> +
> +	/* not task */
> +
> +#ifdef CONFIG_CGROUP_PERF
> +	if ((a->cgrp =3D=3D b->cgrp) && a->cgrp)
> +		return true;
> +#endif
> +
> +	return true; /* if not task or cgroup, we're machine wide */
> +}
> +
> +static struct perf_cgroup *event_to_cgroup(struct perf_event *event)
> +{
> +	if (event->cgrp)
> +		return event->cgrp;
> +
> +	if (event->attach_state & PERF_ATTACH_TASK) /* XXX */
> +		return perf_cgroup_from_task(event->hw.cache_target);
> +
> +	return NULL;
> +}
> +
> +/*
> + * Determine if @na's tasks intersect with @b's tasks
> + */
> +static bool __conflict_event(struct perf_event *a, struct perf_event *b)
> +{
> +#ifdef CONFIG_CGROUP_PERF
> +	struct perf_cb *ac, *bc;
> +
> +	ac =3D event_to_cgroup(a);
> +	bc =3D event_to_cgroup(b);
> +
> +	if (!ac || !bc) {
> +		/*
> +		 * If either is NULL, its a system wide event and that
> +		 * always conflicts with a cgroup one.
> +		 *
> +		 * If both are system wide, __match_event() should've
> +		 * been true and we'll never get here, if we did fail.
> +		 */
> +		return true;
> +	}
> +
> +	/*
> +	 * If one is a parent of the other, we've got an intersection.
> +	 */
> +	if (cgroup_is_descendant(ac->css.cgroup, bc->css.cgroup) ||
> +	    cgroup_is_descendant(bc->css.cgroup, ac->css.cgroup))
> +		return true;
> +#endif
> +
> +	/*
> +	 * If one of them is not a task, same story as above with cgroups.
> +	 */
> +	if (!(a->attach_state & PERF_ATTACH_TASK) ||
> +	    !(b->attach_state & PERF_ATTACH_TASK))
> +		return true;
> +
> +	/*
> +	 * Again, if they're the same __match_event() should've caught us, if n=
ot fail.
> +	 */
> +	if (a->hw.cache_target =3D=3D b->hw.cache_target)
> +		return true;
> +
> +	/*
> +	 * Must be non-overlapping.
> +	 */
> +	return false;
> +}
> +
> +/*
> + * Attempt to rotate the groups and assign new RMIDs, ought to run from =
an
> + * delayed work or somesuch.
> + *
> + * Rotating RMIDs is complicated; firstly because the hardware doesn't g=
ive us
> + * any clues; secondly because of cgroups.
> + *
> + * There's problems with the hardware interface; when you change the tas=
k:RMID
> + * map cachelines retain their 'old' tags, giving a skewed picture. In o=
rder to
> + * work around this, we must always keep one free RMID.
> + *
> + * Rotation works by taking away an RMID from a group (the old RMID), an=
d
> + * assigning the free RMID to another group (the new RMID). We must then=
 wait
> + * for the old RMID to not be used (no cachelines tagged). This ensure t=
hat all
> + * cachelines are tagged with 'active' RMIDs. At this point we can start
> + * reading values for the new RMID and treat the old RMID as the free RM=
ID for
> + * the next rotation.
> + *
> + * Secondly, since cgroups can nest, we must make sure to not program
> + * conflicting cgroups at the same time. A conflicting cgroup is one tha=
t has a
> + * parent<->child relation. After all, a task of the child cgroup will a=
lso be
> + * covered by the parent cgroup.
> + *
> + * Therefore, when selecting a new group, we must invalidate all conflic=
ting
> + * groups. Rotations allows us to measure all (conflicting) groups
> + * sequentially.
> + *
> + * XXX there's a further problem in that because we do our own rotation =
and
> + * cheat with schedulability the event {enabled,running} times are incor=
rect.
> + */
> +static bool cache_pmu_rotate(void)
> +{
> +	struct perf_event *rotor;
> +	int rmid;
> +
> +	mutex_lock(&cache_mutex);
> +
> +	if (list_empty(&cache_groups))
> +		goto unlock_mutex;
> +
> +	rotor =3D list_first_entry(&cache_groups, struct perf_event, hw.cache_g=
roups_entry);
> +
> +	raw_spin_lock_irq(&cache_lock);
> +	list_del(&rotor->hw.cache_groups_entry);
> +	rmid =3D cache_group_xchg_rmid(rotor, -1);
> +	WARN_ON_ONCE(rmid <=3D 0); /* first entry must always have an RMID */
> +	__free_rmid(rmid);
> +	raw_spin_unlock_irq(&cache_loc);
> +
> +	/*
> +	 * XXX O(n^2) schedulability
> +	 */
> +
> +	list_for_each_entry(group, &cache_groups, hw.cache_groups_entry) {
> +		bool conflicts =3D false;
> +		struct perf_event *iter;
> +
> +		list_for_each_entry(iter, &cache_groups, hw.cache_groups_entry) {
> +			if (iter =3D=3D group)
> +				break;
> +			if (__conflict_event(group, iter)) {
> +				conflicts =3D true;
> +				break;
> +			}
> +		}
> +
> +		if (conflicts && group->hw.cache_rmid > 0) {
> +			rmid =3D cache_group_xchg_rmid(group, -1);
> +			WARN_ON_ONCE(rmid <=3D 0);
> +			__free_rmid(rmid);
> +			continue;
> +		}
> +
> +		if (!conflicts && group->hw.cache_rmid <=3D 0) {
> +			rmid =3D __get_rmid();
> +			if (rmid <=3D 0) {
> +				rmid =3D cache_rotation_rmid;
> +				cache_rotation_rmid =3D -1;
> +			}
> +			set_bit(rmid, cache_limbo_rmid);
> +			if (rmid <=3D 0)
> +				break; /* we're out of RMIDs, more next time */
> +
> +			rmid =3D cache_group_xchg_rmid(group, rmid);
> +			WARM_ON_ONCE(rmid > 0);
> +			continue;
> +		}
> +
> +		/*
> +		 * either we conflict and do not have an RMID -> good,
> +		 * or we do not conflict and have an RMID -> also good.
> +		 */
> +	}
> +
> +	raw_spin_lock_irq(&cache_lock);
> +	list_add_tail(&rotor->hw.cache_groups_entry, &cache_groups);
> +	raw_spin_unlock_irq(&cache_lock);
> +
> +	/*
> +	 * XXX force a PMU reprogram here such that the new RMIDs are in
> +	 * effect.
> +	 */
> +
> +	cache_pmu_stabilize();
> +
> +unlock_mutex:
> +	mutex_unlock(&cache_mutex);
> +
> +	/*
> +	 * XXX reschedule work.
> +	 */
> +}
> +
> +/*
> + * Find a group and setup RMID
> + */
> +static struct perf_event *cache_pmu_setup_event(struct perf_event *event=
)
> +{
> +	struct perf_event *iter;
> +	int rmid =3D 0; /* unset */
> +
> +	list_for_each_entry(iter, &cache_groups, hw.cache_groups_entry) {
> +		if (__match_event(iter, event)) {
> +			event->hw.cache_rmid =3D iter->hw.cache_rmid;
> +			return iter;
> +		}
> +		if (__conflict_event(iter, event))
> +			rmid =3D -1; /* conflicting rmid */
> +	}
> +
> +	if (!rmid) {
> +		/* XXX lacks stabilization */
> +		event->hw.cache_rmid =3D __get_rmid();
> +	}
> +
> +	return NULL;
> +}
> +
> +static void cache_pmu_event_read(struct perf_event *event)
> +{
> +	unsigned long rmid =3D event->hw.cache_rmid;
> +	u64 val =3D RMID_VAL_UNAVAIL;
> +
> +	if (!test_bit(rmid, cache_limbo_bitmap))
> +		val =3D __rmid_read(rmid);
> +
> +	/*
> +	 * Ignore this reading on error states and do not update the value.
> +	 */
> +	if (val & (RMID_VAL_ERROR | RMID_VAL_UNAVAIL))
> +		return;
> +
> +	val *=3D l3_scale; /* cachelines -> bytes */
> +
> +	local64_set(&event->count, val);
> +}
> +
> +static void cache_pmu_event_start(struct perf_event *event, int mode)
> +{
> +	struct cache_pmu_state *state =3D &__get_cpu_var(&state);
> +	unsigned long flags;
> +
> +	if (!(event->hw.cache_state & PERF_HES_STOPPED))
> +		return;
> +
> +	event->hw.cache_state &=3D ~PERF_HES_STOPPED;
> +
> +	raw_spin_lock_irqsave(&state->lock, flags);
> +	if (state->cnt++)
> +		WARN_ON_ONCE(state->rmid !=3D rmid);
> +	else
> +		WARN_ON_ONCE(state->rmid);
> +	state->rmid =3D rmid;
> +	wrmsr(MSR_IA32_PQR_ASSOC, state->rmid);
> +	raw_spin_unlock_irqrestore(&state->lock, flags);
> +}
> +
> +static void cache_pmu_event_stop(struct perf_event *event, int mode)
> +{
> +	struct cache_pmu_state *state =3D &__get_cpu_var(&state);
> +	unsigned long flags;
> +
> +	if (event->hw.cache_state & PERF_HES_STOPPED)
> +		return;
> +
> +	event->hw.cache_state |=3D PERF_HES_STOPPED;
> +
> +	raw_spin_lock_irqsave(&state->lock, flags);
> +	cache_pmu_event_read(event);
> +	if (!--state->cnt) {
> +		state->rmid =3D 0;
> +		wrmsr(MSR_IA32_PQR_ASSOC, 0);
> +	} else {
> +		WARN_ON_ONCE(!state->rmid);
> +	raw_spin_unlock_irqrestore(&state->lock, flags);
> +}
> +
> +static int cache_pmu_event_add(struct perf_event *event, int mode)
> +{
> +	struct cache_pmu_state *state =3D &__get_cpu_var(&state);
> +	unsigned long flags;
> +	int rmid;
> +
> +	raw_spin_lock_irqsave(&cache_lock, flags);
> +
> +	event->hw.cache_state =3D PERF_HES_STOPPED;
> +	rmid =3D event->hw.cache_rmid;
> +	if (rmid <=3D 0)
> +		goto unlock;
> +
> +	if (mode & PERF_EF_START)
> +		cache_pmu_event_start(event, mode);
> +
> +unlock:
> +	raw_spin_unlock_irqrestore(&cache_lock, flags);
> +
> +	return 0;
> +}
> +
> +static void cache_pmu_event_del(struct perf_event *event, int mode)
> +{
> +	struct cache_pmu_state *state =3D &__get_cpu_var(&state);
> +	unsigned long flags;
> +
> +	raw_spin_lock_irqsave(&cache_lock, flags);
> +	cache_pmu_event_stop(event, mode);
> +	raw_spin_unlock_irqrestore(&cache_lock, flags);
> +
> +	return 0;
> +}
> +
> +static void cache_pmu_event_destroy(struct perf_event *event)
> +{
> +	struct perf_event *group_other =3D NULL;
> +
> +	mutex_lock(&cache_mutex);
> +	raw_spin_lock_irq(&cache_lock);
> +
> +	list_del(&event->hw.cache_events_entry);
> +
> +	/*
> +	 * If there's another event in this group...
> +	 */
> +	if (!list_empty(&event->hw.cache_group_entry)) {
> +		group_other =3D list_first_entry(&event->hw.cache_group_entry,
> +					       struct perf_event,
> +					       hw.cache_group_entry);
> +		list_del(&event->hw.cache_group_entry);
> +	}
> +	/*
> +	 * And we're the group leader..
> +	 */
> +	if (!list_empty(&event->hw.cache_groups_entry)) {
> +		/*
> +		 * If there was a group_other, make that leader, otherwise
> +		 * destroy the group and return the RMID.
> +		 */
> +		if (group_other) {
> +			list_replace(&event->hw.cache_groups_entry,
> +				     &group_other->hw.cache_groups_entry);
> +		} else {
> +			int rmid =3D event->hw.cache_rmid;
> +			if (rmid > 0)
> +				__put_rmid(rmid);
> +			list_del(&event->hw.cache_groups_entry);
> +		}
> +	}
> +
> +	raw_spin_unlock_irq(&cache_lock);
> +	mutex_unlock(&cache_mutex);
> +}
> +
> +static struct pmu cache_pmu;
> +
> +/*
> + * Takes non-sampling task,cgroup or machine wide events.
> + *
> + * XXX there's a bit of a problem in that we cannot simply do the one ev=
ent per
> + * node as one would want, since that one event would one get scheduled =
on the
> + * one cpu. But we want to 'schedule' the RMID on all CPUs.
> + *
> + * This means we want events for each CPU, however, that generates a lot=
 of
> + * duplicate values out to userspace -- this is not to be helped unless =
we want
> + * to change the core code in some way.
> + */
> +static int cache_pmu_event_init(struct perf_event *event)
> +{
> +	struct perf_event *group;
> +
> +	if (event->attr.type !=3D cache_pmu.type)
> +		return -ENOENT;
> +
> +	if (event->attr.config !=3D 0)
> +		return -EINVAL;
> +
> +	if (event->cpu =3D=3D -1) /* must have per-cpu events; see above */
> +		return -EINVAL;
> +
> +	/* unsupported modes and filters */
> +	if (event->attr.exclude_user   ||
> +	    event->attr.exclude_kernel ||
> +	    event->attr.exclude_hv     ||
> +	    event->attr.exclude_idle   ||
> +	    event->attr.exclude_host   ||
> +	    event->attr.exclude_guest  ||
> +	    event->attr.sample_period) /* no sampling */
> +		return -EINVAL;
> +
> +	event->destroy =3D cache_pmu_event_destroy;
> +
> +	mutex_lock(&cache_mutex);
> +
> +	group =3D cache_pmu_setup_event(event); /* will also set rmid */
> +
> +	raw_spin_lock_irq(&cache_lock);
> +	if (group) {
> +		event->hw.cache_rmid =3D group->hw.cache_rmid;
> +		list_add_tail(&event->hw.cache_group_entry,
> +			      &group->hw.cache_group_entry);
> +	} else {
> +		list_add_tail(&event->hw.cache_groups_entry,
> +			      &cache_groups);
> +	}
> +
> +	list_add_tail(&event->hw.cache_events_entry, &cache_events);
> +	raw_spin_unlock_irq(&cache_lock);
> +
> +	mutex_unlock(&cache_mutex);
> +
> +	return 0;
> +}
> +
> +static struct pmu cache_pmu =3D {
> +	.task_ctx_nr	=3D perf_sw_context, /* we cheat: our add will never fail =
*/
> +	.event_init	=3D cache_pmu_event_init,
> +	.add		=3D cache_pmu_event_add,
> +	.del		=3D cache_pmu_event_del,
> +	.start		=3D cache_pmu_event_start,
> +	.stop		=3D cache_pmu_event_stop,
> +	.read		=3D cache_pmu_event_read,
> +};
> +
> +static int __init cache_pmu_init(void)
> +{
> +	unsigned int eax, ebx, ecd, edx;
> +	int i;
> +
> +	if (boot_cpu_data.x86_vendor !=3D X86_VENDOR_INTEL)
> +		return 0;
> +
> +	if (boot_cpu_data.x86 !=3D 6)
> +		return 0;
> +
> +	cpuid_count(0x07, 0, &eax, &ebx, &ecx, &edx);
> +
> +	/* CPUID.(EAX=3D07H, ECX=3D0).EBX.QOS[bit12] */
> +	if (!(ebx & (1 << 12)))
> +		return 0;
> +
> +	cpuid_count(0x0f, 0, &eax, &ebx, &ecx, &edx);
> +
> +	max_rmid =3D ebx;
> +
> +	/*
> +	 * We should iterate bits in CPUID(EAX=3D0FH, ECX=3D0).EDX
> +	 * For now, only support L3 (bit 1).
> +	 */
> +	if (!(edx & (1 << 1)))
> +		return 0;
> +
> +	cpuid_count(0x0f, 1, &eax, &ebx, &ecx, &edx);
> +
> +	l3_scale =3D ebx;
> +	l3_max_rmid =3D ecx;
> +
> +	if (l3_max_rmid !=3D max_rmid)
> +		return 0;
> +
> +	cache_rmid_bitmap =3D kmalloc(sizeof(long) * BITS_TO_LONGS(max_rmid), G=
FP_KERNEL);
> +	if (!cache_rmid_bitmap)
> +		return -ENOMEM;
> +
> +	cache_limbo_bitmap =3D kmalloc(sizeof(long) * BITS_TO_LONGS(max_rmid), =
GFP_KERNEL);
> +	if (!cache_limbo_bitmap)
> +		return -ENOMEM; /* XXX frees */
> +
> +	cache_freed_rmid =3D kmalloc(sizeof(int) * max_rmid, GFP_KERNEL);
> +	if (!cache_freed_rmid)
> +		return -ENOMEM; /* XXX free bitmaps */
> +
> +	bitmap_zero(cache_rmid_bitmap, max_rmid);
> +	bitmap_set(cache_rmid_bitmap, 0, 1); /* RMID 0 is special */
> +	cache_rotation_rmid =3D __get_rmid(); /* keep one free RMID for rotatio=
n */
> +	if (WARN_ON_ONCE(cache_rotation_rmid < 0))
> +		return cache_rotation_rmid;
> +
> +	/*
> +	 * XXX hotplug notifiers!
> +	 */
> +	for_each_possible_cpu(i) {
> +		struct cache_pmu_state *state =3D &per_cpu(state, cpu);
> +
> +		raw_spin_lock_init(&state->lock);
> +		state->rmid =3D 0;
> +	}
> +
> +	ret =3D perf_pmu_register(&cache_pmu, "cache_qos", -1);
> +	if (WARN_ON(ret)) {
> +		pr_info("Cache QoS detected, registration failed (%d), disabled\n", re=
t);
> +		return -1;
> +	}
> +
> +	return 0;
> +}
> +device_initcall(cache_pmu_init);

--=20
PJ Waskiewicz				Open Source Technology Center
peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org		Intel Corp.

--=-Y6Hnq9jaSTxGHYRJvlaz
Content-Type: application/x-pkcs7-signature; name="smime.p7s"
Content-Disposition: attachment; filename="smime.p7s"
Content-Transfer-Encoding: base64

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
jgvUt1CKjAP30MBN66Optp0GgWSrDwS6pW0Nld3iMX+/IdoG23bUW9BWXMtYXkr6oN7zB+ekvUjg
vwIDAQABo4IC9jCCAvIwCwYDVR0PBAQDAgeAMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIbD
jHWEmeVRg/2BKIWOn1OCkcAJZ4HevTmV8EMCAWQCAQgwHQYDVR0OBBYEFEawoXzp+DrBd+34bKsE
yj4wjKHXMB8GA1UdIwQYMBaAFB5pKrTcKP5HGE4hCz+8rBEv8Jj1MIHJBgNVHR8EgcEwgb4wgbug
gbiggbWGVGh0dHA6Ly93d3cuaW50ZWwuY29tL3JlcG9zaXRvcnkvQ1JML0ludGVsJTIwRXh0ZXJu
YWwlMjBCYXNpYyUyMElzc3VpbmclMjBDQSUyMDRBLmNybIZdaHR0cDovL2NlcnRpZmljYXRlcy5p
bnRlbC5jb20vcmVwb3NpdG9yeS9DUkwvSW50ZWwlMjBFeHRlcm5hbCUyMEJhc2ljJTIwSXNzdWlu
ZyUyMENBJTIwNEEuY3JsMIHvBggrBgEFBQcBAQSB4jCB3zBpBggrBgEFBQcwAoZdaHR0cDovL3d3
dy5pbnRlbC5jb20vcmVwb3NpdG9yeS9jZXJ0aWZpY2F0ZXMvSW50ZWwlMjBFeHRlcm5hbCUyMEJh
c2ljJTIwSXNzdWluZyUyMENBJTIwNEEuY3J0MHIGCCsGAQUFBzAChmZodHRwOi8vY2VydGlmaWNh
dGVzLmludGVsLmNvbS9yZXBvc2l0b3J5L2NlcnRpZmljYXRlcy9JbnRlbCUyMEV4dGVybmFsJTIw
QmFzaWMlMjBJc3N1aW5nJTIwQ0ElMjA0QS5jcnQwHwYDVR0lBBgwFgYIKwYBBQUHAwQGCisGAQQB
gjcKAwwwKQYJKwYBBAGCNxUKBBwwGjAKBggrBgEFBQcDBDAMBgorBgEEAYI3CgMMMFsGA1UdEQRU
MFKgLwYKKwYBBAGCNxQCA6AhDB9wZXRlci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tgR9wZXRl
ci5wLndhc2tpZXdpY3ouanJAaW50ZWwuY29tMA0GCSqGSIb3DQEBBQUAA4IBAQDP4L0gv03sv1PN
XSIPEHQCFZIKC/1T5wPd1EUaFejmnduTD7WcCO61zsMsOPvYTjyrU5f1DYCiV5CUoN0kNdsrOy++
hWplJlk4TOjQFwzgkuouexNWINAICF7WlH3eMMbM+Fo9GC4K+O4w+KRpSVzR815N8B+YBv4SByIY
N+Pnkwnxiq5KaD20gJ6EPsgGCos4Ccu4yWVgXrl6jpcjS8ViOU1jPF0PguQ8BftdfUUrprELUiVo
4RC8q1B/7Yp17tYjIeO7Tb2abzTKp98dXU6agYSK/JNUq2iBhKb5aE+LrlGRTcqC+ioRe1N1D/wX
1Z2L0MEmNIg/Xf5DVdTUCOzBMYICDjCCAgoCAQEwgYcweTELMAkGA1UEBhMCVVMxCzAJBgNVBAgT
AkNBMRQwEgYDVQQHEwtTYW50YSBDbGFyYTEaMBgGA1UEChMRSW50ZWwgQ29ycG9yYXRpb24xKzAp
BgNVBAMTIkludGVsIEV4dGVybmFsIEJhc2ljIElzc3VpbmcgQ0EgNEECCnfQGsYAAAAARQwwCQYF
Kw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE0MDIx
ODE3MjkyN1owIwYJKoZIhvcNAQkEMRYEFJGnuAciXFpkjFwA3i0jfZUidniPMA0GCSqGSIb3DQEB
AQUABIIBAHwtrMNCM7A1LD9cKyASMAUdNbv0y4JLDmjxEF9OR45q0JC0fSCcdALsECqU/+BrKtPJ
dgBcTVwNoLGaHmFsnLXbs5xwStVY4jHqzU3fE/Z5BpgdQJSVHCnMVyRwNrgpuMQ186cY5oPx//sP
sbfil7lNdIabABTdS+ua1+Vymhhti4did2BdVpKxCRlxR4TmJrLCFJr6SMha4Azs5QscmYhTwqVQ
cJtr+R1iHAu4M9QZJFLBEuw3Fvt5LwrTL75H3RWd/6K+WY0tTmrZre0GOGrIu8Axg7BiJL2nrUQA
PvUMdph/Qb20ZxTOoPbWQQcJiFWhNTt7EBLKD0cPZVR1to4AAAAAAAA=


--=-Y6Hnq9jaSTxGHYRJvlaz--

--===============4613417894915767777==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============4613417894915767777==--
