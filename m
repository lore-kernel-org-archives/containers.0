From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: Fwd: Re: lxc-performance?
Date: Thu, 14 Oct 2010 19:24:18 +0530
Message-ID: <AANLkTi=vjW+zPGLdLG_wWtkB0eEcKho5L3AU6MTm-D53@mail.gmail.com>
References: <4CAED1CF.6050908@univ-fcomte.fr>
	<20101012140509.0ab6c617.kamezawa.hiroyu@jp.fujitsu.com>
	<4CB708A1.7000403@univ-fcomte.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CB708A1.7000403-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: MALATTAR <mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Oct 14, 2010 at 7:11 PM, MALATTAR
<mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org> wrote:
>
> =A0Le 12/10/2010 07:05, KAMEZAWA Hiroyuki a =E9crit :
> > On Fri, 08 Oct 2010 10:09:51 +0200
> > MALATTAR<mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org> =A0wrote:
> >
> >> Le 07/10/2010 16:43, MALATTAR a =E9crit :
> >>> ---------------------------------------------------------------------=
---
> >>> 06.10.2010 23:41, MALATTAR ?????:
> >>>
> >>>> / =A0the container dora1, where i launch an instance of my IDS, does=
 not take
> >>> />/ =A0more than 70 MB as memory even though the memory limit for it =
is much
> >>> />/ =A0bigger than this value,
> >>> /
> >>> How do you measure memory usage?
> >> by using the command:
> >> lxc-cgroup -n dora1 memory.usage_in_bytes
> >>> =A0 =A0What's in memory.max_usage_in_bytes of
> >>> the container's cgroup?
> >> executing the next command lxc-cgroup -n dora1 memory.max_usage_in_byt=
es
> >> gave me 70193152 bytes
> >>
> > Hmm. what latencytop shows ?
> >
> > You can see this kind of output.
> > =3D=3D
> > Cause =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Maximum =A0 =A0 Percentage
> > Writing a page to disk =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0551.6 msec =A0 =A0 =A0 =A0 36.8 %
> > Fork() system call =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0273.7 msec =A0 =A0 =A0 =A0 =A01.1 %
> > Page fault =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0253.9 msec =A0 =A0 =A0 =A0 29.5 %
> > Writing buffer to disk (synchronous) =A0 =A0 =A0 =A0 =A0 =A0 =A0225.9 m=
sec =A0 =A0 =A0 =A0 =A02.9 %
> > Creating block layer request =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0202.7 msec =A0 =A0 =A0 =A0 17.1 %
> > Walking directory tree =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0161.5 msec =A0 =A0 =A0 =A0 =A01.4 %
> > [congestion_wait] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A097.6 msec =A0 =A0 =A0 =A0 =A04.4 %
> > Executing a program =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A097.1 msec =A0 =A0 =A0 =A0 =A00.3 %
> > synchronous write =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A073.9 msec =A0 =A0 =A0 =A0 =A00.1 %
> > =3D=3D
> >
> > IMHO, if memory limit is the problem, "Page Fault" tend to be big.
> >
> >
> > Thanks,
> > -Kame
> >
> >
> executing latencytop during the execution of my program gave me:
> Cause
> Maximum =A0 =A0 Percentage
> fsync() on a file (type 'F' for details) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A045.1
> msec =A0 =A0 =A0 2.2 %
> Waiting for event (poll) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A05.0
> msec =A0 =A0 =A0 =A0 47.9 %
> Userspace lock contention =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A05.0
> msec =A0 =A0 =A0 =A0 43.1 %
> Waiting for event (select) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A04.8
> msec =A0 =A0 =A0 =A0 =A05.7 %
> Throttling GPU while waiting for commands =A0 =A0 =A0 =A0 3.4 msec =A0 =
=A0 =A0 =A0 =A00.4 %
> [i915_do_wait_request] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 3.3
> msec =A0 =A0 =A0 =A0 =A00.5 %
> Waiting for data on unix socket =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 0.3
> msec =A0 =A0 =A0 =A0 =A00.1 %
> Waiting for TTY data =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00.2
> msec =A0 =A0 =A0 =A0 =A00.1 %
>
> Process mysqld (291) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 Total: =A0 2.3 msec
> Waiting for data on unix socket =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0=
.3 msec =A0 =A0 =A0 =A0100.0 %
>
> It seems that there is no problem...
>
> also memtest command was able to allocate up to 1024MB but it takes a
> long time
> for one loop only ...
> So, i think the problem is in my program not in the container, is not it?

Could you please dump your cgroup filesystem? What is
memory.limit_in_bytes, memory.stat? fysnc() can clearly hold up things
across the filesystem with ext3 and other FS. The source does sound
like mysql database for the frequent fsync's - is that correct? What
does the iotop output look like?

Balbir
