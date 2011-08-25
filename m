From: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Subject: Re: [PATCH 5/6] cgroup, cpuset: don't use ss->pre_attach()
Date: Thu, 25 Aug 2011 01:53:57 -0700
Message-ID: <CALdu-PD5EbFJBRHf-iehPwb6vyJTYUTWZniihARFDZ7xRZ8_nQ__1435.97184583104$1314262495$gmane$org@mail.gmail.com>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
	<1314138000-2049-6-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1314138000-2049-6-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: rjw-KKrjLPT3xs0@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Aug 23, 2011 at 3:19 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> ->pre_attach() is supposed to be called before migration, which is
> observed during process migration but task migration does it the other
> way around. =A0The only ->pre_attach() user is cpuset which can do the
> same operaitons in ->can_attach(). =A0Collapse cpuset_pre_attach() into
> cpuset_can_attach().
>
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Acked-by: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>

Code looks good, but I think that the some of the Documentation
changes slipped in here by mistake.

Paul

> Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
> =A0Documentation/cgroups/cgroups.txt | =A0 20 --------------------
> =A0kernel/cpuset.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 29 +++++++++=
+++-----------------
> =A02 files changed, 12 insertions(+), 37 deletions(-)
>
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cg=
roups.txt
> index 2eee7cf..afb7cde 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -610,13 +610,6 @@ called on a fork. If this method returns 0 (success)=
 then this should
> =A0remain valid while the caller holds cgroup_mutex and it is ensured
> =A0that either attach() or cancel_attach() will be called in future.
>
> -int can_attach_task(struct cgroup *cgrp, struct task_struct *tsk);
> -(cgroup_mutex held by caller)
> -
> -As can_attach, but for operations that must be run once per task to be
> -attached (possibly many when using cgroup_attach_proc). Called after
> -can_attach.
> -
> =A0void cancel_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_taskset *tset)
> =A0(cgroup_mutex held by caller)
> @@ -627,12 +620,6 @@ function, so that the subsystem can implement a roll=
back. If not, not necessary.
> =A0This will be called only about subsystems whose can_attach() operation=
 have
> =A0succeeded. The parameters are identical to can_attach().
>
> -void pre_attach(struct cgroup *cgrp);
> -(cgroup_mutex held by caller)
> -
> -For any non-per-thread attachment work that needs to happen before
> -attach_task. Needed by cpuset.
> -
> =A0void attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
> =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_taskset *tset)
> =A0(cgroup_mutex held by caller)
> @@ -641,13 +628,6 @@ Called after the task has been attached to the cgrou=
p, to allow any
> =A0post-attachment activity that requires memory allocations or blocking.
> =A0The parameters are identical to can_attach().
>
> -void attach_task(struct cgroup *cgrp, struct task_struct *tsk);
> -(cgroup_mutex held by caller)
> -
> -As attach, but for operations that must be run once per task to be attac=
hed,
> -like can_attach_task. Called before attach. Currently does not support a=
ny
> -subsystem that might need the old_cgrp for every thread in the group.
> -
> =A0void fork(struct cgroup_subsy *ss, struct task_struct *task)
>
> =A0Called when a task is forked into a cgroup.
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 472ddd6..f0b8df3 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1367,6 +1367,15 @@ static int fmeter_getrate(struct fmeter *fmp)
> =A0 =A0 =A0 =A0return val;
> =A0}
>
> +/*
> + * Protected by cgroup_lock. The nodemasks must be stored globally becau=
se
> + * dynamically allocating them is not allowed in can_attach, and they mu=
st
> + * persist until attach.
> + */
> +static cpumask_var_t cpus_attach;
> +static nodemask_t cpuset_attach_nodemask_from;
> +static nodemask_t cpuset_attach_nodemask_to;
> +
> =A0/* Called by cgroups to determine if a cpuset is usable; cgroup_mutex =
held */
> =A0static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *=
cgrp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_tas=
kset *tset)
> @@ -1393,29 +1402,16 @@ static int cpuset_can_attach(struct cgroup_subsys=
 *ss, struct cgroup *cgrp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((ret =3D security_task_setscheduler(ta=
sk)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 return 0;
> -}
> -
> -/*
> - * Protected by cgroup_lock. The nodemasks must be stored globally becau=
se
> - * dynamically allocating them is not allowed in pre_attach, and they mu=
st
> - * persist among pre_attach, and attach.
> - */
> -static cpumask_var_t cpus_attach;
> -static nodemask_t cpuset_attach_nodemask_from;
> -static nodemask_t cpuset_attach_nodemask_to;
> -
> -/* Set-up work for before attaching each task. */
> -static void cpuset_pre_attach(struct cgroup *cont)
> -{
> - =A0 =A0 =A0 struct cpuset *cs =3D cgroup_cs(cont);
>
> + =A0 =A0 =A0 /* prepare for attach */
> =A0 =A0 =A0 =A0if (cs =3D=3D &top_cpuset)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cpumask_copy(cpus_attach, cpu_possible_mas=
k);
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0guarantee_online_cpus(cs, cpus_attach);
>
> =A0 =A0 =A0 =A0guarantee_online_mems(cs, &cpuset_attach_nodemask_to);
> +
> + =A0 =A0 =A0 return 0;
> =A0}
>
> =A0static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cgr=
p,
> @@ -1901,7 +1897,6 @@ struct cgroup_subsys cpuset_subsys =3D {
> =A0 =A0 =A0 =A0.create =3D cpuset_create,
> =A0 =A0 =A0 =A0.destroy =3D cpuset_destroy,
> =A0 =A0 =A0 =A0.can_attach =3D cpuset_can_attach,
> - =A0 =A0 =A0 .pre_attach =3D cpuset_pre_attach,
> =A0 =A0 =A0 =A0.attach =3D cpuset_attach,
> =A0 =A0 =A0 =A0.populate =3D cpuset_populate,
> =A0 =A0 =A0 =A0.post_clone =3D cpuset_post_clone,
> --
> 1.7.6
>
>
