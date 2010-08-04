From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 2/2] cgroups: make procs file writable
Date: Tue, 3 Aug 2010 21:30:00 -0700
Message-ID: <AANLkTikMofFGHSwF2QrdcAsit+hU6ihndhK5cod8duwS__28502.1023512401$1280896392$gmane$org@mail.gmail.com>
References: <20100730235649.GA22644@ghc17.ghc.andrew.cmu.edu>
	<20100730235902.GC22644@ghc17.ghc.andrew.cmu.edu>
	<20100804100811.199d73ba.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100804100811.199d73ba.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Ben, Kame,

Sorry for the delay in getting to look at this,

On Tue, Aug 3, 2010 at 6:08 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
>>
>> =A0 =A0 =A0 for_each_subsys(root, ss) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->attach)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->attach(ss, cgrp, oldcgrp=
, tsk, false);
>> =A0 =A0 =A0 }
>> - =A0 =A0 set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
>> +
>
> Hmm. By this, we call ss->attach(ss, cgrp, oldcgrp, tsk, false) after
> makring CGRP_RELEASABLE+synchronize_rcu() to oldcgroup...is it safe ?
> And why move it before attach() ?
>

Marking as releasable should be fine - the only time this is cleared
is when you write to notify_on_release.

I think that the put_css_set(oldcg) and synchronize_rcu() is safe, by
the following logic:

- we took cgroup_lock in cgroup_tasks_write()

- after this point, oldcgrp was initialized from the task's cgroup;
therefore oldcgrp still existed at this point

- even if all the threads (including the one being operated on) exit
(and hence leave oldcgrp) while we're doing the attach, we're holding
cgroup_lock so no-one else can delete oldcgrp

So it's certainly possible that the task in question has exited by the
time we call the subsys attach methods, but oldcgrp should still be
alive.

Whether we need an additional synchronize_rcu() after the attach()
calls is harder to determine - I guess it's better to be safe than
sorry, unless people are seeing specific performance issues with this.

I think the css_set_check_fetched() function needs more comments
explaining its behaviour and what its return value indicates.
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* we need to make sure we have css_sets for all the tasks w=
e're
>> + =A0 =A0 =A0* going to move -before- we actually start moving them, so =
that in
>> + =A0 =A0 =A0* case we get an ENOMEM we can bail out before making any c=
hanges.

More than that - even if we don't get an ENOMEM, we can't safely sleep
in the RCU section, so we'd either have to do all memory allocations
atomically (which would be bad and unreliable) or else we avoid the
need to allocate in the RCU section (which is the choice taken here).

>> + =A0 =A0 =A0*/
>> + =A0 =A0 struct list_head newcg_list;
>> + =A0 =A0 struct cg_list_entry *cg_entry, *temp_nobe;
>> +
>> + =A0 =A0 /* check that we can legitimately attach to the cgroup. */
>> + =A0 =A0 for_each_subsys(root, ss) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (ss->can_attach) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D ss->can_attach(ss, =
cgrp, leader, true);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 failed_ss =3D =
ss;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 }
>
> Then, we cannot do attach limitaion control per thread ? (This just check=
 leader.)
> Is it ok for all subsys ?

By passing "true" as the "threadgroup" parameter to can_attach(),
we're letting the subsystem decide if it needs to do per-thread
checks. For most subsystems, calling them once for each thread would
be unnecessary.

>
>
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* step 1: make sure css_sets exist for all threads to be mi=
grated.
>> + =A0 =A0 =A0* we use find_css_set, which allocates a new one if necessa=
ry.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 INIT_LIST_HEAD(&newcg_list);
>> + =A0 =A0 oldcgrp =3D task_cgroup_from_root(leader, root);
>> + =A0 =A0 if (cgrp !=3D oldcgrp) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* get old css_set */
>> + =A0 =A0 =A0 =A0 =A0 =A0 task_lock(leader);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (leader->flags & PF_EXITING) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_unlock(leader);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto prefetch_loop;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
> Why do we continue here ? not -ESRCH ?
>

It's possible that some threads from the process are exiting while
we're trying to move the entire process. As long as we move at least
one thread, we shouldn't care if some of its threads are exiting.

Which means that after we've done the prefetch loop, we should
probably check that the newcg_list isn't empty, and return -ESRCH in
that case.

>
>> + =A0 =A0 =A0 =A0 =A0 =A0 oldcg =3D leader->cgroups;
>> + =A0 =A0 =A0 =A0 =A0 =A0 get_css_set(oldcg);
>> + =A0 =A0 =A0 =A0 =A0 =A0 task_unlock(leader);
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* acquire new one */

/* acquire a new css_set for the leader */

>> + =A0 =A0 =A0* if we need to fetch a new css_set for this task, we must =
exit the
>> + =A0 =A0 =A0* rcu_read section because allocating it can sleep. afterwa=
rds, we'll
>> + =A0 =A0 =A0* need to restart iteration on the threadgroup list - the w=
hole thing
>> + =A0 =A0 =A0* will be O(nm) in the number of threads and css_sets; as t=
he typical
>> + =A0 =A0 =A0* case has only one css_set for all of them, usually O(n). =
which ones

Maybe better to say "in the worst case this is O(n^2) on the number of
threads; however, in the vast majority of cases all the threads will
be in the same cgroups as the leader and we'll make a just single pass
through the list with no additional allocations needed".

>
> It's going away but seems to exist for a while....then, "continue" is safe
> for keeping consistency ?

Yes, because we don't sleep so the RCU list is still valid.

>> + =A0 =A0 =A0 =A0 =A0 =A0 /* see if the new one for us is already in the=
 list? */

/* See if we already have an appropriate css_set for this thread */

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* begin iteration again. */

/* Since we may have slept in css_set_prefetch(), the RCU list is no
longer valid, so we must begin the iteration again; Any threads that
we've previously processed will pass the css_set_check_fetched() test
on subsequent iterations since we hold cgroup_lock, so we're
guaranteed to make progress. */

> Does this function work well if the process has 10000+ threads ?

In general there'll only be one cgroup so it'll be a single pass
through the list.

>
> How about this logic ?
> =3D=3D
>
> =A0 =A0 =A0 =A0/* At first, find out necessary things */
> =A0 =A0 =A0 =A0rcu_read_lock();
> =A0 =A0 =A0 =A0list_for_each_entry_rcu() {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0oldcgrp =3D task_cgroup_from_root(tsk, roo=
t);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (oldcgrp =3D=3D cgrp)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task_lock(task);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (task->flags & PF_EXITING) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task_unlock(task);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0oldcg =3D tsk->cgroups;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0get_css_set(oldcg);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task_unlock(task);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0read_lock(&css_set_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0newcg =3D find_existing_css_set(oldcgrp cg=
rp, template);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (newcg)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0remember_this_newcg(newcg,=
 &found_cg_array); {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0put_css_set(oldcg);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0remember_need_to_allocate(=
oldcg, &need_to_allocate_array);

The problem with this is that remember_need_to_allocate() will itself
need to allocate memory in order to allow need_to_allocate_array to
expand arbitrarily. Which can't be done without GFP_ATOMIC or else
sleeping in the RCU section, neither of which are good.
>> +list_teardown:
>> + =A0 =A0 /* clean up the list of prefetched css_sets. */
>> + =A0 =A0 list_for_each_entry_safe(cg_entry, temp_nobe, &newcg_list, lin=
ks) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 list_del(&cg_entry->links);
>> + =A0 =A0 =A0 =A0 =A0 =A0 put_css_set(cg_entry->cg);
>> + =A0 =A0 =A0 =A0 =A0 =A0 kfree(cg_entry);
>> + =A0 =A0 }

I wonder if we might need a synchronize_rcu() here?

>> --- a/kernel/cpuset.c
>> +++ b/kernel/cpuset.c
>> @@ -1404,6 +1404,10 @@ static int cpuset_can_attach(struct cgroup_subsys=
 *ss, struct cgroup *cont,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *c;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!thread_group_leader(tsk)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EAGAIN;
>> + =A0 =A0 =A0 =A0 =A0 =A0 }

Why are you adding this requirement, here and in sched.c? (ns_cgroup.c
doesn't matter since it's being deleted).

Paul
