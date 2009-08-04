From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 5/6] Lets ss->can_attach and ss->attach do whole
	threadgroups at a time
Date: Mon, 3 Aug 2009 17:35:16 -0700
Message-ID: <2f86c2480908031735m7dbee753wf63724959ee135eb__49134.5385359184$1249346162$gmane$org@mail.gmail.com>
References: <20090731012908.27908.62208.stgit@hastromil.mtv.corp.google.com>
	<20090731015149.27908.25403.stgit@hastromil.mtv.corp.google.com>
	<4A7649E1.4000200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A7649E1.4000200-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Sun, Aug 2, 2009 at 7:22 PM, Li Zefan<lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> 09:51, Ben Blum wrote:
>> Lets ss->can_attach and ss->attach do whole threadgroups at a time
>>
>> This patch alters the ss->can_attach and ss->attach functions to be able=
 to
>> deal with a whole threadgroup at a time, for use in cgroup_attach_proc. =
(This
>> is a pre-patch to cgroup-procs-writable.patch.)
>>
>> Currently, new mode of the attach function can only tell the subsystem a=
bout
>> the old cgroup of the threadgroup leader. No subsystem currently needs t=
hat
>> information for each thread that's being moved, but if one were to be ad=
ded
>> (for example, one that counts tasks within a group) this bit would need =
to be
>> reworked a bit to tell the subsystem the right information.
>>
>> Signed-off-by: Ben Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>
>> ---
>>
>> =A0include/linux/cgroup.h =A0 | =A0 =A07 +++--
>> =A0kernel/cgroup.c =A0 =A0 =A0 =A0 =A0| =A0 =A04 +--
>> =A0kernel/cgroup_freezer.c =A0| =A0 15 +++++++++--
>> =A0kernel/cpuset.c =A0 =A0 =A0 =A0 =A0| =A0 65 +++++++++++++++++++++++++=
+++++++++++----------
>> =A0kernel/ns_cgroup.c =A0 =A0 =A0 | =A0 16 ++++++++++-
>> =A0kernel/sched.c =A0 =A0 =A0 =A0 =A0 | =A0 37 ++++++++++++++++++++++++--
>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0| =A0 =A03 +-
>> =A0security/device_cgroup.c | =A0 =A03 +-
>> =A08 files changed, 122 insertions(+), 28 deletions(-)
>>
>> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
>> index 24e3f1a..8286758 100644
>> --- a/include/linux/cgroup.h
>> +++ b/include/linux/cgroup.h
>> @@ -408,10 +408,11 @@ struct cgroup_subsys {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *cgrp);
>> =A0 =A0 =A0 int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *=
cgrp);
>> =A0 =A0 =A0 void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgr=
p);
>> - =A0 =A0 int (*can_attach)(struct cgroup_subsys *ss,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *cgrp, struc=
t task_struct *tsk);
>> + =A0 =A0 int (*can_attach)(struct cgroup_subsys *ss, struct cgroup *cgr=
p,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *tsk, b=
ool threadgroup);
>> =A0 =A0 =A0 void (*attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *old_cgrp, struc=
t task_struct *tsk);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *old_cgrp, struc=
t task_struct *tsk,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool threadgroup);
>
> Could you also update Documentation/cgroups/cgroups.txt?
>
>> =A0 =A0 =A0 void (*fork)(struct cgroup_subsys *ss, struct task_struct *t=
ask);
>> =A0 =A0 =A0 void (*exit)(struct cgroup_subsys *ss, struct task_struct *t=
ask);
>> =A0 =A0 =A0 int (*populate)(struct cgroup_subsys *ss,
>> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
>> index a12bc8e..ea05d6b 100644
>> --- a/kernel/cgroup.c
>> +++ b/kernel/cgroup.c
>> @@ -1324,7 +1324,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct=
 task_struct *tsk)
>>
>> =A0 =A0 =A0 for_each_subsys(root, ss) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->can_attach) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D ss->can_attach(ss, =
cgrp, tsk);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 retval =3D ss->can_attach(ss, =
cgrp, tsk, false);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return retva=
l;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> @@ -1362,7 +1362,7 @@ int cgroup_attach_task(struct cgroup *cgrp, struct=
 task_struct *tsk)
>>
>> =A0 =A0 =A0 for_each_subsys(root, ss) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss->attach)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->attach(ss, cgrp, oldcgrp, =
tsk);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ss->attach(ss, cgrp, oldcgrp, =
tsk, false);
>> =A0 =A0 =A0 }
>> =A0 =A0 =A0 set_bit(CGRP_RELEASABLE, &oldcgrp->flags);
>> =A0 =A0 =A0 synchronize_rcu();
>> diff --git a/kernel/cgroup_freezer.c b/kernel/cgroup_freezer.c
>> index fb249e2..4e352ab 100644
>> --- a/kernel/cgroup_freezer.c
>> +++ b/kernel/cgroup_freezer.c
>> @@ -159,10 +159,9 @@ static bool is_task_frozen_enough(struct task_struc=
t *task)
>> =A0 */
>> =A0static int freezer_can_attach(struct cgroup_subsys *ss,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct cgroup *n=
ew_cgroup,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct=
 *task)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct=
 *task, bool threadgroup)
>> =A0{
>> =A0 =A0 =A0 struct freezer *freezer;
>> -
>
> Please reserve this blank line.
>
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* Anything frozen can't move or be moved to/from.
>> =A0 =A0 =A0 =A0*
>> @@ -177,6 +176,18 @@ static int freezer_can_attach(struct cgroup_subsys =
*ss,
>> =A0 =A0 =A0 if (freezer->state =3D=3D CGROUP_FROZEN)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
>>
>> + =A0 =A0 if (threadgroup) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *c;
>
> And better have a blank line here. ;)
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
>> + =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_rcu(c, &task->thread_group=
, thread_group) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_task_frozen_enough(c)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unloc=
k();
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
>> + =A0 =A0 }
>> +
>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
>> index 7e75a41..86397f4 100644
>> --- a/kernel/cpuset.c
>> +++ b/kernel/cpuset.c
>> @@ -1324,9 +1324,10 @@ static int fmeter_getrate(struct fmeter *fmp)
>> =A0static cpumask_var_t cpus_attach;
>>
>> =A0/* Called by cgroups to determine if a cpuset is usable; cgroup_mutex=
 held */
>> -static int cpuset_can_attach(struct cgroup_subsys *ss,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct cgroup *cont=
, struct task_struct *tsk)
>> +static int cpuset_can_attach(struct cgroup_subsys *ss, struct cgroup *c=
ont,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct task_struct =
*tsk, bool threadgroup)
>> =A0{
>> + =A0 =A0 int ret;
>> =A0 =A0 =A0 struct cpuset *cs =3D cgroup_cs(cont);
>>
>> =A0 =A0 =A0 if (cpumask_empty(cs->cpus_allowed) || nodes_empty(cs->mems_=
allowed))
>> @@ -1343,18 +1344,50 @@ static int cpuset_can_attach(struct cgroup_subsy=
s *ss,
>> =A0 =A0 =A0 if (tsk->flags & PF_THREAD_BOUND)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>>
>> - =A0 =A0 return security_task_setscheduler(tsk, 0, NULL);
>> + =A0 =A0 ret =3D security_task_setscheduler(tsk, 0, NULL);
>> + =A0 =A0 if (ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> + =A0 =A0 if (threadgroup) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *c;
>
> ditto
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
>> + =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_rcu(c, &tsk->thread_group,=
 thread_group) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D security_task_setsched=
uler(c, 0, NULL);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unloc=
k();
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
>> + =A0 =A0 }
>> + =A0 =A0 return 0;
>> +}
>
>

All taken care of. Thanks.
