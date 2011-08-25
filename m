From: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Subject: Re: [PATCH 4/6] cgroup: don't use subsys->can_attach_task() or
	->attach_task()
Date: Thu, 25 Aug 2011 02:07:35 -0700
Message-ID: <CALdu-PCc2RzedXubReF9huamL6W+5qGCfXNNvqS2yUk3QTHRng__6853.72654484144$1314263548$gmane$org@mail.gmail.com>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
	<1314138000-2049-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1314138000-2049-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 23, 2011 at 3:19 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> Now that subsys->can_attach() and attach() take @tset instead of
> @task, they can handle per-task operations. =A0Convert
> ->can_attach_task() and ->attach_task() users to use ->can_attach()
> and attach() instead. =A0Most converions are straight-forward.
> Noteworthy changes are,
>
> * In cgroup_freezer, remove unnecessary NULL assignments to unused
> =A0methods. =A0It's useless and very prone to get out of sync, which
> =A0already happened.
>
> * In cpuset, PF_THREAD_BOUND test is checked for each task. =A0This
> =A0doesn't make any practical difference but is conceptually cleaner.
>
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Cc: Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Cc: James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>
> Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
> Cc: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
> ---
> =A0block/blk-cgroup.c =A0 =A0 =A0| =A0 45 +++++++++++++++++++-----------
> =A0kernel/cgroup_freezer.c | =A0 14 +++-------
> =A0kernel/cpuset.c =A0 =A0 =A0 =A0 | =A0 70 +++++++++++++++++++++--------=
-----------------
> =A0kernel/events/core.c =A0 =A0| =A0 13 +++++---
> =A0kernel/sched.c =A0 =A0 =A0 =A0 =A0| =A0 31 +++++++++++++--------
> =A05 files changed, 91 insertions(+), 82 deletions(-)
>
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index bcaf16e..99e0bd4 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -30,8 +30,10 @@ EXPORT_SYMBOL_GPL(blkio_root_cgroup);
>
> =A0static struct cgroup_subsys_state *blkiocg_create(struct cgroup_subsys=
 *,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup *);
> -static int blkiocg_can_attach_task(struct cgroup *, struct task_struct *=
);
> -static void blkiocg_attach_task(struct cgroup *, struct task_struct *);
> +static int blkiocg_can_attach(struct cgroup_subsys *, struct cgroup *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_t=
askset *);
> +static void blkiocg_attach(struct cgroup_subsys *, struct cgroup *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_taskse=
t *);
> =A0static void blkiocg_destroy(struct cgroup_subsys *, struct cgroup *);
> =A0static int blkiocg_populate(struct cgroup_subsys *, struct cgroup *);
>
> @@ -44,8 +46,8 @@ static int blkiocg_populate(struct cgroup_subsys *, str=
uct cgroup *);
> =A0struct cgroup_subsys blkio_subsys =3D {
> =A0 =A0 =A0 =A0.name =3D "blkio",
> =A0 =A0 =A0 =A0.create =3D blkiocg_create,
> - =A0 =A0 =A0 .can_attach_task =3D blkiocg_can_attach_task,
> - =A0 =A0 =A0 .attach_task =3D blkiocg_attach_task,
> + =A0 =A0 =A0 .can_attach =3D blkiocg_can_attach,
> + =A0 =A0 =A0 .attach =3D blkiocg_attach,
> =A0 =A0 =A0 =A0.destroy =3D blkiocg_destroy,
> =A0 =A0 =A0 =A0.populate =3D blkiocg_populate,
> =A0#ifdef CONFIG_BLK_CGROUP
> @@ -1614,30 +1616,39 @@ done:
> =A0* of the main cic data structures. =A0For now we allow a task to change
> =A0* its cgroup only if it's the only owner of its ioc.
> =A0*/
> -static int blkiocg_can_attach_task(struct cgroup *cgrp, struct task_stru=
ct *tsk)
> +static int blkiocg_can_attach(struct cgroup_subsys *ss, struct cgroup *c=
grp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_t=
askset *tset)
> =A0{
> + =A0 =A0 =A0 struct task_struct *task;
> =A0 =A0 =A0 =A0struct io_context *ioc;
> =A0 =A0 =A0 =A0int ret =3D 0;
>
> =A0 =A0 =A0 =A0/* task_lock() is needed to avoid races with exit_io_conte=
xt() */
> - =A0 =A0 =A0 task_lock(tsk);
> - =A0 =A0 =A0 ioc =3D tsk->io_context;
> - =A0 =A0 =A0 if (ioc && atomic_read(&ioc->nr_tasks) > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EINVAL;
> - =A0 =A0 =A0 task_unlock(tsk);
> -
> + =A0 =A0 =A0 cgroup_taskset_for_each(task, cgrp, tset) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_lock(task);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioc =3D task->io_context;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioc && atomic_read(&ioc->nr_tasks) > 1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_unlock(task);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }

Doesn't the other part of this patch set, that avoids calling the
*attach() methods for tasks that aren't moving, eliminate the need for
the usage of skip_cgrp here (and elsewhere)? When do we actually need
to pass a non-NULL skip_cgrp to cgroup_taskset_for_each()?

Paul

> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -static void blkiocg_attach_task(struct cgroup *cgrp, struct task_struct =
*tsk)
> +static void blkiocg_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_taskse=
t *tset)
> =A0{
> + =A0 =A0 =A0 struct task_struct *task;
> =A0 =A0 =A0 =A0struct io_context *ioc;
>
> - =A0 =A0 =A0 task_lock(tsk);
> - =A0 =A0 =A0 ioc =3D tsk->io_context;
> - =A0 =A0 =A0 if (ioc)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioc->cgroup_changed =3D 1;
> - =A0 =A0 =A0 task_unlock(tsk);
> + =A0 =A0 =A0 cgroup_taskset_for_each(task, cgrp, tset) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_lock(task);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioc =3D task->io_context;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioc)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioc->cgroup_changed =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_unlock(task);
> + =A0 =A0 =A0 }
> =A0}
>
> =A0void blkio_policy_register(struct blkio_policy_type *blkiop)
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index a2b0082..2cb5e72 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -162,10 +162,14 @@ static int freezer_can_attach(struct cgroup_subsys =
*ss,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_=
taskset *tset)
> =A0{
> =A0 =A0 =A0 =A0struct freezer *freezer;
> + =A0 =A0 =A0 struct task_struct *task;
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Anything frozen can't move or be moved to/from.
> =A0 =A0 =A0 =A0 */
> + =A0 =A0 =A0 cgroup_taskset_for_each(task, new_cgroup, tset)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cgroup_freezing(task))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
>
> =A0 =A0 =A0 =A0freezer =3D cgroup_freezer(new_cgroup);
> =A0 =A0 =A0 =A0if (freezer->state !=3D CGROUP_THAWED)
> @@ -174,11 +178,6 @@ static int freezer_can_attach(struct cgroup_subsys *=
ss,
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static int freezer_can_attach_task(struct cgroup *cgrp, struct task_stru=
ct *tsk)
> -{
> - =A0 =A0 =A0 return cgroup_freezing(tsk) ? -EBUSY : 0;
> -}
> -
> =A0static void freezer_fork(struct cgroup_subsys *ss, struct task_struct =
*task)
> =A0{
> =A0 =A0 =A0 =A0struct freezer *freezer;
> @@ -374,10 +373,5 @@ struct cgroup_subsys freezer_subsys =3D {
> =A0 =A0 =A0 =A0.populate =A0 =A0 =A0 =3D freezer_populate,
> =A0 =A0 =A0 =A0.subsys_id =A0 =A0 =A0=3D freezer_subsys_id,
> =A0 =A0 =A0 =A0.can_attach =A0 =A0 =3D freezer_can_attach,
> - =A0 =A0 =A0 .can_attach_task =3D freezer_can_attach_task,
> - =A0 =A0 =A0 .pre_attach =A0 =A0 =3D NULL,
> - =A0 =A0 =A0 .attach_task =A0 =A0=3D NULL,
> - =A0 =A0 =A0 .attach =A0 =A0 =A0 =A0 =3D NULL,
> =A0 =A0 =A0 =A0.fork =A0 =A0 =A0 =A0 =A0 =3D freezer_fork,
> - =A0 =A0 =A0 .exit =A0 =A0 =A0 =A0 =A0 =3D NULL,
> =A0};
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 2e5825b..472ddd6 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1372,33 +1372,34 @@ static int cpuset_can_attach(struct cgroup_subsys=
 *ss, struct cgroup *cgrp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_tas=
kset *tset)
> =A0{
> =A0 =A0 =A0 =A0struct cpuset *cs =3D cgroup_cs(cgrp);
> + =A0 =A0 =A0 struct task_struct *task;
> + =A0 =A0 =A0 int ret;
>
> =A0 =A0 =A0 =A0if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mem=
s_allowed))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENOSPC;
>
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Kthreads bound to specific cpus cannot be moved to a n=
ew cpuset; we
> - =A0 =A0 =A0 =A0* cannot change their cpu affinity and isolating such th=
reads by their
> - =A0 =A0 =A0 =A0* set of allowed nodes is unnecessary. =A0Thus, cpusets =
are not
> - =A0 =A0 =A0 =A0* applicable for such threads. =A0This prevents checking=
 for success of
> - =A0 =A0 =A0 =A0* set_cpus_allowed_ptr() on all attached tasks before cp=
us_allowed may
> - =A0 =A0 =A0 =A0* be changed.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (cgroup_taskset_first(tset)->flags & PF_THREAD_BOUND)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> -
> + =A0 =A0 =A0 cgroup_taskset_for_each(task, cgrp, tset) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Kthreads bound to specific cpus cannot=
 be moved to a new
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* cpuset; we cannot change their cpu aff=
inity and
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* isolating such threads by their set of=
 allowed nodes is
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* unnecessary. =A0Thus, cpusets are not =
applicable for such
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* threads. =A0This prevents checking for=
 success of
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* set_cpus_allowed_ptr() on all attached=
 tasks before
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* cpus_allowed may be changed.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (task->flags & PF_THREAD_BOUND)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((ret =3D security_task_setscheduler(tas=
k)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static int cpuset_can_attach_task(struct cgroup *cgrp, struct task_struc=
t *task)
> -{
> - =A0 =A0 =A0 return security_task_setscheduler(task);
> -}
> -
> =A0/*
> =A0* Protected by cgroup_lock. The nodemasks must be stored globally beca=
use
> =A0* dynamically allocating them is not allowed in pre_attach, and they m=
ust
> - * persist among pre_attach, attach_task, and attach.
> + * persist among pre_attach, and attach.
> =A0*/
> =A0static cpumask_var_t cpus_attach;
> =A0static nodemask_t cpuset_attach_nodemask_from;
> @@ -1417,39 +1418,34 @@ static void cpuset_pre_attach(struct cgroup *cont)
> =A0 =A0 =A0 =A0guarantee_online_mems(cs, &cpuset_attach_nodemask_to);
> =A0}
>
> -/* Per-thread attachment work. */
> -static void cpuset_attach_task(struct cgroup *cont, struct task_struct *=
tsk)
> -{
> - =A0 =A0 =A0 int err;
> - =A0 =A0 =A0 struct cpuset *cs =3D cgroup_cs(cont);
> -
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* can_attach beforehand should guarantee that this doesn=
't fail.
> - =A0 =A0 =A0 =A0* TODO: have a better way to handle failure here
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 err =3D set_cpus_allowed_ptr(tsk, cpus_attach);
> - =A0 =A0 =A0 WARN_ON_ONCE(err);
> -
> - =A0 =A0 =A0 cpuset_change_task_nodemask(tsk, &cpuset_attach_nodemask_to=
);
> - =A0 =A0 =A0 cpuset_update_task_spread_flag(cs, tsk);
> -}
> -
> =A0static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cgr=
p,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_taskset =
*tset)
> =A0{
> =A0 =A0 =A0 =A0struct mm_struct *mm;
> - =A0 =A0 =A0 struct task_struct *tsk =3D cgroup_taskset_first(tset);
> + =A0 =A0 =A0 struct task_struct *task;
> + =A0 =A0 =A0 struct task_struct *leader =3D cgroup_taskset_first(tset);
> =A0 =A0 =A0 =A0struct cgroup *oldcgrp =3D cgroup_taskset_cur_cgroup(tset);
> =A0 =A0 =A0 =A0struct cpuset *cs =3D cgroup_cs(cgrp);
> =A0 =A0 =A0 =A0struct cpuset *oldcs =3D cgroup_cs(oldcgrp);
>
> + =A0 =A0 =A0 cgroup_taskset_for_each(task, cgrp, tset) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* can_attach beforehand should guarantee=
 that this doesn't
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* fail. =A0TODO: have a better way to ha=
ndle failure here
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ON_ONCE(set_cpus_allowed_ptr(task, cpu=
s_attach));
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpuset_change_task_nodemask(task, &cpuset_a=
ttach_nodemask_to);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpuset_update_task_spread_flag(cs, task);
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Change mm, possibly for multiple threads in a threadgro=
up. This is
> =A0 =A0 =A0 =A0 * expensive and may sleep.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0cpuset_attach_nodemask_from =3D oldcs->mems_allowed;
> =A0 =A0 =A0 =A0cpuset_attach_nodemask_to =3D cs->mems_allowed;
> - =A0 =A0 =A0 mm =3D get_task_mm(tsk);
> + =A0 =A0 =A0 mm =3D get_task_mm(leader);
> =A0 =A0 =A0 =A0if (mm) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mpol_rebind_mm(mm, &cpuset_attach_nodemask=
_to);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (is_memory_migrate(cs))
> @@ -1905,9 +1901,7 @@ struct cgroup_subsys cpuset_subsys =3D {
> =A0 =A0 =A0 =A0.create =3D cpuset_create,
> =A0 =A0 =A0 =A0.destroy =3D cpuset_destroy,
> =A0 =A0 =A0 =A0.can_attach =3D cpuset_can_attach,
> - =A0 =A0 =A0 .can_attach_task =3D cpuset_can_attach_task,
> =A0 =A0 =A0 =A0.pre_attach =3D cpuset_pre_attach,
> - =A0 =A0 =A0 .attach_task =3D cpuset_attach_task,
> =A0 =A0 =A0 =A0.attach =3D cpuset_attach,
> =A0 =A0 =A0 =A0.populate =3D cpuset_populate,
> =A0 =A0 =A0 =A0.post_clone =3D cpuset_post_clone,
> diff --git a/kernel/events/core.c b/kernel/events/core.c
> index b8785e2..95e189d 100644
> --- a/kernel/events/core.c
> +++ b/kernel/events/core.c
> @@ -7000,10 +7000,13 @@ static int __perf_cgroup_move(void *info)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static void
> -perf_cgroup_attach_task(struct cgroup *cgrp, struct task_struct *task)
> +static void perf_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *=
cgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgrou=
p_taskset *tset)
> =A0{
> - =A0 =A0 =A0 task_function_call(task, __perf_cgroup_move, task);
> + =A0 =A0 =A0 struct task_struct *task;
> +
> + =A0 =A0 =A0 cgroup_taskset_for_each(task, cgrp, tset)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_function_call(task, __perf_cgroup_move=
, task);
> =A0}
>
> =A0static void perf_cgroup_exit(struct cgroup_subsys *ss, struct cgroup *=
cgrp,
> @@ -7017,7 +7020,7 @@ static void perf_cgroup_exit(struct cgroup_subsys *=
ss, struct cgroup *cgrp,
> =A0 =A0 =A0 =A0if (!(task->flags & PF_EXITING))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> - =A0 =A0 =A0 perf_cgroup_attach_task(cgrp, task);
> + =A0 =A0 =A0 task_function_call(task, __perf_cgroup_move, task);
> =A0}
>
> =A0struct cgroup_subsys perf_subsys =3D {
> @@ -7026,6 +7029,6 @@ struct cgroup_subsys perf_subsys =3D {
> =A0 =A0 =A0 =A0.create =A0 =A0 =A0 =A0 =3D perf_cgroup_create,
> =A0 =A0 =A0 =A0.destroy =A0 =A0 =A0 =A0=3D perf_cgroup_destroy,
> =A0 =A0 =A0 =A0.exit =A0 =A0 =A0 =A0 =A0 =3D perf_cgroup_exit,
> - =A0 =A0 =A0 .attach_task =A0 =A0=3D perf_cgroup_attach_task,
> + =A0 =A0 =A0 .attach =A0 =A0 =A0 =A0 =3D perf_cgroup_attach,
> =A0};
> =A0#endif /* CONFIG_CGROUP_PERF */
> diff --git a/kernel/sched.c b/kernel/sched.c
> index ccacdbd..dd7e460 100644
> --- a/kernel/sched.c
> +++ b/kernel/sched.c
> @@ -8966,24 +8966,31 @@ cpu_cgroup_destroy(struct cgroup_subsys *ss, stru=
ct cgroup *cgrp)
> =A0 =A0 =A0 =A0sched_destroy_group(tg);
> =A0}
>
> -static int
> -cpu_cgroup_can_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
> +static int cpu_cgroup_can_attach(struct cgroup_subsys *ss, struct cgroup=
 *cgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct c=
group_taskset *tset)
> =A0{
> + =A0 =A0 =A0 struct task_struct *task;
> +
> + =A0 =A0 =A0 cgroup_taskset_for_each(task, cgrp, tset) {
> =A0#ifdef CONFIG_RT_GROUP_SCHED
> - =A0 =A0 =A0 if (!sched_rt_can_attach(cgroup_tg(cgrp), tsk))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sched_rt_can_attach(cgroup_tg(cgrp), t=
ask))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> =A0#else
> - =A0 =A0 =A0 /* We don't support RT-tasks being in separate groups */
> - =A0 =A0 =A0 if (tsk->sched_class !=3D &fair_sched_class)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We don't support RT-tasks being in separ=
ate groups */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (task->sched_class !=3D &fair_sched_clas=
s)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> =A0#endif
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static void
> -cpu_cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
> +static void cpu_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *c=
grp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_t=
askset *tset)
> =A0{
> - =A0 =A0 =A0 sched_move_task(tsk);
> + =A0 =A0 =A0 struct task_struct *task;
> +
> + =A0 =A0 =A0 cgroup_taskset_for_each(task, cgrp, tset)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sched_move_task(task);
> =A0}
>
> =A0static void
> @@ -9071,8 +9078,8 @@ struct cgroup_subsys cpu_cgroup_subsys =3D {
> =A0 =A0 =A0 =A0.name =A0 =A0 =A0 =A0 =A0 =3D "cpu",
> =A0 =A0 =A0 =A0.create =A0 =A0 =A0 =A0 =3D cpu_cgroup_create,
> =A0 =A0 =A0 =A0.destroy =A0 =A0 =A0 =A0=3D cpu_cgroup_destroy,
> - =A0 =A0 =A0 .can_attach_task =3D cpu_cgroup_can_attach_task,
> - =A0 =A0 =A0 .attach_task =A0 =A0=3D cpu_cgroup_attach_task,
> + =A0 =A0 =A0 .can_attach =A0 =A0 =3D cpu_cgroup_can_attach,
> + =A0 =A0 =A0 .attach =A0 =A0 =A0 =A0 =3D cpu_cgroup_attach,
> =A0 =A0 =A0 =A0.exit =A0 =A0 =A0 =A0 =A0 =3D cpu_cgroup_exit,
> =A0 =A0 =A0 =A0.populate =A0 =A0 =A0 =3D cpu_cgroup_populate,
> =A0 =A0 =A0 =A0.subsys_id =A0 =A0 =A0=3D cpu_cgroup_subsys_id,
> --
> 1.7.6
>
>
