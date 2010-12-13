From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: cgroup tasks file error
Date: Mon, 13 Dec 2010 17:16:28 -0600
Message-ID: <20101213231628.GA8624@hallyn.com>
References: <149701.57773.qm@web34208.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <149701.57773.qm-VjZBGxy5l2evuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
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
> =

> I see error:[host:/dev/cgroup]$ echo 693 > hello-test/tasks
> -bash: echo: write error: No space left on device
> [host:/dev/cgroup]$ pwd/dev/cgroup
> =

> But the user process is up and running..
> =

> [host:/dev/cgroup]$ ps aux | grep procroot =A0 =A0 =A0 =

> =

> 693 =A00.0 =A00.4 =A034720 =A01112 ttyS0 =A0 =A0Sl =A0 19:11 =A0 0:00 /op=
t/bin/myproc -ext
> =

> Also the cgroup exists and valid..
> =

> [host:/dev/cgroup]$ ls | grep hello-test
> hello-test
> =

> What above error mean and any suggestions ?
> Please email.

Which cgroups do you have composed on that mount?  I'm guess you
have cpuset, and you need to set the cpuset.mems and cpuset.cpus.
Until you do that, no tasks can be assigned to it.

-serge
