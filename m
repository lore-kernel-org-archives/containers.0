From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: lxc-start: Device or resource busy - failed to remove previous
	cgroup
Date: Mon, 4 Jan 2010 19:24:18 -0600
Message-ID: <20100105012418.GA14928@us.ibm.com>
References: <68e6eac61001031710w3e16f62blfb3b5bfb86ea43b7@mail.gmail.com>
	<661de9471001031722o21c6bd55kb73403c85a8145e3@mail.gmail.com>
	<68e6eac61001031746r44668e6cheb497c7df5f68a18@mail.gmail.com>
	<68e6eac61001031854v35c9b0a0sebce033812977e73@mail.gmail.com>
	<4B41C5A4.704@free.fr>
	<68e6eac61001040721m250c0f14u9c07d04ef9ec3648@mail.gmail.com>
	<20100104180225.GA3510@us.ibm.com>
	<68e6eac61001041642p15d34837ocd13f13bd8249f21@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <68e6eac61001041642p15d34837ocd13f13bd8249f21-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dwight Schauer (dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> On Mon, Jan 4, 2010 at 12:02 PM, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > Quoting Dwight Schauer (dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> >> On Mon, Jan 4, 2010 at 4:40 AM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org=
> wrote:
> >> > Did you check the file /cgroup/<name>/tasks is empty ? it's probably=
 a dumb
> >> > question, but just in case :)
> >> >
> >>
> >> Ok, since this is easy enough to reproduce, I got it into this state a=
gain.
> >>
> >> $ cat /cgroup/arch64-1/tasks
> >> $
> >>
> >> it is empty
> >
> > And there are no subdirectories? =A0What does the output of
> > =A0 =A0 =A0 =A0ls -laFZ /cgroup/arch64-1 look like?
> >
> =

> well, tasks is empty.

tasks is empty, but there are subdirectories - 102, 26533, etc.
This looks like the dirtywork of the ns cgroup.  If each of those
subdirs is also empty then you can rmdir them, then rmdir /cgroup/arch64-1.

Or, use a release agent, which is what I do.

cat << EOF > /bin/remove_dead_cgroup.sh
#!/bin/sh
echo "Removing dead cgroup .$*." >> /var/log/cgroup
rmdir /cgroup/$* >> /var/log/cgroup 2>&1
echo "return value was $?" >> /var/log/cgroup
EOF
echo /bin/remove_dead_cgroup.sh > /cgroup/release_agent =

echo 1 > /cgroup/notify_on_release

> $ sudo ls -lRaFZ /cgroup/arch64-1
> /cgroup/arch64-1:
> total 0
> drwxr-xr-x 6 root root  ? 0 Jan  3 21:04 ./
> drwxr-xr-x 9 root root  ? 0 Jan  3 21:04 ../
> drwxr-xr-x 2 root users ? 0 Jan  3 21:05 102/
> drwxr-xr-x 2 root users ? 0 Jan  4 02:31 26533/
> drwxr-xr-x 2 root users ? 0 Jan  4 07:24 26627/
> drwxr-xr-x 2 root users ? 0 Jan  4 07:24 26668/
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 cpu.shares
> -r--r--r-- 1 root root  ? 0 Jan  3 21:04 cpuacct.stat
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 cpuacct.usage
> -r--r--r-- 1 root root  ? 0 Jan  3 21:04 cpuacct.usage_percpu
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 cpuset.cpu_exclusive
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 cpuset.cpus
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 cpuset.mem_exclusive
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 cpuset.mem_hardwall
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 cpuset.memory_migrate
> -r--r--r-- 1 root root  ? 0 Jan  3 21:04 cpuset.memory_pressure
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 cpuset.memory_spread_page
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 cpuset.memory_spread_slab
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 cpuset.mems
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 cpuset.sched_load_balance
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 cpuset.sched_relax_domain_level
> --w------- 1 root root  ? 0 Jan  3 21:04 devices.allow
> --w------- 1 root root  ? 0 Jan  3 21:04 devices.deny
> -r--r--r-- 1 root root  ? 0 Jan  3 21:04 devices.list
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 freezer.state
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 net_cls.classid
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 notify_on_release
> -rw-r--r-- 1 root root  ? 0 Jan  3 21:04 tasks
> =

> /cgroup/arch64-1/102:
> total 0
> drwxr-xr-x 2 root users ? 0 Jan  3 21:05 ./
> drwxr-xr-x 6 root root  ? 0 Jan  3 21:04 ../
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 cpu.shares
> -r--r--r-- 1 root users ? 0 Jan  3 21:05 cpuacct.stat
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 cpuacct.usage
> -r--r--r-- 1 root users ? 0 Jan  3 21:05 cpuacct.usage_percpu
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 cpuset.cpu_exclusive
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 cpuset.cpus
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 cpuset.mem_exclusive
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 cpuset.mem_hardwall
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 cpuset.memory_migrate
> -r--r--r-- 1 root users ? 0 Jan  3 21:05 cpuset.memory_pressure
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 cpuset.memory_spread_page
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 cpuset.memory_spread_slab
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 cpuset.mems
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 cpuset.sched_load_balance
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 cpuset.sched_relax_domain_level
> --w------- 1 root users ? 0 Jan  3 21:05 devices.allow
> --w------- 1 root users ? 0 Jan  3 21:05 devices.deny
> -r--r--r-- 1 root users ? 0 Jan  3 21:05 devices.list
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 freezer.state
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 net_cls.classid
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 notify_on_release
> -rw-r--r-- 1 root users ? 0 Jan  3 21:05 tasks
> =

> /cgroup/arch64-1/26533:
> total 0
> drwxr-xr-x 2 root users ? 0 Jan  4 02:31 ./
> drwxr-xr-x 6 root root  ? 0 Jan  3 21:04 ../
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 cpu.shares
> -r--r--r-- 1 root users ? 0 Jan  4 02:31 cpuacct.stat
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 cpuacct.usage
> -r--r--r-- 1 root users ? 0 Jan  4 02:31 cpuacct.usage_percpu
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 cpuset.cpu_exclusive
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 cpuset.cpus
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 cpuset.mem_exclusive
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 cpuset.mem_hardwall
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 cpuset.memory_migrate
> -r--r--r-- 1 root users ? 0 Jan  4 02:31 cpuset.memory_pressure
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 cpuset.memory_spread_page
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 cpuset.memory_spread_slab
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 cpuset.mems
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 cpuset.sched_load_balance
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 cpuset.sched_relax_domain_level
> --w------- 1 root users ? 0 Jan  4 02:31 devices.allow
> --w------- 1 root users ? 0 Jan  4 02:31 devices.deny
> -r--r--r-- 1 root users ? 0 Jan  4 02:31 devices.list
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 freezer.state
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 net_cls.classid
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 notify_on_release
> -rw-r--r-- 1 root users ? 0 Jan  4 02:31 tasks
> =

> /cgroup/arch64-1/26627:
> total 0
> drwxr-xr-x 2 root users ? 0 Jan  4 07:24 ./
> drwxr-xr-x 6 root root  ? 0 Jan  3 21:04 ../
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpu.shares
> -r--r--r-- 1 root users ? 0 Jan  4 07:24 cpuacct.stat
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuacct.usage
> -r--r--r-- 1 root users ? 0 Jan  4 07:24 cpuacct.usage_percpu
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.cpu_exclusive
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.cpus
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.mem_exclusive
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.mem_hardwall
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.memory_migrate
> -r--r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.memory_pressure
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.memory_spread_page
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.memory_spread_slab
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.mems
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.sched_load_balance
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.sched_relax_domain_level
> --w------- 1 root users ? 0 Jan  4 07:24 devices.allow
> --w------- 1 root users ? 0 Jan  4 07:24 devices.deny
> -r--r--r-- 1 root users ? 0 Jan  4 07:24 devices.list
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 freezer.state
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 net_cls.classid
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 notify_on_release
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 tasks
> =

> /cgroup/arch64-1/26668:
> total 0
> drwxr-xr-x 2 root users ? 0 Jan  4 07:24 ./
> drwxr-xr-x 6 root root  ? 0 Jan  3 21:04 ../
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpu.shares
> -r--r--r-- 1 root users ? 0 Jan  4 07:24 cpuacct.stat
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuacct.usage
> -r--r--r-- 1 root users ? 0 Jan  4 07:24 cpuacct.usage_percpu
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.cpu_exclusive
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.cpus
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.mem_exclusive
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.mem_hardwall
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.memory_migrate
> -r--r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.memory_pressure
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.memory_spread_page
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.memory_spread_slab
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.mems
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.sched_load_balance
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 cpuset.sched_relax_domain_level
> --w------- 1 root users ? 0 Jan  4 07:24 devices.allow
> --w------- 1 root users ? 0 Jan  4 07:24 devices.deny
> -r--r--r-- 1 root users ? 0 Jan  4 07:24 devices.list
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 freezer.state
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 net_cls.classid
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 notify_on_release
> -rw-r--r-- 1 root users ? 0 Jan  4 07:24 tasks
