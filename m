From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: For review: pid_namespaces(7) man page
Date: Thu, 28 Feb 2013 12:24:07 +0100
Message-ID: <CAKgNAki=mUYuu_Ewhe7sjCmo+Dq2Vr+FZCixqNRaadcvAxtpFw__2445.05713130838$1362050699$gmane$org@mail.gmail.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=14dae93b5e363e233f04d6c72253
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
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

--14dae93b5e363e233f04d6c72253
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Eric et al,

Eventually, there will be more namespace man pages, but let us start
now with one for PID namespaces. The attached page aims to provide a
fairly complete overview of PID namespaces.

Eric, various pieces of the page are shifted out of other pages
(clone(2), setns(2), etc.) and are derived from comments you've
emailed me off list, so you are (jointly) in the copyright of the
page. I've chosen the common license for man-pages; let me know if you
have any objections to that license.

I'm looking for review comments (corrections, improvements, additions,
etc.) on this page. I've provided it in two forms inline below, and
reviewers can comment comment on whichever form they are most
comfortable with:

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
       PID.   PID namespaces allow containers to migrate to a new host
       while the processes inside  the  container  maintain  the  same
       PIDs.

       PIDs  in a new PID namespace start at 1, somewhat like a stand=E2=80=
=90
       alone system, and calls to fork(2), vfork(2), or clone(2)  will
       produce  processes  with PIDs that are unique within the names=E2=80=
=90
       pace.

       Use of PID namespaces requires a kernel that is configured with
       the CONFIG_PID_NS option.

   The namespace init process
       The first process created in a new namespace (i.e., the process
       created using clone(2) with the CLONE_NEWPID flag, or the first
       child created by a process after a call to unshare(2) using the
       CLONE_NEWPID flag) has the PID 1, and is the "init" process for
       the namespace (see init(1)).  Children that are orphaned within
       the namespace will be reparented to this  process  rather  than
       init(1).

       If the "init" process of a PID namespace terminates, the kernel
       terminates all of the processes in the namespace via a  SIGKILL
       signal.   This  behavior  reflects  the  fact  that  the "init"
       process is essential for the correct operation of a PID  names=E2=80=
=90
       pace.   In this case, a subsequent fork(2) into this PID names=E2=80=
=90
       pace (e.g., from a process that has done a  setns(2)  into  the
       namespace    using    an    open    file   descriptor   for   a
       /proc/[pid]/ns/pid file corresponding to a process that was  in
       the  namespace) will fail with the error ENOMEM; it is not pos=E2=80=
=90
       sible to create a new processes in a PID namespace whose "init"
       process has terminated.

       Only  signals  for  which  the "init" process has established a
       signal handler can be sent to the "init" process by other  mem=E2=80=
=90
       bers  of  the  PID namespace.  This restriction applies even to
       privileged processes, and prevents other  members  of  the  PID
       namespace from accidentally killing the "init" process.

       Likewise, a process in an ancestor namespace can=E2=80=94subject to =
the
       usual permission checks described in  kill(2)=E2=80=94send  signals =
 to
       the  "init" process of a child PID namespace only if the "init"
       process has established a handler for that signal.  (Within the
       handler,  the  siginfo_t si_pid field described in sigaction(2)
       will be zero.)  SIGKILL or SIGSTOP are  treated  exceptionally:
       these signals are forcibly delivered when sent from an ancestor
       PID namespace.  Neither of these signals can be caught  by  the
       "init" process, and so will result in the usual actions associ=E2=80=
=90
       ated with those signals (respectively, terminating and stopping
       the process).

   Nesting PID namespaces
       PID  namespaces can be nested: each PID namespace has a parent,
       except for the initial ("root") PID namespace.  The parent of a
       PID  namespace is the PID namespace of the process that created
       the namespace using clone(2)  or  unshare(2).   PID  namespaces
       thus  form a tree, with all namespaces ultimately tracing their
       ancestry to the root namespace.

       A process is visible to other processes in its  PID  namespace,
       and  to  the  processes  in  each direct ancestor PID namespace
       going back to the root PID namespace.  In this context,  "visi=E2=80=
=90
       ble"  means that one process can be the target of operations by
       another process using system calls that specify a  process  ID.
       Conversely,  the  processes  in a child PID namespace can't see
       processes in the parent and further removed ancestor namespace.
       More  succinctly:  a  process  can see (e.g., send signals with
       kill(2), set nice values with setpriority(2), etc.)  only  pro=E2=80=
=90
       cesses contained in its own PID namespace and in descendants of
       that namespace.

       A process has one process ID in each of the layers of  the  PID
       namespace  hierarchy  in  which  is  visible,  and walking back
       though each direct ancestor namespace through to the  root  PID
       namespace.   System  calls  that  operate on process IDs always
       operate using the process ID that is visible in the PID  names=E2=80=
=90
       pace of the caller.  A call to getpid(2) always returns the PID
       associated with the namespace in which the process was created.

       Some processes in a PID namespace may  have  parents  that  are
       outside  of the namespace.  For example, the parent of the ini=E2=80=
=90
       tial process in the namespace (i.e., the init(1)  process  with
       PID  1)  is  necessarily  in  another namespace.  Likewise, the
       direct children of a process that uses setns(2)  to  cause  its
       children  to join a PID namespace are in a different PID names=E2=80=
=90
       pace from the caller of setns(2).  Calls to getppid(2) for such
       processes return 0.

   setns(2) and unshare(2) semantics
       Calls  to setns(2) that specify a PID namespace file descriptor
       and calls to unshare(2) with the CLONE_NEWPID flag cause  chil=E2=80=
=90
       dren  subsequently created by the caller to be placed in a dif=E2=80=
=90
       ferent PID namespace from the caller.  These calls do not, how=E2=80=
=90
       ever,  change the PID namespace of the calling process, because
       doing so would change the caller's idea  of  its  own  PID  (as
       reported  by getpid()), which would break many applications and
       libraries.

       To put things another way: a process's PID namespace membership
       is determined when the process is created and cannot be changed
       thereafter.  Among other things, this means that  the  parental
       relationship between processes mirrors the parental between PID
       namespaces: the parent of a  process  is  either  in  the  same
       namespace or resides in the immediate parent PID namespace.

       Every  thread  in  a process must be in the same PID namespace.
       For this reason, the two following call sequences will fail:

           unshare(CLONE_NEWPID);
           clone(..., CLONE_VM, ...);    /* Fails */

           setns(fd, CLONE_NEWPID);
           clone(..., CLONE_VM, ...);    /* Fails */

       Because the above unshare(2) and setns(2) calls only change the
       PID  namespace  for created children, the clone(2) calls neces=E2=80=
=90
       sarily put the new thread in a different PID namespace from the
       calling thread.

   Miscellaneous
       After  creating a new PID namespace, it is useful for the child
       to change its root directory and mount a new procfs instance at
       /proc  so  that  tools such as ps(1) work correctly.  (If a new
       mount  namespace  is  simultaneously   created   by   including
       CLONE_NEWNS  in  the flags argument of clone(2) or unshare(2)),
       then it isn't necessary to change the  root  directory:  a  new
       procfs instance can be mounted directly over /proc.)

       Calling  readlink(2)  on the path /proc/self yields the process
       ID of the caller in the  PID  namespace  of  the  procfs  mount
       (i.e.,  the  PID  namespace  of  the  process  that mounted the
       procfs).

       When a process ID is passed over a  UNIX  domain  socket  to  a
       process  in  a  different PID namespace (see the description of
       SCM_CREDENTIALS in unix(7)), it is translated into  the  corre=E2=80=
=90
       sponding PID value in the receiving process's PID namespace.

CONFORMING TO
       Namespaces are a Linux-specific feature.

SEE ALSO
       unshare(1),  clone(2),  setns(2),  unshare(2), proc(5), creden=E2=80=
=90
       tials(7), capabilities(7), user_namespaces(7), switch_root(8)



Linux                         2013-01-14             PID_NAMESPACES(7)


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D *roff source =3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D

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
PID namespaces allow containers to migrate to a new host
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
Children that are orphaned within the namespace will be reparented
to this process rather than
.BR init (1).

If the "init" process of a PID namespace terminates,
the kernel terminates all of the processes in the namespace via a
.BR SIGKILL
signal.
This behavior reflects the fact that the "init" process
is essential for the correct operation of a PID namespace.
In this case, a subsequent
.BR fork (2)
into this PID namespace (e.g., from a process that has done a
.BR setns (2)
into the namespace using an open file descriptor for a
.I /proc/[pid]/ns/pid
file corresponding to a process that was in the namespace)
will fail with the error
.BR ENOMEM ;
it is not possible to create a new processes in a PID namespace whose "init=
"
process has terminated.

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
between processes mirrors the parental between PID namespaces:
the parent of a process is either in the same namespace
or resides in the immediate parent PID namespace.

Every thread in a process must be in the same PID namespace.
For this reason, the two following call sequences will fail:

.nf
    unshare(CLONE_NEWPID);
    clone(..., CLONE_VM, ...);    /* Fails */

    setns(fd, CLONE_NEWPID);
    clone(..., CLONE_VM, ...);    /* Fails */
.fi

Because the above
.BR unshare (2)
and
.BR setns (2)
calls only change the PID namespace for created children, the
.BR clone (2)
calls necessarily put the new thread in a different PID namespace from
the calling thread.
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS Miscellaneous
After creating a new PID namespace,
it is useful for the child to change its root directory
and mount a new procfs instance at
.I /proc
so that tools such as
.BR ps (1)
work correctly.
.\" mount -t proc proc /proc
(If a new mount namespace is simultaneously created by including
.BR CLONE_NEWNS
in the
.IR flags
argument of
.BR clone (2)
or
.BR unshare (2)),
then it isn't necessary to change the root directory:
a new procfs instance can be mounted directly over
.IR /proc .)

Calling
.BR readlink (2)
on the path
.I /proc/self
yields the process ID of the caller in the PID namespace of the procfs moun=
t
(i.e., the PID namespace of the process that mounted the procfs).

When a process ID is passed over a UNIX domain socket to a
process in a different PID namespace (see the description of
.B SCM_CREDENTIALS
in
.BR unix (7)),
it is translated into the corresponding PID value in
the receiving process's PID namespace.
.SH CONFORMING TO
Namespaces are a Linux-specific feature.
.SH SEE ALSO
.BR unshare (1),
.BR clone (2),
.BR setns (2),
.BR unshare (2),
.BR proc (5),
.BR credentials (7),
.BR capabilities (7),
.BR user_namespaces (7),
.BR switch_root (8)

--14dae93b5e363e233f04d6c72253
Content-Type: application/octet-stream; name="pid_namespaces.7"
Content-Disposition: attachment; filename="pid_namespaces.7"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hdptjyal0

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
Y29udGFpbmVycyB0byBtaWdyYXRlIHRvIGEgbmV3IGhvc3QKd2hpbGUgdGhlIHByb2Nlc3NlcyBp
bnNpZGUgdGhlIGNvbnRhaW5lciBtYWludGFpbiB0aGUgc2FtZSBQSURzLgoKUElEcyBpbiBhIG5l
dyBQSUQgbmFtZXNwYWNlIHN0YXJ0IGF0IDEsCnNvbWV3aGF0IGxpa2UgYSBzdGFuZGFsb25lIHN5
c3RlbSwgYW5kIGNhbGxzIHRvCi5CUiBmb3JrICgyKSwKLkJSIHZmb3JrICgyKSwKb3IKLkJSIGNs
b25lICgyKQp3aWxsIHByb2R1Y2UgcHJvY2Vzc2VzIHdpdGggUElEcyB0aGF0IGFyZSB1bmlxdWUg
d2l0aGluIHRoZSBuYW1lc3BhY2UuCgpVc2Ugb2YgUElEIG5hbWVzcGFjZXMgcmVxdWlyZXMgYSBr
ZXJuZWwgdGhhdCBpcyBjb25maWd1cmVkIHdpdGggdGhlCi5CIENPTkZJR19QSURfTlMKb3B0aW9u
LgouXCIKLlwiID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PQouXCIKLlNTIFRoZSBuYW1lc3BhY2UgImluaXQiIHByb2Nlc3MKVGhlIGZp
cnN0IHByb2Nlc3MgY3JlYXRlZCBpbiBhIG5ldyBuYW1lc3BhY2UKKGkuZS4sIHRoZSBwcm9jZXNz
IGNyZWF0ZWQgdXNpbmcKLkJSIGNsb25lICgyKQp3aXRoIHRoZQouQlIgQ0xPTkVfTkVXUElECmZs
YWcsIG9yIHRoZSBmaXJzdCBjaGlsZCBjcmVhdGVkIGJ5IGEgcHJvY2VzcyBhZnRlciBhIGNhbGwg
dG8KLkJSIHVuc2hhcmUgKDIpCnVzaW5nIHRoZQouQlIgQ0xPTkVfTkVXUElECmZsYWcpIGhhcyB0
aGUgUElEIDEsIGFuZCBpcyB0aGUgImluaXQiIHByb2Nlc3MgZm9yIHRoZSBuYW1lc3BhY2UgKHNl
ZQouQlIgaW5pdCAoMSkpLgpDaGlsZHJlbiB0aGF0IGFyZSBvcnBoYW5lZCB3aXRoaW4gdGhlIG5h
bWVzcGFjZSB3aWxsIGJlIHJlcGFyZW50ZWQKdG8gdGhpcyBwcm9jZXNzIHJhdGhlciB0aGFuCi5C
UiBpbml0ICgxKS4KCklmIHRoZSAiaW5pdCIgcHJvY2VzcyBvZiBhIFBJRCBuYW1lc3BhY2UgdGVy
bWluYXRlcywKdGhlIGtlcm5lbCB0ZXJtaW5hdGVzIGFsbCBvZiB0aGUgcHJvY2Vzc2VzIGluIHRo
ZSBuYW1lc3BhY2UgdmlhIGEKLkJSIFNJR0tJTEwKc2lnbmFsLgpUaGlzIGJlaGF2aW9yIHJlZmxl
Y3RzIHRoZSBmYWN0IHRoYXQgdGhlICJpbml0IiBwcm9jZXNzCmlzIGVzc2VudGlhbCBmb3IgdGhl
IGNvcnJlY3Qgb3BlcmF0aW9uIG9mIGEgUElEIG5hbWVzcGFjZS4KSW4gdGhpcyBjYXNlLCBhIHN1
YnNlcXVlbnQKLkJSIGZvcmsgKDIpCmludG8gdGhpcyBQSUQgbmFtZXNwYWNlIChlLmcuLCBmcm9t
IGEgcHJvY2VzcyB0aGF0IGhhcyBkb25lIGEKLkJSIHNldG5zICgyKQppbnRvIHRoZSBuYW1lc3Bh
Y2UgdXNpbmcgYW4gb3BlbiBmaWxlIGRlc2NyaXB0b3IgZm9yIGEKLkkgL3Byb2MvW3BpZF0vbnMv
cGlkCmZpbGUgY29ycmVzcG9uZGluZyB0byBhIHByb2Nlc3MgdGhhdCB3YXMgaW4gdGhlIG5hbWVz
cGFjZSkKd2lsbCBmYWlsIHdpdGggdGhlIGVycm9yCi5CUiBFTk9NRU0gOwppdCBpcyBub3QgcG9z
c2libGUgdG8gY3JlYXRlIGEgbmV3IHByb2Nlc3NlcyBpbiBhIFBJRCBuYW1lc3BhY2Ugd2hvc2Ug
ImluaXQiCnByb2Nlc3MgaGFzIHRlcm1pbmF0ZWQuCgpPbmx5IHNpZ25hbHMgZm9yIHdoaWNoIHRo
ZSAiaW5pdCIgcHJvY2VzcyBoYXMgZXN0YWJsaXNoZWQgYSBzaWduYWwgaGFuZGxlcgpjYW4gYmUg
c2VudCB0byB0aGUgImluaXQiIHByb2Nlc3MgYnkgb3RoZXIgbWVtYmVycyBvZiB0aGUgUElEIG5h
bWVzcGFjZS4KVGhpcyByZXN0cmljdGlvbiBhcHBsaWVzIGV2ZW4gdG8gcHJpdmlsZWdlZCBwcm9j
ZXNzZXMsCmFuZCBwcmV2ZW50cyBvdGhlciBtZW1iZXJzIG9mIHRoZSBQSUQgbmFtZXNwYWNlIGZy
b20KYWNjaWRlbnRhbGx5IGtpbGxpbmcgdGhlICJpbml0IiBwcm9jZXNzLgoKTGlrZXdpc2UsIGEg
cHJvY2VzcyBpbiBhbiBhbmNlc3RvciBuYW1lc3BhY2UKY2FuXChlbXN1YmplY3QgdG8gdGhlIHVz
dWFsIHBlcm1pc3Npb24gY2hlY2tzIGRlc2NyaWJlZCBpbgouQlIga2lsbCAoMilcKGVtc2VuZApz
aWduYWxzIHRvIHRoZSAiaW5pdCIgcHJvY2VzcyBvZiBhIGNoaWxkIFBJRCBuYW1lc3BhY2Ugb25s
eQppZiB0aGUgImluaXQiIHByb2Nlc3MgaGFzIGVzdGFibGlzaGVkIGEgaGFuZGxlciBmb3IgdGhh
dCBzaWduYWwuCihXaXRoaW4gdGhlIGhhbmRsZXIsIHRoZQouSSBzaWdpbmZvX3QKLkkgc2lfcGlk
CmZpZWxkIGRlc2NyaWJlZCBpbgouQlIgc2lnYWN0aW9uICgyKQp3aWxsIGJlIHplcm8uKQouQiBT
SUdLSUxMCm9yCi5CIFNJR1NUT1AKYXJlIHRyZWF0ZWQgZXhjZXB0aW9uYWxseToKdGhlc2Ugc2ln
bmFscyBhcmUgZm9yY2libHkgZGVsaXZlcmVkIHdoZW4gc2VudCBmcm9tIGFuIGFuY2VzdG9yIFBJ
RCBuYW1lc3BhY2UuCk5laXRoZXIgb2YgdGhlc2Ugc2lnbmFscyBjYW4gYmUgY2F1Z2h0IGJ5IHRo
ZSAiaW5pdCIgcHJvY2VzcywKYW5kIHNvIHdpbGwgcmVzdWx0IGluIHRoZSB1c3VhbCBhY3Rpb25z
IGFzc29jaWF0ZWQgd2l0aCB0aG9zZSBzaWduYWxzCihyZXNwZWN0aXZlbHksIHRlcm1pbmF0aW5n
IGFuZCBzdG9wcGluZyB0aGUgcHJvY2VzcykuCi5cIgouXCIgPT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci5cIgouU1MgTmVzdGluZyBQ
SUQgbmFtZXNwYWNlcwpQSUQgbmFtZXNwYWNlcyBjYW4gYmUgbmVzdGVkOgplYWNoIFBJRCBuYW1l
c3BhY2UgaGFzIGEgcGFyZW50LApleGNlcHQgZm9yIHRoZSBpbml0aWFsICgicm9vdCIpIFBJRCBu
YW1lc3BhY2UuClRoZSBwYXJlbnQgb2YgYSBQSUQgbmFtZXNwYWNlIGlzIHRoZSBQSUQgbmFtZXNw
YWNlIG9mIHRoZSBwcm9jZXNzIHRoYXQKY3JlYXRlZCB0aGUgbmFtZXNwYWNlIHVzaW5nCi5CUiBj
bG9uZSAoMikKb3IKLkJSIHVuc2hhcmUgKDIpLgpQSUQgbmFtZXNwYWNlcyB0aHVzIGZvcm0gYSB0
cmVlLAp3aXRoIGFsbCBuYW1lc3BhY2VzIHVsdGltYXRlbHkgdHJhY2luZyB0aGVpciBhbmNlc3Ry
eSB0byB0aGUgcm9vdCBuYW1lc3BhY2UuCgpBIHByb2Nlc3MgaXMgdmlzaWJsZSB0byBvdGhlciBw
cm9jZXNzZXMgaW4gaXRzIFBJRCBuYW1lc3BhY2UsCmFuZCB0byB0aGUgcHJvY2Vzc2VzIGluIGVh
Y2ggZGlyZWN0IGFuY2VzdG9yIFBJRCBuYW1lc3BhY2UKZ29pbmcgYmFjayB0byB0aGUgcm9vdCBQ
SUQgbmFtZXNwYWNlLgpJbiB0aGlzIGNvbnRleHQsICJ2aXNpYmxlIiBtZWFucyB0aGF0IG9uZSBw
cm9jZXNzCmNhbiBiZSB0aGUgdGFyZ2V0IG9mIG9wZXJhdGlvbnMgYnkgYW5vdGhlciBwcm9jZXNz
IHVzaW5nCnN5c3RlbSBjYWxscyB0aGF0IHNwZWNpZnkgYSBwcm9jZXNzIElELgpDb252ZXJzZWx5
LCB0aGUgcHJvY2Vzc2VzIGluIGEgY2hpbGQgUElEIG5hbWVzcGFjZSBjYW4ndCBzZWUKcHJvY2Vz
c2VzIGluIHRoZSBwYXJlbnQgYW5kIGZ1cnRoZXIgcmVtb3ZlZCBhbmNlc3RvciBuYW1lc3BhY2Uu
Ck1vcmUgc3VjY2luY3RseTogYSBwcm9jZXNzIGNhbiBzZWUgKGUuZy4sIHNlbmQgc2lnbmFscyB3
aXRoCi5CUiBraWxsKDIpLApzZXQgbmljZSB2YWx1ZXMgd2l0aAouQlIgc2V0cHJpb3JpdHkgKDIp
LApldGMuKSBvbmx5IHByb2Nlc3NlcyBjb250YWluZWQgaW4gaXRzIG93biBQSUQgbmFtZXNwYWNl
CmFuZCBpbiBkZXNjZW5kYW50cyBvZiB0aGF0IG5hbWVzcGFjZS4KCkEgcHJvY2VzcyBoYXMgb25l
IHByb2Nlc3MgSUQgaW4gZWFjaCBvZiB0aGUgbGF5ZXJzIG9mIHRoZSBQSUQKbmFtZXNwYWNlIGhp
ZXJhcmNoeSBpbiB3aGljaCBpcyB2aXNpYmxlLAphbmQgd2Fsa2luZyBiYWNrIHRob3VnaCBlYWNo
IGRpcmVjdCBhbmNlc3RvciBuYW1lc3BhY2UKdGhyb3VnaCB0byB0aGUgcm9vdCBQSUQgbmFtZXNw
YWNlLgpTeXN0ZW0gY2FsbHMgdGhhdCBvcGVyYXRlIG9uIHByb2Nlc3MgSURzIGFsd2F5cwpvcGVy
YXRlIHVzaW5nIHRoZSBwcm9jZXNzIElEIHRoYXQgaXMgdmlzaWJsZSBpbiB0aGUKUElEIG5hbWVz
cGFjZSBvZiB0aGUgY2FsbGVyLgpBIGNhbGwgdG8KLkJSIGdldHBpZCAoMikKYWx3YXlzIHJldHVy
bnMgdGhlIFBJRCBhc3NvY2lhdGVkIHdpdGggdGhlIG5hbWVzcGFjZSBpbiB3aGljaAp0aGUgcHJv
Y2VzcyB3YXMgY3JlYXRlZC4KClNvbWUgcHJvY2Vzc2VzIGluIGEgUElEIG5hbWVzcGFjZSBtYXkg
aGF2ZSBwYXJlbnRzCnRoYXQgYXJlIG91dHNpZGUgb2YgdGhlIG5hbWVzcGFjZS4KRm9yIGV4YW1w
bGUsIHRoZSBwYXJlbnQgb2YgdGhlIGluaXRpYWwgcHJvY2VzcyBpbiB0aGUgbmFtZXNwYWNlCihp
LmUuLCB0aGUKLkJSIGluaXQgKDEpCnByb2Nlc3Mgd2l0aCBQSUQgMSkgaXMgbmVjZXNzYXJpbHkg
aW4gYW5vdGhlciBuYW1lc3BhY2UuCkxpa2V3aXNlLCB0aGUgZGlyZWN0IGNoaWxkcmVuIG9mIGEg
cHJvY2VzcyB0aGF0IHVzZXMKLkJSIHNldG5zICgyKQp0byBjYXVzZSBpdHMgY2hpbGRyZW4gdG8g
am9pbiBhIFBJRCBuYW1lc3BhY2UgYXJlIGluIGEgZGlmZmVyZW50ClBJRCBuYW1lc3BhY2UgZnJv
bSB0aGUgY2FsbGVyIG9mCi5CUiBzZXRucyAoMikuCkNhbGxzIHRvCi5CUiBnZXRwcGlkICgyKQpm
b3Igc3VjaCBwcm9jZXNzZXMgcmV0dXJuIDAuCi5cIgouXCIgPT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci5cIgouU1Mgc2V0bnMoMikg
YW5kIHVuc2hhcmUoMikgc2VtYW50aWNzCkNhbGxzIHRvCi5CUiBzZXRucyAoMikKdGhhdCBzcGVj
aWZ5IGEgUElEIG5hbWVzcGFjZSBmaWxlIGRlc2NyaXB0b3IKYW5kIGNhbGxzIHRvCi5CUiB1bnNo
YXJlICgyKQp3aXRoIHRoZQouQlIgQ0xPTkVfTkVXUElECmZsYWcgY2F1c2UgY2hpbGRyZW4gc3Vi
c2VxdWVudGx5IGNyZWF0ZWQKYnkgdGhlIGNhbGxlciB0byBiZSBwbGFjZWQgaW4gYSBkaWZmZXJl
bnQgUElEIG5hbWVzcGFjZSBmcm9tIHRoZSBjYWxsZXIuClRoZXNlIGNhbGxzIGRvIG5vdCwgaG93
ZXZlciwKY2hhbmdlIHRoZSBQSUQgbmFtZXNwYWNlIG9mIHRoZSBjYWxsaW5nIHByb2Nlc3MsCmJl
Y2F1c2UgZG9pbmcgc28gd291bGQgY2hhbmdlIHRoZSBjYWxsZXIncyBpZGVhIG9mIGl0cyBvd24g
UElECihhcyByZXBvcnRlZCBieQouQlIgZ2V0cGlkICgpKSwKd2hpY2ggd291bGQgYnJlYWsgbWFu
eSBhcHBsaWNhdGlvbnMgYW5kIGxpYnJhcmllcy4KClRvIHB1dCB0aGluZ3MgYW5vdGhlciB3YXk6
CmEgcHJvY2VzcydzIFBJRCBuYW1lc3BhY2UgbWVtYmVyc2hpcCBpcyBkZXRlcm1pbmVkIHdoZW4g
dGhlIHByb2Nlc3MgaXMgY3JlYXRlZAphbmQgY2Fubm90IGJlIGNoYW5nZWQgdGhlcmVhZnRlci4K
QW1vbmcgb3RoZXIgdGhpbmdzLCB0aGlzIG1lYW5zIHRoYXQgdGhlIHBhcmVudGFsIHJlbGF0aW9u
c2hpcApiZXR3ZWVuIHByb2Nlc3NlcyBtaXJyb3JzIHRoZSBwYXJlbnRhbCBiZXR3ZWVuIFBJRCBu
YW1lc3BhY2VzOgp0aGUgcGFyZW50IG9mIGEgcHJvY2VzcyBpcyBlaXRoZXIgaW4gdGhlIHNhbWUg
bmFtZXNwYWNlCm9yIHJlc2lkZXMgaW4gdGhlIGltbWVkaWF0ZSBwYXJlbnQgUElEIG5hbWVzcGFj
ZS4KCkV2ZXJ5IHRocmVhZCBpbiBhIHByb2Nlc3MgbXVzdCBiZSBpbiB0aGUgc2FtZSBQSUQgbmFt
ZXNwYWNlLgpGb3IgdGhpcyByZWFzb24sIHRoZSB0d28gZm9sbG93aW5nIGNhbGwgc2VxdWVuY2Vz
IHdpbGwgZmFpbDoKCi5uZgogICAgdW5zaGFyZShDTE9ORV9ORVdQSUQpOwogICAgY2xvbmUoLi4u
LCBDTE9ORV9WTSwgLi4uKTsgICAgLyogRmFpbHMgKi8KCiAgICBzZXRucyhmZCwgQ0xPTkVfTkVX
UElEKTsKICAgIGNsb25lKC4uLiwgQ0xPTkVfVk0sIC4uLik7ICAgIC8qIEZhaWxzICovCi5maQoK
QmVjYXVzZSB0aGUgYWJvdmUKLkJSIHVuc2hhcmUgKDIpCmFuZAouQlIgc2V0bnMgKDIpCmNhbGxz
IG9ubHkgY2hhbmdlIHRoZSBQSUQgbmFtZXNwYWNlIGZvciBjcmVhdGVkIGNoaWxkcmVuLCB0aGUK
LkJSIGNsb25lICgyKQpjYWxscyBuZWNlc3NhcmlseSBwdXQgdGhlIG5ldyB0aHJlYWQgaW4gYSBk
aWZmZXJlbnQgUElEIG5hbWVzcGFjZSBmcm9tCnRoZSBjYWxsaW5nIHRocmVhZC4KLlwiCi5cIiA9
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT0KLlwiCi5TUyBNaXNjZWxsYW5lb3VzCkFmdGVyIGNyZWF0aW5nIGEgbmV3IFBJRCBuYW1lc3Bh
Y2UsCml0IGlzIHVzZWZ1bCBmb3IgdGhlIGNoaWxkIHRvIGNoYW5nZSBpdHMgcm9vdCBkaXJlY3Rv
cnkKYW5kIG1vdW50IGEgbmV3IHByb2NmcyBpbnN0YW5jZSBhdAouSSAvcHJvYwpzbyB0aGF0IHRv
b2xzIHN1Y2ggYXMKLkJSIHBzICgxKQp3b3JrIGNvcnJlY3RseS4KLlwiIG1vdW50IC10IHByb2Mg
cHJvYyAvcHJvYwooSWYgYSBuZXcgbW91bnQgbmFtZXNwYWNlIGlzIHNpbXVsdGFuZW91c2x5IGNy
ZWF0ZWQgYnkgaW5jbHVkaW5nCi5CUiBDTE9ORV9ORVdOUwppbiB0aGUKLklSIGZsYWdzCmFyZ3Vt
ZW50IG9mCi5CUiBjbG9uZSAoMikKb3IKLkJSIHVuc2hhcmUgKDIpKSwKdGhlbiBpdCBpc24ndCBu
ZWNlc3NhcnkgdG8gY2hhbmdlIHRoZSByb290IGRpcmVjdG9yeToKYSBuZXcgcHJvY2ZzIGluc3Rh
bmNlIGNhbiBiZSBtb3VudGVkIGRpcmVjdGx5IG92ZXIKLklSIC9wcm9jIC4pCgpDYWxsaW5nCi5C
UiByZWFkbGluayAoMikKb24gdGhlIHBhdGgKLkkgL3Byb2Mvc2VsZgp5aWVsZHMgdGhlIHByb2Nl
c3MgSUQgb2YgdGhlIGNhbGxlciBpbiB0aGUgUElEIG5hbWVzcGFjZSBvZiB0aGUgcHJvY2ZzIG1v
dW50CihpLmUuLCB0aGUgUElEIG5hbWVzcGFjZSBvZiB0aGUgcHJvY2VzcyB0aGF0IG1vdW50ZWQg
dGhlIHByb2NmcykuCgpXaGVuIGEgcHJvY2VzcyBJRCBpcyBwYXNzZWQgb3ZlciBhIFVOSVggZG9t
YWluIHNvY2tldCB0byBhCnByb2Nlc3MgaW4gYSBkaWZmZXJlbnQgUElEIG5hbWVzcGFjZSAoc2Vl
IHRoZSBkZXNjcmlwdGlvbiBvZgouQiBTQ01fQ1JFREVOVElBTFMKaW4KLkJSIHVuaXggKDcpKSwK
aXQgaXMgdHJhbnNsYXRlZCBpbnRvIHRoZSBjb3JyZXNwb25kaW5nIFBJRCB2YWx1ZSBpbgp0aGUg
cmVjZWl2aW5nIHByb2Nlc3MncyBQSUQgbmFtZXNwYWNlLgouU0ggQ09ORk9STUlORyBUTwpOYW1l
c3BhY2VzIGFyZSBhIExpbnV4LXNwZWNpZmljIGZlYXR1cmUuCi5TSCBTRUUgQUxTTwouQlIgdW5z
aGFyZSAoMSksCi5CUiBjbG9uZSAoMiksCi5CUiBzZXRucyAoMiksCi5CUiB1bnNoYXJlICgyKSwK
LkJSIHByb2MgKDUpLAouQlIgY3JlZGVudGlhbHMgKDcpLAouQlIgY2FwYWJpbGl0aWVzICg3KSwK
LkJSIHVzZXJfbmFtZXNwYWNlcyAoNyksCi5CUiBzd2l0Y2hfcm9vdCAoOCkK
--14dae93b5e363e233f04d6c72253
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--14dae93b5e363e233f04d6c72253--
