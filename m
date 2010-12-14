From: ccmail111 <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
Subject: Re: cgroup tasks file error
Date: Mon, 13 Dec 2010 17:27:44 -0800 (PST)
Message-ID: <478892.90636.qm@web34204.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Serge,

Now I cannot move the pid out of the assigned group !

[host:/dev/cgroup]$ cat cpuset.cpus
0
[host:/dev/cgroup]$ cat cpuset.mems
0
[host:/dev/cgroup]$ cat hello/tasks
580

[host:/dev/cgroup]$ echo 580 > tasks
-bash: echo: write error: Operation not permitted

[host:/dev/cgroup]$
[host:/dev/cgroup]$ cd hello
[host:/dev/cgroup/hello]$ cat cpuset.cpus
0
[host:/dev/cgroup/hello]$ cat cpuset.mems
0
[host:/dev/cgroup/hello]



--- On Mon, 12/13/10, ccmail111 <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org> wrote:

> From: ccmail111 <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
> Subject: Re: cgroup tasks file error
> To: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> Date: Monday, December 13, 2010, 8:23 PM
> Hi Serge,
> =

> Thanks for quick response.
> =

> I had mounted as:
> =

>  mount -t cgroup cpuset /dev/cgroup
> =

> After setting below, it works.
> Thank you for helpful tip !
> =

> =

> --- On Mon, 12/13/10, Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> wrote:
> =

> > From: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> > Subject: Re: cgroup tasks file error
> > To: "ccmail111" <ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
> > Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > Date: Monday, December 13, 2010, 6:16 PM
> > Quoting ccmail111 (ccmail111-/E1597aS9LQAvxtiuMwx3w@public.gmane.org):
> > > =

> > > I see error:[host:/dev/cgroup]$ echo 693 >
> > hello-test/tasks
> > > -bash: echo: write error: No space left on
> device
> > > [host:/dev/cgroup]$ pwd/dev/cgroup
> > > =

> > > But the user process is up and running..
> > > =

> > > [host:/dev/cgroup]$ ps aux | grep procroot =A0 =A0
> =A0 =

> > > =

> > > 693 =A00.0 =A00.4 =A034720 =A01112 ttyS0 =A0 =A0Sl =A0
> 19:11
> > =A0 0:00 /opt/bin/myproc -ext
> > > =

> > > Also the cgroup exists and valid..
> > > =

> > > [host:/dev/cgroup]$ ls | grep hello-test
> > > hello-test
> > > =

> > > What above error mean and any suggestions ?
> > > Please email.
> > =

> > Which cgroups do you have composed on that mount?=A0
> I'm
> > guess you
> > have cpuset, and you need to set the cpuset.mems and
> > cpuset.cpus.
> > Until you do that, no tasks can be assigned to it.
> > =

> > -serge
> > =

> =

> =

> =

> =



      =
