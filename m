From: Kapil Arya <kapil@ccs.neu.edu>
Subject: Re: [Ksummit-2010-discuss] checkpoint-restart: naked patch
Date: Tue, 23 Nov 2010 22:50:44 -0500
Message-ID: <AANLkTinXZ-xO0h7DPB7YrdWhDBNmWM7jg74XT9bWrshK@mail.gmail.com>
References: <4CD72150.9070705@cs.columbia.edu> <4CE3C334.9080401@kernel.org>
 <20101117153902.GA1155@hallyn.com> <4CE3F8D1.10003@kernel.org>
 <20101119041045.GC24031@hallyn.com> <4CE683E1.6010500@kernel.org>
 <4CE69B8C.6050606@cs.columbia.edu> <Pine.LNX.4.64.1011201312470.15662@takamine.ncl.cs.columbia.edu>
 <4CE8228C.3000108@kernel.org> <20101121081853.GA21672@sundance.ccs.neu.edu>
 <20101121082143.GB21672@sundance.ccs.neu.edu> <Pine.LNX.4.64.1011231234410.11731@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.1011231234410.11731@takamine.ncl.cs.columbia.edu>
Sender: linux-kernel-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Gene Cooperman <gene@ccs.neu.edu>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, xemul@sw.ru, "Eric W. Biederman" <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

(Our first comment below actually replies to an earlier post by Oren. I=
t seemed
simpler to combine our comments.)

> > d. =A0screen and other full-screen text programs These are not the =
only
> > examples of difficult interactions with the rest of the world.
>
> This actually never required a userspace "component" with Zap or linu=
x-cr (to
> the best of my knowledge).

We would guess that Zap would not be able to support screen without a u=
ser
space component. The bug occurs when screen is configured to have a sta=
tus line
at the bottom. We would be interested if you want to try it and let us =
know the
results.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

> > > category =A0 =A0 =A0 =A0linux-cr
> > > userspace
> > > -----------------------------------------------------------------=
---------------
> > > PERFORMANCE =A0 =A0 has _zero_ runtime overhead =A0 =A0 visible o=
verhead due to
> > > syscalls interposition and state tracking even w/o checkpoints;
> >
> > In our experiments so far, the overhead of system calls has been
> > unmeasurable. =A0We never wrap read() or write(), in order to keep =
overhead
> > low. =A0We also never wrap pthread synchronization primitives such =
as locks,
> > for the same reason. =A0The other system calls are used much less o=
ften, and
> > so the overhead has been too small to measure in our experiments.
>
> Syscall interception will have visible effect on applications that us=
e those
> syscalls. You may not observe overheasd with HPC ones, but do you hav=
e
> numbers on server apps ? =A0apps that use fork/clone and pipes extens=
ively ?
> threads benchmarks et ? =A0compare that to aboslute zero overhead of =
linux-cr.

Its true that we haven't taken serious data on overhead with server app=
s. Is
there a particular server app that you are thinking of as an example? I=
 would
expect fork/clone and pipes to be invoked infrequently in the server ap=
ps and do
not add measurably to CPU time. In most server apps such as MySQL, it i=
s
common to maintain a pool of threads for reuse rather than to repeatedl=
y call
clone for a new thread. This is done to ensure that the overhead of the=
 clone
calls is not significant. I would expect a similar policy for fork and =
pipes.

<snip>

> > > OPERATION =A0 =A0 =A0 applications run unmodified =A0 =A0 to do c=
/r, needs
> > > 'controller' task (launch and manage _entire_ execution) - point =
of
> > > failure. =A0restricts how a system is used.
> >
> > We'd like to clarify what may be some misconceptions. =A0The DMTCP =
controller
> > does not launch or manage any tasks. =A0The DMTCP controller is sta=
teless,
> > and is only there to provide a barrier, namespace server, and singl=
e point
> > of contact to relay ckpt/restart commands. =A0Recall that the DMTCP
> > controller handls processes across hosts --- not just on a single h=
ost.
>
> The controller is another point of failure. I already pointed that th=
e
> (controlled) application crashes when your controller dies, and you m=
entioned
> it's a bug that should be fixed. But then there will always be a risk=
 for
> another, and another ... =A0 You also mentioned that if the controlle=
r dies,
> then the app should contionue to run, but will not be checkpointable =
anymore
> (IIUC).
>
> The point is, that the controller is another point of failure, and ma=
kes the
> execution/checkpoint intrusive. It also adds security and user-manage=
ment
> issues as you'll need one (or more ?) controller per user (right now,=
 it's
> one for all, no ?). and so on.

Just to clarify, DMTCP uses one coordinator for each checkpointable
computation. A single user may be running multiple computations with on=
e
coordinator for each computation. We don't actually use the word contro=
ller
in DMTCP terminology because the coordinator is stateless and so in
coordinating but not controlling other processes.

> Plus, because the restarted apps get their virtualized IDs from the
> controller, then they can't now "see" existing/new processes that may=
 get the
> "same" pids (virtualization is not in the kernel).

This appears to be a misconception. The wrappers within the user proces=
s
maintain the pid-translation table for that process. The translation ta=
ble is
the translation between the original pid given by the kernel and the cu=
rrent
pid set by the kernel on restart. This is handled locally and does not =
involve
the coordinator.

In the case of a fork there could be a pid-clash (the original pid
generated for a
new process that conflicts with someone else's original pid). However, =
DMTCP
handles this by checking within the fork wrapper for a pid-clash. In th=
e rare
case of a pid-clash, the child process exits and the parent forks again=
=2E Same
applies for clone and any pid clash at restart time.

> > =A0 =A0 Also, in any computation involving multiple processes, _eve=
ry_ process
> > =A0 =A0 of the computation is a point of failure. =A0If any process=
 of the
> > =A0 =A0 computation dies, then the simple application strategy is t=
o give up
> > =A0 =A0 and revert to an earlier checkpoint. =A0There are technique=
s by which an
> > =A0 =A0 app or DMTCP can recreate certain failed processes. =A0DMTC=
P doesn't
> > =A0 =A0 currently recreate a dead controller (no demand for it), bu=
t it's not
> > =A0 =A0 hard to do technically.
>
> The point is that you _add_ a point of failure: you make the "checkpo=
int"
> operation a possible reason for the application to crash. In contrast=
, in
> linux-cr the checkpoiint is idempotent - nunharmful because it does n=
ot make
> the applications execute. Instead, it merely observes their state.

We were speaking above of the case when the process dies during a
computation. We were not referring to checkpoint time.

<snip>

We would like to add our own comment/question. To set the context we qu=
ote an
earlier post:

OL> Even if it did - the question is not how to deal with "glue"
OL> (you demonstrated quite well how to do that with DMTCP), but
OL> how should teh basic, core c/r functionality work - which is
OL> below, and orthogonal to the "glue".

There seems to be an implicit assumption that it is easy to separate th=
e DMTCP
"glue code" from the DMTCP C/R engine as separate modules. DMTCP is mod=
ular but
it splits the problems into modules along a different line than Linux C=
/R. We
look forward to the joint experiment in which we would try to combine D=
MTCP
with Linux C/R. This will help answer the question in our mind.

In order to explore the issue, let's imagine that we have a successful =
merge of
DMTCP and Linux C/R. The following are some user-space glue issues. It'=
s not
obvious to us how the merged software will handle these issues.

1. Sockets -- DMTCP handles all sockets in a common manner through a si=
ngle
module. Sockets are checkpointed independently of whether they are loca=
l or
remote. In a merger of DMTCP and Linux C/R, what does Linux C/R do when=
 it sees
remote sockets? Or should DMTCP take down all remote sockets before
checkpointing? If DMTCP has to do this, it would be less efficient than=
 the
current design which keeps the remote sockets connections alive during
checkpoint.

2. XLib and X11-server -- Consider checkpointing a single X11 app witho=
ut the
X11-server and without VNC. This is something we intend to add to DMTCP=
 in the
next few months. We have already mapped out the design in our minds. An=
 X11
application includes the Xlib library. The data of an X11 window is, by
default, contained in the X11 library -- not in the X11-server. The app=
lication
communicates with the X11-server using socket connections, which would =
be
considered a leak by Linux C/R. At restart time, DMTCP will ask the
X11-server to create a bare window and then make the appropriate Xlib c=
all to
repaint the window based on the data stored in the Xlib =A0library.
=46or checkpoint/resume, the window stays up and does not has to be rep=
ainted.
How will the combined DMTCP/Linux C/R work? Will DMTCP have to take
down the window prior to Linux C/R and paint a new window at resume tim=
e?
Doesn't this add inefficiency?

3. Checkpointing a single process (e.g. a bash shell) talking to an xte=
rm via
a pty -- We assume that from the viewpoint of Linux C/R a pty is a leak=
 since
there is a second process operating the master end of the pty. In this
case we are
guessing that Linux C/R would checkpoint and restart without the gurant=
ees of
reliability. We are guessing that Linux C/R would not save and restore =
the pty,
instead it would be the responsibility of DMTCP to restore the current =
settings
of the pty (e.g. packet mode vs. regular mode). Is our understanding co=
rrect?
Would this work?

Thanks,
Gene and Kapil
