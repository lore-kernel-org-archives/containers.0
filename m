From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH 1/2] cgroup: add per cgroup timer_slack_ns
Date: Wed, 1 Dec 2010 12:17:20 -0800
Message-ID: <AANLkTi=1uv-+Y5t85tyHKk91nJyAKNg5V4Fk2HTJ+ASS__44999.2997259416$1291234781$gmane$org@mail.gmail.com>
References: <1291230012-9536-1-git-send-email-jacob.jun.pan@linux.intel.com>
	<1291230012-9536-2-git-send-email-jacob.jun.pan@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1291230012-9536-2-git-send-email-jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
Cc: Arjan van de Ven <arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, container cgroup <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

When multiple hierarchies are mounted a task will be in one cgroup on
each hierarchy - which cgroup's timer_slack_ns value should be used
for it?

This doesn't belong in the generic cgroups framework. It sounds like
it's something that should be its own subsystem, or else part of
something like the cpu subsystem.

Paul

On Wed, Dec 1, 2010 at 11:00 AM,  <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
> From: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
>
> Per task timer_slack_ns was introduced a while ago to allow tuning
> timer rounding behavior such that tasks can be made mode power friendly.
> This patch introduces per cgroup timer slack value which will override
> the default timer slack value once a task is attached to a cgroup. By
> default, the root cgroup timer slack value is set to the same 50us as
> in all the tasks.
> At runtime, user can choose to change cgroup timer slack value by
> echo xxx > cgroup.timer_slack_ns
>
> The usage of such feature can be found in mobile devices where certain
> background apps are attached to a cgroup and minimum wakeups are desired.
>
> Signed-off-by: Jacob Pan <jacob.jun.pan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
> ---
> =A0include/linux/cgroup.h =A0 =A0| =A0 =A01 +
> =A0include/linux/init_task.h | =A0 =A03 ++-
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0 =A0 | =A0 43 +++++++++++++++++++++++++=
++++++++++++++++++
> =A03 files changed, 46 insertions(+), 1 deletions(-)
>
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index ed4ba11..afac9bb 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -194,6 +194,7 @@ struct cgroup_pidlist {
>
> =A0struct cgroup {
> =A0 =A0 =A0 =A0unsigned long flags; =A0 =A0 =A0 =A0 =A0 =A0/* "unsigned l=
ong" so bitops work */
> + =A0 =A0 =A0 unsigned long timer_slack_ns;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * count users of this cgroup. >0 means busy, but doesn't
> diff --git a/include/linux/init_task.h b/include/linux/init_task.h
> index 1f8c06c..5860af6 100644
> --- a/include/linux/init_task.h
> +++ b/include/linux/init_task.h
> @@ -110,6 +110,7 @@ extern struct cred init_cred;
> =A0# define INIT_PERF_EVENTS(tsk)
> =A0#endif
>
> +#define TIMER_SLACK_NS_DEFAULT (50000) /* 50 usec default slack */
> =A0/*
> =A0* =A0INIT_TASK is used to set up the first task table, touch at
> =A0* your own risk!. Base=3D0, limit=3D0x1fffff (=3D2MB)
> @@ -163,7 +164,7 @@ extern struct cred init_cred;
> =A0 =A0 =A0 =A0.cpu_timers =A0 =A0 =3D INIT_CPU_TIMERS(tsk.cpu_timers), =
=A0 =A0 =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0.fs_excl =A0 =A0 =A0 =A0=3D ATOMIC_INIT(0), =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0.pi_lock =A0 =A0 =A0 =A0=3D __RAW_SPIN_LOCK_UNLOCKED(tsk.p=
i_lock), =A0 =A0 =A0 =A0\
> - =A0 =A0 =A0 .timer_slack_ns =3D 50000, /* 50 usec default slack */ =A0 =
=A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 .timer_slack_ns =3D TIMER_SLACK_NS_DEFAULT, =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0.pids =3D { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0[PIDTYPE_PID] =A0=3D INIT_PID_LINK(PIDTYPE=
_PID), =A0 =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0[PIDTYPE_PGID] =3D INIT_PID_LINK(PIDTYPE_P=
GID), =A0 =A0 =A0 =A0 =A0 \
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 66a416b..0e0a254 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -57,6 +57,7 @@
> =A0#include <linux/vmalloc.h> /* TODO: replace with more sophisticated ar=
ray */
> =A0#include <linux/eventfd.h>
> =A0#include <linux/poll.h>
> +#include <linux/init_task.h>
>
> =A0#include <asm/atomic.h>
>
> @@ -1324,6 +1325,7 @@ static void init_cgroup_root(struct cgroupfs_root *=
root)
> =A0 =A0 =A0 =A0root->number_of_cgroups =3D 1;
> =A0 =A0 =A0 =A0cgrp->root =3D root;
> =A0 =A0 =A0 =A0cgrp->top_cgroup =3D cgrp;
> + =A0 =A0 =A0 cgrp->timer_slack_ns =3D TIMER_SLACK_NS_DEFAULT;
> =A0 =A0 =A0 =A0init_cgroup_housekeeping(cgrp);
> =A0}
>
> @@ -1787,6 +1789,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct =
task_struct *tsk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0rcu_assign_pointer(tsk->cgroups, newcg);
> + =A0 =A0 =A0 tsk->timer_slack_ns =3D cgrp->timer_slack_ns;
> =A0 =A0 =A0 =A0task_unlock(tsk);
>
> =A0 =A0 =A0 =A0/* Update the css_set linked lists if we're using them */
> @@ -3049,6 +3052,38 @@ static int cgroup_write_notify_on_release(struct c=
group *cgrp,
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +static u64 cgroup_read_timer_slack_ns(struct cgroup *cgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cfty=
pe *cft)
> +{
> + =A0 =A0 =A0 return cgrp->timer_slack_ns;
> +}
> +
> +static int cgroup_write_timer_slack_ns(struct cgroup *cgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cfty=
pe *cft,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u64 val)
> +{
> + =A0 =A0 =A0 struct cgroup_iter it;
> + =A0 =A0 =A0 struct task_struct *task;
> +
> + =A0 =A0 =A0 /* TODO: upper range checking for max slack */
> + =A0 =A0 =A0 if (val)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgrp->timer_slack_ns =3D val;
> + =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "cgroup %s: invalid timer s=
lack value %llu\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgrp->dentry->d_name.name, =
val);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* change timer slack value for all tasks in the cgroup */
> + =A0 =A0 =A0 cgroup_iter_start(cgrp, &it);
> + =A0 =A0 =A0 while ((task =3D cgroup_iter_next(cgrp, &it)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task->timer_slack_ns =3D val;
> +
> + =A0 =A0 =A0 cgroup_iter_end(cgrp, &it);
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0/*
> =A0* Unregister event and free resources.
> =A0*
> @@ -3268,6 +3303,13 @@ static struct cftype files[] =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.read_u64 =3D cgroup_clone_children_read,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.write_u64 =3D cgroup_clone_children_write,
> =A0 =A0 =A0 =A0},
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .name =3D CGROUP_FILE_GENERIC_PREFIX "timer=
_slack_ns",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .read_u64 =3D cgroup_read_timer_slack_ns,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_u64 =3D cgroup_write_timer_slack_ns,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =3D S_IRUGO | S_IWUSR,
> + =A0 =A0 =A0 },
> +
> =A0};
>
> =A0static struct cftype cft_release_agent =3D {
> @@ -3393,6 +3435,7 @@ static long cgroup_create(struct cgroup *parent, st=
ruct dentry *dentry,
> =A0 =A0 =A0 =A0cgrp->parent =3D parent;
> =A0 =A0 =A0 =A0cgrp->root =3D parent->root;
> =A0 =A0 =A0 =A0cgrp->top_cgroup =3D parent->top_cgroup;
> + =A0 =A0 =A0 cgrp->timer_slack_ns =3D TIMER_SLACK_NS_DEFAULT;
>
> =A0 =A0 =A0 =A0if (notify_on_release(parent))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0set_bit(CGRP_NOTIFY_ON_RELEASE, &cgrp->fla=
gs);
> --
> 1.7.0.4
>
>
