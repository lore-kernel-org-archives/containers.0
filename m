From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: For review: pid_namespaces(7) man page (draft 2)
Date: Tue, 12 Mar 2013 08:07:30 +0100
Message-ID: <CAKgNAkgAT8vFr7hbEzOjJG5pCt8-kh_4Wh9yrzHHXrCJ3Fhh+w__44462.1955547065$1363072104$gmane$org@mail.gmail.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=bcaec52e58bfa2cd9304d7b4f27b
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

--bcaec52e58bfa2cd9304d7b4f27b
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Eric et al.,

[CCing Li because of reboot(2) changes]

I have (I think) addressed all previous comments in the current draft
of the pid_namespaces(7) page. This is a final sanity check before I
call this page complete (modulo any future kernel changes).

The attached page aims to provide a fairly complete overview of PID
namespaces. I'm looking for review comments (corrections,
improvements, additions, etc.) on this page. I've provided it in two
forms inline below, and reviewers can comment comment on whichever
form they are most comfortable with:

1) The rendered page as plain text
2) The *roff source (also attached); rendering that source will enable
readers to see proper formatting for the page.

Note that the namespaces(7) page referred to in this page is not yet
finished; I'll send it out for review at a future time.

Thanks,

Michael

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

PID_NAMESPACES(7)      Linux Programmer's Manual     PID_NAMESPACES(7)



NAME
       pid_namespaces - overview of Linux PID namespaces

DESCRIPTION
       For an overview of namespaces, see namespaces(7).

       PID  namespaces  isolate  the  process ID number space, meaning
       that processes in different PID namespaces can  have  the  same
       PID.   PID namespaces allow containers to provide functionality
       such as suspending/resuming the set of processes  in  the  con=E2=80=
=90
       tainer and migrating the container to a new host while the pro=E2=80=
=90
       cesses inside the container maintain the same PIDs.

       PIDs in a new PID namespace start at 1, somewhat like a  stand=E2=80=
=90
       alone  system, and calls to fork(2), vfork(2), or clone(2) will
       produce processes with PIDs that are unique within  the  names=E2=80=
=90
       pace.

       Use of PID namespaces requires a kernel that is configured with
       the CONFIG_PID_NS option.

   The namespace init process
       The first process created in a new namespace (i.e., the process
       created using clone(2) with the CLONE_NEWPID flag, or the first
       child created by a process after a call to unshare(2) using the
       CLONE_NEWPID flag) has the PID 1, and is the "init" process for
       the namespace (see init(1)).  A child process that is  orphaned
       within  the namespace will be reparented to this process rather
       than init(1) (unless one of the ancestors of the child
        in   the   same   PID   namespace   employed   the    prctl(2)
       PR_GET_CHILD_SUBREAPER  command to mark itself as the reaper of
       orphaned descendant processes).

       If the "init" process of a PID namespace terminates, the kernel
       terminates  all of the processes in the namespace via a SIGKILL
       signal.  This  behavior  reflects  the  fact  that  the  "init"
       process  is essential for the correct operation of a PID names=E2=80=
=90
       pace.  In this case, a subsequent fork(2) into this PID  names=E2=80=
=90
       pace  will  fail  with  the error ENOMEM; it is not possible to
       create a new processes in a PID namespace whose "init"  process
       has  terminated.  Such scenarios can occur when, for example, a
       process uses an open file descriptor for  a  /proc/[pid]/ns/pid
       file  corresponding  to  a  process  that was in a namespace to
       setns(2) into that namespace after the "init" process has  ter=E2=80=
=90
       minated.   Another  possible scenario can occur after a call to
       unshare(2): if  the  first  child  subsequently  created  by  a
       fork(2)  terminates, then subsequent calls to fork(2) will fail
       with ENOMEM.

       Only signals for which the "init"  process  has  established  a
       signal  handler can be sent to the "init" process by other mem=E2=80=
=90
       bers of the PID namespace.  This restriction  applies  even  to
       privileged  processes,  and  prevents  other members of the PID
       namespace from accidentally killing the "init" process.

       Likewise, a process in an ancestor namespace can=E2=80=94subject to =
the
       usual  permission  checks  described in kill(2)=E2=80=94send signals=
 to
       the "init" process of a child PID namespace only if the  "init"
       process has established a handler for that signal.  (Within the
       handler, the siginfo_t si_pid field described  in  sigaction(2)
       will  be  zero.)  SIGKILL or SIGSTOP are treated exceptionally:
       these signals are forcibly delivered when sent from an ancestor
       PID  namespace.   Neither of these signals can be caught by the
       "init" process, and so will result in the usual actions associ=E2=80=
=90
       ated with those signals (respectively, terminating and stopping
       the process).

       Starting with Linux 3.9, the reboot(2) system causes  a  signal
       to  be sent to the namespace "init" process.  See reboot(2) for
       more details.

   Nesting PID namespaces
       PID namespaces can be nested: each PID namespace has a  parent,
       except for the initial ("root") PID namespace.  The parent of a
       PID namespace is the PID namespace of the process that  created
       the  namespace  using  clone(2)  or unshare(2).  PID namespaces
       thus form a tree, with all namespaces ultimately tracing  their
       ancestry to the root namespace.

       A  process  is visible to other processes in its PID namespace,
       and to the processes in  each  direct  ancestor  PID  namespace
       going  back to the root PID namespace.  In this context, "visi=E2=80=
=90
       ble" means that one process can be the target of operations  by
       another  process  using system calls that specify a process ID.
       Conversely, the processes in a child PID  namespace  can't  see
       processes in the parent and further removed ancestor namespace.
       More succinctly: a process can see  (e.g.,  send  signals  with
       kill(2),  set  nice values with setpriority(2), etc.) only pro=E2=80=
=90
       cesses contained in its own PID namespace and in descendants of
       that namespace.

       A  process  has one process ID in each of the layers of the PID
       namespace hierarchy in  which  is  visible,  and  walking  back
       though  each  direct ancestor namespace through to the root PID
       namespace.  System calls that operate  on  process  IDs  always
       operate  using the process ID that is visible in the PID names=E2=80=
=90
       pace of the caller.  A call to getpid(2) always returns the PID
       associated with the namespace in which the process was created.

       Some  processes  in  a  PID namespace may have parents that are
       outside of the namespace.  For example, the parent of the  ini=E2=80=
=90
       tial  process  in the namespace (i.e., the init(1) process with
       PID 1) is necessarily  in  another  namespace.   Likewise,  the
       direct  children  of  a process that uses setns(2) to cause its
       children to join a PID namespace are in a different PID  names=E2=80=
=90
       pace from the caller of setns(2).  Calls to getppid(2) for such
       processes return 0.

   setns(2) and unshare(2) semantics
       Calls to setns(2) that specify a PID namespace file  descriptor
       and  calls to unshare(2) with the CLONE_NEWPID flag cause chil=E2=80=
=90
       dren subsequently created by the caller to be placed in a  dif=E2=80=
=90
       ferent PID namespace from the caller.  These calls do not, how=E2=80=
=90
       ever, change the PID namespace of the calling process,  because
       doing  so  would  change  the  caller's idea of its own PID (as
       reported by getpid()), which would break many applications  and
       libraries.

       To put things another way: a process's PID namespace membership
       is determined when the process is created and cannot be changed
       thereafter.   Among  other things, this means that the parental
       relationship between processes mirrors the  parental  relation=E2=80=
=90
       ship  between PID namespaces: the parent of a process is either
       in the same namespace or resides in the  immediate  parent  PID
       namespace.

   Compatibility of CLONE_NEWPID with other CLONE_* flags
       CLONE_NEWPID can't be combined with some other CLONE_* flags:

       *  CLONE_THREAD  requires  being  in  the same PID namespace in
          order that that the threads in a process can send signals to
          each  other.   Similarly,  it must be possible to see all of
          the threads of a processes in the proc(5) file system.

       *  CLONE_SIGHAND requires being in the same PID namespace; oth=E2=80=
=90
          erwise  the process ID of the process sending a signal could
          not be meaningfully encoded when a signal is sent  (see  the
          description  of the siginfo_t type in sigaction(2)).  A sig=E2=80=
=90
          nal queue shared by processes  in  multiple  PID  namespaces
          will defeat that.

       *  CLONE_VM  requires  all of the threads to be in the same PID
          namespace, because, from the point of view of a  core  dump,
          if  two  processes  share  the  same  address space they are
          threads and will be core dumped together.  When a core  dump
          is  written, the PID of each thread is written into the core
          dump.  Writing the process IDs could not  meaningfully  suc=E2=80=
=90
          ceed  if some of the process IDs were in a parent PID names=E2=80=
=90
          pace.

       To summarize: there is a  technical  requirement  for  each  of
       CLONE_THREAD, CLONE_SIGHAND, and CLONE_VM to share a PID names=E2=80=
=90
       pace.  (Note furthermore that in clone(2) requires CLONE_VM  to
       be  specified  if  CLONE_THREAD or CLONE_SIGHAND is specified.)
       Thus, call sequences such as the following will fail (with  the
       error EINVAL):

           unshare(CLONE_NEWPID);
           clone(..., CLONE_VM, ...);    /* Fails */

           setns(fd, CLONE_NEWPID);
           clone(..., CLONE_VM, ...);    /* Fails */

           clone(..., CLONE_VM, ...);
           setns(fd, CLONE_NEWPID);      /* Fails */

           clone(..., CLONE_VM, ...);
           unshare(CLONE_NEWPID);        /* Fails */

   /proc and PID namespaces
       A  /proc  file system shows (in the /proc/PID directories) only
       processes visible in the PID namespace of the process that per=E2=80=
=90
       formed  the mount, even if the /proc file system is viewed from
       processes in other namespaces.

       After creating a new PID namespace, it is useful for the  child
       to change its root directory and mount a new procfs instance at
       /proc so that tools such as ps(1) work  correctly.   If  a  new
       mount   namespace   is   simultaneously  created  by  including
       CLONE_NEWNS in the flags argument of  clone(2)  or  unshare(2),
       then  it  isn't  necessary  to change the root directory: a new
       procfs instance can be mounted directly over /proc.

       From a shell, the command to mount /proc is:

           $ mount -t proc proc /proc

       Calling readlink(2) on the path /proc/self yields  the  process
       ID  of  the  caller  in  the  PID namespace of the procfs mount
       (i.e., the PID  namespace  of  the  process  that  mounted  the
       procfs).  This can be useful for introspection purposes, when a
       process wants to discover its PID in other namespaces.

   Miscellaneous
       When a process ID is passed over a  UNIX  domain  socket  to  a
       process  in  a  different PID namespace (see the description of
       SCM_CREDENTIALS in unix(7)), it is translated into  the  corre=E2=80=
=90
       sponding PID value in the receiving process's PID namespace.

CONFORMING TO
       Namespaces are a Linux-specific feature.

EXAMPLE
       See user_namespaces(7).

SEE ALSO
       clone(2),  setns(2), unshare(2), proc(5), credentials(7), capa=E2=80=
=90
       bilities(7), user_namespaces(7), switch_root(8)



Linux                         2013-01-14             PID_NAMESPACES(7)


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D *roff source =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

$ cat pid_namespaces.7
.\" Copyright (c) 2013 by Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
.\" and Copyright (c) 2012 by Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
.\"
.\" Permission is granted to make and distribute verbatim copies of this
.\" manual provided the copyright notice and this permission notice are
.\" preserved on all copies.
.\"
.\" Permission is granted to copy and distribute modified versions of this
.\" manual under the conditions for verbatim copying, provided that the
.\" entire resulting derived work is distributed under the terms of a
.\" permission notice identical to this one.
.\"
.\" Since the Linux kernel and libraries are constantly changing, this
.\" manual page may be incorrect or out-of-date.  The author(s) assume no
.\" responsibility for errors or omissions, or for damages resulting from
.\" the use of the information contained herein.  The author(s) may not
.\" have taken the same level of care in the production of this manual,
.\" which is licensed free of charge, as they might when working
.\" professionally.
.\"
.\" Formatted or processed versions of this manual, if unaccompanied by
.\" the source, must acknowledge the copyright and authors of this work.
.\"
.\"
.TH PID_NAMESPACES 7 2013-01-14 "Linux" "Linux Programmer's Manual"
.SH NAME
pid_namespaces \- overview of Linux PID namespaces
.SH DESCRIPTION
For an overview of namespaces, see
.BR namespaces (7).

PID namespaces isolate the process ID number space,
meaning that processes in different PID namespaces can have the same PID.
PID namespaces allow containers to provide functionality
such as suspending/resuming the set of processes in the container and
migrating the container to a new host
while the processes inside the container maintain the same PIDs.

PIDs in a new PID namespace start at 1,
somewhat like a standalone system, and calls to
.BR fork (2),
.BR vfork (2),
or
.BR clone (2)
will produce processes with PIDs that are unique within the namespace.

Use of PID namespaces requires a kernel that is configured with the
.B CONFIG_PID_NS
option.
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS The namespace "init" process
The first process created in a new namespace
(i.e., the process created using
.BR clone (2)
with the
.BR CLONE_NEWPID
flag, or the first child created by a process after a call to
.BR unshare (2)
using the
.BR CLONE_NEWPID
flag) has the PID 1, and is the "init" process for the namespace (see
.BR init (1)).
A child process that is orphaned within the namespace will be reparented
to this process rather than
.BR init (1)
(unless one of the ancestors of the child
 in the same PID namespace employed the
.BR prctl (2)
.B PR_GET_CHILD_SUBREAPER
command to mark itself as the reaper of orphaned descendant processes).

If the "init" process of a PID namespace terminates,
the kernel terminates all of the processes in the namespace via a
.BR SIGKILL
signal.
This behavior reflects the fact that the "init" process
is essential for the correct operation of a PID namespace.
In this case, a subsequent
.BR fork (2)
into this PID namespace will fail with the error
.BR ENOMEM ;
it is not possible to create a new processes in a PID namespace whose "init=
"
process has terminated.
Such scenarios can occur when, for example,
a process uses an open file descriptor for a
.I /proc/[pid]/ns/pid
file corresponding to a process that was in a namespace to
.BR setns (2)
into that namespace after the "init" process has terminated.
Another possible scenario can occur after a call to
.BR unshare (2):
if the first child subsequently created by a
.BR fork (2)
terminates, then subsequent calls to
.BR fork (2)
will fail with
.BR ENOMEM .

Only signals for which the "init" process has established a signal handler
can be sent to the "init" process by other members of the PID namespace.
This restriction applies even to privileged processes,
and prevents other members of the PID namespace from
accidentally killing the "init" process.

Likewise, a process in an ancestor namespace
can\(emsubject to the usual permission checks described in
.BR kill (2)\(emsend
signals to the "init" process of a child PID namespace only
if the "init" process has established a handler for that signal.
(Within the handler, the
.I siginfo_t
.I si_pid
field described in
.BR sigaction (2)
will be zero.)
.B SIGKILL
or
.B SIGSTOP
are treated exceptionally:
these signals are forcibly delivered when sent from an ancestor PID namespa=
ce.
Neither of these signals can be caught by the "init" process,
and so will result in the usual actions associated with those signals
(respectively, terminating and stopping the process).

Starting with Linux 3.9, the
.BR reboot (2)
system causes a signal to be sent to the namespace "init" process.
See
.BR reboot(2)
for more details.
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS Nesting PID namespaces
PID namespaces can be nested:
each PID namespace has a parent,
except for the initial ("root") PID namespace.
The parent of a PID namespace is the PID namespace of the process that
created the namespace using
.BR clone (2)
or
.BR unshare (2).
PID namespaces thus form a tree,
with all namespaces ultimately tracing their ancestry to the root namespace=
.

A process is visible to other processes in its PID namespace,
and to the processes in each direct ancestor PID namespace
going back to the root PID namespace.
In this context, "visible" means that one process
can be the target of operations by another process using
system calls that specify a process ID.
Conversely, the processes in a child PID namespace can't see
processes in the parent and further removed ancestor namespace.
More succinctly: a process can see (e.g., send signals with
.BR kill(2),
set nice values with
.BR setpriority (2),
etc.) only processes contained in its own PID namespace
and in descendants of that namespace.

A process has one process ID in each of the layers of the PID
namespace hierarchy in which is visible,
and walking back though each direct ancestor namespace
through to the root PID namespace.
System calls that operate on process IDs always
operate using the process ID that is visible in the
PID namespace of the caller.
A call to
.BR getpid (2)
always returns the PID associated with the namespace in which
the process was created.

Some processes in a PID namespace may have parents
that are outside of the namespace.
For example, the parent of the initial process in the namespace
(i.e., the
.BR init (1)
process with PID 1) is necessarily in another namespace.
Likewise, the direct children of a process that uses
.BR setns (2)
to cause its children to join a PID namespace are in a different
PID namespace from the caller of
.BR setns (2).
Calls to
.BR getppid (2)
for such processes return 0.
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS setns(2) and unshare(2) semantics
Calls to
.BR setns (2)
that specify a PID namespace file descriptor
and calls to
.BR unshare (2)
with the
.BR CLONE_NEWPID
flag cause children subsequently created
by the caller to be placed in a different PID namespace from the caller.
These calls do not, however,
change the PID namespace of the calling process,
because doing so would change the caller's idea of its own PID
(as reported by
.BR getpid ()),
which would break many applications and libraries.

To put things another way:
a process's PID namespace membership is determined when the process is crea=
ted
and cannot be changed thereafter.
Among other things, this means that the parental relationship
between processes mirrors the parental relationship between PID namespaces:
the parent of a process is either in the same namespace
or resides in the immediate parent PID namespace.
.SS Compatibility of CLONE_NEWPID with other CLONE_* flags
.BR CLONE_NEWPID
can't be combined with some other
.BR CLONE_*
flags:
.IP * 3
.B CLONE_THREAD
requires being in the same PID namespace in order that that
the threads in a process can send signals to each other.
Similarly, it must be possible to see all of the threads
of a processes in the
.BR proc (5)
file system.
.IP *
.BR CLONE_SIGHAND
requires being in the same PID namespace;
otherwise the process ID of the process sending a signal
could not be meaningfully encoded when a signal is sent
(see the description of the
.I siginfo_t
type in
.BR sigaction (2)).
A signal queue shared by processes in multiple PID namespaces
will defeat that.
.IP *
.BR CLONE_VM
requires all of the threads to be in the same PID namespace,
because, from the point of view of a core dump,
if two processes share the same address space they are threads and will
be core dumped together.
When a core dump is written, the PID of each
thread is written into the core dump.
Writing the process IDs could not meaningfully succeed
if some of the process IDs were in a parent PID namespace.
.PP
To summarize: there is a technical requirement for each of
.BR CLONE_THREAD ,
.BR CLONE_SIGHAND ,
and
.BR CLONE_VM
to share a PID namespace.
(Note furthermore that in
.BR clone (2)
requires
.BR CLONE_VM
to be specified if
.BR CLONE_THREAD
or
.BR CLONE_SIGHAND
is specified.)
Thus, call sequences such as the following will fail (with the error
.BR EINVAL ):

.nf
    unshare(CLONE_NEWPID);
    clone(..., CLONE_VM, ...);    /* Fails */

    setns(fd, CLONE_NEWPID);
    clone(..., CLONE_VM, ...);    /* Fails */

    clone(..., CLONE_VM, ...);
    setns(fd, CLONE_NEWPID);      /* Fails */

    clone(..., CLONE_VM, ...);
    unshare(CLONE_NEWPID);        /* Fails */
.fi
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS /proc and PID namespaces
A
.I /proc
file system shows (in the
.I /proc/PID
directories) only processes visible in the PID namespace
of the process that performed the mount, even if the
.I /proc
file system is viewed from processes in other namespaces.

After creating a new PID namespace,
it is useful for the child to change its root directory
and mount a new procfs instance at
.I /proc
so that tools such as
.BR ps (1)
work correctly.
If a new mount namespace is simultaneously created by including
.BR CLONE_NEWNS
in the
.IR flags
argument of
.BR clone (2)
or
.BR unshare (2),
then it isn't necessary to change the root directory:
a new procfs instance can be mounted directly over
.IR /proc .

From a shell, the command to mount
.I /proc
is:

    $ mount -t proc proc /proc

Calling
.BR readlink (2)
on the path
.I /proc/self
yields the process ID of the caller in the PID namespace of the procfs moun=
t
(i.e., the PID namespace of the process that mounted the procfs).
This can be useful for introspection purposes,
when a process wants to discover its PID in other namespaces.
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS Miscellaneous
When a process ID is passed over a UNIX domain socket to a
process in a different PID namespace (see the description of
.B SCM_CREDENTIALS
in
.BR unix (7)),
it is translated into the corresponding PID value in
the receiving process's PID namespace.
.SH CONFORMING TO
Namespaces are a Linux-specific feature.
.SH EXAMPLE
See
.BR user_namespaces (7).
.SH SEE ALSO
.BR clone (2),
.BR setns (2),
.BR unshare (2),
.BR proc (5),
.BR credentials (7),
.BR capabilities (7),
.BR user_namespaces (7),
.BR switch_root (8)

--bcaec52e58bfa2cd9304d7b4f27b
Content-Type: application/octet-stream; name="pid_namespaces.7"
Content-Disposition: attachment; filename="pid_namespaces.7"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_he6pv9pi0

LlwiIENvcHlyaWdodCAoYykgMjAxMyBieSBNaWNoYWVsIEtlcnJpc2sgPG10ay5tYW5wYWdlc0Bn
bWFpbC5jb20+Ci5cIiBhbmQgQ29weXJpZ2h0IChjKSAyMDEyIGJ5IEVyaWMgVy4gQmllZGVybWFu
IDxlYmllZGVybUB4bWlzc2lvbi5jb20+Ci5cIgouXCIgUGVybWlzc2lvbiBpcyBncmFudGVkIHRv
IG1ha2UgYW5kIGRpc3RyaWJ1dGUgdmVyYmF0aW0gY29waWVzIG9mIHRoaXMKLlwiIG1hbnVhbCBw
cm92aWRlZCB0aGUgY29weXJpZ2h0IG5vdGljZSBhbmQgdGhpcyBwZXJtaXNzaW9uIG5vdGljZSBh
cmUKLlwiIHByZXNlcnZlZCBvbiBhbGwgY29waWVzLgouXCIKLlwiIFBlcm1pc3Npb24gaXMgZ3Jh
bnRlZCB0byBjb3B5IGFuZCBkaXN0cmlidXRlIG1vZGlmaWVkIHZlcnNpb25zIG9mIHRoaXMKLlwi
IG1hbnVhbCB1bmRlciB0aGUgY29uZGl0aW9ucyBmb3IgdmVyYmF0aW0gY29weWluZywgcHJvdmlk
ZWQgdGhhdCB0aGUKLlwiIGVudGlyZSByZXN1bHRpbmcgZGVyaXZlZCB3b3JrIGlzIGRpc3RyaWJ1
dGVkIHVuZGVyIHRoZSB0ZXJtcyBvZiBhCi5cIiBwZXJtaXNzaW9uIG5vdGljZSBpZGVudGljYWwg
dG8gdGhpcyBvbmUuCi5cIgouXCIgU2luY2UgdGhlIExpbnV4IGtlcm5lbCBhbmQgbGlicmFyaWVz
IGFyZSBjb25zdGFudGx5IGNoYW5naW5nLCB0aGlzCi5cIiBtYW51YWwgcGFnZSBtYXkgYmUgaW5j
b3JyZWN0IG9yIG91dC1vZi1kYXRlLiAgVGhlIGF1dGhvcihzKSBhc3N1bWUgbm8KLlwiIHJlc3Bv
bnNpYmlsaXR5IGZvciBlcnJvcnMgb3Igb21pc3Npb25zLCBvciBmb3IgZGFtYWdlcyByZXN1bHRp
bmcgZnJvbQouXCIgdGhlIHVzZSBvZiB0aGUgaW5mb3JtYXRpb24gY29udGFpbmVkIGhlcmVpbi4g
IFRoZSBhdXRob3IocykgbWF5IG5vdAouXCIgaGF2ZSB0YWtlbiB0aGUgc2FtZSBsZXZlbCBvZiBj
YXJlIGluIHRoZSBwcm9kdWN0aW9uIG9mIHRoaXMgbWFudWFsLAouXCIgd2hpY2ggaXMgbGljZW5z
ZWQgZnJlZSBvZiBjaGFyZ2UsIGFzIHRoZXkgbWlnaHQgd2hlbiB3b3JraW5nCi5cIiBwcm9mZXNz
aW9uYWxseS4KLlwiCi5cIiBGb3JtYXR0ZWQgb3IgcHJvY2Vzc2VkIHZlcnNpb25zIG9mIHRoaXMg
bWFudWFsLCBpZiB1bmFjY29tcGFuaWVkIGJ5Ci5cIiB0aGUgc291cmNlLCBtdXN0IGFja25vd2xl
ZGdlIHRoZSBjb3B5cmlnaHQgYW5kIGF1dGhvcnMgb2YgdGhpcyB3b3JrLgouXCIKLlwiCi5USCBQ
SURfTkFNRVNQQUNFUyA3IDIwMTMtMDEtMTQgIkxpbnV4IiAiTGludXggUHJvZ3JhbW1lcidzIE1h
bnVhbCIKLlNIIE5BTUUKcGlkX25hbWVzcGFjZXMgXC0gb3ZlcnZpZXcgb2YgTGludXggUElEIG5h
bWVzcGFjZXMKLlNIIERFU0NSSVBUSU9OCkZvciBhbiBvdmVydmlldyBvZiBuYW1lc3BhY2VzLCBz
ZWUKLkJSIG5hbWVzcGFjZXMgKDcpLgoKUElEIG5hbWVzcGFjZXMgaXNvbGF0ZSB0aGUgcHJvY2Vz
cyBJRCBudW1iZXIgc3BhY2UsCm1lYW5pbmcgdGhhdCBwcm9jZXNzZXMgaW4gZGlmZmVyZW50IFBJ
RCBuYW1lc3BhY2VzIGNhbiBoYXZlIHRoZSBzYW1lIFBJRC4KUElEIG5hbWVzcGFjZXMgYWxsb3cg
Y29udGFpbmVycyB0byBwcm92aWRlIGZ1bmN0aW9uYWxpdHkKc3VjaCBhcyBzdXNwZW5kaW5nL3Jl
c3VtaW5nIHRoZSBzZXQgb2YgcHJvY2Vzc2VzIGluIHRoZSBjb250YWluZXIgYW5kCm1pZ3JhdGlu
ZyB0aGUgY29udGFpbmVyIHRvIGEgbmV3IGhvc3QKd2hpbGUgdGhlIHByb2Nlc3NlcyBpbnNpZGUg
dGhlIGNvbnRhaW5lciBtYWludGFpbiB0aGUgc2FtZSBQSURzLgoKUElEcyBpbiBhIG5ldyBQSUQg
bmFtZXNwYWNlIHN0YXJ0IGF0IDEsCnNvbWV3aGF0IGxpa2UgYSBzdGFuZGFsb25lIHN5c3RlbSwg
YW5kIGNhbGxzIHRvCi5CUiBmb3JrICgyKSwKLkJSIHZmb3JrICgyKSwKb3IKLkJSIGNsb25lICgy
KQp3aWxsIHByb2R1Y2UgcHJvY2Vzc2VzIHdpdGggUElEcyB0aGF0IGFyZSB1bmlxdWUgd2l0aGlu
IHRoZSBuYW1lc3BhY2UuCgpVc2Ugb2YgUElEIG5hbWVzcGFjZXMgcmVxdWlyZXMgYSBrZXJuZWwg
dGhhdCBpcyBjb25maWd1cmVkIHdpdGggdGhlCi5CIENPTkZJR19QSURfTlMKb3B0aW9uLgouXCIK
LlwiID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PQouXCIKLlNTIFRoZSBuYW1lc3BhY2UgImluaXQiIHByb2Nlc3MKVGhlIGZpcnN0IHBy
b2Nlc3MgY3JlYXRlZCBpbiBhIG5ldyBuYW1lc3BhY2UKKGkuZS4sIHRoZSBwcm9jZXNzIGNyZWF0
ZWQgdXNpbmcKLkJSIGNsb25lICgyKQp3aXRoIHRoZQouQlIgQ0xPTkVfTkVXUElECmZsYWcsIG9y
IHRoZSBmaXJzdCBjaGlsZCBjcmVhdGVkIGJ5IGEgcHJvY2VzcyBhZnRlciBhIGNhbGwgdG8KLkJS
IHVuc2hhcmUgKDIpCnVzaW5nIHRoZQouQlIgQ0xPTkVfTkVXUElECmZsYWcpIGhhcyB0aGUgUElE
IDEsIGFuZCBpcyB0aGUgImluaXQiIHByb2Nlc3MgZm9yIHRoZSBuYW1lc3BhY2UgKHNlZQouQlIg
aW5pdCAoMSkpLgpBIGNoaWxkIHByb2Nlc3MgdGhhdCBpcyBvcnBoYW5lZCB3aXRoaW4gdGhlIG5h
bWVzcGFjZSB3aWxsIGJlIHJlcGFyZW50ZWQKdG8gdGhpcyBwcm9jZXNzIHJhdGhlciB0aGFuCi5C
UiBpbml0ICgxKQoodW5sZXNzIG9uZSBvZiB0aGUgYW5jZXN0b3JzIG9mIHRoZSBjaGlsZAogaW4g
dGhlIHNhbWUgUElEIG5hbWVzcGFjZSBlbXBsb3llZCB0aGUKLkJSIHByY3RsICgyKQouQiBQUl9H
RVRfQ0hJTERfU1VCUkVBUEVSCmNvbW1hbmQgdG8gbWFyayBpdHNlbGYgYXMgdGhlIHJlYXBlciBv
ZiBvcnBoYW5lZCBkZXNjZW5kYW50IHByb2Nlc3NlcykuCgpJZiB0aGUgImluaXQiIHByb2Nlc3Mg
b2YgYSBQSUQgbmFtZXNwYWNlIHRlcm1pbmF0ZXMsCnRoZSBrZXJuZWwgdGVybWluYXRlcyBhbGwg
b2YgdGhlIHByb2Nlc3NlcyBpbiB0aGUgbmFtZXNwYWNlIHZpYSBhCi5CUiBTSUdLSUxMCnNpZ25h
bC4KVGhpcyBiZWhhdmlvciByZWZsZWN0cyB0aGUgZmFjdCB0aGF0IHRoZSAiaW5pdCIgcHJvY2Vz
cwppcyBlc3NlbnRpYWwgZm9yIHRoZSBjb3JyZWN0IG9wZXJhdGlvbiBvZiBhIFBJRCBuYW1lc3Bh
Y2UuCkluIHRoaXMgY2FzZSwgYSBzdWJzZXF1ZW50Ci5CUiBmb3JrICgyKQppbnRvIHRoaXMgUElE
IG5hbWVzcGFjZSB3aWxsIGZhaWwgd2l0aCB0aGUgZXJyb3IKLkJSIEVOT01FTSA7Cml0IGlzIG5v
dCBwb3NzaWJsZSB0byBjcmVhdGUgYSBuZXcgcHJvY2Vzc2VzIGluIGEgUElEIG5hbWVzcGFjZSB3
aG9zZSAiaW5pdCIKcHJvY2VzcyBoYXMgdGVybWluYXRlZC4KU3VjaCBzY2VuYXJpb3MgY2FuIG9j
Y3VyIHdoZW4sIGZvciBleGFtcGxlLAphIHByb2Nlc3MgdXNlcyBhbiBvcGVuIGZpbGUgZGVzY3Jp
cHRvciBmb3IgYQouSSAvcHJvYy9bcGlkXS9ucy9waWQKZmlsZSBjb3JyZXNwb25kaW5nIHRvIGEg
cHJvY2VzcyB0aGF0IHdhcyBpbiBhIG5hbWVzcGFjZSB0bwouQlIgc2V0bnMgKDIpCmludG8gdGhh
dCBuYW1lc3BhY2UgYWZ0ZXIgdGhlICJpbml0IiBwcm9jZXNzIGhhcyB0ZXJtaW5hdGVkLgpBbm90
aGVyIHBvc3NpYmxlIHNjZW5hcmlvIGNhbiBvY2N1ciBhZnRlciBhIGNhbGwgdG8KLkJSIHVuc2hh
cmUgKDIpOgppZiB0aGUgZmlyc3QgY2hpbGQgc3Vic2VxdWVudGx5IGNyZWF0ZWQgYnkgYQouQlIg
Zm9yayAoMikKdGVybWluYXRlcywgdGhlbiBzdWJzZXF1ZW50IGNhbGxzIHRvCi5CUiBmb3JrICgy
KQp3aWxsIGZhaWwgd2l0aAouQlIgRU5PTUVNIC4KCk9ubHkgc2lnbmFscyBmb3Igd2hpY2ggdGhl
ICJpbml0IiBwcm9jZXNzIGhhcyBlc3RhYmxpc2hlZCBhIHNpZ25hbCBoYW5kbGVyCmNhbiBiZSBz
ZW50IHRvIHRoZSAiaW5pdCIgcHJvY2VzcyBieSBvdGhlciBtZW1iZXJzIG9mIHRoZSBQSUQgbmFt
ZXNwYWNlLgpUaGlzIHJlc3RyaWN0aW9uIGFwcGxpZXMgZXZlbiB0byBwcml2aWxlZ2VkIHByb2Nl
c3NlcywKYW5kIHByZXZlbnRzIG90aGVyIG1lbWJlcnMgb2YgdGhlIFBJRCBuYW1lc3BhY2UgZnJv
bQphY2NpZGVudGFsbHkga2lsbGluZyB0aGUgImluaXQiIHByb2Nlc3MuCgpMaWtld2lzZSwgYSBw
cm9jZXNzIGluIGFuIGFuY2VzdG9yIG5hbWVzcGFjZQpjYW5cKGVtc3ViamVjdCB0byB0aGUgdXN1
YWwgcGVybWlzc2lvbiBjaGVja3MgZGVzY3JpYmVkIGluCi5CUiBraWxsICgyKVwoZW1zZW5kCnNp
Z25hbHMgdG8gdGhlICJpbml0IiBwcm9jZXNzIG9mIGEgY2hpbGQgUElEIG5hbWVzcGFjZSBvbmx5
CmlmIHRoZSAiaW5pdCIgcHJvY2VzcyBoYXMgZXN0YWJsaXNoZWQgYSBoYW5kbGVyIGZvciB0aGF0
IHNpZ25hbC4KKFdpdGhpbiB0aGUgaGFuZGxlciwgdGhlCi5JIHNpZ2luZm9fdAouSSBzaV9waWQK
ZmllbGQgZGVzY3JpYmVkIGluCi5CUiBzaWdhY3Rpb24gKDIpCndpbGwgYmUgemVyby4pCi5CIFNJ
R0tJTEwKb3IKLkIgU0lHU1RPUAphcmUgdHJlYXRlZCBleGNlcHRpb25hbGx5Ogp0aGVzZSBzaWdu
YWxzIGFyZSBmb3JjaWJseSBkZWxpdmVyZWQgd2hlbiBzZW50IGZyb20gYW4gYW5jZXN0b3IgUElE
IG5hbWVzcGFjZS4KTmVpdGhlciBvZiB0aGVzZSBzaWduYWxzIGNhbiBiZSBjYXVnaHQgYnkgdGhl
ICJpbml0IiBwcm9jZXNzLAphbmQgc28gd2lsbCByZXN1bHQgaW4gdGhlIHVzdWFsIGFjdGlvbnMg
YXNzb2NpYXRlZCB3aXRoIHRob3NlIHNpZ25hbHMKKHJlc3BlY3RpdmVseSwgdGVybWluYXRpbmcg
YW5kIHN0b3BwaW5nIHRoZSBwcm9jZXNzKS4KClN0YXJ0aW5nIHdpdGggTGludXggMy45LCB0aGUK
LkJSIHJlYm9vdCAoMikKc3lzdGVtIGNhdXNlcyBhIHNpZ25hbCB0byBiZSBzZW50IHRvIHRoZSBu
YW1lc3BhY2UgImluaXQiIHByb2Nlc3MuClNlZQouQlIgcmVib290KDIpCmZvciBtb3JlIGRldGFp
bHMuCi5cIgouXCIgPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09Ci5cIgouU1MgTmVzdGluZyBQSUQgbmFtZXNwYWNlcwpQSUQgbmFtZXNw
YWNlcyBjYW4gYmUgbmVzdGVkOgplYWNoIFBJRCBuYW1lc3BhY2UgaGFzIGEgcGFyZW50LApleGNl
cHQgZm9yIHRoZSBpbml0aWFsICgicm9vdCIpIFBJRCBuYW1lc3BhY2UuClRoZSBwYXJlbnQgb2Yg
YSBQSUQgbmFtZXNwYWNlIGlzIHRoZSBQSUQgbmFtZXNwYWNlIG9mIHRoZSBwcm9jZXNzIHRoYXQK
Y3JlYXRlZCB0aGUgbmFtZXNwYWNlIHVzaW5nCi5CUiBjbG9uZSAoMikKb3IKLkJSIHVuc2hhcmUg
KDIpLgpQSUQgbmFtZXNwYWNlcyB0aHVzIGZvcm0gYSB0cmVlLAp3aXRoIGFsbCBuYW1lc3BhY2Vz
IHVsdGltYXRlbHkgdHJhY2luZyB0aGVpciBhbmNlc3RyeSB0byB0aGUgcm9vdCBuYW1lc3BhY2Uu
CgpBIHByb2Nlc3MgaXMgdmlzaWJsZSB0byBvdGhlciBwcm9jZXNzZXMgaW4gaXRzIFBJRCBuYW1l
c3BhY2UsCmFuZCB0byB0aGUgcHJvY2Vzc2VzIGluIGVhY2ggZGlyZWN0IGFuY2VzdG9yIFBJRCBu
YW1lc3BhY2UKZ29pbmcgYmFjayB0byB0aGUgcm9vdCBQSUQgbmFtZXNwYWNlLgpJbiB0aGlzIGNv
bnRleHQsICJ2aXNpYmxlIiBtZWFucyB0aGF0IG9uZSBwcm9jZXNzCmNhbiBiZSB0aGUgdGFyZ2V0
IG9mIG9wZXJhdGlvbnMgYnkgYW5vdGhlciBwcm9jZXNzIHVzaW5nCnN5c3RlbSBjYWxscyB0aGF0
IHNwZWNpZnkgYSBwcm9jZXNzIElELgpDb252ZXJzZWx5LCB0aGUgcHJvY2Vzc2VzIGluIGEgY2hp
bGQgUElEIG5hbWVzcGFjZSBjYW4ndCBzZWUKcHJvY2Vzc2VzIGluIHRoZSBwYXJlbnQgYW5kIGZ1
cnRoZXIgcmVtb3ZlZCBhbmNlc3RvciBuYW1lc3BhY2UuCk1vcmUgc3VjY2luY3RseTogYSBwcm9j
ZXNzIGNhbiBzZWUgKGUuZy4sIHNlbmQgc2lnbmFscyB3aXRoCi5CUiBraWxsKDIpLApzZXQgbmlj
ZSB2YWx1ZXMgd2l0aAouQlIgc2V0cHJpb3JpdHkgKDIpLApldGMuKSBvbmx5IHByb2Nlc3NlcyBj
b250YWluZWQgaW4gaXRzIG93biBQSUQgbmFtZXNwYWNlCmFuZCBpbiBkZXNjZW5kYW50cyBvZiB0
aGF0IG5hbWVzcGFjZS4KCkEgcHJvY2VzcyBoYXMgb25lIHByb2Nlc3MgSUQgaW4gZWFjaCBvZiB0
aGUgbGF5ZXJzIG9mIHRoZSBQSUQKbmFtZXNwYWNlIGhpZXJhcmNoeSBpbiB3aGljaCBpcyB2aXNp
YmxlLAphbmQgd2Fsa2luZyBiYWNrIHRob3VnaCBlYWNoIGRpcmVjdCBhbmNlc3RvciBuYW1lc3Bh
Y2UKdGhyb3VnaCB0byB0aGUgcm9vdCBQSUQgbmFtZXNwYWNlLgpTeXN0ZW0gY2FsbHMgdGhhdCBv
cGVyYXRlIG9uIHByb2Nlc3MgSURzIGFsd2F5cwpvcGVyYXRlIHVzaW5nIHRoZSBwcm9jZXNzIElE
IHRoYXQgaXMgdmlzaWJsZSBpbiB0aGUKUElEIG5hbWVzcGFjZSBvZiB0aGUgY2FsbGVyLgpBIGNh
bGwgdG8KLkJSIGdldHBpZCAoMikKYWx3YXlzIHJldHVybnMgdGhlIFBJRCBhc3NvY2lhdGVkIHdp
dGggdGhlIG5hbWVzcGFjZSBpbiB3aGljaAp0aGUgcHJvY2VzcyB3YXMgY3JlYXRlZC4KClNvbWUg
cHJvY2Vzc2VzIGluIGEgUElEIG5hbWVzcGFjZSBtYXkgaGF2ZSBwYXJlbnRzCnRoYXQgYXJlIG91
dHNpZGUgb2YgdGhlIG5hbWVzcGFjZS4KRm9yIGV4YW1wbGUsIHRoZSBwYXJlbnQgb2YgdGhlIGlu
aXRpYWwgcHJvY2VzcyBpbiB0aGUgbmFtZXNwYWNlCihpLmUuLCB0aGUKLkJSIGluaXQgKDEpCnBy
b2Nlc3Mgd2l0aCBQSUQgMSkgaXMgbmVjZXNzYXJpbHkgaW4gYW5vdGhlciBuYW1lc3BhY2UuCkxp
a2V3aXNlLCB0aGUgZGlyZWN0IGNoaWxkcmVuIG9mIGEgcHJvY2VzcyB0aGF0IHVzZXMKLkJSIHNl
dG5zICgyKQp0byBjYXVzZSBpdHMgY2hpbGRyZW4gdG8gam9pbiBhIFBJRCBuYW1lc3BhY2UgYXJl
IGluIGEgZGlmZmVyZW50ClBJRCBuYW1lc3BhY2UgZnJvbSB0aGUgY2FsbGVyIG9mCi5CUiBzZXRu
cyAoMikuCkNhbGxzIHRvCi5CUiBnZXRwcGlkICgyKQpmb3Igc3VjaCBwcm9jZXNzZXMgcmV0dXJu
IDAuCi5cIgouXCIgPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09Ci5cIgouU1Mgc2V0bnMoMikgYW5kIHVuc2hhcmUoMikgc2VtYW50aWNz
CkNhbGxzIHRvCi5CUiBzZXRucyAoMikKdGhhdCBzcGVjaWZ5IGEgUElEIG5hbWVzcGFjZSBmaWxl
IGRlc2NyaXB0b3IKYW5kIGNhbGxzIHRvCi5CUiB1bnNoYXJlICgyKQp3aXRoIHRoZQouQlIgQ0xP
TkVfTkVXUElECmZsYWcgY2F1c2UgY2hpbGRyZW4gc3Vic2VxdWVudGx5IGNyZWF0ZWQKYnkgdGhl
IGNhbGxlciB0byBiZSBwbGFjZWQgaW4gYSBkaWZmZXJlbnQgUElEIG5hbWVzcGFjZSBmcm9tIHRo
ZSBjYWxsZXIuClRoZXNlIGNhbGxzIGRvIG5vdCwgaG93ZXZlciwKY2hhbmdlIHRoZSBQSUQgbmFt
ZXNwYWNlIG9mIHRoZSBjYWxsaW5nIHByb2Nlc3MsCmJlY2F1c2UgZG9pbmcgc28gd291bGQgY2hh
bmdlIHRoZSBjYWxsZXIncyBpZGVhIG9mIGl0cyBvd24gUElECihhcyByZXBvcnRlZCBieQouQlIg
Z2V0cGlkICgpKSwKd2hpY2ggd291bGQgYnJlYWsgbWFueSBhcHBsaWNhdGlvbnMgYW5kIGxpYnJh
cmllcy4KClRvIHB1dCB0aGluZ3MgYW5vdGhlciB3YXk6CmEgcHJvY2VzcydzIFBJRCBuYW1lc3Bh
Y2UgbWVtYmVyc2hpcCBpcyBkZXRlcm1pbmVkIHdoZW4gdGhlIHByb2Nlc3MgaXMgY3JlYXRlZAph
bmQgY2Fubm90IGJlIGNoYW5nZWQgdGhlcmVhZnRlci4KQW1vbmcgb3RoZXIgdGhpbmdzLCB0aGlz
IG1lYW5zIHRoYXQgdGhlIHBhcmVudGFsIHJlbGF0aW9uc2hpcApiZXR3ZWVuIHByb2Nlc3NlcyBt
aXJyb3JzIHRoZSBwYXJlbnRhbCByZWxhdGlvbnNoaXAgYmV0d2VlbiBQSUQgbmFtZXNwYWNlczoK
dGhlIHBhcmVudCBvZiBhIHByb2Nlc3MgaXMgZWl0aGVyIGluIHRoZSBzYW1lIG5hbWVzcGFjZQpv
ciByZXNpZGVzIGluIHRoZSBpbW1lZGlhdGUgcGFyZW50IFBJRCBuYW1lc3BhY2UuCi5TUyBDb21w
YXRpYmlsaXR5IG9mIENMT05FX05FV1BJRCB3aXRoIG90aGVyIENMT05FXyogZmxhZ3MKLkJSIENM
T05FX05FV1BJRApjYW4ndCBiZSBjb21iaW5lZCB3aXRoIHNvbWUgb3RoZXIKLkJSIENMT05FXyoK
ZmxhZ3M6Ci5JUCAqIDMKLkIgQ0xPTkVfVEhSRUFECnJlcXVpcmVzIGJlaW5nIGluIHRoZSBzYW1l
IFBJRCBuYW1lc3BhY2UgaW4gb3JkZXIgdGhhdCB0aGF0CnRoZSB0aHJlYWRzIGluIGEgcHJvY2Vz
cyBjYW4gc2VuZCBzaWduYWxzIHRvIGVhY2ggb3RoZXIuClNpbWlsYXJseSwgaXQgbXVzdCBiZSBw
b3NzaWJsZSB0byBzZWUgYWxsIG9mIHRoZSB0aHJlYWRzCm9mIGEgcHJvY2Vzc2VzIGluIHRoZQou
QlIgcHJvYyAoNSkKZmlsZSBzeXN0ZW0uCi5JUCAqCi5CUiBDTE9ORV9TSUdIQU5ECnJlcXVpcmVz
IGJlaW5nIGluIHRoZSBzYW1lIFBJRCBuYW1lc3BhY2U7Cm90aGVyd2lzZSB0aGUgcHJvY2VzcyBJ
RCBvZiB0aGUgcHJvY2VzcyBzZW5kaW5nIGEgc2lnbmFsCmNvdWxkIG5vdCBiZSBtZWFuaW5nZnVs
bHkgZW5jb2RlZCB3aGVuIGEgc2lnbmFsIGlzIHNlbnQKKHNlZSB0aGUgZGVzY3JpcHRpb24gb2Yg
dGhlCi5JIHNpZ2luZm9fdAp0eXBlIGluCi5CUiBzaWdhY3Rpb24gKDIpKS4KQSBzaWduYWwgcXVl
dWUgc2hhcmVkIGJ5IHByb2Nlc3NlcyBpbiBtdWx0aXBsZSBQSUQgbmFtZXNwYWNlcwp3aWxsIGRl
ZmVhdCB0aGF0LgouSVAgKgouQlIgQ0xPTkVfVk0KcmVxdWlyZXMgYWxsIG9mIHRoZSB0aHJlYWRz
IHRvIGJlIGluIHRoZSBzYW1lIFBJRCBuYW1lc3BhY2UsCmJlY2F1c2UsIGZyb20gdGhlIHBvaW50
IG9mIHZpZXcgb2YgYSBjb3JlIGR1bXAsCmlmIHR3byBwcm9jZXNzZXMgc2hhcmUgdGhlIHNhbWUg
YWRkcmVzcyBzcGFjZSB0aGV5IGFyZSB0aHJlYWRzIGFuZCB3aWxsCmJlIGNvcmUgZHVtcGVkIHRv
Z2V0aGVyLgpXaGVuIGEgY29yZSBkdW1wIGlzIHdyaXR0ZW4sIHRoZSBQSUQgb2YgZWFjaAp0aHJl
YWQgaXMgd3JpdHRlbiBpbnRvIHRoZSBjb3JlIGR1bXAuCldyaXRpbmcgdGhlIHByb2Nlc3MgSURz
IGNvdWxkIG5vdCBtZWFuaW5nZnVsbHkgc3VjY2VlZAppZiBzb21lIG9mIHRoZSBwcm9jZXNzIElE
cyB3ZXJlIGluIGEgcGFyZW50IFBJRCBuYW1lc3BhY2UuCi5QUApUbyBzdW1tYXJpemU6IHRoZXJl
IGlzIGEgdGVjaG5pY2FsIHJlcXVpcmVtZW50IGZvciBlYWNoIG9mCi5CUiBDTE9ORV9USFJFQUQg
LAouQlIgQ0xPTkVfU0lHSEFORCAsCmFuZAouQlIgQ0xPTkVfVk0KdG8gc2hhcmUgYSBQSUQgbmFt
ZXNwYWNlLgooTm90ZSBmdXJ0aGVybW9yZSB0aGF0IGluCi5CUiBjbG9uZSAoMikKcmVxdWlyZXMK
LkJSIENMT05FX1ZNCnRvIGJlIHNwZWNpZmllZCBpZgouQlIgQ0xPTkVfVEhSRUFECm9yCi5CUiBD
TE9ORV9TSUdIQU5ECmlzIHNwZWNpZmllZC4pClRodXMsIGNhbGwgc2VxdWVuY2VzIHN1Y2ggYXMg
dGhlIGZvbGxvd2luZyB3aWxsIGZhaWwgKHdpdGggdGhlIGVycm9yCi5CUiBFSU5WQUwgKToKCi5u
ZgogICAgdW5zaGFyZShDTE9ORV9ORVdQSUQpOwogICAgY2xvbmUoLi4uLCBDTE9ORV9WTSwgLi4u
KTsgICAgLyogRmFpbHMgKi8KCiAgICBzZXRucyhmZCwgQ0xPTkVfTkVXUElEKTsKICAgIGNsb25l
KC4uLiwgQ0xPTkVfVk0sIC4uLik7ICAgIC8qIEZhaWxzICovCgogICAgY2xvbmUoLi4uLCBDTE9O
RV9WTSwgLi4uKTsKICAgIHNldG5zKGZkLCBDTE9ORV9ORVdQSUQpOyAgICAgIC8qIEZhaWxzICov
CgogICAgY2xvbmUoLi4uLCBDTE9ORV9WTSwgLi4uKTsKICAgIHVuc2hhcmUoQ0xPTkVfTkVXUElE
KTsgICAgICAgIC8qIEZhaWxzICovCi5maQouXCIKLlwiID09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQouXCIKLlNTIC9wcm9jIGFuZCBQ
SUQgbmFtZXNwYWNlcwpBCi5JIC9wcm9jCmZpbGUgc3lzdGVtIHNob3dzIChpbiB0aGUKLkkgL3By
b2MvUElECmRpcmVjdG9yaWVzKSBvbmx5IHByb2Nlc3NlcyB2aXNpYmxlIGluIHRoZSBQSUQgbmFt
ZXNwYWNlCm9mIHRoZSBwcm9jZXNzIHRoYXQgcGVyZm9ybWVkIHRoZSBtb3VudCwgZXZlbiBpZiB0
aGUKLkkgL3Byb2MKZmlsZSBzeXN0ZW0gaXMgdmlld2VkIGZyb20gcHJvY2Vzc2VzIGluIG90aGVy
IG5hbWVzcGFjZXMuCgpBZnRlciBjcmVhdGluZyBhIG5ldyBQSUQgbmFtZXNwYWNlLAppdCBpcyB1
c2VmdWwgZm9yIHRoZSBjaGlsZCB0byBjaGFuZ2UgaXRzIHJvb3QgZGlyZWN0b3J5CmFuZCBtb3Vu
dCBhIG5ldyBwcm9jZnMgaW5zdGFuY2UgYXQKLkkgL3Byb2MKc28gdGhhdCB0b29scyBzdWNoIGFz
Ci5CUiBwcyAoMSkKd29yayBjb3JyZWN0bHkuCklmIGEgbmV3IG1vdW50IG5hbWVzcGFjZSBpcyBz
aW11bHRhbmVvdXNseSBjcmVhdGVkIGJ5IGluY2x1ZGluZwouQlIgQ0xPTkVfTkVXTlMKaW4gdGhl
Ci5JUiBmbGFncwphcmd1bWVudCBvZgouQlIgY2xvbmUgKDIpCm9yCi5CUiB1bnNoYXJlICgyKSwK
dGhlbiBpdCBpc24ndCBuZWNlc3NhcnkgdG8gY2hhbmdlIHRoZSByb290IGRpcmVjdG9yeToKYSBu
ZXcgcHJvY2ZzIGluc3RhbmNlIGNhbiBiZSBtb3VudGVkIGRpcmVjdGx5IG92ZXIKLklSIC9wcm9j
IC4KCkZyb20gYSBzaGVsbCwgdGhlIGNvbW1hbmQgdG8gbW91bnQKLkkgL3Byb2MKaXM6CgogICAg
JCBtb3VudCAtdCBwcm9jIHByb2MgL3Byb2MKCkNhbGxpbmcKLkJSIHJlYWRsaW5rICgyKQpvbiB0
aGUgcGF0aAouSSAvcHJvYy9zZWxmCnlpZWxkcyB0aGUgcHJvY2VzcyBJRCBvZiB0aGUgY2FsbGVy
IGluIHRoZSBQSUQgbmFtZXNwYWNlIG9mIHRoZSBwcm9jZnMgbW91bnQKKGkuZS4sIHRoZSBQSUQg
bmFtZXNwYWNlIG9mIHRoZSBwcm9jZXNzIHRoYXQgbW91bnRlZCB0aGUgcHJvY2ZzKS4KVGhpcyBj
YW4gYmUgdXNlZnVsIGZvciBpbnRyb3NwZWN0aW9uIHB1cnBvc2VzLAp3aGVuIGEgcHJvY2VzcyB3
YW50cyB0byBkaXNjb3ZlciBpdHMgUElEIGluIG90aGVyIG5hbWVzcGFjZXMuCi5cIgouXCIgPT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
Ci5cIgouU1MgTWlzY2VsbGFuZW91cwpXaGVuIGEgcHJvY2VzcyBJRCBpcyBwYXNzZWQgb3ZlciBh
IFVOSVggZG9tYWluIHNvY2tldCB0byBhCnByb2Nlc3MgaW4gYSBkaWZmZXJlbnQgUElEIG5hbWVz
cGFjZSAoc2VlIHRoZSBkZXNjcmlwdGlvbiBvZgouQiBTQ01fQ1JFREVOVElBTFMKaW4KLkJSIHVu
aXggKDcpKSwKaXQgaXMgdHJhbnNsYXRlZCBpbnRvIHRoZSBjb3JyZXNwb25kaW5nIFBJRCB2YWx1
ZSBpbgp0aGUgcmVjZWl2aW5nIHByb2Nlc3MncyBQSUQgbmFtZXNwYWNlLgouU0ggQ09ORk9STUlO
RyBUTwpOYW1lc3BhY2VzIGFyZSBhIExpbnV4LXNwZWNpZmljIGZlYXR1cmUuCi5TSCBFWEFNUExF
ClNlZQouQlIgdXNlcl9uYW1lc3BhY2VzICg3KS4KLlNIIFNFRSBBTFNPCi5CUiBjbG9uZSAoMiks
Ci5CUiBzZXRucyAoMiksCi5CUiB1bnNoYXJlICgyKSwKLkJSIHByb2MgKDUpLAouQlIgY3JlZGVu
dGlhbHMgKDcpLAouQlIgY2FwYWJpbGl0aWVzICg3KSwKLkJSIHVzZXJfbmFtZXNwYWNlcyAoNyks
Ci5CUiBzd2l0Y2hfcm9vdCAoOCkK
--bcaec52e58bfa2cd9304d7b4f27b
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--bcaec52e58bfa2cd9304d7b4f27b--
