From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: For review: pid_namespaces(7) man page
Date: Wed, 20 Aug 2014 18:38:15 -0500
Message-ID: <53F53167.4070207@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080701000506080305070000"
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
Cc: "linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------080701000506080305070000
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello Eric et al.

Here is the current draft of the pid_namespaces(7) man page, which
described PID namespaces. The rendered version is below, and the
source is attached.

Review comments/suggestions for improvements / bug fixes welcome.

Cheers,

Michael

=3D=3D

NAME
       pid_namespaces - overview of Linux PID namespaces

DESCRIPTION
       For an overview of namespaces, see namespaces(7).

       PID  namespaces isolate the process ID number space, meaning that
       processes in different PID namespaces can have the same PID.  PID
       namespaces allow containers to provide functionality such as sus=E2=
=80=90
       pending/resuming the  set  of  processes  in  the  container  and
       migrating  the container to a new host while the processes inside
       the container maintain the same PIDs.

       PIDs in a new PID namespace start at 1, somewhat  like  a  stand=E2=
=80=90
       alone  system,  and  calls to fork(2), vfork(2), or clone(2) will
       produce processes with PIDs that are unique within the namespace.

       Use of PID namespaces requires a kernel that is  configured  with
       the CONFIG_PID_NS option.

   The namespace init process
       The  first  process created in a new namespace (i.e., the process
       created using clone(2) with the CLONE_NEWPID flag, or  the  first
       child  created  by a process after a call to unshare(2) using the
       CLONE_NEWPID flag) has the PID 1, and is the "init"  process  for
       the  namespace  (see  init(1)).  A child process that is orphaned
       within the namespace will be reparented to  this  process  rather
       than init(1) (unless one of the ancestors of the child
        in    the    same    PID   namespace   employed   the   prctl(2)
       PR_GET_CHILD_SUBREAPER command to mark itself as  the  reaper  of
       orphaned descendant processes).

       If  the  "init" process of a PID namespace terminates, the kernel
       terminates all of the processes in the namespace  via  a  SIGKILL
       signal.   This behavior reflects the fact that the "init" process
       is essential for the correct operation of a  PID  namespace.   In
       this case, a subsequent fork(2) into this PID namespace will fail
       with the error ENOMEM; it is not possible to create  a  new  pro=E2=
=80=90
       cesses  in  a  PID namespace whose "init" process has terminated.
       Such scenarios can occur when, for example,  a  process  uses  an
       open  file descriptor for a /proc/[pid]/ns/pid file corresponding
       to a process that was in a namespace to setns(2) into that names=E2=
=80=90
       pace  after  the "init" process has terminated.  Another possible
       scenario can occur after a call to unshare(2): if the first child
       subsequently  created  by  a  fork(2) terminates, then subsequent
       calls to fork(2) will fail with ENOMEM.

       Only signals for which the "init" process has established a  sig=E2=
=80=90
       nal handler can be sent to the "init" process by other members of
       the PID namespace.  This restriction applies even  to  privileged
       processes,  and  prevents other members of the PID namespace from
       accidentally killing the "init" process.

       Likewise, a process in an ancestor namespace can=E2=80=94subject  =
to  the
       usual  permission checks described in kill(2)=E2=80=94send signals=
 to the
       "init" process of a  child  PID  namespace  only  if  the  "init"
       process  has  established a handler for that signal.  (Within the
       handler, the siginfo_t si_pid  field  described  in  sigaction(2)
       will  be  zero.)   SIGKILL  or SIGSTOP are treated exceptionally:
       these signals are forcibly delivered when sent from  an  ancestor
       PID  namespace.   Neither  of  these signals can be caught by the
       "init" process, and so will result in the usual  actions  associ=E2=
=80=90
       ated  with  those signals (respectively, terminating and stopping
       the process).

       Starting with Linux 3.4, the reboot(2) system causes a signal  to
       be  sent to the namespace "init" process.  See reboot(2) for more
       details.

   Nesting PID namespaces
       PID namespaces can be nested: each PID namespace  has  a  parent,
       except  for  the initial ("root") PID namespace.  The parent of a
       PID namespace is the PID namespace of the  process  that  created
       the  namespace using clone(2) or unshare(2).  PID namespaces thus
       form a tree, with all namespaces ultimately tracing their  ances=E2=
=80=90
       try to the root namespace.

       A process is visible to other processes in its PID namespace, and
       to the processes in each direct ancestor PID namespace going back
       to the root PID namespace.  In this context, "visible" means that
       one process can be the target of operations  by  another  process
       using  system  calls  that specify a process ID.  Conversely, the
       processes in a child PID namespace can't  see  processes  in  the
       parent  and further removed ancestor namespace.  More succinctly:
       a process can see (e.g., send signals with kill(2), set nice val=E2=
=80=90
       ues  with  setpriority(2),  etc.) only processes contained in its
       own PID namespace and in descendants of that namespace.

       A process has one process ID in each of the  layers  of  the  PID
       namespace  hierarchy in which is visible, and walking back though
       each direct ancestor namespace through to the root PID namespace.
       System calls that operate on process IDs always operate using the
       process ID that is visible in the PID namespace of the caller.  A
       call  to  getpid(2)  always  returns  the PID associated with the
       namespace in which the process was created.

       Some processes in a PID namespace may have parents that are  out=E2=
=80=90
       side  of  the  namespace.  For example, the parent of the initial
       process in the namespace (i.e., the init(1) process with  PID  1)
       is  necessarily in another namespace.  Likewise, the direct chil=E2=
=80=90
       dren of a process that uses setns(2) to  cause  its  children  to
       join  a  PID  namespace are in a different PID namespace from the
       caller of setns(2).   Calls  to  getppid(2)  for  such  processes
       return 0.

   setns(2) and unshare(2) semantics
       Calls  to  setns(2)  that specify a PID namespace file descriptor
       and calls to unshare(2) with the CLONE_NEWPID flag cause children
       subsequently  created  by  the caller to be placed in a different
       PID namespace from the caller.   These  calls  do  not,  however,
       change the PID namespace of the calling process, because doing so
       would change the caller's idea of its own  PID  (as  reported  by
       getpid()), which would break many applications and libraries.

       To  put  things another way: a process's PID namespace membership
       is determined when the process is created and cannot  be  changed
       thereafter.   Among  other  things,  this means that the parental
       relationship between processes mirrors the parental  relationship
       between  PID namespaces: the parent of a process is either in the
       same namespace or resides in the immediate parent PID namespace.

   Compatibility of CLONE_NEWPID with other CLONE_* flags
       CLONE_NEWPID can't be combined with some other CLONE_* flags:

       *  CLONE_THREAD requires being in the same PID namespace in order
          that  that  the  threads in a process can send signals to each
          other.  Similarly, it must be  possible  to  see  all  of  the
          threads of a processes in the proc(5) filesystem.

       *  CLONE_SIGHAND requires being in the same PID namespace; other=E2=
=80=90
          wise the process ID of the process sending a signal could  not
          be  meaningfully  encoded  when  a  signal  is  sent  (see the
          description of the siginfo_t type in sigaction(2)).  A  signal
          queue  shared  by  processes  in  multiple PID namespaces will
          defeat that.

       *  CLONE_VM requires all of the threads to be  in  the  same  PID
          namespace,  because, from the point of view of a core dump, if
          two processes share the same address space  they  are  threads
          and  will  be core dumped together.  When a core dump is writ=E2=
=80=90
          ten, the PID of each thread is written  into  the  core  dump.
          Writing the process IDs could not meaningfully succeed if some
          of the process IDs were in a parent PID namespace.

       To summarize: there  is  a  technical  requirement  for  each  of
       CLONE_THREAD,  CLONE_SIGHAND,  and CLONE_VM to share a PID names=E2=
=80=90
       pace.  (Note furthermore that in clone(2) requires CLONE_VM to be
       specified  if CLONE_THREAD or CLONE_SIGHAND is specified.)  Thus,
       call sequences such as the following will fail  (with  the  error
       EINVAL):

           unshare(CLONE_NEWPID);
           clone(..., CLONE_VM, ...);    /* Fails */

           setns(fd, CLONE_NEWPID);
           clone(..., CLONE_VM, ...);    /* Fails */

           clone(..., CLONE_VM, ...);
           setns(fd, CLONE_NEWPID);      /* Fails */

           clone(..., CLONE_VM, ...);
           unshare(CLONE_NEWPID);        /* Fails */

   /proc and PID namespaces
       A /proc filesystem shows (in the /proc/PID directories) only pro=E2=
=80=90
       cesses visible in the PID namespace of the process that performed
       the  mount, even if the /proc filesystem is viewed from processes
       in other namespaces.

       After creating a new PID namespace, it is useful for the child to
       change  its  root  directory  and  mount a new procfs instance at
       /proc so that tools such as ps(1) work correctly.  If a new mount
       namespace  is  simultaneously created by including CLONE_NEWNS in
       the flags argument of clone(2) or unshare(2), then it isn't  nec=E2=
=80=90
       essary to change the root directory: a new procfs instance can be
       mounted directly over /proc.

       From a shell, the command to mount /proc is:

           $ mount -t proc proc /proc

       Calling readlink(2) on the path /proc/self yields the process  ID
       of the caller in the PID namespace of the procfs mount (i.e., the
       PID namespace of the process that mounted the procfs).  This  can
       be  useful  for  introspection  purposes, when a process wants to
       discover its PID in other namespaces.

   Miscellaneous
       When a process ID is passed  over  a  UNIX  domain  socket  to  a
       process  in  a  different  PID  namespace (see the description of
       SCM_CREDENTIALS in unix(7)), it is  translated  into  the  corre=E2=
=80=90
       sponding PID value in the receiving process's PID namespace.

CONFORMING TO
       Namespaces are a Linux-specific feature.

EXAMPLE
       See user_namespaces(7).

SEE ALSO
       clone(2), setns(2), unshare(2), proc(5), credentials(7), capabil=E2=
=80=90
       ities(7), user_namespaces(7), switch_root(8)



--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--------------080701000506080305070000
Content-Type: application/x-troff-man;
 name="pid_namespaces.7"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="pid_namespaces.7"

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
.\" ============================================================
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
it is not possible to create a new processes in a PID namespace whose "init"
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
these signals are forcibly delivered when sent from an ancestor PID namespace.
Neither of these signals can be caught by the "init" process,
and so will result in the usual actions associated with those signals
(respectively, terminating and stopping the process).

Starting with Linux 3.4, the
.BR reboot (2)
system causes a signal to be sent to the namespace "init" process.
See
.BR reboot (2)
for more details.
.\"
.\" ============================================================
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
with all namespaces ultimately tracing their ancestry to the root namespace.

A process is visible to other processes in its PID namespace,
and to the processes in each direct ancestor PID namespace
going back to the root PID namespace.
In this context, "visible" means that one process
can be the target of operations by another process using
system calls that specify a process ID.
Conversely, the processes in a child PID namespace can't see
processes in the parent and further removed ancestor namespace.
More succinctly: a process can see (e.g., send signals with
.BR kill (2),
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
.\" ============================================================
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
a process's PID namespace membership is determined when the process is created
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
filesystem.
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
.\" ============================================================
.\"
.SS /proc and PID namespaces
A
.I /proc
filesystem shows (in the
.I /proc/PID
directories) only processes visible in the PID namespace
of the process that performed the mount, even if the
.I /proc
filesystem is viewed from processes in other namespaces.

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
yields the process ID of the caller in the PID namespace of the procfs mount
(i.e., the PID namespace of the process that mounted the procfs).
This can be useful for introspection purposes,
when a process wants to discover its PID in other namespaces.
.\"
.\" ============================================================
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

--------------080701000506080305070000
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--------------080701000506080305070000--
