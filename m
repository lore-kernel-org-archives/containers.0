From: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Subject: Re: [PATCH 6/6] cgroup: kill subsys->can_attach_task(), pre_attach()
	and attach_task()
Date: Thu, 25 Aug 2011 02:45:24 -0700
Message-ID: <CALdu-PBU+1YqNkY9T8hu-Co+4ru776YYt4DKH0nGaE2se59=4g__15975.2706451856$1314266069$gmane$org@mail.gmail.com>
References: <1314138000-2049-1-git-send-email-tj@kernel.org>
	<1314138000-2049-7-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1314138000-2049-7-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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

On Tue, Aug 23, 2011 at 3:20 PM, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> These three methods are no longer used. =A0Kill them.
>
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Acked-by: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>

Overall, I think this patch set is a great improvement in code
simplicity and clarity.

Thanks,
Paul

> Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
> Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> ---
> =A0include/linux/cgroup.h | =A0 =A03 --
> =A0kernel/cgroup.c =A0 =A0 =A0 =A0| =A0 53 ++++--------------------------=
-----------------
> =A02 files changed, 5 insertions(+), 51 deletions(-)
>
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 2470c8e..5659d37 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -490,11 +490,8 @@ struct cgroup_subsys {
> =A0 =A0 =A0 =A0void (*destroy)(struct cgroup_subsys *ss, struct cgroup *c=
grp);
> =A0 =A0 =A0 =A0int (*can_attach)(struct cgroup_subsys *ss, struct cgroup =
*cgrp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_taskset =
*tset);
> - =A0 =A0 =A0 int (*can_attach_task)(struct cgroup *cgrp, struct task_str=
uct *tsk);
> =A0 =A0 =A0 =A0void (*cancel_attach)(struct cgroup_subsys *ss, struct cgr=
oup *cgrp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup_=
taskset *tset);
> - =A0 =A0 =A0 void (*pre_attach)(struct cgroup *cgrp);
> - =A0 =A0 =A0 void (*attach_task)(struct cgroup *cgrp, struct task_struct=
 *tsk);
> =A0 =A0 =A0 =A0void (*attach)(struct cgroup_subsys *ss, struct cgroup *cg=
rp,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_taskset *tset);
> =A0 =A0 =A0 =A0void (*fork)(struct cgroup_subsys *ss, struct task_struct =
*task);
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 474674b..374a4cb 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1926,13 +1926,6 @@ int cgroup_attach_task(struct cgroup *cgrp, struct=
 task_struct *tsk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->can_attach_task) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D ss->can_attach_t=
ask(cgrp, tsk);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 failed_ss =
=3D ss;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0retval =3D cgroup_task_migrate(cgrp, oldcgrp, tsk, false);
> @@ -1940,10 +1933,6 @@ int cgroup_attach_task(struct cgroup *cgrp, struct=
 task_struct *tsk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> =A0 =A0 =A0 =A0for_each_subsys(root, ss) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->pre_attach)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->pre_attach(cgrp);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->attach_task)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->attach_task(cgrp, tsk);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ss->attach)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ss->attach(ss, cgrp, &tset=
);
> =A0 =A0 =A0 =A0}
> @@ -2075,7 +2064,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct =
task_struct *leader)
> =A0{
> =A0 =A0 =A0 =A0int retval, i, group_size, nr_todo;
> =A0 =A0 =A0 =A0struct cgroup_subsys *ss, *failed_ss =3D NULL;
> - =A0 =A0 =A0 bool cancel_failed_ss =3D false;
> =A0 =A0 =A0 =A0/* guaranteed to be initialized later, but the compiler ne=
eds this */
> =A0 =A0 =A0 =A0struct css_set *oldcg;
> =A0 =A0 =A0 =A0struct cgroupfs_root *root =3D cgrp->root;
> @@ -2166,21 +2154,6 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct=
 task_struct *leader)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_c=
ancel_attach;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* a callback to be run on every thread in =
the threadgroup. */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->can_attach_task) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* run on each task in the =
threadgroup. */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < group_siz=
e; i++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tc =3D flex=
_array_get(group, i);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tc->cgr=
p =3D=3D cgrp)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D =
ss->can_attach_task(cgrp, tc->task);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval)=
 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 failed_ss =3D ss;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 cancel_failed_ss =3D true;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 goto out_cancel_attach;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/*
> @@ -2217,15 +2190,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struc=
t task_struct *leader)
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0* step 3: now that we're guaranteed success wrt the css_=
sets, proceed
> - =A0 =A0 =A0 =A0* to move all tasks to the new cgroup, calling ss->attac=
h_task for each
> - =A0 =A0 =A0 =A0* one along the way. there are no failure cases after he=
re, so this is
> - =A0 =A0 =A0 =A0* the commit point.
> + =A0 =A0 =A0 =A0* step 3: now that we're guaranteed success wrt the css_=
sets,
> + =A0 =A0 =A0 =A0* proceed to move all tasks to the new cgroup. =A0There =
are no
> + =A0 =A0 =A0 =A0* failure cases after here, so this is the commit point.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 for_each_subsys(root, ss) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->pre_attach)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->pre_attach(cgrp);
> - =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0for (i =3D 0; i < group_size; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tc =3D flex_array_get(group, i);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* leave current thread as it is if it's a=
lready there */
> @@ -2235,19 +2203,11 @@ int cgroup_attach_proc(struct cgroup *cgrp, struc=
t task_struct *leader)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* if the thread is PF_EXITING, it can jus=
t get skipped. */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D cgroup_task_migrate(cgrp, tc->c=
grp, tc->task, true);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(retval !=3D 0 && retval !=3D -ESRCH=
);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* attach each task to each subsystem */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_subsys(root, ss) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->attach_task)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->attach_=
task(cgrp, tc->task);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0/* nothing is sensitive to fork() after this point. */
>
> =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0* step 4: do expensive, non-thread-specific subsystem ca=
llbacks.
> - =A0 =A0 =A0 =A0* TODO: if ever a subsystem needs to know the oldcgrp fo=
r each task
> - =A0 =A0 =A0 =A0* being moved, this call will need to be reworked to com=
municate that.
> + =A0 =A0 =A0 =A0* step 4: do subsystem attach callbacks.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0for_each_subsys(root, ss) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ss->attach)
> @@ -2271,11 +2231,8 @@ out_cancel_attach:
> =A0 =A0 =A0 =A0/* same deal as in cgroup_attach_task */
> =A0 =A0 =A0 =A0if (retval) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_subsys(root, ss) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss =3D=3D failed_ss) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cancel_=
failed_ss && ss->cancel_attach)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 ss->cancel_attach(ss, cgrp, &tset);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss =3D=3D failed_ss)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ss->cancel_attach)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ss->cancel=
_attach(ss, cgrp, &tset);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> --
> 1.7.6
>
>
