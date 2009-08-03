From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by tgid
	at once
Date: Mon, 3 Aug 2009 14:13:55 -0400
Message-ID: <2f86c2480908031113y525b6cbdhe418b8a0364c7760__10123.0541863062$1249323376$gmane$org@mail.gmail.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>
	<20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>
	<20090803175452.GA5481@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090803175452.GA5481-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Aug 3, 2009 at 1:54 PM, Serge E. Hallyn<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> Quoting Ben Blum (bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> ...
>> +static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldc=
grp,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct task_str=
uct *tsk, int guarantee)
>> +{
>> + =A0 =A0 struct css_set *oldcg;
>> + =A0 =A0 struct css_set *newcg;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* get old css_set. we need to take task_lock and refcount i=
t, because
>> + =A0 =A0 =A0* an exiting task can change its css_set to init_css_set an=
d drop its
>> + =A0 =A0 =A0* old one without taking cgroup_mutex.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 task_lock(tsk);
>> + =A0 =A0 oldcg =3D tsk->cgroups;
>> + =A0 =A0 get_css_set(oldcg);
>> + =A0 =A0 task_unlock(tsk);
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* locate or allocate a new css_set for this task. 'guarante=
e' tells
>> + =A0 =A0 =A0* us whether or not we are sure that a new css_set already =
exists;
>> + =A0 =A0 =A0* in that case, we are not allowed to fail, as we won't nee=
d malloc.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 if (guarantee) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* our caller promises us that the css_set w=
e want already
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* exists, so we use find_existing_css_set d=
irectly.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup_subsys_state *template[CGROUP_SU=
BSYS_COUNT];
>> + =A0 =A0 =A0 =A0 =A0 =A0 read_lock(&css_set_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 newcg =3D find_existing_css_set(oldcg, cgrp, t=
emplate);
>> + =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!newcg);
>> + =A0 =A0 =A0 =A0 =A0 =A0 get_css_set(newcg);
>> + =A0 =A0 =A0 =A0 =A0 =A0 read_unlock(&css_set_lock);
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 might_sleep();
>
> So cgroup_task_migrate() might sleep, but
>
> ...
>
>
>> + =A0 =A0 down_write(&leader->cgroup_fork_mutex);
>> + =A0 =A0 rcu_read_lock();
>> + =A0 =A0 list_for_each_entry_rcu(tsk, &leader->thread_group, thread_gro=
up) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* leave current thread as it is if it's alrea=
dy there */
>> + =A0 =A0 =A0 =A0 =A0 =A0 oldcgrp =3D task_cgroup(tsk, subsys_id);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (cgrp =3D=3D oldcgrp)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* we don't care whether these threads are exi=
ting */
>> + =A0 =A0 =A0 =A0 =A0 =A0 retval =3D cgroup_task_migrate(cgrp, oldcgrp, =
tsk, 1);
>
> Here it is called under rcu_read_lock().

You'll notice the fourth argument, which tells cgroup_task_migrate
whether the css_set is guaranteed or not. If we say we've already got
it covered, the might_sleep section doesn't happen.

>> -void cgroup_fork(struct task_struct *child)
>> +void cgroup_fork(struct task_struct *child, int clone_flags)
>> =A0{
>> + =A0 =A0 if (clone_flags & CLONE_THREAD)
>> + =A0 =A0 =A0 =A0 =A0 =A0 down_read(&current->group_leader->cgroup_fork_=
mutex);
>> + =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 init_rwsem(&child->cgroup_fork_mutex);
>
> I'm also worried about the overhead here on what should be a
> fast case, CLONE_THREAD. =A0Have you done any benchmarking of
> one thread spawning a bunch of others?

Should be strictly better as this is making the rwsem local to the
threadgroup - at least in comparison to the previous edition of this
patch which had it as a global lock.

> What *exactly* is it we are protecting with cgroup_fork_mutex?
> 'fork' (as the name implies) is not a good answer, since we should be
> protecting data, not code.  If it is solely tsk->cgroups, then perhaps
> we should in fact try switching to (s?)rcu. =A0Then cgroup_fork() could
> just do rcu_read_lock, while cgroup_task_migrate() would make the change
> under a spinlock (to protect against concurrent cgroup_task_migrate()s),
> and using rcu_assign_pointer to let cgroup_fork() see consistent data
> either before or after the update... =A0That might mean that any checks d=
one
> before completing the migrate which involve the # of tasks might become
> invalidated before the migration completes? =A0Seems acceptable (since
> it'll be a small overcharge at most and can be quickly remedied).

You'll notice where the rwsem is released - not until cgroup_post_fork
or cgroup_fork_failed. It doesn't just protect the tsk->cgroups
pointer, but rather guarantees atomicity between adjusting
tsk->cgroups and attaching it to the cgroups lists with respect to the
critical section in attach_proc. If you've a better name for the lock
for such a race condition, do suggest.
