From: ccmail111 <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Subject: Re: cgroup tasks file error
Date: Tue, 14 Dec 2010 11:23:20 -0800 (PST)
Message-ID: <867334.55308.qm@web34206.mail.mud.yahoo.com>
References: <20101214174040.GA4644@peq>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101214174040.GA4644@peq>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Serge,

Thanks for the tip. =

It seems to work (no ns).

[host:~]$ mount -t cgroup cpuset -ocpuset /dev/cgroup
[host:~]$ ls /dev/cgroup
cgroup.procs                    cpuset.memory_spread_page
cpuset.cpu_exclusive            cpuset.memory_spread_slab
cpuset.cpus                     cpuset.mems
cpuset.mem_exclusive            cpuset.sched_load_balance
cpuset.mem_hardwall             cpuset.sched_relax_domain_level
cpuset.memory_migrate           notify_on_release
cpuset.memory_pressure          release_agent
cpuset.memory_pressure_enabled  tasks

$ps aux | grep daemon
root       572  0.0  0.9  88816  2216 ?        Sl   18:25   0:00 myproc --d=
aemon

[host:~]$ mkdir /dev/cgroup/hello
[host:~]$ echo 0 > /dev/cgroup/hello/cpuset.mems
[host:~]$ echo 0 > /dev/cgroup/hello/cpuset.cpus
[host:~]$ echo 572 > /dev/cgroup/hello/tasks
[host:~]$ cat /dev/cgroup/hello/tasks
572

Now move it back..

[host:~]$ echo 572 > /dev/cgroup/tasks

check:
[host:~]$ cat /dev/cgroup/hello/tasks
[host:~]$
[host:~]$ cat /dev/cgroup/tasks | grep 572
572
[host:~]$ id
uid=3D0(root) gid=3D0(root) groups=3D0(root)
[host:~]$

Thanks everyone !




--- On Tue, 12/14/10, Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:

> From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Subject: Re: cgroup tasks file error
> To: "ccmail111" <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
> Cc: "Jue Hong" <honshj-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Matt Helsley" <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, =
containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Date: Tuesday, December 14, 2010, 12:40 PM
> Quoting ccmail111 (ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org):
> > =

> > Isn't ns mounted by default ?
> =

> I thought that in an earlier email you said you had done
> =

> =A0=A0=A0 mount -t cgroup cpuset -ocpuset
> /dev/cgroup
> =

> in which case ns would not be mounted.=A0 But note, we
> DO NOT
> want you to have ns mounted :)
> =

> > I rebooted machine,
> > based on 2.6.32 kernel.
> > =

> > Then,
> > =

> > [host:~]$ mkdir /dev/cgroup
> > [host:~]$ mount -t cgroup cpuset -ocpuset,ns
> /dev/cgroup
> > [host:~]$ ps aux | grep libvirt
> > root=A0 =A0 =A0=A0=A0575=A0
> 0.6=A0 0.9=A0 88816=A0 2216 ?=A0 =A0 =A0
> =A0 Sl=A0=A0=A017:28=A0=A0=A00:00
> myproc --daemon
> > root=A0 =A0 =A0=A0=A0654=A0
> 0.0=A0 0.2=A0=A0=A04044=A0=A0=A0664
> ttyS0=A0 =A0
> S+=A0=A0=A017:29=A0=A0=A00:00 grep
> libvirt
> > [host:~]$ mkdir /dev/cgroup/hello
> > [host:~]$ cat /dev/cgroup/hello/tasks
> > [host:~]$ echo 0 > /dev/cgroup/hello/cpuset.cpus
> > [host:~]$ echo 0 > /dev/cgroup/hello/cpuset.mems
> > [host:~]$ echo 575 > /dev/cgroup/hello/tasks
> > [host:~]$ cat /dev/cgroup/hello/tasks
> > 575
> > [host:~]$ id
> > uid=3D0(root) gid=3D0(root) groups=3D0(root)
> > [host:~]$
> > =

> > Now, I try to move the task out - the parent/root:
> > =

> > [host:~]$ echo 575 > /dev/cgroup/tasks
> > -bash: echo: write error: Operation not permitted
> > =

> > =

> > Any thoughts !?
> =

> Yes, ns cgroup is forbidding you from moving back :)=A0
> Mount without it.
> =

> -serge
> =



      =
