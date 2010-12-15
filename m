From: ccmail111 <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Subject: Re: cgroup tasks file error
Date: Wed, 15 Dec 2010 14:08:21 -0800 (PST)
Message-ID: <116655.19981.qm@web34207.mail.mud.yahoo.com>
References: <20101215175158.GB9587@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101215175158.GB9587-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



--- On Wed, 12/15/10, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Subject: Re: cgroup tasks file error
> To: "ccmail111" <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
> Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Date: Wednesday, December 15, 2010, 12:51 PM
> * ccmail111 <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
> [2010-12-14 10:22:32]:
> =

> > =

> > =

> > --- On Tue, 12/14/10, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> wrote:
> > =

> > > From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> > > Subject: Re: cgroup tasks file error
> > > To: "ccmail111" <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
> > > Cc: "Jue Hong" <honshj-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
> containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > > Date: Tuesday, December 14, 2010, 12:41 PM
> > > On Tue, Dec 14, 2010 at 11:03 PM,
> > > ccmail111 <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
> > > wrote:
> > > >
> > > > Isn't ns mounted by default ?
> > > > I rebooted machine,
> > > > based on 2.6.32 kernel.
> > > >
> > > > Then,
> > > >
> > > > [host:~]$ mkdir /dev/cgroup
> > > > [host:~]$ mount -t cgroup cpuset
> -ocpuset,ns
> > > /dev/cgroup
> > > > [host:~]$ ps aux | grep libvirt
> > > > root =A0 =A0 =A0 575 =A00.6 =A00.9 =A088816 =A02216
> ? =A0 =A0
> > > =A0 =A0Sl =A0 17:28 =A0 0:00 myproc --daemon
> > > > root =A0 =A0 =A0 654 =A00.0 =A00.2 =A0 4044 =A0 664
> ttyS0 =A0
> > > =A0S+ =A0 17:29 =A0 0:00 grep libvirt
> > > > [host:~]$ mkdir /dev/cgroup/hello
> > > > [host:~]$ cat /dev/cgroup/hello/tasks
> > > > [host:~]$ echo 0 >
> /dev/cgroup/hello/cpuset.cpus
> > > > [host:~]$ echo 0 >
> /dev/cgroup/hello/cpuset.mems
> > > =

> > > Can you paste the output of
> > > =

> > > cat /dev/cgroup/hello/cpuset.cpus and mems.
> > > =

> > > Also please paste the o/p of
> /dev/cgroup/cpuset.cpus and
> > > mems
> > > =

> > > > [host:~]$ echo 575 >
> /dev/cgroup/hello/tasks
> > > > [host:~]$ cat /dev/cgroup/hello/tasks
> > > > 575
> > > > [host:~]$ id
> > > > uid=3D0(root) gid=3D0(root) groups=3D0(root)
> > > > [host:~]$
> > > >
> > > > Now, I try to move the task out - the
> parent/root:
> > > >
> > > > [host:~]$ echo 575 > /dev/cgroup/tasks
> > > > -bash: echo: write error: Operation not
> permitted
> > > =

> > > can you send us the o/p of
> > > =

> > > ls -al /dev/cgroup
> > > =

> > > and ls -al /dev/cgroup/hello
> > > =

> > > Balbir
> > > =

> > ----
> > =

> > Please find output requested below:
> > =

> > =

> > [host:~]$ mkdir /dev/cgroup/hello
> > [host:~]$ cat /dev/cgroup/hello/tasks
> > [host:~]$ echo 0 > /dev/cgroup/hello/cpuset.cpus
> > [host:~]$ echo 0 > /dev/cgroup/hello/cpuset.mems
> > [host:~]$ echo 575 > /dev/cgroup/hello/tasks
> > [host:~]$ cat /dev/cgroup/hello/tasks
> > 575
> > [host:~]$ id
> > uid=3D0(root) gid=3D0(root) groups=3D0(root)
> > [host:~]$ echo 575 > /dev/cgroup/tasks
> > -bash: echo: write error: Operation not permitted
> > [host:~]$ cat /dev/cgroup/hello/cpuset.cpus
> > 0
> > [host:~]$ cat /dev/cgroup/hello/cpuset.mems
> > 0
> > [host:~]$ cat /dev/cgroup/cpuset.mems
> > 0
> > [host:~]$ cat /dev/cgroup/cpuset.cpus
> > 0
> > [host:~]$ ls -al /dev/cgroup/
> > total 0
> > drwxr-xr-x=A0 3 root root=A0 =A0 0 Dec 14
> 17:29 .
> > drwxr-xr-x 11 root root 2980 Dec 14 17:29 ..
> > -r--r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 cgroup.procs
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 cpuset.cpu_exclusive
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 cpuset.cpus
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 cpuset.mem_exclusive
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 cpuset.mem_hardwall
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 cpuset.memory_migrate
> > -r--r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 cpuset.memory_pressure
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 cpuset.memory_pressure_enabled
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 cpuset.memory_spread_page
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 cpuset.memory_spread_slab
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 cpuset.mems
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 cpuset.sched_load_balance
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 cpuset.sched_relax_domain_level
> > drwxr-xr-x=A0 2 root root=A0 =A0 0 Dec 14
> 17:29 hello
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 notify_on_release
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:29 release_agent
> > -rw-r--r--=A0 1 root root=A0 =A0 0 Dec 14
> 17:31 tasks
> > [host:~]$ ls -al /dev/cgroup/hello/
> > total 0
> > drwxr-xr-x 2 root root 0 Dec 14 17:29 .
> > drwxr-xr-x 3 root root 0 Dec 14 17:29 ..
> > -r--r--r-- 1 root root 0 Dec 14 17:29 cgroup.procs
> > -rw-r--r-- 1 root root 0 Dec 14 17:29
> cpuset.cpu_exclusive
> > -rw-r--r-- 1 root root 0 Dec 14 17:30 cpuset.cpus
> > -rw-r--r-- 1 root root 0 Dec 14 17:29
> cpuset.mem_exclusive
> > -rw-r--r-- 1 root root 0 Dec 14 17:29
> cpuset.mem_hardwall
> > -rw-r--r-- 1 root root 0 Dec 14 17:29
> cpuset.memory_migrate
> > -r--r--r-- 1 root root 0 Dec 14 17:29
> cpuset.memory_pressure
> > -rw-r--r-- 1 root root 0 Dec 14 17:29
> cpuset.memory_spread_page
> > -rw-r--r-- 1 root root 0 Dec 14 17:29
> cpuset.memory_spread_slab
> > -rw-r--r-- 1 root root 0 Dec 14 17:30 cpuset.mems
> > -rw-r--r-- 1 root root 0 Dec 14 17:29
> cpuset.sched_load_balance
> > -rw-r--r-- 1 root root 0 Dec 14 17:29
> cpuset.sched_relax_domain_level
> > -rw-r--r-- 1 root root 0 Dec 14 17:29
> notify_on_release
> > -rw-r--r-- 1 root root 0 Dec 14 17:30 tasks
> > [host:~]$ id
> > uid=3D0(root) gid=3D0(root) groups=3D0(root)
> > [host:~]$
> >
> =

> Looks like Serge's ns suggestion solved your problem,
> right? =

> =

> -- =

> =A0=A0=A0 Three Cheers,
> =A0=A0=A0 Balbir
> =


Yes, Balbir, thats right.

IMHO, it would nice if it can be documented on wiki or such.
Thanks everyone for suggestions..


      =
