From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: cgroup tasks file error
Date: Tue, 14 Dec 2010 11:40:40 -0600
Message-ID: <20101214174040.GA4644@peq>
References: <AANLkTi=tpq0Jo9WAd5eu=fP2bLaSG6iLpHtAVR1xe=Ub@mail.gmail.com>
	<166364.22607.qm@web34208.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
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

Quoting ccmail111 (ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org):
> 
> Isn't ns mounted by default ?

I thought that in an earlier email you said you had done

	mount -t cgroup cpuset -ocpuset /dev/cgroup

in which case ns would not be mounted.  But note, we DO NOT
want you to have ns mounted :)

> I rebooted machine,
> based on 2.6.32 kernel.
> 
> Then,
> 
> [host:~]$ mkdir /dev/cgroup
> [host:~]$ mount -t cgroup cpuset -ocpuset,ns /dev/cgroup
> [host:~]$ ps aux | grep libvirt
> root       575  0.6  0.9  88816  2216 ?        Sl   17:28   0:00 myproc --daemon
> root       654  0.0  0.2   4044   664 ttyS0    S+   17:29   0:00 grep libvirt
> [host:~]$ mkdir /dev/cgroup/hello
> [host:~]$ cat /dev/cgroup/hello/tasks
> [host:~]$ echo 0 > /dev/cgroup/hello/cpuset.cpus
> [host:~]$ echo 0 > /dev/cgroup/hello/cpuset.mems
> [host:~]$ echo 575 > /dev/cgroup/hello/tasks
> [host:~]$ cat /dev/cgroup/hello/tasks
> 575
> [host:~]$ id
> uid=0(root) gid=0(root) groups=0(root)
> [host:~]$
> 
> Now, I try to move the task out - the parent/root:
> 
> [host:~]$ echo 575 > /dev/cgroup/tasks
> -bash: echo: write error: Operation not permitted
> 
> 
> Any thoughts !?

Yes, ns cgroup is forbidding you from moving back :)  Mount without it.

-serge
