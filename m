From: ccmail111 <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Subject: Re: cgroup tasks file error
Date: Mon, 13 Dec 2010 23:28:19 -0800 (PST)
Message-ID: <464217.68381.qm@web34208.mail.mud.yahoo.com>
References: <20101214010243.GC26523@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101214010243.GC26523-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


Thanks Matt.
After doing what Serge suggests, I was able to create a dummy cgroup and
move task (#580) below to the group. But now..
I see another issue: cannot move the task back to its parent (root), from t=
he group (hello) as in:

I am trying to move back task #580..

[host:/dev/cgroup]$ id
uid=3D0(root) gid=3D0(root) groups=3D0(root)


[host:/dev/cgroup]$ echo 580 > tasks
-bash: echo: write error: Operation not permitted

[host:/dev/cgroup]$ cat hello/tasks
580
610
2104
[host:/dev/cgroup]$


--- On Mon, 12/13/10, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:

> From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Subject: Re: cgroup tasks file error
> To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Cc: "ccmail111" <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEmxxBWXNxL4zz@public.gmane.org=
org
> Date: Monday, December 13, 2010, 8:02 PM
> On Mon, Dec 13, 2010 at 05:16:28PM
> -0600, Serge E. Hallyn wrote:
> > Quoting ccmail111 (ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org):
> > > =

> > > I see error:[host:/dev/cgroup]$ echo 693 >
> hello-test/tasks
> > > -bash: echo: write error: No space left on
> device
> =

> This does seem quite odd so I spent a little time looking
> at this and I agree with Serge.
> =

> > > [host:/dev/cgroup]$ pwd/dev/cgroup
> > > =

> > > But the user process is up and running..
> > > =

> > > [host:/dev/cgroup]$ ps aux | grep procroot =A0 =A0
> =A0 =

> > > =

> > > 693 =A00.0 =A00.4 =A034720 =A01112 ttyS0 =A0 =A0Sl =A0
> 19:11 =A0 0:00 /opt/bin/myproc -ext
> > > =

> > > Also the cgroup exists and valid..
> > > =

> > > [host:/dev/cgroup]$ ls | grep hello-test
> > > hello-test
> > > =

> > > What above error mean and any suggestions ?
> > > Please email.
> > =

> > Which cgroups do you have composed on that
> mount?=A0 I'm guess you
> > have cpuset, and you need to set the cpuset.mems and
> cpuset.cpus.
> > Until you do that, no tasks can be assigned to it.
> =

> I looked a a few places in kernel/cgroup.c which return
> ENOSPC
> or could potentially forward such an error. The only place
> that
> fits is in the attach path and is consistent with the
> notion that
> it's a cpuset issue:
> =

> echo <pid> > tasks =3D>
> cgroup_tasks_write() =3D>
> attach_task_by_pid() =3D>
> cgroup_attach_task() =3D> (via ss->can_attach() where
> ss is the cpuset subsystem)
> cpuset_can_attach():
> =A0 =A0 =A0 =A0 if
> (cpumask_empty(cs->cpus_allowed) ||
> nodes_empty(cs->mems_allowed))
> =A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> return -ENOSPC;
> =

> No other cgroup subsystem that I looked at (freezer,
> memcontrol, ns,
> =A0=A0=A0 blkio, devcgroup) returns ENOSPC when
> attaching a task.
> =

> So not only do you need to set those masks but each mask
> must have at
> least one cpu and "mem" respectively.
> =

> Cheers,
> =A0=A0=A0 -Matt Helsley
> =



      =
