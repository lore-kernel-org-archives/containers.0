From: Mike Chan <mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] scheduler: Extract cgroups_cpuaccount code from sched.c
	into own file
Date: Wed, 19 May 2010 12:06:09 -0700
Message-ID: <AANLkTilRwxE2feVWKUGALnTR0BFRIec0j0r3hKwywAYF__19368.2442456067$1274296047$gmane$org@mail.gmail.com>
References: <1274232620-23003-1-git-send-email-mike@android.com>
	<1274232620-23003-4-git-send-email-mike@android.com>
	<201005191130.42851.trenn@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <201005191130.42851.trenn-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
Cc: khilman-1D3HCaltpLuhEniVeURVKkEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cpufreq-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

2010/5/19 Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>:
> Hi,
>
> thread topic was:
> Re: [PATCH 3/4] scheduler: cpuacct: Enable platform callbacks for cpuacct=
 power tracking
>
> I mingled this patch together with a minor comment for Mike's patch.
> Like this interested people in CC are kept.
>
> Peter/Ingo: Can you pick up this cleanup if appropriate, please.
> Shall I resend separately or could you cut out comments below?
>
> On Wednesday 19 May 2010 03:30:19 Mike Chan wrote:
>> Platform must register cpu power function that return power in
>> milliWatt seconds.
>>
>> Signed-off-by: Mike Chan <mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>
>> ---
>> =A0Documentation/cgroups/cpuacct.txt | =A0 =A03 +++
>> =A0include/linux/cpuacct.h =A0 =A0 =A0 =A0 =A0 | =A0 =A04 +++-
>> =A0kernel/sched.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 24 ++++++=
++++++++++++++++--
>> =A03 files changed, 28 insertions(+), 3 deletions(-)
> ...
>> diff --git a/include/linux/cpuacct.h b/include/linux/cpuacct.h
>> index 9ff479e..effe842 100644
>> --- a/include/linux/cpuacct.h
>> +++ b/include/linux/cpuacct.h
>> @@ -31,7 +31,9 @@ struct cpuacct_cpufreq_calls {
> This is a general cpuacct_charge interface, not cpufreq specific?
> I'd call it "struct cpuacct_charge_calls".
> Platforms can account C-states, frequency, power, whatever they like?
> The latter two are implemented with your patches.

I'm ok with the name change if that's what people prefer.

>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 void (*init) (void **cpuacct_data);
>> =A0 =A0 =A0 void (*charge) (void *cpuacct_data, =A0u64 cputime, unsigned=
 int cpu);
>> - =A0 =A0 void (*show) (void *cpuacct_data, struct cgroup_map_cb *cb);
>> + =A0 =A0 void (*cpufreq_show) (void *cpuacct_data, struct cgroup_map_cb=
 *cb);
>> + =A0 =A0 /* Returns power consumed in milliWatt seconds */
>> + =A0 =A0 u64 (*power_usage) (void *cpuacct_data);
>> =A0};
>> =A0int cpuacct_register_cpufreq(struct cpuacct_cpufreq_calls *fn);
> Same here, why not name it cpuacct_register_charge?
> Eventually at other places.
>
>> diff --git a/kernel/sched.c b/kernel/sched.c
>> index 6b6c45a..d55d8af 100644
>> --- a/kernel/sched.c
>> +++ b/kernel/sched.c
> Nothing to do with this patch, but I wonder why this is all in kernel/sch=
ed.c.
> Try a quick cleanup... works.
> Whatabout below cleanup?
> Not sure through which tree this should go in, but if below is accepted,
> would you mind rebasing your things against it.
> Then it would already show up in cgroup_cpuaccount.c git history.

Sounds reasonable

-- Mike

>
> =A0 =A0 =A0 Thomas
>
> This is a cleanup against current linux-2.6 Linus tree.
>
> Having CONFIG_CGROUP_CPUACCT code in kernel/sched.c looks wrong.
> Move this out to kernel/cgroup_cpuaccount.c
>
> Test compiled with and without CONFIG_CGROUP_CPUACCT set on x86_64.
>
> Signed-off-by: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
> CC: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org
> CC: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
> CC: lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
> CC: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> CC: mingo-X9Un+BFzKDI@public.gmane.org
> CC: peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
>
> ---
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 8f78073..6e2c88a 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -609,6 +609,24 @@ bool css_is_ancestor(struct cgroup_subsys_state *cg,
> =A0unsigned short css_id(struct cgroup_subsys_state *css);
> =A0unsigned short css_depth(struct cgroup_subsys_state *css);
>
> +/* Time spent by the tasks of the cpu accounting group executing in ... =
*/
> +enum cpuacct_stat_index {
> + =A0 =A0 =A0 CPUACCT_STAT_USER, =A0 =A0 =A0/* ... user mode */
> + =A0 =A0 =A0 CPUACCT_STAT_SYSTEM, =A0 =A0/* ... kernel mode */
> +
> + =A0 =A0 =A0 CPUACCT_STAT_NSTATS,
> +};
> +
> +#ifdef CONFIG_CGROUP_CPUACCT
> +void cpuacct_charge(struct task_struct *tsk, u64 cputime);
> +void cpuacct_update_stats(struct task_struct *tsk,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum cpuacct_stat_index idx, cputime_t val);
> +#else
> +static inline void cpuacct_charge(struct task_struct *tsk, u64 cputime) =
{}
> +static inline void cpuacct_update_stats(struct task_struct *tsk,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum cpuacct_stat_index idx=
, cputime_t val) {}
> +#endif
> +
> =A0#else /* !CONFIG_CGROUPS */
>
> =A0static inline int cgroup_init_early(void) { return 0; }
> diff --git a/kernel/Makefile b/kernel/Makefile
> index 149e18e..1df6e53 100644
> --- a/kernel/Makefile
> +++ b/kernel/Makefile
> @@ -60,6 +60,7 @@ obj-$(CONFIG_KEXEC) +=3D kexec.o
> =A0obj-$(CONFIG_BACKTRACE_SELF_TEST) +=3D backtracetest.o
> =A0obj-$(CONFIG_COMPAT) +=3D compat.o
> =A0obj-$(CONFIG_CGROUPS) +=3D cgroup.o
> +obj-$(CONFIG_CGROUP_CPUACCT) +=3D cgroup_cpuaccount.o
> =A0obj-$(CONFIG_CGROUP_FREEZER) +=3D cgroup_freezer.o
> =A0obj-$(CONFIG_CPUSETS) +=3D cpuset.o
> =A0obj-$(CONFIG_CGROUP_NS) +=3D ns_cgroup.o
> diff --git a/kernel/cgroup_cpuaccount.c b/kernel/cgroup_cpuaccount.c
> new file mode 100644
> index 0000000..d32b927
> --- /dev/null
> +++ b/kernel/cgroup_cpuaccount.c
> @@ -0,0 +1,284 @@
> +#include <linux/kernel.h>
> +#include <linux/percpu.h>
> +#include <linux/spinlock.h>
> +#include <linux/sched.h>
> +#include <linux/cgroup.h>
> +#include <linux/srcu.h>
> +#include <linux/slab.h>
> +#include <linux/seq_file.h>
> +
> +#include <asm/cputime.h>
> +
> +/*
> + * CPU accounting code for task groups.
> + *
> + * Based on the work by Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org) and Balbir Singh
> + * (balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org).
> + */
> +
> +/* track cpu usage of a group of tasks and its child groups */
> +struct cpuacct {
> + =A0 =A0 =A0 struct cgroup_subsys_state css;
> + =A0 =A0 =A0 /* cpuusage holds pointer to a u64-type object on every cpu=
 */
> + =A0 =A0 =A0 u64 __percpu *cpuusage;
> + =A0 =A0 =A0 struct percpu_counter cpustat[CPUACCT_STAT_NSTATS];
> + =A0 =A0 =A0 struct cpuacct *parent;
> +};
> +
> +struct cgroup_subsys cpuacct_subsys;
> +
> +/* return cpu accounting group corresponding to this container */
> +static inline struct cpuacct *cgroup_ca(struct cgroup *cgrp)
> +{
> + =A0 =A0 =A0 return container_of(cgroup_subsys_state(cgrp, cpuacct_subsy=
s_id),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cpuacct, css=
);
> +}
> +
> +/* return cpu accounting group to which this task belongs */
> +static inline struct cpuacct *task_ca(struct task_struct *tsk)
> +{
> + =A0 =A0 =A0 return container_of(task_subsys_state(tsk, cpuacct_subsys_i=
d),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cpuacct, css=
);
> +}
> +
> +/* create a new cpu accounting group */
> +static struct cgroup_subsys_state *cpuacct_create(
> + =A0 =A0 =A0 struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> + =A0 =A0 =A0 struct cpuacct *ca =3D kzalloc(sizeof(*ca), GFP_KERNEL);
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 if (!ca)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 ca->cpuusage =3D alloc_percpu(u64);
> + =A0 =A0 =A0 if (!ca->cpuusage)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_ca;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < CPUACCT_STAT_NSTATS; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (percpu_counter_init(&ca->cpustat[i], 0))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_counters;
> +
> + =A0 =A0 =A0 if (cgrp->parent)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ca->parent =3D cgroup_ca(cgrp->parent);
> +
> + =A0 =A0 =A0 return &ca->css;
> +
> +out_free_counters:
> + =A0 =A0 =A0 while (--i >=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 percpu_counter_destroy(&ca->cpustat[i]);
> + =A0 =A0 =A0 free_percpu(ca->cpuusage);
> +out_free_ca:
> + =A0 =A0 =A0 kfree(ca);
> +out:
> + =A0 =A0 =A0 return ERR_PTR(-ENOMEM);
> +}
> +
> +/* destroy an existing cpu accounting group */
> +static void
> +cpuacct_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> + =A0 =A0 =A0 struct cpuacct *ca =3D cgroup_ca(cgrp);
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < CPUACCT_STAT_NSTATS; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 percpu_counter_destroy(&ca->cpustat[i]);
> + =A0 =A0 =A0 free_percpu(ca->cpuusage);
> + =A0 =A0 =A0 kfree(ca);
> +}
> +
> +static u64 cpuacct_cpuusage_read(struct cpuacct *ca, int cpu)
> +{
> + =A0 =A0 =A0 u64 *cpuusage =3D per_cpu_ptr(ca->cpuusage, cpu);
> + =A0 =A0 =A0 u64 data;
> +
> +#ifndef CONFIG_64BIT
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Take rq->lock to make 64-bit read safe on 32-bit platf=
orms.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 raw_spin_lock_irq(&cpu_rq(cpu)->lock);
> + =A0 =A0 =A0 data =3D *cpuusage;
> + =A0 =A0 =A0 raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
> +#else
> + =A0 =A0 =A0 data =3D *cpuusage;
> +#endif
> +
> + =A0 =A0 =A0 return data;
> +}
> +
> +static void cpuacct_cpuusage_write(struct cpuacct *ca, int cpu, u64 val)
> +{
> + =A0 =A0 =A0 u64 *cpuusage =3D per_cpu_ptr(ca->cpuusage, cpu);
> +
> +#ifndef CONFIG_64BIT
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Take rq->lock to make 64-bit write safe on 32-bit plat=
forms.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 raw_spin_lock_irq(&cpu_rq(cpu)->lock);
> + =A0 =A0 =A0 *cpuusage =3D val;
> + =A0 =A0 =A0 raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
> +#else
> + =A0 =A0 =A0 *cpuusage =3D val;
> +#endif
> +}
> +
> +/* return total cpu usage (in nanoseconds) of a group */
> +static u64 cpuusage_read(struct cgroup *cgrp, struct cftype *cft)
> +{
> + =A0 =A0 =A0 struct cpuacct *ca =3D cgroup_ca(cgrp);
> + =A0 =A0 =A0 u64 totalcpuusage =3D 0;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for_each_present_cpu(i)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 totalcpuusage +=3D cpuacct_cpuusage_read(ca=
, i);
> +
> + =A0 =A0 =A0 return totalcpuusage;
> +}
> +
> +static int cpuusage_write(struct cgroup *cgrp, struct cftype *cftype,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 reset)
> +{
> + =A0 =A0 =A0 struct cpuacct *ca =3D cgroup_ca(cgrp);
> + =A0 =A0 =A0 int err =3D 0;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 if (reset) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 for_each_present_cpu(i)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpuacct_cpuusage_write(ca, i, 0);
> +
> +out:
> + =A0 =A0 =A0 return err;
> +}
> +
> +static int cpuacct_percpu_seq_read(struct cgroup *cgroup, struct cftype =
*cft,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct seq_file *m)
> +{
> + =A0 =A0 =A0 struct cpuacct *ca =3D cgroup_ca(cgroup);
> + =A0 =A0 =A0 u64 percpu;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for_each_present_cpu(i) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 percpu =3D cpuacct_cpuusage_read(ca, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 seq_printf(m, "%llu ", (unsigned long long)=
 percpu);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 seq_printf(m, "\n");
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static const char *cpuacct_stat_desc[] =3D {
> + =A0 =A0 =A0 [CPUACCT_STAT_USER] =3D "user",
> + =A0 =A0 =A0 [CPUACCT_STAT_SYSTEM] =3D "system",
> +};
> +
> +static int cpuacct_stats_show(struct cgroup *cgrp, struct cftype *cft,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_map_cb *cb)
> +{
> + =A0 =A0 =A0 struct cpuacct *ca =3D cgroup_ca(cgrp);
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < CPUACCT_STAT_NSTATS; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s64 val =3D percpu_counter_read(&ca->cpusta=
t[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 val =3D cputime64_to_clock_t(val);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cb->fill(cb, cpuacct_stat_desc[i], val);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static struct cftype files[] =3D {
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "usage",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D cpuusage_read,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_u64 =3D cpuusage_write,
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "usage_percpu",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_seq_string =3D cpuacct_percpu_seq_rea=
d,
> + =A0 =A0 =A0 },
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "stat",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_map =3D cpuacct_stats_show,
> + =A0 =A0 =A0 },
> +};
> +
> +static int cpuacct_populate(struct cgroup_subsys *ss, struct cgroup *cgr=
p)
> +{
> + =A0 =A0 =A0 return cgroup_add_files(cgrp, ss, files, ARRAY_SIZE(files));
> +}
> +
> +/*
> + * charge this task's execution time to its accounting group.
> + *
> + * called with rq->lock held.
> + */
> +void cpuacct_charge(struct task_struct *tsk, u64 cputime)
> +{
> + =A0 =A0 =A0 struct cpuacct *ca;
> + =A0 =A0 =A0 int cpu;
> +
> + =A0 =A0 =A0 if (unlikely(!cpuacct_subsys.active))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 cpu =3D task_cpu(tsk);
> +
> + =A0 =A0 =A0 rcu_read_lock();
> +
> + =A0 =A0 =A0 ca =3D task_ca(tsk);
> +
> + =A0 =A0 =A0 for (; ca; ca =3D ca->parent) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 *cpuusage =3D per_cpu_ptr(ca->cpuusage,=
 cpu);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 *cpuusage +=3D cputime;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 rcu_read_unlock();
> +}
> +
> +/*
> + * When CONFIG_VIRT_CPU_ACCOUNTING is enabled one jiffy can be very large
> + * in cputime_t units. As a result, cpuacct_update_stats calls
> + * percpu_counter_add with values large enough to always overflow the
> + * per cpu batch limit causing bad SMP scalability.
> + *
> + * To fix this we scale percpu_counter_batch by cputime_one_jiffy so we
> + * batch the same amount of time with CONFIG_VIRT_CPU_ACCOUNTING disabled
> + * and enabled. We cap it at INT_MAX which is the largest allowed batch =
value.
> + */
> +#ifdef CONFIG_SMP
> +#define CPUACCT_BATCH =A0\
> + =A0 =A0 =A0 min_t(long, percpu_counter_batch * cputime_one_jiffy, INT_M=
AX)
> +#else
> +#define CPUACCT_BATCH =A00
> +#endif
> +
> +/*
> + * Charge the system/user time to the task's accounting group.
> + */
> +void cpuacct_update_stats(struct task_struct *tsk,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum cpuacct_stat_index=
 idx, cputime_t val)
> +{
> + =A0 =A0 =A0 struct cpuacct *ca;
> + =A0 =A0 =A0 int batch =3D CPUACCT_BATCH;
> +
> + =A0 =A0 =A0 if (unlikely(!cpuacct_subsys.active))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 ca =3D task_ca(tsk);
> +
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __percpu_counter_add(&ca->cpustat[idx], val=
, batch);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ca =3D ca->parent;
> + =A0 =A0 =A0 } while (ca);
> + =A0 =A0 =A0 rcu_read_unlock();
> +}
> +
> +struct cgroup_subsys cpuacct_subsys =3D {
> + =A0 =A0 =A0 .name =3D "cpuacct",
> + =A0 =A0 =A0 .create =3D cpuacct_create,
> + =A0 =A0 =A0 .destroy =3D cpuacct_destroy,
> + =A0 =A0 =A0 .populate =3D cpuacct_populate,
> + =A0 =A0 =A0 .subsys_id =3D cpuacct_subsys_id,
> +};
> diff --git a/kernel/sched.c b/kernel/sched.c
> index 1d93cd0..45d60dd 100644
> --- a/kernel/sched.c
> +++ b/kernel/sched.c
> @@ -1394,24 +1394,6 @@ static const u32 prio_to_wmult[40] =3D {
> =A0/* =A015 */ 119304647, 148102320, 186737708, 238609294, 286331153,
> =A0};
>
> -/* Time spent by the tasks of the cpu accounting group executing in ... =
*/
> -enum cpuacct_stat_index {
> - =A0 =A0 =A0 CPUACCT_STAT_USER, =A0 =A0 =A0/* ... user mode */
> - =A0 =A0 =A0 CPUACCT_STAT_SYSTEM, =A0 =A0/* ... kernel mode */
> -
> - =A0 =A0 =A0 CPUACCT_STAT_NSTATS,
> -};
> -
> -#ifdef CONFIG_CGROUP_CPUACCT
> -static void cpuacct_charge(struct task_struct *tsk, u64 cputime);
> -static void cpuacct_update_stats(struct task_struct *tsk,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum cpuacct_stat_index idx, cputime_t val);
> -#else
> -static inline void cpuacct_charge(struct task_struct *tsk, u64 cputime) =
{}
> -static inline void cpuacct_update_stats(struct task_struct *tsk,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum cpuacct_stat_index idx, cputime_t val)=
 {}
> -#endif
> -
> =A0static inline void inc_cpu_load(struct rq *rq, unsigned long load)
> =A0{
> =A0 =A0 =A0 =A0update_load_add(&rq->load, load);
> @@ -8617,283 +8599,6 @@ struct cgroup_subsys cpu_cgroup_subsys =3D {
>
> =A0#endif /* CONFIG_CGROUP_SCHED */
>
> -#ifdef CONFIG_CGROUP_CPUACCT
> -
> -/*
> - * CPU accounting code for task groups.
> - *
> - * Based on the work by Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org) and Balbir Singh
> - * (balbir-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org).
> - */
> -
> -/* track cpu usage of a group of tasks and its child groups */
> -struct cpuacct {
> - =A0 =A0 =A0 struct cgroup_subsys_state css;
> - =A0 =A0 =A0 /* cpuusage holds pointer to a u64-type object on every cpu=
 */
> - =A0 =A0 =A0 u64 __percpu *cpuusage;
> - =A0 =A0 =A0 struct percpu_counter cpustat[CPUACCT_STAT_NSTATS];
> - =A0 =A0 =A0 struct cpuacct *parent;
> -};
> -
> -struct cgroup_subsys cpuacct_subsys;
> -
> -/* return cpu accounting group corresponding to this container */
> -static inline struct cpuacct *cgroup_ca(struct cgroup *cgrp)
> -{
> - =A0 =A0 =A0 return container_of(cgroup_subsys_state(cgrp, cpuacct_subsy=
s_id),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cpuacct, css=
);
> -}
> -
> -/* return cpu accounting group to which this task belongs */
> -static inline struct cpuacct *task_ca(struct task_struct *tsk)
> -{
> - =A0 =A0 =A0 return container_of(task_subsys_state(tsk, cpuacct_subsys_i=
d),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cpuacct, css=
);
> -}
> -
> -/* create a new cpu accounting group */
> -static struct cgroup_subsys_state *cpuacct_create(
> - =A0 =A0 =A0 struct cgroup_subsys *ss, struct cgroup *cgrp)
> -{
> - =A0 =A0 =A0 struct cpuacct *ca =3D kzalloc(sizeof(*ca), GFP_KERNEL);
> - =A0 =A0 =A0 int i;
> -
> - =A0 =A0 =A0 if (!ca)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> -
> - =A0 =A0 =A0 ca->cpuusage =3D alloc_percpu(u64);
> - =A0 =A0 =A0 if (!ca->cpuusage)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_ca;
> -
> - =A0 =A0 =A0 for (i =3D 0; i < CPUACCT_STAT_NSTATS; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (percpu_counter_init(&ca->cpustat[i], 0))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_counters;
> -
> - =A0 =A0 =A0 if (cgrp->parent)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ca->parent =3D cgroup_ca(cgrp->parent);
> -
> - =A0 =A0 =A0 return &ca->css;
> -
> -out_free_counters:
> - =A0 =A0 =A0 while (--i >=3D 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 percpu_counter_destroy(&ca->cpustat[i]);
> - =A0 =A0 =A0 free_percpu(ca->cpuusage);
> -out_free_ca:
> - =A0 =A0 =A0 kfree(ca);
> -out:
> - =A0 =A0 =A0 return ERR_PTR(-ENOMEM);
> -}
> -
> -/* destroy an existing cpu accounting group */
> -static void
> -cpuacct_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
> -{
> - =A0 =A0 =A0 struct cpuacct *ca =3D cgroup_ca(cgrp);
> - =A0 =A0 =A0 int i;
> -
> - =A0 =A0 =A0 for (i =3D 0; i < CPUACCT_STAT_NSTATS; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 percpu_counter_destroy(&ca->cpustat[i]);
> - =A0 =A0 =A0 free_percpu(ca->cpuusage);
> - =A0 =A0 =A0 kfree(ca);
> -}
> -
> -static u64 cpuacct_cpuusage_read(struct cpuacct *ca, int cpu)
> -{
> - =A0 =A0 =A0 u64 *cpuusage =3D per_cpu_ptr(ca->cpuusage, cpu);
> - =A0 =A0 =A0 u64 data;
> -
> -#ifndef CONFIG_64BIT
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Take rq->lock to make 64-bit read safe on 32-bit platf=
orms.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 raw_spin_lock_irq(&cpu_rq(cpu)->lock);
> - =A0 =A0 =A0 data =3D *cpuusage;
> - =A0 =A0 =A0 raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
> -#else
> - =A0 =A0 =A0 data =3D *cpuusage;
> -#endif
> -
> - =A0 =A0 =A0 return data;
> -}
> -
> -static void cpuacct_cpuusage_write(struct cpuacct *ca, int cpu, u64 val)
> -{
> - =A0 =A0 =A0 u64 *cpuusage =3D per_cpu_ptr(ca->cpuusage, cpu);
> -
> -#ifndef CONFIG_64BIT
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Take rq->lock to make 64-bit write safe on 32-bit plat=
forms.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 raw_spin_lock_irq(&cpu_rq(cpu)->lock);
> - =A0 =A0 =A0 *cpuusage =3D val;
> - =A0 =A0 =A0 raw_spin_unlock_irq(&cpu_rq(cpu)->lock);
> -#else
> - =A0 =A0 =A0 *cpuusage =3D val;
> -#endif
> -}
> -
> -/* return total cpu usage (in nanoseconds) of a group */
> -static u64 cpuusage_read(struct cgroup *cgrp, struct cftype *cft)
> -{
> - =A0 =A0 =A0 struct cpuacct *ca =3D cgroup_ca(cgrp);
> - =A0 =A0 =A0 u64 totalcpuusage =3D 0;
> - =A0 =A0 =A0 int i;
> -
> - =A0 =A0 =A0 for_each_present_cpu(i)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 totalcpuusage +=3D cpuacct_cpuusage_read(ca=
, i);
> -
> - =A0 =A0 =A0 return totalcpuusage;
> -}
> -
> -static int cpuusage_write(struct cgroup *cgrp, struct cftype *cftype,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 reset)
> -{
> - =A0 =A0 =A0 struct cpuacct *ca =3D cgroup_ca(cgrp);
> - =A0 =A0 =A0 int err =3D 0;
> - =A0 =A0 =A0 int i;
> -
> - =A0 =A0 =A0 if (reset) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -EINVAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 for_each_present_cpu(i)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpuacct_cpuusage_write(ca, i, 0);
> -
> -out:
> - =A0 =A0 =A0 return err;
> -}
> -
> -static int cpuacct_percpu_seq_read(struct cgroup *cgroup, struct cftype =
*cft,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct seq_file *m)
> -{
> - =A0 =A0 =A0 struct cpuacct *ca =3D cgroup_ca(cgroup);
> - =A0 =A0 =A0 u64 percpu;
> - =A0 =A0 =A0 int i;
> -
> - =A0 =A0 =A0 for_each_present_cpu(i) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 percpu =3D cpuacct_cpuusage_read(ca, i);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 seq_printf(m, "%llu ", (unsigned long long)=
 percpu);
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 seq_printf(m, "\n");
> - =A0 =A0 =A0 return 0;
> -}
> -
> -static const char *cpuacct_stat_desc[] =3D {
> - =A0 =A0 =A0 [CPUACCT_STAT_USER] =3D "user",
> - =A0 =A0 =A0 [CPUACCT_STAT_SYSTEM] =3D "system",
> -};
> -
> -static int cpuacct_stats_show(struct cgroup *cgrp, struct cftype *cft,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_map_cb *cb)
> -{
> - =A0 =A0 =A0 struct cpuacct *ca =3D cgroup_ca(cgrp);
> - =A0 =A0 =A0 int i;
> -
> - =A0 =A0 =A0 for (i =3D 0; i < CPUACCT_STAT_NSTATS; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 s64 val =3D percpu_counter_read(&ca->cpusta=
t[i]);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 val =3D cputime64_to_clock_t(val);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cb->fill(cb, cpuacct_stat_desc[i], val);
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 return 0;
> -}
> -
> -static struct cftype files[] =3D {
> - =A0 =A0 =A0 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "usage",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D cpuusage_read,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_u64 =3D cpuusage_write,
> - =A0 =A0 =A0 },
> - =A0 =A0 =A0 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "usage_percpu",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_seq_string =3D cpuacct_percpu_seq_rea=
d,
> - =A0 =A0 =A0 },
> - =A0 =A0 =A0 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D "stat",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_map =3D cpuacct_stats_show,
> - =A0 =A0 =A0 },
> -};
> -
> -static int cpuacct_populate(struct cgroup_subsys *ss, struct cgroup *cgr=
p)
> -{
> - =A0 =A0 =A0 return cgroup_add_files(cgrp, ss, files, ARRAY_SIZE(files));
> -}
> -
> -/*
> - * charge this task's execution time to its accounting group.
> - *
> - * called with rq->lock held.
> - */
> -static void cpuacct_charge(struct task_struct *tsk, u64 cputime)
> -{
> - =A0 =A0 =A0 struct cpuacct *ca;
> - =A0 =A0 =A0 int cpu;
> -
> - =A0 =A0 =A0 if (unlikely(!cpuacct_subsys.active))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> -
> - =A0 =A0 =A0 cpu =3D task_cpu(tsk);
> -
> - =A0 =A0 =A0 rcu_read_lock();
> -
> - =A0 =A0 =A0 ca =3D task_ca(tsk);
> -
> - =A0 =A0 =A0 for (; ca; ca =3D ca->parent) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 *cpuusage =3D per_cpu_ptr(ca->cpuusage,=
 cpu);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 *cpuusage +=3D cputime;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 rcu_read_unlock();
> -}
> -
> -/*
> - * When CONFIG_VIRT_CPU_ACCOUNTING is enabled one jiffy can be very large
> - * in cputime_t units. As a result, cpuacct_update_stats calls
> - * percpu_counter_add with values large enough to always overflow the
> - * per cpu batch limit causing bad SMP scalability.
> - *
> - * To fix this we scale percpu_counter_batch by cputime_one_jiffy so we
> - * batch the same amount of time with CONFIG_VIRT_CPU_ACCOUNTING disabled
> - * and enabled. We cap it at INT_MAX which is the largest allowed batch =
value.
> - */
> -#ifdef CONFIG_SMP
> -#define CPUACCT_BATCH =A0\
> - =A0 =A0 =A0 min_t(long, percpu_counter_batch * cputime_one_jiffy, INT_M=
AX)
> -#else
> -#define CPUACCT_BATCH =A00
> -#endif
> -
> -/*
> - * Charge the system/user time to the task's accounting group.
> - */
> -static void cpuacct_update_stats(struct task_struct *tsk,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum cpuacct_stat_index idx, cputime_t val)
> -{
> - =A0 =A0 =A0 struct cpuacct *ca;
> - =A0 =A0 =A0 int batch =3D CPUACCT_BATCH;
> -
> - =A0 =A0 =A0 if (unlikely(!cpuacct_subsys.active))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> -
> - =A0 =A0 =A0 rcu_read_lock();
> - =A0 =A0 =A0 ca =3D task_ca(tsk);
> -
> - =A0 =A0 =A0 do {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __percpu_counter_add(&ca->cpustat[idx], val=
, batch);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ca =3D ca->parent;
> - =A0 =A0 =A0 } while (ca);
> - =A0 =A0 =A0 rcu_read_unlock();
> -}
> -
> -struct cgroup_subsys cpuacct_subsys =3D {
> - =A0 =A0 =A0 .name =3D "cpuacct",
> - =A0 =A0 =A0 .create =3D cpuacct_create,
> - =A0 =A0 =A0 .destroy =3D cpuacct_destroy,
> - =A0 =A0 =A0 .populate =3D cpuacct_populate,
> - =A0 =A0 =A0 .subsys_id =3D cpuacct_subsys_id,
> -};
> -#endif /* CONFIG_CGROUP_CPUACCT */
> -
> =A0#ifndef CONFIG_SMP
>
> =A0void synchronize_sched_expedited(void)
>
