From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v8 2/3] cgroups: add per-thread subsystem callbacks
Date: Thu, 3 Mar 2011 09:59:57 -0800
Message-ID: <AANLkTimbJO96wYYHMYUfrgh+F0Wc1pLs+HQ-JNDdLqJm__31577.0789552063$1299175351$gmane$org@mail.gmail.com>
References: <20110208013542.GC31569@ghc17.ghc.andrew.cmu.edu>
	<20110208013915.GE31569@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110208013915.GE31569-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Feb 7, 2011 at 5:39 PM, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> Add cgroup subsystem callbacks for per-thread attachment
>
> From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
>
> This patch adds can_attach_task, pre_attach, and attach_task as new callb=
acks
> for cgroups's subsystem interface. Unlike can_attach and attach, these ar=
e for
> per-thread operations, to be called potentially many times when attaching=
 an
> entire threadgroup.
>
> Also, the old "bool threadgroup" interface is removed, as replaced by thi=
s.
> All subsystems are modified for the new interface - of note is cpuset, wh=
ich
> requires from/to nodemasks for attach to be globally scoped (though per-c=
puset
> would work too) to persist from its pre_attach to attach_task and attach.
>
> This is a pre-patch for cgroup-procs-writable.patch.
>
> Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

Reviewed-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Paul

> ---
> =A0Documentation/cgroups/cgroups.txt | =A0 30 ++++++++---
> =A0block/blk-cgroup.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 18 ++----
> =A0include/linux/cgroup.h =A0 =A0 =A0 =A0 =A0 =A0| =A0 10 ++--
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 17 +++++-
> =A0kernel/cgroup_freezer.c =A0 =A0 =A0 =A0 =A0 | =A0 26 ++++-----
> =A0kernel/cpuset.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0105 +++++++++=
+++++++---------------------
> =A0kernel/ns_cgroup.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 23 +++-----
> =A0kernel/sched.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 38 +------=
------
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 18 ++----
> =A0security/device_cgroup.c =A0 =A0 =A0 =A0 =A0| =A0 =A03 -
> =A010 files changed, 122 insertions(+), 166 deletions(-)
>
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cg=
roups.txt
> index 190018b..d3c9a24 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -563,7 +563,7 @@ rmdir() will fail with it. From this behavior, pre_de=
stroy() can be
> =A0called multiple times against a cgroup.
>
> =A0int can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0struct task_struct *task, bool threadgroup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0struct task_struct *task)
> =A0(cgroup_mutex held by caller)
>
> =A0Called prior to moving a task into a cgroup; if the subsystem
> @@ -572,9 +572,14 @@ task is passed, then a successful result indicates t=
hat *any*
> =A0unspecified task can be moved into the cgroup. Note that this isn't
> =A0called on a fork. If this method returns 0 (success) then this should
> =A0remain valid while the caller holds cgroup_mutex and it is ensured tha=
t either
> -attach() or cancel_attach() will be called in future. If threadgroup is
> -true, then a successful result indicates that all threads in the given
> -thread's threadgroup can be moved together.
> +attach() or cancel_attach() will be called in future.
> +
> +int can_attach_task(struct cgroup *cgrp, struct task_struct *tsk);
> +(cgroup_mutex held by caller)
> +
> +As can_attach, but for operations that must be run once per task to be
> +attached (possibly many when using cgroup_attach_proc). Called after
> +can_attach.
>
> =A0void cancel_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *task, bool threadgroup)
> @@ -586,15 +591,24 @@ function, so that the subsystem can implement a rol=
lback. If not, not necessary.
> =A0This will be called only about subsystems whose can_attach() operation=
 have
> =A0succeeded.
>
> +void pre_attach(struct cgroup *cgrp);
> +(cgroup_mutex held by caller)
> +
> +For any non-per-thread attachment work that needs to happen before
> +attach_task. Needed by cpuset.
> +
> =A0void attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
> - =A0 =A0 =A0 =A0 =A0 struct cgroup *old_cgrp, struct task_struct *task,
> - =A0 =A0 =A0 =A0 =A0 bool threadgroup)
> + =A0 =A0 =A0 =A0 =A0 struct cgroup *old_cgrp, struct task_struct *task)
> =A0(cgroup_mutex held by caller)
>
> =A0Called after the task has been attached to the cgroup, to allow any
> =A0post-attachment activity that requires memory allocations or blocking.
> -If threadgroup is true, the subsystem should take care of all threads
> -in the specified thread's threadgroup. Currently does not support any
> +
> +void attach_task(struct cgroup *cgrp, struct task_struct *tsk);
> +(cgroup_mutex held by caller)
> +
> +As attach, but for operations that must be run once per task to be attac=
hed,
> +like can_attach_task. Called before attach. Currently does not support a=
ny
> =A0subsystem that might need the old_cgrp for every thread in the group.
>
> =A0void fork(struct cgroup_subsy *ss, struct task_struct *task)
> diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> index b1febd0..45b3809 100644
> --- a/block/blk-cgroup.c
> +++ b/block/blk-cgroup.c
> @@ -30,10 +30,8 @@ EXPORT_SYMBOL_GPL(blkio_root_cgroup);
>
> =A0static struct cgroup_subsys_state *blkiocg_create(struct cgroup_subsys=
 *,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup *);
> -static int blkiocg_can_attach(struct cgroup_subsys *, struct cgroup *,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_str=
uct *, bool);
> -static void blkiocg_attach(struct cgroup_subsys *, struct cgroup *,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup *, str=
uct task_struct *, bool);
> +static int blkiocg_can_attach_task(struct cgroup *, struct task_struct *=
);
> +static void blkiocg_attach_task(struct cgroup *, struct task_struct *);
> =A0static void blkiocg_destroy(struct cgroup_subsys *, struct cgroup *);
> =A0static int blkiocg_populate(struct cgroup_subsys *, struct cgroup *);
>
> @@ -46,8 +44,8 @@ static int blkiocg_populate(struct cgroup_subsys *, str=
uct cgroup *);
> =A0struct cgroup_subsys blkio_subsys =3D {
> =A0 =A0 =A0 =A0.name =3D "blkio",
> =A0 =A0 =A0 =A0.create =3D blkiocg_create,
> - =A0 =A0 =A0 .can_attach =3D blkiocg_can_attach,
> - =A0 =A0 =A0 .attach =3D blkiocg_attach,
> + =A0 =A0 =A0 .can_attach_task =3D blkiocg_can_attach_task,
> + =A0 =A0 =A0 .attach_task =3D blkiocg_attach_task,
> =A0 =A0 =A0 =A0.destroy =3D blkiocg_destroy,
> =A0 =A0 =A0 =A0.populate =3D blkiocg_populate,
> =A0#ifdef CONFIG_BLK_CGROUP
> @@ -1475,9 +1473,7 @@ done:
> =A0* of the main cic data structures. =A0For now we allow a task to change
> =A0* its cgroup only if it's the only owner of its ioc.
> =A0*/
> -static int blkiocg_can_attach(struct cgroup_subsys *subsys,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgro=
up *cgroup, struct task_struct *tsk,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool thread=
group)
> +static int blkiocg_can_attach_task(struct cgroup *cgrp, struct task_stru=
ct *tsk)
> =A0{
> =A0 =A0 =A0 =A0struct io_context *ioc;
> =A0 =A0 =A0 =A0int ret =3D 0;
> @@ -1492,9 +1488,7 @@ static int blkiocg_can_attach(struct cgroup_subsys =
*subsys,
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -static void blkiocg_attach(struct cgroup_subsys *subsys, struct cgroup *=
cgroup,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgro=
up *prev, struct task_struct *tsk,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool thread=
group)
> +static void blkiocg_attach_task(struct cgroup *cgrp, struct task_struct =
*tsk)
> =A0{
> =A0 =A0 =A0 =A0struct io_context *ioc;
>
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index ce104e3..35b69b4 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -467,12 +467,14 @@ struct cgroup_subsys {
> =A0 =A0 =A0 =A0int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup=
 *cgrp);
> =A0 =A0 =A0 =A0void (*destroy)(struct cgroup_subsys *ss, struct cgroup *c=
grp);
> =A0 =A0 =A0 =A0int (*can_attach)(struct cgroup_subsys *ss, struct cgroup =
*cgrp,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *tsk=
, bool threadgroup);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *tsk=
);
> + =A0 =A0 =A0 int (*can_attach_task)(struct cgroup *cgrp, struct task_str=
uct *tsk);
> =A0 =A0 =A0 =A0void (*cancel_attach)(struct cgroup_subsys *ss, struct cgr=
oup *cgrp,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *tsk=
, bool threadgroup);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_str=
uct *tsk);
> + =A0 =A0 =A0 void (*pre_attach)(struct cgroup *cgrp);
> + =A0 =A0 =A0 void (*attach_task)(struct cgroup *cgrp, struct task_struct=
 *tsk);
> =A0 =A0 =A0 =A0void (*attach)(struct cgroup_subsys *ss, struct cgroup *cg=
rp,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *old_cgrp, st=
ruct task_struct *tsk,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool threadgroup);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup *old_cgrp, str=
uct task_struct *tsk);
> =A0 =A0 =A0 =A0void (*fork)(struct cgroup_subsys *ss, struct task_struct =
*task);
> =A0 =A0 =A0 =A0void (*exit)(struct cgroup_subsys *ss, struct task_struct =
*task);
> =A0 =A0 =A0 =A0int (*populate)(struct cgroup_subsys *ss,
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 66a416b..616f27a 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1750,7 +1750,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct =
task_struct *tsk)
>
> =A0 =A0 =A0 =A0for_each_subsys(root, ss) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ss->can_attach) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D ss->can_attach(s=
s, cgrp, tsk, false);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D ss->can_attach(s=
s, cgrp, tsk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (retval) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Remembe=
r on which subsystem the can_attach()
> @@ -1762,6 +1762,13 @@ int cgroup_attach_task(struct cgroup *cgrp, struct=
 task_struct *tsk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->can_attach_task) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D ss->can_attach_t=
ask(cgrp, tsk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 failed_ss =
=3D ss;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0task_lock(tsk);
> @@ -1798,8 +1805,12 @@ int cgroup_attach_task(struct cgroup *cgrp, struct=
 task_struct *tsk)
> =A0 =A0 =A0 =A0write_unlock(&css_set_lock);
>
> =A0 =A0 =A0 =A0for_each_subsys(root, ss) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->pre_attach)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->pre_attach(cgrp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->attach_task)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->attach_task(cgrp, tsk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ss->attach)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->attach(ss, cgrp, oldcgr=
p, tsk, false);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->attach(ss, cgrp, oldcgr=
p, tsk);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
> =A0 =A0 =A0 =A0synchronize_rcu();
> @@ -1822,7 +1833,7 @@ out:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ss->cancel_attach)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->cancel_=
attach(ss, cgrp, tsk, false);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->cancel_=
attach(ss, cgrp, tsk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return retval;
> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
> index e7bebb7..e691818 100644
> --- a/kernel/cgroup_freezer.c
> +++ b/kernel/cgroup_freezer.c
> @@ -160,7 +160,7 @@ static void freezer_destroy(struct cgroup_subsys *ss,
> =A0*/
> =A0static int freezer_can_attach(struct cgroup_subsys *ss,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup =
*new_cgroup,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_str=
uct *task, bool threadgroup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_str=
uct *task)
> =A0{
> =A0 =A0 =A0 =A0struct freezer *freezer;
>
> @@ -172,26 +172,17 @@ static int freezer_can_attach(struct cgroup_subsys =
*ss,
> =A0 =A0 =A0 =A0if (freezer->state !=3D CGROUP_THAWED)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EBUSY;
>
> + =A0 =A0 =A0 return 0;
> +}
> +
> +static int freezer_can_attach_task(struct cgroup *cgrp, struct task_stru=
ct *tsk)
> +{
> =A0 =A0 =A0 =A0rcu_read_lock();
> - =A0 =A0 =A0 if (__cgroup_freezing_or_frozen(task)) {
> + =A0 =A0 =A0 if (__cgroup_freezing_or_frozen(tsk)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_unlock();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EBUSY;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0rcu_read_unlock();
> -
> - =A0 =A0 =A0 if (threadgroup) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *c;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_rcu(c, &task->thread_gr=
oup, thread_group) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (__cgroup_freezing_or_fr=
ozen(c)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_un=
lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBU=
SY;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> - =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -390,6 +381,9 @@ struct cgroup_subsys freezer_subsys =3D {
> =A0 =A0 =A0 =A0.populate =A0 =A0 =A0 =3D freezer_populate,
> =A0 =A0 =A0 =A0.subsys_id =A0 =A0 =A0=3D freezer_subsys_id,
> =A0 =A0 =A0 =A0.can_attach =A0 =A0 =3D freezer_can_attach,
> + =A0 =A0 =A0 .can_attach_task =3D freezer_can_attach_task,
> + =A0 =A0 =A0 .pre_attach =A0 =A0 =3D NULL,
> + =A0 =A0 =A0 .attach_task =A0 =A0=3D NULL,
> =A0 =A0 =A0 =A0.attach =A0 =A0 =A0 =A0 =3D NULL,
> =A0 =A0 =A0 =A0.fork =A0 =A0 =A0 =A0 =A0 =3D freezer_fork,
> =A0 =A0 =A0 =A0.exit =A0 =A0 =A0 =A0 =A0 =3D NULL,
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 4349935..5f71ca2 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1372,14 +1372,10 @@ static int fmeter_getrate(struct fmeter *fmp)
> =A0 =A0 =A0 =A0return val;
> =A0}
>
> -/* Protected by cgroup_lock */
> -static cpumask_var_t cpus_attach;
> -
> =A0/* Called by cgroups to determine if a cpuset is usable; cgroup_mutex =
held */
> =A0static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *=
cont,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct task_stru=
ct *tsk, bool threadgroup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct task_stru=
ct *tsk)
> =A0{
> - =A0 =A0 =A0 int ret;
> =A0 =A0 =A0 =A0struct cpuset *cs =3D cgroup_cs(cont);
>
> =A0 =A0 =A0 =A0if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mem=
s_allowed))
> @@ -1396,29 +1392,42 @@ static int cpuset_can_attach(struct cgroup_subsys=
 *ss, struct cgroup *cont,
> =A0 =A0 =A0 =A0if (tsk->flags & PF_THREAD_BOUND)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>
> - =A0 =A0 =A0 ret =3D security_task_setscheduler(tsk);
> - =A0 =A0 =A0 if (ret)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> - =A0 =A0 =A0 if (threadgroup) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *c;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_rcu(c, &tsk->thread_gro=
up, thread_group) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D security_task_setsc=
heduler(c);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_un=
lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> - =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static void cpuset_attach_task(struct task_struct *tsk, nodemask_t *to,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cpuse=
t *cs)
> +static int cpuset_can_attach_task(struct cgroup *cgrp, struct task_struc=
t *task)
> +{
> + =A0 =A0 =A0 return security_task_setscheduler(task);
> +}
> +
> +/*
> + * Protected by cgroup_lock. The nodemasks must be stored globally becau=
se
> + * dynamically allocating them is not allowed in pre_attach, and they mu=
st
> + * persist among pre_attach, attach_task, and attach.
> + */
> +static cpumask_var_t cpus_attach;
> +static nodemask_t cpuset_attach_nodemask_from;
> +static nodemask_t cpuset_attach_nodemask_to;
> +
> +/* Set-up work for before attaching each task. */
> +static void cpuset_pre_attach(struct cgroup *cont)
> +{
> + =A0 =A0 =A0 struct cpuset *cs =3D cgroup_cs(cont);
> +
> + =A0 =A0 =A0 if (cs =3D=3D &top_cpuset)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_copy(cpus_attach, cpu_possible_mask=
);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 guarantee_online_cpus(cs, cpus_attach);
> +
> + =A0 =A0 =A0 guarantee_online_mems(cs, &cpuset_attach_nodemask_to);
> +}
> +
> +/* Per-thread attachment work. */
> +static void cpuset_attach_task(struct cgroup *cont, struct task_struct *=
tsk)
> =A0{
> =A0 =A0 =A0 =A0int err;
> + =A0 =A0 =A0 struct cpuset *cs =3D cgroup_cs(cont);
> +
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * can_attach beforehand should guarantee that this doesn'=
t fail.
> =A0 =A0 =A0 =A0 * TODO: have a better way to handle failure here
> @@ -1426,56 +1435,31 @@ static void cpuset_attach_task(struct task_struct=
 *tsk, nodemask_t *to,
> =A0 =A0 =A0 =A0err =3D set_cpus_allowed_ptr(tsk, cpus_attach);
> =A0 =A0 =A0 =A0WARN_ON_ONCE(err);
>
> - =A0 =A0 =A0 cpuset_change_task_nodemask(tsk, to);
> + =A0 =A0 =A0 cpuset_change_task_nodemask(tsk, &cpuset_attach_nodemask_to=
);
> =A0 =A0 =A0 =A0cpuset_update_task_spread_flag(cs, tsk);
> -
> =A0}
>
> =A0static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *con=
t,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *oldcont,=
 struct task_struct *tsk,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool threadgroup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *oldcont,=
 struct task_struct *tsk)
> =A0{
> =A0 =A0 =A0 =A0struct mm_struct *mm;
> =A0 =A0 =A0 =A0struct cpuset *cs =3D cgroup_cs(cont);
> =A0 =A0 =A0 =A0struct cpuset *oldcs =3D cgroup_cs(oldcont);
> - =A0 =A0 =A0 NODEMASK_ALLOC(nodemask_t, from, GFP_KERNEL);
> - =A0 =A0 =A0 NODEMASK_ALLOC(nodemask_t, to, GFP_KERNEL);
> -
> - =A0 =A0 =A0 if (from =3D=3D NULL || to =3D=3D NULL)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto alloc_fail;
>
> - =A0 =A0 =A0 if (cs =3D=3D &top_cpuset) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_copy(cpus_attach, cpu_possible_mask=
);
> - =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 guarantee_online_cpus(cs, cpus_attach);
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 guarantee_online_mems(cs, to);
> -
> - =A0 =A0 =A0 /* do per-task migration stuff possibly for each in the thr=
eadgroup */
> - =A0 =A0 =A0 cpuset_attach_task(tsk, to, cs);
> - =A0 =A0 =A0 if (threadgroup) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *c;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_rcu(c, &tsk->thread_gro=
up, thread_group) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpuset_attach_task(c, to, c=
s);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 /* change mm; only needs to be done once even if threadgrou=
p */
> - =A0 =A0 =A0 *from =3D oldcs->mems_allowed;
> - =A0 =A0 =A0 *to =3D cs->mems_allowed;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Change mm, possibly for multiple threads in a threadgr=
oup. This is
> + =A0 =A0 =A0 =A0* expensive and may sleep.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 cpuset_attach_nodemask_from =3D oldcs->mems_allowed;
> + =A0 =A0 =A0 cpuset_attach_nodemask_to =3D cs->mems_allowed;
> =A0 =A0 =A0 =A0mm =3D get_task_mm(tsk);
> =A0 =A0 =A0 =A0if (mm) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mpol_rebind_mm(mm, to);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mpol_rebind_mm(mm, &cpuset_attach_nodemask_=
to);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (is_memory_migrate(cs))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpuset_migrate_mm(mm, from,=
 to);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpuset_migrate_mm(mm, &cpus=
et_attach_nodemask_from,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 &cpuset_attach_nodemask_to);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mmput(mm);
> =A0 =A0 =A0 =A0}
> -
> -alloc_fail:
> - =A0 =A0 =A0 NODEMASK_FREE(from);
> - =A0 =A0 =A0 NODEMASK_FREE(to);
> =A0}
>
> =A0/* The various types of files and directories in a cpuset file system =
*/
> @@ -1928,6 +1912,9 @@ struct cgroup_subsys cpuset_subsys =3D {
> =A0 =A0 =A0 =A0.create =3D cpuset_create,
> =A0 =A0 =A0 =A0.destroy =3D cpuset_destroy,
> =A0 =A0 =A0 =A0.can_attach =3D cpuset_can_attach,
> + =A0 =A0 =A0 .can_attach_task =3D cpuset_can_attach_task,
> + =A0 =A0 =A0 .pre_attach =3D cpuset_pre_attach,
> + =A0 =A0 =A0 .attach_task =3D cpuset_attach_task,
> =A0 =A0 =A0 =A0.attach =3D cpuset_attach,
> =A0 =A0 =A0 =A0.populate =3D cpuset_populate,
> =A0 =A0 =A0 =A0.post_clone =3D cpuset_post_clone,
> diff --git a/kernel/ns_cgroup.c b/kernel/ns_cgroup.c
> index 2c98ad9..1fc2b1b 100644
> --- a/kernel/ns_cgroup.c
> +++ b/kernel/ns_cgroup.c
> @@ -43,7 +43,7 @@ int ns_cgroup_clone(struct task_struct *task, struct pi=
d *pid)
> =A0* =A0 =A0 =A0 =A0ancestor cgroup thereof)
> =A0*/
> =A0static int ns_can_attach(struct cgroup_subsys *ss, struct cgroup *new_=
cgroup,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct task_struct *task=
, bool threadgroup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct task_struct *task)
> =A0{
> =A0 =A0 =A0 =A0if (current !=3D task) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!capable(CAP_SYS_ADMIN))
> @@ -53,21 +53,13 @@ static int ns_can_attach(struct cgroup_subsys *ss, st=
ruct cgroup *new_cgroup,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (!cgroup_is_descendant(new_cgroup, task))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> -
> - =A0 =A0 =A0 if (threadgroup) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *c;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_rcu(c, &task->thread_gr=
oup, thread_group) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!cgroup_is_descendant(n=
ew_cgroup, c)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_un=
lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPE=
RM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
>
> +static int ns_can_attach_task(struct cgroup *cgrp, struct task_struct *t=
sk)
> +{
> + =A0 =A0 =A0 if (!cgroup_is_descendant(cgrp, tsk))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -112,6 +104,7 @@ static void ns_destroy(struct cgroup_subsys *ss,
> =A0struct cgroup_subsys ns_subsys =3D {
> =A0 =A0 =A0 =A0.name =3D "ns",
> =A0 =A0 =A0 =A0.can_attach =3D ns_can_attach,
> + =A0 =A0 =A0 .can_attach_task =3D ns_can_attach_task,
> =A0 =A0 =A0 =A0.create =3D ns_create,
> =A0 =A0 =A0 =A0.destroy =A0=3D ns_destroy,
> =A0 =A0 =A0 =A0.subsys_id =3D ns_subsys_id,
> diff --git a/kernel/sched.c b/kernel/sched.c
> index 218ef20..d619f1d 100644
> --- a/kernel/sched.c
> +++ b/kernel/sched.c
> @@ -8655,42 +8655,10 @@ cpu_cgroup_can_attach_task(struct cgroup *cgrp, s=
truct task_struct *tsk)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static int
> -cpu_cgroup_can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *tsk, bool t=
hreadgroup)
> -{
> - =A0 =A0 =A0 int retval =3D cpu_cgroup_can_attach_task(cgrp, tsk);
> - =A0 =A0 =A0 if (retval)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return retval;
> - =A0 =A0 =A0 if (threadgroup) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *c;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_rcu(c, &tsk->thread_gro=
up, thread_group) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D cpu_cgroup_can_a=
ttach_task(cgrp, c);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_un=
lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return retv=
al;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 return 0;
> -}
> -
> =A0static void
> -cpu_cgroup_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *old_cont, struct task_st=
ruct *tsk,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool threadgroup)
> +cpu_cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
> =A0{
> =A0 =A0 =A0 =A0sched_move_task(tsk);
> - =A0 =A0 =A0 if (threadgroup) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *c;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_rcu(c, &tsk->thread_gro=
up, thread_group) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sched_move_task(c);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> - =A0 =A0 =A0 }
> =A0}
>
> =A0#ifdef CONFIG_FAIR_GROUP_SCHED
> @@ -8763,8 +8731,8 @@ struct cgroup_subsys cpu_cgroup_subsys =3D {
> =A0 =A0 =A0 =A0.name =A0 =A0 =A0 =A0 =A0 =3D "cpu",
> =A0 =A0 =A0 =A0.create =A0 =A0 =A0 =A0 =3D cpu_cgroup_create,
> =A0 =A0 =A0 =A0.destroy =A0 =A0 =A0 =A0=3D cpu_cgroup_destroy,
> - =A0 =A0 =A0 .can_attach =A0 =A0 =3D cpu_cgroup_can_attach,
> - =A0 =A0 =A0 .attach =A0 =A0 =A0 =A0 =3D cpu_cgroup_attach,
> + =A0 =A0 =A0 .can_attach_task =3D cpu_cgroup_can_attach_task,
> + =A0 =A0 =A0 .attach_task =A0 =A0=3D cpu_cgroup_attach_task,
> =A0 =A0 =A0 =A0.populate =A0 =A0 =A0 =3D cpu_cgroup_populate,
> =A0 =A0 =A0 =A0.subsys_id =A0 =A0 =A0=3D cpu_cgroup_subsys_id,
> =A0 =A0 =A0 =A0.early_init =A0 =A0 =3D 1,
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 729beb7..995f0b9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4720,8 +4720,7 @@ static void mem_cgroup_clear_mc(void)
>
> =A0static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgr=
oup *cgroup,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task=
_struct *p,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool thread=
group)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task=
_struct *p)
> =A0{
> =A0 =A0 =A0 =A0int ret =3D 0;
> =A0 =A0 =A0 =A0struct mem_cgroup *mem =3D mem_cgroup_from_cont(cgroup);
> @@ -4775,8 +4774,7 @@ static int mem_cgroup_can_attach(struct cgroup_subs=
ys *ss,
>
> =A0static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgr=
oup *cgroup,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task=
_struct *p,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool thread=
group)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task=
_struct *p)
> =A0{
> =A0 =A0 =A0 =A0mem_cgroup_clear_mc();
> =A0}
> @@ -4880,8 +4878,7 @@ static void mem_cgroup_move_charge(struct mm_struct=
 *mm)
> =A0static void mem_cgroup_move_task(struct cgroup_subsys *ss,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgr=
oup *cont,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgr=
oup *old_cont,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task=
_struct *p,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool thread=
group)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task=
_struct *p)
> =A0{
> =A0 =A0 =A0 =A0if (!mc.mm)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* no need to move charge */
> @@ -4893,22 +4890,19 @@ static void mem_cgroup_move_task(struct cgroup_su=
bsys *ss,
> =A0#else =A0/* !CONFIG_MMU */
> =A0static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgr=
oup *cgroup,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task=
_struct *p,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool thread=
group)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task=
_struct *p)
> =A0{
> =A0 =A0 =A0 =A0return 0;
> =A0}
> =A0static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgr=
oup *cgroup,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task=
_struct *p,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool thread=
group)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task=
_struct *p)
> =A0{
> =A0}
> =A0static void mem_cgroup_move_task(struct cgroup_subsys *ss,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgr=
oup *cont,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgr=
oup *old_cont,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task=
_struct *p,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool thread=
group)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task=
_struct *p)
> =A0{
> =A0}
> =A0#endif
> diff --git a/security/device_cgroup.c b/security/device_cgroup.c
> index 8d9c48f..cd1f779 100644
> --- a/security/device_cgroup.c
> +++ b/security/device_cgroup.c
> @@ -62,8 +62,7 @@ static inline struct dev_cgroup *task_devcgroup(struct =
task_struct *task)
> =A0struct cgroup_subsys devices_subsys;
>
> =A0static int devcgroup_can_attach(struct cgroup_subsys *ss,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *new_cgroup, struct task_stru=
ct *task,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool threadgroup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *new_cgroup, struct task_stru=
ct *task)
> =A0{
> =A0 =A0 =A0 =A0if (current !=3D task && !capable(CAP_SYS_ADMIN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
>
