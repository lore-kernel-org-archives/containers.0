From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v8 3/3] cgroups: make procs file writable
Date: Thu, 3 Mar 2011 10:38:58 -0800
Message-ID: <AANLkTinEnNsu8=PEktXL_EECzGYqsgdf+uogGxe7k4W+__48472.1918161542$1299177606$gmane$org@mail.gmail.com>
References: <20110208013542.GC31569@ghc17.ghc.andrew.cmu.edu>
	<20110208013950.GF31569@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110208013950.GF31569-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
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
> ---
> + =A0 =A0 =A0 /* remember the number of threads in the array for later. */
> + =A0 =A0 =A0 BUG_ON(i =3D=3D 0);

This BUG_ON() seems unnecessary, given the i++ directly above it.

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

Should we be setting failed_ss here? Doesn't that mean that if all
subsystems pass the can_attach() check but the first one fails a
can_attach_task() check, we don't call any cancel_attach() methods?

What are the rollback semantics for failing a can_attach_task() check?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (threadgroup) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* it is safe to find gro=
up_leader because tsk was found
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* in the tid map, meanin=
g it can't have been unhashed
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* by someone in de_threa=
d changing the leadership.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tsk =3D tsk->group_leader;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!thread_group_leader=
(tsk));

Can this race with an exiting/execing group leader?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else if (tsk->flags & PF_EXITING) {

The check for PF_EXITING doesn't apply to group leaders?

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

Maybe turn these returns into "goto out;" statements and put the
unlock after the out: label?
