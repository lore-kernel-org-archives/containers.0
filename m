From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v8.5 3/3] cgroups: make procs file writable
Date: Tue, 29 Mar 2011 16:27:19 -0700
Message-ID: <BANLkTikMgd5HvMyC1BTGzAtj_=Jk=wZm+A__30703.7541912452$1301441329$gmane$org@mail.gmail.com>
References: <20110208013542.GC31569@ghc17.ghc.andrew.cmu.edu>
	<20110208013950.GF31569@ghc17.ghc.andrew.cmu.edu>
	<AANLkTinEnNsu8=PEktXL_EECzGYqsgdf+uogGxe7k4W+@mail.gmail.com>
	<20110310061831.GA23736@ghc17.ghc.andrew.cmu.edu>
	<AANLkTikkmfwk0nV0p=omz2ddrw+ZqWF1Lx3EfO6dTjEQ@mail.gmail.com>
	<20110315211353.GA9992@ghc17.ghc.andrew.cmu.edu>
	<AANLkTim4z_x_UQE__f5t73Dimja8PTTXTKKgj2phv6FY@mail.gmail.com>
	<20110322051841.GA12055@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110322051841.GA12055-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
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

On Mon, Mar 21, 2011 at 10:18 PM, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> Makes procs file writable to move all threads by tgid at once
>
> From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
>
> This patch adds functionality that enables users to move all threads in a
> threadgroup at once to a cgroup by writing the tgid to the 'cgroup.procs'
> file. This current implementation makes use of a per-threadgroup rwsem th=
at's
> taken for reading in the fork() path to prevent newly forking threads wit=
hin
> the threadgroup from "escaping" while the move is in progress.
>
> Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>

Reviewed-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

OK, I guess this is ready to go in :-)

Paul

> ---
> =A0Documentation/cgroups/cgroups.txt | =A0 =A09 +
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0441 +++++++++=
++++++++++++++++++++++++----
> =A02 files changed, 401 insertions(+), 49 deletions(-)
>
> diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cg=
roups.txt
> index d3c9a24..92d93d6 100644
> --- a/Documentation/cgroups/cgroups.txt
> +++ b/Documentation/cgroups/cgroups.txt
> @@ -236,7 +236,8 @@ containing the following files describing that cgroup:
> =A0- cgroup.procs: list of tgids in the cgroup. =A0This list is not
> =A0 =A0guaranteed to be sorted or free of duplicate tgids, and userspace
> =A0 =A0should sort/uniquify the list if this property is required.
> - =A0 This is a read-only file, for now.
> + =A0 Writing a thread group id into this file moves all threads in that
> + =A0 group into this cgroup.
> =A0- notify_on_release flag: run the release agent on exit?
> =A0- release_agent: the path to use for release notifications (this file
> =A0 =A0exists in the top cgroup only)
> @@ -426,6 +427,12 @@ You can attach the current shell task by echoing 0:
>
> =A0# echo 0 > tasks
>
> +You can use the cgroup.procs file instead of the tasks file to move all
> +threads in a threadgroup at once. Echoing the pid of any task in a
> +threadgroup to cgroup.procs causes all tasks in that threadgroup to be
> +be attached to the cgroup. Writing 0 to cgroup.procs moves all tasks
> +in the writing task's threadgroup.
> +
> =A02.3 Mounting hierarchies by name
> =A0--------------------------------
>
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 616f27a..273633c 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1726,6 +1726,76 @@ int cgroup_path(const struct cgroup *cgrp, char *b=
uf, int buflen)
> =A0}
> =A0EXPORT_SYMBOL_GPL(cgroup_path);
>
> +/*
> + * cgroup_task_migrate - move a task from one cgroup to another.
> + *
> + * 'guarantee' is set if the caller promises that a new css_set for the =
task
> + * will already exist. If not set, this function might sleep, and can fa=
il with
> + * -ENOMEM. Otherwise, it can only fail with -ESRCH.
> + */
> +static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcg=
rp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct task_=
struct *tsk, bool guarantee)
> +{
> + =A0 =A0 =A0 struct css_set *oldcg;
> + =A0 =A0 =A0 struct css_set *newcg;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* get old css_set. we need to take task_lock and refcoun=
t it, because
> + =A0 =A0 =A0 =A0* an exiting task can change its css_set to init_css_set=
 and drop its
> + =A0 =A0 =A0 =A0* old one without taking cgroup_mutex.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 task_lock(tsk);
> + =A0 =A0 =A0 oldcg =3D tsk->cgroups;
> + =A0 =A0 =A0 get_css_set(oldcg);
> + =A0 =A0 =A0 task_unlock(tsk);
> +
> + =A0 =A0 =A0 /* locate or allocate a new css_set for this task. */
> + =A0 =A0 =A0 if (guarantee) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* we know the css_set we want already exis=
ts. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_subsys_state *template[CGROUP=
_SUBSYS_COUNT];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 read_lock(&css_set_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 newcg =3D find_existing_css_set(oldcg, cgrp=
, template);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!newcg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_css_set(newcg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 read_unlock(&css_set_lock);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 might_sleep();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* find_css_set will give us newcg already =
referenced. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 newcg =3D find_css_set(oldcg, cgrp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!newcg) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_css_set(oldcg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 put_css_set(oldcg);
> +
> + =A0 =A0 =A0 /* if PF_EXITING is set, the tsk->cgroups pointer is no lon=
ger safe. */
> + =A0 =A0 =A0 task_lock(tsk);
> + =A0 =A0 =A0 if (tsk->flags & PF_EXITING) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_unlock(tsk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_css_set(newcg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ESRCH;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 rcu_assign_pointer(tsk->cgroups, newcg);
> + =A0 =A0 =A0 task_unlock(tsk);
> +
> + =A0 =A0 =A0 /* Update the css_set linked lists if we're using them */
> + =A0 =A0 =A0 write_lock(&css_set_lock);
> + =A0 =A0 =A0 if (!list_empty(&tsk->cg_list))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_move(&tsk->cg_list, &newcg->tasks);
> + =A0 =A0 =A0 write_unlock(&css_set_lock);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* We just gained a reference on oldcg by taking it from =
the task. As
> + =A0 =A0 =A0 =A0* trading it for newcg is protected by cgroup_mutex, we'=
re safe to drop
> + =A0 =A0 =A0 =A0* it here; it will be freed under RCU.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 put_css_set(oldcg);
> +
> + =A0 =A0 =A0 set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0/**
> =A0* cgroup_attach_task - attach task 'tsk' to cgroup 'cgrp'
> =A0* @cgrp: the cgroup the task is attaching to
> @@ -1736,11 +1806,9 @@ EXPORT_SYMBOL_GPL(cgroup_path);
> =A0*/
> =A0int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
> =A0{
> - =A0 =A0 =A0 int retval =3D 0;
> + =A0 =A0 =A0 int retval;
> =A0 =A0 =A0 =A0struct cgroup_subsys *ss, *failed_ss =3D NULL;
> =A0 =A0 =A0 =A0struct cgroup *oldcgrp;
> - =A0 =A0 =A0 struct css_set *cg;
> - =A0 =A0 =A0 struct css_set *newcg;
> =A0 =A0 =A0 =A0struct cgroupfs_root *root =3D cgrp->root;
>
> =A0 =A0 =A0 =A0/* Nothing to do if the task is already in that cgroup */
> @@ -1771,38 +1839,9 @@ int cgroup_attach_task(struct cgroup *cgrp, struct=
 task_struct *tsk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 task_lock(tsk);
> - =A0 =A0 =A0 cg =3D tsk->cgroups;
> - =A0 =A0 =A0 get_css_set(cg);
> - =A0 =A0 =A0 task_unlock(tsk);
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Locate or allocate a new css_set for this task,
> - =A0 =A0 =A0 =A0* based on its final set of cgroups
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 newcg =3D find_css_set(cg, cgrp);
> - =A0 =A0 =A0 put_css_set(cg);
> - =A0 =A0 =A0 if (!newcg) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D -ENOMEM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 task_lock(tsk);
> - =A0 =A0 =A0 if (tsk->flags & PF_EXITING) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_unlock(tsk);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_css_set(newcg);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D -ESRCH;
> + =A0 =A0 =A0 retval =3D cgroup_task_migrate(cgrp, oldcgrp, tsk, false);
> + =A0 =A0 =A0 if (retval)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 rcu_assign_pointer(tsk->cgroups, newcg);
> - =A0 =A0 =A0 task_unlock(tsk);
> -
> - =A0 =A0 =A0 /* Update the css_set linked lists if we're using them */
> - =A0 =A0 =A0 write_lock(&css_set_lock);
> - =A0 =A0 =A0 if (!list_empty(&tsk->cg_list)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&tsk->cg_list);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add(&tsk->cg_list, &newcg->tasks);
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 write_unlock(&css_set_lock);
>
> =A0 =A0 =A0 =A0for_each_subsys(root, ss) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ss->pre_attach)
> @@ -1812,9 +1851,8 @@ int cgroup_attach_task(struct cgroup *cgrp, struct =
task_struct *tsk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ss->attach)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ss->attach(ss, cgrp, oldcg=
rp, tsk);
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
> +
> =A0 =A0 =A0 =A0synchronize_rcu();
> - =A0 =A0 =A0 put_css_set(cg);
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * wake up rmdir() waiter. the rmdir should fail since the=
 cgroup
> @@ -1864,49 +1902,356 @@ int cgroup_attach_task_all(struct task_struct *f=
rom, struct task_struct *tsk)
> =A0EXPORT_SYMBOL_GPL(cgroup_attach_task_all);
>
> =A0/*
> - * Attach task with pid 'pid' to cgroup 'cgrp'. Call with cgroup_mutex
> - * held. May take task_lock of task
> + * cgroup_attach_proc works in two stages, the first of which prefetches=
 all
> + * new css_sets needed (to make sure we have enough memory before commit=
ting
> + * to the move) and stores them in a list of entries of the following ty=
pe.
> + * TODO: possible optimization: use css_set->rcu_head for chaining inste=
ad
> + */
> +struct cg_list_entry {
> + =A0 =A0 =A0 struct css_set *cg;
> + =A0 =A0 =A0 struct list_head links;
> +};
> +
> +static bool css_set_check_fetched(struct cgroup *cgrp,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
task_struct *tsk, struct css_set *cg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct =
list_head *newcg_list)
> +{
> + =A0 =A0 =A0 struct css_set *newcg;
> + =A0 =A0 =A0 struct cg_list_entry *cg_entry;
> + =A0 =A0 =A0 struct cgroup_subsys_state *template[CGROUP_SUBSYS_COUNT];
> +
> + =A0 =A0 =A0 read_lock(&css_set_lock);
> + =A0 =A0 =A0 newcg =3D find_existing_css_set(cg, cgrp, template);
> + =A0 =A0 =A0 if (newcg)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_css_set(newcg);
> + =A0 =A0 =A0 read_unlock(&css_set_lock);
> +
> + =A0 =A0 =A0 /* doesn't exist at all? */
> + =A0 =A0 =A0 if (!newcg)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 /* see if it's already in the list */
> + =A0 =A0 =A0 list_for_each_entry(cg_entry, newcg_list, links) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cg_entry->cg =3D=3D newcg) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_css_set(newcg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* not found */
> + =A0 =A0 =A0 put_css_set(newcg);
> + =A0 =A0 =A0 return false;
> +}
> +
> +/*
> + * Find the new css_set and store it in the list in preparation for movi=
ng the
> + * given task to the given cgroup. Returns 0 or -ENOMEM.
> + */
> +static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct list_head *n=
ewcg_list)
> +{
> + =A0 =A0 =A0 struct css_set *newcg;
> + =A0 =A0 =A0 struct cg_list_entry *cg_entry;
> +
> + =A0 =A0 =A0 /* ensure a new css_set will exist for this thread */
> + =A0 =A0 =A0 newcg =3D find_css_set(cg, cgrp);
> + =A0 =A0 =A0 if (!newcg)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 /* add it to the list */
> + =A0 =A0 =A0 cg_entry =3D kmalloc(sizeof(struct cg_list_entry), GFP_KERN=
EL);
> + =A0 =A0 =A0 if (!cg_entry) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_css_set(newcg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 cg_entry->cg =3D newcg;
> + =A0 =A0 =A0 list_add(&cg_entry->links, newcg_list);
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/**
> + * cgroup_attach_proc - attach all threads in a threadgroup to a cgroup
> + * @cgrp: the cgroup to attach to
> + * @leader: the threadgroup leader task_struct of the group to be attach=
ed
> + *
> + * Call holding cgroup_mutex and the threadgroup_fork_lock of the leader=
. Will
> + * take task_lock of each thread in leader's threadgroup individually in=
 turn.
> + */
> +int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
> +{
> + =A0 =A0 =A0 int retval, i, group_size;
> + =A0 =A0 =A0 struct cgroup_subsys *ss, *failed_ss =3D NULL;
> + =A0 =A0 =A0 bool cancel_failed_ss =3D false;
> + =A0 =A0 =A0 /* guaranteed to be initialized later, but the compiler nee=
ds this */
> + =A0 =A0 =A0 struct cgroup *oldcgrp =3D NULL;
> + =A0 =A0 =A0 struct css_set *oldcg;
> + =A0 =A0 =A0 struct cgroupfs_root *root =3D cgrp->root;
> + =A0 =A0 =A0 /* threadgroup list cursor and array */
> + =A0 =A0 =A0 struct task_struct *tsk;
> + =A0 =A0 =A0 struct task_struct **group;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* we need to make sure we have css_sets for all the task=
s we're
> + =A0 =A0 =A0 =A0* going to move -before- we actually start moving them, =
so that in
> + =A0 =A0 =A0 =A0* case we get an ENOMEM we can bail out before making an=
y changes.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct list_head newcg_list;
> + =A0 =A0 =A0 struct cg_list_entry *cg_entry, *temp_nobe;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* step 0: in order to do expensive, possibly blocking op=
erations for
> + =A0 =A0 =A0 =A0* every thread, we cannot iterate the thread group list,=
 since it needs
> + =A0 =A0 =A0 =A0* rcu or tasklist locked. instead, build an array of all=
 threads in the
> + =A0 =A0 =A0 =A0* group - threadgroup_fork_lock prevents new threads fro=
m appearing,
> + =A0 =A0 =A0 =A0* and if threads exit, this will just be an over-estimat=
e.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 group_size =3D get_nr_threads(leader);
> + =A0 =A0 =A0 group =3D kmalloc(group_size * sizeof(*group), GFP_KERNEL);
> + =A0 =A0 =A0 if (!group)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> +
> + =A0 =A0 =A0 /* prevent changes to the threadgroup list while we take a =
snapshot. */
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 if (!thread_group_leader(leader)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* a race with de_thread from another thr=
ead's exec() may strip
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* us of our leadership, making while_eac=
h_thread unsafe to use
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* on this task. if this happens, there i=
s no choice but to
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* throw this task away and try again (fr=
om cgroup_procs_write);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* this is "double-double-toil-and-troubl=
e-check locking".
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D -EAGAIN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_free_group_list;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 /* take a reference on each task in the group to go in the =
array. */
> + =A0 =A0 =A0 tsk =3D leader;
> + =A0 =A0 =A0 i =3D 0;
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* as per above, nr_threads may decrease, b=
ut not increase. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(i >=3D group_size);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_task_struct(tsk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 group[i] =3D tsk;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 i++;
> + =A0 =A0 =A0 } while_each_thread(leader, tsk);
> + =A0 =A0 =A0 /* remember the number of threads in the array for later. */
> + =A0 =A0 =A0 group_size =3D i;
> + =A0 =A0 =A0 rcu_read_unlock();
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* step 1: check that we can legitimately attach to the c=
group.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 for_each_subsys(root, ss) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->can_attach) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D ss->can_attach(s=
s, cgrp, leader);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 failed_ss =
=3D ss;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_ca=
ncel_attach;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* a callback to be run on every thread in =
the threadgroup. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->can_attach_task) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* run on each task in the =
threadgroup. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < group_siz=
e; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D =
ss->can_attach_task(cgrp, group[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval)=
 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 failed_ss =3D ss;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 cancel_failed_ss =3D true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goto out_cancel_attach;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* step 2: make sure css_sets exist for all threads to be=
 migrated.
> + =A0 =A0 =A0 =A0* we use find_css_set, which allocates a new one if nece=
ssary.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 INIT_LIST_HEAD(&newcg_list);
> + =A0 =A0 =A0 for (i =3D 0; i < group_size; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk =3D group[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* nothing to do if this task is already in=
 the cgroup */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 oldcgrp =3D task_cgroup_from_root(tsk, root=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cgrp =3D=3D oldcgrp)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* get old css_set pointer */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_lock(tsk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tsk->flags & PF_EXITING) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* ignore this task if it's=
 going away */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_unlock(tsk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 oldcg =3D tsk->cgroups;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_css_set(oldcg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_unlock(tsk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* see if the new one for us is already in =
the list? */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (css_set_check_fetched(cgrp, tsk, oldcg,=
 &newcg_list)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* was already there, nothi=
ng to do. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_css_set(oldcg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* we don't already have it=
. get new one. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D css_set_prefetch=
(cgrp, oldcg, &newcg_list);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_css_set(oldcg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_li=
st_teardown;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* step 3: now that we're guaranteed success wrt the css_=
sets, proceed
> + =A0 =A0 =A0 =A0* to move all tasks to the new cgroup, calling ss->attac=
h_task for each
> + =A0 =A0 =A0 =A0* one along the way. there are no failure cases after he=
re, so this is
> + =A0 =A0 =A0 =A0* the commit point.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 for_each_subsys(root, ss) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->pre_attach)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->pre_attach(cgrp);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 for (i =3D 0; i < group_size; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk =3D group[i];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* leave current thread as it is if it's al=
ready there */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 oldcgrp =3D task_cgroup_from_root(tsk, root=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cgrp =3D=3D oldcgrp)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* attach each task to each subsystem */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_subsys(root, ss) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->attach_task)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->attach_=
task(cgrp, tsk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* if the thread is PF_EXITING, it can just=
 get skipped. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D cgroup_task_migrate(cgrp, oldcgr=
p, tsk, true);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(retval !=3D 0 && retval !=3D -ESRCH);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 /* nothing is sensitive to fork() after this point. */
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* step 4: do expensive, non-thread-specific subsystem ca=
llbacks.
> + =A0 =A0 =A0 =A0* TODO: if ever a subsystem needs to know the oldcgrp fo=
r each task
> + =A0 =A0 =A0 =A0* being moved, this call will need to be reworked to com=
municate that.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 for_each_subsys(root, ss) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->attach)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->attach(ss, cgrp, oldcgr=
p, leader);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* step 5: success! and cleanup
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 synchronize_rcu();
> + =A0 =A0 =A0 cgroup_wakeup_rmdir_waiter(cgrp);
> + =A0 =A0 =A0 retval =3D 0;
> +out_list_teardown:
> + =A0 =A0 =A0 /* clean up the list of prefetched css_sets. */
> + =A0 =A0 =A0 list_for_each_entry_safe(cg_entry, temp_nobe, &newcg_list, =
links) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&cg_entry->links);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_css_set(cg_entry->cg);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(cg_entry);
> + =A0 =A0 =A0 }
> +out_cancel_attach:
> + =A0 =A0 =A0 /* same deal as in cgroup_attach_task */
> + =A0 =A0 =A0 if (retval) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_subsys(root, ss) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss =3D=3D failed_ss) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cancel_=
failed_ss && ss->cancel_attach)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ss->cancel_attach(ss, cgrp, leader);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->cancel_attach)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->cancel_=
attach(ss, cgrp, leader);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 /* clean up the array of referenced threads in the group. */
> + =A0 =A0 =A0 for (i =3D 0; i < group_size; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_task_struct(group[i]);
> +out_free_group_list:
> + =A0 =A0 =A0 kfree(group);
> + =A0 =A0 =A0 return retval;
> +}
> +
> +/*
> + * Find the task_struct of the task to attach by vpid and pass it along =
to the
> + * function to attach either it or all tasks in its threadgroup. Will ta=
ke
> + * cgroup_mutex; may take task_lock of task.
> =A0*/
> -static int attach_task_by_pid(struct cgroup *cgrp, u64 pid)
> +static int attach_task_by_pid(struct cgroup *cgrp, u64 pid, bool threadg=
roup)
> =A0{
> =A0 =A0 =A0 =A0struct task_struct *tsk;
> =A0 =A0 =A0 =A0const struct cred *cred =3D current_cred(), *tcred;
> =A0 =A0 =A0 =A0int ret;
>
> + =A0 =A0 =A0 if (!cgroup_lock_live_group(cgrp))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> +
> =A0 =A0 =A0 =A0if (pid) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_lock();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tsk =3D find_task_by_vpid(pid);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!tsk || tsk->flags & PF_EXITING) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!tsk) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgroup_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ESRCH;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (threadgroup) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* RCU protects this acce=
ss, since tsk was found in the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* tid map. a race with d=
e_thread may cause group_leader
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to stop being the lead=
er, but cgroup_attach_proc will
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* detect it later.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk =3D tsk->group_leader;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (tsk->flags & PF_EXITING) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* optimization for the sin=
gle-task-only case */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgroup_unlock();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ESRCH;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* even if we're attaching all tasks in t=
he thread group, we
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* only need to check permissions on one =
of them.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tcred =3D __task_cred(tsk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cred->euid &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cred->euid !=3D tcred->uid &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cred->euid !=3D tcred->suid) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cgroup_unlock();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EACCES;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0get_task_struct(tsk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_read_unlock();
> =A0 =A0 =A0 =A0} else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk =3D current;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (threadgroup)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk =3D current->group_lead=
er;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk =3D current;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0get_task_struct(tsk);
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 ret =3D cgroup_attach_task(cgrp, tsk);
> + =A0 =A0 =A0 if (threadgroup) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 threadgroup_fork_write_lock(tsk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D cgroup_attach_proc(cgrp, tsk);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 threadgroup_fork_write_unlock(tsk);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D cgroup_attach_task(cgrp, tsk);
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0put_task_struct(tsk);
> + =A0 =A0 =A0 cgroup_unlock();
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> =A0static int cgroup_tasks_write(struct cgroup *cgrp, struct cftype *cft,=
 u64 pid)
> =A0{
> + =A0 =A0 =A0 return attach_task_by_pid(cgrp, pid, false);
> +}
> +
> +static int cgroup_procs_write(struct cgroup *cgrp, struct cftype *cft, u=
64 tgid)
> +{
> =A0 =A0 =A0 =A0int ret;
> - =A0 =A0 =A0 if (!cgroup_lock_live_group(cgrp))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> - =A0 =A0 =A0 ret =3D attach_task_by_pid(cgrp, pid);
> - =A0 =A0 =A0 cgroup_unlock();
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* attach_proc fails with -EAGAIN if thre=
adgroup leadership
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* changes in the middle of the operation=
, in which case we need
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to find the task_struct for the new le=
ader and start over.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D attach_task_by_pid(cgrp, tgid, true=
);
> + =A0 =A0 =A0 } while (ret =3D=3D -EAGAIN);
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> @@ -3260,9 +3605,9 @@ static struct cftype files[] =3D {
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =3D CGROUP_FILE_GENERIC_PREFIX "proc=
s",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.open =3D cgroup_procs_open,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* .write_u64 =3D cgroup_procs_write, TODO =
*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .write_u64 =3D cgroup_procs_write,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.release =3D cgroup_pidlist_release,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =3D S_IRUGO,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .mode =3D S_IRUGO | S_IWUSR,
> =A0 =A0 =A0 =A0},
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.name =3D "notify_on_release",
>
