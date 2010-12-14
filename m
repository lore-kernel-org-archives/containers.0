From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: cgroup tasks file error
Date: Tue, 14 Dec 2010 23:11:30 +0530
Message-ID: <AANLkTi=gR2JVXf0uidRMZo7s88th1wu-4+AbC0ZwRUJk@mail.gmail.com>
References: <AANLkTi=tpq0Jo9WAd5eu=fP2bLaSG6iLpHtAVR1xe=Ub@mail.gmail.com>
	<166364.22607.qm@web34208.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <166364.22607.qm-VjZBGxy5l2evuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ccmail111 <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Dec 14, 2010 at 11:03 PM, ccmail111 <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org> wrote:
>
> Isn't ns mounted by default ?
> I rebooted machine,
> based on 2.6.32 kernel.
>
> Then,
>
> [host:~]$ mkdir /dev/cgroup
> [host:~]$ mount -t cgroup cpuset -ocpuset,ns /dev/cgroup
> [host:~]$ ps aux | grep libvirt
> root =A0 =A0 =A0 575 =A00.6 =A00.9 =A088816 =A02216 ? =A0 =A0 =A0 =A0Sl =
=A0 17:28 =A0 0:00 myproc --daemon
> root =A0 =A0 =A0 654 =A00.0 =A00.2 =A0 4044 =A0 664 ttyS0 =A0 =A0S+ =A0 1=
7:29 =A0 0:00 grep libvirt
> [host:~]$ mkdir /dev/cgroup/hello
> [host:~]$ cat /dev/cgroup/hello/tasks
> [host:~]$ echo 0 > /dev/cgroup/hello/cpuset.cpus
> [host:~]$ echo 0 > /dev/cgroup/hello/cpuset.mems

Can you paste the output of

cat /dev/cgroup/hello/cpuset.cpus and mems.

Also please paste the o/p of /dev/cgroup/cpuset.cpus and mems

> [host:~]$ echo 575 > /dev/cgroup/hello/tasks
> [host:~]$ cat /dev/cgroup/hello/tasks
> 575
> [host:~]$ id
> uid=3D0(root) gid=3D0(root) groups=3D0(root)
> [host:~]$
>
> Now, I try to move the task out - the parent/root:
>
> [host:~]$ echo 575 > /dev/cgroup/tasks
> -bash: echo: write error: Operation not permitted

can you send us the o/p of

ls -al /dev/cgroup

and ls -al /dev/cgroup/hello

Balbir
